({
    Cancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    Yes : function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide'); 
        
        var recId = component.get("v.recordId");
        var action = component.get("c.DeEscalateFunding");
        action.setParams({recordId : recId});
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var msg = 'Success !!';
                helper.showMessage(component, "Success",msg , "success");
            }
            else if (state === "ERROR") {
                console.log('Error');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } 
            } 
            $A.util.addClass(spinner, 'slds-hide'); 
            $A.get("e.force:closeQuickAction").fire();
            $A.get("e.force:refreshView").fire();
        });       
        $A.enqueueAction(action);
    }
})