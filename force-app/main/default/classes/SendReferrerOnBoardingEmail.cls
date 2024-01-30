public class SendReferrerOnBoardingEmail {
	@InvocableMethod(label='SendReferrerOnBoardingEmail' description='This method will be send email to referrers')
    public static void sendReferrerOnBoardingEmailMethod(List<String> accIdList) {
        try{
            List<String>emailBCCList = New List<String>{'chris.white@parkerlane.com.au', 'personalapplications@parkerlane.com.au'};
            EmailTemplate et=[Select id, Subject, Body from EmailTemplate where Name='Referrer Onboarding Form Email']; 
            List<Messaging.SingleEmailMessage> emailList = New List<Messaging.SingleEmailMessage>();
            String query = 'SELECT Id, Name, Email FROM Contact WHERE AccountId IN : accIdList';
        	List<Contact>conList= Database.query(query);
            for(Contact con: conList){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                mail.setToAddresses(New List<String>{con.Email});
                mail.setSenderDisplayName('The Parker Lane Team'); 
                mail.setUseSignature(false); 
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setTargetObjectId(con.Id);
                mail.setBccAddresses(emailBCCList);
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setSaveAsActivity(false); 
                mail.setTemplateId(et.id);
                emailList.add(mail);
            }   
            Messaging.SendEmailResult [] r = Messaging.sendEmail(emailList);
        }catch(exception e){
            UtilityClass.createException('', 'SendReferrerOnBoardingEmail', 'execute', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
        }
    }
}