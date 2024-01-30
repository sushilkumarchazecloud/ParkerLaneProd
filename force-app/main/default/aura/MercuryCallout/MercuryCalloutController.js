({
	doInit : function(component, event, helper) {
		var action = component.get("c.makeCallout");
       	action.setParams({"oppId": component.get("v.recordId")});
		action.setCallback(this, function(response) {
			var state = response.getReturnValue();
			var getCurrentElementIndex = state.indexOf("Error");
            var resultsToast = $A.get("e.force:showToast");
			if(state == "Success") {                               
				resultsToast.setParams({
					"title": "Success!",
                    "type": "success",
					"message": "Application Submitted Successfully!!"
				});               	
			}else if(getCurrentElementIndex != -1){
				resultsToast.setParams({
                	"title": "Error",
                    "type": "error",
                    "message": state
                });
           	} else {
				resultsToast.setParams({
					"title": "Unknown Error",
                    "type": "error",
					"message": "An unknown error has occured please contact your Administrator."
				});
			}
			resultsToast.fire();
			$A.get("e.force:refreshView").fire();
			var dismissActionPanel = $A.get("e.force:closeQuickAction");
			dismissActionPanel.fire();
            
		});
		
 		$A.enqueueAction(action);
	}
})