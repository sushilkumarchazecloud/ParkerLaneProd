({
	getMessage : function(component, event, serviceName) {
        var action = component.get("c.getServiceMessage");
        var self = this;
        action.setParams({
            serviceName: serviceName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                if(!$A.util.isUndefinedOrNull(ret) && ret != null){
                    component.set('v.config', ret);
                    if(ret.isShowMessage__c){
                        if(!$A.util.isUndefinedOrNull(ret.Pages__c) && ret.Pages__c != null){
                            var pageType = component.get("v.pageType");
                            if(pageType != ''){
                                component.set('v.isOpenModal', ret.Pages__c.includes(pageType));
                            }
                        }else{
                            component.set('v.isOpenModal', true);
                        }
                    }
                }
                
            }
        });
        $A.enqueueAction(action);
    },
})