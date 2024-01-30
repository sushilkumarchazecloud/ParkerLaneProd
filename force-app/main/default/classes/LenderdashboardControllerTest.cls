@isTest
public class LenderdashboardControllerTest {
    @testsetup
    static void setUpData(){
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
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test opp2';
        opp1.Lender_Agent__c = testCon.id;
        opp2.StageName ='Funding';
        opp2.CloseDate = System.Today();
        opp2.Approved_Date__c = system.today().addDays(-1);
        insert opp2;
        
        List<Product2> productList = new List<Product2>();
        productList.add(New Product2(IsActive =true, Default_Product__c = true,
                                     Product_Type__c = 'Green Loan', Product_Order__c = 1,
                                     Name = 'product', Features__c='Feature1;Feature2',
                                     Acceptable_Loan_Purpose__c = 'Solar',Lender_Account__c = testAcc.id,
                                     Maximum_Loan_Term_Years__c =1,Maximum_Loan_Amount__c=80000,
                                     Minimum_Loan_Amount__c = 1000,
                                     Is_Feature_Product__c=TRUE));
        productList.add(New Product2(IsActive =true, Default_Product__c = true,
                                     Product_Type__c = 'Green Loan', Product_Order__c = 2,
                                     Name = 'product2', Features__c='Feature1;Feature2',Lender_Account__c = testAcc.id,
                                     Acceptable_Loan_Purpose__c = 'Solar',Maximum_Loan_Amount__c=80000,
                                     Minimum_Loan_Amount__c = 1000,
                                     Maximum_Loan_Term_Years__c =5));
        productList.add(New Product2(IsActive =true, Default_Product__c = true,
                                     Product_Type__c = 'Green Loan', Product_Order__c = 3,
                                     Name = 'product3', Features__c='Feature1;Feature2',Lender_Account__c = testAcc.id,
                                     Acceptable_Loan_Purpose__c = 'Solar',Maximum_Loan_Amount__c=80000,
                                     Minimum_Loan_Amount__c = 1000,
                                     Maximum_Loan_Term_Years__c =3));
        insert productList;
        list<quote> qtlist = new list<quote>();
        qtlist.add(New Quote(Name ='test quote', OpportunityId= opp1.Id, Application__c=true, Up_Front_Costs_Applicable__c = 'Yes',
                             Purpose__c= 'Solar',Gruop_Name__c='One',Quote_Group_Label__c='One', Customer_Amount__c = 35000, Loan_Term__c = 60, Product__c = productList[0].Id,
                             Interest_Rate__c = 3.99, Actual_Comparison_Rate__c = 4.99));
        qtlist.add(New Quote(Name ='test quote2', OpportunityId= opp1.Id, Application__c=true, Up_Front_Costs_Applicable__c = 'Yes',
                             Purpose__c= 'Solar',Gruop_Name__c='Referral-1',Quote_Group_Label__c='Referral-1', Customer_Amount__c = 60000, Loan_Term__c = 80, Product__c = productList[1].Id,
                             Interest_Rate__c = 7.99, Actual_Comparison_Rate__c = 8.99));
        qtlist.add(New Quote(Name ='test quote3', OpportunityId= opp2.Id, Application__c=true, Up_Front_Costs_Applicable__c = 'Yes',
                             Purpose__c= 'Solar',Gruop_Name__c='Referral-1',Quote_Group_Label__c='Referral-1', Customer_Amount__c = 60000, Loan_Term__c = 80, Product__c = productList[1].Id,
                             Interest_Rate__c = 5.99, Actual_Comparison_Rate__c = 6.99));
        insert qtlist;
        list<opportunity> oplist = new list<opportunity>();
        opp1.SyncedQuoteId = qtlist[0].id;
        opp2.SyncedQuoteId = qtlist[2].id;
        oplist.add(opp1);
        oplist.add(opp2);
        update oplist;
        
        Document_Requested__c dr = new Document_Requested__c();
        dr.Opportunity__c = opp1.id;
        dr.Category__c = 'Purchase Invoice';
        insert dr;
           
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Content', 
            VersionData = Blob.valueOf('Test Content Data'),
            PathOnClient = 'TestContent.txt',
            ContentLocation = 'S',
            Current_in_use__c = true,
            Document_Requested__c = dr.id
            //FirstPublishLocationId = testOpp1.id
        );        
        insert testContentVersion;
        
