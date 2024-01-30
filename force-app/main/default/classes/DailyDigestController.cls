public class DailyDigestController {
    public String Image1Link{get;set;}
    public String Image2Link{get;set;}
    public String footerImageLink{get;set;}
    public String description{get;set;}
    public String regards{get;set;}
    public String referrerId{get;set;}
    public Contact referrer{get;set;}
    public Integer noOfInProgressOpp{get;set;}
    public Integer noOfApprovedOpp{get;set;}
    public Integer noOfCompletedOpp{get;set;}
    public Integer noOfSettlementsOpp{get;set;}
    public Integer noOfReferralsOpp{get;set;}
    public Map<String, String> nameAbbrMap{set;get;}
    public Map<String, String> oppStageChangedMap{set;get;}
    public Map<String, Boolean> oppTodayActivityMap{set;get;}
    public List<Opportunity> allOppList{set;get;}
    public Map<String, Map<String, Map<String, List<Task>>>> oppTasksMap{set;get;}
    public Map<String, Map<String, Map<String, List<Event>>>> oppEventsMap{set;get;}
    public Map<String, Map<String, Boolean>> oppStatusBlankCheckMap{set;get;}
    public Boolean init{
        get{
            init();
            return false;
        }
    }        
    public DailyDigestController(){
        Image1Link = Daily_Digest_Images__c.getValues('Image1').Text__c;
        Image2Link = Daily_Digest_Images__c.getValues('Image2').Text__c;
        footerImageLink = Daily_Digest_Images__c.getValues('FooterImage').Text__c;
        description = Daily_Digest_Images__c.getValues('description').Text__c;
        regards = Daily_Digest_Images__c.getValues('regards').Text__c;
        noOfInProgressOpp = 0;
        noOfApprovedOpp = 0;
        noOfCompletedOpp = 0;
    }
    public void init(){
        Set<String> oppIds = New Set<String>();
        nameAbbrMap = New Map<String, String>();
        oppStageChangedMap = New Map<String, String>();
        allOppList = New List<Opportunity> ();
        oppStatusBlankCheckMap = New Map<String, Map<String, Boolean>> ();
        oppTodayActivityMap = New Map<String, Boolean>();
        noOfInProgressOpp = 0;
        noOfApprovedOpp = 0;
        noOfCompletedOpp = 0;
        noOfSettlementsOpp = 0;
        noOfReferralsOpp = 0;
        referrer = [SELECT Id, Name, Account.Name,Referrer_Rating__c,
                    (SELECT Id, Name, StageName, RecordType.Name, Loan_Amount__c, OwnerId, Owner.Name
                     FROM FinServ__OpportunityContactReferrals__r ORDER BY StageName)
                    FROM Contact WHERE Id =: referrerId];
        noOfReferralsOpp = referrer.FinServ__OpportunityContactReferrals__r.size();
        for(Opportunity opp: referrer.FinServ__OpportunityContactReferrals__r){
            oppIds.add(opp.Id);
            if(('Approved').EqualsIgnoreCase(opp.StageName) || ('Docs Signed').EqualsIgnoreCase(opp.StageName) || ('Settlement Booked').EqualsIgnoreCase(opp.StageName)){
                noOfApprovedOpp++;
            }else if(('Settled (closed won)').EqualsIgnoreCase(opp.StageName) || ('Closed Lost').EqualsIgnoreCase(opp.StageName)){
                noOfCompletedOpp++;
            }else{
                noOfInProgressOpp++;
            }
            
            if(('Settled (closed won)').EqualsIgnoreCase(opp.StageName) || ('Settlement Booked').EqualsIgnoreCase(opp.StageName)){
                noOfSettlementsOpp++;
            }
            allOppList.add(opp);
            nameAbbrMap.put(opp.Id,getAbbr(opp.Name));
        }
        oppTasksMap = New Map<String, Map<String, Map<String, List<Task>>>>();
        oppEventsMap = New Map<String, Map<String, Map<String, List<Event>>>>();
        DateTime yesterdayDateTime6PM = DateTime.newInstance(Date.Today(),Time.newInstance(18, 0, 0, 0));
        List<Opportunity> oppList = [SELECT Id, Owner.Name, OwnerId,
                                     (SELECT Id, Old_Stage__c, New_Stage__c
                                      FROM Stage_tracking__r WHERE CreatedDate = TODAY ORDER BY Name DESC LIMIT 1),
                                     (SELECT Id, Subject, Owner.Name, OwnerId, Who.Name, WhoId, What.Name, CreatedBy.Name,Description, Call_Purpose__c, Event_Type__c, 
                                      Event_Result__c,ActivityDate, Make_Activity_Private__c, Make_Comments_Public__c, CompletedDateTime  
                                      FROM Tasks WHERE TaskSubtype != 'Email'  AND Make_Activity_Private__c = FALSE AND
                                      (ActivityDate >= TODAY OR (CompletedDateTime = YESTERDAY AND CreatedDate >=: yesterdayDateTime6PM ))), 
                                     (SELECT Id, Subject, Owner.Name, OwnerId, Who.Name, WhoId, CreatedBy.Name, Description, Call_Purpose__c, Event_Type__c, Event_Result__c,
                                      ActivityDate, Call_Origin__c,  EndDate, EventSubtype, ShowAs,Make_Activity_Private__c, Make_Comments_Public__c, EndDateTime  
                                      FROM Events WHERE (ActivityDate >= TODAY OR (EndDate = YESTERDAY AND CreatedDate >=: yesterdayDateTime6PM )) AND Make_Activity_Private__c = FALSE)
                                     FROM Opportunity WHERE Id In: oppIds ORDER BY StageName];
        for(Opportunity opp: oppList){
            String stageChanged ='nochange';
            if(!opp.Stage_tracking__r.isEmpty()){
                stageChanged = opp.Stage_tracking__r[0].Old_Stage__c + ' --> ' + opp.Stage_tracking__r[0].New_Stage__c;
            }
            oppStageChangedMap.put(opp.Id,stageChanged);
            oppTodayActivityMap.put(opp.Id, false);

            for(Task tk: opp.Tasks){
                Integer daysDiff = (Date.today()).daysBetween(tk.ActivityDate) ;
                String days = daysDiff<=0 ? 'Today': daysDiff== 1 ? '1 Day': daysDiff + ' Days';
                String todayNxt = daysDiff<=0 ? 'Today': 'Next';
                if(todayNxt == 'Today'){
                   oppTodayActivityMap.put(opp.Id, true); 
                }
                Map<String, Map<String, List<Task>>> todayNxtMap = oppTasksMap.get(opp.Id);
                if(todayNxtMap == NULL){
                    todayNxtMap = New Map<String, Map<String, List<Task>>>();
                }
                
                Map<String, List<Task>> daysTasksMap = todayNxtMap.get(todayNxt);
                if(daysTasksMap == NULL){
                    daysTasksMap = New  Map<String, List<Task>>();
                }
                List<Task> lstTasks = daysTasksMap.get(days);
                if(lstTasks == NULL){
                    lstTasks = New List<Task>();
                }
                lstTasks.add(tk);
                daysTasksMap.put(days, lstTasks);
                todayNxtMap.put(todayNxt,daysTasksMap);
                oppTasksMap.put(opp.Id, todayNxtMap);

                nameAbbrMap.put(tk.OwnerId, getAbbr(tk.Owner.Name));
                if(tk.Who.Name != null)
                nameAbbrMap.put(tk.WhoId, getAbbr(tk.Who.Name));
            }
            
            for(Event ev: opp.Events){
                Integer daysDiff = (Date.today()).daysBetween(ev.ActivityDate) ;
                String days = daysDiff<=0 ? 'Today': daysDiff== 1 ? '1 Day': daysDiff + ' Days';
                String todayNxt = daysDiff<=0 ? 'Today': 'Next';
                if(todayNxt == 'Today'){
                   oppTodayActivityMap.put(opp.Id, true); 
                }
                Map<String, Map<String, List<Event>>> todayNxtMap = oppEventsMap.get(opp.Id);
                if(todayNxtMap == NULL){
                    todayNxtMap = New Map<String, Map<String, List<Event>>>();
                }
                
                Map<String, List<Event>> daysEventsMap = todayNxtMap.get(todayNxt);
                if(daysEventsMap == NULL){
                    daysEventsMap = New  Map<String, List<Event>>();
                }
                List<Event> lstEvents = daysEventsMap.get(days);
                if(lstEvents == NULL){
                    lstEvents = New List<Event>();
                }
                lstEvents.add(ev);
                daysEventsMap.put(days, lstEvents);
                todayNxtMap.put(todayNxt,daysEventsMap);
                oppEventsMap.put(opp.Id, todayNxtMap);
                nameAbbrMap.put(ev.OwnerId, getAbbr(ev.Owner.Name));
                if(ev.Who.Name != null)
                    nameAbbrMap.put(ev.WhoId, getAbbr(ev.Who.Name));
            }
            Map<String, Boolean> isBlankMap = New Map<String, Boolean>();
            if((oppTasksMap.containsKey(opp.Id) && oppTasksMap.get(opp.Id).containsKey('Today')) ||
                (oppEventsMap.containsKey(opp.Id) && oppEventsMap.get(opp.Id).containsKey('Today'))){
                    isBlankMap.put('Today', false);
                    oppStatusBlankCheckMap.put(opp.Id, isBlankMap);
            }else{
                isBlankMap.put('Today', true);
               oppStatusBlankCheckMap.put(opp.Id, isBlankMap);
            }
            
            if((oppTasksMap.containsKey(opp.Id) && oppTasksMap.get(opp.Id).containsKey('Next')) ||
                (oppEventsMap.containsKey(opp.Id) && oppEventsMap.get(opp.Id).containsKey('Next'))){
                    isBlankMap.put('Next', false);
                    oppStatusBlankCheckMap.put(opp.Id, isBlankMap);
            }else{
                isBlankMap.put('Next', true);
                oppStatusBlankCheckMap.put(opp.Id, isBlankMap);
            }            
            System.debug('@@@@oppEventsMap' + oppEventsMap);
            nameAbbrMap.put(opp.OwnerId, getAbbr(opp.Owner.Name));
        }
        System.debug('@@@@oppStatusBlankCheckMap' + oppStatusBlankCheckMap);
    }
    
    private string getAbbr(String name){
        List<String> abbList = ((name.remove(',')).toUpperCase()).split(' ');
        while(abbList.contains('')){
            Integer indx = abbList.indexOf('');
            abbList.remove(indx);
        }
        return abbList[0].substring(0, 1) + (abbList.size()>1 && abbList[1].equalsIgnoreCase('and') ?(abbList.size()>2 ? abbList[2].substring(0, 1):'') : abbList[1].substring(0, 1));
    //return '';
    }
}