@isTest
public class openSolarControllerTest {
	
    @testsetup
    static void setdata(){
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Referrer_Business').getRecordTypeId();
        id conRefId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referrer').getRecordTypeId();                                         
        Account acc = New Account();
        acc.Name = 'test Name';
        acc.Custom_Loan_Options_Landing_Page__c = true;
        acc.Custom_Loan_Options_Page_Type__c = 'Co-branded standard solar page';
        acc.Open_Solar_Supplier_ID__c = 'suppId234';
        acc.Phone = '0400000000';                
        acc.Supplier_Logo_URL_For_Site__c = 'www.google.com';                        
        acc.RecordTypeId = accRTId;
        acc.Logo_Image_source__c = 'Open Solar';
        insert acc; 
        
        List<contact> conList = new List<contact>();
        Contact con = New Contact();
        con.FirstName = 'test';                            
        con.LastName = 'Opp';                                 
        con.Email = 'test@gamil.com';                                         
        con.AccountId = acc.id;
        con.RecordTypeId = conRefId; 
        conList.add(con);   
        
        Contact con1 = New Contact();
        con1.FirstName = 'test';                            
        con1.LastName = 'Opp';                                 
        con1.Email = 'test@gamil.com';                                         
        con1.AccountId = acc.id;
        con1.RecordTypeId = conRefId; 
        conList.add(con1); 
        
        insert conList;
        
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String recordHTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Household').getRecordTypeId();
        List<Account> accList= new List<Account>();
        Account acct= new Account(
            RecordTypeID=recordHTypeId ,
            Name='Test Name'
        );
        accList.add(acct);
        
        Account accPerson= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test Person',
            LastName='Test LName',
            PersonEmail='test@yahoo.com',
            PersonBirthdate = system.today(),
            Is_Sync_with_Household__c=false,
            Does_your_spouse_earn_an_income__pc = 'Yes',
            spouse_s_approximate_annual_income__pc = 2000,
            FinServ__MaritalStatus__pc = 'Married / Defacto (to applicant 2)',
            Year__pc = '1',            
            Months__pc = '1',
            Year_1__pc = '1',
            Months_1__pc = '1',
            FinServ__NumberOfChildren__pc = 3
        );
        
