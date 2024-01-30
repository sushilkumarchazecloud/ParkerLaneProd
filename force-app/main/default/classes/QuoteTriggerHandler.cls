public class QuoteTriggerHandler {
    public void onAfterDelete(List<Quote> oldQuote, Map<Id,Quote> oldQuoteMap){
        Set<Id> v = new Set<Id>();
        for(Quote q: oldQuote){
            if(q.Application__c == true){
                v.add(q.OpportunityId);
            }
        }
        if(v.size() > 0){
            List<Opportunity> oppList = [Select Id, Loan_Amount__c from Opportunity where Id in: v];
            for(Opportunity opp: oppList){
                opp.Loan_Amount__c = 0;
                opp.Lender__c = '';
            }
            update oppList;
        }
    }
}