@isTest
public class TestUpdateQuotesByProductBatch {
    
    static testMethod void testUpdateQuotesByProduct() {
        Product2 product = new product2();   
        product.Name='Test Product';
        product.Interest_Rate__c=3.5; 
        product.Actual_Comparison_Rate__c=4.0;
        product.Commission_Amount__c=100.0;
        product.Brokerage_Amount__c=200;
        product.Default_Loan_Term__c = 8;
        product.Lender__c='Test Lender';
        
        insert product;
        
        Loan_Fees__c loanFeeq = new Loan_Fees__c();
        loanFeeq.Amount__c=5000;
        loanFeeq.Fee_Type__c='Account Keeping';
        loanFeeq.Frequency__c='Setup';
        loanFeeq.Product__c = product.id;
        insert loanFeeq;
        
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opportunity';
        opp.StageName='Working';
        opp.CloseDate=System.today();  
        insert opp;
        
        Quote quote = new Quote();
        quote.Name='Test Quote';
        quote.Customer_Amount__c=8000;
        quote.OpportunityId=opp.Id;
        quote.Product__c=product.Id;
        quote.Loan_Term__c = 80;
        
        insert quote;
        
        Loan_Rate__c loanRate = new Loan_Rate__c();
        loanRate.Interest_rate__c=3.0;
        loanRate.From_amount__c=1000; 
        loanRate.To_amount__c=10000; 
        loanRate.Comparison_rate__c=3.5;
        loanRate.Product__c=product.Id;
        insert loanRate;
        
        Loan_Fees__c loanFee = new Loan_Fees__c();
        loanFee.Amount__c=5000;
        loanFee.Fee_Type__c='Account Keeping';
        loanFee.Frequency__c='Setup';
        loanFee.Quote__c = quote.id;
        loanFee.Product_Loan_Fees__c = loanFeeq.Id;
        insert loanFee;
        
        test.startTest();
        updateQuotesByProductBatch obj = new updateQuotesByProductBatch(product.Id);
        database.executeBatch(obj,50);
        test.stopTest();
        
        Quote updatedQuote = [SELECT Id,Name,product__r.Name, Actual_Comparison_Rate__c, Interest_Rate__c,
                              Loan_Term__c, Commission_Amount__c, Brokerage_Amount__c, Lender__c 
                              FROM Quote WHERE Id=:quote.Id  ];
        
    }
    
}