({
	doInit : function(component, event, helper) {
        if(confirm('Are you sure you want to send Credit Proposal to customer?')){
            var action = component.get("c.makeCallout");
    
            action.setParams({"oppId": component.get("v.recordId")});
            action.setCallback(this, function(response) {
                var state = response.getReturnValue();
                console.log('===> '+state);
                var resultsToast = $A.get("e.force:showToast");
                if(state === "Success") {                               
                    resultsToast.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Credit Proposal has been sent successfully!!"
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
	}
})