@isTest
public class CaseAssignmentHandlerTest {
    
    static testMethod void testCase(){
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
        testCon.Email = 'test@testt.com';
        insert testCon; 
        
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test opp';
        opp1.StageName ='Approved';
        opp1.CloseDate = System.Today();
        opp1.Loan_Amount__c = 5000;
        opp1.Approved_Date__c = system.today().addDays(-1);
        insert opp1;   
        
        Case cs = new Case();
        cs.Opportunity__c = opp1.id;
        cs.Origin = 'Email';
        cs.SuppliedEmail = 'test@testt.com';
        insert cs;
    }
    
    static testMethod void testCaseOpp(){
        String recordTypePId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account testAcc1 = new Account();
        testAcc1.RecordTypeId  = recordTypePId;
        testAcc1.FirstName = 'test';
        testAcc1.LastName = 'oppp';
        testAcc1.Phone = '1234567890';
        testAcc1.On_Board_Referral__c  = true;
        testAcc1.PersonEmail = 'testopp11@test.com';
        insert testAcc1;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test opp';
        opp1.StageName ='Approved';
        opp1.CloseDate = System.Today();
        opp1.Loan_Amount__c = 5000;
        opp1.Approved_Date__c = system.today().addDays(-1);
        opp1.Applicant_1__c = testAcc1.Id;
        insert opp1;        
        
        Case cs = new Case();
        cs.Opportunity__c = opp1.id;
        cs.Origin = 'Email';
        cs.SuppliedEmail = 'testopp11@test.com';
        insert cs;
    }
    
     static testMethod void testElseCase(){        
        Case cs = new Case();
        insert cs;
    }
}