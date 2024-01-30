@isTest
Private class UploadDocuments_Test {
    @isTest
    static void getContacts(){
         String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String recordHTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Household').getRecordTypeId();
        
        
        Account accPerson= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test Person',
            LastName='Test LName',
            PersonEmail='test@yahoo.com',
            PersonBirthdate = system.today(),
            Is_Sync_with_Household__c=false,
            Phone = '0400000000',
            Security_Question__pc = 'Mothers maiden name',
            Security_Answer__pc = 'qwerty',
            Rental_Amount__pc = 500,
            Rental_or_Board_paid__pc =  50,
            Education_ChildCare_SchoolFees_Uniform__pc = 12,
            Maintenance_If_pay_child_maintenance__pc =  25,
            Other_loans_and_or_debt_commitments__pc = 24,
            Education_public_and_private__pc  = 10,
            Driver_s_licence_state_Territory__pc = 'Queensland',
            Connections_Phone_Mobile_Internet_C__pc = 200,
            FinServ__NumberOfChildren__pc = 3
        );
        insert accPerson;
        
        Opportunity opp = new Opportunity(Name='Test',applicant_1__c = accPerson.id, StageName='open', CloseDate= Date.today());
        Insert opp;
        
        List<Product2> productList = new List<Product2>();
        productList.add(New Product2(IsActive =true, Default_Product__c = true,
                                     Product_Type__c = 'Green Loan', Product_Order__c = 1,
                                     Name = 'product(6-10)', Features__c='Feature1;Feature2',
                                     Acceptable_Loan_Purpose__c = 'Solar',
                                     Maximum_Loan_Term_Years__c =1,
                                    Is_Feature_Product__c=TRUE));
        productList.add(New Product2(IsActive =true, Default_Product__c = true,
                                     Product_Type__c = 'Green Loan', Product_Order__c = 2,
                                     Name = 'product2(6-10)', Features__c='Feature1;Feature2',
                                     Acceptable_Loan_Purpose__c = 'Solar',
                                     Maximum_Loan_Term_Years__c =5));
        productList.add(New Product2(IsActive =true, Default_Product__c = true,
                                     Product_Type__c = 'Green Loan', Product_Order__c = 3,
                                     Name = 'product3(6-10)', Features__c='Feature1;Feature2',
                                     Acceptable_Loan_Purpose__c = 'Solar',
                                     Maximum_Loan_Term_Years__c =3));
        insert productList;
        
        Quote qt = New Quote(Name ='test quote', OpportunityId= opp.Id, Application__c=true, Up_Front_Costs_Applicable__c = 'Yes',
                             Purpose__c= 'Solar', Customer_Amount__c = 1000, Loan_Term__c = 60, Product__c = productList[0].Id,
                             Interest_Rate__c = 5, Actual_Comparison_Rate__c = 20,Lender__c = 'Transport Mutual Credit Union');
        insert qt;
        Loan_Fees__c fee1 = New Loan_Fees__c(Amount__c = 200, Product__c = productList[0].Id);
        insert fee1;
        
        opp.Access_Id__c = opp.id;
        update opp;
        Document_Requested__c Dc = new Document_Requested__c(Opportunity__c = opp.id, isComplete__c = false,Document__c='Test',Category__c='Bank Statements');
        insert Dc;
        
        Opportunity oppUpdate = [SELECT Id, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                                 FROM Opportunity WHERE Id =: opp.Id];
        
        FinServ__Employment__c emp1 =New FinServ__Employment__c();
        emp1.Name = 'test';
        emp1.FinServ__EmploymentStatus__c = 'Full time permanent';
        emp1.FinServ__Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        emp1.Years__c = 2;
        emp1.Work_Overtime_amount__c = 250;
        emp1.Commission_or_Bonus_amount__c = 520;
        emp1.Allowance_Amount__c = 250;
        emp1.Last_year_net_profit__c = 250;
        emp1.Months__c= 2;
        emp1.Source_Document__c = 'Mogo';
        emp1.Verified_Income_Amount__c = 1210;
        emp1.Verified_Income_Frequency__c = 'Monthly';
        emp1.Years_1_Previous__c = 2;
        emp1.Months_1_Previous__c = 2;
        emp1.FinServ__EndDate__c = system.today();
        emp1.Is_Primary__c = true;
        insert emp1;
        
        
        test.startTest();
        UploadDocuments.getOpportunityId(opp.Id,'https://teamindi-apply-parkerlane.cs76.force.com/apex/MogoSupportingDocument?MGACCESSID=680003188&MGREF=0069D00000BBQHoQAP');
        Object oc = UploadDocuments.getContacts(opp.Id,''); 
        Opportunity_Config__c cs = new Opportunity_Config__c(Name = 'Default', BankStmtURL__c = 'https://www.bankstatements.com.au/r/b/BZPK', Record_Type__c = 'Green Loan');
        insert cs;
        UploadDocuments.getBankStmtUrl(opp.Id);
        UploadDocuments.finishLater(opp.id);
        UploadDocuments.generateerrorTypeDoc(opp.Id);
        UploadDocuments.completeBankstatement(opp.Id);
        UploadDocuments.updateActivity(true, opp.Id);
        UploadDocuments.UpdateDocument(Dc.Id, false, 'test',true,true,opp.Id);
        sessionIdclass sc = new sessionIdclass();
        sc.ReturnAccessToken();
        string str = '[{"Id":"'+Dc.Id+'","isAlready_provided":false,"isComplete":false,"isNotApplicable":true,"isOpen":false,"isComment":false,"isStart":false,"count":0,"value":null}]';
        UploadDocuments.sendMail(opp.id,'1', str);
        test.stopTest();
    }
}