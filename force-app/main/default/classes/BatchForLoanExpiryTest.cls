@istest
public class BatchForLoanExpiryTest {
    static testmethod void LoanApprovalExpiryBatchTest(){
        String recordTypeRefId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Referrer (Business)').getRecordTypeId();
        String recordTypePId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
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
        testAcc2.FirstName = 'Test';
        testAcc2.LastName = 'Opportunity 2';
        testAcc2.Phone = '1234567890';
        testAcc2.PersonEmail = 'opp2@test.com';
        
        insert testAcc2;
        
        Contact testCon = new Contact();
        testCon.FirstName = 'TestRef';
        testCon.LastName = 'Contact';
        testCon.AccountId = testAcc.Id;
        testCon.Admin__c = true;
        testCon.Email = 'test@gmail.com';
        insert testCon;
       
        Opportunity oppty = new Opportunity ();
        oppty.applicant_1__c = testAcc1.Id;
        oppty.applicant_2__c = testAcc2.Id;  
        oppty.AccountId = testAcc1.Id;
        oppty.FinServ__ReferredByContact__c = testCon.Id;
        oppty.Contact_1__c = testCon.Id;
        oppty.name = 'test Oppty';
        oppty.StageName='Approved'; 
        oppty.CloseDate = Date.today();
        oppty.Application_Sections__c ='Own and Owe'; 
        oppty.Current_Application_Sections__c ='Who is applying';
        oppty.RecordTypeId = recid;
        oppty.Approved_Date__c = system.now().addDays(-30); 
        insert oppty; 
        
        Opportunity opp = new Opportunity ();
        opp.applicant_1__c = testAcc1.Id;
        opp.AccountId = testAcc1.Id;
        opp.FinServ__ReferredByContact__c = testCon.Id;
        opp.Contact_1__c = testCon.Id;
        opp.name = 'test opp';
        opp.StageName='Approved'; 
        opp.CloseDate = Date.today();
        opp.Application_Sections__c ='Own and Owe'; 
        opp.Current_Application_Sections__c ='Who is applying';
        opp.RecordTypeId = recid;
        opp.Approved_Date__c = system.now().addDays(-60);
        insert opp;
        
        Opportunity opp1 = new Opportunity ();
        opp1.applicant_1__c = testAcc1.Id;
        opp1.AccountId = testAcc1.Id;
        opp1.FinServ__ReferredByContact__c = testCon.Id;
        opp1.Contact_1__c = testCon.Id;
        opp1.name = 'test opp';
        opp1.StageName='Approved'; 
        opp1.CloseDate = Date.today();
        opp1.Application_Sections__c ='Own and Owe'; 
        opp1.Current_Application_Sections__c ='Who is applying';
        opp1.RecordTypeId = recid;
        opp1.Approved_Date__c = system.now().addDays(-80);
        insert opp1;  
        
        Opportunity opp2 = new Opportunity ();
        opp2.applicant_1__c = testAcc1.Id;
        opp2.AccountId = testAcc1.Id;
        opp2.FinServ__ReferredByContact__c = testCon.Id;
        opp2.Contact_1__c = testCon.Id;
        opp2.name = 'test opp';
        opp2.StageName='Approved'; 
        opp2.CloseDate = Date.today();
        opp2.Application_Sections__c ='Own and Owe'; 
        opp2.Current_Application_Sections__c ='Who is applying';
        opp2.RecordTypeId = recid;
        opp2.Approved_Date__c = system.now().addDays(-31);
        insert opp2;
        
        Opportunity opp3 = new Opportunity ();
        opp3.applicant_1__c = testAcc1.Id;
        opp3.AccountId = testAcc1.Id;
        opp3.FinServ__ReferredByContact__c = testCon.Id;
        opp3.Contact_1__c = testCon.Id;
        opp3.name = 'test opp';
        opp3.StageName='Approved'; 
        opp3.CloseDate = Date.today();
        opp3.Application_Sections__c ='Own and Owe'; 
        opp3.Current_Application_Sections__c ='Who is applying';
        opp3.RecordTypeId = recid;
        opp3.Approved_Date__c = system.now().addDays(-61);
        insert opp3;
        
        Opportunity opp4 = new Opportunity ();
        opp4.applicant_1__c = testAcc1.Id;
        opp4.AccountId = testAcc1.Id;
        opp4.Contact_1__c = testCon.Id;
        opp4.name = 'test opp55';
        opp4.StageName='Funding'; 
        opp4.CloseDate = Date.today();
        opp4.Application_Sections__c ='Own and Owe'; 
        opp4.Current_Application_Sections__c ='Who is applying';
        opp4.RecordTypeId = recid;
        opp4.Approved_Date__c = system.now().addDays(-81);
        insert opp4;
        
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
        qtlist.add(New Quote(Name ='test quote2', OpportunityId= opp.Id, Application__c=true, Up_Front_Costs_Applicable__c = 'Yes',
                             Purpose__c= 'Solar',Gruop_Name__c='Referral-1',Quote_Group_Label__c='Referral-1', Customer_Amount__c = 60000, Loan_Term__c = 80, Product__c = productList[1].Id,
                             Interest_Rate__c = 7.99, Actual_Comparison_Rate__c = 8.99));
        qtlist.add(New Quote(Name ='test quote3', OpportunityId= opp1.Id, Application__c=true, Up_Front_Costs_Applicable__c = 'Yes',
                             Purpose__c= 'Solar',Gruop_Name__c='Referral-1',Quote_Group_Label__c='Referral-1', Customer_Amount__c = 60000, Loan_Term__c = 80, Product__c = productList[1].Id,
                             Interest_Rate__c = 5.99, Actual_Comparison_Rate__c = 6.99));
        insert qtlist;
        
        Loan_Fees__c fee1 = New Loan_Fees__c(Amount__c = 200, Product__c = productList[0].Id);
        insert fee1;
        
        Test.startTest();
        BatchForLoanExpiry opptybatch = new BatchForLoanExpiry ();
        Database.executebatch(opptybatch,10);
        Test.stopTest();
        
    }
}