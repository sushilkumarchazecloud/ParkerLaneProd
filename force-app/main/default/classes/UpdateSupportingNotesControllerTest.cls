@isTest
public class UpdateSupportingNotesControllerTest {
    @testsetup
    static void setUpData(){
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String recordHTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Household').getRecordTypeId();
        List<Account> accList= new List<Account>();
        Account acc= new Account(
            RecordTypeID=recordHTypeId ,
            Name='Test Name'
        );
        accList.add(acc);
        
        Account accPerson= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test Person',
            LastName='Test LName',
            PersonEmail='test@yahoo.com',
            Is_Sync_with_Household__c=false,
            Relationship_with_Applicant_1__c='Client'
        );
        accList.add(accPerson);
        
        Account accPerson2= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test Person2',
            LastName='Test LName',
            Phone ='1234567890',
            PersonEmail='test@yahoo.com',
            Is_Sync_with_Household__c=false,
            Relationship_with_Applicant_1__c='Spouse'
        );
        accList.add(accPerson2);
        
        insert accList;
        
        Account accChild= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test Child',
            LastName='Test LName',
            PersonEmail='test@yahoo.com',
            Is_Sync_with_Household__c=false,
            Relationship_with_Applicant_1__c='Dependent',
            Dependent_Parent__c = accPerson.Id
        );
        
        insert accChild;
        Account accChild2 = new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test Child',
            LastName='Test LName',
            PersonEmail='test@yahoo.com',
            Is_Sync_with_Household__c=false,
            Relationship_with_Applicant_1__c='Dependent',
            Dependent_Parent__c = accPerson2.Id
        );
        insert accChild2;
        
        Opportunity oppty = new Opportunity ();
        oppty.applicant_1__c = accPerson.Id;
        oppty.applicant_2__c = accPerson2.Id;
        oppty.AccountId = acc.Id;
        oppty.name = 'test Oppty';
        oppty.StageName='Assessment Needed'; 
        oppty.CloseDate = Date.today();
        oppty.Application_Sections__c ='Own and Owe'; 
        oppty.Current_Application_Sections__c ='Who is applying';
        oppty.Relationship_to_Applicant_2__c = 'Spouse';
        oppty.Confirm_Settlement_Date__c = true;
        oppty.Mortgage_repayments_halved__c = 'Yes';
        oppty.Servicing_Notes__c = 'Servicing Notes';
        insert oppty;
        
        Opportunity oppUpdate = [SELECT Id, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                                 FROM Opportunity WHERE Id =: oppty.Id];
        
        FinServ__Employment__c emp1 =New FinServ__Employment__c();
        emp1.Name = 'test';
        emp1.FinServ__EmploymentStatus__c = 'Part time permanent';
        emp1.FinServ__Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        emp1.Regularly_work_Overtime__c = 'Yes';
        emp1.Regularly_receive_Commission_or_Bonus__c = 'Yes';
        emp1.Regularly_Receive_Allowance__c = 'Yes';
        emp1.Provide_a_Company_Car__c = 'Yes';
        FinServ__Employment__c emp2 =New FinServ__Employment__c();
        emp2.Name = 'test1';
        emp2.FinServ__EmploymentStatus__c = 'Part time permanent';
        emp2.FinServ__Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        emp2.Regularly_work_Overtime__c = 'Yes';
        emp2.Regularly_receive_Commission_or_Bonus__c = 'Yes';
        emp2.Regularly_Receive_Allowance__c = 'Yes';
        emp2.Provide_a_Company_Car__c = 'Yes';
        insert New List<FinServ__Employment__c>{emp1, emp2};
            
        List<FinServ__AssetsAndLiabilities__c> assLiaList = new List<FinServ__AssetsAndLiabilities__c>();
        assLiaList.add(new FinServ__AssetsAndLiabilities__c(Name = 'Asset', Is_Address_Same__c= true, 
                                                            FinServ__PrimaryOwner__c = accPerson.Id,
                                                            Value__c = 10,
                                                            RecordTypeId = Schema.SObjectType.FinServ__AssetsAndLiabilities__c.getRecordTypeInfosByName().get('Asset').getRecordTypeId()));
        assLiaList.add(new FinServ__AssetsAndLiabilities__c(Name = 'Liability', 
                                                            FinServ__AssetsAndLiabilitiesType__c = 'Car Lease',
                                                            Institution__c = 'test',
                                                            Value__c = 10,
                                                            Monthly_Repayment__c=10,
                                                            Post_tax_lease_Payment__c =10,
                                                            Pre_tax_lease_Payment__c = 10,
                                                            FinServ__PrimaryOwner__c = accPerson.Id,
                                                            RecordTypeId = Schema.SObjectType.FinServ__AssetsAndLiabilities__c.getRecordTypeInfosByName().get('Liability').getRecordTypeId()));
        
        insert assLiaList;
        
        List<Product2> productList = new List<Product2>();
        productList.add(New Product2(IsActive =true, Default_Product__c = true,
                                     Product_Type__c = 'Green Loan', Product_Order__c = 1,
                                     Name = 'product', Features__c='Feature1;Feature2',
                                     Acceptable_Loan_Purpose__c = 'Solar',
                                     Maximum_Loan_Term_Years__c =1,
                                     Is_Feature_Product__c=TRUE));
        productList.add(New Product2(IsActive =true, Default_Product__c = true,
                                     Product_Type__c = 'Green Loan', Product_Order__c = 2,
                                     Name = 'product2', Features__c='Feature1;Feature2',
                                     Acceptable_Loan_Purpose__c = 'Solar',
                                     Maximum_Loan_Term_Years__c =5));
        productList.add(New Product2(IsActive =true, Default_Product__c = true,
                                     Product_Type__c = 'Green Loan', Product_Order__c = 3,
                                     Name = 'product3', Features__c='Feature1;Feature2',
                                     Acceptable_Loan_Purpose__c = 'Solar',
                                     Maximum_Loan_Term_Years__c =3));
        insert productList;
        
        Quote qt = New Quote(Name ='test quote', OpportunityId= oppty.Id, Application__c=true, Up_Front_Costs_Applicable__c = 'Yes',
                             Purpose__c= 'Solar', Customer_Amount__c = 1000, Loan_Term__c = 60, Product__c = productList[0].Id,
                             Interest_Rate__c = 5, Actual_Comparison_Rate__c = 20);
        insert qt;
        
        Loan_Fees__c fee1 = New Loan_Fees__c(Amount__c = 200, Product__c = productList[0].Id);
        insert fee1;
    }
    
    static testmethod void refreshNotesTest(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name ='test Oppty' Limit 1];
        
        Test.startTest();
        	UpdateSupportingNotesController.refreshNotes(opp.Id);
        Test.stopTest();
        opp = [SELECT Id, Application_Supporting_Notes__c FROM Opportunity WHERE Name ='test Oppty' Limit 1];
        System.assertNotEquals('', opp.Application_Supporting_Notes__c, 'value should not be blank');
    }
}