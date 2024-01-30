global class leadOnUserBatch implements Database.Batchable<sObject>, Database.Stateful {

    global Set<id> userIds;

    global leadOnUserBatch( Set<Id> setIds) {
       userIds = setIds;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT id, Broker_Marketing_Quote__c FROM Lead WHERE OwnerID IN: userIds';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Lead> scope){
        List<Lead> listSobject = new List<Lead>();
        for(Lead l: scope){
            l.Broker_Marketing_Quote__c = 'update';
            listSobject.add(l);
        }
        update listSobject;
    }   

    global void finish(Database.BatchableContext BC) {
    }
 
}