({
    doInit: function(component, event, helper){
        let recordId = component.get("v.recordId");
        helper.toggleSpinner(component, event);
        helper.getPreferences(component, event, recordId);
        helper.scrollTop(component, event, 315);
    },
    prevSave: function(component, event, helper) {
        var recordId =component.get("v.recordId");
        helper.toggleSpinner(component, event);
        helper.SavePrev(component, event, recordId);

    },
    
    saveNext: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var isValidated = helper.validateDetails(component, event);
        if(isValidated){
            helper.toggleSpinner(component, event);
            helper.upsertPreferences(component, event, true, false);
        }
        helper.scrollTop(component, event, 315);
    },
    
    saveApplication: function(component, event, helper) {
        var args = event.getParam("arguments");
        var isShare = args.isShare;
        var isNext = args.isNext;
        
        var recordId =component.get("v.recordId");
        helper.toggleSpinner(component, event);
        helper.upsertPreferences(component, event, isNext, isShare);
        
    },
    
})