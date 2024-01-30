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
    
    public void afterInsert(List<Quote> QtList){
        Set<Id> qtIds = new Set<Id>();
        List<Quote> qtListToUpdate = new List<Quote>();
        if(!QtList.isEmpty()){
            for(Quote qtt : QtList){
               qtIds.add(qtt.Id); 
               system.debug('tigeuih'+qtt.Product__r.Lender_Account__c);
            }
            List<Quote> newQtList = [SELECT Id,Lender_Account__c,Product__c,Product__r.Lender_Account__c FROM Quote WHERE Id IN: qtIds];
            for(Quote qt : newQtList){
                if(qt.Product__c != null){
                    if(qt.Product__r.Lender_Account__c != null){
                       qt.Lender_Account__c = qt.Product__r.Lender_Account__c;
                       qtListToUpdate.add(qt);
                    } 
                }
            }  
        } 
        if(!qtListToUpdate.isEmpty()){
            update qtListToUpdate;
        }
    }
}