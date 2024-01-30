trigger UpdateApplication on Quote (after delete) {
    QuoteTriggerHandler handler = new QuoteTriggerHandler();
    if(Trigger.isAfter){
        if(Trigger.isDelete){
            handler.onAfterDelete(Trigger.old,Trigger.oldMap);
        }
    }
}