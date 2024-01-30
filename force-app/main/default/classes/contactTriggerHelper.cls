public class contactTriggerHelper {
    public void SendEmailToReferrer(List<contact> conList){
        String recTypeName = 'Referrer';
        EmailTemplate emailTemplate = [SELECT Id,Subject, Body FROM EmailTemplate WHERE DeveloperName = 'Welcome_For_Referrer' ];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Set<id> AccId = new Set<id>();
        for(contact con : conList){
            accId.add(con.AccountId);
        }
        Map<id, Boolean> checkRef = new Map<id, Boolean>();
        for(account acc : [Select Id, On_Board_Referral__c from Account where Id In: AccId]){
            if(acc.On_Board_Referral__c){
                if(!checkRef.containsKey(acc.Id)){
                    checkRef.put(acc.Id, true);
                }
            }
        }
        System.debug('checkRefcheckRef'+checkRef);
        List<Contact_Tracking__c> statusTrackingList = new List<Contact_Tracking__c>();
        for(contact con : conList){
            String recTyname = Schema.SObjectType.contact.getRecordTypeInfosById().get(con.RecordTypeId).getDeveloperName();
            SYstem.debug('recordTY'+recTyname);
            if(recTyname == recTypeName && checkRef.get(con.AccountId) == true){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(emailTemplate.id);
                email.setTargetObjectId(con.Id);
                email.setTreatTargetObjectAsRecipient(false);
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'personalapplications@parkerlane.com.au'];
                if(owea != null){
                    if ( owea.size() > 0 ) {
                        email.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                }
                email.setReplyTo('personalapplications@parkerlane.com.au');
                email.saveAsActivity = true;
                string[] to = new string[] {con.email};
                    email.setToAddresses(to);
                mails.add(email);
            }
            if(recTyname == recTypeName){
                Contact_Tracking__c ct  = new Contact_Tracking__c();
                ct.New_Value__c = con.Referrer_Status__c;
                ct.Field_Name__c = 'Referrer Status';
                ct.New_Date__c = System.Datetime.now();
                ct.Contact__c= con.id;
                ct.count__c = 1;
                statusTrackingList.add(ct);
                Contact_Tracking__c ct2 = new Contact_Tracking__c();
                ct2.New_Value__c = con.Referrer_Rating__c;
                ct2.Field_Name__c = 'Referrer Rating';
                ct2.New_Date__c = System.Datetime.now();
                ct2.Contact__c = con.id;
                ct2.count__c = 1;
                statusTrackingList.add(ct2);
            }
        }
        try{
            if(mails != null && mails.size() > 0){
                Messaging.sendEmail(mails);
            }
            if(!statusTrackingList.isEmpty()){
                insert statusTrackingList;
            }
        }catch(Exception ex){
            Exception__c eror = new Exception__c();
            eror.Class_Name__c = 'new referrer Customer';
            eror.Method_Name__c = 'Contact Trigger';
            eror.Error_Message__c = ex.getMessage() + '' + ex.getLineNumber();
            insert eror;
        }
    }
    public void AfterUpdate(list<Contact> newlist, list<Contact> oldlist, map<id,Contact> newmap, map<id,Contact> oldmap){
        Set<id> conIds = newmap.keySet();
        Map<Id, Map<String, Decimal>> oppStageCount = New Map<Id, Map<String, Decimal>>();
        Map<id,contact> conMap = new Map<id,contact>([select id,Referrer_Rating__c,Referrer_Status__c,
                                                      (select id,Contact__c,New_Value__c,Old_Value__c,Field_Name__c,New_Date__c,count__c,Previous_Date__c
                                                       FROM Contact_Trackings__r ORDER BY Previous_Date__c DESC NULLS FIRST)
                                                      FROM contact WHERE ID IN: conIds]);
        for(Contact con: conMap.values()){
            Map<String, Decimal> stCount = oppStageCount.get(con.Id);
            if(stCount == NULL){
                stCount = New Map<String, Decimal>();
            }
            for(Contact_Tracking__c st: con.Contact_Trackings__r){
                Decimal count = stCount.get(st.New_Value__c);
                if(count == NULL){
                    count = 0;
                }
                count++;
                stCount.put(st.New_Value__c, count);
            }
            oppStageCount.put(con.Id, stCount);
        }
        CreateContactTrackingRecords(newlist, oldmap, oppStageCount, conMap);
    }
    public static void CreateContactTrackingRecords(List<Contact> newContact, Map<ID, Contact> oldOpportunityMap, Map<Id, Map<String, Decimal>> oppStageCount, Map<Id,Contact> oppMap){
        List<Contact_Tracking__c> stageTrackingList = New List<Contact_Tracking__c>();
        for(Contact con: newContact){
            String oldStatus = oldOpportunityMap.get(con.Id).Referrer_Status__c;
            String oldRating = oldOpportunityMap.get(con.Id).Referrer_Rating__c;
            if(con.Referrer_Status__c  != oldStatus  ){
                Contact_Tracking__c stageTracking = New Contact_Tracking__c();
                stageTracking.New_Value__c = con.Referrer_Status__c;
                stageTracking.Old_Value__c = oldStatus;
                stageTracking.Contact__c  = con.Id;
                stageTracking.Field_Name__c = 'Referrer Status';
                stageTracking.New_Date__c = System.Datetime.now();
                if(oppStageCount.ContainsKey(con.Id) && oppStageCount.get(con.Id).ContainsKey(con.Referrer_Status__c)){
                    stageTracking.Count__c = oppStageCount.get(con.Id).get(con.Referrer_Status__c)+1;
                }else{
                    stageTracking.Count__c = 1;
                }
                stageTrackingList.add(stageTracking);
                if(!oppMap.get(con.Id).Contact_Trackings__r.isEmpty()){
                    Contact_Tracking__c oldStageTrack = New Contact_Tracking__c();
                    for(Contact_Tracking__c oldSTrack: oppMap.get(con.Id).Contact_Trackings__r){
                        if(oldSTrack.Field_Name__c.equalsIgnoreCase('Referrer Status')){
                            oldStageTrack = oldSTrack;
                            break;
                        }
                    }
                    oldStageTrack.Previous_Date__c = System.Datetime.now();
                    stageTrackingList.add(oldStageTrack);
                }
            }
            if(con.Referrer_Rating__c  != oldRating  ){
                Contact_Tracking__c stageTracking = New Contact_Tracking__c();
                stageTracking.New_Value__c = con.Referrer_Rating__c;
                stageTracking.Old_Value__c = oldRating;
                stageTracking.Contact__c  = con.Id;
                stageTracking.Field_Name__c = 'Referrer Rating';
                stageTracking.New_Date__c = System.Datetime.now();
                if(oppStageCount.ContainsKey(con.Id) && oppStageCount.get(con.Id).ContainsKey(con.Referrer_Rating__c)){
                    stageTracking.Count__c = oppStageCount.get(con.Id).get(con.Referrer_Rating__c)+1;
                }else{
                    stageTracking.Count__c = 1;
                }
                stageTrackingList.add(stageTracking);
                if(!oppMap.get(con.Id).Contact_Trackings__r.isEmpty()){
                    Contact_Tracking__c oldStageTrack = New Contact_Tracking__c();
                    for(Contact_Tracking__c oldSTrack: oppMap.get(con.Id).Contact_Trackings__r){
                        if(oldSTrack.Field_Name__c.equalsIgnoreCase('Referrer Rating')){
                            oldStageTrack = oldSTrack;
                            break;
                        }
                    }
                    oldStageTrack.Previous_Date__c = System.Datetime.now();
                    stageTrackingList.add(oldStageTrack);
                }
            }
        }
        if(!stageTrackingList.isEmpty()){
            upsert stageTrackingList;
        }
    }
}