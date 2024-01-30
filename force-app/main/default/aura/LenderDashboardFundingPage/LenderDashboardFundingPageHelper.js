({
	showSpinnerForThreeSeconds: function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        setTimeout(function() {
            $A.util.addClass(spinner, 'slds-hide');
        }, 500); 
    },
    
    getPreviousFundingRequests : function(component, event, helper) {
        var spinner = component.find("mySpinner2");
        $A.util.removeClass(spinner, 'slds-hide');
        component.set("v.spinner2",true);
        
        var oppId = component.get("v.opp.Id");
        var action = component.get("c.getPreviousFundingData");
        action.setParams({
            oppId : oppId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var ret = response.getReturnValue();
                if(ret != null){
                    component.set("v.PreviousData",ret)
                }
            }
            component.set("v.spinner2",false);
            $A.util.addClass(spinner, 'slds-hide');
        });
        $A.enqueueAction(action);
    },
    
})