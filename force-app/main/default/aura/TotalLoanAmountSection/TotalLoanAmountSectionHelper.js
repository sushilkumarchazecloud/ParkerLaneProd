({
	getSelectedQuote : function(component, event) {
        var action = component.get("c.getSelectedQuote");
        var self = this;
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var ret = response.getReturnValue();

                if(!$A.util.isUndefinedOrNull(ret) && ret != null){
                    component.set('v.selectedQuote', ret);
                    component.set("v.totalAmount", ret.Monthly_Repayment__c);
                    if(!$A.util.isUndefinedOrNull(ret.Lead__c)){
                        if(!$A.util.isUndefinedOrNull(ret.Lead__r.FirstName)){
                            component.set("v.applicantFName", ret.Lead__r.FirstName);
                        }
                        component.set("v.applicantLName", ret.Lead__r.LastName);
                        component.set("v.applicantEmail", ret.Lead__r.Email);
                    }
                }
            }

        });
        $A.enqueueAction(action);
    },
    
})