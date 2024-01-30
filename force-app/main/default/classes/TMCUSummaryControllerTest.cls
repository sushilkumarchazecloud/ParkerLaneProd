@isTest
public class TMCUSummaryControllerTest{
    
   
    @isTest
    public static void testTMCUApp(){
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
        
        
        Opportunity oppty = new Opportunity ();
        oppty.applicant_1__c = accPerson.Id;
        oppty.AccountId = acc.Id;
        oppty.name = 'test Oppty';
        oppty.StageName='Assessment Needed'; 
        oppty.CloseDate = Date.today();
        oppty.Application_Sections__c ='Own and Owe'; 
        oppty.Current_Application_Sections__c ='Who is applying';
        oppty.Relationship_to_Applicant_2__c = 'Spouse';
        insert oppty;
        
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
        
        Quote qt = New Quote(Name ='test quote', OpportunityId= oppty.Id, Application__c=true, Up_Front_Costs_Applicable__c = 'Yes',
                             Purpose__c= 'Solar', Customer_Amount__c = 1000, Loan_Term__c = 60, Product__c = productList[0].Id,
                             Interest_Rate__c = 5, Actual_Comparison_Rate__c = 20);
        insert qt;
        Loan_Fees__c fee1 = New Loan_Fees__c(Amount__c = 200, Product__c = productList[0].Id);
        insert fee1;
        
        
        List<FinServ__AssetsAndLiabilities__c> assetsList = new List<FinServ__AssetsAndLiabilities__c>{new FinServ__AssetsAndLiabilities__c(Name = 'Asset', Is_Address_Same__c= true)};
        List<FinServ__AssetsAndLiabilities__c> liabilitiesList = new List<FinServ__AssetsAndLiabilities__c>{new FinServ__AssetsAndLiabilities__c(Name = 'Liability')};
        ParkerLaneLoanController.upsertOppAssetsAndLiabilities(assetsList, liabilitiesList, oppty.Id, true, true);
        
        Map<String, Contact> conEmpMap = ParkerLaneLoanController.getEmploymentDetails(oppty.Id);
        ParkerLaneLoanController.upsertEmploymentDetails(conEmpMap.get('applicant1'), conEmpMap.get('applicant2'), new List<FinServ__Employment__c>{new FinServ__Employment__c(Name = 'emp1')}, new List<FinServ__Employment__c>{new FinServ__Employment__c(Name = 'emp1')}, oppty.Id, true, true);
        
        ParkerLaneLoanController.ContactWithOpp conWrap = ParkerLaneLoanController.getLivingExpensesDetails(oppty.Id);
        ParkerLaneLoanController.upsertLivingExpensesDetails(conWrap.con, oppty.Id, true, true);
        
        Profile SysAdProfileId = [SELECT id FROM Profile 
                             WHERE name = 'System Administrator'];

        User newUser = new User
             (username='theparkerlane@test.com', 
             lastName='myLastName', profileId=SysAdProfileId.id, 
             email='theparkerlane@au.com', alias='testUser', 
             timeZoneSidKey='America/Denver',
             localeSidKey='en_CA', emailEncodingKey='UTF-8', 
             languageLocaleKey='en_US');
        insert newUser;

        
        InteflowUsers__c newUserVal = new InteflowUsers__c();
        newUserVal.setupOwnerId = newUser.id;
        newUserVal.Username__c = 'cwhite';
        newUserVal.Password__c = 'test19';
        insert newUserVal;
        
        System.runAs(newUser){
            ApexPages.CurrentPage().getParameters().put('id',oppty.Id);
            TMCUSummaryController obj = new TMCUSummaryController();
        }
        
        
    }
    
