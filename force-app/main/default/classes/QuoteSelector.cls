/**
 * @description       : This is a Selector Class for Quote
 * @Author            : Sethu Singh Rawat
 * @Created on        : 26/02/2024
 * @Last Modified By  : Sethu Singh Rawat
 * @Last Modified On  : 26/02/2024
**/
public without sharing class QuoteSelector {
    
    /**
    * @description : Retrieves up to three Quote records based on the provided leadId and masterQuote.
    * The query is enforced with sharing rules for record-level security.
    * @Author      : Sethu Singh Rawat
    * @param 	   : leadId
    * @param       : masterQuote
    * @return      : Map<Id, Quote>
    */
    public static List<Quote> selectQuoteByLeadIdAndMasterQuote(String leadId, String masterQuote) {
        return[
            SELECT Id, Actual_Comparison_Rate__c, Comparison_Rate_Warning__c, Eligibility__c, Product__r.Features__c,Product_Type_Lookup__r.Name,
            Interest_Rate__c, Customer_Amount__c, Loan_Term__c, Name, Product__r.Eligibility_Description__c, Product__r.Minimum_Loan_Amount__c,
            Monthly_Repayment__c, Product__r.Min_Loan_Term__c, Product__r.Max_Loan_Term__c, Purpose__c, Lead__c, Product__r.Maximum_Loan_Amount__c, 
            Product__c, Product__r.Comparison_Rate_Display__c, Product__r.Security__c, Product__r.Interest_Rate_Type__c,
            Product__r.Interest_Rate_From__c, Product__r.Product_Order__c, Product__r.Is_Feature_Product__c, Total_Setup_Fees__c,
            Product__r.Total_Setup_Fees__c, Product__r.Decision_in_Hours__c, Product__r.Interest_Rate_Based_On__c, Application__c, Product_Description__c,
            Total_loan_amount__c, Up_Front_Costs_Applicable__c, Product__r.Interest_Rate__c, OpportunityId, Product__r.Default_Loan_Term_Months__c,
            Product__r.What_document_needs_to_apply__c, Product__r.Summary_Page_What_You_ll_Get__c, Monthly_Account_Keeping_Fees__c, Lender__c, Product_Type__c
            FROM Quote 
            WHERE Gruop_Name__c = :masterQuote AND Lead__c = :leadId //WITH SECURITY_ENFORCED
            ORDER BY Product__r.Product_Order__c ASC 
            LIMIT 3 
            
        ];
    }


}