/**
 * @description: This is a trigger class for Account object.
 * @author     : Sethu Singh Rawat
 * @created on : 25-02-2024
 */
trigger OpportunityTrigger on Opportunity (before insert,after insert, before update, after update, before delete, after undelete) {
    TriggerDispatcher.run(new OpportunityTriggerHandler(),'OpportunityTrigger');
}