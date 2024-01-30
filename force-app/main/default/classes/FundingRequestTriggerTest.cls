@isTest
public class FundingRequestTriggerTest {
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
        
        Opportunity testOpp1 = new Opportunity();
        testOpp1.Name = 'Test Opportunity 1';
        testOpp1.FinServ__ReferredByContact__c = testCon.Id;
        testOpp1.Referred_by_Company__c =testAcc.id;
        testOpp1.Contact_1__c = testCon.id;
        testOpp1.StageName ='Approved';
        testOpp1.CloseDate = System.Today();
        testOpp1.Applicant_1__c = testAcc1.Id;
        testOpp1.Applicant_2__c = testAcc2.id;
        testOpp1.Loan_Amount__c = 22000;
        insert testOpp1;
        
        Document_Requested__c dr = new Document_Requested__c();
        dr.Opportunity__c = testOpp1.id;
        dr.Category__c = 'Purchase Invoice';
        insert dr;
        
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Content',
            VersionData = Blob.valueOf('Test Content Data'),
            PathOnClient = 'TestContent.txt',
            ContentLocation = 'S',
            Current_in_use__c = true,
            Document_Requested__c = dr.id
        );        
        insert testContentVersion;
        
        ContentDocumentLink link = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id].ContentDocumentId,
            LinkedEntityId = testOpp1.Id,
            ShareType = 'I'
        );
        insert link;
        
        Funding_Request__c fr = new Funding_Request__c();
        fr.Request_Type__c = 'Payment in full after installation';
        fr.Request_Status__c = 'Payment requested by customer';
        fr.Opportunity__c = testOpp1.Id;
        fr.Applicant_1_A1__c = testOpp1.Applicant_1__c;
        fr.Applicant_2_A2__c = testOpp1.Applicant_2__c;
        fr.Requested_by__c = 'Customer';
        fr.Person_Requesting__c = testOpp1.Applicant_1__r.personcontactId;
        fr.Variation_Requested_By__c = testOpp1.Applicant_1__c;
        fr.Customer_Authorisation_Type__c = 'Both to sign';
        fr.Funding_On_Hold__c = false;
        fr.Date_Last_Request_Status_Changes__c = system.now().addDays(-1);
        insert fr;
    
    }
    
    static testMethod void testMailOnInsert1(){
        Opportunity opp = [select id,name,Applicant_1__c,Applicant_2__c,Applicant_1__r.personcontactId from opportunity where Name= 'Test Opportunity 1' LIMIT 1];
        Funding_Request__c fr = new Funding_Request__c();
        fr.Request_Type__c = 'Variation';
        fr.Request_Status__c = 'Variation requested by customer';
        fr.Opportunity__c = opp.Id;
        fr.Applicant_1_A1__c = opp.Applicant_1__c;
        fr.Applicant_2_A2__c = opp.Applicant_2__c;
        fr.Requested_by__c = 'Customer';
        fr.Person_Requesting__c = opp.Applicant_1__r.personcontactId;
        fr.Variation_Requested_By__c = opp.Applicant_1__c;
        fr.Customer_Authorisation_Type__c = 'Either to sign';
        fr.Date_Last_Request_Status_Changes__c = system.now().addDays(-1);
        insert fr;
        
        fr.Request_Status__c = 'Payment requested by customer';
        fr.Date_Last_Request_Status_Changes__c = System.now();
        update fr;
    }
    
    static testMethod void testMailOnInsert2(){
        Opportunity opp = [select id,name,Applicant_1__c,Applicant_2__c,Applicant_1__r.personcontactId from opportunity where Name= 'Test Opportunity 1' LIMIT 1];
        list<Funding_Request__c> frList = new list<Funding_Request__c>(); 
        Funding_Request__c fr = new Funding_Request__c();
        fr.Request_Type__c = 'Payment in full before installation';
        fr.Request_Status__c = 'Payment requested by customer';
        fr.Opportunity__c = opp.Id;
        fr.Applicant_1_A1__c = opp.Applicant_1__c;
        fr.Applicant_2_A2__c = opp.Applicant_2__c;
        fr.Requested_by__c = 'Customer';
        fr.Person_Requesting__c = opp.Applicant_1__r.personcontactId;
        fr.Customer_Authorisation_Type__c = 'Either to sign';
        fr.Date_Last_Request_Status_Changes__c = system.now().addDays(-1);
        frList.add(fr);
        
        Funding_Request__c fr2 = new Funding_Request__c();
        fr2.Request_Type__c = 'Payment in full before installation';
        fr2.Request_Status__c = 'Payment requested by supplier';
        fr2.Opportunity__c = opp.Id;
        fr2.Applicant_1_A1__c = opp.Applicant_1__c;
        fr2.Applicant_2_A2__c = opp.Applicant_2__c;
        fr2.Requested_by__c = 'Supplier';
        fr2.Person_Requesting__c = opp.Applicant_1__r.personcontactId;
        fr2.Customer_Authorisation_Type__c = 'Both to sign';
        fr2.Date_Last_Request_Status_Changes__c = system.now().addDays(-1);
        frList.add(fr2);
        
        insert frList;
        
        fr.Request_Status__c = 'Variation requested by customer';
        fr.Date_Last_Request_Status_Changes__c = system.now();
        update fr;
        
        fr2.Request_Status__c = 'Payment authorised by customer';
        fr2.Date_Last_Request_Status_Changes__c = system.now();
        fr2.A1_Funding_Call_Handover__c = system.now();
        fr2.A2_Funding_Call_Handover__c = system.now();
        update fr2;    
    }
    
    static testMethod void testMailOnInsert3(){
        list<Funding_Request__c> frlist = [select id,Funding_On_Hold__c,Funding_Hold_Expiry_Date__c,Funding_On_Hold_Reason__c from Funding_Request__c where Request_Type__c = 'Payment in full after installation' LIMIT 1];
        list<Funding_Request__c> frToUpdate = new list<Funding_Request__c>();
        //system.debug('frlist'+frlist);
        frlist[0].Funding_On_Hold__c = true;
        frlist[0].Funding_Hold_Expiry_Date__c = system.Today().addDays(1);
        frlist[0].Funding_On_Hold_Reason__c = 'Closed';
        frlist[0].Request_Status__c = 'Payment funded';
        frlist[0].Date_Last_Request_Status_Changes__c = system.now();
        frlist[0].A1_Funding_Call_Handover__c = system.now();
        frToUpdate.add(frlist[0]);
        update frToUpdate;
    }

}