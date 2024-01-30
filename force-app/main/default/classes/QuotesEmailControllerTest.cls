@isTest
private class QuotesEmailControllerTest {
    @testSetup
    static void createTestData() {
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new account();
        acc.RecordTypeId= recordTypeId;
        acc.FirstName = 'Test';
        acc.LastName = 'Testr'; 
        acc.PersonEmail='rakesh@gmail.com';
        insert acc;
        
        Opportunity testOpp1 = new Opportunity();
        testOpp1.Name = 'Test Opportunity 1';
        testOpp1.StageName ='Approved';
        testOpp1.CloseDate = System.Today();
        testOpp1.Loan_Amount__c = 22000;
        testOpp1.Applicant_1__c = acc.Id;
        insert testOpp1;

        List<Quote> quotes = new List<Quote>();
        quotes.add(new Quote(
            Name = 'Test Quote 1',
            Customer_Amount__c = 1000,
            OpportunityId = testOpp1.Id,
            Interest_Rate__c = 0.01,
            Gruop_Name__c = 'Test Group Label 1',
            Quote_Group_Label__c = 'Test Group Label 1',
            Actual_Comparison_Rate__c = 0.02,
            IsSelected__c = true
        ));
        quotes.add(new Quote(
            Name = 'Test Quote 2',
            Customer_Amount__c = 2000,
            OpportunityId = testOpp1.Id,
            Interest_Rate__c = 0.02,
            Gruop_Name__c = 'Test Group Label 1',
            Quote_Group_Label__c = 'Test Group Label 1',
            Actual_Comparison_Rate__c = 0.03,
            IsSelected__c = true
        ));
        insert quotes;
        
        Opportunity testOpp2 = new Opportunity();
        testOpp2.Name = 'Test Opportunity 2';
        testOpp2.StageName ='Approved';
        testOpp2.CloseDate = System.Today();
        testOpp2.Loan_Amount__c = 22000;
        testOpp2.SyncedQuoteId = quotes[0].id;
        insert testOpp2;
        
        lead jd = new lead();
        jd.Email ='rakesh@gmail.com';
        jd.LastName='test';
        insert jd;
        
    }

    @isTest
    static void testInit() {
        QuotesEmailController controller = new QuotesEmailController();
        controller.opportunityId = [SELECT Id FROM Opportunity where name='Test Opportunity 1' LIMIT 1].Id;
        
        Test.startTest();
        controller.init();
        Test.stopTest();
   
    }
    
    @isTest
    static void testgetOpportunity() {
        QuotesEmailController controller = new QuotesEmailController();
        controller.opportunityId = [SELECT Id FROM Opportunity where name='Test Opportunity 2' LIMIT 1].Id;
        
        Test.startTest();
        controller.getOpportunity();
        Test.stopTest();
   
    }
}