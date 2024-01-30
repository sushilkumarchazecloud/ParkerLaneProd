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
            }
            try{
                if(mails != null && mails.size() > 0){
                    Messaging.sendEmail(mails);
                }
            }catch(Exception ex){
                Exception__c eror = new Exception__c();
                eror.Class_Name__c = 'new referrer Customer';
                eror.Method_Name__c = 'Contact Trigger';
                eror.Error_Message__c = ex.getMessage() + '' + ex.getLineNumber();
                insert eror;
            }            
        
    }
}