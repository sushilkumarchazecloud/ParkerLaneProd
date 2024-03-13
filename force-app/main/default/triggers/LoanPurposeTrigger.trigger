/**
 * @description: This is a trigger class for Loan Purpose object.
 * @author     : Sethu Singh Rawat
 * @created on : 22-02-2024
 */
trigger LoanPurposeTrigger on Loan_Purpose__c (before insert,after insert, before update, after update, before delete, after undelete) {
	TriggerDispatcher.run(new LoanPurposeTriggerHandler(),'LoanPurposeTrigger');
}