trigger VOI_status on VOI_Status__c (After update,After Insert) {
    VOI_status_Trigger_helper obj = new VOI_status_Trigger_helper();
    if(trigger.isAfter){
        if(trigger.isUpdate){
            obj.updateStatus(trigger.new, trigger.oldMap);
            obj.UpdateOpp(trigger.new,trigger.oldMap);
            obj.createAdviserTask(trigger.new,trigger.oldMap);
        }
        if(trigger.isInsert){
            obj.UpdateOppAfterInsert(trigger.new);
        }
    }
}