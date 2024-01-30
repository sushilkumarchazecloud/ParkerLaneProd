@isTest
public class Generate_PDF_VOI_COntroller_Test {
    
    @isTest
    public static void PdfTestMethodFirst(){
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String recordHTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Household').getRecordTypeId();
        List<Account> accList= new List<Account>();
        Account acc= new Account(
            RecordTypeID=recordHTypeId ,
            Name='Test Name'
        );
        accList.add(acc);
        
        System.debug('acc id +++'+acc.Id);
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
        op1.Preferred_repayment_frequency__c = 'Monthly';  
        op1.Loan_Amount__c = 560;
        op1.StageName = 'Working';
        op1.Application_Supporting_Notes__c = 'hello';
        op1.CloseDate = System.today();
        insert op1;
        
        System.debug('90--'+op1.Applicant_1__r.id);
        System.debug('qwerty--'+op1.Applicant_1__r.personContactId);
        
        Opportunity oppUpdate = [SELECT Applicant_1__c, Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                                 FROM Opportunity WHERE Id = : op1.id limit 1];
        
        System.debug('---oppUpdate.Applicant_2__r.PersonContactId--'+ oppUpdate.Applicant_2__r.PersonContactId);
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
       	
        contact con = new contact();
        con.firstname = 'qwert';
        con.lastName = 'testing';
        insert con;
        
        VOI_Detail__c obj  = new VOI_Detail__c();
        obj.Secure_Code_Orignal__c = '1234';
        obj.Contact__c = con.Id;
        insert obj;
        
        Quote temp = new Quote();
        temp.Name = 'testing';
        temp.Monthly_Account_Keeping_Fees__c = 1234;
        temp.OpportunityId = op1.id;
        temp.Application__c = true;
        temp.Loan_Term__c = 60;
        insert temp;
        
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
        
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='Sign1', 
            PathOnClient ='Sign1.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                           FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = obj.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
        
        Test.setCurrentPageReference(new PageReference('Page.Generate_PDF_FOR_Application_Doc')); 
        System.currentPageReference().getParameters().put('oppId', op1.id);
        System.currentPageReference().getParameters().put('conId', con.id);
		
        
		Genrate_PDF_For_VOI_Controller.getOpportunity();
        Genrate_PDF_For_VOI_Controller.generateImageURL();
        Genrate_PDF_For_VOI_Controller.getQuote();
        Genrate_PDF_For_VOI_Controller.getcontact();
        Genrate_PDF_For_VOI_Controller.Employementdata(oppUpdate.Applicant_1__r.PersonContactId);
        Genrate_PDF_For_VOI_Controller.getfinancialGoal();
    }
}