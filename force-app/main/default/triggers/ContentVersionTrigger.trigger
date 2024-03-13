/**
 * @description: This is a trigger class for ContentVersion object.
 * @author     : Sethu Singh Rawat
 * @created on : 26-02-2024
 */
trigger ContentVersionTrigger on ContentVersion (before insert,after insert, before update, after update, before delete, after undelete) {
	TriggerDispatcher.run(new ContentVersionTriggerHandler(),'ContentVersionTrigger');
}