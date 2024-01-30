({
    helperMethod : function(component) {        
        var action = component.get("c.GenrateIdentityCertificate");
        action.setParams({voiDt: component.get("v.VOI")});
        action.setCallback(this, function(response) {
            var toastEvent = $A.get("e.force:showToast");
            var state = response.getState();
            if (state === "SUCCESS") {
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Record Updated and PDF generated."  ,
                    "type" : "success"
                });
                //component.set('v.VOI', action.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert("Error message: " + 
                                  errors[0].message);
                        }
                    } else {
                        alert("Unknown error");
                    }
                }
            toastEvent.fire();
        });
        $A.get("e.force:refreshView").fire();
        $A.enqueueAction(action);
    }
})