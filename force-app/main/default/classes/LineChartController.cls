public class LineChartController {
    private static Map<Integer, String> monthNameMap = New Map<Integer, String>{
        1 => 'Jan', 2 => 'Feb', 3 => 'Mar', 4 => 'Apr', 5 => 'May', 6 => 'Jun', 7 => 'Jul', 8 => 'Aug', 9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Dec'};
    @auraEnabled
    public static String getStages(){
        String stagesName = '';
        List<String> appSectionsList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            appSectionsList.add(f.getLabel());
            stagesName += '{\"label\":\"' + f.getLabel() +'\",\"value\": \"'+ f.getLabel() +'\"},';
        } 
        stagesName = '[' + stagesName.removeEnd(',') + ']';
        return stagesName;
    }
    
    @auraEnabled
    public static String getChartData(String lender, String adviser, String loanType, List<String>stagesList, DateTime stageStartDate, DateTime stageEndDate){
        try{
            BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
            Map<String, List<StagesWrapper>> oppStageWpr = New Map<String, List<StagesWrapper>>();
            Boolean isWhere = false;
            Boolean isSTWhere = false;
            stageStartDate = DateTime.newInstance(stageStartDate.date(),Time.newInstance(0, 0, 0, 0));
            stageEndDate = DateTime.newInstance(stageEndDate.date(),Time.newInstance(23, 59, 59, 0));
            List<StagesWrapper> stagesWrpList = New List<StagesWrapper>();
            String queryStr = 'SELECT Id, Opportunity__r.StageName, Opportunity__r.Lender__c, Opportunity__r.RecordType.Name, Opportunity__r.Owner.Name, ';
            queryStr +='Opportunity__c, Duration_Bus_Days__c, Old_Stage__c, Last_Stage_Change_Date__c, ';
            queryStr +='New_Stage__c, Time_at_current_stage__c, Stage_Changing_Date__c, New_Stage_End_Date__c, ';
            queryStr +='New_Stage_Duration__c ';
            queryStr +='FROM Stage_Tracking__c ';
            
            
            if(!stagesList.isEmpty()){
                if(!isSTWhere){
                    isSTWhere = true;
                    queryStr +=' WHERE ';
                }else{
                    queryStr +=' AND ';
                }
                String stagesListStr = '';
                for(String st: stagesList){
                    stagesListStr += '\'' + st + '\',';
                }
                queryStr +=' New_Stage__c IN (' + stagesListStr.removeEnd(',') +')';
            }
            if(stageStartDate != NULL){
                if(!isSTWhere){
                    isSTWhere = true;
                    queryStr +=' WHERE ';
                }else{
                    queryStr +=' AND ';
                }
                queryStr +=' (New_Stage_End_Date__c >= :stageStartDate OR New_Stage_End_Date__c = NULL) ';
            }
            if(String.isNotBlank(lender)){
                if(!isSTWhere){
                    isSTWhere = true;
                    queryStr +=' WHERE ';
                }else{
                    queryStr +=' AND ';
                }
                if(lender.contains(';')){
                    String lstStr = '';
                    for(String str : lender.split(';')){
                        lstStr += ' Opportunity__r.Lender__c like \'%' +str+'%\' OR';
                    }
                    queryStr +=' (' + lstStr.removeEnd('OR') +')';
                }else{
                    queryStr +=' Opportunity__r.Lender__c like \'%' +lender+'%\' ';
                }
            }
            
            if(String.isNotBlank(adviser)){
                if(!isSTWhere){
                    isSTWhere = true;
                    queryStr +=' WHERE ';
                }else{
                    queryStr +=' AND ';
                }
                if(adviser.contains(';')){
                    String lstStr = '';
                    for(String str : adviser.split(';')){
                        lstStr += ' Opportunity__r.Owner.Name like \'%' +str+'%\' OR';
                    }
                    queryStr +=' (' + lstStr.removeEnd('OR') +')';
                }else{
                    queryStr +=' Opportunity__r.Owner.Name like \'%' +adviser+'%\' ';
                }
            }
            
            if(String.isNotBlank(loanType)){
                if(!isSTWhere){
                    isSTWhere = true;
                    queryStr +=' WHERE ';
                }else{
                    queryStr +=' AND ';
                }
                if(loanType.contains(';')){
                    String lstStr = '';
                    for(String str : loanType.split(';')){
                        lstStr += ' Opportunity__r.RecordType.Name like \'%' +str+'%\' OR';
                    }
                    queryStr +=' (' + lstStr.removeEnd('OR') +')';
                }else{
                    queryStr +=' Opportunity__r.RecordType.Name like \'%' +loanType+'%\' ';
                }
            }
            queryStr +=' LIMIT 10000';
            System.debug('queryStr' + queryStr);
            
            LIST<Stage_Tracking__c>stageTrackingList = Database.query(queryStr);
            System.debug('stageTrackingList' + stageTrackingList.size());
            
            for(Stage_Tracking__c st: stageTrackingList){
                stagesWrpList = oppStageWpr.get(st.Opportunity__c);
                if(stagesWrpList ==NULL){
                    stagesWrpList = New List<StagesWrapper>();
                }
                Double newStageDuration = getDuration(bh.Id, st.Stage_Changing_Date__c, st.New_Stage_End_Date__c);
                if(newStageDuration > 1 ){
                    
                    DateTime startDate = st.Stage_Changing_Date__c;
                    DateTime currentDateTime = stageEndDate==NULL ? DateTime.now() : stageEndDate;
                    DateTime endDate = st.New_Stage_End_Date__c == NULL ? currentDateTime : st.New_Stage_End_Date__c;
                    Integer i=1;
                    Decimal duration = 0;
                    while(startDate.date() <= endDate.date()){
                        if( startDate.format('EEEE').EqualsIgnoreCase('Saturday') || startDate.format('EEEE').EqualsIgnoreCase('Sunday')){
                            startDate = startDate.addDays(1);
                            continue;
                        }
                        if(st.Stage_Changing_Date__c == startDate){
                            duration = ((24-((Decimal)startDate.hour() + ((Decimal)startDate.minute()/60)))/24).setScale(2);
                        }else {
                            duration +=1;
                        }
                        StagesWrapper stw = New StagesWrapper(); 
                        stw.lender = st.Opportunity__r.Lender__c;
                        stw.loanType = st.Opportunity__r.RecordType.Name;
                        stw.adviser = st.Opportunity__r.Owner.Name;
                        stw.stage = st.New_Stage__c;  
                        stw.duration = newStageDuration > duration ? duration : newStageDuration;
                        stw.stageDate = startDate.date();
                        stagesWrpList.add(stw);
                        i++;
                        startDate = startDate.addDays(1);
                    }
                }else{
                    StagesWrapper stw = New StagesWrapper(); 
                    stw.lender = st.Opportunity__r.Lender__c;
                    stw.loanType = st.Opportunity__r.RecordType.Name;
                    stw.adviser = st.Opportunity__r.Owner.Name;
                    stw.stage = st.New_Stage__c;
                    stw.duration = newStageDuration;
                    stw.stageDate = st.Stage_Changing_Date__c.date();
                    stagesWrpList.add(stw);
                }
                if(!stagesWrpList.isEmpty()){
                    oppStageWpr.put(st.Opportunity__c, stagesWrpList);
                }
            }
            
            
            String dateListStr = '';
            String data = '';
            String stagesName = '';
            Map<String, Map<Date, Map<String, Decimal>>> stageDurationCountMap = New Map<String, Map<Date, Map<String, Decimal>>>();
            Set<Date> dateSet = New Set<Date>();
            
            for(String oppId: oppStageWpr.keySet()){
                for(StagesWrapper stw: oppStageWpr.get(oppId)){
                    Datetime tmpDate = DateTime.newInstance(stw.stageDate, Time.newInstance(0, 0, 0, 0));
                    if(!(tmpDate.format('EEEE').EqualsIgnoreCase('Saturday') || tmpDate.format('EEEE').EqualsIgnoreCase('Sunday'))){
                        if(stw.stageDate < stageStartDate || stw.stageDate > stageEndDate) continue;
                        	dateSet.add(stw.stageDate);
                    }
                    
                    Map<Date, Map<String, Decimal>> dtDurCntMap = stageDurationCountMap.get(stw.stage);
                    if(dtDurCntMap == NULL){
                        dtDurCntMap = New Map<Date, Map<String, Decimal>>();
                    }
                    Map<String, Decimal> durCntMap = dtDurCntMap.get(stw.stageDate);
                    if(durCntMap == NULL){
                        durCntMap = New Map<String, Decimal>();
                    }
                    
                    Decimal duration = durCntMap.get('duration');
                    if(duration == NULL){
                        duration = 0;
                    }
                    
                    Decimal count = durCntMap.get('count');
                    if(count == NULL){
                        count = 0;
                    }
                    duration += stw.duration == NULL ? 0 :stw.duration;
                    count++;
                    durCntMap.put('duration',duration);
                    durCntMap.put('count',count);
                    dtDurCntMap.put(stw.stageDate,durCntMap);
                    stageDurationCountMap.put(stw.stage, dtDurCntMap);
                }
            }
            
            boolean isAddDate = true;
            List<Date> dateList = New List<Date>();
            dateList.addAll(dateSet);
            dateList.sort();
            
            for(Date dt: dateList){
                String dateStr = dt.day() + ' ' + monthNameMap.get(dt.month()) + ' ' + (''+dt.year()).substring(2,4);
                System.debug('date-->' + dateStr);
                dateListStr += '\"' + dateStr + '\",';
            }
            for(String stage: stageDurationCountMap.keySet()){
                stagesName += '{\"label\":\"' + stage +'\",\"value\": \"'+ stage +'\"},';
                data += '{\"name\":\"' + stage +'\",\"data\": [';
                for(Date dt: dateList){
                    String dateStr = dt.day() + ' ' + monthNameMap.get(dt.month()) + ' ' + (''+dt.year()).substring(2,4);
                    if(stageDurationCountMap.get(stage).containsKey(dt)){
                        Decimal val = ((stageDurationCountMap.get(stage).get(dt).get('duration')/stageDurationCountMap.get(stage).get(dt).get('count')).setScale(1));
                        data += val +',';
                    }else{
                        data += '0,';
                    }
                }   
                data = data.removeEnd(',');
                data += ']},';
            }
            data = data.removeEnd(',');
            dateListStr = '[' + dateListStr.removeEnd(',') + ']';
            stagesName = '[' + stagesName.removeEnd(',') + ']';
            return '{\"stages\": '+stagesName+', \"dates\":' + dateListStr + ', \"data\":[' + data + ']}';
        }catch(Exception e){
            return '';
        }
    }
    public static Double getDuration(Id bhId, DateTime startDate, DateTime endDate){
        endDate = endDate == Null? System.now() : endDate;
        long hours = (BusinessHours.diff(bhId ,startDate, endDate)/1000/60/60);
        integer durDays = (integer)hours/24; 
        integer mod = math.mod((integer)hours, 24);
        return (durDays+(mod/24.0));
    }
    public class StagesWrapper{
        public Date stageDate{get;set;}
        public String lender{get;set;}
        public String loanType{get;set;}
        public String adviser{get;set;}
        public String stage{get;set;}
        public Decimal duration{get;set;}
    }
}