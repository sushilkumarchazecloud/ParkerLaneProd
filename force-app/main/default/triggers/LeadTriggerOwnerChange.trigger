trigger LeadTriggerOwnerChange on Lead (before insert, before update) {
  LeadTriggerHandler lth = new LeadTriggerHandler(trigger.new,trigger.old);

  if(trigger.isBefore){
    if(trigger.isInsert){
      lth.on_before_insert_Leads();
      LeadRecordTypeChange.changeRecordType(Trigger.new);
    }
    if(trigger.isUpdate){
      lth.on_before_update_Leads();
    }
  }
}