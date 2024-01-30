global with sharing class ScheduleBatchForReferrer implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        //Implement any logic to be scheduled
        batchForReferrar obj = new batchForReferrar();
        Id batchId = Database.executeBatch(obj, 200);
        
    }
    
}