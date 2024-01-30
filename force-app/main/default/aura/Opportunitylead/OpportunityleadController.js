({
	doInit: function(component, event, helper) {
        var recordIds = component.get("v.recordId");
        var obj = component.get("v.sobjecttype");
        helper.callDoInit(component, recordIds, obj);
    },
})