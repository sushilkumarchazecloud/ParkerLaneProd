@isTest
public class AuthorisationCertificateControllerTest {
    
    @isTest
    public static void authorisationTest(){
        String recordTypeRefId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Lender').getRecordTypeId();
        String recordTypePId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String recordTypeConId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Lender Contact').getRecordTypeId();
        
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
        testCon.Portal_View__c = 'Admin View';
        testCon.Phone = '1234567890';
        testCon.RecordTypeId = recordTypeConId;
        testCon.Password__c = '1234';
        testCon.Email = 'testpass@gmail.com';
        insert testCon; 
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test opp1';
        opp1.Lender_Agent__c = testCon.id;
        opp1.StageName ='Approved';
        opp1.CloseDate = System.Today();
        opp1.Applicant_1__c = testAcc1.Id;
        opp1.Loan_Amount__c = 5000;
        opp1.Approved_Date__c = system.today().addDays(-1);
        insert opp1;
        
        List<Funding_Request__c> frList = new List<Funding_Request__c>();
        
        Funding_Request__c frData = new Funding_Request__c(); 
        frData.Request_Status_before_handover__c = 'Example';
        frData.Opportunity__c = opp1.id;
        
        test.startTest();
        if(frData != null){
        	insert frData;    
        }
        test.stopTest();
        
        PageReference pageRef = Page.FundingAuthorisationCertificatePDF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', frData.Id);
        
        AuthorisationCertificateController controller = new AuthorisationCertificateController();
        System.assertEquals(opp1.Name, controller.oppName);
        
    }
}