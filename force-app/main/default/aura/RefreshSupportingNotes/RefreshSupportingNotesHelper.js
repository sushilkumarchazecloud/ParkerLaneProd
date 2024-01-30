({
	doInit : function(component, event) {
        var action = component.get("c.refreshNotes"); 
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) { 
            var state = response.getState(); 
            if (state === "SUCCESS") { 
                $A.get('e.force:refreshView').fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been refreshed successfully."
                });
                toastEvent.fire();
            } 
        });
        $A.enqueueAction(action);
    },
})