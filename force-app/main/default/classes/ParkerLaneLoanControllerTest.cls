@istest
public class ParkerLaneLoanControllerTest {
    @testsetup
    static void setUpData(){
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String recordHTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Household').getRecordTypeId();
        List<Account> accList= new List<Account>();
        Account acc= new Account(
            RecordTypeID = recordHTypeId,
            Name='Test Name'
        );
        accList.add(acc);
        
        Account accPerson= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test Person',
            LastName='Test LName',
            Phone ='1234567890',
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
        
        contact con = new contact();
        con.LastName ='test';
        insert con;
        
        Opportunity oppty = new Opportunity ();
        oppty.applicant_1__c = accPerson.Id;
        oppty.applicant_2__c = accPerson2.Id;
        oppty.Contact_1__c = con.Id;
        oppty.AccountId = acc.Id;
        oppty.name = 'test Oppty';
        oppty.StageName='Assessment Needed'; 
        oppty.CloseDate = Date.today();
        oppty.Application_Sections__c ='Own and Owe'; 
        oppty.Current_Application_Sections__c ='Who is applying';
        oppty.Document_Redirect_URL__c = '/MogoDocument';
        oppty.Relationship_to_Applicant_2__c = 'Spouse';
        oppty.Confirm_Settlement_Date__c = true; 
        insert oppty;
        
      
        voi_Status__c vc = new voi_Status__c();
        vc.Contact__c = oppty.Applicant_1__r.personcontactId;
        vc.Case_Status__c = 'Sent';
        vc.Opportunity__c = oppty.Id;
        vc.link_Expire_code__c ='ttttt';
        insert vc;
        
        Opportunity oppUpdate = [SELECT Id, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                                FROM Opportunity WHERE Id =: oppty.Id];
        
        FinServ__Employment__c emp1 =New FinServ__Employment__c();
        emp1.Name = 'test';
        emp1.FinServ__EmploymentStatus__c = 'Part time permanent';
        emp1.FinServ__Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        FinServ__Employment__c emp2 =New FinServ__Employment__c();
        emp2.Name = 'test1';
        emp2.FinServ__EmploymentStatus__c = 'Part time permanent';
        emp2.FinServ__Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        
        insert New List<FinServ__Employment__c>{emp1, emp2};
        List<Product2> productList = new List<Product2>();
        productList.add(New Product2(IsActive =true, Default_Product__c = true,
                                     Product_Type__c = 'Green Loan', Product_Order__c = 1,
                                     Name = 'product', Features__c='Feature1;Feature2',
                                     Acceptable_Loan_Purpose__c = 'Solar',
                                     Maximum_Loan_Term_Years__c =1,Interest_Rate_Based_On__c  ='Tiered Rate',
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
                             Interest_Rate__c = 5, Actual_Comparison_Rate__c = 20,Gruop_Name__c='Website-1');
        insert qt;
      
        
        Loan_Fees__c fee1 = New Loan_Fees__c(Amount__c = 200, Product__c = productList[0].Id);
        insert fee1;
        Loan_Rate__c rate = New Loan_Rate__c(From_amount__c=0,Interest_rate__c=1.2,To_amount__c = 999999999,Comparison_rate__c = 1.5, Product__c = productList[0].Id);
        insert rate;
    }
    
    static testmethod void selectedSectionTest(){
        Opportunity opp = [SELECT Id,Application_Sections__c, Current_Application_Sections__c FROM Opportunity WHERE Name ='test Oppty' Limit 1];
        String path = ParkerLaneLoanController.getSelectedSection(opp.Id);
        System.assertNotEquals('[]', path, 'value should not be blank');
        
        path = ParkerLaneLoanController.SaveAndNextWithoutId('Who is applying');
        System.assertNotEquals('[]', path, 'value should not be blank');
        
        path = ParkerLaneLoanController.previous(opp.id);
        System.assertNotEquals('[]', path, 'value should not be blank');
        
        path = ParkerLaneLoanController.setSelectedSection(opp.id, 'Who is applying');
        System.assertNotEquals('[]', path, 'value should not be blank');
    }
    
    static testmethod void getFeaturedProductsTest(){
        List<Product2> products = ParkerLaneLoanController.getFeaturedProducts(true,'');
        System.assertEquals(1,products.size(), 'value should be 1');
        products = ParkerLaneLoanController.getFeaturedProducts(false,'Solar');
        System.assertEquals(3,products.size(), 'value should be 3');
    }
    
    static testmethod void getVerifyPhoneNumberTest(){
        Opportunity opp = [SELECT Id ,Application_Sections__c, Current_Application_Sections__c 
                           FROM Opportunity WHERE Name ='test Oppty' Limit 1];
        
        Boolean isVerify = ParkerLaneLoanController.getVerifyPhoneNumber(opp.Id, '1234567890');
        System.assert(isVerify, 'value should be false');
        
        isVerify = ParkerLaneLoanController.getVerifyPhoneNumber(opp.Id, '1234567892');
        System.assert(!isVerify, 'value should be true');
    }
   
    static testmethod void createLeadAndQuotesTest(){
        test.startTest();
        String path = ParkerLaneLoanController.createLeadAndQuotes('Solar','cFName', 'cLName', 'test@test.com', 1000,'Lowest Repayment','Between 3-5 Years','No');
       // System.assertNotEquals('[]', path, 'value should not be blank');
        Opportunity opp = [SELECT Id, AccountId, FinServ__Household__c, Account.RecordType.Name 
                           FROM Opportunity Limit 1];
        sObject selectedQuote = (sObject)[SELECT Id, Actual_Comparison_Rate__c, Comparison_Rate_Warning__c, Eligibility__c,
                 Features__c, Interest_Rate__c, Customer_Amount__c, Loan_Term__c, Name, Product__c, Up_Front_Costs_Applicable__c,
                 Monthly_Repayment__c, Min_Loan_Term__c, Max_Loan_Term__c, Purpose__c, Lead__c,Product__r.Maximum_Loan_Amount__c,Product__r.Minimum_Loan_Amount__c
                                          FROM Quote WHERE OpportunityId=:opp.Id ORDER BY Max_Loan_Term__c limit 1];

        path = ParkerLaneLoanController.SaveAndConfirm(selectedQuote, Opp);
        System.assertNotEquals('[]', path, 'value should not be blank'); 
        apexpages.currentpage().getparameters().put('id', opp.Id);
        QuotationTemplatePDFCtrl qTPDF = New QuotationTemplatePDFCtrl();
        List<ParkerLaneLoanController.WrapperLoanRate> wprLoanRateList = New List<ParkerLaneLoanController.WrapperLoanRate>();
        wprLoanRateList = ParkerLaneLoanController.getQuotaions(opp.Id,'Website-1');
        System.assertNotEquals(0,wprLoanRateList.size(), 'value should not be 0');
        Contact con = (Contact) ParkerLaneLoanController.getLead(opp.Id);
        Integer index = ParkerLaneLoanController.getOppIndex(opp.Id); 
        List<Quote> quotes = New List<Quote>();
        for(ParkerLaneLoanController.WrapperLoanRate wrp: wprLoanRateList){
            quotes.add(wrp.quote);
        }
        path = ParkerLaneLoanController.UpdateQuote(quotes, quotes[0].id);  
        System.assertNotEquals('[]', path, 'value should not be blank');
        sObject quote = ParkerLaneLoanController.getSelectedQuote(Opp.Id);
        System.assertNotEquals(null, quote.id, 'value should not be null');
        ParkerLaneLoanController.sendApplication(opp.Id, con.Id, quote.id, New List<String>{'abc@gmail.com'}, 'Quotation From Referrer', true);
        string result = ParkerLaneLoanController.checkExistingCustomer(New Contact(LastName = 'Con1', Email='test@gmail.com'), New Contact(LastName = 'Con1', Email='test@gmail.com'), opp , 2); 
        System.assertNotEquals('[]', result, 'value should not be blank');
        test.stopTest();
    }
    
    static testmethod void oppContactsTest(){
        Opportunity opp = [SELECT Id, Application_Sections__c, Current_Application_Sections__c, Applicant_1__c, Applicant_2__c,
                           AccountId, Relationship_to_Applicant_2__c
                           FROM Opportunity WHERE Name ='test Oppty' Limit 1];
      
        ParkerLaneLoanController.OpportunityContacts oppCons = ParkerLaneLoanController.getOppContacts(opp.Id);
        
        apexpages.currentpage().getparameters().put('id', opp.Id);
        QuotationTemplatePDFCtrl qTPDF = New QuotationTemplatePDFCtrl();
        
        String path = ParkerLaneLoanController.upsertOppContacts(oppCons.contact1, oppCons.contact2, oppCons.app1Children, oppCons.app2Children, opp, true, true);
        System.assertNotEquals('[]', path, 'value should not be blank');
        oppCons.app1Children[0].id = null;
        oppCons.app2Children[0].id = null;
        oppCons.contact2.id = null;
        opp.Applicant_2__c = null;
        path = ParkerLaneLoanController.upsertOppContacts(oppCons.contact1, oppCons.contact2, oppCons.app1Children, oppCons.app2Children, opp, true, true);
        path = ParkerLaneLoanController.upsertOppContacts(oppCons.contact1, oppCons.contact2, oppCons.app1Children, oppCons.app2Children, opp, false, true);
        System.assertEquals('[]', path, 'value should not be blank');
        
        ParkerLaneLoanController.shareApplicationByEmail(opp.Id, 'test@gmail.com', 'emailBody');
    }
    
    static testmethod void getSelectedPersonTest(){
        Opportunity opp = [SELECT Id, Application_Sections__c, Current_Application_Sections__c, 
                           Number_of_applicants__c,  Applicant_1__c, Applicant_2__c
                           FROM Opportunity WHERE Name ='test Oppty' Limit 1];
        
        String persons = ParkerLaneLoanController.getSelectedPerson(opp.Id);
        System.assertEquals('joint', persons, 'value should not be blank');
        
        opp.Applicant_2__c = Null;
        update opp;
        
        persons = ParkerLaneLoanController.getSelectedPerson(opp.Id);
        System.assertEquals('single', persons, 'value should not be blank');
    }
    
    static testmethod void assetsAndLiabilitiesTest(){
        Opportunity opp = [SELECT Id ,Application_Sections__c, Current_Application_Sections__c 
                           FROM Opportunity WHERE Name ='test Oppty' Limit 1];
        List<FinServ__AssetsAndLiabilities__c> assetsList = new List<FinServ__AssetsAndLiabilities__c>{new FinServ__AssetsAndLiabilities__c(Name = 'Asset', Is_Address_Same__c= true, Property_Situation__c ='Own with mortgage', FinServ__AssetsAndLiabilitiesType__c = 'Home'),
            new FinServ__AssetsAndLiabilities__c(Name = 'Asset1', Is_Address_Same__c= true, Property_Situation__c ='Own with mortgage', FinServ__AssetsAndLiabilitiesType__c = 'Investment Property')};
        List<FinServ__AssetsAndLiabilities__c> liabilitiesList = new List<FinServ__AssetsAndLiabilities__c>{new FinServ__AssetsAndLiabilities__c(Name = 'Liability', 
                                                                                                                                                 FinServ__AssetsAndLiabilitiesType__c = 'Car Lease',
                                                                                                                                                Institution__c = 'test',
                                                                                                                                                Value__c = 10,
                                                                                                                                                Monthly_Repayment__c=10,
                                                                                                                                                Post_tax_lease_Payment__c =10,
                                                                                                                                                Pre_tax_lease_Payment__c = 10)};
        String path = ParkerLaneLoanController.upsertOppAssetsAndLiabilities(assetsList, liabilitiesList, opp.Id, true, true);
        System.assertNotEquals('[]', path, 'value should not be blank');
        Map<String, List<FinServ__AssetsAndLiabilities__c>> assLiaMap = ParkerLaneLoanController.getAssetsAndLiabilities(opp.Id);
        System.assertEquals(2, assLiaMap.get('Asset').Size(), 'Size should be 2');
        System.assertEquals(1, assLiaMap.get('Liability').Size(), 'Size should be 1');
        path = ParkerLaneLoanController.upsertOppAssetsAndLiabilitiesPL(assetsList, liabilitiesList, opp.Id, true, true,'Yes','Yes','Yes',true);
        ParkerLaneLoanController.deleteRecordsByIds(New List<Id>{assLiaMap.get('Asset')[0].Id} );
        ParkerLaneLoanController.deleteAssetAndLibByIds(New List<Id>{assLiaMap.get('Asset')[1].Id});
    }
    
    static testmethod void employmentTest(){
        Opportunity opp = [SELECT Id ,Application_Sections__c, Current_Application_Sections__c 
                           FROM Opportunity WHERE Name ='test Oppty' Limit 1];
        Map<String, Contact> conEmpMap = ParkerLaneLoanController.getEmploymentDetails(opp.Id);
        String path = ParkerLaneLoanController.upsertEmploymentDetails(conEmpMap.get('applicant1'), conEmpMap.get('applicant2'), new List<FinServ__Employment__c>{new FinServ__Employment__c(Name = 'emp1')}, new List<FinServ__Employment__c>{new FinServ__Employment__c(Name = 'emp1')}, opp.Id, true, true);
        System.assertNotEquals('[]', path, 'value should not be blank');
    }
    
    static testmethod void livingExpensesTest(){
        Opportunity opp = [SELECT Id ,Application_Sections__c, RecordTypeId, Current_Application_Sections__c 
                           FROM Opportunity WHERE Name ='test Oppty' Limit 1];
        opp.Current_Application_Sections__c = 'Goals & Objectives';
        update opp;
        ParkerLaneLoanController.ContactWithOpp conWrap = ParkerLaneLoanController.getLivingExpensesDetails(opp.Id);
        String path = ParkerLaneLoanController.upsertLivingExpensesDetails(conWrap.con, opp.Id, true, true);
        System.assertNotEquals('[]', path, 'value should not be blank');
    }
    
    static testmethod void AnticipateTest(){
        Opportunity opp = [SELECT Id, Application_Sections__c, Current_Application_Sections__c, Applicant_1__c, Applicant_2__c,
                           AccountId, Relationship_to_Applicant_2__c, Number_of_applicants__c, RecordTypeId
                           FROM Opportunity WHERE Name ='test Oppty' Limit 1];
        Anticipated_Changes_to_Circumstance__c anti = ParkerLaneLoanController.getAnticipatedChangesCircumstancesDetails(opp.Id);
        
        String path = ParkerLaneLoanController.upsertAnticipatedChangesCircumstancesDetails(New Anticipated_Changes_to_Circumstance__c(), opp.Id, true, true);
        System.assertNotEquals('[]', path, 'value should not be blank'); 

    }
    static testmethod void preferencesTest(){
        Opportunity opp = [SELECT Id, Application_Sections__c, Current_Application_Sections__c, Applicant_1__c, Applicant_2__c,
                           AccountId, Relationship_to_Applicant_2__c, Number_of_applicants__c, RecordTypeId
                           FROM Opportunity WHERE Name ='test Oppty' Limit 1];
        ParkerLaneLoanController.OpportunityContacts oppCons = ParkerLaneLoanController.getPreferences(opp.Id);
        String path = ParkerLaneLoanController.upsertPreferences(oppCons.contact1, oppCons.contact2, opp, New List<Loan_Purpose__c>{}, true, true);
        System.assertNotEquals('[]', path, 'value should not be blank'); 

    }
    
    static testmethod void goalsTest(){
        
        Opportunity opp = [SELECT Id ,Application_Sections__c, Current_Application_Sections__c,Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId 
                           FROM Opportunity WHERE Name ='test Oppty' Limit 1];
        opp.Current_Application_Sections__c = 'Goals & Objectives';
        update opp;
        
        FinServ__FinancialGoal__c goal = new FinServ__FinancialGoal__c(Name='');
        Contact con1 = New Contact(Id = opp.Applicant_1__r.PersonContactId);
        Contact con2 = New Contact(Id = opp.Applicant_2__r.PersonContactId);
        //String path = ParkerLaneLoanController.upsertGoals(goal, opp.Id, con1,con2, true, true); //AlreadyCommented
        test.startTest();
        string path = ParkerLaneLoanController.upsertGoals(goal, opp.Id, con1,con2, true, false);
        
        //System.assertNotEquals('', path, 'value should not be blank');
        
        goal = ParkerLaneLoanController.getGoals(opp.Id);
        test.stopTest();
        //System.assertEquals(null, goal.Id, 'value should not be NULL');
        
    }
   
   
    static testmethod void summaryTest(){
        Opportunity opp = [SELECT Id ,Application_Sections__c, Current_Application_Sections__c,Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId 
                           FROM Opportunity WHERE Name ='test Oppty' Limit 1];
		test.startTest();
        ParkerLaneLoanController.updateSummary(opp.Id, 'false');
        //System.assertNotEquals('[]', path, 'value should not be blank');
        ParkerLaneLoanController.getSummary(opp.Id);
        //System.assertNotEquals(null, goal.Id, 'value should not be NULL');
        test.stopTest();
    }

    static testmethod void onOppUpdate(){
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User tuser = new User(firstname = 'frName',
                              lastName = 'lName',
                              email = 'frName@test.org',
                              Username = 'frName@test.org',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = 'sc',
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = pf.Id);
        insert tuser;
        /*
        Opportunity oppty = new Opportunity ();
        oppty.name = 'test Oppty1';
        oppty.StageName='Assessment Needed'; 
        oppty.CloseDate = Date.today();
        oppty.Application_Sections__c ='Own and Owe'; 
        oppty.Current_Application_Sections__c ='Who is applying';
        oppty.Relationship_to_Applicant_2__c = 'Spouse';
        oppty.Confirm_Settlement_Date__c = true;
        insert oppty;*/
        
        Opportunity opp = [SELECT Id, StageName,Amount,OwnerId,SF_Type__c,SF_Rate_inc_GST__c FROM Opportunity WHERE Name ='test Oppty' Limit 1];
        opp.StageName = 'Quote';
        opp.SF_Type__c = 'Amount';
        opp.SF_Rate_inc_GST__c = 1000;
        update opp;
        Opportunity aopp = [SELECT Id, StageName,Amount,OwnerId,SF_Type__c,SF_Rate_inc_GST__c FROM Opportunity WHERE Name ='test Oppty' Limit 1];
        //System.assert(aopp.Amount == 1000);
        opp.StageName = 'Settled (closed won)';
        opp.OwnerId = tuser.Id;
        System.runAs(tuser) {
            
            update opp;
            System.assertEquals(opp.StageName, 'Settled (closed won)', 'value should not be NULL');
            opp.SF_Rate_inc_GST__c = 500;
        	update opp;
            aopp = [SELECT Id, StageName,Amount,OwnerId,SF_Type__c,SF_Rate_inc_GST__c FROM Opportunity WHERE Name ='test Oppty' Limit 1];
            //System.assert(aopp.Amount == 500);
        }
    }
     static testmethod void UpdateApplicationSectionTest(){
         opportunity oppRec = [SELECT Id, Application_Sections__c, Current_Application_Sections__c, RecordTypeId
                              FROM Opportunity WHERE Name='test Oppty' Limit 1];
         oppRec.Current_Application_Sections__c = 'Loan Recommendation';
         oppRec.Application_Sections__c = 'Loan Recommendation';
         oppRec.Application_Sections__c = 'Summary';
         update oppRec;
      string path = ParkerLaneLoanController.UpdateApplicationSection(oppRec.Id,oppRec.Application_Sections__c,True);
       System.assertNotEquals('[]',path);
    }
    
    static testmethod void createEnvelopeTest(){
        opportunity oppRec = [SELECT Id, Application_Sections__c, Current_Application_Sections__c, RecordTypeId
                              FROM Opportunity WHERE Name='test Oppty' Limit 1];
        
         string str = ParkerLaneLoanController.createEnvelope(oppRec.Id);
         system.assertEquals('', str);
    }
        static testmethod void getoppIndexExceptionTest(){
        
        ParkerLaneLoanController.getOppIndex(null);
    }
    static testmethod void smsvalidationTest(){
        Opportunity opp = [select Id,Applicant_Details_Change__c,Applicant_1__r.VOI_type__pc,Applicant_2__r.VOI_type__pc, name,Loan_Details_change__c, Applicant_1__r.PersonContactId, Applicant_1__r.Phone, Applicant_2__c, 
                               Applicant_2__r.PersonContactId, Applicant_2__r.Phone, Document_Redirect_URL__c 
                               FROM opportunity WHERE Name='test Oppty' Limit 1];
        opp.Applicant_Details_Change__c =true;
         update opp;
        voi_Status__c vc = new voi_Status__c();
        vc.Contact__c = opp.Applicant_1__r.personcontactId;
        vc.Case_Status__c = 'Sent';
        vc.Opportunity__c = opp.Id;
        vc.link_Expire_code__c ='ttttt';
        insert vc;
        test.startTest();
        ParkerLaneLoanController.checkVOIConditions(opp);
        ParkerLaneLoanController.inertPDF(opp.Id);
        ParkerLaneLoanController.getOppDetails(opp.Id);
        test.stopTest();
    }
}