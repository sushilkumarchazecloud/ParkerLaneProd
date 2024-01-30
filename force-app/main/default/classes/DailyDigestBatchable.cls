global class DailyDigestBatchable implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        DateTime yesterdayDateTime6PM = DateTime.newInstance(Date.Today(),Time.newInstance(18, 0, 0, 0));
        List<String> excludeStages = New List<String>{'Nurturing','Settled (closed won)','Closed Lost'};
        List<Opportunity> oppList = [SELECT Id, FinServ__ReferredByContact__c, 
                                    (SELECT Id FROM Tasks WHERE TaskSubtype != 'Email'  AND Make_Activity_Private__c = FALSE AND
                                    (ActivityDate = TODAY OR (CompletedDateTime = YESTERDAY AND CreatedDate >=: yesterdayDateTime6PM ))), 
                                    (SELECT Id FROM Events WHERE (ActivityDate = TODAY OR (EndDate = YESTERDAY AND CreatedDate >=: yesterdayDateTime6PM )) AND Make_Activity_Private__c = FALSE)
                                    FROM Opportunity 
                                    WHERE StageName NOT in: excludeStages AND FinServ__ReferredByContact__c != NULL];
        Set<Id> receiverIds = New Set<Id>();
        for(Opportunity op: oppList){
            if(op.Tasks.size() == 0 && op.Events.size() == 0){
                continue;
            }
            receiverIds.add(op.FinServ__ReferredByContact__c);
        }
		System.debug('@@@@@receiverIds' + receiverIds);
        String query = 'SELECT Id FROM Contact WHERE Id in: receiverIds';
        
                
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<Contact> conList)
    {
        try{
            EmailTemplate et=[Select id, Subject, Body from EmailTemplate where Name='Daily Digest Template']; 
            List<Messaging.SingleEmailMessage> emailList = New List<Messaging.SingleEmailMessage>();
            
            
            for(Contact con: conList){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                mail.setToAddresses(New List<String>{'chris.white@parkerlane.com.au','personalapplications@parkerlane.com.au'});
                mail.setSenderDisplayName('The Parker Lane Team'); 
                mail.setUseSignature(false); 
                mail.setTargetObjectId(con.Id);
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setSaveAsActivity(false); 
                mail.setTemplateId(et.id);
                emailList.add(mail);
            }   
            Messaging.SendEmailResult [] r = Messaging.sendEmail(emailList);
        }catch(exception e){
            UtilityClass.createException('', 'DailyDigestBatchable', 'execute', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
        }
    }  
    global void finish(Database.BatchableContext BC)
    {
    }
}