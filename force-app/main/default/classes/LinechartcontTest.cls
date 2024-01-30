@isTest
public class LinechartcontTest {
    
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
            Relationship_with_Applicant_1__c='Client',
            PersonTitle = 'Mr.',
            Phone = '0400000000',
            Security_Question__pc = 'Mothers maiden name',
            Security_Answer__pc = 'qwerty',
            Rental_Amount__pc = 500,
            Rental_or_Board_paid__pc =  50,
            Education_ChildCare_SchoolFees_Uniform__pc = 12,
            Maintenance_If_pay_child_maintenance__pc =  25,
            Other_loans_and_or_debt_commitments__pc = 24,
            Education_public_and_private__pc  = 10,
            Food_Groceries_Meat_Fruit_Vegetabl__pc = 100,
            Living_Situation__pc = 'Renting',
            Citizenship_Status__pc = 'Australian Citizen',
            FinServ__Gender__pc = 'Male',
            Transport_Public_Petrol_Registration__pc = 100,
            Medical_Private_Health_Insurance_Ong__pc = 100,
            Personal_Insurances_life_and_income_pro__pc = 100,
            Insurances_Home_Personal_Voluntary__pc = 100,
            Utilities__pc = 100,
            Driver_s_licence_state_Territory__pc = 'Queensland',
            Connections_Phone_Mobile_Internet_C__pc = 200,
            FinServ__NumberOfChildren__pc = 3
        );
        
        Account acc2Person= new Account(
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
            Relationship_with_Applicant_1__c='Client',
            PersonTitle = 'Mr.',
            Phone = '0400000000',
            Security_Question__pc = 'Mothers maiden name',
            Security_Answer__pc = 'qwerty',
            Rental_Amount__pc = 500,
            Rental_or_Board_paid__pc =  50,
            Education_ChildCare_SchoolFees_Uniform__pc = 12,
            Maintenance_If_pay_child_maintenance__pc =  25,
            Other_loans_and_or_debt_commitments__pc = 24,
            Education_public_and_private__pc  = 10,
            Food_Groceries_Meat_Fruit_Vegetabl__pc = 100,
            Living_Situation__pc = 'Renting',
            Citizenship_Status__pc = 'Australian Citizen',
            FinServ__Gender__pc = 'Male',
            Transport_Public_Petrol_Registration__pc = 100,
            Medical_Private_Health_Insurance_Ong__pc = 100,
            Personal_Insurances_life_and_income_pro__pc = 100,
            Insurances_Home_Personal_Voluntary__pc = 100,
            Utilities__pc = 100,
            Driver_s_licence_state_Territory__pc = 'Queensland',
            Connections_Phone_Mobile_Internet_C__pc = 200,
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
        opportunity op1 = new Opportunity()	;
        op1.Name = 'testing';
        op1.AccountId = acc.Id;
        op1.Applicant_1__c = accPerson.Id;
        op1.Applicant_2__c = acc2Person.Id;
        op1.Preferred_repayment_frequency__c = 'Monthly';  
        op1.Loan_Amount__c = 560;
        op1.StageName = 'CPA Done';
        op1.Send_the_quote_to__c = 'Me only';
        op1.Current_Application_Sections__c = 'Who is applying';
        op1.Application_Supporting_Notes__c = 'hello';
        op1.Purchase_Price_Funds_Needed__c = 20000;
        op1.CloseDate = System.today();
        insert op1;
        
        Contact testCon = new Contact();
        testCon.FirstName = 'Test';
        testCon.LastName = 'Con';
        testCon.Phone = '1234567890';
        insert testCon;
        
        
        Opportunity oppUpdate = [SELECT Applicant_1__c, Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                                 FROM Opportunity WHERE Id = : op1.id limit 1];
        
       
        
        list<Document_Requested__c> dcl = new List<Document_Requested__c>();
        Document_Requested__c Dc = new Document_Requested__c();
        Dc.Opportunity__c = op1.id;
        Dc.isComplete__c = true;
        Dc.Document__c='Test';
        Dc.Category__c='Bank Statements';
        Dc.Details__c ='testdocument';
        dcl.add(Dc);
        
        Document_Requested__c Dc2 = new Document_Requested__c();
        Dc2.Opportunity__c = op1.id;
        Dc2.isComplete__c = false;
        Dc2.Document__c='Test';
        Dc2.Category__c='Bank Statements';
        Dc2.Details__c ='testdocument';
        dcl.add(Dc2);
        
        Document_Requested__c Dc1 = new Document_Requested__c();
        Dc1.Opportunity__c = op1.id;
        Dc1.isComplete__c = true;
        Dc1.Document__c='Test';
        Dc1.Category__c='Purchase Invoice';
        Dc1.Details__c ='testdocument';
        dcl.add(Dc1);
        
        Document_Requested__c Dc3 = new Document_Requested__c();
        Dc3.Opportunity__c = op1.id;
        Dc3.isComplete__c = false;
        Dc3.Document__c='Test';
        Dc3.Category__c='Purchase Invoice';
        Dc3.Details__c ='testdocument';
        dcl.add(Dc3);
        
        insert dcl;
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        
        ContentVersion cvv=new Contentversion();
        cvv.title='text';
        cvv.PathOnClient ='text.png';
        cvv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cvv.IsMajorVersion = false;
        cvv.Document_Requested__c = dc1.id;
        cvv.Send_to_Lender__c = true;
        insert cvv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LImit 5];
        
        System.debug('documents_+'+documents);
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        
        cdl.LinkedEntityId = op1.id;
        
        cdl.ContentDocumentId = documents[0].Id;
        
        cdl.shareType = 'V';
        
        Insert cdl;     
       
        
        List<Time_Line_Conditions__c> ls = Test.loadData(Time_Line_Conditions__c.sObjectType, 'lineChartJson');
        system.debug('_+_+'+ls.size());
        
        
    }
    
    
    public static testMethod void testfillActivity(){
        Opportunity oppUpdate = [SELECT Applicant_1__c, Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                                 FROM Opportunity WHERE Name = 'testing' limit 1];
        List<VOI_Status__c> objList = new List<VOI_Status__c>();
        VOI_Status__c vs = new VOI_Status__c();
        vs.Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        vs.Opportunity__c = oppUpdate.id;
        vs.Case_Status__c = 'Submitted';
        vs.VOI_Type_For__c = 'FULL';        
        objList.add(vs);
        
        
        VOI_Status__c vs1 = new VOI_Status__c();
        vs1.Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        vs1.Opportunity__c = oppUpdate.id;
        vs1.Case_Status__c = 'Verified';
        vs1.VOI_Type_For__c = 'VOI';        
        objList.add(vs1);
        
        VOI_Status__c vs2 = new VOI_Status__c();
        vs2.Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        vs2.Opportunity__c = oppUpdate.id;
        vs2.Case_Status__c = 'Submitted';
        vs2.VOI_Type_For__c = 'E-SIGN';        
        vs2.Current_VOI_section__c = 'CQP';
        objList.add(vs2);
        
        VOI_Status__c vs4 = new VOI_Status__c();
        vs4.Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        vs4.Opportunity__c = oppUpdate.id;
        vs4.Case_Status__c = 'Submitted';
        vs4.VOI_Type_For__c = 'FULL';        
        objList.add(vs4);
        
        VOI_Status__c vs5 = new VOI_Status__c();
        vs5.Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        vs5.Opportunity__c = oppUpdate.id;
        vs5.Case_Status__c = 'Verified';
        vs5.VOI_Type_For__c = 'VOI';        
        objList.add(vs5);
        
        VOI_Status__c vs6 = new VOI_Status__c();
        vs6.Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        vs6.Opportunity__c = oppUpdate.id;
        vs6.Case_Status__c = 'Submitted';
        vs6.VOI_Type_For__c = 'E-SIGN'; 
        vs6.Current_VOI_section__c = 'CQP';
        objList.add(vs6);
        
        insert objList;
        
        Linechartcont.fillActivity(oppUpdate.id);
    }
    
    public static testMethod void testfillActivity1(){
        Opportunity oppUpdate = [SELECT Applicant_1__c, Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                                 FROM Opportunity WHERE Name = 'testing' limit 1];
        oppUpdate.stageName = 'Funding';
        update oppUpdate;
        
        List<VOI_Status__c> objList = new List<VOI_Status__c>();
        VOI_Status__c vs = new VOI_Status__c();
        vs.Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        vs.Opportunity__c = oppUpdate.id;
        vs.Case_Status__c = 'Sent';
        vs.VOI_Type_For__c = 'FULL';        
        objList.add(vs);
        
        
        VOI_Status__c vs1 = new VOI_Status__c();
        vs1.Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        vs1.Opportunity__c = oppUpdate.id;
        vs1.Case_Status__c = 'Sent';
        vs1.VOI_Type_For__c = 'VOI';        
        objList.add(vs1);
        
        VOI_Status__c vs2 = new VOI_Status__c();
        vs2.Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        vs2.Opportunity__c = oppUpdate.id;
        vs2.Case_Status__c = 'Sent';
        vs2.VOI_Type_For__c = 'E-SIGN';
        vs2.Current_VOI_section__c = 'CQP';        
        objList.add(vs2);
        
        VOI_Status__c vs4 = new VOI_Status__c();
        vs4.Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        vs4.Opportunity__c = oppUpdate.id;
        vs4.Case_Status__c = 'Sent';
        vs4.VOI_Type_For__c = 'FULL';        
        objList.add(vs4);
        
        VOI_Status__c vs5 = new VOI_Status__c();
        vs5.Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        vs5.Opportunity__c = oppUpdate.id;
        vs5.Case_Status__c = 'Sent';
        vs5.VOI_Type_For__c = 'VOI';        
        objList.add(vs5);
        
        VOI_Status__c vs6 = new VOI_Status__c();
        vs6.Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        vs6.Opportunity__c = oppUpdate.id;
        vs6.Case_Status__c = 'Sent';
        vs6.VOI_Type_For__c = 'E-SIGN';  
        vs6.Current_VOI_section__c = 'CQP';
        objList.add(vs6);
        
        insert objList;
        
        Linechartcont.fillActivity(oppUpdate.id);
    }
    
    public static testMethod void testfillActivity2(){
        Opportunity oppUpdate = [SELECT Applicant_1__c, Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                                 FROM Opportunity WHERE Name = 'testing' limit 1];
        oppUpdate.stageName = 'Approved';
        OpportunityTriggerHandler.isByPassApprovedValidation = true;
        update oppUpdate;
        OpportunityTriggerHandler.isByPassApprovedValidation = false;
        
        List<VOI_Status__c> objList = new List<VOI_Status__c>();
        VOI_Status__c vs = new VOI_Status__c();
        vs.Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        vs.Opportunity__c = oppUpdate.id;
        vs.Case_Status__c = 'Sent';
        vs.VOI_Type_For__c = 'FULL';        
        objList.add(vs);
        
      
        VOI_Status__c vs2 = new VOI_Status__c();
        vs2.Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        vs2.Opportunity__c = oppUpdate.id;
        vs2.Case_Status__c = 'Sent';
        vs2.VOI_Type_For__c = 'E-SIGN';  
        vs2.Current_VOI_section__c = 'CQP';
        objList.add(vs2);
        
        VOI_Status__c vs4 = new VOI_Status__c();
        vs4.Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        vs4.Opportunity__c = oppUpdate.id;
        vs4.Case_Status__c = 'Sent';
        vs4.VOI_Type_For__c = 'FULL';        
        objList.add(vs4);
      
        VOI_Status__c vs6 = new VOI_Status__c();
        vs6.Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        vs6.Opportunity__c = oppUpdate.id;
        vs6.Case_Status__c = 'Sent';
        vs6.VOI_Type_For__c = 'E-SIGN';    
        vs6.Current_VOI_section__c = 'CQP';
        objList.add(vs6);
        
        insert objList;
        
        Linechartcont.fillActivity(oppUpdate.id);
    }
    
    public static testMethod void testfillActivity3(){
        Opportunity oppUpdate = [SELECT Applicant_1__c, Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                                 FROM Opportunity WHERE Name = 'testing' limit 1];
       // oppUpdate.stageName = 'Quote';
       // update oppUpdate;
        
        List<VOI_Status__c> objList = new List<VOI_Status__c>();
        VOI_Status__c vs = new VOI_Status__c();
        vs.Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        vs.Opportunity__c = oppUpdate.id;
        vs.Case_Status__c = 'Sent';
        vs.VOI_Type_For__c = 'FULL';        
        objList.add(vs);
        
        
        VOI_Status__c vs4 = new VOI_Status__c();
        vs4.Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        vs4.Opportunity__c = oppUpdate.id;
        vs4.Case_Status__c = 'Sent';
        vs4.VOI_Type_For__c = 'FULL';        
        objList.add(vs4);
        insert objList;
        
        Linechartcont.fillActivity(oppUpdate.id);
    }
    
    public static testMethod void testfillActivity4(){
        Opportunity oppUpdate = [SELECT Applicant_1__c, Send_the_quote_to__c,Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                                 FROM Opportunity WHERE Name = 'testing' limit 1];
        oppUpdate.stageName = 'CPA Done';
        oppUpdate.Send_the_quote_to__c = 'Me and my customer';
        update oppUpdate;
        
        List<VOI_Status__c> objList = new List<VOI_Status__c>();
        VOI_Status__c vs = new VOI_Status__c();
        vs.Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        vs.Opportunity__c = oppUpdate.id;
        vs.Case_Status__c = 'Sent';
        vs.VOI_Type_For__c = 'FULL';        
        objList.add(vs);
        
        
        VOI_Status__c vs1 = new VOI_Status__c();
        vs1.Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        vs1.Opportunity__c = oppUpdate.id;
        vs1.Case_Status__c = 'Sent';
        vs1.VOI_Type_For__c = 'VOI';        
        objList.add(vs1);
        
        VOI_Status__c vs4 = new VOI_Status__c();
        vs4.Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        vs4.Opportunity__c = oppUpdate.id;
        vs4.Case_Status__c = 'Sent';
        vs4.VOI_Type_For__c = 'FULL';        
        objList.add(vs4);
        
        VOI_Status__c vs5 = new VOI_Status__c();
        vs5.Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        vs5.Opportunity__c = oppUpdate.id;
        vs5.Case_Status__c = 'Sent';
        vs5.VOI_Type_For__c = 'VOI';        
        objList.add(vs5);
        
        insert objList;
        
        list<Document_Requested__c> dcl = new List<Document_Requested__c>();
        Document_Requested__c Dc = new Document_Requested__c();
        Dc.Opportunity__c = oppUpdate.id;
        Dc.isComplete__c = false;
        Dc.Document__c='Test';
        Dc.Category__c='Bank Statements';
        Dc.Details__c ='testdocument';
        dcl.add(Dc);
        insert dcl;

        Linechartcont.fillActivity(oppUpdate.id);
    }
    
    
    public static testMethod void testfillActivity5(){
       String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
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
            Relationship_with_Applicant_1__c='Client',
            PersonTitle = 'Mr.',
            Phone = '0400000000',
            Security_Question__pc = 'Mothers maiden name',
            Security_Answer__pc = 'qwerty',
            Rental_Amount__pc = 500,
            Rental_or_Board_paid__pc =  50,
            Education_ChildCare_SchoolFees_Uniform__pc = 12,
            Maintenance_If_pay_child_maintenance__pc =  25,
            Other_loans_and_or_debt_commitments__pc = 24,
            Education_public_and_private__pc  = 10,
            Food_Groceries_Meat_Fruit_Vegetabl__pc = 100,
            Living_Situation__pc = 'Renting',
            Citizenship_Status__pc = 'Australian Citizen',
            FinServ__Gender__pc = 'Male',
            Transport_Public_Petrol_Registration__pc = 100,
            Medical_Private_Health_Insurance_Ong__pc = 100,
            Personal_Insurances_life_and_income_pro__pc = 100,
            Insurances_Home_Personal_Voluntary__pc = 100,
            Utilities__pc = 100,
            Driver_s_licence_state_Territory__pc = 'Queensland',
            Connections_Phone_Mobile_Internet_C__pc = 200,
            FinServ__NumberOfChildren__pc = 3
        );
       insert accPerson;
        
        opportunity op1 = new Opportunity()	;
        op1.Name = 'testing';
        op1.Applicant_1__c = accPerson.Id;
        op1.Applicant_2__c = accPerson.Id;
        op1.Preferred_repayment_frequency__c = 'Monthly';  
        op1.Loan_Amount__c = 560;
        op1.StageName = 'Packs Back';
        op1.Send_the_quote_to__c = 'Me only';
        op1.Current_Application_Sections__c = 'Who is applying';
        op1.Application_Supporting_Notes__c = 'hello';
        op1.CloseDate = System.today();
        insert op1;
        
        Opportunity oppUpdate = [SELECT Applicant_1__c, Send_the_quote_to__c,Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                                 FROM Opportunity WHERE id =: op1.id limit 1];
        
        VOI_Status__c vs1 = new VOI_Status__c();
        vs1.Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        vs1.Opportunity__c = oppUpdate.id;
        vs1.Case_Status__c = 'Verified';
        vs1.VOI_Type_For__c = 'VOI';        
        
        insert vs1;
        
        list<Document_Requested__c> dcl = new List<Document_Requested__c>();
        Document_Requested__c Dc = new Document_Requested__c();
        Dc.Opportunity__c = op1.id;
        Dc.isComplete__c = true;
        Dc.Document__c='Test';
        Dc.Category__c='Bank Statements';
        Dc.Details__c ='testdocument';
        dcl.add(Dc);
        
        Document_Requested__c Dc1 = new Document_Requested__c();
        Dc1.Opportunity__c = op1.id;
        Dc1.isComplete__c = true;
        Dc1.Document__c='Test';
        Dc1.Category__c='Purchase Invoice';
        Dc1.Details__c ='testdocument';
        dcl.add(Dc1);
        
        insert dcl;
        
        Linechartcont.fillActivity(op1.id);
    }
    
    public static testMethod void testfundingReq1(){
        Opportunity opp = [SELECT Applicant_1__c, Send_the_quote_to__c,Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                           FROM Opportunity WHERE Name = 'testing' Order by CreatedDate DESC];
        
        Funding_Request__c fr = new Funding_Request__c();
        fr.Applicant_1_A1__c = opp.Applicant_1__c;
        fr.Applicant_2_A2__c = opp.Applicant_2__c;
        fr.Person_Requesting__c = opp.Applicant_1__r.PersonContactId;
        fr.Request_Status__c = 'Payment requested by customer';
        fr.Customer_Authorisation_Type__c = 'Both to sign';
        fr.Opportunity__c = opp.Id;
        fr.Customer_Authorisation_Status__c = 'Pending Applicant 1';
        
        insert fr;
        Linechartcont.fillActivity(opp.id);
    }
    
    public static testMethod void testfundingReq2(){
        Opportunity opp = [SELECT Applicant_1__c, Send_the_quote_to__c,Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                           FROM Opportunity WHERE Name = 'testing' Order by CreatedDate DESC];
        
        Funding_Request__c fr = new Funding_Request__c();
        fr.Applicant_1_A1__c = opp.Applicant_1__c;
        fr.Applicant_2_A2__c = opp.Applicant_2__c;
        fr.Person_Requesting__c = opp.Applicant_1__r.PersonContactId;
        fr.Request_Status__c = 'Payment requested by customer';
        fr.Customer_Authorisation_Type__c = 'Both to sign';
        fr.Opportunity__c = opp.Id;
        fr.Customer_Authorisation_Status__c = 'Pending Applicant 1';
        
        insert fr;
        Linechartcont.fillActivity(opp.id);
    }
    
    public static testMethod void testfundingReq3(){
        Opportunity opp = [SELECT Applicant_1__c, Send_the_quote_to__c,Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                           FROM Opportunity WHERE Name = 'testing' Order by CreatedDate DESC];
        
        Funding_Request__c fr = new Funding_Request__c();
        fr.Applicant_1_A1__c = opp.Applicant_1__c;
        fr.Applicant_2_A2__c = opp.Applicant_2__c;
        fr.Person_Requesting__c = opp.Applicant_1__r.PersonContactId;
        fr.Request_Status__c = 'Payment requested by customer';
        fr.Customer_Authorisation_Type__c = 'Both to sign';
        fr.Opportunity__c = opp.Id;
        fr.Customer_Authorisation_Status__c = 'Pending Applicant 2';
        
        insert fr;
        Linechartcont.fillActivity(opp.id);
    }
    
    public static testMethod void testfundingReq4(){
        Opportunity opp = [SELECT Applicant_1__c, Applicant_2__c, Send_the_quote_to__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                           FROM Opportunity WHERE Name = 'testing' Order by CreatedDate DESC];
        opp.Applicant_2__c = null;
        opp.Funding_Variation_Request__c = true;
        update opp;
        
        Funding_Request__c fr = new Funding_Request__c();
        fr.Applicant_1_A1__c = opp.Applicant_1__c;
        fr.Person_Requesting__c = opp.Applicant_1__r.PersonContactId;
        fr.Request_Status__c = 'Payment requested by supplier';
        fr.Customer_Authorisation_Type__c = 'Either to sign';
        fr.Opportunity__c = opp.Id;
        fr.Customer_Authorisation_Status__c = 'Request sent to customer(s)';
        
        insert fr;
        Linechartcont.fillActivity(opp.id);
    }
    
    public static testMethod void testfundingReq5(){
        Opportunity opp = [SELECT Applicant_1__c, Send_the_quote_to__c,Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                           FROM Opportunity WHERE Name = 'testing' Order by CreatedDate DESC];
        
        Funding_Request__c fr = new Funding_Request__c();
        fr.Applicant_1_A1__c = opp.Applicant_1__c;
        fr.Applicant_2_A2__c = opp.Applicant_2__c;
        fr.Person_Requesting__c = opp.Applicant_1__r.PersonContactId;
        fr.Request_Status__c = 'Payment requested by customer';
        fr.Customer_Authorisation_Type__c = 'Either to sign';
        fr.Opportunity__c = opp.Id;
        fr.Customer_Authorisation_Status__c = 'Authorised';
        
        insert fr;
        Linechartcont.fillActivity(opp.id);
    }
    
    public static testMethod void testfundingReq6(){
        Opportunity opp = [SELECT Applicant_1__c, Send_the_quote_to__c,Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                           FROM Opportunity WHERE Name = 'testing' Order by CreatedDate DESC];
        
        Funding_Request__c fr = new Funding_Request__c();
        fr.Applicant_1_A1__c = opp.Applicant_1__c;
        fr.Applicant_2_A2__c = opp.Applicant_2__c;
        fr.Person_Requesting__c = opp.Applicant_1__r.PersonContactId;
        fr.Request_Status__c = 'Payment requested by customer';
        fr.Customer_Authorisation_Type__c = 'Both to sign';
        fr.Opportunity__c = opp.Id;
        fr.Customer_Authorisation_Status__c = 'Request sent to customer(s)';
        
        insert fr;
        Linechartcont.fillActivity(opp.id);
    }
    
     public static testMethod void testfundingReq7(){
        Opportunity opp = [SELECT Applicant_1__c, Send_the_quote_to__c,Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                           FROM Opportunity WHERE Name = 'testing' Order by CreatedDate DESC];
        
        Funding_Request__c fr = new Funding_Request__c();
        fr.Applicant_1_A1__c = opp.Applicant_1__c;
        fr.Applicant_2_A2__c = opp.Applicant_2__c;
        fr.Person_Requesting__c = opp.Applicant_1__r.PersonContactId;
        fr.Request_Status__c = 'Payment requested by customer';
        fr.Customer_Authorisation_Type__c = 'Either to sign';
        fr.Opportunity__c = opp.Id;
        fr.Customer_Authorisation_Status__c = 'Pending Applicant 1';
        
        insert fr;
        Linechartcont.fillActivity(opp.id);
    }
    
    public static testMethod void testfundingReq8(){
        Opportunity opp = [SELECT Applicant_1__c, Send_the_quote_to__c,Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId,Purchase_Price_Funds_Needed__c
                           FROM Opportunity WHERE Name = 'testing' Order by CreatedDate DESC];
        
        Funding_Request__c fr = new Funding_Request__c();
        fr.Applicant_1_A1__c = opp.Applicant_1__c;
        fr.Applicant_2_A2__c = opp.Applicant_2__c;
        fr.Person_Requesting__c = opp.Applicant_1__r.PersonContactId;
        fr.Request_Status__c = 'Payment requested by customer';
        fr.Customer_Authorisation_Type__c = 'Either to sign';
        fr.Opportunity__c = opp.Id;
        fr.Customer_Authorisation_Status__c = 'Pending Applicant 1';
        
        insert fr;
        Linechartcont.fillActivity(opp.id);
    }
}