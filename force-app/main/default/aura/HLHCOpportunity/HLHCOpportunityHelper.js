({
	createHLHCOpportunity : function(component, event) {
		var recordOwner = component.get("v.recordOwner");
        var homeLoanRT = component.get("v.homeLoanRT");
        var rating = component.get("v.rating");
        var recordId = component.get("v.recordId");
        console.log('@@@@' + JSON.stringify(recordOwner));
        console.log('@@@@homeLoanRT' + homeLoanRT);
        console.log('@@@@rating  ' + rating);
        console.log('@@@@recordId  ' + recordId);
        
        var action = component.get("c.Save");
        var self = this;
        console.log('@@@@call  ');
     	action.setParams({
            recordId: recordId, 
            recordTypeName: homeLoanRT,
            rating: rating, 
            OwnerId: recordOwner.Id
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            console.log('@@@@state  ' + state);
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
               	$A.get("e.force:closeQuickAction").fire();
                
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/"+ ret
                });
                urlEvent.fire();
            }
            self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
        
        
	},
    
    toggleSpinner: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
    
})