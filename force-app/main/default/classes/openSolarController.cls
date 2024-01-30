public class openSolarController {       
    private static Map<String, Id> leadRecordTypeMap = New Map<String, Id>{
        'Solar' => Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Green Loan').getRecordTypeId(),
            'Home Improvement' => Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Home Improvement').getRecordTypeId(),
            'Debt Consolidation' => Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Debt Consolidation').getRecordTypeId()};
                private static Id personAccRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    private static Id householdAccRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    private static Map<String, Id> oppRecordTypeMap = New Map<String, Id>{
        'Solar' => Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Green Loan').getRecordTypeId(),
         'Home Improvement' => Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Home Improvement').getRecordTypeId(),
         'Debt Consolidation' => Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Debt Consolidation').getRecordTypeId()};
    
    public static string insertData(){
        try{
            string uniqueFileID = Apexpages.currentPage().getParameters().get('uniqueFileID');        
            string cAmount = Apexpages.currentPage().getParameters().get('cAmount');
            string loanTerm = Apexpages.currentPage().getParameters().get('loanTerm');
            string lendingPurpose = Apexpages.currentPage().getParameters().get('lendingPurpose');
            string cFName = Apexpages.currentPage().getParameters().get('cFName');
            string cLName = Apexpages.currentPage().getParameters().get('cLName');
            string cEmail = Apexpages.currentPage().getParameters().get('cEmail');
            string cPhone = Apexpages.currentPage().getParameters().get('cPhone');
            string streetNum = Apexpages.currentPage().getParameters().get('streetNum');
            string street = Apexpages.currentPage().getParameters().get('street');
            string streetTyp = Apexpages.currentPage().getParameters().get('streetTyp');
            string suburb = Apexpages.currentPage().getParameters().get('suburb');
            string state = Apexpages.currentPage().getParameters().get('state');
            string postcode = Apexpages.currentPage().getParameters().get('postcode');
            string suppId = Apexpages.currentPage().getParameters().get('suppId');
            string sCompName = Apexpages.currentPage().getParameters().get('sCompName');
            string sLogoURL = Apexpages.currentPage().getParameters().get('sLogoURL');
            string scompPhone = Apexpages.currentPage().getParameters().get('scompPhone');
            string scompEmail = Apexpages.currentPage().getParameters().get('scompEmail');
            string sFirstName = Apexpages.currentPage().getParameters().get('sFirstName');
            string sLastName = Apexpages.currentPage().getParameters().get('sLastName');
            string sEmail = Apexpages.currentPage().getParameters().get('sEmail');
            string sPhone = Apexpages.currentPage().getParameters().get('sPhone');
            string systemTyp = Apexpages.currentPage().getParameters().get('systemTyp');
            string systemCapacity = Apexpages.currentPage().getParameters().get('systemCapacity');
            string batteryCapacity = Apexpages.currentPage().getParameters().get('batteryCapacity');
            string QuarterlyEnergyBill = Apexpages.currentPage().getParameters().get('QuarterlyEnergyBill');
            string refferedBy = Apexpages.currentPage().getParameters().get('refferedBy');
            string ReferredAppURL = Apexpages.currentPage().getParameters().get('ReferreURL');
            
            string address = streetNum + ',' + street + ',' + suburb + ',' + state + ',' + state + ',' + postcode;
            
            List<opportunity> oppList = new List<opportunity>();
            for(opportunity opp : [Select id, name,How_much_do_you_need__c from opportunity where Referrer_File_ID__c =: uniqueFileID Order By createdDate LIMIT 1]){
                oppList.add(opp);
            }
            
            if(cAmount != null){
                if(oppList == null || oppList.size() == 0){
                    opportunity opp = createLeadOpp(uniqueFileID, lendingPurpose, 'Solar', suppId, 
                                                    Decimal.valueof(loanTerm), sCompName,sLogoURL, scompEmail,scompPhone,sFirstName,sLastName, sEmail,sPhone,
                                                    cFName,cLName,cEmail,cPhone, integer.valueOf(cAmount),  address, streetNum, street, streetTyp, suburb, state, 
                                                    postcode, systemTyp, systemCapacity, QuarterlyEnergyBill, batteryCapacity, refferedBy, ReferredAppURL);
                    
                    List<Quote> quoteList = [SELECT Id,Quote_Group_Label__c, Lead__c, Interest_Rate__c, Actual_Comparison_Rate__c, Loan_Term__c, Monthly_Repayment__c, 
                                             Fortnightly_Repayments__c, Weekly_Repayments__c, Comparison_Rate_Warning__c, Total_loan_amount__c,
                                             Product__r.Minimum_Loan_Term_Years__c, Product__r.Maximum_Loan_Term_Years__c, Monthly_Account_Keeping_Fees__c
                                             FROM Quote WHERE OpportunityId =: opp.Id];
                    
                    string url = system.label.baseURl + '?id='+ opp.Id + '&master=' + quoteList[0].Quote_Group_Label__c;
                    return url;
                }else{  
                    List<Quote> quoteList = [SELECT Id,Quote_Group_Label__c, Lead__c, Interest_Rate__c, Actual_Comparison_Rate__c, Loan_Term__c, Monthly_Repayment__c, 
                                             Fortnightly_Repayments__c, Weekly_Repayments__c, Comparison_Rate_Warning__c, Total_loan_amount__c,
                                             Product__r.Minimum_Loan_Term_Years__c, Product__r.Maximum_Loan_Term_Years__c, Monthly_Account_Keeping_Fees__c
                                             FROM Quote WHERE OpportunityId =: oppList[0].id];
                    if(oppList[0].How_much_do_you_need__c != Decimal.valueof(cAmount)){
                        updateQuotes(Decimal.valueof(cAmount),string.valueOf(oppList[0].id), true);
                        
                        string url = system.label.baseURl + '?id='+ oppList[0].id + '&master=' + quoteList[0].Quote_Group_Label__c;
                        return url;
                    }
                    else{
                        string url = system.label.baseURl + '?id='+ oppList[0].id + '&master=' + quoteList[0].Quote_Group_Label__c;
                        return url;
                    }
                }              
                
            }else{
                return '';
            }
        }catch(Exception e){
            UtilityClass.createException('','openSolarController', 'insertData', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return '';
        }
    }
    
    public static opportunity createLeadOpp(String uniqueFileID, String lendingPurpose, String productType, String supplierId, 
                                            Decimal loanTerm, String sName, String sLogoURL, String sEmail, String sPhone, String spcFName, 
                                            String spcLName, String spcEmail, String spcPhone, String cFName, String cLName, 
                                            String cEmail, String cPhone, Integer cAmount, String InstallationAddress,
                                            String streetNumber, String street, String streetType, String Suburb, String State,
                                            String postcode, String systemType, String systemSize, String QuarterlyEnergyBill, 
                                            String batteryCapacity, String referredBy, string ReferredAppURL){
                                                
                                                try{                                         
                                                    if( String.isBlank(cLName) ){
                                                        cLName = uniqueFileID;
                                                    }                                     
                                                    String jsonOppStr = createLeadAndQuotes(productType, cFName, cLName, cEmail, cAmount, '', (''+ loanTerm), '');
                                                    Map<String, Object> objMap = (Map<String, Object>)JSON.deserializeUntyped(jsonOppStr);                                         
                                                    system.debug('-->>'+jsonOppStr);		
                                                    
                                                    String oppId = (String)objMap.get('recordId');
                                                    
                                                    Decimal lowestRate;
                                                    Decimal comparsionRate;
                                                    Decimal minRepayment;
                                                    Decimal minTerm = 0;
                                                    Decimal maxTerm = 0;
                                                    Decimal fortRepayment;
                                                    Decimal weeklyRepayment;
                                                    String comWarning = '';
                                                    Boolean isDefault = true;
                                                    
                                                    system.debug('--oppId--'+oppId);                                         
                                                    List<Quote> quoteList = [SELECT Id,Quote_Group_Label__c, Lead__c, Interest_Rate__c, Actual_Comparison_Rate__c, Loan_Term__c, Monthly_Repayment__c, 
                                                                             Fortnightly_Repayments__c, Weekly_Repayments__c, Comparison_Rate_Warning__c, Total_loan_amount__c,
                                                                             Product__r.Minimum_Loan_Term_Years__c, Product__r.Maximum_Loan_Term_Years__c, Monthly_Account_Keeping_Fees__c
                                                                             FROM Quote WHERE OpportunityId =: oppId];
                                                    
                                                    String quoteRepayment = ' {';
                                                    for(Quote qt : quoteList){
                                                        if(isDefault){
                                                            lowestRate = qt.Interest_Rate__c;
                                                            comparsionRate = qt.Actual_Comparison_Rate__c;
                                                            minRepayment = qt.Monthly_Repayment__c;
                                                            fortRepayment = qt.Fortnightly_Repayments__c;
                                                            weeklyRepayment = qt.Weekly_Repayments__c;
                                                            //loanterm  = qt.Loan_Term__c;
                                                            isDefault = FALSE;
                                                        }
                                                        if(lowestRate > qt.Interest_Rate__c){
                                                            lowestRate = qt.Interest_Rate__c;
                                                            comparsionRate= qt.Actual_Comparison_Rate__c;
                                                        }
                                                        if(qt.Monthly_Repayment__c < minRepayment){
                                                            //loanterm  = qt.Loan_Term__c;
                                                            minRepayment = qt.Monthly_Repayment__c;
                                                            fortRepayment = qt.Fortnightly_Repayments__c;
                                                            weeklyRepayment = qt.Weekly_Repayments__c;
                                                            comWarning = String.isBlank(qt.Comparison_Rate_Warning__c) ? '' : qt.Comparison_Rate_Warning__c;
                                                        }
                                                        
                                                        if(objMap.get('quoteId').equals(qt.Id)){
                                                            minTerm = qt.Product__r.Minimum_Loan_Term_Years__c;
                                                            maxTerm = qt.Product__r.Maximum_Loan_Term_Years__c;
                                                            for(Decimal yr = minTerm; yr<= maxTerm; yr++){
                                                                Decimal repayment = Math.ceil(((((qt.Interest_Rate__c/1200) * qt.Total_loan_amount__c) * (Math.pow((double)(1 + (qt.Interest_Rate__c/1200)),(double)(yr*12)))) / (Math.pow((double)(1 + (qt.Interest_Rate__c/1200)),(double)(yr*12)) - 1))+ qt.Monthly_Account_Keeping_Fees__c);
                                                                quoteRepayment += '"' + yr + 'yrMonthlyPayment":' + repayment + ',';
                                                            }
                                                            
                                                        }
                                                    }
                                                    quoteRepayment = quoteRepayment.removeEnd(',');
                                                    quoteRepayment += '}';
                                                    
                                                    if(!quoteList.isEmpty()){
                                                        Supplier__c supp = New Supplier__c(Name = sName, Lead__c = quoteList[0].Lead__c);
                                                        insert supp;
                                                    }
                                                    
                                                    string openSolarId = system.Label.open_Solar_Acc_Id; 
                                                    string solarProofId = system.Label.Solar_Proof_Id;
                                                    string PyloanId = system.Label.Pyloan_Agg_Id;
                                                    string SolarPlus = system.Label.Solar_Plus_Agg_Id;
                                                    Account accAggr = new Account();
                                                    
                                                    if(!Test.isRunningTest()){
                                                        string Accid = '';                                                                                                                
                                                        if(referredBy == 'Open Solar'){
                                                            Accid = openSolarId;
                                                        }
                                                        else if(referredBy == 'Solar Proof'){
                                                            Accid = solarProofId; 
                                                        }
                                                        else if(referredBy == 'Pyloan'){
                                                            Accid = PyloanId;
                                                        }
                                                        else if(referredBy == 'Solar Plus'){
                                                            Accid = SolarPlus;
                                                        }
                                                        
                                                        if(Accid != ''){
                                                           accAggr = [select id,BackgroundImage__c,CustomLoanOptionsPageMessage__c, name from Account where id =: Accid];    
                                                        }                                                        
                                                    }
                                                    else{
                                                        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Referrer_Business').getRecordTypeId();
                                                        accAggr.name = 'test';
                                                        accAggr.Custom_Loan_Options_Landing_Page__c = true;
                                                        accAggr.Custom_Loan_Options_Page_Type__c = 'Co-branded standard solar page';
                                                        accAggr.Open_Solar_Supplier_ID__c = 'suppId234';
                                                        accAggr.Phone = '0400000000';                
                                                        accAggr.Supplier_Logo_URL_For_Site__c = 'www.google.com';                        
                                                        accAggr.RecordTypeId = accRTId;
                                                        accAggr.Logo_Image_source__c = 'Open Solar';
                                                        upsert accAggr;
                                                    } 
                                                    
                                                    Opportunity opp = New Opportunity();
                                                    opp.Id = oppId;
                                                    opp.Referrer_File_ID__c = uniqueFileID;
                                                    opp.referred_by_aggregator__c = accAggr.id;
                                                    opp.installationAddressLineOne__c = InstallationAddress;
                                                    opp.What_type_of_system_are_you_after__c = systemType;
                                                    opp.size__c = systemSize;
                                                    opp.quarterlyBill__c = QuarterlyEnergyBill;
                                                    opp.Battery_capacity__c = batteryCapacity;
                                                    opp.referred_Application_URL__c = ReferredAppURL;
                                                    system.debug('--1--');	                                         
                                                    Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Referrer_Business').getRecordTypeId();
                                                    id conRefId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referrer').getRecordTypeId();                                         
                                                    List<contact> conlist = new List<contact>();
                                                    List<Account> Acclist = new List<Account>();
                                                    for(Account acc : [Select id, name,CustomLoanOptionsPageMessage__c,Supplier_Logo_URL_For_Site__c,BackgroundImage__c,LogoImage__c,Custom_Loan_Options_Page_Type__c,Custom_Loan_Options_Landing_Page__c from Account where Open_Solar_Supplier_ID__c =: supplierId AND RecordTypeId =: accRTId order By createdDate ASC LIMIT 1]){
                                                        Acclist.add(acc);                                             
                                                    }
                                                    
                                                    for(contact con : [select id,AccountId, name from contact where Email =: spcEmail AND RecordTypeId=: conRefId ]){
                                                        conlist.add(con);
                                                    }  
                                                    
                                                    Acclist = (string.isBlank(supplierId) ? AccList = new List<Account>() : Acclist);
                                                    conlist = (string.isBlank(spcEmail) ? conlist = new List<contact>() : conlist);
                                                    
                                                    system.debug('--Acclist--'+Acclist);
                                                    system.debug('--conlist--'+conlist);
                                                    if(Acclist != null && Acclist.size() > 0){ 
                                                        if((!Acclist[0].Custom_Loan_Options_Landing_Page__c) || (Acclist[0].Custom_Loan_Options_Page_Type__c == null || Acclist[0].Custom_Loan_Options_Page_Type__c == '') || string.isBlank(Acclist[0].LogoImage__c) || string.isBlank(Acclist[0].BackgroundImage__c) ){
                                                            Acclist[0].Custom_Loan_Options_Landing_Page__c = true;
                                                            AccList[0].Logo_Image_source__c = 'Open Solar';
                                                            Acclist[0].Custom_Loan_Options_Page_Type__c = 'Co-branded standard solar page';                
                                                            Acclist[0].Supplier_Logo_URL_For_Site__c = (string.isBlank(Acclist[0].Supplier_Logo_URL_For_Site__c) ? sLogoURL : Acclist[0].Supplier_Logo_URL_For_Site__c);
                                                            Acclist[0].BackgroundImage__c = (string.isBlank(Acclist[0].BackgroundImage__c) ? accAggr.BackgroundImage__c : Acclist[0].BackgroundImage__c);
                                                            Acclist[0].CustomLoanOptionsPageMessage__c = (string.isBlank(Acclist[0].CustomLoanOptionsPageMessage__c) ? accAggr.CustomLoanOptionsPageMessage__c : Acclist[0].CustomLoanOptionsPageMessage__c);
                                                            update Acclist[0];
                                                        }
                                                        
                                                        system.debug('--2--');
                                                        opp.Referred_by_Company__c = Acclist[0].id;
                                                        if(conlist != null && conlist.size() > 0){
                                                            system.debug('--3--');
                                                            if(conlist[0].AccountId == Acclist[0].id){
                                                                system.debug('--4--');
                                                                opp.FinServ__ReferredByContact__c = conlist[0].id;
                                                            }                                           
                                                        }
                                                        else{
                                                            system.debug('--5--');
                                                            Contact con = New Contact();
                                                            con.FirstName = spcFName;                            
                                                            con.LastName = spcLName;                                 
                                                            con.Email = spcEmail;                                 
                                                            con.Phone = spcPhone;
                                                            con.AccountId = Acclist[0].id;
                                                            con.RecordTypeId = conRefId; 
                                                            insert con;
                                                            referrerWelcomEmail(con);
                                                            opp.FinServ__ReferredByContact__c = con.id;
                                                        }
                                                    }
                                                    else{
                                                        system.debug('--6--');
                                                        if(conlist != null && conlist.size() > 0){
                                                            system.debug('--7--');
                                                            List<contact> conListDuplicates = new List<contact>();
                                                            for(Contact con : [select id, name,Account.name from contact where Email =: spcEmail AND Id !=: conlist[0].id AND RecordTypeId =:conRefId ]){
                                                                conListDuplicates.add(con);
                                                            }
                                                            if(conListDuplicates != null && conListDuplicates.size() > 0){
                                                                system.debug('--8--');
                                                                sendDuplicateEmail(conListDuplicates, sName, sEmail);
                                                            }
                                                            opp.FinServ__ReferredByContact__c = conlist[0].id;
                                                            opp.Referred_by_Company__c = conlist[0].AccountId;                                
                                                        }
                                                    }
                                                    
                                                    if((Acclist == null || Acclist.size() == 0) && (conlist == null || conlist.size() == 0) ){
                                                        system.debug('-9--');
                                                        List<Account> isAccount = new List<Account>();
                                                        List<Account> isWebsite = new List<Account>();
                                                        for(Account acc : [Select id, name from Account Where Name =: sName AND Referrer_Business_Type__c != 'Aggregator']){
                                                            isAccount.add(acc);
                                                        }            
                                                        if(isAccount != null &&  isAccount.size() > 0){
                                                            system.debug('--10--');
                                                            opp.Referred_by_Company__c = isAccount[0].id;  
                                                        }
                                                        else{ 
                                                            system.debug('--11--');
                                                            string email = '';
                                                            if(!string.isBlank(spcEmail)){
                                                                email = spcEmail.split('@')[1];
                                                                
                                                                for(Account acc : [select id, name from Account where Website LIKE : '%'+email+'%' AND RecordTypeId =: accRTId]){
                                                                    system.debug('--12--');
                                                                    isWebsite.add(acc);
                                                                } 
                                                                if(isWebsite != null || isWebsite.size() > 0){
                                                                    opp.Referred_by_Company__c = isWebsite[0].id; 
                                                                    system.debug('--13--');
                                                                }
                                                            }
                                                        }
                                                        
                                                        if((isAccount == null || isAccount.size() == 0) && (isWebsite == null || isWebsite.size() == 0) ){
                                                            system.debug('--14--');
                                                            Account acc = New Account();
                                                            acc.Name = sName;
                                                            acc.Custom_Loan_Options_Landing_Page__c = true;
                                                            acc.Custom_Loan_Options_Page_Type__c = 'Co-branded standard solar page';
                                                            acc.Open_Solar_Supplier_ID__c = supplierId;
                                                            acc.Phone = sPhone; 
                                                            acc.Supplier_Logo_URL_For_Site__c = sLogoURL;
                                                            acc.BackgroundImage__c = accAggr.BackgroundImage__c;
                                                            acc.CustomLoanOptionsPageMessage__c = accAggr.CustomLoanOptionsPageMessage__c; 
                                                            acc.Referred_By__c = String.isBlank(referredBy) ? '' : referredBy;
                                                            acc.RecordTypeId = accRTId;
                                                            acc.Logo_Image_source__c = 'Open Solar';
                                                            insert acc; 
                                                            
                                                            if(!string.isBlank(spcLName)){
                                                                Contact con = New Contact();
                                                                con.FirstName = spcFName;                            
                                                                con.LastName = spcLName;                                 
                                                                con.Email = spcEmail;                                 
                                                                con.Phone = spcPhone;
                                                                con.AccountId = acc.id;
                                                                con.RecordTypeId = conRefId; 
                                                                insert con;     
                                                                referrerWelcomEmail(con);
                                                            	opp.FinServ__ReferredByContact__c = con.id;
                                                            }                                                                                                                        
                                                                                                                        
                                                            opp.Referred_by_Company__c = acc.id;
                                                        }
                                                    }                                         
                                                    
                                                    update opp;
                                                    contact con = new contact();
                                                    if(opp.FinServ__ReferredByContact__c != null){
                                                        con = [select id, name, Email from contact where Id =: opp.FinServ__ReferredByContact__c LIMIT 1];
                                                    }
                                                    String leadId = (String)objMap.get('leadId');
                                                    if(con != null){
                                                        MyReferrerController.sendApplication(opp.Id, leadId, con.id, new list<string>{con.Email}, 'Quotation_from Referrer_ReferrerPortal', true);      
                                                    }            
                                                    
                                                    return opp;
                                                }catch(Exception e){
                                                    system.debug('->>>>Exception__>>>'+e.getMessage() + '-'+e.getLineNumber());
                                                    UtilityClass.createException('','openSolarController', 'createLeadOpp', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                                                                 e.getTypeName(), ''+e.getCause());
                                                    return null;           
                                                }
                                            }
    
    public static void sendDuplicateEmail(List<Contact> duplicateContacts, String supplierName, String supplierContactEmail) {
        try{
            system.debug('---23---');
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            String subject = 'Duplicate referrer record detected';
            String body = 'Hi team,<br/><br/>' +
                'A duplicate referrer record has been detected when receiving a referral from ' +
                '‘Open Solar’.<br/><br/>' +
                'Duplicate record information<br/>' +
                'Referrer: ' + supplierContactEmail + '<br/>' +
                'Referrer Account: ' + duplicateContacts[0].Account.name + '<br/><br/>' +
                'Please clean up the duplicates and consolidate records onto the correct account.<br/><br/>' +
                'Chris';
            OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address =: UtilityClass.adminEmail];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
            sendTo.add(UtilityClass.adminEmail);
            if(owea.size() > 0){
                mail.setorgWideEmailAddressId(Owea.get(0).Id);
            }
            mail.setToAddresses(sendTo);
            mail.setSubject(subject);
            mail.setHtmlBody(body);
            mails.add(mail);
            if(!Test.isRunningTest()){
                Messaging.sendEmail(mails);   
            }            
        }catch(Exception e){
            UtilityClass.createException('','openSolarController', 'sendDuplicateEmail', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
        }
    }
    
    
    public static void referrerWelcomEmail(contact con){
        try{
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            EmailTemplate emailTemplate = [SELECT Id,Subject, Body FROM EmailTemplate WHERE DeveloperName = 'Welcome_For_Referrer' ];
            String recTyname = Schema.SObjectType.contact.getRecordTypeInfosById().get(con.RecordTypeId).getDeveloperName();
            SYstem.debug('recordTY'+recTyname);
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            email.setTemplateId(emailTemplate.id);
            email.setUseSignature(false);
            email.setTargetObjectId(con.Id);
            email.setTreatTargetObjectAsRecipient(false);//personalapplications@parkerlane.com.au
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: UtilityClass.adminEmail];
            if(owea != null){
                if ( owea.size() > 0 ) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
            }
            email.setReplyTo('personalapplications@parkerlane.com.au');
            email.saveAsActivity = true;
            string[] to = new string[] {con.email};  
                email.setToAddresses(to);
            mails.add(email);
            
            if(mails != null && mails.size() > 0){
                Messaging.sendEmail(mails);
            }
        }catch(Exception e){
            UtilityClass.createException('','openSolarController', 'referrerWelcomEmail', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
        }
    }
    
    
    public static void updateQuotes(Decimal cAmount, string oppId, Boolean isOpenSolar) {
        if(isOpenSolar == null || isOpenSolar == false){
            isOpenSolar = false; 
        }
        String jsonStr = '';
        String comWarning = '';
        Decimal lowestRate = 100;
        Decimal comparsionRate;
        Decimal minRepayment;
        Decimal minTerm = 0;
        Decimal maxTerm = 0;
        Map<String, Decimal> freqMap = New Map<String, Decimal>{'Monthly' => 1,'Weekly'=> (52.0/12.0),'Fortnightly'=> 26.0/12.0,'Annual'=> 1/12.0};
            String quoteRepayment = ' {';
        try{
            decimal minAmount,maxAmount;
            minAmount = cAmount;
            maxAmount = cAmount;
            
            opportunity opp = [Select id,How_much_do_you_need__c,Purpose__c, FinServ__ReferredByContact__r.AccountId from opportunity where id =: OppId];
            
            Map<Id,Product2> productsMap = New Map<Id,Product2>([SELECT Id, IsActive, Actual_Comparison_Rate__c, Commission_Amount__c,Brokerage_Amount__c,
                                                                 Comparison_Rate_Disclaimer__c, Comparison_Rate_Warning__c, Eligibility__c, Acceptable_Loan_Purpose__c,
                                                                 Features__c, Interest_Rate__c, Interest_Rate_Type__c, Lender__c, Loan_Amount__c, Is_Feature_Product__c,
                                                                 Loan_Term__c, Name, Security__c, Min_Loan_Term__c, Max_Loan_Term__c, Product_Type__c, Default_Loan_Term_Months__c,
                                                                 Interest_Rate_Based_On__c,Maximum_Loan_Amount__c,Minimum_Loan_Amount__c,Minimum_Loan_Term_Years__c, Maximum_Loan_Term_Years__c,
                                                                 (SELECT ID, Active__c, Amount__c,Description__c, Fee_From__c, Fee_Type__c, Frequency__c,
                                                                  Notes__c, Override_allowed__c, Product__c, Product_Loan_Fees__c, Quote__c FROM Loan_Fees__r),
                                                                 (SELECT id,From_amount__c,Interest_rate__c,To_amount__c,Comparison_rate__c,Product__c FROM Loan_Rates__r)
                                                                 FROM Product2 WHERE isActive = TRUE AND Acceptable_Loan_Purpose__c INCLUDES (:opp.Purpose__c) AND Maximum_Loan_Amount__c >=: maxAmount 
                                                                 AND Minimum_Loan_Amount__c <=: minAmount ORDER BY Product_Order__c ASC limit 20]);
            system.debug('products are:'+productsMap.size());
            
            
            Integer j=1;
            
            for(Product2 pr: productsMap.values()){
                
                
                if(j>3)break;
                else if(pr.Maximum_Loan_Amount__c >= cAmount &&  pr.Minimum_Loan_Amount__c <= cAmount ){
                    
                    if(pr.Interest_Rate_Based_On__c =='Tiered Rate' && pr.Loan_Rates__r.size()>0 ){
                        for(Loan_Rate__c  lr: pr.Loan_Rates__r){
                            if(lr.From_amount__c <= cAmount && lr.To_amount__c >= cAmount){
                                pr.Actual_Comparison_Rate__c = lr.Comparison_rate__c;
                                pr.Interest_Rate__c = lr.Interest_rate__c;
                                break;
                            }
                        }
                    } 
                    if(lowestRate > pr.Interest_Rate__c){
                        lowestRate = pr.Interest_Rate__c;
                        minTerm = pr.Minimum_Loan_Term_Years__c;
                        maxTerm = pr.Maximum_Loan_Term_Years__c;
                        comparsionRate= pr.Actual_Comparison_Rate__c;
                        comWarning = String.isBlank(pr.Comparison_Rate_Warning__c) ? '' : comWarning;
                    }
                    j++;
                    Decimal monthlyAccKFees = 0;
                    Decimal totalFees = 0;
                    for(Loan_Fees__c fee : pr.Loan_Fees__r){
                        if(('Account Keeping').equalsIgnoreCase(fee.Fee_Type__c)){
                            monthlyAccKFees += fee.Amount__c * (freqMap.containsKey(fee.Frequency__c) ? freqMap.get(fee.Frequency__c) : 0);
                        }else{
                            totalFees += fee.Amount__c;
                        }        
                    }
                    monthlyAccKFees = monthlyAccKFees.setScale(2);
                    Decimal brokerage = pr.Brokerage_Amount__c == NULL ? 0: pr.Brokerage_Amount__c;
                    Decimal totalLoanAmount = (cAmount + totalFees + brokerage).setScale(2);
                    System.debug('>>>>minTerm    ' + minTerm +'>>>>maxTerm  '+ maxTerm);
                    System.debug('>>>>qt.Interest_Rate__c' + pr.Interest_Rate__c);
                    System.debug('>>>>qt.Total_loan_amount__c' + totalLoanAmount);
                    System.debug('>>>>qt.Monthly_Account_Keeping_Fees__c' + monthlyAccKFees);
                    quoteRepayment = ' {';
                    for(Decimal yr = minTerm; yr<= maxTerm; yr++){
                        Decimal repayment = Math.ceil(((((pr.Interest_Rate__c/1200) * totalLoanAmount) * (Math.pow((double)(1 + (pr.Interest_Rate__c/1200)),(double)(yr*12)))) / (Math.pow((double)(1 + (pr.Interest_Rate__c/1200)),(double)(yr*12)) - 1))+ monthlyAccKFees);
                        quoteRepayment += '"' + yr + 'yrMonthlyPayment":' + repayment + ',';
                    }
                    quoteRepayment = quoteRepayment.removeEnd(',');
                    quoteRepayment += '}';
                }
            } 
            
            
            
            
            String appURL = system.Label.baseUrl + '?id=' + oppId + '&master=Website-1';
            
            jsonStr = '{"Status" : "Success","Message" : "Opportunity Updated successfully with ' + oppId;
            jsonStr += ' record Id","AppURL" : "' + appURL + '",';
            jsonStr += ' "sfdcAccId" : "' + opp.FinServ__ReferredByContact__r.AccountId + '",';
            jsonStr += ' "recordId" : "' + oppId + '",';
            //jsonStr += ' "quoteId" : "' + featuredQuote + '",';
            jsonStr += ' "quoteRepayment":' + quoteRepayment + ',';
            jsonStr += ' "lowestRate" : "' + lowestRate + '",';
            jsonStr += ' "comparsionRate" : "' + comparsionRate + '",';
            jsonStr += ' "minTerm" : "' + minTerm + '",';
            jsonStr += ' "maxTerm" : "' + maxTerm + '",';
            jsonStr += ' "comWarning" : "' + comWarning + '"}';
            
            //addeed by tazeem 
            opp.How_much_do_you_need__c = cAmount;
            opp.Current_Application_Sections__c = 'Loan Recommendation';
            update opp;
            //addeed by tazeem 
            
        }catch(exception e){
            UtilityClass.createException(OppId,'MyReferrerCsontroller', 'updateQuotes', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            
            jsonStr = e.getMessage() + '    '+  e.getStackTraceString()+ '    '+e.getLineNumber()+ '    '+e.getCause();
        }
        updateReferrerQuote(cAmount, oppId);
        if(!isOpenSolar){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(jsonStr);
            return;
        }
    }
    
    @future
    public static void updateReferrerQuote(Decimal cAmount, string oppId){
        
        String comWarning = '';
        Decimal lowestRate;
        Decimal comparsionRate;
        Decimal minRepayment;
        Decimal minTerm = 0;
        Decimal maxTerm = 0;
        String quoteRepayment = ' {';
        try{
            boolean flg = true;
            decimal minAmount,maxAmount;
            list<String> groupnames = new list<string>();
            if(flg){
                minAmount = cAmount;
                maxAmount = cAmount;
                flg= false;
            }
            if(minAmount > cAmount){
                minAmount = cAmount;
            }
            if(maxAmount < cAmount){
                maxAmount = cAmount;
            }
            //groupnames.add(qdw.GroupName);
            
            opportunity oppList = [Select id,Purpose__c from opportunity where id =: OppId];
            
            Map<Id,Product2> productsMap = New Map<Id,Product2>([SELECT Id, IsActive, Actual_Comparison_Rate__c, Commission_Amount__c,Brokerage_Amount__c,
                                                                 Comparison_Rate_Disclaimer__c, Comparison_Rate_Warning__c, Eligibility__c, Acceptable_Loan_Purpose__c,
                                                                 Features__c, Interest_Rate__c, Interest_Rate_Type__c, Lender__c, Loan_Amount__c, Is_Feature_Product__c,
                                                                 Loan_Term__c, Name, Security__c, Min_Loan_Term__c, Max_Loan_Term__c, Product_Type__c, Default_Loan_Term_Months__c,
                                                                 Interest_Rate_Based_On__c,Maximum_Loan_Amount__c,Minimum_Loan_Amount__c,Minimum_Loan_Term_Years__c, Maximum_Loan_Term_Years__c,
                                                                 (SELECT ID, Active__c, Amount__c,Description__c, Fee_From__c, Fee_Type__c, Frequency__c,
                                                                  Notes__c, Override_allowed__c, Product__c, Product_Loan_Fees__c, Quote__c FROM Loan_Fees__r),
                                                                 (SELECT id,From_amount__c,Interest_rate__c,To_amount__c,Comparison_rate__c,Product__c FROM Loan_Rates__r)
                                                                 FROM Product2 WHERE isActive = TRUE AND Acceptable_Loan_Purpose__c INCLUDES (:oppList.Purpose__c) AND Maximum_Loan_Amount__c >=: maxAmount 
                                                                 AND Minimum_Loan_Amount__c <=: minAmount ORDER BY Product_Order__c ASC limit 20]);
            system.debug('products are:'+productsMap.size());
            
            list<Quote> quoteTodelete = new list<Quote>();
            string qtName = '';  
            list<quote>  qtlist = [select id,name,Customer_Amount__c,Actual_Comparison_Rate__c,Quote_Group_Label__c,Gruop_Name__c,Product__c from quote where OpportunityId =: oppId];
            for(Quote qt : qtlist){
                qtName = qt.Quote_Group_Label__c;
                quoteTodelete.add(qt);
            }
            if(quoteTodelete.size()>0){
                delete quoteTodelete;
            }
            
            Map<String, List<Quote>> quotesListMap = New Map<String, List<Quote>>();
            string nme ='';
            /*for(integer i=0; i< quoteDetailWrpList.size(); i++){*/
            
            Integer j=1;
            list<Quote> quotesList = new list<Quote>();
            for(Product2 pr: productsMap.values()){
                if(j>3)break;
                else if(pr.Maximum_Loan_Amount__c >= cAmount &&  pr.Minimum_Loan_Amount__c <= cAmount ){
                    Quote quote = New Quote();
                    //quote.Lead__c = oppList.Lead__c;
                    quote.OpportunityId = oppId;
                    quote.Actual_Comparison_Rate__c = pr.Actual_Comparison_Rate__c;
                    quote.Name = pr.Name;
                    quote.Interest_Rate__c = pr.Interest_Rate__c;
                    quote.Loan_Term__c = pr.Max_Loan_Term__c;
                    quote.Product__c = pr.Id;
                    quote.Purpose__c = oppList.Purpose__c;
                    quote.Is_Featured__c = pr.Is_Feature_Product__c;
                    quote.Customer_Amount__c = cAmount;
                    quote.Gruop_Name__c = qtName;
                    quote.Quote_Group_Label__c = qtName;
                    quote.Commission_Amount__c = pr.Commission_Amount__c;
                    quote.Brokerage_Amount__c = pr.Brokerage_Amount__c;
                    quote.Lender__c = pr.Lender__c;
                    if(pr.Interest_Rate_Based_On__c =='Tiered Rate' && pr.Loan_Rates__r.size()>0 ){
                        for(Loan_Rate__c  lr: pr.Loan_Rates__r){
                            if(lr.From_amount__c <= cAmount && lr.To_amount__c >= cAmount){
                                quote.Actual_Comparison_Rate__c = lr.Comparison_rate__c;
                                quote.Interest_Rate__c = lr.Interest_rate__c;
                                break;
                            }
                        }
                    }
                    quotesList = quotesListMap.get(quote.Gruop_Name__c);
                    if(quotesList == NULL)quotesList = New list<Quote>();
                    quotesList.add(quote);
                    quotesListMap.put(quote.Gruop_Name__c, quotesList);                           
                    j++;
                    //quotesList.add(quote);
                }
            } 
            
            List<Quote> quotesListToInsert = New List<Quote>();
            for(String qName: quotesListMap.keySet()){
                Boolean isFeature = false;
                String lowRatePrId = '';
                lowestRate = 100;
                for(Quote qt: quotesListMap.get(qName)){
                    if(qt.Is_Featured__c)
                        isFeature = true;
                    if(lowestRate > qt.Interest_Rate__c){
                        lowestRate = qt.Interest_Rate__c;
                        lowRatePrId = qt.Product__c;
                    }
                }
                
                for(Quote qt: quotesListMap.get(qName)){
                    if(!isFeature && lowRatePrId.equals(qt.Product__c)){
                        qt.Is_Featured__c = true; // NEED TO UNCOMMENT IN UAT
                        
                    }
                    
                    quotesListToInsert.add(qt);
                }
            }
            insert quotesListToInsert;
            
            String featuredQuote;
            list<Loan_Fees__c> loanFees = new list<Loan_Fees__c>();
            Id loanfeeRT = Schema.SObjectType.Loan_Fees__c.getRecordTypeInfosByName().get('Quote Loan Fees').getRecordTypeId();
            for(Quote qt : quotesListToInsert){
                Product2 pr = productsMap.get(qt.Product__c);
                if(qt.Is_Featured__c){
                    featuredQuote = qt.Id;
                }
                for(Loan_Fees__c fees: pr.Loan_Fees__r){    
                    Loan_Fees__c fee = New Loan_Fees__c();  
                    fee.Active__c = fees.Active__c; 
                    fee.Amount__c = fees.Amount__c; 
                    fee.Description__c = fees.Description__c;   
                    fee.Fee_From__c = fees.Fee_From__c; 
                    fee.Product_Loan_Fees__c =fees.Id;  
                    fee.Fee_Type__c =fees.Fee_Type__c;  
                    fee.Frequency__c =fees.Frequency__c;    
                    fee.Notes__c =fees.Notes__c;    
                    fee.Override_allowed__c =fees.Override_allowed__c;  
                    fee.RecordTypeId = loanfeeRT;   
                    fee.Quote__c = qt.Id;   
                    loanFees.add(fee);  
                }
            }
            if(String.isBlank(featuredQuote)){
                featuredQuote = quotesListToInsert[0].Id;
            }
            insert loanFees;
            
            
        }catch(exception e){
            system.debug('-->>Exception-updateQuotes->>'+e.getMessage() + '---' + e.getLineNumber());
            UtilityClass.createException(OppId,'MyReferrerCsontroller', 'updateQuotes', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
        }
        
    }
    
    
    public static String createLeadAndQuotes(String productType, String cFName, String cLName, String cEmail, Integer cAmount, 
                                             String myPriority, String repayOverTerm, String homeOwner){
        try{
            String alreadyCust = 'You already have a quote or application under way. Please call 1300 131 711 or email personalapplications@parkerlane.com.au';
            String ownerId = '';
            String nextSection = 'Loan Recommendation';
            Map<Id,Product2> productsMap = New Map<Id,Product2>([SELECT Id, IsActive, Actual_Comparison_Rate__c, Commission_Amount__c,Brokerage_Amount__c,
                                                                 Comparison_Rate_Disclaimer__c, Comparison_Rate_Warning__c, Eligibility__c, Acceptable_Loan_Purpose__c,
                                                                 Features__c, Interest_Rate__c, Interest_Rate_Type__c, Lender__c, Loan_Amount__c, Is_Feature_Product__c,
                                                                 Loan_Term__c, Name, Security__c, Min_Loan_Term__c, Max_Loan_Term__c, Product_Type__c, Default_Loan_Term_Months__c,
                                                                 Interest_Rate_Based_On__c,
                                                                 (SELECT ID, Active__c, Amount__c,Description__c, Fee_From__c, Fee_Type__c, Frequency__c,
                                                                  Notes__c, Override_allowed__c, Product__c, Product_Loan_Fees__c, Quote__c FROM Loan_Fees__r),
                                                                 (SELECT id,From_amount__c,Interest_rate__c,To_amount__c,Comparison_rate__c,Product__c FROM Loan_Rates__r)
                                                                 FROM Product2 WHERE isActive = TRUE AND Acceptable_Loan_Purpose__c INCLUDES (:productType) AND Maximum_Loan_Amount__c >=: cAmount 
                                                                 AND Minimum_Loan_Amount__c <=: cAmount ORDER BY Product_Order__c ASC limit 3]);
            
            List<Lead> leadList = [SELECT Id, FirstName, LastName, Email, Status, FinServ__ReferredByContact__c, FinServ__RelatedAccount__c, OwnerId, 
                                   Point_of_Origin__c, Phone, Referred_by_Company__c, LeadSource, FinServ__ReferredByContact__r.Name,
                                   FinServ__ReferredByContact__r.Account.Referrer_Business_Type__c, leadAddress__c, installationSuburb__c,
                                   installationCountry__c, installationPostcode__c, installationState__c 
                                   FROM Lead WHERE Email =: cEmail LIMIT 1]; 
            Lead lead = New Lead();
            if(leadList.isEmpty()){ 
                lead = New Lead(FirstName = cFName, LastName = cLName, Email = cEmail, Customer_Amount__c = cAmount, 
                                Purpose__c = productType, RecordTypeId = leadRecordTypeMap.get(productType), LeadSource='Website', 
                                Lead_Type__c = 'New Customer', Point_of_Origin__c = 'Website Quote / Application');
                
            }else{ 
                lead = leadList.get(0);
                ownerId = leadList.get(0).OwnerId;
                List<Quote> existingQuotesList = [SELECT Id FROM Quote WHERE Lead__c =: lead.Id AND Opportunity.Purpose__c =:productType AND 
                                                  Opportunity.StageName != 'Settled (closed won)' AND Opportunity.StageName != 'Closed Lost'];
                if(!existingQuotesList.isEmpty()){
                    //return '{\"status\":\"Error\","message\":\"'+ alreadyCust +'\"}';
                }
            }
            lead.Status = 'Online Quote';
            upsert lead;
            
            List<Account> existingPAccList = [SELECT Id FROM Account WHERE PersonContact.Email =: lead.Email];
            if(!existingPAccList.isEmpty()){
               // return '{\"status\":\"Error\","message\":\"'+ alreadyCust +'\"}';
            }
            

            List<Account> solarQuoteAcc  = [SELECT Id FROM Account WHERE Name = 'SolarQuotes.com.au' LIMIT 1];
            Id refCompanyId = (lead.Referred_by_Company__c==NULL && ('SolarQuotes API').EqualsIgnoreCase(lead.Point_of_Origin__c) 
                               && !solarQuoteAcc.isEmpty()) ? solarQuoteAcc[0].Id : lead.Referred_by_Company__c;
            String leadSource = lead.LeadSource;
                                   
            if(('SolarQuotes').equalsIgnoreCase(lead.FinServ__ReferredByContact__r.Name)){
                leadSource = 'SolarQuotes';
            }else if(('solar installer').equalsIgnoreCase(lead.FinServ__ReferredByContact__r.Account.Referrer_Business_Type__c) ||
                    ('solar retailer').equalsIgnoreCase(lead.FinServ__ReferredByContact__r.Account.Referrer_Business_Type__c)){
                leadSource = 'Solar Installer / Retailer';
            }else if(('home improvement').equalsIgnoreCase(lead.FinServ__ReferredByContact__r.Account.Referrer_Business_Type__c)){
                leadSource = 'Home Improvement Installer / Retailer';
            }else if(('builder').equalsIgnoreCase(lead.FinServ__ReferredByContact__r.Account.Referrer_Business_Type__c)){
                leadSource = 'Builder';
            }else if(('real estate agent').equalsIgnoreCase(lead.FinServ__ReferredByContact__r.Account.Referrer_Business_Type__c)){
                leadSource = 'Real Estate Agent';
            }
            
            Account householdAccount = new Account(Name = lead.FirstName + ' ' + lead.LastName +' Household', RecordTypeId = householdAccRTId,
                                                  Referred_by_Company__c = refCompanyId, Account_Lead_Source__c = leadSource,
                                                  FinServ__ReferredByContact__c = lead.FinServ__ReferredByContact__c);
            insert householdAccount;
            
            Account personAccount = new Account(FirstName = lead.FirstName, LastName = lead.LastName, PersonEmail = lead.Email,
                                                Relationship_with_Applicant_1__c='Client', RecordTypeId = personAccRTId,
                                                Phone = lead.Phone, Referred_by_Company__c = refCompanyId, Account_Lead_Source__c = leadSource,
                                                PersonLeadSource = leadSource, FinServ__ReferredByContact__c = lead.FinServ__ReferredByContact__c,
                                                Residential_Address__pc = lead.leadAddress__c, Suburb__pc  = lead.installationSuburb__c,
                                                FinServ__CountryOfResidence__pc = lead.installationCountry__c, Postal_Code__pc = lead.installationPostcode__c,
                                                State__pc = lead.installationState__c );
            insert personAccount;
            
            Id pConId = [SELECT Id, PersonContactId FROM Account WHERE Id =: personAccount.Id].PersonContactId;

            Opportunity opp = new Opportunity(Name = lead.FirstName + ' ' +lead.LastName + ', ' + (productType =='Solar' ? 'Green Loan' : productType),
                                              Purpose__c = productType,
                                              applicant_1__c = personAccount.Id,
                                              Contact_1__c = pConId,
                                              AccountId = householdAccount.Id,
                                              Application_Sections__c = nextSection, 
                                              Current_Application_Sections__c = nextSection, 
                                              How_much_do_you_need__c = cAmount,
                                              StageName='Quote', 
                                              FinServ__ReferredByContact__c = lead.FinServ__ReferredByContact__c,
                                              Referred_by_Company__c = refCompanyId,
                                              Point_of_Origin__c = lead.Point_of_Origin__c,
                                              CloseDate = Date.today(),
                                              Priority_is__c = myPriority,
                                              //Prefer_to_repay_over_a_term__c = repayOverTerm,
                                              Home_Owner__c = homeOwner,
                                              LeadSource = leadSource,
                                              RecordTypeId = oppRecordTypeMap.get(productType));
            if(String.isNotBlank(ownerId))
                opp.OwnerId = ownerId;
            insert opp;

            String quoteGrpName = 'Website-';
            AggregateResult[] quoteGruop = [Select Gruop_Name__c from quote where Gruop_Name__c like 'Website-%' AND  Lead__c =: lead.Id 
                                      GROUP BY Gruop_Name__c];
            if(quoteGruop.isEmpty()){
                quoteGrpName += '1';
            }else{
                quoteGrpName += (quoteGruop.size() + 1);
            }
            
            Id loanfeeRT = Schema.SObjectType.Loan_Fees__c.getRecordTypeInfosByName().get('Quote Loan Fees').getRecordTypeId();
            List<Quote> quotesList = New List<Quote>();
            List<Loan_Fees__c> loanFees = New List<Loan_Fees__c>();
            for(Product2 pr: productsMap.values()){
                Quote quote = New Quote();
                quote.Lead__c = lead.Id;
                quote.OpportunityId = opp.Id;
                quote.Actual_Comparison_Rate__c = pr.Actual_Comparison_Rate__c;
                quote.Name = pr.Name;
                quote.Interest_Rate__c = pr.Interest_Rate__c;
                quote.Loan_Term__c = pr.Max_Loan_Term__c;
                
                if(pr.Default_Loan_Term_Months__c != NULL && pr.Default_Loan_Term_Months__c > 0){   
                    quote.Loan_Term__c = pr.Default_Loan_Term_Months__c;    
                }
                if(String.isNotBlank(repayOverTerm) && repayOverTerm.isNumeric()){
                    quote.Loan_Term__c = Decimal.valueOf(repayOverTerm);
                }
                quote.Product__c = pr.Id;
                quote.Customer_Amount__c = cAmount;
                quote.Gruop_Name__c = quoteGrpName;
                quote.Quote_Group_Label__c = quoteGrpName;
                quote.Purpose__c = productType;
                quote.isSelected__c= true;
                quote.Commission_Amount__c = pr.Commission_Amount__c;
                quote.Brokerage_Amount__c = pr.Brokerage_Amount__c;
                quote.Lender__c = pr.Lender__c;

                if(pr.Interest_Rate_Based_On__c  =='Tiered Rate'){
                    for(Loan_Rate__c lr: pr.Loan_Rates__r){
                        if(lr.From_amount__c <= cAmount && lr.To_amount__c >= cAmount ){
                            quote.Actual_Comparison_Rate__c = lr.Comparison_rate__c;
                            quote.Interest_Rate__c = lr.Interest_rate__c;
                            break;
                        }
                    }
                }
                quotesList.add(quote);
            }
            insert quotesList;
            
            String featuredQuoteId = '';
            decimal lowestRate = 100;
            for(Quote qt : quotesList){
                Product2 pr = productsMap.get(qt.Product__c);
                /*if(pr.Is_Feature_Product__c){
                    featuredQuoteId = qt.Id;
                }*/
                if(lowestRate > qt.Interest_Rate__c){
                    lowestRate = qt.Interest_Rate__c;
                    featuredQuoteId = qt.id;
                }
                for(Loan_Fees__c fee: pr.Loan_Fees__r){
                    fee.Product__c = null;
                    fee.Product_Loan_Fees__c =fee.Id;
                    fee.RecordTypeId = loanfeeRT;
                    fee.Quote__c = qt.Id;
                    fee.Id = null;
                    loanFees.add(fee);
                }
            }
            insert loanFees;
            
            String path = '{\"status\":\"Success\",\"recordId\":\"'+ opp.Id +'\","leadId\":\"'+ pConId +'\","quoteId\":\"'+ featuredQuoteId +'\","quoteGrpName\":\"'+ quoteGrpName +'\",\"CurrentSection\":\"'+ nextSection +'\", \"path\": '+getPath(nextSection,nextSection, opp.RecordTypeId)+ '}';
            return path;
        }catch(exception e){
            system.debug('-->>createLeadAndQuotes-->>'+e.getMessage());
            UtilityClass.createException('New','ParkerLaneLoanController', 'createLeadAndQuotes', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                       e.getTypeName(), ''+e.getCause());
            return '[]';
        }
    }
    
    private static String getPath(String currPath, String inProgressPath, String recordTypeId){
        List<String> appSecPLList = New List<String>{'Who is applying', 'Own and Owe', 'Earn', 'Living Expenses','Goals & Objectives'};
        List<String> appSecHLHCList = New List<String>{'Who is applying', 'Own and Owe', 'Earn', 'Living Expenses', 'Preferences', 'Risk Assessment', 'Anticipated Changes to Circumstances','Goals & Objectives'};
        List<String> appSectionsList = ParkerLaneLoanController.getApplicationSections();  
        Boolean isMortgage = true;
        String pathJSON ='[';
        String status = ' slds-is-complete ';
        if(String.isNotBlank(currPath) && appSectionsList.contains(currPath) && 
           String.isNotBlank(inProgressPath) && appSectionsList.contains(inProgressPath)){
               for( String appSec : appSectionsList){
                   String statusActive='';
                   Boolean isClickable = false;
                   if((status != ' slds-is-incomplete ') && appSec !='Getting Started'){
                       isClickable = true;
                   }
                   if(!ParkerLaneLoanController.mortgageRTList.contains(recordTypeId) && !appSecPLList.contains(appSec)){
                       isMortgage = false;
                       continue;
                   }
                   if(ParkerLaneLoanController.mortgageRTList.contains(recordTypeId) && !appSecHLHCList.contains(appSec)){
                       continue;
                   }
                   
                   if(currPath.equalsIgnoreCase(appSec) && currPath.equalsIgnoreCase(inProgressPath)){
                       pathJSON += '{ \"status\": \" slds-is-current slds-is-active\", \"label\": \"'+ appSec + '\", \"isClickable\": \"'+ false +'\" },';
                       status = ' slds-is-incomplete ';
                       continue;
                   }else if(currPath.equalsIgnoreCase(appSec)){
                       pathJSON += '{ \"status\": \" slds-is-current\", \"label\": \"'+ appSec + '\", \"isClickable\": \"'+ false +'\" },';
                       continue;
                   }
                   
                   if(inProgressPath.equalsIgnoreCase(appSec)){
                       pathJSON += '{ \"status\": \" slds-is-active\", \"label\": \"'+ appSec + '\", \"isClickable\": \"'+ isClickable +'\" },';
                       status = ' slds-is-incomplete ';
                       continue;
                   }
                   
                   pathJSON += '{ \"status\": \"'+ status + statusActive + '\", \"label\": \"'+ appSec + '\", \"isClickable\": \"'+ isClickable +'\" },';
               }
               pathJSON = pathJSON.removeEnd(',');
           }
        pathJSON += '], \"isMortgage\":'+ isMortgage;

        return pathJSON;
    }
    
    
}