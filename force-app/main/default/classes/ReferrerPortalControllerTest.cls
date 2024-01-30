@isTest
public class ReferrerPortalControllerTest {
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
        testCon.Portal_View__c = 'Admin View';
        testCon.Phone = '1234567890';
        testCon.RecordTypeId = recordTypeConId;
        insert testCon;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test opp1';
        opp1.FinServ__ReferredByContact__c = testCon.Id;
        opp1.StageName ='Approved';
        opp1.CloseDate = System.Today();
        opp1.Applicant_1__c = testAcc1.Id;
        opp1.Loan_Amount__c = 5000;
        opp1.Approved_Date__c = system.today().addDays(-1);
        insert opp1;
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test opp2';
        opp2.FinServ__ReferredByContact__c = testCon.Id;
        opp2.StageName ='Funding';
        opp2.CloseDate = System.Today();
        opp2.Approved_Date__c = system.today().addDays(-1);
        insert opp2;
        
    }
    static testMethod void testupdateViewofPortal(){
        
            Contact Con = [SELECT Id,AccountId,Name,Phone,RecordType.Name FROM Contact WHERE Name = 'TestRef Con' LIMIT 1];
            Account acc = [SELECT Id, On_Board_Referral__c FROM Account WHERE id =: Con.accountId LIMIT 1];
            
            ReferrerPortalController.updateViewofPortal(Con,'Admin View');
            ReferrerPortalController.getConWrapper result = ReferrerPortalController.SendMessage(Con.Phone, Con.Id);
            ReferrerPortalController.getConWrapper result1 = ReferrerPortalController.SendMessage(Con.Phone, '');
            //  ReferrerPortalController.otpMatched();
        
    } 
    
    static testMethod void testgetMyTeam(){
        Contact Con = [SELECT Id,AccountId,Name,Phone FROM Contact WHERE Name = 'TestRef Con' LIMIT 1];
        List<ReferrerPortalController.getMyTeamWrapper> result = ReferrerPortalController.getMyTeam(null, Con.Id, null);
        List<ReferrerPortalController.getMyTeamWrapper> result1 = ReferrerPortalController.getMyTeam('test opp', Con.Id, null);
        List<ReferrerPortalController.getMyTeamWrapper> result2 = ReferrerPortalController.getMyTeam(null, Con.Id, 'LastName ASC');
    }
    
    static testMethod void testSaveContactOnMyTeamCard(){
        Contact Con = [SELECT Id,AccountId,Name,Phone,RecordType.Name FROM Contact WHERE Name = 'TestRef Con' LIMIT 1];
        Account acc = [SELECT Id,Phone, On_Board_Referral__c FROM Account WHERE id =: Con.accountId LIMIT 1];
        Opportunity opp =[select id from opportunity where name ='Test opp1' limit 1];
        ReferrerPortalController.SaveContactOnMyTeamCard(Con);
        ReferrerPortalController.createContact(new List<Contact>{Con}, Con.Id);
        ReferrerPortalController.createContact(new List<Contact>{Con}, '');
        ReferrerPortalController.getMyAccount(Con.Id);
        ReferrerPortalController.getMyAccount('');
        ReferrerPortalController.updatedeclarationOnMyAccount(Con.Id, true,'');
        ReferrerPortalController.updatedeclarationOnMyAccount('', true,'');
        ReferrerPortalController.insertPdf(Con.Id);
        ReferrerPortalController.accountDetails(acc.Id);
        ReferrerPortalController.accountDetails('');
        ReferrerPortalController.getAccountId(acc.Phone);
        ReferrerPortalController.getAccountId('');
        ReferrerPortalController.emailForOtp('test@gmail.com',Con.Id);
        ReferrerPortalController.emailForOtp('test@gmail.com','');
        ReferrerPortalController.getContact(Con.Id);
        ReferrerPortalController.getContact('');
        ReferrerPortalController.getSearchData(Con.Id, 'test opp');
        ReferrerPortalController.getSearchData('', 'test opp');
        ReferrerPortalController.getOpp(Con.Id);
        ReferrerPortalController.getOpp('');
        ReferrerPortalController.getOppOnScrollForRecent(Con.Id,new List<Opportunity>{opp});
        ReferrerPortalController.UpdateConLoginLogs(con.Id, 'General');
        ReferrerPortalController.UpdateConLoginLogs('', 'General');
    }
}