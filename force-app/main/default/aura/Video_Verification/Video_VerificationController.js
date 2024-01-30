({
	myAction : function(component, event, helper) {
		var returndata = [];
        var action = component.get("c.FetchVoiDetail");
        var id = component.get("v.recordId");
        action.setParams({recId: id});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.VOI', action.getReturnValue());
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
    
    updateVOI : function(component, event, helper){
        var action = component.get("c.UpdateVOI");
        let isPDF;
       //ar wantPDF = component.get("v.wantPDF");
        
        if(confirm("Do you want to generate PDF Also?")){
            component.set("v.wantPDF", true);
            isPDF = true;
        }
        else{
            component.set("v.wantPDF", false);
            isPDF = false;
        }
        action.setParams({
            voiDt : component.get("v.VOI"),
        });
        
       
        action.setCallback(this, function(response) {
            var toastEvent = $A.get("e.force:showToast");            
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.VOI', action.getReturnValue());
                if(isPDF){                    
                    helper.helperMethod(component);                         
                }
                else{
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Record Updated"  ,
                        "type" : "success"
                    });
                }
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
       
        
        $A.enqueueAction(action);
    },
    
    
})