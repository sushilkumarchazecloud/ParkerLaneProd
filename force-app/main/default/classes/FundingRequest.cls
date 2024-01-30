public without sharing Class FundingRequest {
    private final String clientId = System.Label.ClientId;
    private final String clientSecret = System.Label.ClientSecret;
    private final String username = System.Label.Username;
    private final String password = System.Label.PasswordSupportingDoc;
    private final String endPointUrl = System.Label.EndpointURL;
    public string accessToken{get;set;}
    
    public class deserializeResponse{
        public String id;
        public String access_token;
    }
    
    public FundingRequest(){
        String reqbody = '&client_id='+clientId+'&client_secret='+clientSecret+'&username='+username+'&password='+password;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setBody(reqbody);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setEndpoint(endPointUrl);
        if(!Test.isRunningTest()){
            HttpResponse res = h.send(req);
            system.debug('@@@@access_token@@'+res );
            system.debug('@@@@access_token@@'+res.getbody());
            deserializeResponse resp1 = (deserializeResponse)JSON.deserialize(res.getbody(),deserializeResponse.class);
            system.debug('@@@@access_token@@'+resp1 ); 
            accessToken = resp1.access_token; 
        } 
    }
    
    @AuraEnabled
    public static String CheckConditions(String oppId){
        String returnval = '';
        Boolean hasLenderCreditContractCurrent = false;
        Boolean hasPurchaseInvoiceCurrent = false;
        Set<Id> contentDocId = new Set<Id>();
        
        Opportunity opp =[SELECT Id,StageName,SyncedQuote.Customer_Amount__c,Approved_Expire_Date__c FROM Opportunity WHERE Id=: oppId LIMIT 1];
        
        List<String> oppStages = new List <String>{'Approved','Funding','Settled (closed won)','Closed Lost'};
            if(oppStages.contains(opp.StageName)){
                List<Funding_Request__c> frList = [SELECT Id,Request_Type__c,Request_Status__c FROM Funding_Request__c WHERE Opportunity__c =: OppId]; 
                if(frList.Size() == 0){
                    if(opp.Approved_Expire_Date__c <= Date.today()){
                        returnval = 'You can’t create a funding request after the loan approval has expired.';   
                    }
                    else{ 
                        List<ContentDocumentLink> linkList = [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: oppId];  
                        if(!linkList.isEmpty()){
                            for(ContentDocumentLink cnt : linkList){
                                contentDocId.add(cnt.ContentDocumentId); 
                            }
                        }
                        if(!contentDocId.isEmpty()){
                            List<ContentVersion> cvList = [SELECT Id, Title,Category__c,Current_in_use__c, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: contentDocId];
                            if(!cvList.isEmpty()){
                                for(ContentVersion cvv : cvList){
                                    if(cvv.Category__c == 'Lender Credit Contract' && cvv.Current_in_use__c == true){
                                        hasLenderCreditContractCurrent = true;
                                    }
                                    if(cvv.Category__c == 'Purchase Invoice' && cvv.Current_in_use__c == true){
                                        hasPurchaseInvoiceCurrent = true; 
                                    }
                                }
                            }
                        }
                        if(hasLenderCreditContractCurrent == true && hasPurchaseInvoiceCurrent == true){
                            returnval = 'Success';
                        }
                        else{
                            returnval = 'You must first have a current version of the supplier’s quote/invoice and the lender’s credit contract attached to the opportunity.';  
                        }
                    }
                }
                if(frList.Size() == 1){
                    for(Funding_Request__c fr : frList){
                        if(fr.Request_Type__c == 'Part payment before installation' && fr.Request_Status__c != 'Payment funded'){
                            returnval = 'Part Payment Request already exists, you will not be able to request until previous request will be funded.';  
                        }
                        else if(fr.Request_Type__c == 'Part payment before installation' && fr.Request_Status__c == 'Payment funded'){
                            returnval = 'Request for Remainder Payment.';
                        }
                        else if(fr.Request_Type__c == 'Payment in full before installation' || fr.Request_Type__c == 'Payment in full after installation' || fr.Request_Type__c == 'Variation'){
                            returnval = 'Request already exists.'; 
                        }
                    } 
                }
                if(frList.Size() == 2){
                    returnval = 'Request already exists.'; 
                }
            }
        else{
            returnval = ' You can not submit a funding request until loan is approved.' ;  
        }
        return returnval; 
    }
    
    @AuraEnabled
    public static Opportunity getOpp(String oppId){
        Opportunity opp =[SELECT Id,Applicant_1__c,Applicant_2__c, Applicant_1__r.Name, Applicant_2__r.Name,
                          FinServ__ReferredByContact__c,StageName,SyncedQuote.Customer_Amount__c,
                          SyncedQuote.Product__r.No_of_Signatories_allowed__c,
                          Applicant_1__r.Number_of_applicants_to_operate_account__pc,Docs_Outstanding__c
                          FROM Opportunity WHERE Id=: oppId LIMIT 1];
        return opp;
    } 
    
    @AuraEnabled
    public static Funding_Request__c getFundingOnHandOverPopUp(String recId){
        Funding_Request__c fr = [SELECT Id,Opportunity__r.SyncedQuote.Customer_Amount__c,Request_Type__c,Invoice_Amount__c,Request_Amount__c,Installation_Date__c,
                                 Opportunity__c,Applicant_1_A1__c,Applicant_1_A1__r.Name,Applicant_2_A2__c,
                                 Applicant_2_A2__r.Name, A1_Funding_Call_Handover__c,A2_Funding_Call_Handover__c
                                 FROM Funding_Request__c WHERE Id=: recId];
        return fr;
        
    }
    
    @AuraEnabled
    public static Funding_Request__c getOldRequest(String oppId, String recId){
        Funding_Request__c fr = [SELECT Id,Request_Type__c,Opportunity__c,Net_Funds_after_Request__c,
                                 Request_Amount__c,Invoice_Amount__c 
                                 FROM Funding_Request__c WHERE Id !=: recId AND Opportunity__c =: oppId  
                                 AND Request_Type__c = 'Part payment before installation' LIMIT 1];
        return fr;
        
    }
    
    @AuraEnabled
    public static void UpdateFundingHandOver(String recId,boolean app1HandOver,boolean app2HandOver ){
        Funding_Request__c fr = [SELECT Id,Applicant_1_A1__c,Applicant_1_A1__r.Name,Applicant_2_A2__c,Applicant_2_A2__r.Name,
                                 A1_Funding_Call_Handover__c,A2_Funding_Call_Handover__c FROM Funding_Request__c 
                                 WHERE Id=: recId];
        
        if(fr.A1_Funding_Call_Handover__c == null && app1HandOver){
            system.debug('Hiii');
            fr.A1_Funding_Call_Handover__c = Datetime.now();
        }
        else if(fr.A1_Funding_Call_Handover__c != null && !app1HandOver){
            fr.A1_Funding_Call_Handover__c = null;  
        }
        
        if(fr.Applicant_2_A2__c != null && fr.A2_Funding_Call_Handover__c == null && app2HandOver){
            fr.A2_Funding_Call_Handover__c = Datetime.now();
        }
        else if(fr.A2_Funding_Call_Handover__c != null && !app2HandOver){
            fr.A2_Funding_Call_Handover__c = null;  
        }
        system.debug('frrrrrrrr'+fr);
        if(fr != null){
            Update fr;
        }
    }
    
    @AuraEnabled
    public static Funding_Request__c getFundingRequest(String oppId){
        Funding_Request__c fr = [SELECT Id,Request_Type__c,Request_Amount__c,Request_Status__c,Invoice_Amount__c,
                                 Date_Last_Request_Status_Changes__c,Net_Funds_after_Request__c
                                 FROM Funding_Request__c WHERE Opportunity__c =: OppId
                                 Order by CreatedDate DESC LIMIT 1]; 
        return fr;
        
    }
    
    @AuraEnabled
    public static void createFundingRequestFromAction(String oppId,Decimal invoice_amount,String reqType,Decimal req_amount,String requestBy, String requestOrigin,Date Inst_Date, String Csmtr_agreedORSatisfy,String req_person,String Cstmr_auth_Type){
        
        Opportunity Opp = [SELECT Id,StageName,Applicant_1__c,Applicant_2__c,SyncedQuote.Customer_Amount__c,FinServ__ReferredByContact__c,
                           Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId FROM Opportunity WHERE Id=: oppId];
        Funding_Request__c fr = new Funding_Request__c();
        fr.Opportunity__c = oppId;
        if(Opp.Applicant_1__c != null){
            fr.Applicant_1_A1__c = Opp.Applicant_1__c; 
        }
        if(Opp.Applicant_2__c != null){
            fr.Applicant_2_A2__c = Opp.Applicant_2__c;  
        }
        fr.Invoice_Amount__c = invoice_amount;
        fr.Request_Type__c = reqType;
        fr.Previous_Req_Type__c = reqType;
        fr.Request_Amount__c = req_amount;  
        fr.Requested_by__c = requestBy;
        system.debug('Cstmr_auth_Type'+Cstmr_auth_Type);
        fr.Customer_Authorisation_Type__c = Cstmr_auth_Type;
        
        if(reqType == 'Variation'){
            fr.Request_Status__c = 'Variation requested by customer'; 
            fr.Variation_Status__c = 'Requested by customer';
            fr.Variation_Amount__c = Math.abs(opp.SyncedQuote.Customer_Amount__c - invoice_amount);
            fr.New_Customer_Amount__c = invoice_amount;
            fr.A1_Variation_Request_Submitted_Date__c = System.now();
            fr.Net_Surplus_Shortfall__c = Math.abs(opp.SyncedQuote.Customer_Amount__c - invoice_amount);
            fr.Surplus_Shortfall_Treatment__c = 'Variation to contract (requires re-approval)';
            if(req_person == 'Applicant 1'){
                fr.Variation_Requested_By__c = opp.Applicant_1__c;
            }
            else if(req_person == 'Applicant 2'){
                fr.Variation_Requested_By__c = opp.Applicant_2__c;
            }
            else{
               fr.Variation_Requested_By__c = opp.Applicant_1__c;  
            }
            string SecureCodeOriginal = string.valueOf(Math.round((Math.random() * (9000) + 1000)));
            VOI_Detail__c voi  = new VOI_Detail__c();
            voi.Secure_Code_Orignal__c = SecureCodeOriginal;
            voi.Contact__c = Opp.Applicant_1__r.PersonContactId;
            voi.opportunity__c = Opp.Id;
            voi.VOI_Type__c = 'E-SIGN';
            insert voi;
            list<VOI_Status__c> voiList = new list<VOI_Status__c>();
            string IntrandomNumber1 = string.valueOf(Math.round((Math.random() * (900000) + 100000)));
            string URL = System.Label.baseUrl + 'DigitalSigning?oppId=' + opp.Id + '&conId=' + Opp.Applicant_1__r.PersonContactId + '&r='+ IntrandomNumber1;            
            VOI_Status__c obj = new VOI_Status__c();
            obj.Opportunity__c = Opp.id;
            obj.Contact__c = Opp.Applicant_1__r.PersonContactId;
            obj.Case_Status__c = 'Sent';
            obj.VOI_Detail__c = voi.id;
            obj.link_Expire_code__c = IntrandomNumber1;
            obj.VOI_Type_For__c = 'E-SIGN';
            obj.Current_VOI_section__c = 'CQP';
            obj.VOI_URL__c = URL;
            fr.VOI_link_app1__c = URL;
            voiList.add(obj);
            
            if(Opp.Applicant_2__c != null){
                string SecureCodeOriginal1 = string.valueOf(Math.round((Math.random() * (9000) + 1000)));
                VOI_Detail__c voi1  = new VOI_Detail__c();
                voi1.Secure_Code_Orignal__c = SecureCodeOriginal1;
                voi1.Contact__c = Opp.Applicant_2__r.personContactId;
                voi1.opportunity__c = Opp.Id;
                voi1.VOI_Type__c = 'E-SIGN';
                insert voi1;
                
                string IntrandomNumber2 = string.valueOf(Math.round((Math.random() * (900000) + 100000)));
                string URL1 = system.Label.baseUrl + 'DigitalSigning?oppId='+Opp.id + '&conId='+Opp.Applicant_2__r.personContactId +'&r='+IntrandomNumber2;
                VOI_Status__c obj2 = new VOI_Status__c();
                obj2.Opportunity__c = Opp.id;
                obj2.VOI_Detail__c = voi1.id;
                obj2.Contact__c = Opp.Applicant_2__r.personContactId;
                obj2.Case_Status__c = 'Sent';
                obj2.link_Expire_code__c = IntrandomNumber2;
                obj2.VOI_Type_For__c = 'E-SIGN';
                obj2.Current_VOI_section__c = 'CQP';
                obj2.VOI_URL__c = URL1;
                fr.VOI_link_app2__c = URL1;
                voiList.add(obj2);
            }
            insert voiList;
        }
        else if(requestBy == 'Supplier'){
            fr.Request_Status__c = 'Payment requested by supplier';
            fr.Net_Surplus_Shortfall__c = opp.SyncedQuote.Customer_Amount__c - invoice_amount;
        }
        else if(requestBy == 'Customer'){
            fr.Request_Status__c = 'Payment requested by customer';  
            fr.Net_Surplus_Shortfall__c = opp.SyncedQuote.Customer_Amount__c - invoice_amount;
        }
        
        fr.Request_Origin__c = requestOrigin;
        fr.Installation_Date__c = Inst_Date;
        fr.Has_the_customer_agreed_to_this_payment__c = Csmtr_agreedORSatisfy;  
        fr.Request_Date__c = System.Now();
        if(req_person == 'Applicant 1'){
            fr.Person_Requesting__c = opp.Applicant_1__r.PersonContactId;
        }
        else if(req_person == 'Applicant 2'){
            fr.Person_Requesting__c = opp.Applicant_2__r.PersonContactId;
        }
        else if(req_person == 'Referrer'){
            fr.Person_Requesting__c = opp.FinServ__ReferredByContact__c;
        }
        fr.Customer_Authorisation_Status__c = 'Request sent to customer(s)';
        
        insert fr;
        
        if(reqType != 'Variation'){
            opp.StageName = 'Funding';
            Update opp;
        }
    } 
    
    @AuraEnabled
    public static void UpdateFundingRequest(String recId,Decimal invoice_amount,String reqType,Decimal req_amount,Date Inst_Date){
        system.debug('RequestTYPE'+reqType);
        Funding_Request__c fr = [SELECT Id,Opportunity__r.SyncedQuote.Customer_Amount__c,Request_Type__c,Invoice_Amount__c,
                                 Request_Amount__c,Installation_Date__c,Opportunity__c,Request_Status__c,Requested_by__c,
                                 Variation_Status__c,Variation_Amount__c,New_Customer_Amount__c,A1_Variation_Request_Submitted_Date__c,
                                 Net_Surplus_Shortfall__c,Surplus_Shortfall_Treatment__c,Person_Requesting__c
                                 FROM Funding_Request__c WHERE Id=: recId];
        Opportunity Opp = [SELECT Id,StageName,Applicant_1__c,Applicant_2__c,Funding_Variation_Request__c,SyncedQuote.Customer_Amount__c,FinServ__ReferredByContact__c,
                           Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId FROM Opportunity WHERE Id=: fr.Opportunity__c];
        
        boolean Lender_Credit_Doc_Exist = false;
        Set<Id> contentDocId = new Set<Id>();
        List<ContentDocumentLink> linkList = [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: fr.Opportunity__c];  
        if(!linkList.isEmpty()){
            for(ContentDocumentLink cnt : linkList){
                contentDocId.add(cnt.ContentDocumentId);
            }
        }
        if(!contentDocId.isEmpty()){
            List<ContentVersion> cvList = [SELECT Id, Title,Category__c,Current_in_use__c, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: contentDocId];
            if(!cvList.isEmpty()){
                for(ContentVersion cvv : cvList){
                    if(cvv.Category__c == 'Lender Credit Contract' && cvv.Current_in_use__c == true){
                        Lender_Credit_Doc_Exist = true;
                        break;
                    }
                }
            }
        }
        
        if((fr.Invoice_Amount__c != invoice_amount) || (fr.Request_Type__c != reqType)){
            if(fr.Invoice_Amount__c != invoice_amount){ 
                fr.Net_Surplus_Shortfall__c = fr.Opportunity__r.SyncedQuote.Customer_Amount__c - invoice_amount;    
            }
            fr.Invoice_Amount__c = invoice_amount; 
            fr.Request_Amount__c = req_amount;
            fr.Installation_Date__c = Inst_Date;
            fr.Customer_Authorisation_Status__c = 'Request sent to customer(s)';
            
            if(reqType == 'Variation' && fr.Request_Type__c != 'Variation'){
                fr.Request_Status__c = 'Variation requested by customer'; 
                fr.Variation_Status__c = 'Requested by customer';
                fr.Variation_Amount__c = Math.abs(opp.SyncedQuote.Customer_Amount__c - invoice_amount);
                fr.New_Customer_Amount__c = invoice_amount;
                fr.A1_Variation_Request_Submitted_Date__c = System.now();
                fr.Net_Surplus_Shortfall__c = Math.abs(opp.SyncedQuote.Customer_Amount__c - invoice_amount);
                fr.Surplus_Shortfall_Treatment__c = 'Variation to contract (requires re-approval)';
                if(fr.Person_Requesting__c == opp.Applicant_1__r.PersonContactId){
                    fr.Variation_Requested_By__c = opp.Applicant_1__c;
                }
                else if(fr.Person_Requesting__c == opp.Applicant_2__r.PersonContactId){
                    fr.Variation_Requested_By__c = opp.Applicant_2__c;
                }
                else {
                  fr.Variation_Requested_By__c = opp.Applicant_1__c;  
                }
                string SecureCodeOriginal = string.valueOf(Math.round((Math.random() * (9000) + 1000)));
                VOI_Detail__c voi  = new VOI_Detail__c();
                voi.Secure_Code_Orignal__c = SecureCodeOriginal;
                voi.Contact__c = Opp.Applicant_1__r.PersonContactId;
                voi.opportunity__c = Opp.Id;
                voi.VOI_Type__c = 'E-SIGN';
                insert voi;
                list<VOI_Status__c> voiList = new list<VOI_Status__c>();
                string IntrandomNumber1 = string.valueOf(Math.round((Math.random() * (900000) + 100000)));
                string URL = System.Label.baseUrl + 'DigitalSigning?oppId=' + opp.Id + '&conId=' + Opp.Applicant_1__r.PersonContactId + '&r='+ IntrandomNumber1;            
                VOI_Status__c obj = new VOI_Status__c();
                obj.Opportunity__c = Opp.id;
                obj.Contact__c = Opp.Applicant_1__r.PersonContactId;
                obj.Case_Status__c = 'Sent';
                obj.VOI_Detail__c = voi.id;
                obj.link_Expire_code__c = IntrandomNumber1;
                obj.VOI_Type_For__c = 'E-SIGN';
                obj.Current_VOI_section__c = 'CQP';
                obj.VOI_URL__c = URL;
                fr.VOI_link_app1__c = URL;
                voiList.add(obj);
                
                if(Opp.Applicant_2__c != null){
                    string SecureCodeOriginal1 = string.valueOf(Math.round((Math.random() * (9000) + 1000)));
                    VOI_Detail__c voi1  = new VOI_Detail__c();
                    voi1.Secure_Code_Orignal__c = SecureCodeOriginal1;
                    voi1.Contact__c = Opp.Applicant_2__r.personContactId;
                    voi1.opportunity__c = Opp.Id;
                    voi1.VOI_Type__c = 'E-SIGN';
                    insert voi1;
                    
                    string IntrandomNumber2 = string.valueOf(Math.round((Math.random() * (900000) + 100000)));
                    string URL1 = system.Label.baseUrl + 'DigitalSigning?oppId='+Opp.id + '&conId='+Opp.Applicant_2__r.personContactId +'&r='+IntrandomNumber2;
                    VOI_Status__c obj2 = new VOI_Status__c();
                    obj2.Opportunity__c = Opp.id;
                    obj2.VOI_Detail__c = voi1.id;
                    obj2.Contact__c = Opp.Applicant_2__r.personContactId;
                    obj2.Case_Status__c = 'Sent';
                    obj2.link_Expire_code__c = IntrandomNumber2;
                    obj2.VOI_Type_For__c = 'E-SIGN';
                    obj2.Current_VOI_section__c = 'CQP';
                    obj2.VOI_URL__c = URL1;
                    fr.VOI_link_app2__c = URL1;
                    voiList.add(obj2);
                }
                insert voiList; 
            }
            else if(reqType != 'Variation' && fr.Request_Type__c == 'Variation'){
                fr.Variation_Status__c = 'Variation cancelled by customer';
                fr.Variation_Amount__c = null;
                fr.New_Customer_Amount__c = null;
                fr.A1_Variation_Request_Submitted_Date__c = null;
                fr.Surplus_Shortfall_Treatment__c = null;
                fr.Variation_Requested_By__c = null;
                if(Lender_Credit_Doc_Exist == true){
                    if(fr.Requested_by__c == 'Customer'){
                        fr.Request_Status__c = 'Payment requested by customer';
                    }
                    else if(fr.Requested_by__c == 'Supplier'){
                        fr.Request_Status__c = 'Payment requested by supplier';  
                    }
                }
                else if(Lender_Credit_Doc_Exist == false){
                    if(fr.Requested_by__c == 'Customer'){
                        fr.Request_Status__c = 'Payment requested by customer (pending contract)';
                    }
                    else if(fr.Requested_by__c == 'Supplier'){
                        fr.Request_Status__c = 'Payment requested by supplier (pending contract)';  
                    }
                }
                
                List<voi_Status__c> OldvoiList = new List<voi_Status__c>();            
                for(voi_Status__c vs : [SELECT Id,CreatedDate,link_Expire_code__c, Name,Case_Status__c,Opportunity__r.id,
                                        contact__c,VOI_Type_For__c FROM VOi_status__c WHERE Opportunity__r.id =: Opp.id ORDER BY CreatedDate DESC ]){
                                            if(vs.VOI_Type_For__c == 'E-SIGN' && (vs.Case_Status__c == 'Sent' || vs.Case_Status__c == 'Delivered' || vs.Case_Status__c == 'Rejected')){
                                                vs.link_Expire_code__c = '';
                                                vs.Case_Status__c = 'Rejected';
                                                OldvoiList.add(vs);
                                            }
                                        }
                if(OldvoiList != null && OldvoiList.size() > 0){
                    Update OldvoiList; 
                }
                
                if(opp.Funding_Variation_Request__c == true){
                    opp.Funding_Variation_Request__c = false;
                    opp.StageName = 'Funding';
                    OpportunityTriggerHandler.isByPassValidation = true;
                    Update opp;
                    OpportunityTriggerHandler.isByPassValidation = false;
                }
            }
            else if(Lender_Credit_Doc_Exist == true){
                if(fr.Requested_by__c == 'Customer'){
                    fr.Request_Status__c = 'Payment requested by customer';
                }
                else if(fr.Requested_by__c == 'Supplier'){
                    fr.Request_Status__c = 'Payment requested by supplier';  
                }
            }
            else if(Lender_Credit_Doc_Exist == false){
                if(fr.Requested_by__c == 'Customer'){
                    fr.Request_Status__c = 'Payment requested by customer (pending contract)';
                }
                else if(fr.Requested_by__c == 'Supplier'){
                    fr.Request_Status__c = 'Payment requested by supplier (pending contract)';  
                }
            }
            
            fr.Request_Type__c = reqType;
            fr.A1_Acknowledgments__c = null;
            fr.A2_Acknowledgments__c = null;
            fr.A1_Payment_Authorisation_Submitted_Date__c = null;
            fr.A2_Payment_Authorisation_Submitted_Date__c = null;
            Update fr;
        }   
    } 
    
    @AuraEnabled
    public static void takeOffHold(String recordId){
        Funding_Request__c fr = [SELECT Id,Funding_Hold_Expiry_Date__c,Funding_On_Hold__c FROM Funding_Request__c WHERE Id=: recordId];
        if(fr != null && fr.Funding_On_Hold__c){
            fr.Funding_Hold_Expiry_Date__c = Date.today();
            update fr;
        }                                                  
    }                     
    
    @AuraEnabled
    public static void cancelVariation(String recordId){
        Set<Id> OldDocsIdToUpdate = new Set<Id>();
        Funding_Request__c fr = [SELECT Id,Variation_Status__c,Request_Type__c,Request_Status__c,Requested_by__c,
                                 Opportunity__c,Customer_Authorisation_Status__c,Previous_Req_Type__c
                                 FROM Funding_Request__c WHERE Id=: recordId];
        Opportunity opp = [SELECT Id,Funding_Variation_Request__c,Lender_Documents_after_Variation__c,
                           Previous_Loan_Amount_After_Variation__c FROM Opportunity WHERE Id =: fr.Opportunity__c];
        
        if(fr != null && fr.Request_Type__c == 'Variation'){
            // Updating Old Documents(Lender Credit Contract) again as Current in use True.
            if(opp.Lender_Documents_after_Variation__c != null){
                String OldDocsIdsString = opp.Lender_Documents_after_Variation__c;
                List<String> idStrings = OldDocsIdsString.split(',');
                system.debug('idStrings'+idStrings);
                for (String idString : idStrings) { 
                    OldDocsIdToUpdate.add(idString);
                }
                List<ContentVersion> oldCvListToUpdate = new List<ContentVersion>();
                List<ContentVersion> oldCvList = [SELECT Id, Title,Category__c,Current_in_use__c, ContentDocumentId FROM ContentVersion WHERE Id IN: OldDocsIdToUpdate]; 
                if(!oldCvList.isEmpty()){
                    for(ContentVersion cv : oldCvList){
                        if(cv.Category__c == 'Lender Credit Contract' && cv.Current_in_use__c == false){
                            cv.Current_in_use__c = true;
                            oldCvListToUpdate.add(cv);
                        }   
                    } 
                    if(!oldCvListToUpdate.isEmpty()){
                        Update oldCvListToUpdate;
                    }  
                }
            }
            
            //Updating Loan Amount to again Previous Loan Amount.
            List<Quote> qtlist = [SELECT Id,customer_amount__c,Gruop_Name__c,OpportunityId,Opportunity.SyncedQuote.Gruop_Name__c FROM Quote WHERE OpportunityId =: opp.Id];
            List<Quote> qtListToUpdate = new List<Quote>();
            if(!qtlist.isEmpty()){
                for(Quote qt : qtlist){
                    if(qt.Gruop_Name__c == qt.Opportunity.SyncedQuote.Gruop_Name__c){
                        qt.customer_amount__c =  opp.Previous_Loan_Amount_After_Variation__c;
                        qtListToUpdate.add(qt);
                    }
                }
                if(!qtListToUpdate.isEmpty()){
                    update qtListToUpdate; 
                }
            } 
            
            //Checking if No Lender Document available on Opp with Current in use True the Updating Request Status based on that.
            boolean Lender_Credit_Doc_Exist = false;
            Set<Id> contentDocId = new Set<Id>();
            List<ContentDocumentLink> linkList = [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: fr.Opportunity__c];  
            if(!linkList.isEmpty()){
                for(ContentDocumentLink cnt : linkList){
                    contentDocId.add(cnt.ContentDocumentId);
                }
            }
            if(!contentDocId.isEmpty()){
                List<ContentVersion> cvList = [SELECT Id, Title,Category__c,Current_in_use__c, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: contentDocId];
                if(!cvList.isEmpty()){
                    for(ContentVersion cvv : cvList){
                        if(cvv.Category__c == 'Lender Credit Contract' && cvv.Current_in_use__c == true){
                            Lender_Credit_Doc_Exist = true;
                            break;
                        }
                    }
                }
            }
            if(Lender_Credit_Doc_Exist == true){
                if(fr.Requested_by__c == 'Customer'){
                    fr.Request_Status__c = 'Payment requested by customer';
                }
                else if(fr.Requested_by__c == 'Supplier'){
                    fr.Request_Status__c = 'Payment requested by supplier';  
                }
            }
            else if(Lender_Credit_Doc_Exist == false){
                if(fr.Requested_by__c == 'Customer'){
                    fr.Request_Status__c = 'Payment requested by customer (pending contract)';
                }
                else if(fr.Requested_by__c == 'Supplier'){
                    fr.Request_Status__c = 'Payment requested by supplier (pending contract)';  
                }
            }
            
            fr.Variation_Status__c = 'Variation cancelled by customer';
            fr.Request_Type__c = fr.Previous_Req_Type__c;
            fr.Customer_Authorisation_Status__c = 'Request sent to customer(s)';
            fr.Variation_Amount__c = null;
            fr.New_Customer_Amount__c = null;
            fr.A1_Variation_Request_Submitted_Date__c = null;
            fr.Surplus_Shortfall_Treatment__c = null;
            fr.Variation_Requested_By__c = null;
            fr.A1_Acknowledgments__c = null;
            fr.A2_Acknowledgments__c = null;
            fr.A1_Payment_Authorisation_Submitted_Date__c = null;
            fr.A2_Payment_Authorisation_Submitted_Date__c = null;
            update fr;
            
            // Updating Voi's for rejected.
            List<voi_Status__c> OldvoiList = new List<voi_Status__c>();            
            for(voi_Status__c vs : [SELECT Id,CreatedDate,link_Expire_code__c, Name,Case_Status__c,Opportunity__r.id,
                                    contact__c,VOI_Type_For__c FROM VOi_status__c WHERE Opportunity__r.id =: opp.id ORDER BY CreatedDate DESC ]){
                                        if(vs.VOI_Type_For__c == 'E-SIGN' && (vs.Case_Status__c == 'Sent' || vs.Case_Status__c == 'Delivered' || vs.Case_Status__c == 'Rejected')){
                                            vs.link_Expire_code__c = '';
                                            vs.Case_Status__c = 'Rejected';
                                            OldvoiList.add(vs);
                                        }
                                    }
            if(OldvoiList != null && OldvoiList.size() > 0){
                Update OldvoiList; 
            }
            
            // Updating Opportunity.
            if(opp.Funding_Variation_Request__c == true){
                opp.Funding_Variation_Request__c = false;
                opp.StageName = 'Funding';
                OpportunityTriggerHandler.isByPassValidation = true;
                Update opp;
                OpportunityTriggerHandler.isByPassValidation = false;
            }
        }                                                  
    }  
    
    @AuraEnabled
    Public static fundingWrapper getfundRequest2(String oppId){ 
        fundingWrapper fdWrapper = new fundingWrapper();
        list<Opportunity> opp = [select id,syncedquote.customer_amount__c,SyncedQuote.Product__r.No_of_Signatories_allowed__c,SyncedQuote.Product__r.Short_Fall_Instructions__c,SyncedQuote.Product__r.Surplus_Instructions__c,Applicant_1__c,Applicant_2__c,Applicant_1__r.PersonContactId,Applicant_2__r.PersonContactId,
                                 Referred_by_Company__r.Name,Applicant_1__r.name,Applicant_2__r.name,Applicant_1__r.Number_of_applicants_to_operate_account__pc,SyncedQuote.lender__c,Approved_Date__c,Approved_Expire_Date__c from opportunity where id=:oppId LIMIT 1]; 
        list<Funding_Request__c> fnList = [SELECT ID,Request_Type__c,Previous_Req_Type__c,Invoice_Amount__c,Request_Status__c,Customer_Authorisation_Status__c,Customer_Authorisation_Type__c,A1_Acknowledgments__c,Opportunity__c, VOI_link_app1__c,Request_Date__c,
                                           A2_Acknowledgments__c,Surplus_Shortfall_Treatment__c,Requested_by__c,Variation_Requested_By__c,Variation_Type__c,Variation_Status__c,Variation_Amount__c,A1_Variation_Request_Submitted_Date__c,Contact_1__c,Contact_2__c,
                                           New_Customer_Amount__c,Applicant_acknowledgements__c,Date_Last_Request_Status_Changes__c,Request_Amount__c,Funded_To_Date__c,Person_Requesting__c,Person_Requesting__r.Name,Variation_Requested_By__r.name
                                           from Funding_Request__c WHERE Opportunity__C =:oppId order by createdDate desc limit 1];
        
        fdWrapper.totalFunds = opp[0].syncedquote.customer_amount__c;
        fdWrapper.Opportunity = opp[0];
        fdWrapper.app1 = opp[0].Applicant_1__c;
        fdWrapper.app2 = opp[0].Applicant_2__c;
        fdWrapper.fundReqlist = fnList;
        fdWrapper.authoType = opp[0].SyncedQuote.Product__r.No_of_Signatories_allowed__c;
        fdWrapper.tmcu = opp[0].Applicant_1__r.Number_of_applicants_to_operate_account__pc;
        if(opp[0].Approved_Expire_Date__c <= Date.today()){
            fdWrapper.isExpired = true;
        }
        else{
            fdWrapper.isExpired = false;
        }
        
        boolean Lender_Credit_Doc_Exist = false;
        Set<Id> contentDocId = new Set<Id>();
        List<ContentDocumentLink> linkList = [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: oppId];  
        if(!linkList.isEmpty()){
            for(ContentDocumentLink cnt : linkList){
                contentDocId.add(cnt.ContentDocumentId); 
            }
        }
        if(!contentDocId.isEmpty()){
            List<ContentVersion> cvList = [SELECT Id, Title,Category__c,Current_in_use__c, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: contentDocId];
            if(!cvList.isEmpty()){
                for(ContentVersion cvv : cvList){
                    if(cvv.Category__c == 'Lender Credit Contract' && cvv.Current_in_use__c == true){
                        Lender_Credit_Doc_Exist = true;
                        break;
                    }
                }
            }
        }
        fdWrapper.isLenderCredit = Lender_Credit_Doc_Exist;
        return fdWrapper;
    }
    
    @AuraEnabled
    Public static void createReqest(Funding_Request__c fundRequest){
        if(fundRequest != null){
            FundingRequestTriggerHandler.isByPassAuthFromSite = true;
            upsert fundRequest;
            FundingRequestTriggerHandler.isByPassAuthFromSite = false;
            Opportunity opp = [SELECT Id,Name,StageName FROM Opportunity WHERE Id=: fundRequest.Opportunity__c LIMIT 1];
            if(opp.StageName != 'Funding'){
                opp.StageName = 'Funding';
                Update opp;
            }
        }
    }
    
    @AuraEnabled
    Public static String createVariation(Funding_Request__c fundRequest){
        if(fundRequest != null){
            Opportunity Opp = [Select id,Applicant_1__c,Applicant_2__c,Applicant_1__r.personContactId,Applicant_2__r.personContactId from Opportunity where id=:fundRequest.Opportunity__c];
            string SecureCodeOriginal = string.valueOf(Math.round((Math.random() * (9000) + 1000)));
            VOI_Detail__c voi  = new VOI_Detail__c();
            voi.Secure_Code_Orignal__c = SecureCodeOriginal;
            voi.Contact__c = Opp.Applicant_1__r.PersonContactId;
            voi.opportunity__c = Opp.Id;
            voi.VOI_Type__c = 'E-SIGN';
            insert voi;
            list<VOI_Status__c> voiList = new list<VOI_Status__c>();
            string IntrandomNumber1 = string.valueOf(Math.round((Math.random() * (900000) + 100000)));
            string URL = System.Label.baseUrl + 'DigitalSigning?oppId=' + opp.Id + '&conId=' + Opp.Applicant_1__r.PersonContactId + '&r='+ IntrandomNumber1;
            String urlToReturn = System.Label.baseUrl + 'DigitalSigning?oppId=' + opp.Id + '&conId=' + Opp.Applicant_1__r.PersonContactId + '&r='+ IntrandomNumber1;
            VOI_Status__c obj = new VOI_Status__c();
            obj.Opportunity__c = Opp.id;
            obj.Contact__c = Opp.Applicant_1__r.PersonContactId;
            obj.Case_Status__c = 'Sent';
            obj.VOI_Detail__c = voi.id;
            obj.link_Expire_code__c = IntrandomNumber1;
            obj.VOI_Type_For__c = 'E-SIGN';
            obj.Current_VOI_section__c = 'CQP';
            obj.VOI_URL__c = URL;
            fundRequest.VOI_link_app1__c = URL;
            voiList.add(obj);
            
            if(Opp.Applicant_2__c != null){
                string SecureCodeOriginal1 = string.valueOf(Math.round((Math.random() * (9000) + 1000)));
                VOI_Detail__c voi1  = new VOI_Detail__c();
                voi1.Secure_Code_Orignal__c = SecureCodeOriginal1;
                voi1.Contact__c = Opp.Applicant_2__r.personContactId;
                voi1.opportunity__c = Opp.Id;
                voi1.VOI_Type__c = 'E-SIGN';
                insert voi1;
                
                string IntrandomNumber2 = string.valueOf(Math.round((Math.random() * (900000) + 100000)));
                string URL1 = system.Label.baseUrl + 'DigitalSigning?oppId='+Opp.id + '&conId='+Opp.Applicant_2__r.personContactId +'&r='+IntrandomNumber2;
                VOI_Status__c obj2 = new VOI_Status__c();
                obj2.Opportunity__c = Opp.id;
                obj2.VOI_Detail__c = voi1.id;
                obj2.Contact__c = Opp.Applicant_2__r.personContactId;
                obj2.Case_Status__c = 'Sent';
                obj2.link_Expire_code__c = IntrandomNumber2;
                obj2.VOI_Type_For__c = 'E-SIGN';
                obj2.Current_VOI_section__c = 'CQP';
                obj2.VOI_URL__c = URL1;
                fundRequest.VOI_link_app2__c = URL1;
                voiList.add(obj2);
                if(fundRequest.Variation_Requested_By__c == Opp.Applicant_2__c){
                    urlToReturn = URL1;
                }
            }
            insert voiList;
    
            upsert fundRequest;
            return urlToReturn;
        }
        else{
            return '';
        }
    }
    
    @AuraEnabled
    public static QuoteDetailWrapper getDocument(String OppId) {
        QuoteDetailWrapper qtWrapper = new QuoteDetailWrapper();
        list<ContentDocumentLink> allCdLinks = new list<ContentDocumentLink> ();
        ContentDocument doc;
        Document_Requested__c req;
        if(OppId != null){
            for(ContentDocumentLink cdDoc : [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility 
                                             from ContentDocumentLink where LinkedEntityId =: OppId]){
                                                 if(cdDoc != null){
                                                     allCdLinks.add(cdDoc);  
                                                 }
                                             }
        }
        Set<id> ContentDocIds = new Set<id>();
        Set<id> newConDocIds = new Set<id>();
        Set<Id> docReq = new Set<Id>();
        if(allCdLinks.Size() > 0 && allCdLinks != null){
            for(ContentDocumentLink cv : allCdLinks){   
                ContentDocIds.add(cv.ContentDocumentId);
            }
            for(ContentVersion cvs : [SELECT Id,contentDocumentId, title,Category__c,Current_in_use__c,Document_Requested__c from contentVersion where contentDocumentId IN: ContentDocIds ORDER BY CreatedDate DESC]){
                if(cvs != null && cvs.Current_in_use__c ==true && cvs.Category__c=='Purchase Invoice'){
                    newConDocIds.add(cvs.contentDocumentId);  
                    docReq.add(cvs.Document_Requested__c);
                }
            }
        }
        if (!newConDocIds.isEmpty()) {
            doc = [SELECT Id,Title,FileType FROM ContentDocument WHERE Id IN : newConDocIds LIMIT 1];
            ContentVersion Cvv = [SELECT Id,contentDocumentId,Document_Requested__c,CreatedDate,Current_in_use__c from contentVersion where contentDocumentId =: doc.Id AND Current_in_use__c = true ORDER By CreatedDate DESC LIMIT 1];
            if(doc != null && Cvv.Document_Requested__c != null){
                String name = doc.Title;
                if(name.length() > 22) {
                    String truncatedName = name.substring(0, 25) + '...';
                    qtWrapper.NmList.add(truncatedName);
                }
                else{
                    qtWrapper.NmList.add(doc.Title); 
                }
                qtWrapper.cdlId.add(doc.Id);
                qtWrapper.document = doc; 
                qtWrapper.docReqId = Cvv.Document_Requested__c;
            } 
        }
        return qtWrapper;   
    }
    
    @auraEnabled
    public static list<QuoteDetailWrapper> ret(List<QuoteDetailWrapper> qtwrapper){
        system.debug('qtwrapper'+qtwrapper);
        QuoteDetailWrapper quoteDetailWrpList2 = New QuoteDetailWrapper();
        qtwrapper.add(quoteDetailWrpList2);
        system.debug('newwqtwrapper'+qtwrapper);
        return qtwrapper;
    }
    
    @InvocableMethod(label='Send SMS' description='send sms(after 15 mins) to applicants if any VOi is pending after variation request created ')
    public static void sendMessages(List<Id> Ids){
        list<Funding_Request__c> frRec = [select id,Opportunity__r.Applicant_1__c,Opportunity__r.Contact_1__c,Opportunity__r.SyncedQuote.Product__r.Funding_Authorisation_Type__c, Requested_by__c,
                                          Opportunity__r.Referred_by_Company__c,Applicant_2_A2__c,Applicant_2_A2__r.PersonEmail,Applicant_1_A1__c,Applicant_1_A1__r.PersonEmail,Applicant_1_A1__r.Name,Applicant_2_A2__r.Name,Person_Requesting__r.name,
                                          Customer_Authorisation_Type__c,Date_Last_Request_Status_Changes__c,Customer_Authorisation_Status__c,Variation_Requested_By__r.name,Opportunity__c,Applicant_1_A1__r.Phone,Applicant_2_A2__r.Phone,
                                          Funding_On_Hold__c,Person_Requesting__r.id,Applicant_1_A1__r.PersonContactId,Applicant_2_A2__r.PersonContactId,Person_Requesting__c,Request_Status__c,Opportunity__r.FinServ__ReferredByContact__c,
                                          Opportunity__r.FinServ__ReferredByContact__r.Email from Funding_Request__c where Request_Status__c = 'Variation requested by customer' AND ID IN: Ids AND Opportunity__c != null];
        set<id> oppId = new set<id>();
        for(Funding_Request__c fr : frRec){
            oppId.add(fr.Opportunity__c);
        }
        Map<id, list<id>> conMap = new Map<id, list<id>>();
        for(VOi_Status__c vs : [select id,Case_Status__c,Contact__c,Opportunity__c from VOi_Status__c where opportunity__c IN: oppId AND (Case_Status__c='Sent' OR Case_Status__c='Delivered')]){
            if(!conMap.containsKey(vs.Opportunity__c)){
                conMap.put(vs.Opportunity__c,new list<id>{vs.Contact__c});
            }
            else{
                conMap.get(vs.Opportunity__c).add(vs.Contact__c);
            }
        }
        system.debug('map'+conMap);
        
        if(conMap != null){
            for(Funding_Request__c fr : [select id,Opportunity__c,Applicant_1_A1__c,Applicant_2_A2__c,Applicant_1_A1__r.personContactId,Applicant_2_A2__r.personContactId,Applicant_1_A1__r.Name,Applicant_2_A2__r.Name,Applicant_1_A1__r.Phone,Applicant_2_A2__r.Phone,Person_Requesting__r.name,Variation_Requested_By__c,Variation_Requested_By__r.name from Funding_Request__c where Opportunity__c IN:conMap.keyset()]){
                system.debug('mapvalues'+conMap.get(fr.Opportunity__c));
                system.debug('PersonId'+fr.Applicant_1_A1__r.personContactId);
                if(conMap.get(fr.Opportunity__c).contains(fr.Applicant_1_A1__r.personContactId)){
                    if(fr.Variation_Requested_By__c == fr.Applicant_1_A1__c){
                        system.debug('istOf1');
                        string txt = 'Hi '+fr.Applicant_1_A1__r.Name+', Action required! We have received your variation request but you must first sign the updated credit proposal before we can process your request. Please refer to your email to review and approve. The Parker Lane team :)';
                        sendMessage(fr.Applicant_1_A1__r.Phone, txt);
                    }
                    else if(fr.Variation_Requested_By__c == fr.Applicant_2_A2__c){
                        system.debug('2ndOf1');
                        string txt = 'Hi '+fr.Applicant_1_A1__r.Name+', Action required! '+fr.Variation_Requested_By__r.name+' has requested a variation to your approved limit and we require your authorisation. Please refer to your email to review and approve. The Parker Lane team :)';
                        sendMessage(fr.Applicant_1_A1__r.Phone, txt);
                    }
                }
                if(conMap.get(fr.Opportunity__c).contains(fr.Applicant_2_A2__r.personContactId)){
                    if(fr.Variation_Requested_By__c == fr.Applicant_2_A2__c){
                        system.debug('2ndOf1');
                        string txt = 'Hi '+fr.Applicant_2_A2__r.Name+', Action required! We have received your variation request but you must first sign the updated credit proposal before we can process your request. Please refer to your email to review and approve. The Parker Lane team :)';
                        sendMessage(fr.Applicant_2_A2__r.Phone, txt);
                    }
                    else if(fr.Variation_Requested_By__c == fr.Applicant_1_A1__c){
                        system.debug('2ndOf2');
                        string txt = 'Hi '+fr.Applicant_2_A2__r.Name+', Action required! '+fr.Variation_Requested_By__r.name+' has requested a variation to your approved limit and we require your authorisation. Please refer to your email to review and approve. The Parker Lane team :)';
                        sendMessage(fr.Applicant_2_A2__r.Phone, txt);
                    }
                }
            }
        }
    }
    
    public static void sendMessage(String phone, String templateText){
        List<smagicinteract__smsMagic__c> smsObjectList = new List<smagicinteract__smsMagic__c> ();
        smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
        smsObject.smagicinteract__SenderId__c = 'parkerlane';
        smsObject.smagicinteract__PhoneNumber__c = phone;//contact.MobilePhone;
        smsObject.smagicinteract__Name__c = 'test';//contact.Name; // recordsname
        smsObject.smagicinteract__ObjectType__c = 'Funding Request'; // record type
        smsObject.smagicinteract__disableSMSOnTrigger__c = 0; // this field either be 0 or 1, if you specify the value as 1 then sms will not get send but entry of sms will get create under SMS History object
        smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
        smsObject.smagicinteract__SMSText__c = templateText;
        //smsObject.smagicinteract__Funding_Request__c = fundingId;
        smsObjectList.add(smsObject);
        Database.SaveResult[] results = Database.insert(smsObjectList, false);
        for(Database.SaveResult result : results) {
            if(result.isSuccess()) {
                //  System.debug('Successfully inserted Accounts : ' + result.getId());
            } else {
                for(Database.Error error : result.getErrors()) {
                    System.debug('Error Status : ' + error.getMessage() + ' : ' + 'Error Fields : ' + error.getFields());
                }
            }
        }
    }
        
    @AuraEnabled
    public static void escalateFunding(String recordId){
        Funding_Request__c fr = [SELECT Id,Funding_escalation__c,Funding_escalation_date__c FROM Funding_Request__c WHERE id=: recordId LIMIT 1];
        if(fr != null){
            fr.Funding_escalation__c = true;
            fr.Funding_escalation_date__c = Date.today();
            update fr;
        }                                                  
    } 
    
    @AuraEnabled
    public static void DeEscalateFunding(String recordId){
        Funding_Request__c fr = [SELECT Id,Funding_escalation__c,Funding_escalation_date__c FROM Funding_Request__c WHERE id=: recordId LIMIT 1];
        if(fr != null){
            fr.Funding_escalation__c = false;
            fr.Funding_escalation_date__c = null;
            update fr;
        }                                                  
    }    
    
    public class QuoteDetailWrapper{
        @auraEnabled public String masterQuote {get;set;}
        @auraEnabled public Decimal Amount {get;set;}
        @auraEnabled public String errorMessage {get;set;}
        @auraEnabled public Boolean checkError {get;set;}
        @auraEnabled public Decimal minAmt {get;set;}
        @auraEnabled public Decimal maxAmt {get;set;}
        @auraEnabled public list<String> NmList =new List<string>();
        @auraEnabled public list<id> cdlId =new List<id>();
        @auraEnabled public ContentDocument document {get;set;} 
        @auraEnabled public Id docReqId {get;set;} 
    }
    
    public class fundingWrapper{
        @AuraEnabled public boolean isSecond;
        @AuraEnabled public boolean isCustomer;
        @AuraEnabled public Decimal totalFunds;
        @AuraEnabled public list<Funding_Request__c> fundReqlist;
        @AuraEnabled public Opportunity Opportunity;
        @AuraEnabled public String app1;
        @AuraEnabled public String app2;
        @AuraEnabled public String authoType; 
        @AuraEnabled public String tmcu;
        @AuraEnabled public boolean isLenderCredit;
        @AuraEnabled public boolean isExpired;
    }
    
    /*  @AuraEnabled
public static Boolean hasCurrentVersion(Id oppId) {
Boolean hasLenderCreditContractCurrent = false;
Boolean hasPurchaseInvoiceCurrent = false;
Set<Id> contentDocId = new Set<Id>();

List<ContentDocumentLink> linkList = [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: oppId];  
if(!linkList.isEmpty()){
for(ContentDocumentLink cnt : linkList){
contentDocId.add(cnt.ContentDocumentId); 
}
}
if(!contentDocId.isEmpty()){
List<ContentVersion> cvList = [SELECT Id, Title,Category__c,Current_in_use__c, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: contentDocId];
if(!cvList.isEmpty()){
for(ContentVersion cvv : cvList){
if(cvv.Category__c == 'Lender Credit Contract' && cvv.Current_in_use__c == true){
hasLenderCreditContractCurrent = true;
}
if(cvv.Category__c == 'Purchase Invoice' && cvv.Current_in_use__c == true){
hasPurchaseInvoiceCurrent = true; 
}
}
}
}
return hasLenderCreditContractCurrent && hasPurchaseInvoiceCurrent;
} */
    @AuraEnabled
    public static void insertAuthorisationCertificate(String oppId){
        Funding_Request__c  fr = [select id,Opportunity__c,Opportunity__r.name,CREATEDDATE from Funding_Request__c where Opportunity__c =:oppId ORDER BY CREATEDDATE DESC LIMIT 1];
        String[] oppName = fr.Opportunity__r.name.split(',');
        string name = 'Funding Autorisation Certificate for '+oppName;
        
        Document_Requested__c dc = new Document_Requested__c();
        dc.Category__c = 'Funding Authorisation Certificate';
        dc.Opportunity__c = oppId;
        insert dc;
        
        PageReference pdf = Page.FundingAuthorisationCertificatePDF;
        pdf.getParameters().put('id',fr.Id);
        pdf.setRedirect(true);
        Blob bPDF;
        
        if (Test.IsRunningTest()){
            bPDF=Blob.valueOf('UNIT.TEST');
        }
        else{
            bPDF = pdf.getContent();
        }
        
        ContentVersion ContVerFile = new ContentVersion();
        ContVerFile.VersionData = bPDF;
        ContVerFile.Title = name; 
        ContVerFile.PathOnClient= name+'.pdf'; 
        ContVerFile.Document_Requested__c = dc.Id;
        ContVerFile.FirstPublishLocationId = oppId;
        insert ContVerFile;
        /*list<ContentVersion> conDocId = new list<ContentVersion>();
        
        conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :ContVerFile.Id];
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = oppId;
        cdl.ContentDocumentId = conDocId[0].ContentDocumentId;
        cdl.shareType = 'V';
        Insert cdl;*/
        
        if(ContVerFile != null){
            Document_Requested__c doc = new Document_Requested__c();
            doc.id = dc.Id;
            doc.isComplete__c = true;
            update doc;
        }
    }  
}