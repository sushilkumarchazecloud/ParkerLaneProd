trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {
	TriggerContentDocumentLink handler = new TriggerContentDocumentLink();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            handler.OnBeforeInsert(Trigger.new);
        }
    }
}