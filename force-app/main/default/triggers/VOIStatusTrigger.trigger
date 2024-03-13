/**
 * @description: This is a trigger class for VOI_Status object.
 * @author     : Sethu Singh Rawat
 * @created on : 22-02-2024
 */
trigger VOIStatusTrigger on VOI_Status__c (before insert,after insert, before update, after update, before delete, after undelete) {
	TriggerDispatcher.run(new VOIStatusTriggerHandler(),'VOIStatusTrigger');
}