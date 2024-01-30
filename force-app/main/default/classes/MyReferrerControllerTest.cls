@isTest
public class MyReferrerControllerTest {
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
        
        Opportunity testOpportunity2 = new Opportunity();
        testOpportunity2.Name = 'Test Opportunity 2';
        testOpportunity2.FinServ__ReferredByContact__c = testCon.Id;
        testOpportunity2.StageName ='Funding';
        testOpportunity2.CloseDate = System.Today();
        insert testOpportunity2;
        
        Lead le = new Lead();
        le.RecordTypeId = LeadRecordType;
        le.FirstName = 'Test';
        le.LastName = 'Opportunity 1';
        le.Email = 'opp1@test.com';
        insert le;
        
        Opportunity oppty = new Opportunity ();
        oppty.applicant_1__c = testAcc1.Id;
        oppty.applicant_2__c = testAcc.Id;
        oppty.AccountId = testAcc1.Id;
        oppty.FinServ__ReferredByContact__c = testCon.Id;
        oppty.name = 'test Oppty';
        oppty.StageName='Assessment Needed'; 
        oppty.CloseDate = Date.today();
        oppty.Application_Sections__c ='Own and Owe'; 
        oppty.Current_Application_Sections__c ='Who is applying';
        oppty.Relationship_to_Applicant_2__c = 'Spouse';
        oppty.RecordTypeId = recid;
        oppty.LeadId__c = le.Id;
        insert oppty;
        
