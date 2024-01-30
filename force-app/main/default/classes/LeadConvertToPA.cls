@IsTest
public class LeadConvertToPA{

    private static testMethod void personAccountLeadConvert() {
        
        Lead lead=new Lead(LastName='Doe',FirstName='John',Status='Inquiry');
        
        insert lead;                
        
        Test.startTest();
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            User usr = new User(Alias = 'standt', Email='testparker@parker.com', 
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, 
                        TimeZoneSidKey='America/Los_Angeles', UserName='testparker@parker.com');
            insert usr ;
            System.runAs(usr)
            {
                lead.ownerId = usr.id;
                update lead;
            }
        Test.stopTest();  
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
    }
}