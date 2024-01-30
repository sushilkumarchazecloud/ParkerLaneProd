({ 
    getDocuments: function(component, event, helper){
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var action = component.get("c.getDocs");
        action.setParams({
            oppId : component.get("v.opp.Id")
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (state === "SUCCESS"){
                var ret = result.getReturnValue();
                if(ret != null && ret.length > 0){
                    component.set("v.recordsFound",true);
                    component.set("v.cvList",ret);
                }
                else{
                    component.set("v.recordsFound",false);   
                }
                
            }
            $A.util.addClass(spinner, 'slds-hide');
        });
        $A.enqueueAction(action);
    },
})