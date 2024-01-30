public without sharing class ParkerLaneLoanController {
    public static final String alreadyCustomer = 'We are unable to accept referrals when a customer is already in our system. Please call us on 1300 131 711 or email us with details instead to PersonalApplications@parkerlane.com.au';
    private static Id personAccRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    private static Id householdAccRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    public static final String adminEmail = 'personalapplications@parkerlane.com.au';
    public static final String guestUserName = 'Lanecorp Site Guest User';
    public static final String personalCreditEmailId = 'personal.credit@parkerlane.com.au';
    private static Map<String, Id> oppRecordTypeMap = New Map<String, Id>{
        'Solar' => Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Green Loan').getRecordTypeId(),
         'Home Improvement' => Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Home Improvement').getRecordTypeId(),
         'Debt Consolidation' => Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Debt Consolidation').getRecordTypeId()};
    private static Map<String, Id> leadRecordTypeMap = New Map<String, Id>{
        'Solar' => Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Green Loan').getRecordTypeId(),
         'Home Improvement' => Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Home Improvement').getRecordTypeId(),
         'Debt Consolidation' => Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Debt Consolidation').getRecordTypeId()};
    public static Set<Id> mortgageRTList = New Set<Id>{
         Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commercial Mortgage').getRecordTypeId(),
         Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commercial Property Purchase').getRecordTypeId(),
        // Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Debt Consolidation').getRecordTypeId(),
         Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('First Home Purchase').getRecordTypeId(),
         Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Home Loan Construction').getRecordTypeId(),
         Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Home Loan Purchase').getRecordTypeId(),
         Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Home Loan Refinance').getRecordTypeId(),
         Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investment Property Purchase').getRecordTypeId(),
         Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Next Home Purchase').getRecordTypeId()
    };
    
    public static List<String> getApplicationSections(){
        List<String> appSectionsList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Opportunity.Application_Sections__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            appSectionsList.add(f.getLabel());
        }   
        return appSectionsList;
    }
    
    private static String getPath(String currPath, String inProgressPath, String recordTypeId){
        List<String> appSecPLList = New List<String>{'Who is applying', 'Own and Owe', 'Earn', 'Living Expenses','Goals & Objectives'};
        List<String> appSecHLHCList = New List<String>{'Who is applying', 'Own and Owe', 'Earn', 'Living Expenses', 'Preferences', 'Risk Assessment', 'Anticipated Changes to Circumstances','Goals & Objectives'};
        List<String> appSectionsList = getApplicationSections();  
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
                   if(!mortgageRTList.contains(recordTypeId) && !appSecPLList.contains(appSec)){
                       isMortgage = false;
                       continue;
                   }
                   if(mortgageRTList.contains(recordTypeId) && !appSecHLHCList.contains(appSec)){
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
    
    @auraEnabled
    public static String getSelectedSection(Id recordId){
        Opportunity opp = [SELECT Id, Application_Sections__c, Current_Application_Sections__c, RecordTypeId FROM Opportunity WHERE Id =: recordId];
        String path = '{\"CurrentSection\":\"'+opp.Current_Application_Sections__c+'\", \"path\": '+getPath( opp.Current_Application_Sections__c, opp.Application_Sections__c, opp.RecordTypeId)+ '}';
        return path;
    }
    
    @auraEnabled
    public static Opportunity getOpportunityRec(Id recordId){
        Opportunity opp = [SELECT Id,Lender__c,app_Two_completed_Summary__c,Document_Redirect_URL__c,Referred_by_Company__r.Custom_Loan_Options_Page_Type__c, Referred_by_Company__r.Custom_Loan_Options_Landing_Page__c FROM Opportunity WHERE Id =: recordId];
        return opp;
    }
    
    @auraEnabled
    public static String SaveAndNextWithoutId(String secName){
        List<String> appSectionsList = getApplicationSections();
        String nextSection = appSectionsList[appSectionsList.indexOf(secName) + 1];
        String path = '{\"CurrentSection\":\"'+ nextSection +'\", \"path\": '+getPath(nextSection, nextSection, null)+ '}';
        return path;
    }
    
    @auraEnabled
    public static boolean getVerifyPhoneNumber(Id recordId,  String phNo){
        boolean isVerify = false;
        if(string.isNotBlank(recordId) && string.isNotBlank(phNo)){
            Opportunity opp = [SELECT Id, Applicant_1__c, Applicant_2__c, Applicant_1__r.Phone, Applicant_2__r.Phone  FROM Opportunity 
                               WHERE Id =: recordId ];
            if( phNo.equalsIgnoreCase(opp.Applicant_1__r.Phone) || phNo.equalsIgnoreCase(opp.Applicant_2__r.Phone)){
                isVerify = true;
            }
        }
        return isVerify;
    }
       
    @auraEnabled
    public static String SaveAndConfirm(sObject selectedQuote, Opportunity opp){
        try{
            String nextSection = 'Who is applying';
            Quote quote = (Quote) selectedQuote;
            List<Quote> toUpdateQuoteList = new List<Quote>();

            Map<Id, Quote> quotesMap = New Map<Id,Quote> ([SELECT Id, Up_Front_Costs_Applicable__c,Affordability_Confirmation__c,Total_loan_amount__c, Application__c
                                            FROM Quote WHERE OpportunityId =: opp.Id]);
            for(Id qtId : quotesMap.keySet()){
                Quote qt = quotesMap.get(qtId);
                qt.Affordability_Confirmation__c = quote.Affordability_Confirmation__c;
                if(quote.Id.equals(qt.Id)){
                    qt.Application__c = true;
                }                    
                toUpdateQuoteList.add(qt);
            }
            update toUpdateQuoteList;
            //opp.StageName='CPA Started';
            opp.Application_Sections__c = nextSection;
            opp.Current_Application_Sections__c = nextSection;
            opp.How_much_do_you_need__c = quotesMap.get(quote.Id).Total_loan_amount__c;
            //opp.Loan_Amount__c = quotesMap.get(quote.Id).Total_loan_amount__c;
            update opp;           
            
            
            if(String.isNotBlank(quote.Lead__c)){
                Lead lead = New Lead();
                lead.Id = quote.Lead__c;
                lead.Status = 'PA Commenced';
                update lead;
            }
            
            String path = '{\"status\":\"Success\",\"CurrentSection\":\"'+ nextSection +'\", \"path\": '+getPath(nextSection, nextSection, opp.RecordTypeId)+ '}';
            return path;
                       
        }catch(exception e){
            UtilityClass.createException(opp.Id, 'ParkerLaneLoanController', 'SaveAndConfirm', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                       e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @auraEnabled
    public static String checkExistingCustomer(Contact con1, Contact con2, opportunity opp, Integer Number_of_applicants){
        List<Contact>upsertConsList = new List<Contact>();
        try{
            String householdId = '';
            if(String.isNotBlank(opp.FinServ__Household__c)){
                householdId = opp.FinServ__Household__c;
            }else if(String.isNotBlank(opp.AccountId) && ('Household').equalsIgnoreCase(opp.Account.RecordType.Name)){
                householdId = opp.AccountId;
            }
            List<Account> householdAcc = [SELECT Id, Name FROM Account WHERE Id =: householdId];
            Id personAccRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            String status = '{\"status\":\"Success\"}';
            List<String> eMailIds = New  List<String> ();
            if(con1 != Null && String.isBlank(con1.Id) && String.isNotBlank(con1.Email)){
                eMailIds.add(con1.Email);
            }
            if(con2 != Null && String.isBlank(con2.Id) && String.isNotBlank(con2.Email)){
                eMailIds.add(con2.Email);
            }
            
            List<Account> existingPAccList = [SELECT Id FROM Account WHERE PersonContact.Email in: eMailIds];
            
            if(!existingPAccList.isEmpty()){
                return '{\"status\":\"Error\",\"message\":\"'+ System.Label.Already_Customer_Exist +'\"}';
            }else{
                
                String householdName='';
                if(Number_of_applicants == 1){
                    upsertConsList.add(con1);

                    householdName = con1.FirstName + ' ' + con1.LastName +' Household (' + con1.Suburb__c +' ' + con1.State__c + ')';
                    if(!householdAcc.isEmpty() && !householdAcc[0].Name.equalsIgnoreCase(householdName)){
                        householdAcc[0].Name = householdName;
                        update householdAcc;
                    }
                    if(con2 !=null && String.isNotBlank(con2.Id)){
                        /* i added because when acount delete there depedent emplyoment also be deleted*/
                        delete [SELECT Id FROM FinServ__Employment__c where FinServ__Contact__c = :con2.Id];
                        delete [SELECT Id FROM Account WHERE PersonContactId =: con2.Id];
                        
                        opp.Relationship_to_Applicant_2__c = null;
                        con2 = null;
                        opp.Applicant_2__c = null;
                    }
                }else if(Number_of_applicants == 2){
                    if(con2.Id == NULL){
                        Account personAccount = new Account(FirstName = con2.FirstName, LastName = con2.LastName,  
                                                            Relationship_with_Applicant_1__c=opp.Relationship_to_Applicant_2__c, 
                                                            RecordTypeId = personAccRTId);
                        insert personAccount;
                        opp.Applicant_2__c = personAccount.Id;
                        con2.Id = [SELECT Id, PersonContactId FROM Account WHERE Id =: personAccount.Id].PersonContactId;
                    }
                    upsertConsList.add(con1);
                    upsertConsList.add(con2);
                    householdName = '';
                    
                    if(con1.LastName.equalsIgnoreCase(con2.LastName)){
                        householdName = con1.FirstName + ' and ' + con2.FirstName + ' ' + con1.LastName;
                    }else{
                        householdName = con1.FirstName + ' ' + con1.LastName + ' and ' + con2.FirstName + ' ' + con2.LastName;
                    }
                    opp.Name = householdName + ', ' + Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(opp.RecordTypeId).getName();
                    householdName += ' Household (' + con1.Suburb__c +' ' + con1.State__c + ')';
                    if(!householdAcc.isEmpty() && !householdAcc[0].Name.equalsIgnoreCase(householdName)){
                        householdAcc[0].Name = householdName;
                        update householdAcc;
                    }
                    status = '{\"status\":\"Success\",\"con2Id\":\"'+ con2.Id +'\"}';
                }
                
                upsert upsertConsList;
                opp.Contact_1__c = con1 !=Null ? con1.Id : Null;
                opp.Contact_2__c = con2 !=Null ? con2.Id : Null;
                upsert opp;
                setAssetLiabilityOwnership(opp.Id);
                return status; 
            }
            
        }catch(exception e){
            UtilityClass.createException(opp.Id, 'ParkerLaneLoanController', 'checkExistingCustomer', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                       e.getTypeName(), ''+e.getCause());
            return '';
        }
    }
    
    @auraEnabled
    public static sObject getSelectedQuote(Id recordId){
        try{
            List<Quote> qtList = [SELECT Id, Customer_Amount__c, Loan_Term__c, Monthly_Repayment__c, Purpose__c,  Interest_Rate__c,
                        Lead__c, Lead__r.FirstName, Lead__r.LastName, Lead__r.Email, Shared_Message__c, Product__r.Summary_Page_What_You_ll_Get__c, Product__r.What_document_needs_to_apply__c, 
                        Opportunity.Applicant_1__r.PersonContactId, Total_loan_amount__c, Up_Front_Costs_Applicable__c, Total_Setup_Fees__c,Affordability_Confirmation__c
                        FROM Quote WHERE OpportunityId =: recordId AND Application__c = true LIMIT 1];
            if(!qtList.isEmpty()){
               return qtList[0];
            }
            return New Quote();
        }catch(exception e){
            UtilityClass.createException(recordId, 'ParkerLaneLoanController', 'getSelectedQuote', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                       e.getTypeName(), ''+e.getCause());
            return null;
        }
    }

    @auraEnabled
    public static OpportunityContacts getOppContacts(Id recordId){
        if (String.isBlank(recordId)) return null;
        List<Contact> app1Children = new List<Contact>();
        List<Contact> app2Children = new List<Contact>();
        
        OpportunityContacts oppCons = new OpportunityContacts();
        Opportunity opp = new Opportunity();
        try{
            opp = [SELECT Id, Number_of_applicants__c, Application_Sections__c, Current_Application_Sections__c,
                   Applicant_1__c, Applicant_1__r.PersonContactId, Applicant_2__c, Applicant_2__r.PersonContactId,
                   AccountId, Account.RecordType.Name, FinServ__Household__c, Relationship_to_Applicant_2__c, RecordType.DeveloperName,
                   Purpose__c, RecordTypeId, SyncedQuote.Lender__c, SyncedQuote.Product_Type__c,Lender__c, Loan_Amount__c, Do_you_both_live_at_the_same_address__c
                   FROM Opportunity WHERE Id =: recordId limit 1];
            oppCons.opp = opp;
            set<Id> conIds = new Set<Id>();
            if(String.isNotBlank(opp.Applicant_1__c)){
                conIds.add(opp.Applicant_1__r.PersonContactId);
            }
            if(String.isNotBlank(opp.Applicant_2__c)){
                conIds.add(opp.Applicant_2__r.PersonContactId);
            }
            
            Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT FirstName, LastName, MiddleName, Email, Phone, Title, Birthdate, 
                                                                 OtherPhone, FinServ__Gender__c, FinServ__MaritalStatus__c, Government_ID__c,
                                                                 Govt_Id_Number__c, Living_Situation__c, FinServ__NumberOfChildren__c,
                                                                 Security_Answer__c, Security_Question__c, Driver_s_licence_state_Territory__c,
                                                                 Dont_have_drivers_licence__c, FinServ__PrimaryAddressIsOther__c, isFindPostalAdd__c,
                                                                 Postal_address_is_PO_or_GPO_box__c, Months__c, Months_1__c, Months_2__c, Year__c, 
                                                                 Year_1__c, Year_2__c, Unit_Number__c, Unit_Number_1__c, Unit_Number_2__c,
                                                                 Suburb__c, Suburb_1__c, Suburb_2__c, Street_Type__c, Street_Type_1__c, Street_Type_2__c,
                                                                 Street_Number__c, Street_Number_1__c, Street_Number_2__c, Street__c, Street_1__c, 
                                                                 Street_2__c, State__c, State_1__c, State_2__c, Residential_Address__c, Residential_Address_1__c,
                                                                 Residential_Address_2__c, Postal_Suburb__c, Postal_State__c, Postal_Postal_Code__c, 
                                                                 Postal_Number__c, Postal_Code__c, Postal_Code_1__c, Postal_Country__c, FinServ__EmailVerified__c,
                                                                 Postal_Code_2__c, Postal_Box_Type__c, Postal_Address__c, Is_Find_Address__c, Is_Find_Address_1__c, 
                                                                 Is_Find_Address_2__c, Is_Address_Same__c, FinServ__CountryOfResidence__c, Country_1__c, Country_2__c,
                                                                 Rental_Amount__c, Rental_Frequency__c, Rental_Managed_via__c, Citizenship_Status__c, Visa_Details__c,
                                                                 First_Name_Child_1__c, First_Name_Child_2__c, First_Name_Child_3__c, First_Name_Child_4__c, First_Name_Child_5__c,
                                                                 Age_Child_1__c, Age_Child_2__c, Age_Child_3__c, Age_Child_4__c, Age_Child_5__c, Medicare_Card_Colour__c, Medicare_Reference__c,
                                                                 Medicare_Expiry_Date__c, Medicare_Number__c, Is_Previous_Address_Same__c, Medicare_Expiry_Year__c, Medicare_Expiry_Month__c,
                                                                 Postal_Street_Number__c,Postal_Street_Type__c,Postal_Street__c, Postal_Unit_Number__c, Do_you_own_where_you_live__c,
                                                                 Do_you_own_any_other_property__c,Total_non_property_assets__c/*, CreditCardsCommitments__c,PersonalAndAuto__c,
                                                                 OtherCommitments__c*/
                                                                 FROM Contact WHERE Id in: conIds]);
            
            oppCons.contact1 = contactsMap.get(opp.Applicant_1__r.PersonContactId);
            oppCons.contact2 = contactsMap.get(opp.Applicant_2__r.PersonContactId);
            
            for(Contact con : [SELECT Id, FirstName, LastName, Account.Dependent_parent__c,Child_Age__c FROM Contact WHERE  Account.Dependent_parent__r.personContactId in: conIds]){
                if(String.isNotBlank(con.Account.Dependent_parent__c)){
                    if(String.isNotBlank(opp.Applicant_1__c) && opp.Applicant_1__c.equals(con.Account.Dependent_parent__c)){
                        app1Children.add(con);
                    }
                    if(String.isNotBlank(opp.Applicant_2__c) && opp.Applicant_2__c.equals(con.Account.Dependent_parent__c)){
                        app2Children.add(con);
                    }
                }
            }
            oppCons.app1Children = app1Children;
            oppCons.app2Children = app2Children;
            
            return oppCons;
        }catch(exception e){
            UtilityClass.createException(recordId, 'ParkerLaneLoanController', 'getOppContacts', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                       e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @auraEnabled
    public static String upsertOppContacts(Contact con1, Contact con2, List<Contact> app1Children, List<Contact> app2Children, Opportunity opp, Boolean isOppUpdate, Boolean isShare){
        try{
            Set<Id> toDeleteRecordsSet = new Set<Id>();
            List<String> emails =New List<String>();
            Opportunity oppUpdate = [SELECT Id, Number_of_applicants__c, Applicant_1__c, Applicant_2__c, 
                                     Applicant_1__r.LastName, Applicant_2__r.LastName, Application_Sections__c,
                                     Current_Application_Sections__c, Relationship_to_Applicant_2__c, RecordTypeId
                                     FROM Opportunity WHERE Id =: opp.Id];

            Id personAccRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            List<String> appSectionsList = getApplicationSections();  

            List<Contact>upsertConsList = new List<Contact>();

            if(oppUpdate.Number_of_applicants__c == 1){
                upsertConsList.add(con1);
                emails.add(con1.Email);
            }else if(oppUpdate.Number_of_applicants__c == 2){
                upsertConsList.add(con1);
                upsertConsList.add(con2);
                emails.add(con1.Email);
                emails.add(con2.Email);
            }
            
            List<Account> upsertChildren = new List<Account>();
            if(app1Children.size()>0){
                for(Contact con : app1Children){
                    if(con.Id == null){
                        upsertChildren.add(new Account(FirstName= con.FirstName, LastName = oppUpdate.Applicant_1__r.LastName, Relationship_with_Applicant_1__c='Dependent',
                                                       Dependent_Parent__c = oppUpdate.Applicant_1__c,
                                                       Child_Age__pc = con.Child_Age__c,
                                                       RecordTypeId = personAccRTId));
                    }else{
                        toDeleteRecordsSet.add(con.AccountId);
                        upsertChildren.add(new Account(FirstName= con.FirstName, LastName = oppUpdate.Applicant_1__r.LastName, Relationship_with_Applicant_1__c='Dependent',
                                                       Dependent_Parent__c = oppUpdate.Applicant_1__c,
                                                       Child_Age__pc = con.Child_Age__c, Id = con.AccountId,
                                                       RecordTypeId = personAccRTId));
                    }
                }
            }
            if(app2Children.size()>0){
                for(Contact con : app2Children){
                    if(String.isBlank(con.Id)){
                        upsertChildren.add(new Account(FirstName= con.FirstName, LastName = oppUpdate.Applicant_2__r.LastName, Relationship_with_Applicant_1__c='Dependent',
                                                       Dependent_Parent__c = oppUpdate.Applicant_2__c,
                                                       Child_Age__pc = con.Child_Age__c,
                                                       RecordTypeId = personAccRTId));
                    }else{
                        toDeleteRecordsSet.add(con.AccountId);
                        upsertChildren.add(new Account(FirstName= con.FirstName, LastName = oppUpdate.Applicant_2__r.LastName, Relationship_with_Applicant_1__c='Dependent',
                                                       Dependent_Parent__c = oppUpdate.Applicant_2__c,
                                                       Child_Age__pc = con.Child_Age__c, Id = con.AccountId,
                                                       RecordTypeId = personAccRTId));
                    }
                }
            }
            

            String nextSection = appSectionsList[appSectionsList.indexOf(oppUpdate.Current_Application_Sections__c) + 1];
            
            delete [SELECT Id FROM Account WHERE Dependent_parent__r.personContactId in: upsertConsList AND (NOT id in: toDeleteRecordsSet)];
            upsert upsertChildren;
            upsert upsertConsList;
            if(isOppUpdate){
                if(oppUpdate.Application_Sections__c == oppUpdate.Current_Application_Sections__c){
                    oppUpdate.Application_Sections__c = nextSection;
                }
                oppUpdate.Current_Application_Sections__c = nextSection;
            }else{
                nextSection = oppUpdate.Current_Application_Sections__c;
            }

            oppUpdate.Contact_1__c = con1 !=Null ? con1.Id : Null;
            oppUpdate.Contact_2__c = con2 !=Null ? con2.Id : Null;
            Database.update(oppUpdate,false);
            Boolean isMortgageApp = mortgageRTList.contains(oppUpdate.recordTypeId);
            if(isShare && !isMortgageApp){
                quote qt = [SELECT Id FROM Quote WHERE OpportunityId =: opp.Id AND Application__c = TRUE];
                sendApplication(opp.Id, con1.Id, qt.Id, emails, 'Application Resume Later Email', false);
            }
            
            String path = '{\"CurrentSection\":\"'+ nextSection +'\", \"path\": '+getPath(nextSection, oppUpdate.Application_Sections__c, oppUpdate.RecordTypeId)+ '}';
            return path;
        }catch(exception e){
            UtilityClass.createException(opp.Id, 'ParkerLaneLoanController', 'upsertOppContacts', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                       e.getTypeName(), ''+e.getCause());
            return '[]';
        }
    }
    
    @auraEnabled
    public static String setSelectedSection(Id recordId, String selectedPath){
        Opportunity oppUpdate = [SELECT Id, Application_Sections__c, Current_Application_Sections__c, RecordTypeId
                                 FROM Opportunity WHERE Id =: recordId];
        oppUpdate.Current_Application_Sections__c = selectedPath;
        update oppUpdate;
        String path = '{\"CurrentSection\":\"'+oppUpdate.Current_Application_Sections__c+'\", \"path\": '+getPath( oppUpdate.Current_Application_Sections__c, oppUpdate.Application_Sections__c, oppUpdate.RecordTypeId)+ '}';
        return path;
        
    }
    
    @auraEnabled
    public static String getSelectedPerson(Id recordId){
        if (String.isBlank(recordId)) return '';
        
        try{
            List<Opportunity> oppList = [SELECT Id, Number_of_applicants__c,  Applicant_1__c, Applicant_2__c
                               FROM Opportunity WHERE Id =: recordId limit 1];
            if(!oppList.isEmpty()){
                if(String.isNotBlank(oppList[0].Applicant_1__c) && String.isNotBlank(oppList[0].Applicant_2__c)){
                    return 'joint';
                }else if(String.isNotBlank(oppList[0].Applicant_1__c) || String.isNotBlank(oppList[0].Applicant_2__c)){
                    return 'single';
                }
            }
            
            return '';
        }catch(exception e){
            UtilityClass.createException(recordId, 'ParkerLaneLoanController', 'getSelectedPerson', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                       e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @auraEnabled
    public static void shareApplicationByEmail(Id recordId, String email, String emailBody){
        Quote qt = (Quote) getSelectedQuote(recordId);

        qt.Shared_Message__c = emailBody;
   
        sendApplication(recordId, qt.Opportunity.Applicant_1__r.PersonContactId, qt.Id, New List<String>{email}, 'Quotation From Application For Save & Share', false);

    } 
    
    @auraEnabled
    public static void sendApplication(String oppId, String leadId, String quoteId, List<String> emails, String templateName, Boolean isPDFAttach){
        try{
            
            Opportunity opp = [SELECT Id, Purpose__c, Applicant_1__r.Name, FinServ__ReferredByContact__r.Name, 
                               How_much_do_you_need__c, Applicant_1__r.Phone, Send_the_quote_to__c,
                               Owner.Name, Owner.Email,Credit_Analyst__c, Credit_Analyst__r.Email,RecordType.Name,RecordTypeId
                               FROM Opportunity WHERE Id =: oppId];
            system.debug('opp'+opp);
            List<String>emailBCCList = New List<String>();
            List<String>emailCCList = new List<String>();
            List<String>  personalRecTypeNameList = New List<String>{'Green Loan','Asset Finance','Commercial Solar Purchase','Commercial Asset Finance','Debt Consolidation','Home Improvement','Personal Loan','Vehicle Purchase'};
            List<String>  mortgageRecTypeNameList = New List<String>{'Commercial Mortgage','Commercial Property Purchase','Home Loan Construction','Home Loan Purchase','Home Loan Refinance','Opportunity (Wallet Share)'};
                
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            System.debug('to emails>>' +emails);
            System.debug('quoteId>>' + quoteId);
            System.debug('leadId>>>' + leadId);
            mail.setToAddresses(emails);
            mail.setWhatId(quoteId); 
            mail.setUseSignature(false); 
            mail.setTargetObjectId(leadId);
            mail.setTreatTargetObjectAsRecipient(false);
            if(mortgageRecTypeNameList.contains(opp.RecordType.Name) || oppRecordTypeMap.get('Debt Consolidation') == opp.RecordTypeId){
                if(opp.Credit_Analyst__c!=null){
                    emailCCList.add(opp.Credit_Analyst__r.Email);
                }
                if(guestUserName.equalsIgnoreCase(opp.Owner.Name)){
                    emailBCCList.add(adminEmail);
                    
                }else{
                    emailBCCList.add(opp.Owner.Email);
                }
                
                mail.setBccAddresses(emailBCCList);
                //added 16-2-22
                if(emailCCList.size()>0){
                    mail.setCcAddresses(emailCCList);
                }
                emailBCCList.add(personalCreditEmailId);
            }
            
            mail.setSaveAsActivity(true); 
            EmailTemplate et=[Select id, Subject, Body from EmailTemplate where Name=:templateName]; 
            mail.setTemplateId(et.id); 
            String fromEmailAddress = 'hello@parkerlane.com.au';
            if(personalRecTypeNameList.contains(opp.RecordType.Name)){
                fromEmailAddress = UtilityClass.adminEmail;
            }else if(mortgageRecTypeNameList.contains(opp.RecordType.Name)){
                fromEmailAddress = 'mortgageapplications@parkerlane.com.au';
            }
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:fromEmailAddress];
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }            
            
            if(isPDFAttach){
                //System.debug('_____===--+-+-+-'+[select id, name from opportunity where id =: oppId]);
                PageReference pdf = Page.QuotationTemplatePDF;
                pdf.getParameters().put('id',opp.id);
                pdf.setRedirect(true);
                Blob bPDF;
                if(Test.isRunningTest()){
                    bPDF = Blob.valueOf('Unit Test Body');
                }else{
                    bPDF = pdf.getContent();
                    System.debug('-------11111'+pdf.getContent());
                    System.debug('-------'+bPDF);
                }
                String dateSTR = Date.today().day() + '-' + Date.today().month() + '-' + Date.today().year();
                String pdfName = opp.Purpose__c + ' Finance Options for ' + opp.Applicant_1__r.Name + ', ' + dateSTR +'.pdf';
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(pdfName);
                efa.setBody(bPDF);
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            }
            system.debug('mailllllllllllll'+mail);
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        }catch(exception e){
            UtilityClass.createException(oppId, 'ParkerLaneLoanController', 'sendApplication', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
        }
    }
    
    @auraEnabled
    public static String previous(Id recordId){
        List<String> appSectionsList = getApplicationSections();
        Opportunity oppUpdate = [SELECT Id, Application_Sections__c, Current_Application_Sections__c, RecordTypeId
                                 FROM Opportunity WHERE Id =: recordId];
        Integer preNo = 1;
        if(!mortgageRTList.contains(oppUpdate.recordTypeId) && oppUpdate.Current_Application_Sections__c == 'Goals & Objectives'){
            preNo = 4;
        }
        String preSection = appSectionsList[appSectionsList.indexOf(oppUpdate.Current_Application_Sections__c) - preNo];
        oppUpdate.Current_Application_Sections__c = preSection;
        try{
            
            update oppUpdate;            
            String path = '{\"CurrentSection\":\"'+ preSection +'\", \"path\": '+getPath(preSection, oppUpdate.Application_Sections__c, oppUpdate.RecordTypeId)+ '}';
            return path;
        }catch(exception e){
            UtilityClass.createException(recordId, 'ParkerLaneLoanController', 'previous', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                       e.getTypeName(), ''+e.getCause());
            return '[]';
        }
    }
    
    @auraEnabled
    public static Map<String, List<FinServ__AssetsAndLiabilities__c>> getAssetsAndLiabilities(Id recordId){
        Opportunity oppt = [SELECT Applicant_1__c,Applicant_2__c FROM Opportunity WHERE Id =: recordId LIMIT 1];
        List<FinServ__AssetsAndLiabilities__c> assetsAndLiabilitiesList = 
            [SELECT FinServ__Amount__c, FinServ__Description__c, RecordType.Name, Limit__c, Monthly_Repayment__c,
             FinServ__Ownership__c, FinServ__AssetsAndLiabilitiesType__c, Address__c, Interest_Rate__c,
             Approximate_Remaining_Term_Years__c, Bank_Type__c, Country__c, Institution__c, Repayment_Type__c,
             Is_Address_Same__c, Is_Find_Address__c, Make_Model__c, Payment_Frequency__c, Postal_Code__c, Lender__c,
             Property_Managed_By__c, Rate_Expires_in_Months__c, Rate_Expires_in_Years__c, Rate_Type__c, Rental_Amount__c,
             Rental_Frequency__c, Repayment_Frequency__c, State__c, Street__c, Street_Number__c, Street_Type__c, Suburb__c,
             Type_of_Fund__c, Type_of_Tenancy__c, Unit_Number__c, Year__c, Post_Payment_Frequency__c, Post_tax_lease_Payment__c,
             Pre_Payment_Frequency__c, Pre_tax_lease_Payment__c, Ownership_Share__c, Other_Ownership_Share__c, Value__c,
             Salary_sacrifice_any_of_the_payments__c, Monthly_Calculation__c,FinServ__PrimaryOwner__r.Total_non_property_assets__pc,Property_Situation__c,
             FinServ__PrimaryOwner__r.CreditCardsCommitments__pc, FinServ__PrimaryOwner__r.OtherCommitments__pc, FinServ__PrimaryOwner__r.PersonalAndAuto__pc
             FROM FinServ__AssetsAndLiabilities__c 
             WHERE FinServ__PrimaryOwner__c =: oppt.Applicant_1__c OR FinServ__PrimaryOwner__c =: oppt.Applicant_2__c ORDER BY  FinServ__AssetsAndLiabilitiesType__c] ;
        
        Map<String, List<FinServ__AssetsAndLiabilities__c>> assetsAndLiabilitiesMap = new Map<String, List<FinServ__AssetsAndLiabilities__c>>();
        for(FinServ__AssetsAndLiabilities__c assLiab : assetsAndLiabilitiesList){
            List<FinServ__AssetsAndLiabilities__c>assLiabList = assetsAndLiabilitiesMap.get(assLiab.RecordType.Name);
            if(assLiabList == Null){
                assLiabList = new List<FinServ__AssetsAndLiabilities__c>();
            }
            assLiabList.add(assLiab);
            assetsAndLiabilitiesMap.put(assLiab.RecordType.Name, assLiabList);
        }
        Opportunity opp = [SELECT Applicant_1__r.Living_Situation__pc  FROM Opportunity WHERE Id =: recordId];
        assetsAndLiabilitiesMap.put('livingSituation', new List<FinServ__AssetsAndLiabilities__c>{new FinServ__AssetsAndLiabilities__c(Name = opp.Applicant_1__r.Living_Situation__pc)});
        return assetsAndLiabilitiesMap;
    }
    @auraEnabled
    public static String upsertOppAssetsAndLiabilities(List<FinServ__AssetsAndLiabilities__c> assetsList, List<FinServ__AssetsAndLiabilities__c> liabilitiesList, Id oppId, Boolean isOppUpdate, Boolean isShare){
        Id assetRTypeId = Schema.SObjectType.FinServ__AssetsAndLiabilities__c.getRecordTypeInfosByName().get('Asset').getRecordTypeId();
        Id liabilityRTypeId = Schema.SObjectType.FinServ__AssetsAndLiabilities__c.getRecordTypeInfosByName().get('Liability').getRecordTypeId();
        Opportunity oppUpdate = [SELECT Id, Applicant_1__c, Applicant_2__c, Applicant_1__r.PersonContactId, Application_Sections__c, Current_Application_Sections__c, AccountId,
                                 Applicant_1__r.PersonContact.Email, Applicant_2__r.PersonContact.Email, RecordTypeId
                                 FROM Opportunity WHERE Id =: oppId];

        List<String> appSectionsList = getApplicationSections();
        List<String> emails = New  List<String>();
        if(String.isNotBlank(oppUpdate.Applicant_1__c)){
            emails.add(oppUpdate.Applicant_1__r.PersonContact.Email);
        }
        if(String.isNotBlank(oppUpdate.Applicant_2__c)){
            emails.add(oppUpdate.Applicant_2__r.PersonContact.Email);
        }

        Contact con=[SELECT Unit_Number__c, Suburb__c, Street_Type__c, Street_Number__c, Street__c, State__c, 
                     Residential_Address__c, Postal_Code__c, Is_Find_Address__c, FinServ__CountryOfResidence__c
                     FROM Contact WHERE Id =: oppUpdate.Applicant_1__r.PersonContactId];

        List<FinServ__AssetsAndLiabilities__c>upsertAssetsAndLiabilitiesList = new List<FinServ__AssetsAndLiabilities__c>();
        
        for(FinServ__AssetsAndLiabilities__c assLiab : assetsList){
            assLiab.FinServ__PrimaryOwner__c = oppUpdate.Applicant_1__c;
            if(assLiab.FinServ__Ownership__c == 'Applicant 2'){
                assLiab.FinServ__PrimaryOwner__c = oppUpdate.Applicant_2__c;
            }
            if(assLiab.FinServ__Ownership__c == 'Applicant 1' || assLiab.FinServ__Ownership__c == 'Applicant 2'){
                assLiab.Ownership_Share__c = 100;
            }
            assLiab.recordTypeId = assetRTypeId;
            assLiab.FinServ__JointOwner__c = NULL;
            if(assLiab.FinServ__Ownership__c == 'Joint'){
                assLiab.FinServ__JointOwner__c = oppUpdate.Applicant_2__c;
            }
            if(assLiab.Is_Address_Same__c){
                assLiab.Is_Find_Address__c = con.Is_Find_Address__c;
                assLiab.Unit_Number__c = con.Unit_Number__c;
                assLiab.Street_Number__c = con.Street_Number__c;
                assLiab.Street__c = con.Street__c;
                assLiab.State__c = con.State__c;
                assLiab.Suburb__c = con.Suburb__c;
                assLiab.Street_Type__c = con.Street_Type__c;
                assLiab.Postal_Code__c = con.Postal_Code__c;
                assLiab.Address__c = con.Residential_Address__c;
                assLiab.Country__c = con.FinServ__CountryOfResidence__c;
                
            }
            upsertAssetsAndLiabilitiesList.add(assLiab);
        }

        for(FinServ__AssetsAndLiabilities__c assLiab : liabilitiesList){
            assLiab.FinServ__PrimaryOwner__c = oppUpdate.Applicant_1__c;
            if(assLiab.FinServ__Ownership__c == 'Applicant 2'){
                assLiab.FinServ__PrimaryOwner__c = oppUpdate.Applicant_2__c;
            }
            if(assLiab.FinServ__Ownership__c == 'Applicant 1' || assLiab.FinServ__Ownership__c == 'Applicant 2'){
                assLiab.Ownership_Share__c = 100;
            }
            assLiab.FinServ__JointOwner__c = NULL;
            if(assLiab.FinServ__Ownership__c == 'Joint'){
                assLiab.FinServ__JointOwner__c = oppUpdate.Applicant_2__c;
            }
            assLiab.recordTypeId = liabilityRTypeId;
            upsertAssetsAndLiabilitiesList.add(assLiab);
        }
        String nextSection = appSectionsList[appSectionsList.indexOf(oppUpdate.Current_Application_Sections__c) + 1];
        
        try{
            upsert upsertAssetsAndLiabilitiesList;

            if(isOppUpdate){
                if(oppUpdate.Application_Sections__c == oppUpdate.Current_Application_Sections__c){
                    oppUpdate.Application_Sections__c = nextSection;
                }
                oppUpdate.Current_Application_Sections__c = nextSection;
            }else{
                nextSection = oppUpdate.Current_Application_Sections__c;
            }

            update oppUpdate;
            Boolean isMortgageApp = mortgageRTList.contains(oppUpdate.recordTypeId);
            if(isShare && !isMortgageApp){
                quote qt = [SELECT Id FROM Quote WHERE OpportunityId =: oppId AND Application__c = TRUE];
                sendApplication(oppId, oppUpdate.Applicant_1__r.PersonContactId, qt.Id, emails, 'Application Resume Later Email', false);
            }
            String path = '{\"CurrentSection\":\"'+ nextSection +'\", \"path\": '+getPath(nextSection, oppUpdate.Application_Sections__c, oppUpdate.RecordTypeId)+ '}';
            return path;
        }catch(exception e){
            UtilityClass.createException(oppId, 'ParkerLaneLoanController', 'upsertOppAssetsAndLiabilities', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return '[]';
        }
    }
    
    @auraEnabled
    public static String upsertOppAssetsAndLiabilitiesPL(List<FinServ__AssetsAndLiabilities__c> assetsList, List<FinServ__AssetsAndLiabilities__c> liabilitiesList, Id oppId, Boolean isOppUpdate, Boolean isShare, String creditCardscheck, String personalAndAutoLoanscheck, String OtherCommitmentscheck, Boolean skipSave){
        system.debug('creditCardscheck'+creditCardscheck);
        system.debug('personalAndAutoLoanscheck'+personalAndAutoLoanscheck);
        system.debug('OtherCommitmentscheck'+OtherCommitmentscheck); 
        Id assetRTypeId = Schema.SObjectType.FinServ__AssetsAndLiabilities__c.getRecordTypeInfosByName().get('Asset').getRecordTypeId();
        Id liabilityRTypeId = Schema.SObjectType.FinServ__AssetsAndLiabilities__c.getRecordTypeInfosByName().get('Liability').getRecordTypeId();
        Opportunity oppUpdate = [SELECT Id, Applicant_1__c, Applicant_2__c, Applicant_1__r.PersonContactId, Application_Sections__c, Current_Application_Sections__c, AccountId,
                                 Applicant_1__r.PersonContact.Email, Applicant_2__r.PersonContact.Email, RecordTypeId, Relationship_to_Applicant_2__c,
                                 Contact_1__r.FinServ__MaritalStatus__c, Contact_2__r.FinServ__MaritalStatus__c
                                 FROM Opportunity WHERE Id =: oppId];

        List<String> appSectionsList = getApplicationSections();
        List<String> emails = New  List<String>();
        List<Id> deletedIds = New  List<Id>();
        List<String> notOthersLiabilityList = New List<String>{'Credit Card / Store Card','Personal Loan','Auto Loan','Home Loan/Mortgage','Investment Home Loan'};
        
        if(String.isNotBlank(oppUpdate.Applicant_1__c)){
            emails.add(oppUpdate.Applicant_1__r.PersonContact.Email);
        }
        if(String.isNotBlank(oppUpdate.Applicant_2__c)){
            emails.add(oppUpdate.Applicant_2__r.PersonContact.Email);
        }

        Contact con=[SELECT Unit_Number__c, Suburb__c, Street_Type__c, Street_Number__c, Street__c, State__c, 
                     Residential_Address__c, Postal_Code__c, Is_Find_Address__c, FinServ__CountryOfResidence__c
                     FROM Contact WHERE Id =: oppUpdate.Applicant_1__r.PersonContactId];

        List<FinServ__AssetsAndLiabilities__c>upsertAssetsAndLiabilitiesList = new List<FinServ__AssetsAndLiabilities__c>();
        
        for(FinServ__AssetsAndLiabilities__c assLiab : assetsList){
            assLiab.FinServ__PrimaryOwner__c = oppUpdate.Applicant_1__c;
           
            assLiab.recordTypeId = assetRTypeId;
            if(assLiab.FinServ__AssetsAndLiabilitiesType__c == 'Home'){
                assLiab.Is_Address_Same__c = true;
            }
           
            upsertAssetsAndLiabilitiesList.add(assLiab);
        }
        
        for(FinServ__AssetsAndLiabilities__c assLiab : liabilitiesList){
            assLiab.FinServ__PrimaryOwner__c = oppUpdate.Applicant_1__c;
            if(!string.isBlank(assLiab.FinServ__AssetsAndLiabilitiesType__c)){
                if( assLiab.FinServ__AssetsAndLiabilitiesType__c.equalsIgnoreCase('Credit Card / Store Card')){
                    assLiab.Monthly_Repayment__c = assLiab.Limit__c * 0.03;
                    assLiab.Repayment_Frequency__c = 'Monthly'; 
                }                
            }
            assLiab.recordTypeId = liabilityRTypeId;
            upsertAssetsAndLiabilitiesList.add(assLiab);
            
            if(creditCardscheck.equalsIgnoreCase('No') && assLiab.FinServ__AssetsAndLiabilitiesType__c.equalsIgnoreCase('Credit Card / Store Card')){
                deletedIds.add(assLiab.Id);
            }else if(personalAndAutoLoanscheck.equalsIgnoreCase('No') && (assLiab.FinServ__AssetsAndLiabilitiesType__c.equalsIgnoreCase('Personal Loan') || assLiab.FinServ__AssetsAndLiabilitiesType__c.equalsIgnoreCase('Auto Loan') )){
                deletedIds.add(assLiab.Id);
            }else if(OtherCommitmentscheck.equalsIgnoreCase('No') && !notOthersLiabilityList.contains(assLiab.FinServ__AssetsAndLiabilitiesType__c)){
                deletedIds.add(assLiab.Id);
            }
        }
        String nextSection = appSectionsList[appSectionsList.indexOf(oppUpdate.Current_Application_Sections__c) + 1];
        
        try{
            upsert upsertAssetsAndLiabilitiesList;
            
            Map<Id,FinServ__AssetsAndLiabilities__c> assetsMap = New Map<Id,FinServ__AssetsAndLiabilities__c>();
            Map<Id,FinServ__AssetsAndLiabilities__c> liabilitiesMap = New Map<Id,FinServ__AssetsAndLiabilities__c>();
            List<FinServ__AssetsAndLiabilities__c>upsertLiabilitiesList = new List<FinServ__AssetsAndLiabilities__c>();
        
            for(FinServ__AssetsAndLiabilities__c assLiab : upsertAssetsAndLiabilitiesList){
                if(assLiab.RecordTypeId == assetRTypeId && assLiab.Property_Situation__c =='Own with mortgage'){
                    assetsMap.put(assLiab.Id, assLiab);
                }
            }
            
            for(FinServ__AssetsAndLiabilities__c assLiab : [SELECT Id, Asset_to_Liability__c FROM FinServ__AssetsAndLiabilities__c WHERE Asset_to_Liability__c IN: assetsMap.keySet()]){
                liabilitiesMap.put(assLiab.Asset_to_Liability__c, assLiab);
            }
           
            FinServ__AssetsAndLiabilities__c liab; 
            for(Id assId : assetsMap.keySet()){
                FinServ__AssetsAndLiabilities__c assLiab = assetsMap.get(assId);
                liab = new FinServ__AssetsAndLiabilities__c();
                liab.FinServ__PrimaryOwner__c = assetsMap.get(assId).FinServ__PrimaryOwner__c;
                liab.Name = assLiab.Name;
                liab.RecordTypeId = liabilityRTypeId;
                liab.Asset_to_Liability__c = assId;
                liab.Is_Find_Address__c = assLiab.Is_Find_Address__c;
                liab.Unit_Number__c = assLiab.Unit_Number__c;
                liab.Street_Number__c = assLiab.Street_Number__c;
                liab.Street__c = assLiab.Street__c;
                liab.State__c = assLiab.State__c;
                liab.Suburb__c = assLiab.Suburb__c;
                liab.Street_Type__c = assLiab.Street_Type__c;
                liab.Postal_Code__c = assLiab.Postal_Code__c;
                liab.Address__c = assLiab.Address__c;
                liab.Country__c = assLiab.Country__c;
                
                if(assLiab.FinServ__AssetsAndLiabilitiesType__c == 'Home'){
                    liab.FinServ__AssetsAndLiabilitiesType__c = 'Home Loan/Mortgage';
                  
                }else if(assLiab.FinServ__AssetsAndLiabilitiesType__c == 'Investment Property'){
                    liab.FinServ__AssetsAndLiabilitiesType__c = 'Investment Home Loan';  
                }
                if(liabilitiesMap.containsKey(assId)){
                    liab.Id = liabilitiesMap.get(assId).Id;
                }else{
                    liab.Id = NULL;
                }
                
                upsertLiabilitiesList.add(liab);
            }
            
            upsert upsertLiabilitiesList;
            
            if(isOppUpdate){
                if(oppUpdate.Application_Sections__c == oppUpdate.Current_Application_Sections__c){
                    oppUpdate.Application_Sections__c = nextSection;
                }
                oppUpdate.Current_Application_Sections__c = nextSection;
            }else{
                nextSection = oppUpdate.Current_Application_Sections__c;
            }

            update oppUpdate;
            
            setAssetLiabilityOwnership(oppId);
            
            for(integer i=0; i<deletedIds.size(); i++){
                if(deletedIds[i] == null){
                    deletedIds.remove(i);
                }
            }            
            if(deletedIds != null && deletedIds.size()> 0){
                Database.delete(deletedIds);    
            }
            
            if(!skipSave){
                system.debug('enter------'+skipSave);
                update New Contact(Id= con.Id, CreditCardsCommitments__c = creditCardscheck, OtherCommitments__c= OtherCommitmentscheck, PersonalAndAuto__c= personalAndAutoLoanscheck);
            }
            Boolean isMortgageApp = mortgageRTList.contains(oppUpdate.recordTypeId);
            if(isShare && !isMortgageApp){
                quote qt = [SELECT Id FROM Quote WHERE OpportunityId =: oppId AND Application__c = TRUE];
                sendApplication(oppId, oppUpdate.Applicant_1__r.PersonContactId, qt.Id, emails, 'Application Resume Later Email', false);
            }
            
            String path = '{\"CurrentSection\":\"'+ nextSection +'\", \"path\": '+getPath(nextSection, oppUpdate.Application_Sections__c, oppUpdate.RecordTypeId)+ '}';
            return path;
        }catch(exception e){
            UtilityClass.createException(oppId, 'ParkerLaneLoanController', 'upsertOppAssetsAndLiabilities', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            
            return '[]';
        }
    }
    
    public static void setAssetLiabilityOwnership(String oppId){
        Opportunity opp = [SELECT Id, Applicant_1__c, Applicant_2__c, Relationship_to_Applicant_2__c, Number_of_applicants__c
                           FROM Opportunity WHERE Id =: oppId];
        Map<Id, FinServ__AssetsAndLiabilities__c> assetsAndLiabilitiesMap = New Map<Id, FinServ__AssetsAndLiabilities__c>();
        List<FinServ__AssetsAndLiabilities__c> assetsAndLiabilitiesList = 
            [SELECT Id, RecordType.Name, FinServ__Ownership__c, FinServ__AssetsAndLiabilitiesType__c, Ownership_Share__c, 
             Other_Ownership_Share__c, FinServ__PrimaryOwner__c,FinServ__JointOwner__c, Asset_to_Liability__c
             FROM FinServ__AssetsAndLiabilities__c 
             WHERE FinServ__PrimaryOwner__c =: opp.Applicant_1__c OR FinServ__PrimaryOwner__c =: opp.Applicant_2__c ORDER BY RecordType.Name ] ;
        
        for(FinServ__AssetsAndLiabilities__c assLiab: assetsAndLiabilitiesList){

            assLiab.FinServ__PrimaryOwner__c = opp.Applicant_1__c;
            assLiab.Ownership_Share__c = 100;
            assLiab.Other_Ownership_Share__c = 0;
            assLiab.FinServ__JointOwner__c = NULL;
            
            if(String.isBlank( assLiab.FinServ__Ownership__c) || 
               assLiab.RecordType.Name == 'Liability' && String.isBlank( assLiab.Asset_to_Liability__c)){
                assLiab.FinServ__Ownership__c = opp.Number_of_applicants__c == 1 ? 'Applicant 1': 'Joint';
            }else if(assLiab.FinServ__Ownership__c == 'Applicant 2'){
                assLiab.FinServ__PrimaryOwner__c = opp.Applicant_2__c;
            }
            
            if(assLiab.FinServ__Ownership__c == 'Joint' || assLiab.FinServ__Ownership__c == 'Joint with Spouse'){
                assLiab.FinServ__JointOwner__c = opp.Applicant_2__c;
                assLiab.Ownership_Share__c = 50;
                assLiab.Other_Ownership_Share__c = 50;
            }
            
            if(assLiab.RecordType.Name == 'Liability' && String.isNotBlank( assLiab.Asset_to_Liability__c)){
                assLiab.FinServ__PrimaryOwner__c = assetsAndLiabilitiesMap.get(assLiab.Asset_to_Liability__c).FinServ__PrimaryOwner__c;
                assLiab.FinServ__JointOwner__c = assetsAndLiabilitiesMap.get(assLiab.Asset_to_Liability__c).FinServ__JointOwner__c;
                assLiab.Ownership_Share__c = assetsAndLiabilitiesMap.get(assLiab.Asset_to_Liability__c).Ownership_Share__c;
                assLiab.Other_Ownership_Share__c = assetsAndLiabilitiesMap.get(assLiab.Asset_to_Liability__c).Other_Ownership_Share__c;
                assLiab.FinServ__Ownership__c = assetsAndLiabilitiesMap.get(assLiab.Asset_to_Liability__c).FinServ__Ownership__c;
            }
            
            assetsAndLiabilitiesMap.put(assLiab.Id, assLiab);
        }
        
        update assetsAndLiabilitiesMap.values();
    }
    
    
    @auraEnabled
    public static void deleteRecordsByIds(List<Id> recordIdsList){
        database.delete(recordIdsList);
    }
    
    @auraEnabled
    public static void deleteAssetAndLibByIds(List<Id> recordIdsList){
       List<FinServ__AssetsAndLiabilities__c> assLiab = [SELECT Id, Asset_to_Liability__c FROM FinServ__AssetsAndLiabilities__c WHERE Asset_to_Liability__c IN: recordIdsList];
       list<id> parentOrchildId = new list<id>(); 
        for(FinServ__AssetsAndLiabilities__c obj : assLiab){
            parentOrchildId.add(obj.Id);
        }
        parentOrchildId.addAll(recordIdsList);
       database.delete(parentOrchildId);
       
    }
   
    
    @auraEnabled
    public static Map<String, Contact> getEmploymentDetails(Id recordId){
        Opportunity opp = [SELECT Applicant_1__c, Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId, RecordTypeId
                           FROM Opportunity WHERE Id =: recordId limit 1];
        Set<Id> conIds = new Set<Id>();
        if(opp.Applicant_1__c != null){
            conIds.add(opp.Applicant_1__r.PersonContactId);
        }
        if(opp.Applicant_2__c != null){
            conIds.add(opp.Applicant_2__r.PersonContactId);
        }
        Map<Id, Contact> conEmploymentMap =new Map<Id, Contact>([SELECT Name,FirstName, FinServ__CurrentEmployer__c, 
              FinServ__Occupation__c, FinServ__MaritalStatus__c, Email, Does_your_spouse_earn_an_income__c,
              spouse_s_approximate_annual_income__c, Primary_Employer_Job_Title__c, Primary_Employer_Name__c,
              What_is_spouse_s_primary_income_source__c,FinServ__NumberOfChildren__c,Is_Address_Same__c,Residential_Address__c,
              Unit_Number__c,Street_Number__c,Street__c,Street_Type__c,Suburb__c,State__c,Postal_Code__c,
              FinServ__CountryOfResidence__c,Child_Age__c,
             (SELECT Id, Name, FinServ__Occupation__c, FinServ__AnnualIncome__c, FinServ__EmployerAddress__c, 
              FinServ__EmployerPhoneNumber__c, FinServ__EmploymentStatus__c, Income_Frequency__c, Months__c,
              Years__c, Self_Employed_Type__c, Employment_Status_1_Previous__c, Employer_Name_1_Previous__c,
              Years_1_Previous__c, Months_1_Previous__c, Annual_Income_1_Previous__c, Occupation_1_Previous__c, 
              Employment_Status_2_Previous__c, Employer_Name_2_Previous__c,Years_2_Previous__c, Months_2_Previous__c, 
              Annual_Income_2_Previous__c, Occupation_2_Previous__c,Is_Find_Address__c, Is_Find_Address_1__c, Is_Find_Address_2__c, 
              Unit_Number__c, Unit_Number_1__c, Unit_Number_2__c, Street_Number__c, Street_Number_1__c, Street_Number_2__c, 
              Street__c, Street_1__c, Street_2__c, Street_Type__c, Street_Type_1__c, Street_Type_2__c, 
              Suburb__c, Suburb_1__c, Suburb_2__c, State__c, State_1__c, State_2__c, Postal_Code__c, Postal_Code_1__c, Postal_Code_2__c, 
              Country__c, Country_1__c, Country_2__c, Ownership_Share__c, ABN__c, Date_ABN_registered__c, Are_you_registered_for_GST__c, 
              Last_year_net_profit__c, Previous_year_net_profit__c, Pay_yourself_salary__c, Annual_salary_before_tax__c, 
              Does_your_spouse_earn_an_income__c, spouse_approximate_annual_income__c, Description__c, Address_1_Previous__c,
              Address_2_Previous__c, Regularly_work_Overtime__c, Work_Overtime_amount__c, Work_Overtime_Frequency__c, 
              Regularly_receive_Commission_or_Bonus__c, Commission_or_Bonus_amount__c, Commission_or_Bonus_Frequency__c,
              Regularly_Receive_Allowance__c, Allowance_Amount__c, Allowance_Frequency__c, Provide_a_Company_Car__c,
              Job_Title__c, Minimum_hours_per_week__c, Ownership_Share_Type__c,Same_as_home_address__c,Income_Frequency_1__c
              FROM FinServ__Employment__r  ORDER BY Is_Primary__c desc)
              FROM Contact WHERE Id in :conIds]);
        Map<String, Contact> conMap = new Map<String, Contact>();
        if(opp.Applicant_1__c != null){
            conMap.put('applicant1', conEmploymentMap.get(opp.Applicant_1__r.PersonContactId));
        }
        if(opp.Applicant_2__c != null){
            conMap.put('applicant2', conEmploymentMap.get(opp.Applicant_2__r.PersonContactId));
        }

        return conMap;
    }
    
    @auraEnabled
    public static String upsertEmploymentDetails(Contact con1, Contact con2, List<FinServ__Employment__c> employmentDetailsList1, List<FinServ__Employment__c> employmentDetailsList2, Id oppId, Boolean isOppUpdate, Boolean isShare){
        
        Set<Id> toDeleteRecordsSet = new Set<Id>();
        Opportunity oppUpdate = [SELECT Id, Application_Sections__c, Current_Application_Sections__c, AccountId, RecordTypeId 
                                 FROM Opportunity WHERE Id =: oppId];
        List<Contact> consList = new List<Contact>();
        List<FinServ__Employment__c> empsList = new List<FinServ__Employment__c>();
        List<String> appSectionsList = getApplicationSections();
        String nextSection = appSectionsList[appSectionsList.indexOf(oppUpdate.Current_Application_Sections__c) + 1];
        
        for(FinServ__Employment__c emp: employmentDetailsList1){
            emp.Months__c=0;
            if(emp.Years__c == 6){
                emp.Months__c = emp.Years__c;
                emp.Years__c = 0;//This is added for year to month when we select 6 month from component
            }
           
            if(emp.Is_Primary__c){
                con1.Primary_Employer_Job_Title__c = emp.Job_Title__c;
                con1.Primary_Employer_Name__c = emp.Name;
            }
        }
        
        consList.add(con1);          
        List<String> emails = New  List<String>();
        emails.add(con1.Email);
        
        if(con2 !=null){
            for(FinServ__Employment__c emp: employmentDetailsList2){
                emp.Months__c=0;
                if(emp.Years__c == 6){
                    emp.Months__c = emp.Years__c;
                    emp.Years__c = 0;//This is added for year to month when we select 6 month from component
                }
                if(emp.Is_Primary__c){
                    con2.Primary_Employer_Job_Title__c = emp.Job_Title__c;
                    con2.Primary_Employer_Name__c = emp.Name;
                }
            }
            consList.add(con2);
            emails.add(con2.Email); 
        } 
        empsList.addAll(employmentDetailsList1);
        if(employmentDetailsList2 !=null && !employmentDetailsList2.isEmpty()) 
            empsList.addAll(employmentDetailsList2);
        
        try{
            for(FinServ__Employment__c emp : empsList){
                if(String.isNotBlank(emp.Id))toDeleteRecordsSet.add(emp.Id);
            }
            List<FinServ__Employment__c> toDeleteEmpsList = New List<FinServ__Employment__c>();
            Map<Id, Contact> conEmploymentMap = New Map<Id, Contact>([SELECT Id, 
                                                                      (SELECT Id FROM FinServ__Employment__r WHERE (NOT id IN :toDeleteRecordsSet))
                                                                      FROM Contact WHERE Id in :consList]);
            
            for(Id id: conEmploymentMap.keySet()){
                toDeleteEmpsList.addAll(conEmploymentMap.get(id).FinServ__Employment__r);
            }
            
            delete toDeleteEmpsList;
            
            upsert consList;
            upsert empsList;
            
            if(isOppUpdate){
                if(oppUpdate.Application_Sections__c == oppUpdate.Current_Application_Sections__c){
                    oppUpdate.Application_Sections__c = nextSection;
                }
                oppUpdate.Current_Application_Sections__c = nextSection;
            }else{
                nextSection = oppUpdate.Current_Application_Sections__c;
            }
            
            update oppUpdate;
            
            Boolean isMortgageApp = mortgageRTList.contains(oppUpdate.recordTypeId);
            if(isShare && !isMortgageApp){
                quote qt = [SELECT Id FROM Quote WHERE OpportunityId =: oppId AND Application__c = TRUE];
                sendApplication(oppId, con1.Id, qt.Id, emails, 'Application Resume Later Email', false);
            }
            
            String path = '{\"CurrentSection\":\"'+ nextSection +'\", \"path\": '+getPath(nextSection, oppUpdate.Application_Sections__c, oppUpdate.RecordTypeId)+ '}';
            return path;
        }catch(exception e){
            UtilityClass.createException(oppId, 'ParkerLaneLoanController', 'upsertEmploymentDetails', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                       e.getTypeName(), ''+e.getCause());
            return '[]';
        }
    }
    
    @auraEnabled
    public static ContactWithOpp getLivingExpensesDetails(Id recordId){
        ContactWithOpp cwithopp = new ContactWithOpp();  
        Opportunity opp = [SELECT Applicant_1__r.PersonContactId,RecordTypeid,Living_Expense_Group_Type__c,Lender__c FROM Opportunity WHERE Id =: recordId];
        if(opp.Living_Expense_Group_Type__c == 'Limited personal'){
            cwithopp.isLimited = true;
        }else{
            cwithopp.isLimited = false; 
        }
        
        List<Contact> conList = 
            [SELECT FinServ__CurrentEmployer__c, FinServ__Occupation__c, Home_Loan_repayment__c, Investment_Property_Loan_repayment__c,
             Credit_Card_payment_3_of_total_limit__c, Other_loans_and_or_debt_commitments__c, Rental_or_Board_paid__c, Utilities__c,
             Connections_Phone_Mobile_Internet_C__c, Education_ChildCare_SchoolFees_Uniform__c, Food_Groceries_Meat_Fruit_Vegetabl__c,
             Transport_Public_Petrol_Registration__c, Medical_Private_Health_Insurance_Ong__c, Insurances_Home_Personal_Voluntary__c,
             Household_Purchases_and_Maintenance__c, Entertainment_Dining_Out_Movies_Gift__c, Sports_Hobbies_and_Memberships__c,
             Gambling_Betting_and_Lottery__c, Other_Regular_Expenditure__c, Total_Living_Expenses__c, Email, Investment_property_utilities__c,
             Education_public_and_private__c, Maintenance_If_pay_child_maintenance__c, HECS_HELP_debt__c, Clothing_and_personal_care__c,
             Personal_Insurances_life_and_income_pro__c, FirstName, LastName, Groceries_transport__c, Clothing_and_entertainment__c,
             Insurance_and_medical__c, Education_and_childcare__c,FinServ__MaritalStatus__c,FinServ__NumberOfChildren__c,(select id,Is_Primary__c,FinServ__EmploymentStatus__c from FinServ__Employment__r WHERE Is_Primary__c = true LIMIT 1)
             FROM Contact 
             WHERE Id =: opp.Applicant_1__r.PersonContactId];
        
        cwithopp.con = conList[0];
        
        if(conList.isEmpty()){
            return NULL;
        }
        
        return cwithopp;
    }
    
    @auraEnabled
    public static String upsertLivingExpensesDetails(Contact con, Id oppId, Boolean isOppUpdate, Boolean isShare){

       Opportunity oppUpdate = [SELECT Id, Application_Sections__c, Current_Application_Sections__c,Lender__c, AccountId, RecordTypeId 
                                FROM Opportunity WHERE Id =: oppId];

        List<String> appSectionsList = getApplicationSections();
        integer nextNo = 1;
        if(!mortgageRTList.contains(oppUpdate.recordTypeId)){
            nextNo = 4;
        }
        String nextSection = appSectionsList[appSectionsList.indexOf(oppUpdate.Current_Application_Sections__c) + nextNo];
        
        try{
            if(con != NULL && con.Id != NULL){ 
                if(oppUpdate.Lender__c == 'Community First Credit Union' && con.Groceries_transport__c != null){
                    con.Food_Groceries_Meat_Fruit_Vegetabl__c = con.Groceries_transport__c*70/100;
                    con.Transport_Public_Petrol_Registration__c = con.Groceries_transport__c*30/100;   
                }
                update con; 
            }
            
            if(isOppUpdate){
                if(oppUpdate.Application_Sections__c == oppUpdate.Current_Application_Sections__c){
                    oppUpdate.Application_Sections__c = nextSection;
                }
                oppUpdate.Current_Application_Sections__c = nextSection;
            }else{
                nextSection = oppUpdate.Current_Application_Sections__c;
            }
            
            update oppUpdate;
            
            Boolean isMortgageApp = mortgageRTList.contains(oppUpdate.recordTypeId);
            if(isShare && !isMortgageApp){
                quote qt = [SELECT Id FROM Quote WHERE OpportunityId =: oppId AND Application__c = TRUE];
                sendApplication(oppId, con.Id, qt.Id, New List<String>{con.Email}, 'Application Resume Later Email', false);
            }
            
            String path = '{\"CurrentSection\":\"'+ nextSection +'\", \"path\": '+getPath(nextSection, oppUpdate.Application_Sections__c, oppUpdate.RecordTypeId)+ '}';
            return path;
        }catch(exception e){
            UtilityClass.createException(oppId, 'ParkerLaneLoanController', 'upsertLivingExpensesDetails', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                       e.getTypeName(), ''+e.getCause());
            return '[]';
        }
    }
    
    @auraEnabled
    public static Anticipated_Changes_to_Circumstance__c getAnticipatedChangesCircumstancesDetails(Id recordId){
        
       List<Anticipated_Changes_to_Circumstance__c> anticipatedChangesCircumstance = 
            [SELECT Id FROM Anticipated_Changes_to_Circumstance__c 
             WHERE Opportunity__c =: recordId LIMIT 1];
        if(anticipatedChangesCircumstance.size()==0){
            insert new Anticipated_Changes_to_Circumstance__c(Opportunity__c = recordId);
        }
        anticipatedChangesCircumstance = 
            [SELECT Id, Additional_income_source__c, Additional_income_source_Description__c, Applicant_1_planning_to_retire_Age__c,
             Applicant_2_planning_to_retire_Age__c, Co_applicant_s_income__c, Co_applicant_s_income_Description__c, Do_you_plan_or_anticipate_changes__c,
             Downsizing_home__c, Downsizing_home_Description__c, End_of_contract_loss_of_emp__c, End_of_contract_loss_of_emp_Description__c,
             Extended_unpaid_Leave__c, Extended_unpaid_Leave_Description__c,Income_from_other_investments__c, Income_from_other_investment_Description__c,
             Increased_debt_repayment__c, Increased_debt_repayment_Description__c, Large_expenditure__c, Large_expenditure_Description__c, Leaving_employment__c,
             Leaving_employment_Description__c, Loan_into_retirements_Other__c, Loan_into_retirements_Other_Description__c, Medical_treatment_illness__c,
             Medical_treatment_illness_Description__c, Ongoing_income_from_your_superannuation__c, Ongoing_income_superannuation_descriptio__c,
             Other_anticipate_changes__c, Other_anticipate_changes_Description__c, Reduce_expenditure__c, Reduce_expenditure_Description__c, Reduced_income__c,
             Reduced_income_Description__c, Reducing_loan_term__c, Reducing_loan_term_Description__c, Relevant_options_Other__c, Relevant_options_Other_Description__c,
             Repayment_of_loan_prior_to_retirement__c, Repayment_of_loan_prior_retirement_Desc__c, Sale_of_assets__c, Sale_of_assets_Description__c, Savings__c,
             Savings_Description__c, Savings_and_or_Superannuation__c, Savings_Superannuation_Description__c, Superannuation_lump_sum_retirement__c, 
             Superannuation_lump_sum_retirement_Desc__c, Sale_of_assets_Retirement__c, Sale_of_assets_Retirement_Description__c, Co_applicant_s_income_Retirement__c,
             Co_applicant_s_income_Retirement_Desc__c, Opportunity__r.Applicant_1__r.PersonBirthdate, Opportunity__r.Applicant_2__r.PersonBirthdate,
             Opportunity__r.Number_of_applicants__c
             FROM Anticipated_Changes_to_Circumstance__c 
             WHERE Opportunity__c =: recordId LIMIT 1];
        return anticipatedChangesCircumstance[0];
    }
    
    @auraEnabled
    public static String upsertAnticipatedChangesCircumstancesDetails(Anticipated_Changes_to_Circumstance__c acCircumtanceDetail, Id oppId, Boolean isOppUpdate, Boolean isShare){
        Opportunity oppUpdate = [SELECT Id, Application_Sections__c, Current_Application_Sections__c, AccountId,
                                 Applicant_1__r.PersonContact.Email, Applicant_1__r.PersonContactId, RecordTypeId
                                FROM Opportunity WHERE Id =: oppId];
        List<String> appSectionsList = getApplicationSections();
        String nextSection = appSectionsList[appSectionsList.indexOf(oppUpdate.Current_Application_Sections__c) + 1];
        
        try{
            upsert acCircumtanceDetail;
            
            if(isOppUpdate){
                if(oppUpdate.Application_Sections__c == oppUpdate.Current_Application_Sections__c){
                    oppUpdate.Application_Sections__c = nextSection;
                }
                oppUpdate.Current_Application_Sections__c = nextSection;
            }else{
                nextSection = oppUpdate.Current_Application_Sections__c;
            }
            
            update oppUpdate;
            
            Boolean isMortgageApp = mortgageRTList.contains(oppUpdate.recordTypeId);
            if(isShare && !isMortgageApp){
                quote qt = [SELECT Id FROM Quote WHERE OpportunityId =: oppId AND Application__c = TRUE];
                sendApplication(oppId, oppUpdate.Applicant_1__r.PersonContactId, qt.Id, New List<String>{oppUpdate.Applicant_1__r.PersonContact.Email}, 'Application Resume Later Email', false);
            }
            
            String path = '{\"CurrentSection\":\"'+ nextSection +'\", \"path\": '+getPath(nextSection, oppUpdate.Application_Sections__c, oppUpdate.RecordTypeId)+ '}';
            return path;
        }catch(exception e){
            UtilityClass.createException(oppId, 'ParkerLaneLoanController', 'upsertAnticipatedChangesCircumstancesDetails', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                       e.getTypeName(), ''+e.getCause());
            return '[]';
        }
    }
    
    @auraEnabled
    public static OpportunityContacts getPreferences(Id recordId){

        if (String.isBlank(recordId)) return null;
        
        OpportunityContacts oppCons = new OpportunityContacts();
        
        Opportunity opp = new Opportunity();
        try{
            opp = [SELECT Id, Number_of_applicants__c, Application_Sections__c, Current_Application_Sections__c, AccountId,
                   Applicant_1__c, Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId,
                   Primary_reason_for_installing_solar__c, Type_of_interest_rate__c, Preferred_repayment_frequency__c, 
                   Expect_to_remain_in_the_credit_contract__c, Any_lenders_you_don_t_wish_to_deal_with__c, 
                   Have_adequate_Life_Insurance__c, Have_adequate_Debt_Protection_Insurance__c, Have_adequate_Income_Protection__c,
                   Have_adequate_insurance__c, Would_you_like_us_to_arrange_a_meeting__c, What_is_the_intended_use_of_the_funds__c,
                   Loan_amount_you_want_to_apply_for__c, Term_you_wish_to_apply_for_in_years__c, preference_for_the_type_of_lender__c,
                   Do_you_have_a_fixed_term_in_mind__c, locking_rate_at_the_time_of_application__c, Interested_in_Fixed_rate__c,
                   Interested_in_Variable_rate__c, Interested_in_Part_fixed_and_variable__c, Interest_only_repayments__c,
                   Interest_in_advance__c, Interested_in_Offset_account__c, Interested_in_Redraw__c, Interested_in_Access_to_a_branch_network__c,
                   Other_features_you_are_interested_in__c, Any_product_types_you_are_interested_in__c, RecordTypeId, Fixed_Term_Preference__c,
                   (SELECT Id, Name, Amount__c, Description__c FROM Loan_Purposes__r)
                   FROM Opportunity WHERE Id =: recordId limit 1];
            oppCons.opp = opp;
            set<Id> conIds = new Set<Id>();
            if(String.isNotBlank(opp.Applicant_1__c)){
                conIds.add(opp.Applicant_1__r.PersonContactId);
            }
            if(String.isNotBlank(opp.Applicant_2__c)){
                conIds.add(opp.Applicant_2__r.PersonContactId);
            }
            Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Rate_current_Job_Security__c, Judgements_or_legal_proceedings_recorded__c, 
                                                                 Description_Judgement_legal_proceeding__c, Credit_commitments_up_to_date__c, 
                                                                 Description_Credit_commitment_up_to_date__c, Your_income_in_the_next_6_12_months__c, 
                                                                 Decription_income_in_next_6_12_months__c, Materially_in_the_next_6_12_months__c, 
                                                                 Description_materially_next_6_12_months__c, Income_expenses_in_the_next_6_12_months__c, 
                                                                 Description_Income_expenses_6_12_months__c, Email, Are_you_tax_resident_of_foreign_country__c,
                                                                 Description_resident_of_foreign_country__c, rising_interest_rates__c, FirstName, LastName
                                                                 FROM Contact WHERE Id in: conIds]);
            
            oppCons.contact1 = contactsMap.get(opp.Applicant_1__r.PersonContactId);
            oppCons.contact2 = contactsMap.get(opp.Applicant_2__r.PersonContactId);
            
            return oppCons;
        }catch(exception e){
            UtilityClass.createException(recordId, 'ParkerLaneLoanController', 'getPreferences', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                       e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @auraEnabled
    public static String upsertPreferences(Contact con1, Contact con2, Opportunity opp, List<Loan_Purpose__c> loanPurposesList, Boolean isOppUpdate, Boolean isShare){

        Opportunity oppUpdate = new Opportunity();

        List<String> appSectionsList = getApplicationSections();
        oppUpdate = opp;
        List<String> emails = New  List<String>();
        
        List<Contact>upsertConsList = new List<Contact>();
        if(oppUpdate.Number_of_applicants__c == 1){
            upsertConsList.add(con1);
            emails.add(con1.Email);
        }else if(oppUpdate.Number_of_applicants__c == 2){
            upsertConsList.add(con1);
            upsertConsList.add(con2);
            emails.add(con1.Email);
            emails.add(con2.Email);
        }
        integer nextNo = 1;
        if(!mortgageRTList.contains(opp.recordTypeId)){
            nextNo = 3;
        }
        String nextSection = appSectionsList[appSectionsList.indexOf(oppUpdate.Current_Application_Sections__c) + nextNo];
        
        try{
            update upsertConsList;
            if(loanPurposesList != Null) upsert loanPurposesList;
            String currAppSections = [SELECT Id, Current_Application_Sections__c FROM Opportunity WHERE Id =: opp.Id].Current_Application_Sections__c;

            if(isOppUpdate){
                if(oppUpdate.Application_Sections__c == currAppSections){
                    oppUpdate.Application_Sections__c = nextSection;
                }
            }else{
                nextSection = currAppSections;
            }
            oppUpdate.Current_Application_Sections__c = nextSection;
            update oppUpdate;
            
            Boolean isMortgageApp = mortgageRTList.contains(oppUpdate.recordTypeId);
            if(isShare && !isMortgageApp){
                quote qt = [SELECT Id FROM Quote WHERE OpportunityId =: opp.Id AND Application__c = TRUE];
                sendApplication(opp.Id, con1.Id, qt.Id, emails, 'Application Resume Later Email', false);
            }
            
            String path = '{\"CurrentSection\":\"'+ nextSection +'\", \"path\": '+getPath(nextSection, oppUpdate.Application_Sections__c, oppUpdate.RecordTypeId)+ '}';
            return path;
        }catch(exception e){
            UtilityClass.createException(opp.Id, 'ParkerLaneLoanController', 'upsertPreferences', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                       e.getTypeName(), ''+e.getCause());
            return '[]';
        }
    }
    
    @auraEnabled
    public static FinServ__FinancialGoal__c getGoals(Id recordId){
        List<FinServ__FinancialGoal__c> goalList = 
            [SELECT Id, Control_of_your_finances__c, Find_ways_to_save_money__c, Plan_to_achieve_your_financial_goals__c,
             Plan_to_repay_debt_quickly__c, Rates_of_interest_you_currently_pay__c, Take_action_to_save_money__c, Track_and_manage_your_finances__c,
             What_is_your_stage_in_life__c, Which_financial_priorities_relevant_you__c, Which_life_events_are_relevant_to_you__c,
             Why_did_you_chose_Parker_Lane__c, Is_Not_Applicable_For_Life_Event__c, Is_Not_Applicable_For_financial_priority__c,
             Description_struggle_to_meet_houshold__c,Do_you_struggle_to_meet_your_household__c,Would_you_describe_yourself__c,Description_Would_you_describe_yourself__c,
             household_expense_in_the_next_6_12_month__c,Description_exp_in_the_next_6_12_month__c,Do_you_have_an_adequate_plan__c,
             Description_Do_you_have_an_adequate_plan__c,preferred_repayment_frequency__c,Finish_this_sentance_i_get_annoyed__c
            
             FROM FinServ__FinancialGoal__c 
             WHERE FinServ__PrimaryOwner__c in (SELECT Applicant_1__c FROM Opportunity WHERE Id =: recordId)];
        FinServ__FinancialGoal__c goal = New FinServ__FinancialGoal__c();
        if(!goalList.isEmpty()){
            goal = goalList[0];
        }
        return goal;
    }
       
    
    @auraEnabled
    public static String upsertGoals(FinServ__FinancialGoal__c goal, Id oppId, Contact con1, Contact con2, Boolean isOppUpdate, Boolean isShare){
        try{
        Opportunity oppUpdate = [SELECT Id,Applicant_1__r.is_Email_verified_for_VOI__pc,Applicant_2__r.is_Email_verified_for_VOI__pc,Applicant_2__r.Firstname,Applicant_2__r.Name,Applicant_1__r.Name,Applicant_2__r.PersonContactId,Purpose__c,Applicant_2__r.Phone, Name,Applicant_2__c,Application_Sections__c, Current_Application_Sections__c, AccountId, Applicant_1__c,
                                 Applicant_1__r.PersonContactId, Applicant_1__r.PersonContact.Email, StageName, RecordTypeId,
                                 Number_of_applicants__c,
                                 (SELECT Id, Lead__c, Lender__c, Purpose__c  FROM Quotes WHERE Application__c = TRUE)
                                 FROM Opportunity WHERE Id =: oppId];
        List<Contact>upsertConsList = new List<Contact>();
        
        OpportunityTriggerHandler.isByPassPDF = true;
        oppUpdate.StageName='CPA Done';
        update oppUpdate;
        OpportunityTriggerHandler.isByPassPDF = False;		
        
        Quote qt = New Quote();        
        Boolean isMortgageApp = mortgageRTList.contains(oppUpdate.recordTypeId);

        if(!isMortgageApp){
            if(oppUpdate.Number_of_applicants__c == 1){
                upsertConsList.add(con1);
            }else if(oppUpdate.Number_of_applicants__c == 2){
                upsertConsList.add(con1);
                upsertConsList.add(con2);
            }
            qt = oppUpdate.Quotes[0];
        }
        List<String> appSectionsList = getApplicationSections();
        
        String isRedirect = 'No';
        String nextSection = '';
        
        if(isMortgageApp){
            nextSection = appSectionsList[appSectionsList.indexOf('Standard Document Upload')]; 
        }else{
            nextSection = appSectionsList[appSectionsList.indexOf('VOI')]; 
        }

        String url ='';
        
            goal.FinServ__PrimaryOwner__c = oppUpdate.Applicant_1__c;
            upsert goal;
            if(!upsertConsList.isEmpty()) update upsertConsList;
            
            if(!isMortgageApp && String.isNotBlank(qt.Lead__c)){
                Lead lead = New Lead();
                lead.Id = qt.Lead__c;
                lead.Status = 'PA Completed';
                update lead;
            }

            
            if('Goals & Objectives'.equalsIgnoreCase(oppUpdate.Current_Application_Sections__c) && !isMortgageApp){
                string URLVOI = checkVOIConditions(oppUpdate);

                url = URLVOI;
                isRedirect = 'Yes';
    
            }             

            if('Goals & Objectives'.equalsIgnoreCase(oppUpdate.Current_Application_Sections__c) && isMortgageApp){
                url = String.valueof(System.URL.getSalesforceBaseURL().toExternalForm()) + '/supportingDocument/?oppId=' + oppId;
            }
            
            if(isShare && !isMortgageApp){
                sendApplication(oppId, oppUpdate.Applicant_1__r.PersonContactId, qt.Id, New List<String>{oppUpdate.Applicant_1__r.PersonContact.Email}, 'Application Resume Later Email', false);
                url = '';
            }
            
            if(url == ''){
                return '[]';
            }
            if(!isMortgageApp){
                if(isOppUpdate){
                    if(oppUpdate.Application_Sections__c == oppUpdate.Current_Application_Sections__c){
                        oppUpdate.Application_Sections__c = nextSection;
                    }
                    oppUpdate.Current_Application_Sections__c = nextSection;
                }else{
                    nextSection = oppUpdate.Current_Application_Sections__c;
                }
            }
            oppUpdate.Document_Redirect_URL__c  = url; 
            oppUpdate.stageName = 'Packs Out';
            update oppUpdate;
            
            String path = '{\"CurrentSection\":\"'+ nextSection +'\",\"url\":\"'+ url +'\",\"isRedirect\":\"'+ isRedirect +'\", \"path\": '+getPath(nextSection, oppUpdate.Application_Sections__c, oppUpdate.RecordTypeId)+ '}';
            return path;
            //return url;
        }catch(exception e){
            UtilityClass.createException(oppId, 'ParkerLaneLoanController', 'upsertGoals', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                       e.getTypeName(), ''+e.getCause());
            return '[]';
        }
    }

    public static string checkVOIConditions(opportunity oppUpdate){
       try{
            string IntrandomNumber1 = string.valueOf(Math.round((Math.random() * (900000) + 100000)));
            string URLVOI = System.Label.baseUrl + 'DigitalSigning?oppId=' + oppUpdate.Id + '&conId=' + oppUpdate.Applicant_1__r.PersonContactId + '&r='+ IntrandomNumber1;            
            string SecureCodeOriginal = string.valueOf(Math.round((Math.random() * (9000) + 1000)));
            
            string app1Id = oppUpdate.Applicant_1__r.PersonContactId;
            string app2Id = '';
            if(oppUpdate.Applicant_2__c != null){
                app2Id = oppUpdate.Applicant_2__r.PersonContactId;
            }
            list<voi_Status__c> OldvoiList = new List<voi_Status__c>();
            Boolean sentFullForAppOne = false;
            Boolean sentEsingForAppOne = false;

            for(voi_Status__c vs : [select Id,link_Expire_code__c, Name,Case_Status__c, contact__c from VOi_status__c WHERE contact__r.id =: app1Id order by CreatedDate DESC LIMIT 1]){
                if(vs.Case_Status__c == 'Sent' || vs.Case_Status__c == 'Delivered' || vs.Case_Status__c == 'Rejected'){
                    vs.link_Expire_code__c = '';
                    vs.Case_Status__c = 'Rejected';
                    OldvoiList.add(vs);
                    sentFullForAppOne = true;
                }
                if(vs.Case_Status__c == 'Submitted' || vs.Case_Status__c == 'Verified'){
                    sentEsingForAppOne = true;
                }
            }

            if(OldvoiList != null && OldvoiList.size() > 0){
                update OldvoiList;
            }


            if(sentEsingForAppOne || sentFullForAppOne){
                VOI_Detail__c voi  = new VOI_Detail__c();
                voi.Secure_Code_Orignal__c = SecureCodeOriginal;
                voi.Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
                voi.opportunity__c = oppUpdate.Id;
                insert voi;

                VOI_Status__c obj = new VOI_Status__c();
                obj.Opportunity__c = oppUpdate.id;
                obj.Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
                obj.Case_Status__c = 'Sent';
                obj.VOI_Detail__c = voi.id;
                obj.link_Expire_code__c = IntrandomNumber1;
                if(sentFullForAppOne){
                    obj.VOI_Type_For__c = 'FULL';
                    obj.Current_VOI_section__c = 'Email Verificaiton';
                }
                if(sentEsingForAppOne){
                    obj.VOI_Type_For__c = 'E-SIGN';
                    obj.Current_VOI_section__c = 'CQP';
                }
                
                obj.VOI_URL__c = URLVOI;
                
                insert obj;
            }else{
                VOI_Detail__c voi  = new VOI_Detail__c();
                voi.Secure_Code_Orignal__c = SecureCodeOriginal;
                voi.Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
                voi.opportunity__c = oppUpdate.Id;
                insert voi;

                VOI_Status__c obj = new VOI_Status__c();
                obj.Opportunity__c = oppUpdate.id;
                obj.Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
                obj.Case_Status__c = 'Sent';
                obj.VOI_Detail__c = voi.id;
                obj.link_Expire_code__c = IntrandomNumber1;                 
                obj.VOI_Type_For__c = 'FULL';
                obj.Current_VOI_section__c = 'Email Verificaiton';                               
                obj.VOI_URL__c = URLVOI;
                
                insert obj;
            }


            

            if(oppUpdate.applicant_2__c != null){
                string IntrandomNumber2 = string.valueOf(Math.round((Math.random() * (900000) + 100000)));
                string URLVOI2 = System.Label.baseUrl + 'DigitalSigning?oppId=' + oppUpdate.Id + '&conId=' + oppUpdate.Applicant_2__r.PersonContactId + '&r='+ IntrandomNumber2;            
                string SecureCodeOriginal2 = string.valueOf(Math.round((Math.random() * (9000) + 1000)));
                list<voi_Status__c> OldvoiListApp2 = new List<voi_Status__c>();
                Boolean sentFullForAppTwo = false;
                Boolean sentEsingForAppTwo = false;

                for(voi_Status__c vs : [select Id,link_Expire_code__c, Name,Case_Status__c, contact__c from VOi_status__c WHERE contact__r.id =: app2Id order by CreatedDate DESC LIMIT 1]){
                    if(vs.Case_Status__c == 'Sent' || vs.Case_Status__c == 'Delivered' || vs.Case_Status__c == 'Rejected'){
                        vs.link_Expire_code__c = '';
                        vs.Case_Status__c = 'Rejected';
                        OldvoiListApp2.add(vs);
                        sentFullForAppTwo = true;
                    }
                    if(vs.Case_Status__c == 'Submitted' || vs.Case_Status__c == 'Verified'){
                        sentEsingForAppTwo = true;
                    }
                }

                if(OldvoiListApp2 != null && OldvoiListApp2.size() > 0){
                    update OldvoiListApp2;
                }
    
    
                if(sentEsingForAppTwo || sentFullForAppTwo){
                    VOI_Detail__c voi1  = new VOI_Detail__c();
                    voi1.Secure_Code_Orignal__c = SecureCodeOriginal2;
                    voi1.Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
                    voi1.opportunity__c = oppUpdate.Id;
                    insert voi1;
            
                    VOI_Status__c obj1 = new VOI_Status__c();
                    obj1.Opportunity__c = oppUpdate.Id;
                    obj1.Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
                    obj1.Case_Status__c = 'Sent';
                    obj1.VOI_Detail__c = voi1.id;
                    obj1.link_Expire_code__c = IntrandomNumber2;
                    if(sentFullForAppTwo){
                        obj1.VOI_Type_For__c = 'FULL';
                        obj1.Current_VOI_section__c = 'Email Verificaiton';
                    }
                    if(sentEsingForAppTwo){
                        obj1.VOI_Type_For__c = 'E-SIGN';
                        obj1.Current_VOI_section__c = 'CQP';
                    }
                    obj1.VOI_URL__c = URLVOI2;
                    
                    insert obj1;
                    SendEmailofVOIforApp2(obj1.id, oppUpdate.Applicant_2__r.PersonContactId);
                   	SMSforApp2(oppUpdate, URLVOI2);
                }
                else{
                    VOI_Detail__c voi1  = new VOI_Detail__c();
                    voi1.Secure_Code_Orignal__c = SecureCodeOriginal2;
                    voi1.Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
                    voi1.opportunity__c = oppUpdate.Id;
                    insert voi1;
            
                    VOI_Status__c obj1 = new VOI_Status__c();
                    obj1.Opportunity__c = oppUpdate.Id;
                    obj1.Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
                    obj1.Case_Status__c = 'Sent';
                    obj1.VOI_Detail__c = voi1.id;
                    obj1.link_Expire_code__c = IntrandomNumber2;
                    obj1.VOI_Type_For__c = 'FULL';
                    obj1.Current_VOI_section__c = 'Email Verificaiton';
                    obj1.VOI_URL__c = URLVOI2;
                    
                    insert obj1;
                    SendEmailofVOIforApp2(obj1.id, oppUpdate.Applicant_2__r.PersonContactId);
                    SMSforApp2(oppUpdate, URLVOI2); 
                }

            }
            return URLVOI;
        }catch(Exception e){
            UtilityClass.createException('', 'ParkerLaneLoanController', 'checkVOIConditions', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                e.getTypeName(), ''+e.getCause());
                return null;
        }

    } 
    
    public static void SendEmailofVOIforApp2(string vsId, string conId){
        try{
            contact con = [Select id,Name,Session_Start_Time__c,voi_Email_Verification_Code__c,Email,Count__c, Phone, PhoneForPortal__c from contact where id =: conId LIMIT 1];         
            VOI_status__c voi = new VOI_status__c();
            for(VOI_status__c vois : [Select Id,opportunity__r.Applicant_1__r.name,opportunity__r.Purpose__c,VOI_Detail__r.id,VOI_URL__c,contact__r.Email,contact__r.FirstName,Current_VOI_section__c,VOI_Type_For__c, name,VOI_Detail__c,contact__r.name, Skip_VOI__c From VOI_status__c WHERE Id =: vsId order by createddate DESC LIMIT 1]){
                voi= vois;
            } 
            
            OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address =:UtilityClass.adminEmail];
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<string> sendTo = new List<string>();
            if(con.Email != Null){
                sendTo.add(con.Email);
            }
            mail.setToAddresses(sendTo);
            if(owea.size() > 0){
                mail.setorgWideEmailAddressId(Owea.get(0).Id);
            }
            mail.setUseSignature(false);
            mail.setTargetObjectId(con.id);
            mail.Setwhatid(voi.id); 
            mail.setSaveAsActivity(true);
            mail.setTreatTargetObjectAsRecipient(false);
            EmailTemplate et=[Select id, Subject from EmailTemplate where Name = 'EmailToApplicantForVOI']; 
            mail.setTemplateId(et.id);
            mails.add(mail);
            if(!test.isRunningTest()){
                Messaging.sendEmail(mails);   
            }
        }catch(Exception e){
            UtilityClass.createException('', 'ParkerLaneLoanController', 'SendEmailofVOIforApp2', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
        }
    }
    
    public static void SMSforApp2(opportunity opp, string VOIUrl){
        try{
            string URL = 'Hi '+ opp.Applicant_2__r.Firstname + ', \n';
            URL += opp.Applicant_1__r.Name + ' has applied for ' + opp.Purpose__c + ' finance and listed you as co-borrower. ACTION REQUIRED! Verify your identity so we can complete your application. Click below or check your email for more. The Parker Lane Team. \n';
            URL+= VOIUrl;
            List<smagicinteract__smsMagic__c> smsObjectList = new List<smagicinteract__smsMagic__c> ();
            smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
            smsObject.smagicinteract__SenderId__c = 'Parkerlane';
            smsObject.smagicinteract__Contact__c = opp.Applicant_2__r.PersonContactId;
            smsObject.smagicinteract__Opportunity__c = opp.Id;
            smsObject.smagicinteract__PhoneNumber__c = opp.Applicant_2__r.Phone;//'61400247471';//contact.MobilePhone;
            smsObject.smagicinteract__Name__c = opp.Applicant_2__r.Name;//contact.Name; // recordsname
            smsObject.smagicinteract__ObjectType__c = 'Contact';//'Contact'; // record type
            smsObject.smagicinteract__disableSMSOnTrigger__c = 0; // this field either be 0 or 1, if you specify the value as 1 then sms will not get send but entry of sms will get create under SMS History object
            smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
            smsObject.smagicinteract__SMSText__c = URL;
            smsObjectList.add(smsObject);
            Database.SaveResult[] results = Database.insert(smsObjectList, false);
            for(Database.SaveResult result : results) {
                if(result.isSuccess()) {
                    //  System.debug('Successfully inserted Accounts : ' + result.getId());
                }
                else{
                    for(Database.Error e : result.getErrors()) {
                        UtilityClass.createException('', 'ParkerLaneLoanController', 'SMSforApp2', e.getMessage(), '', ''+'',
                                                     '', ''+'');                     
                    }
                }
            }            

        }catch(Exception e){
            UtilityClass.createException('', 'ParkerLaneLoanController', 'SMSforApp2', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
            e.getTypeName(), ''+e.getCause()); 
        }
    }
    
    @future @auraEnabled
    public static void inertPDF(id oppId){
        try{
            Opportunity oppUpdate = [SELECT Id, Name,Applicant_2__c,Application_Sections__c, Current_Application_Sections__c, AccountId, Applicant_1__c,
                                     Applicant_1__r.PersonContactId, Applicant_1__r.PersonContact.Email, StageName, RecordTypeId,
                                     Number_of_applicants__c,
                                     (SELECT Id, Lead__c, Lender__c, Purpose__c  FROM Quotes WHERE Application__c = TRUE)
                                     FROM Opportunity WHERE Id =: oppId];
            PageReference pdf1 = Page.PreliminaryAssessmentPDF;
            pdf1.getParameters().put('id',oppUpdate.id);
            pdf1.setRedirect(true);
            
            Datetime dt = System.now();
            List<string> data = string.valueOf(dt).split(' ');
            dateTime tim =  dt;
            string timeCorrect = data[0]+ ' '+ tim.format('h:mm a');
            system.debug('--'+timeCorrect);
            string title = 'Preliminary Assessment: ' + oppUpdate.Name + '(' + timeCorrect + ')';
            Blob bPDF;
            
            
            Document_Requested__c dc = new Document_Requested__c();
            dc.Category__c = 'Preliminary Assessment';
            dc.Opportunity__c = oppUpdate.id;
            insert dc;
            
            if (Test.IsRunningTest()){
                bPDF = Blob.valueOf('UNIT.TEST');
            }else{
                System.debug('pdf.getContent()'+pdf1.getContent());
                bPDF = pdf1.getContent();                
            }               
            
            set<id> oldcontIDs = new Set<id>();
            for(ContentDocumentLink link : [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId =: oppUpdate.id]){
                oldcontIDs.add(link.ContentDocumentId);
            }  
            List<ContentVersion> oldcntList = new List<ContentVersion>();
            if(oldcontIDs.Size() > 0){
                for(ContentVersion cv : [SELECT Id,contentDocumentId,Category__c,Current_in_use__c from contentVersion where contentDocumentId IN:oldcontIDs AND Current_in_use__c=True AND Category__c = 'Preliminary Assessment']){
                    cv.Current_in_use__c = false;
                    oldcntList.add(cv); 
                }
            }
            
            update oldcntList;
            
            ContentVersion ContVerFile = new ContentVersion();
            ContVerFile.VersionData = bPDF;
            ContVerFile.Title = title; 
            ContVerFile.PathOnClient= title+'.Pdf';
            ContVerFile.Document_Requested__c = dc.id;
            ContVerFile.Current_in_use__c = true;
            insert ContVerFile;
            
            ContentVersion cdlListId = [select Id, ContentDocumentId From ContentVersion WHERE Id =: ContVerFile.id LIMIT 1];
            
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = oppUpdate.Id;
            cdl.ContentDocumentId = cdlListId.ContentDocumentId;
            cdl.shareType = 'V';
            insert cdl;
            
            List<Document_Requested__c> updateDc = new List<Document_Requested__c>();
            for(Document_Requested__c d : [SELECT Id, OwnerId, Name, LastModifiedDate, LastModifiedById, LastActivityDate, Contact__c, Category__c, Description__c, Details__c, Document__c, Opportunity__c, isComplete__c FROM Document_Requested__c WHERE Id =: dc.id]){
                d.isComplete__c = true;
                updateDc.add(d);
            }
            
            if(updateDc != null && updateDc.size() > 0){
                update updateDc;
            }
        }catch(Exception e){
            UtilityClass.createException('', 'ParkerLaneLoanController', 'inertPDF', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause()); 
        }
    }    
    
    @auraEnabled
    public static String getSummary(String oppId){
        Opportunity opp = [select Id, Document_Redirect_URL__c, Applicant_1__r.State__pc FROM opportunity WHERE Id =: oppId LIMIT 1];
        String retURL = '';
        if(String.isNotBlank(opp.Document_Redirect_URL__c)){
            retURL = opp.Document_Redirect_URL__c;
        }
        String path = '{\"applicantState\":\"'+ opp.Applicant_1__r.State__pc +'\",\"retURL\":\"'+ retURL +'\"}';
        return path;
    }
    
    @auraEnabled
    public static void updateSummary(String oppId ,String isApp2){
        try{
            Opportunity opp = [select Id,Applicant_Details_Change__c,Applicant_1__r.VOI_type__pc,Applicant_2__r.VOI_type__pc, name,Loan_Details_change__c, Applicant_1__r.PersonContactId, Applicant_1__r.Phone, Applicant_2__c, 
                               Applicant_2__r.PersonContactId, app_Two_completed_Summary__c, Applicant_2__r.Phone, Document_Redirect_URL__c 
                               FROM opportunity WHERE Id =: oppId];
            
            if(isApp2 == 'false'){
                if(opp.Document_Redirect_URL__c.contains('/MogoDocument')){
                    opp.Application_Sections__c = 'Standard Document Upload';
                    opp.Current_Application_Sections__c = 'Standard Document Upload';
                }
                /*else if(opp.Document_Redirect_URL__c.contains('/MogoSupportingDocument')){
                    opp.Application_Sections__c = 'Mogo Document Upload';
                    opp.Current_Application_Sections__c = 'Mogo Document Upload';
                    }else*/
                if(opp.Document_Redirect_URL__c.contains('/supportingDocument')){
                    opp.Application_Sections__c = 'Standard Document Upload';
                    opp.Current_Application_Sections__c = 'Standard Document Upload';
                }
                update opp;
            }
            else if(isApp2 == 'true'){
                opp.app_Two_completed_Summary__c = true;
                update opp;
            }
        }catch(Exception e){
            UtilityClass.createException(oppId, 'ParkerLaneLoanController', 'updateSummary', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause()); 
        }
    }
            
    
    @auraEnabled
    public static String createEnvelope(String oppId){
        List<dsfs__DocuSign_Status__c> docStatus = [SELECT Id,dsfs__Envelope_Status__c,dsfs__Opportunity__c 
                                                    FROM dsfs__DocuSign_Status__c
                                                    WHERE dsfs__Opportunity__c =: oppId];
        if(docStatus.size() == 0){                                        
            DocuSignRestUtility.createEnvelope((String)oppId);
        }
        return '';
    }
    
    @auraEnabled
    public static String createLeadAndQuotes(String productType, String cFName, String cLName, String cEmail, Integer cAmount, 
                                             String myPriority, String repayOverTerm, String homeOwner){
        try{
            String alreadyCust = 'You already have a quote or application under way. Please call 1300 131 711 or email personalapplications@parkerlane.com.au';
            String ownerId = '';
            String nextSection = 'Loan Recommendation';
            boolean isAlreadyLead = false;            
            List<opportunity> convertedLeadOpp = new List<opportunity>();
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
            
            List<Lead> leadList = [SELECT Id, FirstName,Referred_by_Aggregator_Acc__c, LastName, Email, Status, FinServ__ReferredByContact__c, FinServ__RelatedAccount__c, OwnerId, 
                                   Point_of_Origin__c, Phone, Referred_by_Company__c, LeadSource, FinServ__ReferredByContact__r.Name,
                                   FinServ__ReferredByContact__r.Account.Referrer_Business_Type__c, leadAddress__c, installationSuburb__c,
                                   installationCountry__c, installationPostcode__c, installationState__c 
                                   FROM Lead WHERE Email =: cEmail LIMIT 1]; 
            Lead lead = New Lead();
            if(leadList.isEmpty()){ 
                lead = New Lead(FirstName = cFName, LastName = cLName, Email = cEmail, Customer_Amount__c = cAmount, 
                                Purpose__c = productType, RecordTypeId = leadRecordTypeMap.get(productType), LeadSource='Website', 
                                Lead_Type__c = 'New Customer', Point_of_Origin__c = 'Website Quote / Application');
                lead.Status = 'Online Quote';
                upsert lead;                
            }else{ 
                lead = leadList.get(0);
                ownerId = leadList.get(0).OwnerId;
                List<Quote> existingQuotesList = [SELECT Id FROM Quote WHERE Lead__c =: lead.Id AND Opportunity.Purpose__c =:productType AND 
                                                  Opportunity.StageName != 'Settled (closed won)' AND Opportunity.StageName != 'Closed Lost'];
                if(existingQuotesList == null || existingQuotesList.size() == 0){                                        
                    // Added by tazeem for 1202
                    isAlreadyLead = true;
                    Database.LeadConvert lc = new database.LeadConvert();
                    lc.setLeadId(lead.id);
                    LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
                    lc.setConvertedStatus(convertStatus.MasterLabel);
                    Database.LeadConvertResult lcr = Database.convertLead(lc);                     
                    for(opportunity op : [select id, name, AccountId,applicant_1__r.id from opportunity where id = : lcr.getOpportunityId()]){
                       convertedLeadOpp.add(op); 
                    }                    
                    for(lead ld : [SELECT Id, FirstName,Referred_by_Aggregator_Acc__c, LastName, Email, Status, FinServ__ReferredByContact__c, FinServ__RelatedAccount__c, OwnerId, 
                                   Point_of_Origin__c, Phone, Referred_by_Company__c, LeadSource, FinServ__ReferredByContact__r.Name,
                                   FinServ__ReferredByContact__r.Account.Referrer_Business_Type__c, leadAddress__c, installationSuburb__c,
                                   installationCountry__c, installationPostcode__c, installationState__c 
                                   FROM Lead WHERE id = : lcr.getLeadId() ]){
                      lead = ld;  
                    }
                    
                }
                else{
                    return '{\"status\":\"Error\","message\":\"'+ alreadyCust +'\"}';
                }
            }
            
            
           /* List<Account> existingPAccList = [SELECT Id FROM Account WHERE PersonContact.Email =: lead.Email];
            if(!existingPAccList.isEmpty()){
                return '{\"status\":\"Error\","message\":\"'+ alreadyCust +'\"}';
            }*/
            

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
            
            if(isAlreadyLead){
                householdAccount.id = convertedLeadOpp[0].AccountId;
                update householdAccount;
            }
            else{
                insert householdAccount;   
            }                       
            
            Account personAccount = new Account(FirstName = lead.FirstName, LastName = lead.LastName, PersonEmail = lead.Email,
                                                Relationship_with_Applicant_1__c='Client', RecordTypeId = personAccRTId,
                                                Phone = lead.Phone, Referred_by_Company__c = refCompanyId, Account_Lead_Source__c = leadSource,
                                                PersonLeadSource = leadSource, FinServ__ReferredByContact__c = lead.FinServ__ReferredByContact__c,
                                                Residential_Address__pc = lead.leadAddress__c, Suburb__pc  = lead.installationSuburb__c,
                                                FinServ__CountryOfResidence__pc = lead.installationCountry__c, Postal_Code__pc = lead.installationPostcode__c,
                                                State__pc = lead.installationState__c );
            
            if(isAlreadyLead){
                personAccount.id = convertedLeadOpp[0].applicant_1__r.id;
                update personAccount; 
            }
            else{
                insert personAccount;
            }
            
            
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
                                              referred_by_aggregator__c = lead.Referred_by_Aggregator_Acc__c,
                                              Point_of_Origin__c = lead.Point_of_Origin__c,
                                              CloseDate = Date.today(),
                                              Priority_is__c = myPriority,
                                              //Prefer_to_repay_over_a_term__c = repayOverTerm,
                                              Home_Owner__c = homeOwner,
                                              LeadSource = leadSource,
                                              RecordTypeId = oppRecordTypeMap.get(productType));
            if(String.isNotBlank(ownerId))
                opp.OwnerId = ownerId;
            
            if(isAlreadyLead){
                opp.id = convertedLeadOpp[0].id;
                update opp;
            }
            else{
                insert opp; 
            }            

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
    
    
    
    @auraEnabled
    public static List<WrapperLoanRate> getQuotaions(Id oppId, String masterQuote){
        List<WrapperLoanRate> wprLoanRateList = New List<WrapperLoanRate>();
        Map<Id,Id> productQuoteIdMap = New Map<Id,Id>();
        Map<Id,List<Loan_Rate__c>> quoteIdLoanRatesMap = New Map<Id,List<Loan_Rate__c>>();
        Map<Id,Quote> quotesMap = New Map<Id,Quote>
            ([SELECT Id, Actual_Comparison_Rate__c, Comparison_Rate_Warning__c, Eligibility__c, Product__r.Features__c, 
             Interest_Rate__c, Customer_Amount__c, Loan_Term__c, Name, Product__r.Eligibility_Description__c , Product__r.Minimum_Loan_Amount__c,
             Monthly_Repayment__c, Product__r.Min_Loan_Term__c, Product__r.Max_Loan_Term__c, Purpose__c, Lead__c, Product__r.Maximum_Loan_Amount__c, 
             Product__c, Product__r.Comparison_Rate_Display__c, Product__r.Security__c, Product__r.Interest_Rate_Type__c,
             Product__r.Interest_Rate_From__c, Product__r.Product_Order__c, Product__r.Is_Feature_Product__c, Total_Setup_Fees__c,
             Product__r.Total_Setup_Fees__c, Product__r.Decision_in_Hours__c, Product__r.Interest_Rate_Based_On__c,Application__c, Product_Description__c,
             Total_loan_amount__c, Up_Front_Costs_Applicable__c,Product__r.Interest_Rate__c, OpportunityId, Product__r.Default_Loan_Term_Months__c,Affordability_Confirmation__c,
             Product__r.What_document_needs_to_apply__c, Product__r.Summary_Page_What_You_ll_Get__c, Monthly_Account_Keeping_Fees__c, Lender__c, Product_Type__c,Not_Applicable__c
             FROM Quote WHERE Gruop_Name__c =: masterQuote AND  OpportunityId =: oppId ORDER BY Product__r.Product_Order__c ASC limit 3]);
        
        Opportunity oppDetails = [Select id, Referred_by_Company__r.Supplier_Logo_URL_For_Site__c,Referred_by_Company__r.CustomLoanOptionsPageMessage__c, Referred_by_Company__r.BackgroundImage__c, Referred_by_Company__r.LogoImage__c from opportunity where id =: oppId];
        
        system.debug('quotesMap'+quotesMap);
        for(Quote qt: quotesMap.values()){
            productQuoteIdMap.put(qt.Product__c, qt.Id);
        }
        
        for(Loan_Rate__c lr: [Select id,From_amount__c,Interest_rate__c,To_amount__c,Comparison_rate__c,Product__c from Loan_Rate__c WHERE Product__c IN: productQuoteIdMap.keySet()]){
            List<Loan_Rate__c> loanRateList = quoteIdLoanRatesMap.get(productQuoteIdMap.get(lr.Product__c));
            if(loanRateList == NULL){
                loanRateList = New List<Loan_Rate__c>();
            }
            loanRateList.add(lr);
            quoteIdLoanRatesMap.put(productQuoteIdMap.get(lr.Product__c),loanRateList);
        }
        
        for(Quote qt: quotesMap.values()){
            WrapperLoanRate qouteOrLoanRate = new WrapperLoanRate();
            qouteOrLoanRate.quote = qt; 
            qouteOrLoanRate.opp = oppDetails;
            qouteOrLoanRate.loanRatelist = quoteIdLoanRatesMap.get(qt.Id);
            wprLoanRateList.add(qouteOrLoanRate);
        }
        
        return wprLoanRateList;
        
    }
    
    @auraEnabled
    public static WrapperLoanRate getFreshQuotes(sObject qtUpdate){
        try{
            WrapperLoanRate wl = new WrapperLoanRate();
            Quote qt = (Quote)qtUpdate;
            List<Loan_Rate__c> loanRateList = [Select id,From_amount__c,Interest_rate__c,To_amount__c,Comparison_rate__c,Product__c from Loan_Rate__c WHERE Product__c =: qt.Product__c];
            if(qt.Product__r.Interest_Rate_Based_On__c =='Tiered Rate' && !loanRateList.isEmpty() ){
                for(Loan_Rate__c lr : loanRateList){
                    if(lr.From_amount__c <= qt.Customer_Amount__c && lr.From_amount__c >= qt.Customer_Amount__c ){
                        qt.Actual_Comparison_Rate__c = lr.Comparison_rate__c;
                        qt.Interest_Rate__c = lr.Interest_rate__c;
                        break;
                    }
                }
            }
            update qt;
            wl.loanRatelist = loanRateList;
            wl.quote = qt;
            return wl;
        }catch(exception e){
            UtilityClass.createException(qtUpdate.id, 'ParkerLaneLoanController', 'getFreshQuotes', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @auraEnabled
    public static void updateNotApplicableQuote(sObject qtUpdate){
        try{
            Quote qt = (Quote)qtUpdate;
            if(qt.Not_Applicable__c != true){
                qt.Not_Applicable__c = true; 
                update qt;
            }
        }
        catch(exception e){
            UtilityClass.createException(qtUpdate.id, 'ParkerLaneLoanController', 'updateNotApplicableQuote', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
        }
    }
        
    @auraEnabled
    public static sObject getLead(Id oppId){
        List<Quote> quotesList = [SELECT Id, Lead__c, Opportunity.Applicant_1__c, Opportunity.Applicant_1__r.PersonContactId 
                                  FROM Quote WHERE OpportunityId =: oppId limit 1];
        system.debug('quotesList'+quotesList);
        if(!quotesList.isEmpty()){
            if(String.isNotBlank(quotesList[0].Opportunity.Applicant_1__c)){
                Contact con = [SELECT Id, FirstName, LastName, Email 
                               FROM Contact WHERE Id =: quotesList[0].Opportunity.Applicant_1__r.PersonContactId limit 1];
                system.debug('con'+con);
                return con;
            }
            Lead lead = [SELECT Id, FirstName, LastName, Email 
                         FROM Lead WHERE Id =: quotesList[0].Lead__c limit 1];
            system.debug('lead'+lead);
            return lead;
        }
        return null;
    }
    
    @auraEnabled
    public static Integer getOppIndex(Id oppId){
        try{
            Opportunity opp = [SELECT Id,  Application_Sections__c, RecordTypeId FROM Opportunity WHERE Id =: oppId limit 1];
            List<String> appSectionsList = getApplicationSections();
               
            return appSectionsList.indexOf(opp.Application_Sections__c) ;
        }catch(exception e){
            UtilityClass.createException(oppId, 'ParkerLaneLoanController', 'getOppIndex', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                       e.getTypeName(), ''+e.getCause());
            return 0;
        }
    }
        
    @auraEnabled
    public static List<Product2> getFeaturedProducts(Boolean isFeatured, String purpose){
        try{
            String query = 'SELECT Id FROM Product2 WHERE isActive = TRUE ';
            if(isFeatured){
                query += ' AND Is_Feature_Product__c = TRUE ';
            }else{
                query += ' AND Acceptable_Loan_Purpose__c INCLUDES (\''+purpose +'\') ';
            }
            query += ' AND Default_Product__c = TRUE ORDER BY Product_Type__c, Product_Order__c limit 3';
            List<Product2> productsList = Database.query(query);
            return [SELECT Id, Actual_Comparison_Rate__c, Acceptable_Loan_Purpose__c, Product_Type__c, Eligibility_Description__c, 
                    Features__c, Interest_Rate__c, Interest_Rate_Type__c, Name, Security__c, Loan_Term_Duration__c, 
                    Comparison_Rate_Display__c, Description, Interest_Rate_From__c, Product_Order__c 
                    FROM Product2 WHERE Id in: productsList ORDER BY Product_Order__c];

        }catch(exception e){
            UtilityClass.createException('','ParkerLaneLoanController', 'getFeaturedProducts', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                       e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @auraEnabled
    public static String UpdateQuote(List<sObject> quotesList, String selectedQuoteId){
        List<Quote> quotesListToUpdate = New List<Quote>();
        String oppId = null;
        try{
            for(sObject quot : quotesList){
                Quote qt = (Quote)quot;
                qt.Application__c = qt.Id.equals(selectedQuoteId);
                if(qt.Application__c){
                    oppId = qt.OpportunityId;
                }
                quotesListToUpdate.add(qt); 
            }
            
            update quotesListToUpdate;
            List<Stage_Tracking__c> stageTrackingList =[SELECT Id,Change_in_Expected_Revenue__c, Opportunity__r.ExpectedRevenue FROM Stage_Tracking__c WHERE Opportunity__c  =: oppId ORDER BY CreatedDate LIMIT 1];
            if(!stageTrackingList.isEmpty()){
                Stage_Tracking__c stageTracking = stageTrackingList[0];
                stageTracking.Expected_Revenue__c = stageTracking.Opportunity__r.ExpectedRevenue;
                stageTracking.Change_in_Expected_Revenue__c = stageTracking.Change_in_Expected_Revenue__c == NULL? 0: stageTracking.Change_in_Expected_Revenue__c;
                //stageTracking.Stage_Changing_Date__c = System.Datetime.now();
                
                update stageTracking;
            }
            
            String nextSection = 'Getting Started';
            Opportunity opp = new Opportunity();
            opp.Id = oppId;
            opp.StageName = 'CPA Started';
            opp.Current_Application_Sections__c = nextSection;
            opp.Application_Sections__c = nextSection;
            update opp;
            
            String path = '{\"CurrentSection\":\"'+ nextSection +'\", \"path\": '+getPath(nextSection,nextSection,oppId)+ '}';
            return path;
        }catch(exception e){
            UtilityClass.createException(oppId,'ParkerLaneLoanController', 'UpdateQuote', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return '[]';
        }
    }
    
    @auraEnabled
    public static String updateApplicationSection(String oppId, String appSection, Boolean isChangeSection){
        opportunity oppRec = [SELECT Id, Application_Sections__c, Current_Application_Sections__c, RecordTypeId
                              FROM Opportunity WHERE Id =: oppId];
        oppRec.Current_Application_Sections__c =appSection;// 'Loan Recommendation';
        oppRec.Application_Sections__c = appSection;//'Loan Recommendation';                    
        update oppRec;      
        
        if(!isChangeSection) return '';
        
        String path = '{\"CurrentSection\":\"'+ appSection +'\", \"path\": '+getPath(appSection, appSection, oppRec.RecordTypeId)+ '}';
        return path;        
    }
       
    
    @AuraEnabled
    public static oppDetails getOppDetails(String recordId){
        Opportunity opp = [Select id, Applicant_1__c, Applicant_2__c, applicant_1__r.FirstName, applicant_2__r.FirstName, Customer_Support_Person_Name__c, Purpose__c, Applicant_1__r.personContactId, Applicant_2__r.personContactId,
                           Customer_Support_Person__r.FirstName, Customer_Support_Person__r.FullPhotoUrl, Customer_Support_Person__r.MediumPhotoUrl, Customer_Support_Person__r.SmallPhotoUrl, Customer_Support_Person__r.Best_Customer_Review__c from Opportunity where id =: recordId];
        oppDetails oppCons = new oppDetails();
        oppCons.opp = opp;
        for(VOI_Status__c sd : [select id,VOi_Status__c,Case_Status__c,VOI_Type_For__c,Contact__c,Contact__r.name,Opportunity__c from VOI_Status__c where opportunity__c =: recordId]){
            if(opp.Applicant_2__c != null){
                if(sd.Contact__c == opp.Applicant_1__r.personContactId){
                    oppCons.app1Voi = sd;
                }                
                if(sd.Contact__c == opp.Applicant_2__r.personContactId){
                    oppCons.app2Voi = sd;
                }   
            }
            else{
                oppCons.app1Voi = null;
                oppCons.app1Voi = null;
            }            
        }        
        return oppCons;
    }    
    
    public class WrapperLoanRate{
        @AuraEnabled public Quote quote;
        @AuraEnabled public Opportunity opp;
        @AuraEnabled public List<Loan_Rate__c> loanRatelist;
    }
    
    public class oppDetails{
        @AuraEnabled public Opportunity opp{get;set;}
        @AuraEnabled public VOI_Status__c app1Voi{get;set;}
        @AuraEnabled public VOI_Status__c app2Voi{get;set;}
    }
    
    public class OpportunityContacts{
        @AuraEnabled public Opportunity opp;
        @AuraEnabled public Contact contact1;
        @AuraEnabled public Contact contact2;
        @AuraEnabled public List<Contact> app1Children;
        @AuraEnabled public List<Contact> app2Children;
    }
    
    public class ContactWithOpp{
        @AuraEnabled public Contact con;
        @AuraEnabled public Boolean isLimited; 
    } 
}