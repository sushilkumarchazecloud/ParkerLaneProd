trigger GoalsTrigger on Goals__c (before insert,after insert, before update, after update, before delete, after undelete) {
	TriggerDispatcher.run(new GoalsTriggerHandler(),'GoalsTrigger');
}