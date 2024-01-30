@isTest
public class BatchForReferrersReportTest {
	
    @isTest
    public static void methodOne(){
        Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Referrer').getRecordTypeId();
        System.debug(devRecordTypeId);
        
        Account acc = new Account();
        acc.name = 'gdnsns';
        insert acc;
        
        
        contact con = new Contact();
        con.FirstName = 'qtrrywert';
        con.LastName = 'shnsnj';
        con.email = 'test@gmail.com';
        con.AccountId = acc.Id;
        con.Admin__c = true;
        con.RecordTypeId = devRecordTypeId;
        insert con;
        
        
        opportunity op = new Opportunity();
        op.Name = 'qwert';
        op.CloseDate = system.today();
        op.StageName = 'Approved';
        op.FinServ__ReferredByContact__c = con.Id;
        insert op;
        
        EmailTemplate emailTemplate = [SELECT Id,Subject, Body FROM EmailTemplate WHERE DeveloperName = 'Daily_Referral_Report' ];
        
        BatchForReferrersReport obj = new BatchForReferrersReport();
        DataBase.executeBatch(obj);
        
    }
}