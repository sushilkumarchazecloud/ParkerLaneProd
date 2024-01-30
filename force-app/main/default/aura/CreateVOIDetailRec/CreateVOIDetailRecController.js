({
    myAction : function(component, event, helper) {
        if(confirm("are you sure!")){
            var action = component.get("c.GenerateVOI");
            action.setParams({ 
                recId : component.get("v.recordId")               
             });
            action.setCallback(this, function(response) {
                var toastEvent = $A.get("e.force:showToast");
                var state = response.getState();
                if (state === "SUCCESS") {
                 //  alert("From server: " + action.getReturnValue());
                    if(action.getReturnValue() == 'Error'){
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Record already Exist!" ,
                            "type" : "Error"
                        });
                    }
                    else{
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Record record Created Successfully!" ,
                            "type" : "Success"
                        });
                    }
                    toastEvent.fire();
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
                $A.get("e.force:refreshView").fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            });
           
            $A.enqueueAction(action);
        }
        else{
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        }
	}
})