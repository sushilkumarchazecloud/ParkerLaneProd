({    
    doInit : function(component, event, helper) {
        var recordId =component.get("v.recordId");
        helper.getSectionStatus(component, event, recordId);  
    },
})