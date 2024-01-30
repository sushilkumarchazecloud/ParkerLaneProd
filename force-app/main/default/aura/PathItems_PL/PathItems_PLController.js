({
	SelectPath : function(component, event, helper) {
        var selectEvent = component.getEvent("PathChangeEvent");
        selectEvent.setParams({"selectedPath" : component.get("v.value")});
        selectEvent.fire();
    }, 
})