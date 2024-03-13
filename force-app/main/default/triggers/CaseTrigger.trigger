/**
 * @description: This is a trigger class for Case object.
 * @author     : Sethu Singh Rawat
 * @created on : 26-02-2024
 */
trigger CaseTrigger on Case (before insert,after insert, before update, after update, before delete, after undelete) {
	TriggerDispatcher.run(new CaseTriggerHandler(),'CaseTrigger');
}