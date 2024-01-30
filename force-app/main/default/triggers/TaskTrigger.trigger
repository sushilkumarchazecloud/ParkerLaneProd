trigger TaskTrigger on Task (after update) {
    TaskTriggerHandler handler = new TaskTriggerHandler();
    if(Trigger.isAfter && Trigger.isUpdate){
        handler.UpdateFundingHandOverTasks(Trigger.New);
    }
}