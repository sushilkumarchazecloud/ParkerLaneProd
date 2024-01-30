({
	doInit : function(component, event, helper) {
        helper.getOpp(component, event, helper);
    }, 
    
    hanleOk :function(component, event, helper) {   
        var field_val = component.get("v.DatetimeValue")
        if(field_val != null){
         helper.UpdateOpp(component, event, helper);   
        }
        else{
            component.set("v.FieldNullErorr",true);
        }
    },
    
     Cancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})