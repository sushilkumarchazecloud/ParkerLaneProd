@istest
public class BatchForFundingTasksTest {
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
        testOpp1.Approved_Date__c = Date.Today();
        insert testOpp1;
        
        Opportunity testOpp2 = new Opportunity();
        testOpp2.Name = 'Test Opportunity 2';
        testOpp2.FinServ__ReferredByContact__c = testCon.Id;
        testOpp2.Contact_1__c = testCon.id;
        testOpp2.StageName ='Approved';
        testOpp2.CloseDate = System.Today();
        testOpp2.Applicant_1__c = testAcc1.Id;
        testOpp2.Applicant_2__c = testAcc2.id;
        testOpp2.Approved_Date__c = Date.Today();
        insert testOpp2;
        
        List<Product2> productList = new List<Product2>();
        productList.add(New Product2(IsActive =true, Default_Product__c = true,
                                     Product_Type__c = 'Green Loan', Product_Order__c = 1,
                                     Name = 'product', Features__c='Feature1;Feature2',
                                     Acceptable_Loan_Purpose__c = 'Solar', Funding_Authorisation_Type__c = 'Managed via Parker Lane',
                                     Maximum_Loan_Term_Years__c =1,Maximum_Loan_Amount__c=80000,
                                     Minimum_Loan_Amount__c = 1000,
                                     Is_Feature_Product__c=TRUE));
        productList.add(New Product2(IsActive =true, Default_Product__c = true,
                                     Product_Type__c = 'Green Loan', Product_Order__c = 2,
                                     Name = 'product2', Features__c='Feature1;Feature2',Funding_Authorisation_Type__c = 'Direct with lender',
                                     Acceptable_Loan_Purpose__c = 'Solar',Maximum_Loan_Amount__c=80000,
                                     Minimum_Loan_Amount__c = 1000,
                                     Maximum_Loan_Term_Years__c =5));
        productList.add(New Product2(IsActive =true, Default_Product__c = true,
                                     Product_Type__c = 'Green Loan', Product_Order__c = 3,
                                     Name = 'product3', Features__c='Feature1;Feature2',Funding_Authorisation_Type__c = 'Managed via Parker Lane',
                                     Acceptable_Loan_Purpose__c = 'Solar',Maximum_Loan_Amount__c=80000,
                                     Minimum_Loan_Amount__c = 1000,
                                     Maximum_Loan_Term_Years__c =3));
        insert productList;
        list<quote> qtlist = new list<quote>();
        qtlist.add(New Quote(Name ='test quote', OpportunityId= testOpp1.Id, Application__c=true, Up_Front_Costs_Applicable__c = 'Yes',
                             Purpose__c= 'Solar',Gruop_Name__c='One',Quote_Group_Label__c='One', Customer_Amount__c = 35000, Loan_Term__c = 60, Product__c = productList[0].Id,
                             Interest_Rate__c = 3.99, Actual_Comparison_Rate__c = 4.99));
        qtlist.add(New Quote(Name ='test quote2', OpportunityId= testOpp2.Id, Up_Front_Costs_Applicable__c = 'Yes',
                             Purpose__c= 'Solar',Gruop_Name__c='Referral-1',Quote_Group_Label__c='Referral-1', Customer_Amount__c = 60000, Loan_Term__c = 80, Product__c = productList[1].Id,
                             Interest_Rate__c = 7.99, Actual_Comparison_Rate__c = 8.99));
        qtlist.add(New Quote(Name ='test quote3', OpportunityId= testOpp1.Id, Up_Front_Costs_Applicable__c = 'Yes',
                             Purpose__c= 'Solar',Gruop_Name__c='Referral-1',Quote_Group_Label__c='Referral-1', Customer_Amount__c = 60000, Loan_Term__c = 80, Product__c = productList[2].Id,
                             Interest_Rate__c = 5.99, Actual_Comparison_Rate__c = 6.99));
        insert qtlist;
        
        testOpp1.SyncedQuoteId = qtlist[0].id;
        update testOpp1;
        