    @isTest
    public static void testCFCU(){
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
        insert oppty;
        
        List<Product2> productList = new List<Product2>();
        productList.add(New Product2(IsActive =true, Default_Product__c = true,
                                     Product_Type__c = 'Green Loan', Product_Order__c = 1,
                                     Name = 'product(1-5)', Features__c='Feature1;Feature2',
                                     Acceptable_Loan_Purpose__c = 'Solar',
                                     Maximum_Loan_Term_Years__c =1,
                                    Is_Feature_Product__c=TRUE));
        productList.add(New Product2(IsActive =true, Default_Product__c = true,
                                     Product_Type__c = 'Green Loan', Product_Order__c = 2,
                                     Name = 'product2(1-5)', Features__c='Feature1;Feature2',
                                     Acceptable_Loan_Purpose__c = 'Solar',
                                     Maximum_Loan_Term_Years__c =5));
        productList.add(New Product2(IsActive =true, Default_Product__c = true,
                                     Product_Type__c = 'Green Loan', Product_Order__c = 3,
                                     Name = 'product3(6-10)', Features__c='Feature1;Feature2',
                                     Acceptable_Loan_Purpose__c = 'Solar',
                                     Maximum_Loan_Term_Years__c =3));
        insert productList;
        
        Quote qt = New Quote(Name ='test quote', OpportunityId= oppty.Id, Application__c=true, Up_Front_Costs_Applicable__c = 'Yes',
                             Purpose__c= 'Solar', Customer_Amount__c = 1000, Loan_Term__c = 60, Product__c = productList[0].Id,
                             Interest_Rate__c = 5, Actual_Comparison_Rate__c = 20);
        insert qt;
        Loan_Fees__c fee1 = New Loan_Fees__c(Amount__c = 200, Product__c = productList[0].Id);
        insert fee1;
        
        
        List<FinServ__AssetsAndLiabilities__c> assetsList = new List<FinServ__AssetsAndLiabilities__c>{new FinServ__AssetsAndLiabilities__c(Name = 'Asset', Is_Address_Same__c= true)};
        List<FinServ__AssetsAndLiabilities__c> liabilitiesList = new List<FinServ__AssetsAndLiabilities__c>{new FinServ__AssetsAndLiabilities__c(Name = 'Liability')};
        ParkerLaneLoanController.upsertOppAssetsAndLiabilities(assetsList, liabilitiesList, oppty.Id, true, true);
        
        Map<String, Contact> conEmpMap = ParkerLaneLoanController.getEmploymentDetails(oppty.Id);
        ParkerLaneLoanController.upsertEmploymentDetails(conEmpMap.get('applicant1'), conEmpMap.get('applicant2'), new List<FinServ__Employment__c>{new FinServ__Employment__c(Name = 'emp1')}, new List<FinServ__Employment__c>{new FinServ__Employment__c(Name = 'emp1')}, oppty.Id, true, true);
        
        ParkerLaneLoanController.ContactWithOpp conWrap = ParkerLaneLoanController.getLivingExpensesDetails(oppty.Id);
        ParkerLaneLoanController.upsertLivingExpensesDetails(conWrap.con, oppty.Id, true, true);
        
        Profile SysAdProfileId = [SELECT id FROM Profile 
                             WHERE name = 'System Administrator'];

        User newUser = new User
             (username='theparkerlane@test.com', 
             lastName='myLastName', profileId=SysAdProfileId.id, 
             email='theparkerlane@au.com', alias='testUser', 
             timeZoneSidKey='America/Denver',
             localeSidKey='en_CA', emailEncodingKey='UTF-8', 
             languageLocaleKey='en_US');
        insert newUser;

        
        InteflowUsers__c newUserVal = new InteflowUsers__c();
        newUserVal.setupOwnerId = newUser.id;
        newUserVal.Username__c = 'cwhite';
        newUserVal.Password__c = 'test19';
        insert newUserVal;
        
        System.runAs(newUser){
            ApexPages.CurrentPage().getParameters().put('id',oppty.Id);
            TMCUSummaryController obj = new TMCUSummaryController();
        }
        
        
    }
    
}