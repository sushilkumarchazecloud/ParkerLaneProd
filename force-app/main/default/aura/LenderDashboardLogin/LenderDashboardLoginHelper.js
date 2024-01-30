({
	toggleSpinner: function (component, event) {        
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
        
    UpdateLogs : function (component, event, helper, splitId) { 
        var logMethod = 'General';
        var action = component.get("c.UpdateConLoginLogs");
        action.setParams({ 
            contactId : splitId,
            loginMethod : logMethod
        }); 
        
        action.setCallback(this,function(response) 
                           {
                               var state = response.getState(); 
                               if (state === "SUCCESS") { 
                                   console.log('LogInLogCreated');   
                               }
                               else{
                                   console.log('Error To create login Log');
                               }
                           });
        $A.enqueueAction(action);
    },
})