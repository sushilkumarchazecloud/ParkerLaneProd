({
	helperMethod : function(component) {
		var action = component.get("c.getVoiStatus");   
        var name = component.find("contactName").get("v.value");
        var RecorId = component.get("v.recordId");
        
        action.setParams({
            OppId : RecorId,
            contactName : name
        });
        
        action.setCallback(this, function(response){     
               component.set("v.vois", response.getReturnValue());
        });        
        $A.enqueueAction(action);      
        
	},
    
    helpersec : function(component){
        var name = component.find("contactName").get("v.value");
        var phone = component.get("v.getPhone");
        var action = component.get("c.resendSMS");        
        var RecorId = component.get("v.recordId");
        var type = component.get("v.opp.VOI_type__c");
        var via = component.find("voiVIa").get("v.value");        
        if(type == ''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": 'Please Select Type',
                "type" : "error",
            }); 
            toastEvent.fire();
            return false;
        }
        else{
            component.set("v.spinnerShow", true);
        }
        
        action.setParams({
            phoneNo : phone,
            OppId : RecorId,
            contactName : name,
            voiType : type,
            viaMethod : via
            
        });
        
        action.setCallback(this, function(response){     
            var toastEvent = $A.get("e.force:showToast");
            var ret = response.getReturnValue();
            if(ret != null){
                if(ret.includes('Success')){
                    component.set("v.spinnerShow", false);
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": response.getReturnValue() ,
                        "type" : "success"
                    }); 
                }
                else{
                    component.set("v.spinnerShow", false);
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": response.getReturnValue() ,
                        "type" : "error",
                    }); 
                }
            }
            toastEvent.fire();
            $A.get("e.force:refreshView").fire();
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();                
            
        });   
        $A.enqueueAction(action);
    }
})