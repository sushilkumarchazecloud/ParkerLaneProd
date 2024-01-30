@isTest
public class CaseAssignmentHandlerTest {
	@testsetup
    static void setUpData(){     
        String recordTypeRefId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Referrer (Business)').getRecordTypeId();
        String recordTypePId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String recordTypeConId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Referrer').getRecordTypeId();
        
        Account testAcc = new Account();
        testAcc.RecordTypeId  = recordTypeRefId;
        testAcc.Name = 'Test acc'; 
        testAcc.On_Board_Referral__c  = true;
        insert testAcc;
        
        Account testAcc1 = new Account();
        testAcc1.RecordTypeId  = recordTypePId;
        testAcc1.FirstName = 'test';
        testAcc1.LastName = 'opp';
        testAcc1.Phone = '1234567890';
        testAcc1.On_Board_Referral__c  = true;
        testAcc1.PersonEmail = 'testopp1@test.com';
        insert testAcc1;
        
        Contact testCon = new Contact();
        testCon.FirstName = 'TestRef';
        testCon.LastName = 'Con';
        testCon.AccountId = testAcc.Id;
        testCon.Admin__c = true;
        testCon.Status__c = 'Active';
        //testCon.Referrer_Rating__c = 'Platinum';
        testCon.Portal_View__c = 'Admin View';
        testCon.Phone = '1234567890';
        testCon.RecordTypeId = recordTypeConId;
        insert testCon;        
        
    }
    static testMethod void testupdateViewofPortal(){
        Contact Con = [SELECT Id,AccountId,Name,Phone,RecordType.Name FROM Contact WHERE Name = 'TestRef Con' LIMIT 1];
        Account acc = [SELECT Id,Phone, On_Board_Referral__c FROM Account WHERE id =: Con.accountId LIMIT 1];
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test opp1';
        opp1.FinServ__ReferredByContact__c = Con.Id;
        opp1.StageName ='Approved';
        opp1.CloseDate = System.Today();
        opp1.Applicant_1__c = acc.Id;
        opp1.Contact_1__c = Con.Id;
        opp1.Loan_Amount__c = 5000;
        opp1.Approved_Date__c = system.today().addDays(-1);
        insert opp1;
        
        Case cs = new Case();
        cs.AccountId = acc.Id;
        cs.Opportunity__c = opp1.Id;
        cs.ContactId = Con.Id;
        insert cs;
    }
    
    static testMethod void testCase(){
        Contact Con = [SELECT Id,AccountId,Name,Phone,RecordType.Name FROM Contact WHERE Name = 'TestRef Con' LIMIT 1];
        Account acc = [SELECT Id,Phone, On_Board_Referral__c FROM Account WHERE id =: Con.accountId LIMIT 1];      
        
        Case cs = new Case();
        cs.AccountId = acc.Id;
        cs.ContactId = Con.Id;
        insert cs;
    }
}