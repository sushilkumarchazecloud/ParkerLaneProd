({
    showSpinner: function(component, event, helper) {
        component.set("v.showSpinner", true);
        setTimeout(function() {
            component.set("v.showSpinner", false);
        }, 1500);  
    },
    
})