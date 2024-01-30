trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update) {
    OpportunityTriggerHandler handler = New OpportunityTriggerHandler();    
    if(!OpportunityTriggerHandler.isByPassTrigger){
        if(Trigger.isBefore){
            if(Trigger.isUpdate){
                if(!OpportunityTriggerHandler.isByPassApprovedValidation){
                    handler.UseApprovedBtnValidation(Trigger.new,Trigger.oldMap);
                }
                if(!OpportunityTriggerHandler.isByPassValidation){
                handler.OnBeforeUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap );
                }
            }
            if(Trigger.isInsert){
                handler.OnBeforeInsert(Trigger.new, Trigger.newMap);               
            }
        }
        
        if(Trigger.isAfter){
            //OpportunityTriggerHandler.isSummarySet = false;
            if(Trigger.isUpdate){
                handler.OnAfterUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap );
                handler.OnAfterUpdate2(Trigger.new, Trigger.oldMap);
                handler.sendCustomerEmail(Trigger.new, Trigger.oldMap);
                handler.createAdviserTask(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
             	handler.PreliminaryAssessmentPDFData(Trigger.new, Trigger.oldMap);
            }
            if(Trigger.isInsert){
                handler.OnAfterInsert(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap ); 
                handler.roundRobinFunctionality(Trigger.new); 
            }
        }
        
        
        If(Trigger.isBefore){
            if(Trigger.isUpdate){
                handler.updateOppFields(Trigger.new, Trigger.oldMap);
            }
        }
    }
}