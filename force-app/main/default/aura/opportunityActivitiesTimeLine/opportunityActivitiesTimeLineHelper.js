({
	getActivities : function(component, event) {
		var action = component.get("c.getActivities");
        var self = this;
        action.setParams({
            oppId: component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.lstActivity" , response.getReturnValue()); 
            }else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE RESPONSE");
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            //self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
	},
    
    toggleSpinner: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
})