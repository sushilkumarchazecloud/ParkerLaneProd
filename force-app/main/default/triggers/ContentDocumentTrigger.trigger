trigger ContentDocumentTrigger on ContentDocument (before Delete) {
    ContentDocumentTriggerHandler handler = new ContentDocumentTriggerHandler();
     if(Trigger.isBefore){
         if(Trigger.isDelete){
            handler.beforeDelete(Trigger.Old);
         }  
     }

}