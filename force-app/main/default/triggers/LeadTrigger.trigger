/**
 * @description: This is a trigger class for Lead object.
 * @author     : Sethu Singh Rawat
 * @created on : 26-02-2024
 */
trigger LeadTrigger on Lead (before insert,after insert, before update, after update, before delete, after undelete) {
	TriggerDispatcher.run(new LeadTriggerHandler(),'LeadTrigger');
}