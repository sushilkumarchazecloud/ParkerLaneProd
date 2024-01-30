public without sharing class AuthorisationCertificateController {
    public Funding_Request__c frRec{get; set;}
    public string oppName{get; set;}
    public string auhtoDate{get; set;}
    public string authoName{get; set;}
    public boolean isTwoPerson{get; set;}
    
     /*public Boolean init{
        get{
            init();            
            return false;
        }
    } */

    public AuthorisationCertificateController(){
        ID fundId = ApexPages.currentPage().getParameters().get('id');
        system.debug('FUNDIUNID'+fundId);
        frRec = [select Id,Opportunity__r.Applicant_1__c,Opportunity__r.SyncedQuote.Product__r.Funding_Authorisation_Type__c, Requested_by__c,Request_Type__c,Opportunity__c,Total_Funds_Approved_Customer_Amount__c,Invoice_Amount__c,Disbursement_amount__c,Net_Funds_Available__c,Funded_To_Date__c,Net_Surplus_Shortfall__c,
                                          Opportunity__r.Referred_by_Company__c,Applicant_2_A2__c,Applicant_2_A2__r.PersonEmail,Applicant_1_A1__c,Applicant_1_A1__r.PersonEmail,Opportunity__r.Name,Opportunity__r.Referred_by_Company__r.Name,Applicant_1_A1__r.Phone,Applicant_2_A2__r.Phone,Request_Amount__c,Request_Date__c,Opportunity__r.Lender__c,
                                          Customer_Authorisation_Type__c,Date_Last_Request_Status_Changes__c,Customer_Authorisation_Status__c,Applicant_1_A1__r.PersonContactId,Applicant_2_A2__r.PersonContactId,Person_Requesting__r.Name,Opportunity__r.Purpose__c,Applicant_1_A1__r.Name,Applicant_2_A2__r.Name,Installation_Date__c,
                                          A1_Payment_Authorisation_Submitted_Date__c,A2_Payment_Authorisation_Submitted_Date__c,Opportunity__r.SyncedQuote.Brokerage_Amount__c,
                                          Funding_On_Hold__c,Person_Requesting__c,Person_Requesting__r.email,Person_Requesting__r.id,Opportunity__r.Contact_1__c,Opportunity__r.Contact_2__c,Request_Status__c,Opportunity__r.FinServ__ReferredByContact__c,Opportunity__r.FinServ__ReferredByContact__r.Email from Funding_Request__c where id=: fundId LIMIT 1];
        if(frRec.Opportunity__c != null){
        	String nme = frRec.Opportunity__r.Name; 
        	string[] ch = nme.split(',');
        	oppName = ch[0];    
        }
        Datetime now = System.now();
        auhtoDate = now.format('dd/MM/yyyy hh:mm a');
        authoName = frRec.Applicant_1_A1__r.name;
        if(frRec.Applicant_2_A2__c != null){
            authoName = authoName+','+' '+frRec.Applicant_2_A2__r.name;
            isTwoPerson = true;
        }
        
    }
}