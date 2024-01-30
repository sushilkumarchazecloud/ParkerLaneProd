@isTest
public class BatchForReviewsMailTest {
    @testsetup
    static void setUpData(){
        String recordTypePId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String recordTypeRefId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Referrer (Business)').getRecordTypeId();
        
        Account testAcc = new Account();
        testAcc.RecordTypeId  = recordTypeRefId;
        testAcc.Name = 'TestRef Account';
        insert testAcc;
        
        Account testAcc1 = new Account();
        testAcc1.RecordTypeId  = recordTypePId;
        testAcc1.FirstName = 'Test';
        testAcc1.LastName = 'Opportunity 1';
        testAcc1.Phone = '1234567890';
        testAcc1.PersonEmail = 'opp1@test.com';
        
        Account testAcc2 = new Account();
        testAcc2.RecordTypeId  = recordTypePId;
        testAcc2.FirstName = 'Test2';
        testAcc2.LastName = 'Opportunity 2';
        testAcc2.Phone = '1234567870';
        testAcc2.PersonEmail = 'opp1@test1.com';
        
        insert testAcc1;
        insert testAcc2;
        
        Contact testCon = new Contact();
        testCon.FirstName = 'TestRef';
        testCon.LastName = 'Contact';
        testCon.AccountId = testAcc.Id;
        testCon.Admin__c = true;
        testCon.Portal_View__c = 'Admin View';
        testCon.Phone ='0412568868';
        testCon.Email ='rakesh@gmail.com';
        insert testCon;
        
        Contact testCon1 = new Contact();
        testCon1.FirstName = 'TestRef1';
        testCon1.LastName = 'Contact';
        testCon1.AccountId = testAcc.Id;
        testCon1.Admin__c = true;
        testCon1.Portal_View__c = 'Admin View';
        testCon1.Phone ='0412568868';
        testCon1.Email ='rakesh@gmail.com';
        insert testCon1;
        
        Opportunity testOpp1 = new Opportunity();
        testOpp1.Name = 'Test Opportunity 1';
        testOpp1.FinServ__ReferredByContact__c = testCon.Id;
        testOpp1.Referred_by_Company__c =testAcc.id;
        testOpp1.Contact_1__c = testCon.id;
        testOpp1.StageName ='Approved';
        testOpp1.CloseDate = System.Today();
        testOpp1.Applicant_1__c = testAcc1.Id;
        testOpp1.Applicant_2__c = testAcc2.id;
        testOpp1.Review_message__c = 'Good response';
        testOpp1.Review_title__c = 'Good';
        testOpp1.Review_updated__c = system.today().addDays(-3);
        testOpp1.Review_stars__c = '4 stars';
        insert testOpp1;
        
        Opportunity testOpp2 = new Opportunity();
        testOpp2.Name = 'Test Opportunity 2';
        testOpp2.FinServ__ReferredByContact__c = testCon.Id;
        testOpp2.Referred_by_Company__c =testAcc.id;
        testOpp2.Contact_1__c = testCon.id;
        testOpp2.StageName ='Approved';
        testOpp2.CloseDate = System.Today();
        testOpp2.Applicant_1__c = testAcc1.Id;
        testOpp2.Applicant_2__c = testAcc2.id;
        testOpp2.Review_message__c = 'Good response';
        testOpp2.Review_title__c = 'Good';
        testOpp2.Review_updated__c = system.today().addDays(-3);
        testOpp2.Review_stars__c = '4 stars';
        insert testOpp2;
    }
    static testMethod void test1(){
        list<opportunity> opplist = [select id,Review_updated__c from opportunity];
        for(opportunity opp: opplist){
            opp.Review_updated__c = system.today().addDays(-3);
        }
        update opplist;
        BatchForReviewsMail obj = new BatchForReviewsMail();
        Id batchId = Database.executeBatch(obj, 200); 
    }
}