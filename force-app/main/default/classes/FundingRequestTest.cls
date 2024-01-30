@isTest
public class FundingRequestTest {
    @testsetup
    static void setUpData(){
        String recordTypePId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String recordTypeRefId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Referrer (Business)').getRecordTypeId();
        String recid = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Green Loan').getRecordTypeId();
        
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
        
        Account testAcc2 = new Account();
        testAcc2.RecordTypeId  = recordTypePId;
        testAcc2.FirstName = 'Test2';
        testAcc2.LastName = 'Opportunity 2';
        testAcc2.Phone = '1234567840';
        testAcc2.PersonEmail = 'opp1@tesrt.com';
        
        insert testAcc2;
        
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
        testOpp1.Contact_1__c = testCon.id;
        testOpp1.StageName ='Approved';
        testOpp1.CloseDate = System.Today();
        testOpp1.Applicant_1__c = testAcc1.Id;
        testOpp1.Applicant_2__c = testAcc2.id;
        insert testOpp1;
        
        Opportunity testOpportunity2 = new Opportunity();
        testOpportunity2.Name = 'Test Opportunity 2';
        testOpportunity2.FinServ__ReferredByContact__c = testCon.Id;
        testOpportunity2.Contact_1__c = testCon.id;
        testOpportunity2.StageName ='Funding';
        testOpportunity2.CloseDate = System.Today();
        testOpportunity2.Applicant_1__c = testAcc1.Id;
        testOpportunity2.Applicant_2__c= testAcc2.id;
        testOpportunity2.RecordTypeId = recid;
        insert testOpportunity2;
        
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
        qtlist.add(New Quote(Name ='test quote',Application__c=true, OpportunityId= testOpp1.Id, Up_Front_Costs_Applicable__c = 'Yes',
                             Purpose__c= 'Solar',Gruop_Name__c='One',Quote_Group_Label__c='One', Customer_Amount__c = 35000, Loan_Term__c = 60,
                             Interest_Rate__c = 3.99, Actual_Comparison_Rate__c = 4.99, Product__c = productList[0].Id));
        qtlist.add(New Quote(Name ='test quote2',Application__c=true, OpportunityId= testOpportunity2.Id, Up_Front_Costs_Applicable__c = 'Yes',
                             Purpose__c= 'Solar',Gruop_Name__c='Referral-1',Quote_Group_Label__c='Referral-1', Customer_Amount__c = 60000, Loan_Term__c = 80,
                             Interest_Rate__c = 7.99, Actual_Comparison_Rate__c = 8.99, Product__c = productList[0].Id));
        qtlist.add(New Quote(Name ='test quote3',Application__c=false, OpportunityId= testOpp1.Id, Up_Front_Costs_Applicable__c = 'Yes',
                             Purpose__c= 'Solar',Gruop_Name__c='Referral-1',Quote_Group_Label__c='Referral-1', Customer_Amount__c = 60000, Loan_Term__c = 80,
                             Interest_Rate__c = 5.99, Actual_Comparison_Rate__c = 6.99, Product__c = productList[1].Id));
        insert qtlist;
        
        Loan_Fees__c fee1 = New Loan_Fees__c(Amount__c = 200, Product__c = productList[0].Id);
        insert fee1;
        
        testOpp1.SyncedQuoteId = qtlist[0].id;
        update testOpp1;  
        
        Document_Requested__c dr = new Document_Requested__c();
        dr.Opportunity__c = testOpp1.id;
        dr.Category__c = 'Lender Credit Contract';
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
        
        ContentDocumentLink link = new ContentDocumentLink(ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id].ContentDocumentId,LinkedEntityId = testOpp1.Id,ShareType = 'I');
        insert link;
        
        list<Funding_Request__c> frList = new list<Funding_Request__c>();
        Funding_Request__c fr = new Funding_Request__c();
        fr.Request_Amount__c = 20000;
        fr.Invoice_Amount__c = 20000;
        fr.Request_Type__c = 'Part payment before installation';
        fr.Request_Status__c = 'Payment funded';
        fr.Opportunity__c = testOpportunity2.Id;
        fr.Requested_by__c = 'Supplier';
        fr.Person_Requesting__c = testOpportunity2.Applicant_1__r.personcontactId;
        fr.A1_Funding_Call_Handover__c = system.now();
        fr.A2_Funding_Call_Handover__c = system.now();
        fr.Installation_Date__c = date.today();
        fr.Net_Surplus_Shortfall__c = 2000;
        fr.Surplus_Shortfall_Treatment__c = 'Variation to contract (requires re-approval)';
        frList.add(fr);
        
