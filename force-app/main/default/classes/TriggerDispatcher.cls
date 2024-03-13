/**
 * @description	: A dispatcher class that delegates trigger events to corresponding handler methods.
 * @author     	: Sethu Singh Rawat
 * @created on 	: 22-02-2024
 */
public class TriggerDispatcher {

    /**
     * @description	: Executes the appropriate trigger handler method based on the context of the trigger event.
     * @author     	: Sethu Singh Rawat
     * @created on 	: 22-02-2024
     * @param      	: ITriggerHandlerInf handler - An instance of a class that implements the ITriggerHandlerInf interface.
     * @return     	: void
     */
    public static void run(ITriggerHandlerInf handler, String triggerName){
        // Check the metadata if the fields are enabled in order to execute the Trigger.
        if(Trigger_Configuration__mdt.getInstance('Run_All_Triggers')?.Value__c && Trigger_Configuration__mdt.getInstance(triggerName)?.Value__c) {
            if(handler.isDisabled()){
                return;
            }
            
            //Delegating the correct Trigger Context
            if(Trigger.isBefore){
                if(Trigger.isDelete){   
                    handler.beforeDelete(trigger.oldMap);
                }else if(Trigger.isInsert){
                    handler.beforeInsert(trigger.new);   
                }else if(Trigger.isUpdate){
                    handler.beforeUpdate(trigger.newMap, trigger.oldMap);
                }
                
            }
            if(Trigger.isAfter){
                if(Trigger.isInsert){        
                    handler.afterInsert(trigger.newMap);
                }else if(Trigger.isUpdate){   
                    handler.afterUpdate(trigger.newMap,trigger.oldMap);
                }else if(Trigger.isDelete){   
                    handler.afterDelete(trigger.oldMap);
                }else if(Trigger.isUndelete){
                    handler.afterUndelete(trigger.newMap);
                }
            }
        } 
    }
}