({
    doInit : function(component, event, helper) {        
        var action = component.get("c.getProductType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                console.log(JSON.stringify(response.getReturnValue()));
                component.set("v.contentMap", response.getReturnValue());
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    }
})