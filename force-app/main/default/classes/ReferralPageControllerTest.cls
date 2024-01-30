@istest
public class ReferralPageControllerTest {
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
        insert oppty;
        
        Contact con = new Contact();
        con.LastName = 'test';
        insert con;
        
        List<Product2> productList = new List<Product2>();
        productList.add(New Product2(IsActive =true, Product_Order__c = 1,
                                     Name = 'product', Features__c='Feature1;Feature2',
                                     Acceptable_Loan_Purpose__c = 'Solar',Maximum_Loan_Amount__c = 80000,
                                     Maximum_Loan_Term_Years__c =1,Minimum_Loan_Amount__c = 1000));
        productList.add(New Product2(IsActive =true, Product_Order__c = 2,
                                     Name = 'product2', Features__c='Feature1;Feature2',
                                     Acceptable_Loan_Purpose__c = 'Solar',Maximum_Loan_Amount__c = 80000,
                                     Maximum_Loan_Term_Years__c =5, Minimum_Loan_Amount__c = 1000));
        productList.add(New Product2(IsActive =true, Product_Order__c = 3,
                                     Name = 'product3', Features__c='Feature1;Feature2',
                                     Acceptable_Loan_Purpose__c = 'Solar',Maximum_Loan_Amount__c = 80000,
                                     Maximum_Loan_Term_Years__c =3, Minimum_Loan_Amount__c = 1000));
        
        insert productList;
        Quote qt = New Quote(Name ='test quote', OpportunityId= oppty.Id, Application__c=true, Up_Front_Costs_Applicable__c = 'Yes',
                             Purpose__c= 'Solar', Customer_Amount__c = 1000, Loan_Term__c = 60, Product__c = productList[0].Id,
                             Interest_Rate__c = 5, Actual_Comparison_Rate__c = 20, Is_Featured__c = true);
        insert qt;
        Loan_Fees__c fee1 = New Loan_Fees__c(Amount__c = 200, Product__c = productList[0].Id);
        insert fee1;
    }
    
    static testmethod void testvalidatePhone(){
        //ReferralPageController.validatePhone('test');
        map<String,String> mmap = new map<String,String>();
        
        try{
            ReferralPageController.generateAndSendPDF(mmap);            
        }
        catch(exception e){
            system.debug('test');
        }        
    }
    
    static testmethod void testif(){
        ReferralPageController amt = New ReferralPageController();
        //amt.quoteDetailWrpList[0].Amount = 10;
        //ReferralPageController.submitReferral();
    }
    
    static testmethod void submitReferralForNotEligibleTest(){        
        Id accRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referrer (Business)').getRecordTypeId();
        Account acc = new Account(Name='test acc', On_Board_Referral__c = true, RecordTypeId = accRT);
        insert acc;
        Contact con = New Contact(Email = 'test@test.com', LastName ='test', AccountId = acc.Id);
        insert con;
        contact conId = [Select id,LastName,email from contact where Email = 'test@test.com' LIMIT 1];
        String cont = conId.id; 
        ReferralPageController.QuoteDetailWrapper rpc = New ReferralPageController.QuoteDetailWrapper();
        rpc.Amount = 500;
        rpc.masterQuote = 'aa';
        rpc.errorMessage = 'err';
        rpc.checkError = true;
            /*rpc.minAmt = 90;
            rpc.maxAmt = 900;*/
            rpc.NmList = new list<String>();
            rpc.cdlId = new list<id>();
            rpc.pdfData = new map<String,String>();
        String wrp = '[{"cdlId":[],"NmList":[],"Amount":"2000","masterQuote":"one"}]';
        /*rpc.quoteType = 'Solar';
        rpc.quoteAmount = 10;
        rpc.lastName = 'test';
        rpc.FirstName = 'check';
        rpc.customerEmail = 'test@test.com';
        rpc.customerPhone = '1234567890';
        rpc.refEmail = 'test@test.com';
        rpc.customerInstallationAddress = '';
        rpc.sendQuote = 'Me and my customer';
        rpc.support = 'The customer will contact you';
        rpc.isObtainedTheCustomer = true;
        rpc.isReferralAgreement = true;
        rpc.rowIndex = 1;*/
        ReferralPageController.submitReferral('test@test.com','test','check','test@test.com','1234567890','abc','Solar','Me only',cont,true,wrp,'a','b','c','d','e','f','g');
        ReferralPageController.ret(new list<ReferralPageController.QuoteDetailWrapper>{rpc});
        ReferralPageController.ret1();
		ReferralPageController.getEmail('test@test.com');
        /*List<SelectOption> qtOpt = rpc.getQuoteTypeOptions();
        List<SelectOption> sqOpt = rpc.getSendQuoteOptions();*/
        //List<SelectOption> sOpt = rpc.getSupportOptions();
        //System.assertEquals(rpc.status, 'error' , 'value should be contains Error');
    } 
    
    static testmethod void submitReferralForEligibleTest(){
        Id accRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referrer (Business)').getRecordTypeId();
        Account acc = new Account(Name='test acc', On_Board_Referral__c = true, RecordTypeId = accRT);
        insert acc;
        Contact con = New Contact(Email = 'test@test.com', LastName ='test', AccountId = acc.Id);
        insert con;
        contact conId = [Select id,LastName,email from contact where Email = 'test@test.com' LIMIT 1];
        String cont = conId.id;
        ReferralPageController.QuoteDetailWrapper rpc = New ReferralPageController.QuoteDetailWrapper();
        rpc.Amount = 500;
        rpc.masterQuote = 'aa';
        rpc.errorMessage = 'err';
        rpc.checkError = true;
            /*rpc.minAmt = 90;
            rpc.maxAmt = 900;*/
            rpc.NmList = new list<String>();
            rpc.cdlId = new list<id>();
            rpc.pdfData = new map<String,String>();
        String wrp = '[{"cdlId":[],"NmList":[],"Amount":"2000","masterQuote":"one"}]';
        /*rpc.quoteType = 'Solar';
        rpc.quoteAmount = 10;
        rpc.customerName = 'test';
        rpc.customerFName = 'check';
        rpc.customerEmail = 'test@test.com';
        rpc.customerPhone = '1234567890';
        rpc.referrerEmail = 'test@test.com';
        rpc.customerInstallationAddress = '';
        rpc.sendQuote = 'Me and my customer';
        rpc.support = 'The customer will contact you';
        rpc.isObtainedTheCustomer = true;
        rpc.isReferralAgreement = true;
        rpc.rowIndex = 1;*/
        ReferralPageController.submitReferral('test@test.com','test','check','test@test.com','1234567890','abc','Solar','Me only',cont,true,wrp,'a','b','c','d','e','f','g');
        ReferralPageController.ret(new list<ReferralPageController.QuoteDetailWrapper>{rpc});
        ReferralPageController.ret1();
        ReferralPageController.getEmail('test@test.com');
        //System.assertEquals(rpc.status, 'success' , 'value should be contains Error');
    }    
}