trigger FundingRequestTrigger on Funding_Request__c (before insert,after insert, before update, after update, before delete, after undelete) {
	TriggerDispatcher.run(new FundingRequestTriggerHandler(),'FundingRequestTrigger');
}