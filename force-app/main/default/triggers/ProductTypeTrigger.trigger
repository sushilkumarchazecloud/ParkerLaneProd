/**
 * @description: This is a trigger class for Lead object.
 * @author     : Rishabh Verma
 * @created on : 27-02-2024
 */
trigger ProductTypeTrigger on Product_Type__c (before insert,after insert, before update, after update, before delete,after delete, after undelete) {
	TriggerDispatcher.run(new ProductTypeTriggerHandler(),'ProductTypeTrigger');
}