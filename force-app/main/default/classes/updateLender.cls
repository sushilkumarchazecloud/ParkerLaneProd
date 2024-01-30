public class updateLender{
    
    @future
    public static void processRecords(List<ID> recordIds){
        List<Opportunity> tempList = new List<Opportunity>();
        List<Opportunity> oppList = [select Lender__c,(select Lender__c,Application__c from Quotes where Application__c = true LIMIT 1) from opportunity where Id IN: recordIds];
        for(Opportunity opp : oppList){
            if(opp.Quotes.size() > 0){
                
                    Quote q = opp.Quotes[0];
                    if(q.Lender__c != null && q.Application__c == true){
                        opp.Lender__c = q.Lender__c;
                        tempList.add(opp);
                    }
                
            }    
        }
        System.debug('===> '+tempList.size());
        update tempList;
    }
}