        List<Product2> productList = new List<Product2>();
        productList.add(New Product2(IsActive =true, Default_Product__c = true,
                                     Product_Type__c = 'Green Loan', Product_Order__c = 1,
                                     Name = 'product', Features__c='Feature1;Feature2',
                                     Acceptable_Loan_Purpose__c = 'Solar',
                                     Maximum_Loan_Term_Years__c =1,Maximum_Loan_Amount__c=80000,
                                     Minimum_Loan_Amount__c = 1000,
                                     Is_Feature_Product__c=TRUE));
        productList.add(New Product2(IsActive =true, Default_Product__c = true,
                                     Product_Type__c = 'Green Loan', Product_Order__c = 2,
                                     Name = 'product2', Features__c='Feature1;Feature2',
                                     Acceptable_Loan_Purpose__c = 'Solar',Maximum_Loan_Amount__c=80000,
                                     Minimum_Loan_Amount__c = 1000,
                                     Maximum_Loan_Term_Years__c =5));
        productList.add(New Product2(IsActive =true, Default_Product__c = true,
                                     Product_Type__c = 'Green Loan', Product_Order__c = 3,
                                     Name = 'product3', Features__c='Feature1;Feature2',
                                     Acceptable_Loan_Purpose__c = 'Solar',Maximum_Loan_Amount__c=80000,
                                     Minimum_Loan_Amount__c = 1000,
                                     Maximum_Loan_Term_Years__c =3));
        insert productList;
        list<quote> qtlist = new list<quote>();
        qtlist.add(New Quote(Name ='test quote', OpportunityId= oppty.Id, Application__c=true, Up_Front_Costs_Applicable__c = 'Yes',
                             Purpose__c= 'Solar',Gruop_Name__c='One',Quote_Group_Label__c='One', Customer_Amount__c = 35000, Loan_Term__c = 60, Product__c = productList[0].Id,
                             Interest_Rate__c = 3.99, Actual_Comparison_Rate__c = 4.99));
        qtlist.add(New Quote(Name ='test quote2', OpportunityId= oppty.Id, Application__c=true, Up_Front_Costs_Applicable__c = 'Yes',
                             Purpose__c= 'Solar',Gruop_Name__c='Referral-1',Quote_Group_Label__c='Referral-1', Customer_Amount__c = 60000, Loan_Term__c = 80, Product__c = productList[1].Id,
                             Interest_Rate__c = 7.99, Actual_Comparison_Rate__c = 8.99));
        qtlist.add(New Quote(Name ='test quote3', OpportunityId= oppty.Id, Application__c=true, Up_Front_Costs_Applicable__c = 'Yes',
                             Purpose__c= 'Solar',Gruop_Name__c='Referral-1',Quote_Group_Label__c='Referral-1', Customer_Amount__c = 60000, Loan_Term__c = 80, Product__c = productList[1].Id,
                             Interest_Rate__c = 5.99, Actual_Comparison_Rate__c = 6.99));
        insert qtlist;
        Loan_Fees__c fee1 = New Loan_Fees__c(Amount__c = 200, Product__c = productList[0].Id);
        insert fee1;  
        
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Content',
            VersionData = Blob.valueOf('Test Content Data'),
            PathOnClient = 'TestContent.txt',
            ContentLocation = 'S'
        );        
        insert testContentVersion;
        
        ContentDocumentLink link = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id].ContentDocumentId,
            LinkedEntityId = oppty.Id,
            ShareType = 'I'
        );
        insert link;
        
        
    }
    
    static testMethod void testGetMyReferrals() {
        Contact Con = [SELECT Id,Name FROM Contact WHERE Name = 'TestRef Contact' LIMIT 1];
        test.startTest();
        List<MyReferrerController.getMyReferralWrapper> result = MyReferrerController.getMyRefferals(null, Con.Id, null);
        List<MyReferrerController.getMyReferralWrapper> result1 = MyReferrerController.getMyRefferals('test opp', Con.Id, null);
        List<MyReferrerController.getMyReferralWrapper> result2 = MyReferrerController.getMyRefferals(null, Con.Id, 'Name ASC');
        List<MyReferrerController.getMyReferralWrapper> result3 = MyReferrerController.getMyRefferals(null, Con.Id, 'CreatedDate DESC');
        List<MyReferrerController.getMyReferralWrapper> result4 = MyReferrerController.getMyRefferals('test opp', Con.Id, 'CreatedDate ASC');
        List<MyReferrerController.getMyReferralWrapper> result5 = MyReferrerController.getMyRefferals('test opp', Con.Id, 'Name DESC');
        List<MyReferrerController.getMyReferralWrapper> result6 = MyReferrerController.getMyRefferals('test opp', '', 'Name DESC');
        test.stopTest(); 
        System.assertNotEquals(null, result, 'The result should not be null');
        
    }
    static testMethod void testSaveOpportunityOnMyReferralCard(){
        Opportunity Opp = [SELECT Id,Name,StageName,Applicant_1__c,Applicant_1__r.FirstName,
                           Applicant_1__r.LastName,Applicant_1__r.Phone,Applicant_1__r.PersonEmail
                           From Opportunity WHERE Name ='Test Opportunity 1'];
        Account acc = [SELECT Id,Name,FirstName,LastName,Phone,PersonEmail FROM Account WHERE Name ='Test Opportunity 1'];
        Opportunity resultOpp = MyReferrerController.SaveOpportunityOnMyReferralCard(Opp);
        
        System.assertEquals(acc.Id, resultOpp.Applicant_1__c);
        System.assertEquals(acc.FirstName, resultOpp.Applicant_1__r.FirstName);
        System.assertEquals(acc.LastName, resultOpp.Applicant_1__r.LastName);
        System.assertEquals(acc.Phone, resultOpp.Applicant_1__r.Phone);
        System.assertEquals(acc.PersonEmail, resultOpp.Applicant_1__r.PersonEmail);
    }
    
    static testMethod void testgetUpdatedListofOpp(){
        Contact Con = [SELECT Id,Name FROM Contact WHERE Name = 'TestRef Contact' LIMIT 1];
        test.startTest();
        List<MyReferrerController.getMyReferralWrapper> result = MyReferrerController.getUpdatedListofOpp('All',Con.Id,'name','CreatedDate DESC'); 
        List<MyReferrerController.getMyReferralWrapper> result1 = MyReferrerController.getUpdatedListofOpp('Quotes',Con.Id,'name','CreatedDate DESC'); 
        List<MyReferrerController.getMyReferralWrapper> result2 = MyReferrerController.getUpdatedListofOpp('Applications',Con.Id,'name','CreatedDate DESC');
        List<MyReferrerController.getMyReferralWrapper> result3 = MyReferrerController.getUpdatedListofOpp('Approved',Con.Id,'name','CreatedDate ASC'); 
        List<MyReferrerController.getMyReferralWrapper> result4 = MyReferrerController.getUpdatedListofOpp('Funded',Con.Id,'name','CreatedDate ASC');
        List<MyReferrerController.getMyReferralWrapper> result5 = MyReferrerController.getUpdatedListofOpp('Funded',Con.Id,'name',null);
        List<MyReferrerController.getMyReferralWrapper> result6 = MyReferrerController.getUpdatedListofOpp('Funded',Con.Id,null,null);
        List<MyReferrerController.getMyReferralWrapper> result7 = MyReferrerController.getUpdatedListofOpp('Funded',Con.Id,'name','Name ASC');
        List<MyReferrerController.getMyReferralWrapper> result8 = MyReferrerController.getUpdatedListofOpp('Funded',Con.Id,null,'CreatedDate ASC');
        List<MyReferrerController.getMyReferralWrapper> result9 = MyReferrerController.getUpdatedListofOpp('Funded',Con.Id,null,'Name DESC');
        test.stopTest();
        
        Contact Con1 = MyReferrerController.getCondata(Con.Id);
        Contact con2 = MyReferrerController.getCondata('');
    } 
    
    static testMethod void testcreateActionRequest(){
        Contact Con = [SELECT Id,Name FROM Contact WHERE Name = 'TestRef Contact' LIMIT 1];
        Opportunity Opp = [SELECT Id,Name From Opportunity where FinServ__ReferredByContact__c =: Con.Id LIMIT 1];
        id opId = Opp.Id;
        String idOfOp = (String)opId;
        
        MyReferrerController.GetVoiRelToOpp(idOfOp);
        MyReferrerController.GetVoiRelToOpp('');
        MyReferrerController.sendMail(idOfOp);
        MyReferrerController.sendMail('');
        //MyReferrerController.sendVoi1('0400000000', idOfOp, Con.Name, 'FULL');
        //MyReferrerController.sendVoi2('0400000000', idOfOp, Con.Name, 'FULL');
        
        List<Action_Centre_Request__c> resul1 = MyReferrerController.createActionRequest(Con.Id, Opp.Id, 'Escalation Request', 'TestBody', null, 'Standard', 'Approved');
        List<Action_Centre_Request__c> resul2 = MyReferrerController.createActionRequest('', '', 'Escalation Request', 'TestBody', null, 'Standard', 'Approved');
        List<Action_Centre_Request__c> result3 = MyReferrerController.getActionCentreRequest(Con.Id, Opp.Id);
        List<Action_Centre_Request__c> result4 = MyReferrerController.getActionCentreRequest('', '');
    }
    
    static testMethod void testGroupquotes(){
        Contact Con = [SELECT Id,Name FROM Contact WHERE Name = 'TestRef Contact' LIMIT 1];
        Opportunity Opp = [SELECT Id,Name,RecordType.Name,LeadId__c From Opportunity where name ='test Oppty' LIMIT 1];
        
        list<MyReferrerController.getQuotesWrapper> result = MyReferrerController.GroupQuotes(Opp.Id);
        
        string newresult = JSON.serialize(result);
        String quoteType = opp.recordType.name;
        if(Opp.recordType.name=='Green Loan'){
            quoteType='Solar';
        }
        
        MyReferrerController.updatequotes(newresult,quoteType,Opp.Id,Opp.LeadId__c);
        MyReferrerController.sendQuotes(newresult, Opp.Id, Con.Id, 'opp1@test.com', 'con@gmail.com', 'Yes');
        MyReferrerController.sendQuotes(newresult, Opp.Id, Con.Id, 'opp1@test.com', 'con@gmail.com', 'No');        
        
        List<MyReferrerController.QuoteDetailWrapper> qtWrapper= new List<MyReferrerController.QuoteDetailWrapper>();
        
        MyReferrerController.ret(qtWrapper);
        MyReferrerController.ret1();
        
        String wrp = '[{"cdlId":[],"NmList":[],"Amount":"2000","masterQuote":"one"}]';
        
        MyReferrerController.newQuotes(quoteType, Opp.LeadId__c, Opp.Id, wrp);
        MyReferrerController.selectedQuotes(newresult,Opp.Id);
        
    }
    
    static testMethod void testSaveAddressMethod(){
        Opportunity Opp = [SELECT Id,Name From Opportunity where name ='test Oppty' LIMIT 1];
        MyReferrerController.SaveAddressOnOpp(Opp,'ajmer','opp1@test.com','a','b','c','d','e','f','g');
        MyReferrerController.SaveAddressOnOpp(Opp,'','','a','b','c','d','e','f','g');
        MyReferrerController.GetOppOnExpand(Opp.Id);
        MyReferrerController.GetOppOnExpand('');
    }
    
    static testMethod void testVoiMethod(){
        Contact Con = [SELECT Id,Name,Phone FROM Contact WHERE Name = 'TestRef Contact' LIMIT 1];
        Opportunity Opp = [SELECT Id,Name,Applicant_1__c, Applicant_2__c,FinServ__ReferredByContact__c,RecordType.Name,LeadId__c From Opportunity where name ='test Oppty' LIMIT 1];
        MyReferrerController.sendVoi1(Con.Phone, Opp.Id, Con.Name, 'FULL');
        MyReferrerController.sendVoi2(Con.Phone, Opp.Id, Con.Name, 'FULL');
        Date today = System.today();
        MyReferrerController.createFundingRequest(Opp.Id, 2000, 'Payment in full before installation', 20000, 'Yes',today , 'Both to sign', 0, Opp.Applicant_1__c, Opp.Applicant_2__c, Opp.FinServ__ReferredByContact__c);
        MyReferrerController.getPreviousFundingRequests(Opp.Id);
    }
    
    static testMethod void testDocumentsFunctions(){
        Opportunity Opp = [SELECT Id,Name,RecordType.Name,LeadId__c From Opportunity where name ='test Oppty' LIMIT 1];   
        ContentDocumentLink cnt = [SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =:Opp.Id LIMIT 1];  
        
        MyReferrerController.addDocReqOnOppfromFunding(opp.Id,cnt.ContentDocumentId);
        
        ContentVersion cvold = [SELECT Id,Document_Requested__c,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: cnt.ContentDocumentId LIMIT 1];    
        ContentVersion cvv = new ContentVersion(
            Title = 'Test ContentNew',
            VersionData = Blob.valueOf('Test Content Data'), 
            PathOnClient = 'TestContent.txt', 
            ContentLocation = 'S'
        );        
        insert cvv;
        
        ContentDocumentLink link = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cvv.Id].ContentDocumentId,
            LinkedEntityId = Opp.Id,
            ShareType = 'I'
        );
        insert link;
        
        MyReferrerController.ReplaceDoc(Opp.Id,link.ContentDocumentId, cvold.Document_Requested__c);
        MyReferrerController.getDocument(Opp.Id);
        MyReferrerController.deleteDocumentRequest(Opp.Id, cvold.Document_Requested__c);
    }
}