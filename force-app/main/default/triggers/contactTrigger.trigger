trigger contactTrigger on Contact (After insert, After update) {
    
    contactTriggerHelper helper =  new contactTriggerHelper();
    if(trigger.isAfter){
        if(trigger.isInsert){
            helper.SendEmailToReferrer(trigger.new); 
        }
        if(Trigger.isUpdate){
            helper.AfterUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
        }
    }
}