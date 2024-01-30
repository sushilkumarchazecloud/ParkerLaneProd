public without sharing class ReferrerOnboardingFormController {
    public Account acc{get;Set;}
    public ReferrerOnboardingFormController(){
        String accId = apexpages.currentpage().getparameters().get('id');
		acc = New Account();
        if(String.isNotBlank(accId)){
            acc = [SELECT Id, ABN__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Company_Legal_Name__c, 
                   (SELECT Id, FirstName, LastName, Name, Position__c FROM Contacts WHERE Is_Authorised_Signatory__c =true LIMIT 1)
                   FROM Account WHERE id =: accId];
        }
    }
    
    @auraEnabled
    public static Account saveReferrer(Account acc, Contact con){
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referrer (Business)').getRecordTypeId();
        Id conRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Referrer').getRecordTypeId();
        Savepoint sp = Database.setSavepoint();
        try{
            acc.RecordTypeId = accRTId;
            upsert acc;
            con.AccountId = acc.Id;
            con.RecordTypeId = conRTId;
            con.Status__c = 'Active';
            con.Admin__c = true;
            upsert con;
            acc = [SELECT Id, Name, ABN__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Company_Legal_Name__c,
                   Referrer_Business_Type__c, Other_Business_Type_Description__c, Is_Find_Billing_Address__c, Website, Are_you_Clean_Energy_Council_Accredited__c,
                   Listing_URL__c,How_many_new_sales_appointments_per_week__c,How_do_you_conduct_your_appointment__c, Anticipate_intro_finance_to_customer__c,
                   General_Business_Description__c, Unique_Value_Proposition_1__c, Unique_Value_Proposition_2__c, Unique_Value_Proposition_3__c,
                   Key_Accreditations_1__c, Key_Accreditations_2__c, Key_Accreditations_3__c, Phone,
                   (SELECT Id, FirstName, LastName, Email, Phone, Position__c FROM Contacts)
                   FROM Account WHERE Id =: acc.Id];
            return acc;
            
        }catch(exception e){
            UtilityClass.createException(acc.Id, 'ReferrerOnboardingFormController', 'submitReferrer', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            System.debug('@@@@'+ e.getMessage());
            Database.rollback(sp);
            return Null;
        }
    }  
    
    @auraEnabled
    public static void createEnvelope(String accId){
        try{
			DocuSignRESTUtility.createEnvelopeForAccount(accId);
        }catch(exception e){
            UtilityClass.createException(accId, 'ReferrerOnboardingFormController', 'createEnvelope', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
        }
    }
    
    @auraEnabled
    public static Account submitReferrer(Account acc, List<Contact> conList, Boolean isNext){
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referrer (Business)').getRecordTypeId();
        Id conRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Referrer').getRecordTypeId();
        Savepoint sp = Database.setSavepoint();
        try{
            List<Contact> conListToInsert = New List<Contact>();
            update acc;
            
            
            for(Contact con: conList){
                con.AccountId = acc.Id;
                con.RecordTypeId = conRTId;
                con.Status__c ='Active';
                conListToInsert.add(con);
            }
            upsert conListToInsert;
            
            System.debug('isnext ++'+isNext);
            if(conListToInsert != null && !isNext){
                if(conListToInsert.size() > 0){
                    List<Contact> con = [select Id,Phone, name from Contact WHERE AccountId =: acc.id AND Is_Authorised_Signatory__c = true LIMIT 1];
                    
                    string IntrandomNumber = string.valueOf(Math.round((Math.random() * (900000) + 100000)));
                    Set<id> vioIdSet = new Set<id>();
                    for(VOi_status__c vois : [select Id,link_Expire_code__c, Name,Case_Status__c, contact__c, contact__r.name from VOi_status__c WHERE contact__r.id IN: con AND Case_Status__c != 'Verified' AND Case_Status__c != 'Rejected' order by createddate DESC LIMIT 1]){
                        if(vois.Case_Status__c == 'Delivered' || vois.Case_Status__c == 'Sent'){
                            string msg = vois.Contact__r.name + ' has already completed the VOI. To send again, you must first update the status of the current VOI record to either Verified or Rejected.';
                            System.debug('mesgae+'+msg);
                        }else{
                            vioIdSet.add(vois.id);            
                        }
                    }
                    List<string> smsText = new List<string>();
                    string voiSId= '';
                    for(smagicinteract__smsMagic__c obj : [select ID, name,VOI_Status__c,VOI_Status__r.id,smagicinteract__SMSText__c, smagicinteract__Contact__c from smagicinteract__smsMagic__c WHERE VOI_Status__r.id IN: vioIdSet order by createddate DESC LIMIT 1]){
                        smsText.add(obj.smagicinteract__SMSText__c);
                        voiSId = obj.VOI_Status__r.id;
                    }
                    
                    if(smsText != null && smsText.size() > 0){
                        SMSController.SendMessageToReferr('Contact', 'Parkerlane', con[0].id, acc.id, IntrandomNumber, smsText[0], voisId);
                        System.debug('firstSuccess');
                    }	
                    else{
                        VOI_Status__c obj = new VOI_Status__c();
                        obj.Account__c = acc.id;
                        obj.Contact__c = con[0].id;
                        obj.Case_Status__c = 'Sent';
                        obj.link_Expire_code__c = IntrandomNumber;
                        
                        insert obj;     
                        
                        SMSController.SendMessageToReferr('Contact', 'Parkerlane', con[0].id, acc.id, IntrandomNumber, '', obj.id);
                        
                        System.debug('secSuccess');
                    }   
                   
                }
            }
            acc = [SELECT Id, Name, ABN__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Company_Legal_Name__c,
                   Referrer_Business_Type__c, Other_Business_Type_Description__c, Is_Find_Billing_Address__c, Website, Are_you_Clean_Energy_Council_Accredited__c,
                   Listing_URL__c,How_many_new_sales_appointments_per_week__c,How_do_you_conduct_your_appointment__c, Anticipate_intro_finance_to_customer__c,
                   General_Business_Description__c, Unique_Value_Proposition_1__c, Unique_Value_Proposition_2__c, Unique_Value_Proposition_3__c,
                   Key_Accreditations_1__c, Key_Accreditations_2__c, Key_Accreditations_3__c, Phone,
                   (SELECT Id, FirstName, LastName, Email, Phone, Position__c FROM Contacts)
                   FROM Account WHERE Id =: acc.Id];
            return acc;
        }catch(exception e){
            UtilityClass.createException(acc.Id, 'ReferrerOnboardingFormController', 'submitReferrer', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            Database.rollback(sp);
            return null;
        }
    }   
    
    
}