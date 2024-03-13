/**
 * @description: This is a trigger class for Loan_Rate object.
 * @author     : Sethu Singh Rawat
 * @created on : 22-02-2024
 */
trigger LoanRateTrigger on Loan_Rate__c (before insert,after insert, before update, after update, before delete, after undelete) {
	TriggerDispatcher.run(new LoanFeesTriggerHandler(),'LoanRateTrigger');
}