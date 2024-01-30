({
	getProducts : function(component, event, purpose) {
		var action = component.get("c.getFeaturedProducts");
        var self = this;
        action.setParams({
            isFeatured: false,
            purpose: purpose
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                component.set('v.loanTitle',purpose);
                component.set('v.Products',ret);
                self.scrollTop(component, event, 540);
                
            }
            self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
	},
    
    scrollTop: function (component, event, top){
        var scrollOptions = {
            left: 0,
            top: top,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    },
    
    toggleSpinner: function (component, event) {

        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    }
})