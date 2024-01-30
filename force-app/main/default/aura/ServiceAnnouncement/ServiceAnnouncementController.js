({
	doInit : function(component, event, helper) {
        var serviceName = component.get("v.serviceName");
        if(serviceName != '' || serviceName != null){
            helper.getMessage(component, event, serviceName); 
        }
        
    },
    
    close: function(component, event, helper) {
        component.set("v.isOpenModal", false);
    },
})