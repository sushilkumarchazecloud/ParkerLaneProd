@isTest
private class QuoteTriggerHandlerTest {
     @testSetup static void setup() {
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND Name = 'Green Loan'];
        Date dt = date.today();
        List<Opportunity> testOpp = new List<Opportunity>();
        for(Integer i=1; i<5; i++){
            testOpp.add(new Opportunity(RecordType = rt,
                                         Name = 'Test'+i,
                                         StageName = 'Quote',
                                         CloseDate = dt+i,
                                         Loan_Amount__c = i*100));
        }
        insert testOpp;
        Opportunity toUse = [Select Id, Loan_Amount__c From Opportunity where Name = 'Test1'];
        
        System.assert(toUse.Loan_Amount__c == 100);
        List<Quote> testQuot = new List<Quote>();
        for(Integer i=1; i<5; i++){
            testQuot.add(new Quote(Name = 'Quotetest'+i,
                                   OpportunityId = toUse.Id,
                                   Application__c = false,
                                   Lender__c = 'Test Leader',
                                   Customer_Amount__c = i*1000 ));
        }
        insert testQuot;
     }    
    
    @isTest
    static void TestDeleteApplication(){
        Test.startTest();
        Quote fetchQuo = [Select Id,Application__c from Quote where Name = 'Quotetest1'];
        fetchQuo.Application__c = true;
        update fetchQuo;
        delete fetchQuo;
        Opportunity fetchOpp = [Select Id,Loan_Amount__c from Opportunity where Name = 'Test1'];
        System.assert(fetchOpp.Loan_Amount__c == 0);
        Test.stopTest();
            
    }
}