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
        var t = component.get("v.VOI");
        var chkbx = component.find("checkbx").get("v.value");
        
        let isPDF;
        
        if(confirm("Do you want to generate PDF Also?")){
            component.set("v.wantPDF", true);
        }
        else{
            component.set("v.wantPDF", false);
        }
        
        action.setParams({
            voiDt : component.get("v.VOI"),
            wantPDF : component.get("v.wantPDF")
        });
        
       
        action.setCallback(this, function(response) {
            var toastEvent = $A.get("e.force:showToast");
            var isPDF = component.get("v.wantPDF");
            var mesg; 
            if(isPDF == true){
                mesg = 'Record Updated and PDF generated.';
            }
            else{
               mesg = 'Record Updated'; 
            }
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.VOI', action.getReturnValue());
                toastEvent.setParams({
                    "title": "Success!",
                    "message": mesg  ,
                    "type" : "success"
                }); 
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
    },
    
    
})