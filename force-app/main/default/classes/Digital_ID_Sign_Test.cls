@isTest
public class Digital_ID_Sign_Test {
    
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
        //op1.Lender__c = 'Transport Mutual Credit Union';
        op1.Applicant_1__c = accPerson.Id;
        op1.Applicant_2__c = acc2Person.Id;
        //op1.Contact_1__c = Ac.PersonContactId;
        //op1.Contact_2__c = accPerson.Id;    
        op1.Preferred_repayment_frequency__c = 'Monthly';  
        op1.Loan_Amount__c = 560;
        op1.StageName = 'Working';
        op1.Application_Supporting_Notes__c = 'hello';
        op1.CloseDate = System.today();
        insert op1;
        
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
        cvv.title='text';
        cvv.PathOnClient ='text.png';
        //Blob b=Blob.valueOf('Unit Test Attachment Body');
        cvv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cvv.IsMajorVersion = false;
        insert cvv;
        
        List<ContentDocument> documents1 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentVersion> conDocId1 = new List<ContentVersion>();
        
        conDocId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cvv.Id];
        System.debug('conDocId : '+conDocId1[0].ContentDocumentId);
        
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        
        cdl1.LinkedEntityId = obj.id;
        
        cdl1.ContentDocumentId = documents1[0].Id;
        
        cdl1.shareType = 'I';
        cdl1.Visibility = 'AllUsers';
        
        Insert cdl1;        
        
        
    }
    
    @isTest
    public static void TestForDigital(){
        
        opportunity op = [Select id, name, Applicant_1__r.personContactId from Opportunity where name = 'testing' Limit 1];
        contact con = [Select id, MiddleName,FirstName,LastName,ID_Card_Number__c,Driver_s_licence_state_Territory__c, name,Postal_Code__c,Salutation,Birthdate,Government_ID__c,Govt_Id_Number__c,FinServ__Gender__c from contact where LastName = 'testing123' Limit 1];
        VOI_Status__c temp = [select Id, name,VOI_Detail__c,link_Expire_code__c, contact__c from VOI_Status__c WHERE contact__r.Id =: con.id order by createddate DESC LIMIT 1];
        
        System.debug('opppp+'+op.Applicant_1__r.personContactId);
        Test.setCurrentPageReference(new PageReference('Page.Digital_ID_Sign')); 
        System.currentPageReference().getParameters().put('oppId', op.id);
        System.currentPageReference().getParameters().put('conId', con.id);
        System.currentPageReference().getParameters().put('SecureCode', '12345');
        

        test.startTest();
        Digital_ID_Sign.getContact();
        Digital_ID_Sign.getOpportunity();
        Digital_ID_Sign.getQuote();
        Digital_ID_Sign.updateopportunityStatus();
        
        
        Digital_ID_Sign abc = new Digital_ID_Sign();	
        
        
        Digital_ID_Sign.securecode();
        Digital_ID_Sign.VOIDetailID();
        VOI_Detail__c obj = [Select id, name from VOI_Detail__c where contact__c =: con.id LIMIT 1];
       
       
        Digital_ID_Sign.updateCont();
        Digital_ID_Sign.updateVOIStages();
        
        Digital_ID_Sign.UpdateOppCon(con);
        
        Digital_ID_Sign.insertPdf();
        Digital_ID_Sign.finishVOI();
        Digital_ID_Sign.erroOnVOI('test message');
       
        ContentVersion cv = [Select id,versiondata, title from ContentVersion WHERE title = 'text' LImit 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        Digital_ID_Sign.frontUpload(string.valueOf(documents[0].id), string.valueOf(obj.id), 'DlFront');
        
       
        test.stopTest();
        
        
        
    }

    
  @isTest
    public static void testmehodthree(){
        opportunity op = [Select id, name, Applicant_1__r.personContactId from Opportunity where name = 'testing' Limit 1];
        contact con = [Select id, MiddleName,FirstName,LastName,ID_Card_Number__c,Driver_s_licence_state_Territory__c, name,Postal_Code__c,Salutation,Birthdate,Government_ID__c,Govt_Id_Number__c,FinServ__Gender__c from contact where LastName = 'testing123' Limit 1];
        VOI_Status__c temp = [select Id, name,VOI_Detail__c,link_Expire_code__c, contact__c from VOI_Status__c WHERE contact__r.Id =: con.id order by createddate DESC LIMIT 1];
        ContentVersion cv = [Select id,versiondata, title from ContentVersion WHERE title = 'text' LImit 1];
        
        System.debug('opppp+'+op.Applicant_1__r.personContactId);
        Test.setCurrentPageReference(new PageReference('Page.Digital_ID_Sign')); 
        System.currentPageReference().getParameters().put('oppId', op.id);
        System.currentPageReference().getParameters().put('conId', con.id);
        System.currentPageReference().getParameters().put('SecureCode', '');
        
		test.startTest();
            
        Digital_ID_Sign abc = new Digital_ID_Sign();	
        
        Digital_ID_Sign.securecode();
        Digital_ID_Sign.VOIDetailID();
        VOI_Detail__c obj = [Select id, name from VOI_Detail__c where contact__c =: con.id LIMIT 1];
        
        PageReference pageRef = Page.Digital_ID_Sign; // Add your VF page Name here
        pageRef.getParameters().put('imageDeta', String.valueOf(cv.Id));
        pageRef.getParameters().put('imageDetaBack', String.valueOf(cv.Id));
        pageRef.getParameters().put('sign1', String.valueOf(cv.Id));
        pageRef.getParameters().put('sign2', String.valueOf(cv.Id));
        pageRef.getParameters().put('VideoId', 'qwertyyyoiureq');
        pageRef.getParameters().put('Video_SS', String.valueOf(cv.Id));
        pageRef.getParameters().put('videoData', String.valueOf(cv.Id));
        Test.setCurrentPage(pageRef);
       
        Digital_ID_Sign.FrontDlData();
        Digital_ID_Sign.BackDlData();
        
        Digital_ID_Sign.Sign1DataforClass();
        
        Digital_ID_Sign.Sign2DataforClass();
        
        Digital_ID_Sign.videoDataforClass();
        
        Digital_ID_Sign.generateLog();
        
        Digital_ID_Sign.videoSS();
        Digital_ID_Sign.SendMailtoUs();
        
        Digital_ID_Sign.sendImageDataToComponent(obj.id, 'DlFront');
        Digital_ID_Sign.FetchContact(obj.id);
        
        test.stopTest();        
    }
 	
    @isTest
    public static void testmehodFour(){
        opportunity op = [Select id, name, Applicant_1__r.personContactId from Opportunity where name = 'testing' Limit 1];
        contact con = [Select id, MiddleName,FirstName,LastName,ID_Card_Number__c,Driver_s_licence_state_Territory__c, name,Postal_Code__c,Salutation,Birthdate,Government_ID__c,Govt_Id_Number__c,FinServ__Gender__c from contact where LastName = 'testing123' Limit 1];
        VOI_Status__c temp = [select Id, name,VOI_Detail__c,link_Expire_code__c, contact__c from VOI_Status__c WHERE contact__r.Id =: con.id order by createddate DESC LIMIT 1];
        ContentVersion cv = [Select id,versiondata, title from ContentVersion WHERE title = 'text' LImit 1];
        op.Lender__c = 'Transport Mutual Credit Union';
        update op;
        System.debug('opppp+'+op.Applicant_1__r.personContactId);
        Test.setCurrentPageReference(new PageReference('Page.Digital_ID_Sign')); 
        System.currentPageReference().getParameters().put('oppId', op.id);
        System.currentPageReference().getParameters().put('conId', con.id);
        System.currentPageReference().getParameters().put('SecureCode', '');
        
        test.startTest();
        
        Digital_ID_Sign abc = new Digital_ID_Sign();	
        Digital_ID_Sign.insertPdf();
        Digital_ID_Sign.securecode();
        Digital_ID_Sign.VOIDetailID();
        VOI_Detail__c obj = [Select id, name from VOI_Detail__c where contact__c =: con.id LIMIT 1];
        
        Digital_ID_Sign.FrontDlData();
        
        test.stopTest();
    }
    
}