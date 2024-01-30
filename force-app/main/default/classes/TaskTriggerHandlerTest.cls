@isTest
public class TaskTriggerHandlerTest {
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
        
        Contact testCon = new Contact();
        testCon.FirstName = 'TestRef';
        testCon.LastName = 'Contact';
        testCon.AccountId = testAcc.Id;
        testCon.Admin__c = true;
        testCon.Portal_View__c = 'Admin View';
        testCon.Phone ='0412568868';
        insert testCon;
        
        Lead le = new Lead();
        le.RecordTypeId = LeadRecordType;
        le.FirstName = 'Test';
        le.LastName = 'Opportunity 1';
        le.Email = 'opp1@test.com';
        insert le;
        
        Opportunity oppty = new Opportunity ();
        oppty.applicant_1__c = testAcc.Id;
        oppty.FinServ__ReferredByContact__c = testCon.Id;
        oppty.name = 'test Oppty';
        oppty.StageName='Assessment Needed'; 
        oppty.CloseDate = Date.today();
        oppty.Application_Sections__c ='Own and Owe'; 
        oppty.Current_Application_Sections__c ='Who is applying';
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
        
        Funding_Request__c fr = new Funding_Request__c();
        fr.Request_Amount__c = 20000;
        fr.Invoice_Amount__c = 20000;
        fr.Request_Type__c = 'Part payment before installation';
        fr.Request_Status__c = 'Payment funded';
        fr.Opportunity__c = oppty.Id;
        fr.Requested_by__c = 'Supplier';
        fr.Person_Requesting__c = oppty.Applicant_1__r.personcontactId;
        fr.Installation_Date__c = date.today();
        fr.Applicant_1_A1__c = oppty.Applicant_1__c;
            
        Insert fr;
        
        User usr = [SELECT Id,username FROM USER WHERE username =: System.Label.Admin_User_Name];
        Task tk = new Task();
        tk.WhatId = fr.Id; 
        tk.WhoId = fr.Applicant_1_A1__r.PersonContactId;
        tk.Subject ='Day 1 Funding Handover Call '; 
        tk.Description = 'IMPORTANT: If the funding handover call is successful, you must mark ‘Sales outcome’ fields = Successful. An SMS will automatically be sent if you save this task as successful with instructions to call the lender back and to let you know if the call was successful.';  
        tk.OwnerId = usr.Id;
        tk.ActivityDate =  Date.today();
        tk.Type = 'Call';
        tk.Priority = 'Medium';
        insert tk;
    }
    
     static testMethod void testUpdateFundingHandOverTasks() {
         List<Task> tkList = [SELECT Id,Description,Status,Outcome__c FROM TASK ];
         for(Task newtk : tkList){
             newtk.Status = 'Completed';
             newtk.Outcome__c = 'Successful';
         }
         Update tkList;
     }
}