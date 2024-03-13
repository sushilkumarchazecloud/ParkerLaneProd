public without sharing class ReferralPageController {
    QuoteDetailWrapper newObj = new QuoteDetailWrapper();
    public static Id householdAccRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    public static Id personAccRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    public static Map<String,String> pdfData;
    
    @auraEnabled
    public static list<QuoteDetailWrapper> ret(List<QuoteDetailWrapper> qtwrapper){
        system.debug('qtwrapper'+qtwrapper);
        QuoteDetailWrapper quoteDetailWrpList2 = New QuoteDetailWrapper();
        qtwrapper.add(quoteDetailWrpList2);
        return qtwrapper;
    }
    @auraEnabled
    public static QuoteDetailWrapper ret1(){        
        return New QuoteDetailWrapper();
    }
    
    public static Map<String, Id> oppRecordTypeMap = New Map<String, Id>{
        'Solar' => Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Green Loan').getRecordTypeId(),
            'Home Improvement' => Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Home Improvement').getRecordTypeId(),
            'Debt Consolidation' => Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Debt Consolidation').getRecordTypeId()};
                
                public static Map<String, Id> leadRecordTypeMap = New Map<String, Id>{
                    'Solar' => Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Green Loan').getRecordTypeId(),
                        'Home Improvement' => Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Home Improvement').getRecordTypeId(),
                        'Debt Consolidation' => Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Debt Consolidation').getRecordTypeId()};
    
    @auraEnabled
    public static id getEmail(string referrerEmail){
        List<Contact> con = [SELECT Id, Name, Account.Name, AccountId, Account.Referrer_Business_Type__c 
                             FROM Contact WHERE Email =: referrerEmail AND Account.On_Board_Referral__c = TRUE AND  Account.RecordType.developerName = 'Referrer_Business' limit 1];
        if(!con.isEmpty()){
            return con[0].id;
        }
        return null;
    }
    
    @auraEnabled
    public static QuoteDetailWrapper submitReferral(String refEmail, String firstName, String lastName, String custEmail, String custPhone, String custAdd, String quoteType, String sendQuote, String contactId, Boolean isObtainedTheCustomer, string quoteDetailWrpList1,
                                                   String street, String postalCode, String suburb, String country, String state, String streetNumber, String streetType){
        try{
        QuoteDetailWrapper newWrp = new QuoteDetailWrapper();
        list<QuoteDetailWrapper> quoteDetailWrpList = (list<QuoteDetailWrapper>)JSON.deserialize(quoteDetailWrpList1, list<QuoteDetailWrapper>.class);
        
        pdfData = New Map<String,String>();
        
        Decimal minAmount = 0;
        Decimal maxAmount = 0;  
        String nextSection = 'Loan Recommendation';
        String description ='';
        boolean flg = true;
        for(QuoteDetailWrapper qdw:quoteDetailWrpList){
            if(flg){
                minAmount = qdw.Amount;
                maxAmount = qdw.Amount;
                flg= false;
            }
            if(minAmount > qdw.Amount){
                minAmount = qdw.Amount;
            }
            if(maxAmount < qdw.Amount){
                maxAmount = qdw.Amount;
            }
        }
        User usrManager = [SELECT Id FROM User WHERE Email = 'chris.white@chazecloud.com' AND Profile.Name='System Administrator' LIMIT 1];            
        Map<Id,Profile> guestProfileIds = new Map<id,profile>([SELECT Id,Name,UserLicenseId FROM Profile where UserLicenseId  in (SELECT Id FROM UserLicense where name ='Guest User License')]);
        
        Map<Id,Product2> productsMap = New Map<Id,Product2>(
            [SELECT Id, IsActive, Actual_Comparison_Rate__c, Acceptable_Loan_Purpose__c,  Commission_Amount__c,
             Comparison_Rate_Disclaimer__c, Comparison_Rate_Warning__c, Eligibility__c, Is_Feature_Product__c,
             Features__c, Interest_Rate__c, Interest_Rate_Type__c, Lender__c, Loan_Amount__c, Brokerage_Amount__c,Maximum_Loan_Amount__c, Minimum_Loan_Amount__c,
             Loan_Term__c, Name, Security__c, Min_Loan_Term__c, Max_Loan_Term__c, Product_Type__c,Interest_Rate_Based_On__c,
             (SELECT ID, Active__c, Amount__c,Description__c, Fee_From__c, Fee_Type__c, Frequency__c,
              Notes__c, Override_allowed__c, Product__c, Product_Loan_Fees__c, Quote__c FROM Loan_Fees__r),
             (SELECT id,From_amount__c,Interest_rate__c,To_amount__c,Comparison_rate__c,Product__c FROM Loan_Rates__r)
             FROM Product2 WHERE isActive = TRUE AND Acceptable_Loan_Purpose__c INCLUDES (:quoteType) AND Maximum_Loan_Amount__c >=: minAmount 
             AND Minimum_Loan_Amount__c <=: maxAmount ORDER BY Product_Order__c ASC limit 3]); 
        system.debug('productsMap'+productsMap);
        
        for(integer i=0; i< quoteDetailWrpList.size(); i++){
            if(productsMap.isEmpty()){
                newWrp.errorMessage = 'At least one of the amounts you entered is below the minimum or above the maximum of all our lenders. Please review the form and try again';
                return newWrp;
            }
        }
        boolean isMinError = false;
        boolean isMaxError = false;
        for(integer i=0; i< quoteDetailWrpList.size(); i++){
            quoteDetailWrpList[i].errorMessage = ''; 
            Decimal minPrAmount = 0;
            Decimal maxPrAmount = 0;  
            boolean flgPr = true;
            for(Product2 pr: productsMap.values()){ 
                if(flgPr){
                    minPrAmount = pr.Minimum_Loan_Amount__c;
                    maxPrAmount = pr.Maximum_Loan_Amount__c;
                    flgPr= false;
                }
                if(minPrAmount > pr.Minimum_Loan_Amount__c){
                    minPrAmount = pr.Minimum_Loan_Amount__c;
                }
                if(maxPrAmount < pr.Maximum_Loan_Amount__c){
                    maxPrAmount = pr.Maximum_Loan_Amount__c;
                }                    
            }
            
            if(quoteDetailWrpList[i].Amount < minPrAmount){
                isMinError = true;
                newWrp.minAmt = minPrAmount;
            }
            else if(quoteDetailWrpList[i].Amount > maxPrAmount){
                isMaxError = true;
                newWrp.maxAmt = maxPrAmount;
            }
        }
        //system.debug('errList'+errList);
        if(isMaxError && !isMinError){
            newWrp.errorMessage = 'At least one of the amounts you entered is above the maximum of all our lenders. Please review the form and try again';
            return newWrp;
            
        }
        else if(isMinError && !isMaxError){
            newWrp.errorMessage = 'At least one of the amounts you entered is below the minimum of all our lenders. Please review the form and try again';
            return newWrp;
            
        }
        else if(isMinError && isMaxError){
            newWrp.errorMessage = 'At least one of the amounts you entered is below the minimum or above the maximum of all our lenders. Please review the form and try again';
            return newWrp;
        }
        
        String conId = '';        	
        system.debug('email'+refEmail);
        List<Contact> con = new list<Contact>();
        if(contactId == null){
            con = [SELECT Id, Name, Account.Name, AccountId, Account.Referrer_Business_Type__c 
                   FROM Contact WHERE Email =: refEmail AND Account.On_Board_Referral__c = TRUE AND  Account.RecordType.developerName = 'Referrer_Business' limit 1];
        }
        else{
            con = [SELECT Id, Name, Email, Account.Name, AccountId, Account.Referrer_Business_Type__c 
                   FROM Contact WHERE id =: contactId AND Account.On_Board_Referral__c = TRUE AND  Account.RecordType.developerName = 'Referrer_Business' limit 1];
            refEmail = con[0].Email;          
        }
        
        /*if(con.isEmpty()){
//String errorMsg = '';
errorMsg = 'Error : Your email is not registered as an authorised referrer. Please check your details or call 1300 13 17 11 to become accredited.';
return errorMsg;

}else{*/
        //String errorMsg = '';
        String ownerId = '';                
        conId = con[0].Id;              
        List<Lead> leadList = [SELECT Id, FirstName, LastName, Email, Status, ReferredByContact__c, RelatedAccount__c, OwnerId, 
                               Point_of_Origin__c, Phone, LeadSource, Referred_by_Company__c
                               FROM Lead WHERE Email =: custEmail LIMIT 1];
        Lead lead = New Lead();
        system.debug('lastName'+lastName);
        if(leadList.isEmpty()){
            system.debug('lastName'+lastName);
            lead = New Lead(FirstName = firstName, LastName = lastName, Email = custEmail, leadAddress__c = custAdd, 
                            /*Customer_Amount__c = quoteAmount,*/ company = con[0].Account.Name, ReferredByContact__c = con[0].Id,
                            RelatedAccount__c = con[0].AccountId, Phone = custPhone,
                            Referred_by_Company__c= con[0].AccountId, RecordTypeId = leadRecordTypeMap.get(quoteType),
                            Point_of_Origin__c = 'Referral Page', Timeframe__c = 'Immediately', Send_the_quote_to__c = sendQuote,
                            Purpose__c = quoteType, Lead_Type__c = 'Business Referral', Status = 'Online Quote');
            if('Solar Installer'.EqualsIgnoreCase(con[0].Account.Referrer_Business_Type__c) || 'Solar Retailer'.EqualsIgnoreCase(con[0].Account.Referrer_Business_Type__c)){
                lead.LeadSource='Solar Installer / Retailer';
            }else if('Home Improvement'.EqualsIgnoreCase(con[0].Account.Referrer_Business_Type__c)){
                lead.LeadSource='Home Improvment Installer / Retailer';
            }else if('Builder Referrer'.EqualsIgnoreCase(con[0].Account.Referrer_Business_Type__c)){
                lead.LeadSource='Builder';
            }
            
        }else{
            lead.Id = leadList.get(0).Id;
            ownerId = leadList.get(0).OwnerId;
            List<Quote> existingQuotesList = [SELECT Id FROM Quote WHERE Lead__c =: lead.Id AND Opportunity.Purpose__c =:quoteType  AND 
                                              Opportunity.StageName != 'Settled (closed won)' AND Opportunity.StageName != 'Closed Lost'];
            if(!existingQuotesList.isEmpty()){
                newWrp.errorMessage = 'Oops! This customer is already in our system and can not be referred again. Please contact the team if you have any questions on 1300 13 17 11.';
                return newWrp;
            }
        }
        system.debug('lead'+lead);
        upsert lead;
        
        List<Account> existingPAccList = [SELECT Id FROM Account WHERE PersonContact.Email =: lead.Email];
        if(!existingPAccList.isEmpty()){                    
            newWrp.errorMessage = 'Oops! This customer is already in our system and can not be referred again. Please contact the team if you have any questions on 1300 13 17 11.';
            return newWrp;
        }
        
        List<Account> solarQuoteAcc  = [SELECT Id FROM Account WHERE Name = 'SolarQuotes.com.au' LIMIT 1];
        Id refCompanyId = (lead.Referred_by_Company__c==NULL && ('SolarQuotes API').EqualsIgnoreCase(lead.Point_of_Origin__c) 
                           && !solarQuoteAcc.isEmpty()) ? solarQuoteAcc[0].Id : lead.Referred_by_Company__c;
        
        Account householdAccount = new Account(Name = firstName + ' '+ lastName +' Household', RecordTypeId = householdAccRTId,
                                               Referred_by_Company__c = refCompanyId, Account_Lead_Source__c = lead.leadSource,
                                               ReferredByContact__c = lead.ReferredByContact__c);
        insert householdAccount;
        
        Account personAccount = new Account(FirstName = firstName, LastName = lastName, PersonEmail = lead.Email, Phone = custPhone,
                                            Relationship_with_Applicant_1__c='Client', RecordTypeId = personAccRTId, Residential_Address__pc = custAdd, 
                                            Street__pc = street, Postal_Code__pc = postalCode, Suburb__pc = suburb, Street_Type__pc = streetType,
                                            CountryOfResidence__pc = country, State__pc = state, Street_Number__pc = streetNumber, Referred_by_Company__c = refCompanyId,
                                            Account_Lead_Source__c = lead.leadSource, ReferredByContact__c = lead.ReferredByContact__c);
        insert personAccount;
        Id pConId = [SELECT Id, PersonContactId FROM Account WHERE Id =: personAccount.Id].PersonContactId;
        Opportunity opp = new Opportunity(Name = firstName + ' '+ LastName + ', ' + (quoteType =='Solar' ? 'Green Loan' : quoteType),
                                          Purpose__c = quoteType,
                                          applicant_1__c = personAccount.Id,
                                          Contact_1__c = pConId,
                                          AccountId = householdAccount.Id,
                                          Application_Sections__c = nextSection, 
                                          Current_Application_Sections__c = nextSection, 
                                          //How_much_do_you_need__c = quoteAmount,
                                          StageName='Quote', 
                                          installationAddressLineOne__c = custAdd,
                                          ReferredByContact__c = con[0].Id,
                                          Referred_by_Company__c = con[0].AccountId,
                                          Point_of_Origin__c = lead.Point_of_Origin__c,
                                          CloseDate = Date.today(),
                                          Send_the_quote_to__c = sendQuote,
                                          RecordTypeId = oppRecordTypeMap.get(quoteType),
                                          LeadSource = lead.LeadSource,
                                          Lead_Type__c =  lead.Lead_Type__c);
        
        if(String.isNotBlank(ownerId))
            opp.OwnerId = ownerId;
        
        insert opp;
        String taskOwnerId ='';
        if(String.isBlank(ownerId) || guestProfileIds.containsKey(ownerId)){
            taskOwnerId = usrManager.Id;
        }else{
            taskOwnerId = ownerId;
        }
        
        String quoteGrpName = 'Referral-';
        AggregateResult[] quoteGruop = [Select Gruop_Name__c from quote where Gruop_Name__c like 'Referral-%' AND  Lead__c =: lead.Id 
                                        GROUP BY Gruop_Name__c];
        
        if(quoteGruop.isEmpty()){
            quoteGrpName += '1';
        }else{
            quoteGrpName += (quoteGruop.size() + 1);
        }
        
        Map<String, List<Quote>> quotesListMap = New Map<String, List<Quote>>();
        List<Loan_Fees__c> loanFees = New List<Loan_Fees__c>();
        string nme='';
        for(integer i=0; i< quoteDetailWrpList.size(); i++){
            string qtName= 'Referral-';  
            Integer sum = i+1;
            Integer j=1;
            List<Quote> quotesList = New List<Quote>();
            for(Product2 pr: productsMap.values()){
                if(j>3)break;
                else if(pr.Maximum_Loan_Amount__c >= quoteDetailWrpList[i].Amount &&  pr.Minimum_Loan_Amount__c <= quoteDetailWrpList[i].Amount ){
                    Quote quote = New Quote();
                    quote.Lead__c = lead.Id;
                    quote.OpportunityId = opp.Id;
                    quote.Actual_Comparison_Rate__c = pr.Actual_Comparison_Rate__c;
                    quote.Name = pr.Name;
                    quote.Interest_Rate__c = pr.Interest_Rate__c;
                    quote.Loan_Term__c = pr.Max_Loan_Term__c;
                    quote.Product__c = pr.Id;
                    quote.Purpose__c = quoteType;
                    quote.Is_Featured__c = pr.Is_Feature_Product__c;
                    quote.isSelected__c = true;
                    quote.Customer_Amount__c = quoteDetailWrpList[i].Amount;                        
                    if(string.isBlank(quoteDetailWrpList[i].masterQuote)){
                        nme = qtName + sum;
                        quote.Gruop_Name__c = nme;
                        quote.Quote_Group_Label__c = nme;
                        quoteDetailWrpList[i].masterQuote = nme;
                    }
                    else{
                        quote.Quote_Group_Label__c = quoteDetailWrpList[i].masterQuote;
                        quote.Gruop_Name__c = quoteDetailWrpList[i].masterQuote;
                    }                        
                    quote.Commission_Amount__c = pr.Commission_Amount__c;
                    quote.Brokerage_Amount__c = pr.Brokerage_Amount__c;
                    quote.Lender__c = pr.Lender__c;
                    if(pr.Interest_Rate_Based_On__c =='Tiered Rate' && pr.Loan_Rates__r.size()>0 ){
                        for(Loan_Rate__c  lr: pr.Loan_Rates__r){
                            if(lr.From_amount__c <= quoteDetailWrpList[i].Amount && lr.To_amount__c >= quoteDetailWrpList[i].Amount){
                                quote.Actual_Comparison_Rate__c = lr.Comparison_rate__c;
                                quote.Interest_Rate__c = lr.Interest_rate__c;
                                break;
                            }
                        }
                    }
                    quotesList = quotesListMap.get(quote.Gruop_Name__c);
                    if(quotesList == NULL)quotesList = New List<Quote>();
                    quotesList.add(quote);
                    quotesListMap.put(quote.Gruop_Name__c, quotesList);                            
                    j++;
                }
            }           
        }
        List<Quote> quotesListToInsert = New List<Quote>();
        for(String qName: quotesListMap.keySet()){
            Boolean isFeature = false;
            String lowRatePrId = '';
            decimal lowestRate = 100;
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
                    qt.Is_Featured__c = true;
                }
                
                quotesListToInsert.add(qt);
            }
        }
        insert quotesListToInsert;
        
        map<String,list<id>> newdata= new map<String,list<id>>();
        for(integer i=0; i< quoteDetailWrpList.size(); i++){
            for(integer j=0; j< quoteDetailWrpList[i].cdlId.size(); j++){
                if(!newdata.containsKey(quoteDetailWrpList[i].masterQuote)){
                    newdata.put(quoteDetailWrpList[i].masterQuote,new LIst<id>{quoteDetailWrpList[i].cdlId[j]});
                }
                else{
                    newdata.get(quoteDetailWrpList[i].masterQuote).add(quoteDetailWrpList[i].cdlId[j]);
                }   
            }                        
        }
        System.debug('Map data +++++++++'+newdata);
        System.debug('Map size +++++++++'+newdata.size());
        
        list<ContentDocumentLink> allCdLinksToIns = new list<ContentDocumentLink> ();
        for(Quote qtlst : quotesListToInsert){
            System.debug('-------'+qtlst.Gruop_Name__c);
            if(newdata != null && newdata.size() > 0){
                if(newdata.get(qtlst.Gruop_Name__c) != null && newdata.get(qtlst.Gruop_Name__c).size() > 0){
                    for(String s : newdata.get(qtlst.Gruop_Name__c)){
                        system.debug('s--===--=='+s);
                        ContentDocumentLink cdlink = new ContentDocumentLink();
                        cdlink.ContentDocumentId = s;
                        cdlink.LinkedEntityId = qtlst.Id;
                        cdlink.ShareType = 'I';  
                        allCdLinksToIns.add(cdlink);
                    }
                }
            }
        }
        system.debug('--allCdLinksToIns--'+allCdLinksToIns);
        if(!allCdLinksToIns.isEmpty()){
            Insert allCdLinksToIns;
        }
        
        
        String featuredQuote;
        Id loanfeeRT = Schema.SObjectType.Loan_Fees__c.getRecordTypeInfosByName().get('Quote Loan Fees').getRecordTypeId();
        for(Quote qt : quotesListToInsert){
            system.debug('qt---------');
            Product2 pr = productsMap.get(qt.Product__c);
            if(qt.Is_Featured__c){
                featuredQuote = qt.Id;
            }
            for(Loan_Fees__c fees: pr.Loan_Fees__r){  
                system.debug('fees>>>>>>>>>>>>>');
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
        system.debug('loanFees____________>>>>>>>>>>>>>>>>'+loanFees);
        if(String.isBlank(featuredQuote)){
            featuredQuote = quotesListToInsert[0].Id;
        }
        insert loanFees;
        
        pdfData.put('oppId',(String)opp.Id);
        pdfData.put('conId',(String)conId);
        pdfData.put('leadId',(String)lead.Id);
        pdfData.put('referrerEmail',(String)refEmail);
        pdfData.put('customerEmail',(String)custEmail);
        pdfData.put('sendQuote',(String)sendQuote);
        pdfData.put('featuredQuote',(String)featuredQuote);
        newWrp.pdfData = pdfData;
        String errorMsg = '';  
        if(loanFees != null){ 
            newWrp.errorMessage = 'Success! Your latest referral can now be found by selecting ' + '\'' + 'My Referrals' +'\'' + ' in the quick menu at the top of the page. Or fill the form again to submit another customer.';
            return newWrp;
        }
        else{                
            return null;
        }
        }catch(exception e){
            UtilityClass.createException('','ReferralPageController', 'submitReferral', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                       e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @auraEnabled
    public static String generateAndSendPDF(Map<String,String> pdfData){
        String errMsg = '';
        system.debug('==generateAndSendPDF==');
        /*ApplicationFormController.sendApplication(pdfData.get('oppId'), pdfData.get('conId'), pdfData.get('leadId'), new List<String>{pdfData.get('referrerEmail')}, 'Quotation From Referrer VF', true);
        if(pdfData.get('sendQuote').equalsIgnoreCase('Me and my customer')){            
            ApplicationFormController.sendApplication(pdfData.get('oppId'), pdfData.get('conId'), pdfData.get('leadId'), New List<String>{pdfData.get('customerEmail')}, 'Quotation From Referral VF', false);
        }*/
        ApplicationFormController.sendApplication(pdfData.get('oppId'), pdfData.get('conId'), pdfData.get('oppId'), new List<String>{pdfData.get('referrerEmail')}, 'Quotation_from Referrer_ReferrerPortal', true);
        if(pdfData.get('sendQuote').equalsIgnoreCase('Me and my customer')){
            system.debug('Me and My customer');
            ApplicationFormController.sendApplication(pdfData.get('oppId'), pdfData.get('conId'), pdfData.get('oppId'), New List<String>{pdfData.get('customerEmail'),pdfData.get('referrerEmail')}, 'Quotation_from Referral_ReferrerPortal', false);
        }
        list<Quote> quoteList = [select id,name,IsSelected__c from quote where IsSelected__c=true AND OpportunityId=:pdfData.get('oppId')];
        for(Quote qtt : quoteList){
            qtt.IsSelected__c = false;
        }
        if(quoteList.size()>0){
            system.debug('My deleted list');
            update quoteList;
        }
        errMsg = 'Success! Your latest referral can now be found by selecting ' + '\'' + 'My Referrals' +'\'' + ' in the quick menu at the top of the page. Or fill the form again to submit another customer.';
        return errMsg;
    }
    
    public class QuoteDetailWrapper{
        @auraEnabled public String masterQuote {get;set;}
        @auraEnabled public String errorMessage {get;set;}
        @auraEnabled public Boolean checkError {get;set;}
        @auraEnabled public Decimal minAmt {get;set;}
        @auraEnabled public Decimal maxAmt {get;set;}
        @auraEnabled public Decimal Amount {get;set;}
        @auraEnabled public list<String> NmList =new List<string>();
        @auraEnabled public list<id> cdlId =new List<id>();
        @auraEnabled public Map<String,String> pdfData = New Map<String,String>();
    }
}