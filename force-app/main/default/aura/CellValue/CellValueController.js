({
	setData : function(component, event, helper) {
		var data = component.get("v.recordData");
        var field = component.get("v.fieldAPIName");
        console.log('>>>>' + JSON.stringify(data));
        console.log('>>>>field' + field);
        console.log('>>>>' + data[field]);
        component.set("v.data",data[field]);
        component.set("v.dataLink",data["Id"]);
	},
    viewRecord: function (component, event, helper) {  
        var data = component.get("v.recordData");
        var navEvt = $A.get("e.force:navigateToSObject");  
        var recId = data["Id"]; 
        navEvt.setParams({  
            "recordId": recId  
        });  
        navEvt.fire();  
          
    } 
})