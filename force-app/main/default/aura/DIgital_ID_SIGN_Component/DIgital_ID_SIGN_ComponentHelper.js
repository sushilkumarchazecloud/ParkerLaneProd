({
	helperMethod : function(component) {
		var returndata;
        var action = component.get("c.FetchContact");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               returndata = action.getReturnValue();
                //alert(action.getReturnValue());
               component.set('v.Con', action.getReturnValue());
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
	},
    
    FetchDlBack : function(component){
        var returndata = [];
        //alert(component.get("v.recordId"));
        var action = component.get("c.sendImageDataToComponent");
        action.setParams({ 
            RecId : component.get("v.recordId"),
            title : 'BackDL'
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.ImageDataSec', action.getReturnValue());
                //alert("From server: " + action.getReturnValue());
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
    },  
    
    againGetData : function(component, face){
        var action = component.get("c.sendImageDataToComponent");
        action.setParams({ 
            RecId : component.get("v.recordId"),
            title : face
        
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(face == 'DlFront'){
                    component.set('v.ImageData', '');
                    component.set('v.ImageData', action.getReturnValue());
                }
                else{
                    component.set('v.ImageDataSec', ''); 
                    component.set('v.ImageDataSec', action.getReturnValue()); 
                }
                $A.get('e.force:refreshView').fire();
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