public class OppActivitiesTimeLineController {
    @auraEnabled
    public static List<activityWrapper> getActivities(String oppId){
        List<activityWrapper> activityWrapperList = New List<activityWrapper>();
        Map<String, String> iconMap = New Map<String, String>{
            'Call' => 'standard:log_a_call',
            'Task' => 'standard:task',
            'Event' => 'standard:event',
            'Email' => 'standard:email'
        };
        
        Map<DateTime,List<activityWrapper>> activityWprMap = New Map<DateTime,List<activityWrapper>>();
        Opportunity opp = [SELECT Id, Owner.Name, OwnerId,
                           (SELECT Id, Subject, Owner.Name, OwnerId, Who.Name, WhoId, What.Name, CreatedBy.Name,Description, Call_Purpose__c, Event_Type__c, 
                            Event_Result__c,ActivityDate, Make_Activity_Private__c, Make_Comments_Public__c, Is_Stage_Changed__c ,CallType, CreatedDate,
                            TaskSubtype, CompletedDateTime,Status
                            FROM Tasks WHERE ActivityDate !=NULL ORDER BY CreatedDate), 
                           (SELECT Id, Subject, Owner.Name, OwnerId, Who.Name, WhoId, CreatedBy.Name, Description, Call_Purpose__c, Event_Type__c, Event_Result__c,
                            ActivityDate, Call_Origin__c,  EndDate, EventSubtype, ShowAs,Make_Activity_Private__c, Make_Comments_Public__c, CreatedDate,
                            Is_Stage_Changed__c, EndDateTime
                            FROM Events  WHERE ActivityDate !=NULL  ORDER BY CreatedDate)
                           FROM Opportunity WHERE Id =: oppId];
        List<ContentDocumentLink> conLinks = 
            [SELECT Id, ContentDocumentId from ContentDocumentLink where LinkedEntityId =: oppId];
        
        Set<Id> contentDocIds = New Set<Id>();
        for(ContentDocumentLink cdl: conLinks){
            contentDocIds.add(cdl.ContentDocumentId);
        }
        List<ContentNote> contentNotesList = [select Id, Title, FileType, TextPreview, Owner.Name, CreatedDate 
                                              from ContentNote where Id =:contentDocIds AND FileType = 'SNOTE'];

        for(ContentNote cn: contentNotesList){
            List<activityWrapper> activityWprList = activityWprMap.get(cn.CreatedDate.Date());
            if(activityWprList == NULL){
                activityWprList = New List<activityWrapper>();
            }
            DateTime activityDateTime = cn.CreatedDate;
            activityWrapper actWpr = New activityWrapper();
            actWpr.subject = cn.Title;
            actWpr.type = 'Note';
            actWpr.description = cn.TextPreview;
            actWpr.fromMsg = opp.Owner.Name;
            actWpr.toMsg = cn.Owner.Name;
            actWpr.isNext = false;
            actWpr.isStage = false;
            actWpr.iconName = 'standard:note';
            actWpr.isMonthChange = false;      
            actWpr.activityDate = cn.CreatedDate.Date();
            actWpr.activityDateStr = ''+ activityDateTime.formatGMT('dd/MM/yy hh:mm a');
            activityWprList.add(actWpr);
            activityWprMap.put(cn.CreatedDate, activityWprList);
        }
        for(Task tk: opp.Tasks){
            List<activityWrapper> activityWprList = activityWprMap.get(tk.ActivityDate);
            if(activityWprList == NULL){
                activityWprList = New List<activityWrapper>();
            }
            DateTime activityDateTime = DateTime.newInstance(tk.ActivityDate,Time.newInstance(0, 0, 0, 0));
            activityWrapper actWpr = New activityWrapper();
            actWpr.subject = tk.Subject;
            actWpr.type = tk.TaskSubtype;
            actWpr.purpose = tk.Call_Purpose__c;
            actWpr.description = tk.Description;
            actWpr.fromMsg = opp.Owner.Name;
            actWpr.toMsg = tk.Owner.Name;
            actWpr.isNext = false;
            actWpr.isStage = tk.Is_Stage_Changed__c;
            actWpr.iconName = iconMap.containsKey(tk.TaskSubtype) ? iconMap.get(tk.TaskSubtype) : 'standard:task';
            actWpr.isMonthChange = false;      
            actWpr.activityDate = tk.ActivityDate;
            actWpr.activityDateStr = ''+ activityDateTime.formatGMT('dd/MM/yy hh:mm a');
            activityWprList.add(actWpr);
            if(tk.ActivityDate > tk.CreatedDate.Date()){
                if(('Completed').equalsIgnoreCase(tk.Status)){
                    activityWprMap.put(tk.CompletedDateTime,activityWprList);
                }else{
                    activityWprMap.put(DateTime.newInstance(tk.ActivityDate,Time.newInstance(0, 0, 0, 0)),activityWprList);
                }
            }else{
                activityWprMap.put(tk.CreatedDate,activityWprList);
            }
        }
        for(Event ev: opp.Events){
            List<activityWrapper> activityWprList = activityWprMap.get(ev.ActivityDate);
            if(activityWprList == NULL){
                activityWprList = New List<activityWrapper>();
            }
            DateTime activityDateTime = ev.CreatedDate;//DateTime.newInstance(ev.ActivityDate,Time.newInstance(0, 0, 0, 0));
            activityWrapper actWpr = New activityWrapper();
            actWpr.subject = ev.Subject;
            actWpr.type = ev.EventSubtype;
            actWpr.purpose = ev.Call_Purpose__c;
            actWpr.description = ev.Description;
            actWpr.fromMsg = opp.Owner.Name;
            actWpr.toMsg = ev.Owner.Name;
            actWpr.isNext = false;
            actWpr.isStage = ev.Is_Stage_Changed__c; 
            actWpr.iconName = iconMap.containsKey(ev.EventSubtype) ? iconMap.get(ev.EventSubtype) :'standard:event';
            actWpr.isMonthChange = false;     
            actWpr.activityDate = ev.ActivityDate;
            actWpr.activityDateStr = ''+ activityDateTime.formatGMT('dd/MM/yy hh:mm a');
            activityWprList.add(actWpr);
            System.debug('>>>>>'+ev.EndDateTime  +'----------'+ ev.CreatedDate.Date());
            if(ev.EndDateTime > ev.CreatedDate){
                activityWprMap.put(ev.EndDateTime,activityWprList);
            }else{
                activityWprMap.put(ev.CreatedDate,activityWprList);
            }
            
        }
        Date monthChanged;
        Boolean isNext = false;

        List<DateTime>dateList = New List<DateTime>(activityWprMap.keySet());
        dateList.sort();
        for(DateTime dt: dateList){
            System.debug('>>>>>>>>>>' + dt);
            if(dt.Date() > Date.today()){
                if(!isNext){
                    activityWrapper actWpr = New activityWrapper();
                    actWpr.activityDateStr = 'Next Steps';
                    actWpr.isNext = true;
                    actWpr.iconName = 'standard:event';
                    actWpr.isStage = false;  
                    actWpr.isMonthChange = true;  
                    activityWrapperList.add(actWpr);
                    isNext = true;
                }
            }
            if(monthChanged == NULL || monthChanged.month() != dt.month() || monthChanged.year() != dt.year()){
                activityWrapper actWpr = New activityWrapper();
                actWpr.activityDateStr = DateTime.newInstance(dt.Date(),Time.newInstance(0, 0, 0, 0)).format('MMMMM yyyy');
                actWpr.isNext = dt.Date() > Date.today();
                actWpr.isStage = false;  
                actWpr.isMonthChange = true; 
                
                activityWrapperList.add(actWpr);
                monthChanged = dt.Date();
            }
            if(dt.date() > Date.today()){
                for(activityWrapper act: activityWprMap.get(dt)){
                    act.isNext = true;
                    act.activityDateStr = 'Estimated ' + act.activityDateStr;
                    activityWrapperList.add(act);
                }
            }else{
                activityWrapperList.addAll(activityWprMap.get(dt));
            }
            
        }        
        return activityWrapperList;
    }
    
    public class activityWrapper{
        @AuraEnabled public String subject;
        @AuraEnabled public String type;
        @AuraEnabled public String purpose;
        @AuraEnabled public String description;
        @AuraEnabled public String fromMsg;
        @AuraEnabled public String toMsg;
        @AuraEnabled public String iconName;
        @AuraEnabled public String activityDateStr;
        @AuraEnabled public Date activityDate;
        @AuraEnabled public Boolean isNext;
        @AuraEnabled public Boolean isStage;
        @AuraEnabled public Boolean isMonthChange;
    }
}