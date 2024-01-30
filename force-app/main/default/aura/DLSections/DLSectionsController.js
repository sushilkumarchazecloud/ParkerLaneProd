({
    handleFilesChange: function (cmp, event, helper) {
        // Get the list of uploaded files
        var file = event.getSource().get("v.files");
        console.log('0-0-0',file);
        cmp.set("v.isClickToUpload",true);
        helper.uploadDocument(cmp, event,file[0],helper);
        
    },
    
    getVOIDATA : function(component, event){
        var action = component.get("c.getVOI");
        action.setParams({ 
            conId : component.get("v.CON")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.VOIID', action.getReturnValue());
                // alert("From server: " + action.getReturnValue());
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
        });
        
        $A.enqueueAction(action);
    }
    
})