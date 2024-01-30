@isTest
public class TestOpportunityLeadController {
	@isTest
    public static void testchangeUnread(){
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND Name = 'Green Loan'];
        Lead testLed = new Lead(FirstName='Test',
                                LastName='Lead',
                               RecordType = rt,
                               Unread__c = true);
        insert testLed;
        Account acct = new Account(FirstName='Test',LastName='Acct');
        insert acct;
        Account acct1 = new Account(FirstName='Test1',LastName='Acct1');
        insert acct1;
        Date dt = date.today();
        Opportunity testOpp = new Opportunity(RecordType = rt,
                                         Name = 'Test',
                                         StageName = 'Quote',
                                         CloseDate = dt,
                                         Applicant_1__c = acct.Id,
                                         Applicant_2__c = acct1.Id,
                                         Unread__c = true);
        insert testOpp;
        System.assert(testLed.Unread__c == true);
        System.assert(testOpp.Unread__c == true);
        OpportunityLeadController.changeUnread(testOpp.Id,'opportunity');
        OpportunityLeadController.changeUnread(testLed.Id,'lead');
        testOpp = [Select id,Unread__c from opportunity where Id=:testOpp.Id];
        testLed = [Select id,Unread__c from Lead where Id=:testLed.Id];
        System.assert(testLed.Unread__c == false);
        System.assert(testOpp.Unread__c == false);
    }
}