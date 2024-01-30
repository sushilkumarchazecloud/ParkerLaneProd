trigger UpdateApplication on Quote (after delete,after update, after insert) {
    QuoteTriggerHandler handler = new QuoteTriggerHandler();
    if(Trigger.isAfter){
        if(Trigger.isDelete){
            handler.onAfterDelete(Trigger.old,Trigger.oldMap);
        }
        if(trigger.isInsert){
            handler.afterInsert(Trigger.new); 
        }
    }
        
}