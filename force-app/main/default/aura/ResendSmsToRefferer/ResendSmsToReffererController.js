({
    myAction : function(component, event, helper) {
        var action = component.get("c.fetchAccount");        
        var RecorId = component.get("v.recordId");
        action.setParams({
            AccID : RecorId
            
        });
        
        
        action.setCallback(this, function(response){            
            var data = [];
            data = response.getReturnValue();
            component.set("v.getName",data[0]);
            component.set("v.getPhone",data[1]);
        });
        $A.enqueueAction(action);    
	},
    
    SendSMS : function(component, event, helper) {
        var action = component.get("c.sendSmsFromReferrer");        
        action.setParams({
            AccID : component.get("v.recordId"),
            Name : component.get("v.getName"),
            phone : component.get("v.getPhone")
        }); 
        
        action.setCallback(this, function(response){     
            var toastEvent = $A.get("e.force:showToast");
            if(response.getReturnValue() == 'Success'){
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "SMS Sent Successfully" ,
                    "type" : "success"
                }); 
            }
            else{
                toastEvent.setParams({
                    "title": "Error!",
                    "message": response.getReturnValue() ,
                    "type" : "error",
                    duration : 15000
                }); 
            }
            toastEvent.fire();
            $A.get("e.force:refreshView").fire();
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();                
            
        });        
        $A.enqueueAction(action);
    }
})