        ContentDocumentLink link = new ContentDocumentLink(ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id].ContentDocumentId,LinkedEntityId = opp1.Id,ShareType = 'I');
        insert link;
        
        system.debug('SYNCED'+opp1.SyncedQuote.Product__r.Lender_Account__c);
        list<Funding_Request__c> frList = new list<Funding_Request__c>();
        Funding_Request__c fr = new Funding_Request__c();
        fr.Request_Amount__c = 20000;
        fr.Invoice_Amount__c = 20000;
        fr.Request_Type__c = 'Part payment before installation';
        fr.Request_Status__c = 'Payment funded';
        fr.Opportunity__c = opp1.Id;
        fr.Requested_by__c = 'Supplier';
        fr.Person_Requesting__c = opp1.Applicant_1__r.personcontactId;
        fr.A1_Funding_Call_Handover__c = system.now();
        fr.A2_Funding_Call_Handover__c = system.now();
        fr.Installation_Date__c = date.today();
        fr.Net_Surplus_Shortfall__c = 2000;
        fr.Surplus_Shortfall_Treatment__c = 'Variation to contract (requires re-approval)';
        frList.add(fr);
        
        Funding_Request__c fr2 = new Funding_Request__c();
        fr2.Request_Amount__c = 20000;
        fr2.Invoice_Amount__c = 20000;
        fr2.Request_Type__c = 'Part payment before installation';
        fr2.Request_Status__c = 'Payment authorised by customer';
        fr2.Opportunity__c = opp2.Id;
        fr2.Requested_by__c = 'Supplier';
        fr2.Person_Requesting__c = opp2.Applicant_1__r.personcontactId;
        fr2.A1_Funding_Call_Handover__c = system.now();
        fr2.A2_Funding_Call_Handover__c = system.now();
        fr2.Installation_Date__c = date.today();
        fr2.Net_Surplus_Shortfall__c = 2000;
        fr2.Surplus_Shortfall_Treatment__c = 'Variation to contract (requires re-approval)';
        frList.add(fr2);
        insert frList;
    }
    
    static testMethod void testLenderOne(){
        Contact Con = [SELECT Id,AccountId,Name,Phone,RecordType.Name FROM Contact WHERE Name = 'TestRef Con' LIMIT 1];
        LenderdashboardController.updateViewofPortal(Con,'Admin View');
        LenderdashboardController.login('1234','testpass@gmail.com');
        LenderdashboardController.SendMessage('1234');
        LenderdashboardController.passwordUpdate(Con.id,'1234');
        LenderdashboardController.emailForOtp(Con.id);
        LenderdashboardController.updatePasswordEmail('testpass@gmail.com');
        LenderdashboardController.otpMatched(Con.id);
        LenderdashboardController.getContact(Con.id);
    }
    
    static testMethod void testLenderTwo(){
        Contact Con = [SELECT Id,AccountId,Name,Phone,RecordType.Name FROM Contact WHERE Name = 'TestRef Con' LIMIT 1];
        list<contact> conlist = new list<contact>();
        conlist.add(new contact(lastname= 'testtt'));
        
        LenderdashboardController.getOpp(Con.Id);
        LenderdashboardController.getSearchData(Con.Id,'Test');
        LenderdashboardController.getMyAccount(Con.Id);
        LenderdashboardController.createContact(conlist,Con.Id);
        LenderdashboardController.SaveContactOnMyTeamCard(Con);
    }
    
    static testMethod void testLenderThird(){
        Contact Con = [SELECT Id,AccountId,Name,Phone,RecordType.Name FROM Contact WHERE Name = 'TestRef Con' LIMIT 1];
        list<Opportunity> OppList = [SELECT Id,Name,StageName,Applicant_1__c,Applicant_1__r.FirstName,
                           Applicant_1__r.LastName,Applicant_1__r.Phone,Applicant_1__r.PersonEmail
                           From Opportunity WHERE Name ='Test opp1'];
        LenderdashboardController.getOppOnScrollForRecent(Con.id,OppList);
        LenderdashboardController.getMyTeam('Test',Con.id,'Name');  
        LenderdashboardController.getDocs(OppList[0].id);
    }
    
    static testMethod void testLenderFourth(){
        Contact Con = [SELECT Id,AccountId,Name,Phone,RecordType.Name FROM Contact WHERE Name = 'TestRef Con' LIMIT 1];
        LenderdashboardController.getMySettlments('All','Test',Con.id,'Name');
        list<Opportunity> OppList = [SELECT Id,Name,StageName,Applicant_1__c,Applicant_1__r.FirstName,
                           Applicant_1__r.LastName,Applicant_1__r.Phone,Applicant_1__r.PersonEmail
                           From Opportunity WHERE Name ='Test opp1'];
        LenderdashboardController.GetOppOnExpand(Con.id,OppList[0].id);
        LenderdashboardController.LenderAgentAssign(Con.id,OppList[0].id);
        LenderdashboardController.ReassignAgent(Con.id,Con.id);
    }
    
    static testMethod void testLenderFifth(){
        Contact Con = [SELECT Id,AccountId,Name,Phone,RecordType.Name FROM Contact WHERE Name = 'TestRef Con' LIMIT 1];
        Funding_Request__c fr = [select id from Funding_Request__c limit 1];
        LenderdashboardController.updateFundingByLender(fr.id,20000.00,'Customer',Con.Id);
    }
}