        Account acc2Person= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test Person',
            LastName='Test LName',
            PersonEmail='test@yahoo.com',
            PersonBirthdate = system.today(),
            FinServ__NumberOfChildren__pc = 3
        );
        
        accList.add(accPerson);
        accList.add(acc2Person);
        insert accList;
        
        Account accChild1= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test Child',
            LastName='Test LName',
            PersonEmail='test@yahoo.com',
            Is_Sync_with_Household__c=false,
            Child_Age__pc = '1 Year',
            Relationship_with_Applicant_1__c='Dependent',
            Dependent_Parent__c = accPerson.Id
        );
        
        insert accChild1;
        
        Account Ac = [Select Id,PersonContactId from Account Where Id =: accPerson.Id];
        
        System.debug('acid'+Ac.PersonContactId);
        opportunity op1 = new Opportunity()	;
        op1.Name = 'testing';
        op1.AccountId = acc.Id;
        op1.Applicant_1__c = accPerson.Id;
        op1.Applicant_2__c = acc2Person.Id;
        //op1.Contact_1__c = Ac.PersonContactId;
        //op1.Contact_2__c = accPerson.Id;    
        op1.Preferred_repayment_frequency__c = 'Monthly';  
        op1.Loan_Amount__c = 560;
        op1.StageName = 'Working';
       // op1.Lender__c = 'Transport Mutual Credit Union';
        op1.Application_Supporting_Notes__c = 'hello';
        op1.CloseDate = System.today();
        op1.Purpose__c = 'Solar';
        OpportunityTriggerHandler.isByPassTrigger = true;
        insert op1;
        OpportunityTriggerHandler.isByPassTrigger = false;
        
        List<Product2> productList = new List<Product2>();
        productList.add(New Product2(IsActive =true, Default_Product__c = true,
                                     Product_Type__c = 'Green Loan', Product_Order__c = 1,
                                     Name = 'product', Features__c='Feature1;Feature2',
                                     Acceptable_Loan_Purpose__c = 'Solar',
                                     Maximum_Loan_Term_Years__c =1,Maximum_Loan_Amount__c=130000,
                                     Minimum_Loan_Amount__c = 1000,
                                     Is_Feature_Product__c=TRUE));
        productList.add(New Product2(IsActive =true, Default_Product__c = true,
                                     Product_Type__c = 'Green Loan', Product_Order__c = 2,
                                     Name = 'product2', Features__c='Feature1;Feature2',
                                     Acceptable_Loan_Purpose__c = 'Solar',Maximum_Loan_Amount__c=130000,
                                     Minimum_Loan_Amount__c = 1000,
                                     Maximum_Loan_Term_Years__c =5));
        productList.add(New Product2(IsActive =true, Default_Product__c = true,
                                     Product_Type__c = 'Green Loan', Product_Order__c = 3,
                                     Name = 'product3', Features__c='Feature1;Feature2',
                                     Acceptable_Loan_Purpose__c = 'Solar',Maximum_Loan_Amount__c=130000,
                                     Minimum_Loan_Amount__c = 1000,
                                     Maximum_Loan_Term_Years__c =3));
        insert productList;
        list<quote> qtlist = new list<quote>();
        qtlist.add(New Quote(Name ='test quote', OpportunityId= op1.Id, Application__c=true, Up_Front_Costs_Applicable__c = 'Yes',
                             Purpose__c= 'Solar',Gruop_Name__c='One',Quote_Group_Label__c='One', Customer_Amount__c = 35000, Loan_Term__c = 60, Product__c = productList[0].Id,
                             Interest_Rate__c = 3.99, Actual_Comparison_Rate__c = 4.99));
        qtlist.add(New Quote(Name ='test quote2', OpportunityId= op1.Id, Application__c=true, Up_Front_Costs_Applicable__c = 'Yes',
                             Purpose__c= 'Solar',Gruop_Name__c='Referral-1',Quote_Group_Label__c='Referral-1', Customer_Amount__c = 60000, Loan_Term__c = 80, Product__c = productList[1].Id,
                             Interest_Rate__c = 7.99, Actual_Comparison_Rate__c = 8.99));
        qtlist.add(New Quote(Name ='test quote3', OpportunityId= op1.Id, Application__c=true, Up_Front_Costs_Applicable__c = 'Yes',
                             Purpose__c= 'Solar',Gruop_Name__c='Referral-1',Quote_Group_Label__c='Referral-1', Customer_Amount__c = 60000, Loan_Term__c = 80, Product__c = productList[1].Id,
                             Interest_Rate__c = 5.99, Actual_Comparison_Rate__c = 6.99));
        insert qtlist;
        Loan_Fees__c fee1 = New Loan_Fees__c(Amount__c = 200, Product__c = productList[0].Id);
        insert fee1; 
    }
    
    
    @isTest
    public static void atttampOne(){
       	opportunity opp = [select id, name from opportunity where name = 'testing'];
        List<contact> conList = [Select id, name, email, Account.name from contact where email = 'test@gamil.com'];
        Test.setCurrentPageReference(new PageReference('Page.openSolarPage')); 
        System.currentPageReference().getParameters().put('uniqueFileID', 'TestOpen123');
        System.currentPageReference().getParameters().put('cAmount', '10000');
        System.currentPageReference().getParameters().put('loanTerm', '8');
        System.currentPageReference().getParameters().put('lendingPurpose', '');
        System.currentPageReference().getParameters().put('cFName', 'Test');
        System.currentPageReference().getParameters().put('cLName', 'opp First');
        System.currentPageReference().getParameters().put('cEmail', 'testoppemail@gmail.com');
        System.currentPageReference().getParameters().put('streetNum', '834');
        System.currentPageReference().getParameters().put('suppId', 'suppId234');
        System.currentPageReference().getParameters().put('sCompName', 'chaze');
        System.currentPageReference().getParameters().put('sLogoURL', 'www.google.com');
        System.currentPageReference().getParameters().put('scompEmail', 'suppcomp@gmail.com');
        System.currentPageReference().getParameters().put('sFirstName', 'supp Name');
        System.currentPageReference().getParameters().put('sLastName', 'supp Last Name');
        System.currentPageReference().getParameters().put('sEmail', 'testoppppo@gmail.com');
        System.currentPageReference().getParameters().put('systemTyp', 'test');
        System.currentPageReference().getParameters().put('batteryCapacity', '200');
        System.currentPageReference().getParameters().put('systemCapacity', '1200');
        System.currentPageReference().getParameters().put('refferedBy', 'Open Solar');		         
        
        test.startTest();
        openSolarController.insertData();
        openSolarController.updateQuotes(120000.0, opp.Id, true);
        test.stopTest();
        
        openSolarController.sendDuplicateEmail(conList, 'Test supp', 'tazeem.khan@chazecloud.com');
        
    }
    
    @isTest 
    public static void attampTwo(){
        List<contact> conList = [Select id, name, email, Account.name from contact where email = 'test@gamil.com'];
        opportunity opp = [select id, name from opportunity where name = 'testing'];
        Test.setCurrentPageReference(new PageReference('Page.openSolarPage')); 
        System.currentPageReference().getParameters().put('uniqueFileID', 'TestOpen123');
        System.currentPageReference().getParameters().put('cAmount', '10000');
        System.currentPageReference().getParameters().put('loanTerm', '8');
        System.currentPageReference().getParameters().put('lendingPurpose', '');
        System.currentPageReference().getParameters().put('cFName', 'Test');
        System.currentPageReference().getParameters().put('cLName', 'opp First');
        System.currentPageReference().getParameters().put('cEmail', 'testoppemail@gmail.com');
        System.currentPageReference().getParameters().put('streetNum', '834');
        System.currentPageReference().getParameters().put('suppId', 'suppId234cvfadszf');
        System.currentPageReference().getParameters().put('sCompName', 'chaze');
        System.currentPageReference().getParameters().put('sLogoURL', 'www.google.com');
        System.currentPageReference().getParameters().put('scompEmail', 'suppcomp@gmail.com');
        System.currentPageReference().getParameters().put('sFirstName', 'supp Name');
        System.currentPageReference().getParameters().put('sLastName', 'supp Last Name');
        System.currentPageReference().getParameters().put('sEmail', 'testoppppo@gmail.com');
        System.currentPageReference().getParameters().put('systemTyp', 'test');
        System.currentPageReference().getParameters().put('batteryCapacity', '200');
        System.currentPageReference().getParameters().put('systemCapacity', '1200');
        System.currentPageReference().getParameters().put('refferedBy', 'Open Solar');		         
        
        test.startTest();
        openSolarController.insertData();
        openSolarController.updateQuotes(120000.0, opp.Id, true);
        test.stopTest();
    }
    
}