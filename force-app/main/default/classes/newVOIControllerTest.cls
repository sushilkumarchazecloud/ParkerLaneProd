@isTest
public class newVOIControllerTest {
    @testsetup
    static void setdata(){
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
        OpportunityTriggerHandler.isByPassTrigger = true;
        insert op1;
        OpportunityTriggerHandler.isByPassTrigger = false;
        
        contact con = new contact();
        con.firstname = 'qwert';
        con.lastName = 'tesqweting';
        con.VOI_type__c = 'VOI';
        insert con;
        
        opportunity op = [select Id, name, Applicant_1__c, Applicant_1__r.personContactId, Applicant_2__c, Applicant_2__r.personContactId from opportunity where id =: op1.Id limit 1];
        
        FinServ__Employment__c emp = new FinServ__Employment__c();
        emp.Name = 'asdf';
        emp.Is_Primary__c = true;
        emp.FinServ__Contact__c = op.Applicant_1__r.personContactId;
        insert emp;
        
        FinServ__Employment__c emp1 = new FinServ__Employment__c();
        emp1.Name = 'asdf';
        emp1.Is_Primary__c = true;
        emp1.FinServ__Contact__c = op.Applicant_2__r.personContactId;
        insert emp1;
        
        
        Quote temp = new Quote();
        temp.Name = 'testing';
        temp.Monthly_Account_Keeping_Fees__c = 1234;
        temp.OpportunityId = op1.id;
        temp.Application__c = true;
        temp.Loan_Term__c = 84;
        insert temp;
        
        FinServ__FinancialGoal__c fg = new FinServ__FinancialGoal__c();
        fg.Which_financial_priorities_relevant_you__c = 'Consolidate debt';
        fg.FinServ__PrimaryOwner__c = op1.Applicant_1__c;
        
        insert fg;
        
        VOI_Detail__c obj  = new VOI_Detail__c();
        obj.Secure_Code_Orignal__c = '1234';
        obj.Contact__c = con.Id;
        insert obj;
        
        contact cont = new contact();
        cont.LastName = 'testing123';
        cont.Birthdate = system.today();
        cont.Government_ID__c = 'card';
        cont.Phone = '0400000000';
        cont.Email = 'tsykaj@gamil.com';
        cont.Govt_Id_Number__c = '32417239';
        cont.FinServ__Gender__c = 'male';
        cont.FirstName = 'qwse'; 
        cont.ID_Card_Number__c = 'qwer';
        cont.Residential_Address__c = 'testing';
        insert cont;
        
        VOI_Status__c voiS = new VOI_Status__c();
        voiS.link_Expire_code__c = '12345';
        voiS.Contact__c = cont.Id;
        insert voiS;
        ContentVersion cvv=new Contentversion();
        try{
            
            cvv.title='text';
            cvv.PathOnClient ='text.txt';
            Blob blo =Blob.valueOf('Unit Test Attachment Body');
            cvv.versiondata = blo;//EncodingUtil.base64Decode('Unit Test Attachment Body');
            insert cvv;
        }catch(Exception ex){
            system.debug('--++'+ex.getCause() + '--' + ex.getMessage() + '=--' + ex.getTypeName());
        }
        List<ContentDocument> documents1 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentVersion> conDocId1 = new List<ContentVersion>();
        
        conDocId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cvv.Id];
        
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        
        cdl1.LinkedEntityId = obj.id;
        
        cdl1.ContentDocumentId = documents1[0].Id;
        
        cdl1.shareType = 'I';
        cdl1.Visibility = 'AllUsers';
        
