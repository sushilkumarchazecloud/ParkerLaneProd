({
	doInit: function(component, event, helper) {
       
    },
    save : function(component, event, helper) {
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        
		component.set("v.showError",!allValid);
        
        if (allValid) {
            helper.toggleSpinner(component, event);
            helper.createHLHCOpportunity(component, event);
        }else{
            component.set("v.errorMsg", "Please update the form entries highlighted in red and try again");
        }
        
    },
    
    cancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }

})