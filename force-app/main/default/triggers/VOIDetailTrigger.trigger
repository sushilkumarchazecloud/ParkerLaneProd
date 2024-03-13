/**
 * @description: This is a trigger class for VOI_Detail object.
 * @author     : Sethu Singh Rawat
 * @created on : 26-02-2024
 */
trigger VOIDetailTrigger on VOI_Detail__c (before insert,after insert, before update, after update, before delete, after undelete) {
	TriggerDispatcher.run(new VOIDetailTriggerHandler(),'VOIDetailTrigger');
}