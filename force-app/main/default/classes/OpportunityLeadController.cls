public class OpportunityLeadController {
    @AuraEnabled
    public static String changeUnread(String rId, String rObj){
        String change = '';
        if(rObj == 'opportunity'){
            Opportunity opp = [Select Id, Unread__c from Opportunity where Id=: rId];
            if(opp.Unread__c == true){
                opp.Unread__c = false;
            	change = 'yes';
                update opp;
            }
        }
        else if(rObj == 'lead'){
            Lead led = [Select Id, Unread__c from Lead where Id=: rId];
            if(led.Unread__c == true){
                led.Unread__c = false;
                change = 'yes';
            	update led;
            }
        }
        return change;        
    }
}