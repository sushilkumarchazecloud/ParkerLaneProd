@isTest
private class updateQuoteHandleTest {
    
    @isTest
    static void testUpdateQuote() {
        Opportunity opp = new Opportunity();
        opp.Name='Test Opportunity';
        opp.StageName='Working';
        opp.CloseDate=System.today();  
        insert opp;
        
        Quote quote = new Quote();
        quote.Name = 'Test Quote';
        quote.OpportunityId=opp.Id;
        insert quote;
        
        updateQuoteHandle.updateQuote(quote.Id);

    }
}