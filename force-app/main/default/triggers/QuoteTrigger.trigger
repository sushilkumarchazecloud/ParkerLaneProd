/**
 * @description: This is a trigger class for Quote object.
 * @author     : Sethu Singh Rawat
 * @created on : 26-02-2024
 */
trigger QuoteTrigger on Quote (before insert,after insert, before update, after update, before delete, after undelete) {
	TriggerDispatcher.run(new QuoteTriggerHandler(),'QuoteTrigger');
}