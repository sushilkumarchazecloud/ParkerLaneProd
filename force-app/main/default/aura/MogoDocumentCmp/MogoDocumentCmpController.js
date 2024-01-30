({
	doInit : function(component, event, helper) {
        component.set('v.showSpinner',true);
        var action = component.get('c.makeMOGORequest');
        
        console.log(component.get("v.recordId"));
        action.setParams({
            'opId': component.get("v.recordId")
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            console.log(state);
            if(component.isValid() && state === "SUCCESS"){
            	console.log(result.getReturnValue());
                component.set("v.mogoURL",result.getReturnValue()); 
            }
            component.set('v.showSpinner',false);
        });
        $A.enqueueAction(action);
	},
    
    fullyLoaded : function(component, event, helper) {
        var sp = component.get('v.showIfSpinner');
        component.set("v.showIfSpinner",!sp);
    },
        
    saveSection : function(component, event, helper){
        var ret = component.get('v.redirectURL');
        var action = component.get("c.updateSection");
        var self = this;
        var oppId = component.get('v.recordId');
        console.log(oppId);
     	action.setParams({
            oppId : oppId
        });
        $A.enqueueAction(action);
    }
})