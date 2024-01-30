({
	myAction : function(component, event, helper) {        
		var action = component.get("c.fillActivity");
        action.setParams({ 
            Recid : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var t = response.getReturnValue()
              	t.sort();
                console.log('sorted----'+JSON.stringify(t));
                component.set("v.mailList" , response.getReturnValue());        
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
            
        });
        $A.enqueueAction(action);
        
	}
})