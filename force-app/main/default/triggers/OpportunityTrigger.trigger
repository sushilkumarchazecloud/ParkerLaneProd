trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update) {
    OpportunityTriggerHandler handler = New OpportunityTriggerHandler();    
    
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            handler.OnBeforeUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap );
        }
        if(Trigger.isInsert){
            handler.OnBeforeInsert(Trigger.new, Trigger.newMap);
        }
    }
    
    if(Trigger.isAfter){
        //OpportunityTriggerHandler.isSummarySet = false;
        if(Trigger.isUpdate){
            handler.OnAfterUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap );
        }
        if(Trigger.isInsert){
            handler.OnAfterInsert(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap );
        }
    }
    
    
    If(Trigger.isBefore){
        if(Trigger.isUpdate){
            handler.updateOppFields(Trigger.new, Trigger.oldMap);
        }
    }
}