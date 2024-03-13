/**
 * @description       : This is a Selector Class for All object
 * @Author            : Sethu Singh Rawat
 * @Created on        : 01/03/2024
**/
public class AllObjectsQuerySelector {
    
    public static Lead selectLeadId(String leadId){
        return[SELECT Id,Name,Application_Sections__c, Current_Application_Sections__c FROM Lead WHERE id =: leadId];
    }
    
    /**
    * @description	: Retrieves a Map of Product2 records based on the specified productTypeId.
    * Only active products with the specified productTypeId are included in the result.
    * @author 		: Sethu Singh Rawat
    * @createdDate 	: 01-03-2024
    * @param 		: productTypeId 
    * @return   	: Map<Id, Product2> 
    */
    public static Map<Id, Product2> selectedproductTypeId(String productTypeId) {
        return new Map<Id, Product2>([SELECT Id, IsActive, Actual_Comparison_Rate__c, Commission_Amount__c, Brokerage_Amount__c,
                                      Comparison_Rate_Disclaimer__c, Comparison_Rate_Warning__c, Eligibility__c, Acceptable_Loan_Purpose__c,
                                      Features__c, Interest_Rate__c, Interest_Rate_Type__c, Lender__c, Loan_Amount__c, Is_Feature_Product__c,
                                      Loan_Term__c, Name, Security__c, Min_Loan_Term__c, Max_Loan_Term__c, Product_Type__c, Default_Loan_Term_Months__c,
                                      Interest_Rate_Based_On__c,
                                      (SELECT ID, Active__c, Amount__c, Description__c, Fee_From__c, Fee_Type__c, Frequency__c,
                                       Notes__c, Override_allowed__c, Product__c, Product_Loan_Fees__c, Quote__c FROM Loan_Fees__r),
                                      (SELECT id, From_amount__c, Interest_rate__c, To_amount__c, Comparison_rate__c, Product__c FROM Loan_Rates__r)
                                      FROM Product2 WHERE isActive = TRUE AND product_type_lookup__c = :productTypeId  ORDER BY Product_Order__c ASC LIMIT 3]);
    }
    
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
            WHERE Gruop_Name__c = :masterQuote AND (Lead__c = :leadId OR OpportunityId =: leadId)//WITH SECURITY_ENFORCED
            ORDER BY Product__r.Product_Order__c ASC 
            LIMIT 3];
    }
}