        testOpp2.SyncedQuoteId = qtlist[1].id;
        update testOpp2;
        
    }
    
    static testMethod void test1(){
        Opportunity opp = [select id,Applicant_1__c,Applicant_2__c,Applicant_2__r.personcontactId,SyncedQuote.Product__r.Funding_Authorisation_Type__c,Customer_Support_Person__c,Approved_Expire_Date__c,name from opportunity where Name= 'Test Opportunity 1' LIMIT 1];
        Funding_Request__c fr2 = new Funding_Request__c();
        fr2.Request_Type__c = 'Payment in full before installation';
        fr2.Request_Status__c = 'Payment requested by supplier';
        fr2.Opportunity__c = opp.Id;
        fr2.Applicant_1_A1__c = opp.Applicant_1__c;
        fr2.Applicant_2_A2__c = opp.Applicant_2__c;
        fr2.Requested_by__c = 'Supplier';
        fr2.Person_Requesting__c = opp.Applicant_2__r.personcontactId;
        fr2.Customer_Authorisation_Type__c = 'Both to sign';
        fr2.Customer_Authorisation_Status__c = 'Request sent to customer(s)';
        //fr2.Date_Last_Request_Status_Changes__c = system.now().addDays(-3);
        fr2.Funding_On_Hold__c =false;
        insert fr2;
        
        fr2.Date_Last_Request_Status_Changes__c = system.now().addDays(-3);
        update fr2;
        
        Test.startTest();
        BatchForFundingTasks opptybatch = new BatchForFundingTasks ();
        Database.executebatch(opptybatch,10);
        Test.stopTest();
    }
    
    static testMethod void test2(){
        Opportunity opp = [select id,Applicant_1__c,Applicant_2__c,Applicant_2__r.personcontactId,SyncedQuote.Product__r.Funding_Authorisation_Type__c,Customer_Support_Person__c,Approved_Expire_Date__c,name from opportunity where Name= 'Test Opportunity 1' LIMIT 1];
        Funding_Request__c fr2 = new Funding_Request__c();
        fr2.Request_Type__c = 'Payment in full before installation';
        fr2.Request_Status__c = 'Payment requested by supplier';
        fr2.Opportunity__c = opp.Id;
        fr2.Applicant_1_A1__c = opp.Applicant_1__c;
        fr2.Applicant_2_A2__c = opp.Applicant_2__c;
        fr2.Requested_by__c = 'Supplier';
        fr2.Person_Requesting__c = opp.Applicant_2__r.personcontactId;
        fr2.Customer_Authorisation_Type__c = 'Both to sign';
        fr2.Customer_Authorisation_Status__c = 'Pending Applicant 1';
        //fr2.Date_Last_Request_Status_Changes__c = system.now().addDays(-3);
        fr2.Funding_On_Hold__c =false;
        insert fr2;
        
        fr2.Date_Last_Request_Status_Changes__c = system.now().addDays(-3);
        update fr2;
        
        Test.startTest();
        BatchForFundingTasks opptybatch = new BatchForFundingTasks ();
        Database.executebatch(opptybatch,10);
        Test.stopTest();
    }
    
    static testMethod void test3(){
        Opportunity opp = [select id,Applicant_1__c,Applicant_2__c,Applicant_2__r.personcontactId,SyncedQuote.Product__r.Funding_Authorisation_Type__c,Customer_Support_Person__c,Approved_Expire_Date__c,name from opportunity where Name= 'Test Opportunity 1' LIMIT 1];
        Funding_Request__c fr2 = new Funding_Request__c();
        fr2.Request_Type__c = 'Payment in full before installation'; 
        fr2.Request_Status__c = 'Payment requested by supplier';
        fr2.Opportunity__c = opp.Id;
        fr2.Applicant_1_A1__c = opp.Applicant_1__c;
        fr2.Applicant_2_A2__c = opp.Applicant_2__c;
        fr2.Requested_by__c = 'Supplier';
        fr2.Person_Requesting__c = opp.Applicant_2__r.personcontactId;
        fr2.Customer_Authorisation_Type__c = 'Both to sign';
        fr2.Customer_Authorisation_Status__c = 'Pending Applicant 2';
        //fr2.Date_Last_Request_Status_Changes__c = system.now().addDays(-3);
        fr2.Funding_On_Hold__c =false;
        insert fr2;
        
        fr2.Date_Last_Request_Status_Changes__c = system.now().addDays(-9);
        update fr2;
        
        Test.startTest();
        BatchForFundingTasks opptybatch = new BatchForFundingTasks ();
        Database.executebatch(opptybatch,10);
        Test.stopTest();
    }
    
       static testMethod void test4(){
        Opportunity opp = [select id,Applicant_1__c,Applicant_2__c,Applicant_2__r.personcontactId,SyncedQuote.Product__r.Funding_Authorisation_Type__c,Customer_Support_Person__c,Approved_Expire_Date__c,name from opportunity where Name= 'Test Opportunity 2' LIMIT 1];
        Funding_Request__c fr2 = new Funding_Request__c();
        fr2.Request_Type__c = 'Payment in full before installation'; 
        fr2.Request_Status__c = 'Payment requested by supplier';
        fr2.Opportunity__c = opp.Id;
        fr2.Applicant_1_A1__c = opp.Applicant_1__c;
        fr2.Applicant_2_A2__c = opp.Applicant_2__c;
        fr2.Requested_by__c = 'Supplier';
        fr2.Person_Requesting__c = opp.Applicant_2__r.personcontactId;
        fr2.Customer_Authorisation_Type__c = 'Both to sign';
        fr2.Customer_Authorisation_Status__c = 'Pending Applicant 2';
        //fr2.Date_Last_Request_Status_Changes__c = system.now().addDays(-3);
        fr2.Funding_On_Hold__c =false;
        insert fr2;
        
        fr2.Date_Last_Request_Status_Changes__c = system.now().addDays(-4);
        update fr2;
        system.debug('fund'+fr2.Opportunity__r.SyncedQuote.Product__r.Funding_Authorisation_Type__c);
        Test.startTest();
        BatchForFundingTasks opptybatch = new BatchForFundingTasks ();
        Database.executebatch(opptybatch,10);
        Test.stopTest();
    }
}