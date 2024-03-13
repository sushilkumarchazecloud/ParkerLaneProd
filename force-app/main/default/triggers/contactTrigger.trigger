/**
 * @description: This is a trigger class for Contact object.
 * @author     : Sethu Singh Rawat
 * @created on : 26-02-2024
 */
trigger ContactTrigger on Contact (before insert,after insert, before update, after update, before delete, after undelete) {
    TriggerDispatcher.run(new ContactTriggerHandler(),'ContactTrigger');
}