/**
 * @description: This is a trigger class for Document_Requested object.
 * @author     : Sethu Singh Rawat
 * @created on : 26-02-2024
 */
trigger DocumentRequestedTrigger on Document_Requested__c (before insert,after insert, before update, after update, before delete, after undelete) {
	TriggerDispatcher.run(new DocumentRequestedTriggerHandler(),'DocumentRequestedTrigger');
}