trigger FundingRequestTrigger on Funding_Request__c (before insert, before update,after insert, after update, after Delete) {
    FundingRequestTriggerhandler handler = New FundingRequestTriggerhandler();
    if(Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isUpdate){
            handler.AfterInsertOrUpdate(Trigger.new, Trigger.OldMap);
            handler.UpdateFundingAfterVariation(Trigger.new, Trigger.OldMap);
        }  
        if(Trigger.isDelete){
            handler.variationDelete(Trigger.old);
        } 
    }
    if(Trigger.isBefore){
        if(Trigger.isInsert || Trigger.isUpdate){
            handler.LastRequestStatusUpdate(Trigger.new,Trigger.oldMap);
            handler.UpdatefundedToDate(Trigger.new);
            handler.HoldStatus(Trigger.new,Trigger.oldMap);
        }
        if(Trigger.isUpdate){
            handler.updateRequestStatus(Trigger.new,Trigger.oldMap);
        }
    }
}