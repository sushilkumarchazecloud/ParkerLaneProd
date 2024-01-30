global class StageTrackerReportScheduler  implements Schedulable {
    global void execute(SchedulableContext sc){
        try{
            
            executeCreate();
        }catch(exception e){
            UtilityClass.createException('', 'StageTrackerReportScheduler', 'execute', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());

        }
    }
	
    global void executeCreate(){
        
        Map<Id, Opportunity> oppStageTrackingMap = New Map<Id, Opportunity>();
        
        Map<String, Map<String, Decimal>> stageWithDurationMap = New Map<String, Map<String, Decimal>>();

        for(Opportunity opp: [SELECT Id,Time_at_current_stage__c, StageName FROM Opportunity LIMIT 50000]){
                                  
            System.debug('@@@@opp= '+ opp);
            Map<String, Decimal> durationMap = stageWithDurationMap.get(opp.StageName);
            
            if(durationMap == NULL){
                durationMap = New Map<String, Decimal>();
                durationMap.put('count', 0);
                durationMap.put('duration', 0);
            }
            
            durationMap.put('count', durationMap.get('count') + 1);
            durationMap.put('duration', durationMap.get('duration') + (opp.Time_at_current_stage__c == NULL ? 0 : opp.Time_at_current_stage__c));
            stageWithDurationMap.put(opp.StageName, durationMap);
        }
        List<Average_Stage_Tracker__c> avrgStageTrackerList = New List<Average_Stage_Tracker__c>();
        for(String st: getStages()){
            Decimal duration = 0;
            if(stageWithDurationMap.containsKey(st) && stageWithDurationMap.get(st).get('count') > 0){
                duration = stageWithDurationMap.get(st).get('duration')/stageWithDurationMap.get(st).get('count');
            }
            Average_Stage_Tracker__c aStageTracker = New Average_Stage_Tracker__c(
                Average_Stage_Duration__c  = duration,
                Date__c = Date.today(),
                Stage_Name__c = st
            );
            avrgStageTrackerList.add(aStageTracker);
        }
        insert avrgStageTrackerList;
        
    }
    
    private List<String> getStages(){
        List<String> appSectionsList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            appSectionsList.add(f.getLabel());
        }   
        return appSectionsList;
    }
}