trigger ContentVersionTrigger on ContentVersion (after Update, after insert) {
    ContentVersiontriggerHandler handler = new ContentVersiontriggerHandler();
    if(Trigger.isAfter){
        if(Trigger.isupdate){
            if(ContentVersiontriggerHandler.Stop == false){ 
                ContentVersiontriggerHandler.Stop = true;
                handler.afterUpdate(Trigger.new); 
                ContentVersiontriggerHandler.Stop = false;
            } 
        }
        if(Trigger.isinsert){
            handler.afterInsert(Trigger.new);
        }
    }
}