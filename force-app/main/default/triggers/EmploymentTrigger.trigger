/**
 * @description: This is a trigger class for Employment object.
 * @author     : Sethu Singh Rawat
 * @created on : 26-02-2024
 */
trigger EmploymentTrigger on Employment__c (before insert,after insert, before update, after update, before delete, after undelete) {
	TriggerDispatcher.run(new EmploymentTriggerHandler(),'EmploymentTrigger');
}