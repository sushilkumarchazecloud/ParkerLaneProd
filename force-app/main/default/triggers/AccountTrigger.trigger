/**
 * @description: This is a trigger class for Account object.
 * @author     : Sethu Singh Rawat
 * @created on : 22-02-2024
 */
trigger AccountTrigger on Account (before insert,after insert, before update, after update, before delete, after undelete) {
	system.debug('Trigger is running on Account');
    TriggerDispatcher.run(new AccountTriggerHandler(),'AccountTrigger');
}