({
    sendEmail : function(component, event, helper) {
        var action = component.get("c.insertPdf");
        action.setParams({ 
            conId : component.get("v.accountId")
        });
        action.setCallback(this, function(response) { 
            var state = response.getState(); 
            if (state === "SUCCESS") {
                alert(state);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } 
            } 
        });
        $A.enqueueAction(action); 
    },
})