        Insert cdl1;                      
    }
    
    @isTest
    public static void testAttOne(){
        OpportunityTriggerHandler.isByPassTrigger = true;
        opportunity op = [Select id, name, Applicant_1__r.personContactId from Opportunity where name = 'testing' Limit 1];
        contact con = [Select id, MiddleName,FirstName,LastName,ID_Card_Number__c,Driver_s_licence_state_Territory__c, name,Postal_Code__c,Salutation,Birthdate,Government_ID__c,Govt_Id_Number__c,FinServ__Gender__c from contact where LastName = 'testing123' Limit 1];
        VOI_Status__c temp = [select Id, name,VOI_Detail__c,link_Expire_code__c, contact__c from VOI_Status__c WHERE contact__r.Id =: con.id order by createddate DESC LIMIT 1];
        
        test.startTest();
        string SecureCodeOriginal = string.valueOf(Math.round((Math.random() * (9000) + 1000)));
        VOI_Detail__c voi  = new VOI_Detail__c();
        voi.Secure_Code_Orignal__c = SecureCodeOriginal;
        voi.Contact__c = con.id;
        voi.opportunity__c = op.Id;
        insert voi;
        temp.VOI_Detail__c = voi.id;
        update temp;
        
        System.debug('opppp+'+op.Applicant_1__r.personContactId);
        Test.setCurrentPageReference(new PageReference('Page.DigitalSigning')); 
        System.currentPageReference().getParameters().put('oppId', op.id);
        System.currentPageReference().getParameters().put('conId', con.id);
        System.currentPageReference().getParameters().put('SecureCode', '12345');
        newVOIController obj = new newVOIController();
        
        opportunity opprt = newVOIController.getOpportunityData(op.id);
        VOI_Status__c VST = newVOIController.getVOI(con.Id);
        newVOIController.getContactData(con.Id);
        newVOIController.getVOIDetail(VST);
        newVOIController.getQUoteData(op.id);
        newVOIController.Employementdata(opprt.Applicant_1__r.personContactId);
        newVOIController.updateForEmailVerify(con.Id);
        newVOIController.updateVOIst(VST);
        newVOIController.sendCustomEmail('testop@gmail.com',con.Id);
        newVOIController.sendAnotherDevByLwc('email', con.Id);
        newVOIController.insertPDFAndSendEmail(con.Id, op.id);
        newVOIController.forDocsAndAlldone(op.id, op.Applicant_1__r.personContactId);
        newVOIController.updateContFromLWC(con.Id,op.id, 'both to sign',  'Australia', '92029', 'test', '29109', '92188 9128');
        
        newVOIController.emailForOtp(con.Id);
        test.stopTest();
        
        OpportunityTriggerHandler.isByPassTrigger = false;
    }
    
    @isTest
    public static void testAttTwo(){
        OpportunityTriggerHandler.isByPassTrigger = true;
        opportunity op = [Select id, name, Applicant_1__r.personContactId from Opportunity where name = 'testing' Limit 1];
        contact con = [Select id,Email, MiddleName,FirstName,LastName,ID_Card_Number__c,Driver_s_licence_state_Territory__c, name,Postal_Code__c,Salutation,Birthdate,Government_ID__c,Govt_Id_Number__c,FinServ__Gender__c from contact where LastName = 'testing123' Limit 1];
        VOI_Status__c temp = [select Id, name,VOI_Detail__c,link_Expire_code__c, contact__c from VOI_Status__c WHERE contact__r.Id =: con.id order by createddate DESC LIMIT 1];
        string SecureCodeOriginal = string.valueOf(Math.round((Math.random() * (9000) + 1000)));
        VOI_Detail__c voi  = new VOI_Detail__c();
        voi.Secure_Code_Orignal__c = SecureCodeOriginal;
        voi.Contact__c = con.id;
        voi.opportunity__c = op.Id;
        insert voi;
        
        test.startTest();
        con.Email = 't@gamil.com';
        update con;
        PageReference pageRef = Page.DigitalSigning;
        pageRef.getParameters().put('Video_SS', 'test,testtesttesttesttest');
        pageRef.getParameters().put('conId', con.Id);
		pageRef.getParameters().put('videoData', 'test,testtesttesttesttest');
        pageRef.getParameters().put('type', 'email');
         pageRef.getParameters().put('conId', con.Id);
        pageRef.getParameters().put('sign1', 'test,testtesttesttesttest');
        pageRef.getParameters().put('name', 'sign1');
        pageRef.getParameters().put('section', 'TMCU');
        pageRef.getParameters().put('conId', con.Id);
        pageRef.getParameters().put('oppId', op.Id);
        Test.setCurrentPage(pageRef);
        newVOIController.videoSS();
        newVOIController.videoDataforClass();
        newVOIController.sendAnotherDevice();
        newVOIController.updateVOIfromesign();
        newVOIController.Sign1DataforClass();
        newVOIController.updateOppSection();
        newVOIController.insertPDFAndSendEmailFromVFCmp();
        test.stopTest();
        
        OpportunityTriggerHandler.isByPassTrigger = false;
        
    }
    
    @isTest
    public static void testAttThree(){
        OpportunityTriggerHandler.isByPassTrigger = true;
        opportunity op = [Select id, Lender__c,name, Applicant_1__r.personContactId from Opportunity where name = 'testing' Limit 1];
        contact con = [Select id, MiddleName,FirstName,LastName,ID_Card_Number__c,Driver_s_licence_state_Territory__c, name,Postal_Code__c,Salutation,Birthdate,Government_ID__c,Govt_Id_Number__c,FinServ__Gender__c from contact where LastName = 'testing123' Limit 1];
        VOI_Status__c temp = [select Id, name,VOI_Detail__c,link_Expire_code__c, contact__c from VOI_Status__c WHERE contact__r.Id =: con.id order by createddate DESC LIMIT 1];
		List<ContentDocument> documents1 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        op.Lender__c = 'Transport Mutual Credit Union';
        OpportunityTriggerHandler.isByPassTrigger = true;
        update op;
        OpportunityTriggerHandler.isByPassTrigger = false;
        
        VOI_Detail__c voi  = new VOI_Detail__c();
        voi.Contact__c = con.id;
        voi.opportunity__c = op.Id;
        insert voi;
        
        test.startTest();
        con.Email = 'te@gamil.com';
        update con;
        newVOIController.insertPDFAndSendEmail(con.Id, op.id);
        newVOIController.sendAnotherDevByLwc('SMS',con.Id);
        newVOIController.dataWrapmethod(op.id, con.Id);
        newVOIController.removeContent(documents1[0].Id);
        PageReference pageRef = Page.DigitalSigning;
        pageRef.getParameters().put('type', 'SMS');
        pageRef.getParameters().put('conId', con.Id);
        pageRef.getParameters().put('oppId', op.Id);
        Test.setCurrentPage(pageRef);
        
        newVOIController.sendAnotherDevice();
        
        newVOIController.getQUoteData(con.Id);
        newVOIController.updateForEmailVerify(op.Id);
		newVOIController.sendAnotherDevByLwc('email',op.Id);
        newVOIController.forDocsAndAlldone(con.Id, op.Id);
        test.stopTest();
        
        OpportunityTriggerHandler.isByPassTrigger = false;
    }      
}