public class ApprovedRemainderController {
    
    public String opportunityId{get;set;}
    public Product2 product{get;set;}
    public Quote Qt{get;set;}
    public String oppName{get;set;}
    
    public Boolean init{
        get{
            init();            
            return false;
        }
    } 
    
    public void init(){
        product = new Product2();
        Qt = new Quote();
        
        Qt = [Select id,Customer_Amount__c, Product__c,Product__r.id from Quote where OpportunityId =: opportunityId AND Application__c = true LIMIT 1]; 
        
        product = [Select id, Customer_Approval_Email_Instructions__c,Funding_Authorisation_Type__c from Product2 WHERE id =: Qt.Product__r.id LIMIT 1];
    }
    
    public opportunity getOpportunity(){
        Opportunity opp = [select id,Applicant_1__c,Applicant_2__c,Approved_Expire_Date__c,Loan_Amount__c ,Opportunity.Applicant_2_FirstName__c,name,Applicant_1_FirstName__c,Applicant_1_Email__c,
                           FinServ__ReferredByContact__r.Name,FinServ__ReferredByContact__r.Account.name,purpose__c,leadAddress__c, Applicant_1__r.phone, Send_the_quote_to__c 
                           from opportunity where id=:opportunityId LIMIT 1];
        oppName = opp.name.split(',')[0];
        return opp;
    }
    
}