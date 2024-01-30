@istest
public class CalculateTotalFeesTest {
    
    static testmethod void calculateFeesTest(){
        Product2 product = New Product2(IsActive =true,
                                        Product_Type__c = 'Green Loan',
                                        Acceptable_Loan_Purpose__c = 'Home Improvement',
                                        Name = 'product',
                                        Maximum_Loan_Term_Years__c =1);
        insert product;
        Opportunity oppty = new Opportunity ();
        oppty.name = 'test Oppty';
        oppty.StageName='Assessment Needed'; 
        oppty.CloseDate = Date.today();
        insert oppty;
        
        Quote quote = New Quote();
        quote.OpportunityId = oppty.Id;
        quote.Name = 'quote';
        quote.Loan_Term__c = 12;
        insert quote;
        
        Loan_Fees__c fee1 = New Loan_Fees__c(Amount__c = 200, Product__c = product.Id);
        insert fee1;
        
        Loan_Fees__c fee2 = New Loan_Fees__c(Amount__c = 200, Quote__c = quote.Id);
        insert fee2;
        
        Loan_Fees__c fee3 = New Loan_Fees__c(Amount__c = 200, Quote__c = quote.Id, Fee_Type__c = 'Account Keeping');
        insert fee3;
        
        fee1.Amount__c = 300;
        update fee1;
        
        delete fee1;
        delete fee2;
    }
}