        Funding_Request__c fr2 = new Funding_Request__c();
        fr2.Request_Type__c = 'Variation';
        fr2.Request_Status__c = 'Variation requested by customer';
        fr2.Opportunity__c = testOpp1.Id;
        fr2.Requested_by__c = 'Customer';
        fr2.Applicant_1_A1__c = testOpp1.Applicant_1__c;
        fr2.Applicant_2_A2__c = testOpp1.Applicant_2__c;
        fr2.Person_Requesting__c = testOpp1.Applicant_1__r.personcontactId;
        fr2.Invoice_Amount__c = 20000;
        fr2.Request_Amount__c = 15000;
        //frList.add(fr2);  
        insert frList; 
        
        list<VOI_Status__c> voiList = new list<VOI_Status__c>();
        VOI_Status__c obj = new VOI_Status__c();
        obj.Opportunity__c = testOpp1.id;
        obj.Contact__c = testOpp1.Applicant_1__r.PersonContactId;
        obj.Case_Status__c = 'Sent';
        obj.VOI_Type_For__c = 'E-SIGN';
        obj.Current_VOI_section__c = 'CQP';
        voiList.add(obj);
        
        VOI_Status__c obj2 = new VOI_Status__c();
        obj2.Opportunity__c = testOpp1.id;
        obj2.Contact__c = testOpp1.Applicant_2__r.PersonContactId;
        obj2.Case_Status__c = 'Sent';
        obj2.VOI_Type_For__c = 'E-SIGN';
        obj2.Current_VOI_section__c = 'CQP';
        //voiList.add(obj2);
        insert voiList;

    }
    
    /*static testMethod void testCheckConditions(){
        Opportunity opp = [select id,name from opportunity where Name= 'Test Opportunity 1' LIMIT 1];
        Opportunity opp2 = [select id,name from opportunity where Name= 'Test Opportunity 2' LIMIT 1];
        list<Funding_Request__c> fundlist = [select id,name,opportunity__c from Funding_Request__c where opportunity__c =:opp.id limit 1];
        FundingRequest.CheckConditions(opp.id);
        FundingRequest.CheckConditions(opp2.id);
    }*/
    
    static testMethod void testFundingReq(){
        Opportunity opp = [select id,name from opportunity where Name= 'Test Opportunity 1' LIMIT 1];
        Opportunity opp1 = [select id,name from opportunity where Name= 'Test Opportunity 2' LIMIT 1];
        list<Funding_Request__c> fundlist = [select id,name,opportunity__c from Funding_Request__c where opportunity__c =:opp1.id limit 1];
        FundingRequest fr = new FundingRequest();
        FundingRequest.CheckConditions(opp.id);
        FundingRequest.CheckConditions(opp1.id);
        FundingRequest.getOpp(opp.id);
        FundingRequest.getFundingRequest(opp1.id);
        //FundingRequest.createFundingRequestFromAction(opp.id,10000,'Variation',4000,'Supplier','Call',system.today(),'yes','Applicant 1','Either to sign');
        FundingRequest.getfundRequest2(opp1.id);
        FundingRequest.getDocument(opp.id);
    }
    
    static testMethod void testFundingReq2(){
        Opportunity opp = [select id,name,SyncedQuote.Customer_Amount__c from opportunity where Name= 'Test Opportunity 2' LIMIT 1];
        system.debug('opppAMount'+opp.SyncedQuote.Customer_Amount__c);
        list<Funding_Request__c> fundlist = [select id,Opportunity__r.SyncedQuote.Customer_Amount__c,name,
                                             Invoice_Amount__c, Request_Amount__c,Installation_Date__c,Opportunity__c,Request_Status__c,Requested_by__c,
                                             Variation_Status__c,Variation_Amount__c,New_Customer_Amount__c,A1_Variation_Request_Submitted_Date__c,
                                             Net_Surplus_Shortfall__c,Surplus_Shortfall_Treatment__c,Person_Requesting__c,VOI_link_app1__c,VOI_link_app2__c,Variation_Requested_By__c from Funding_Request__c where opportunity__c =:opp.id limit 1];
        system.debug('frrrAmount'+fundlist[0].Opportunity__r.SyncedQuote.Customer_Amount__c);
        FundingRequest.createReqest(fundlist[0]);
        FundingRequest.createVariation(fundlist[0]);
    }
    
    static testMethod void testFundingReq3(){
        Opportunity opp = [select id,name,SyncedQuote.Customer_Amount__c from opportunity where Name= 'Test Opportunity 1' LIMIT 1];
        system.debug('opppamt'+opp.SyncedQuote.Customer_Amount__c);
        List<Funding_Request__c> frList = [select id,name,Invoice_Amount__c, Request_Amount__c,Installation_Date__c,Opportunity__c,Request_Status__c,Requested_by__c,
                                             Variation_Status__c,Variation_Amount__c,New_Customer_Amount__c,A1_Variation_Request_Submitted_Date__c,
                                             Net_Surplus_Shortfall__c,Surplus_Shortfall_Treatment__c,Person_Requesting__c,VOI_link_app1__c,VOI_link_app2__c,Variation_Requested_By__c
                                             from Funding_Request__c where opportunity__c =:opp.id limit 1];
        test.Starttest();
        FundingRequest.createFundingRequestFromAction(opp.id,10000,'Variation',4000,'Supplier','Call',system.today(),'yes','Applicant 1','Either to sign');
        test.stopTest();
    }
    
    static testMethod void testFundingReq4(){
        Opportunity opp = [select id,name from opportunity where Name= 'Test Opportunity 2' LIMIT 1];
        list<Funding_Request__c> fundlist = [select id,name,opportunity__c,Person_Requesting__c,VOI_link_app1__c,VOI_link_app2__c from Funding_Request__c where opportunity__c =:opp.id limit 1];
        FundingRequest.getFundingOnHandOverPopUp(fundlist[0].id);
        FundingRequest.UpdateFundingHandOver(fundlist[0].id,false,false);
        FundingRequest.takeOffHold(fundlist[0].id);
    }
    
    static testMethod void testFundingReq5(){
        test.startTest();
        //FundingRequest.sendMessage('0412567677','HI');
        Opportunity opp = [select id,Applicant_1__c,Applicant_2__c,Applicant_1__r.personcontactId,Applicant_2__r.personcontactId,name from opportunity where Name= 'Test Opportunity 1' LIMIT 1];
        Funding_Request__c fr2 = new Funding_Request__c();
        fr2.Request_Type__c = 'Variation';
        fr2.Request_Status__c = 'Variation requested by customer';
        fr2.Opportunity__c = opp.Id;
        fr2.Requested_by__c = 'Customer';
        fr2.Applicant_1_A1__c = opp.Applicant_1__c;
        fr2.Applicant_2_A2__c = opp.Applicant_2__c;
        fr2.Person_Requesting__c = opp.Applicant_1__r.personcontactId;
        fr2.Invoice_Amount__c = 20000;
        fr2.Request_Amount__c = 15000;
        insert fr2;
        
        list<id> isList = new list<id>();
        list<Funding_Request__c> frlist = [select id from Funding_Request__c where Opportunity__c =:opp.id];
        for(Funding_Request__c fr : frlist){
            isList.add(fr.id);
        }
       
        FundingRequest.sendMessages(isList);
        FundingRequest.DeEscalateFunding(fr2.id);
        test.stopTest();
    }
    
    static testMethod void testFundingReq6(){
        Opportunity opp = [select id,Applicant_1__c,Applicant_2__c,Applicant_1__r.personcontactId,Applicant_2__r.personcontactId,name from opportunity where Name= 'Test Opportunity 1' LIMIT 1];
        list<id> isList = new list<id>();
        Funding_Request__c fr2 = new Funding_Request__c();
        fr2.Request_Type__c = 'Payment in full after installation';
        fr2.Request_Status__c = 'Payment requested by customer';
        fr2.Opportunity__c = opp.Id;
        fr2.Requested_by__c = 'Customer';
        fr2.Applicant_1_A1__c = opp.Applicant_1__c;
        fr2.Applicant_2_A2__c = opp.Applicant_2__c;
        fr2.Person_Requesting__c = opp.Applicant_1__r.personcontactId;
        fr2.Invoice_Amount__c = 20000;
        fr2.Request_Amount__c = 15000;
        insert fr2;
        
        Test.StartTest();
        FundingRequest.UpdateFundingRequest(fr2.id, 22000, 'Variation',21000,System.Today());
        FundingRequest.escalateFunding(fr2.id);
        Test.StopTest();
    }
    
    static testMethod void testFundingReq7(){
        Test.StartTest();
        FundingRequest.sendMessage('0412567677','HI');
        Test.StopTest();
    }
    
    static testMethod void testFundingReq8(){
        Test.StartTest();
        Opportunity opp = [select id,name,Applicant_1__c,Applicant_2__c,Applicant_1__r.personcontactId from opportunity where Name= 'Test Opportunity 1' LIMIT 1];
        Funding_Request__c fr2 = new Funding_Request__c();
        fr2.Request_Type__c = 'Variation';
        fr2.Request_Status__c = 'Variation requested by customer';
        fr2.Opportunity__c = opp.Id;
        fr2.Requested_by__c = 'Customer';
        fr2.Applicant_1_A1__c = opp.Applicant_1__c;
        fr2.Applicant_2_A2__c = opp.Applicant_2__c;
        fr2.Person_Requesting__c = opp.Applicant_1__r.personcontactId;
        fr2.Invoice_Amount__c = 20000;
        fr2.Request_Amount__c = 15000;  
        insert fr2;
        
        list<Funding_Request__c> fundlist = [select id,name,opportunity__c from Funding_Request__c where opportunity__c =:opp.id AND Request_Type__c = 'Variation' limit 1];
        string rec = fundlist[0].id;
        
        FundingRequest.cancelVariation(fundlist[0].id);
        FundingRequest.UpdateFundingRequest(fr2.id, 22000, 'Payment in full after installation',21000,System.Today());
        FundingRequest.insertAuthorisationCertificate(opp.id);
        Test.StopTest();
    }
    
}