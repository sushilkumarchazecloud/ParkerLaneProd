/**
 * @description: This is a trigger class for Loan Fees object.
 * @author     : Sethu Singh Rawat
 * @created on : 22-02-2024
 */
trigger LoanFeesTrigger on Loan_Fees__c (before insert,after insert, before update, after update, before delete, after undelete) {
	TriggerDispatcher.run(new LoanFeesTriggerHandler(),'LoanFeesTrigger');
}