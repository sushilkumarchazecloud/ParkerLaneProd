({
	showSpinnerForThreeSeconds: function(component, event, helper) {
        component.set("v.spinner", true);
        setTimeout(function() {
            component.set("v.spinner", false);
        }, 1200); 
    },
})