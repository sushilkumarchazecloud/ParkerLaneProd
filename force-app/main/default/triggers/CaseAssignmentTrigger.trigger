trigger CaseAssignmentTrigger on Case (After insert, Before insert) {
	CaseAssignmentHandler handler = new CaseAssignmentHandler();
    if(trigger.isbefore && trigger.isInsert){
        handler.assignCaseOwnerforWeb(trigger.new);
    }
    if(trigger.isAfter && trigger.isInsert){
        handler.assignCaseOwner(trigger.new);
    }
}