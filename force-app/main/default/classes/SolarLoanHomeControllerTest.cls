@istest
public class SolarLoanHomeControllerTest {
    @testsetup
    static void setUpData(){
        String recordTypeRefId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Referrer (Business)').getRecordTypeId();
        String recordTypePId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String recid = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Green Loan').getRecordTypeId();
        String LeadRecordType = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('Green Loan').getRecordTypeId();
        
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
        
        insert testAcc1;
        
        Contact testCon = new Contact();
        testCon.FirstName = 'TestRef';
        testCon.LastName = 'Contact';
        testCon.AccountId = testAcc.Id;
        testCon.Admin__c = true;
        testCon.Portal_View__c = 'Admin View';
        testCon.Phone ='0412568868';
        insert testCon;
        
        Opportunity testOpp1 = new Opportunity();
        testOpp1.Name = 'Test Opportunity 1';
        testOpp1.FinServ__ReferredByContact__c = testCon.Id;
        testOpp1.StageName ='Approved';
        testOpp1.CloseDate = System.Today();
        testOpp1.Applicant_1__c = testAcc1.Id;
        testOpp1.Loan_Amount__c = 22000;
        insert testOpp1;
    }
    @istest
    public static void Test1(){
        String testLbl = Label.Credit_analyst;
        Profile pf= [Select Id from profile where Name='System Administrator'];
        /*User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = 'test@gmail.com', 
                         Username =  ' john@accc.com',  
                         ProfileId = pf.Id
                        ); 
        insert uu;*/
        Opportunity Opp = [SELECT Id,Name From Opportunity where name ='Test Opportunity 1' LIMIT 1];
        apexpages.currentpage().getparameters().put('id', Opp.Id);
        SolarLoanHomeController sl = new SolarLoanHomeController();
        SolarLoanHomeController.getOpponPriorties(Opp.id);
    }
}