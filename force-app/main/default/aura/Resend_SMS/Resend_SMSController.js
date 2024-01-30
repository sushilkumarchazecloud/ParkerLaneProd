({
    myAction : function(component, event, helper) {
       	var action = component.get("c.fetchContacts");        
        var RecorId = component.get("v.recordId");
        action.setParams({
            iddata : RecorId
            
        });
        
        
        action.setCallback(this, function(response){            
            component.set("v.getName",response.getReturnValue());              
        });
        $A.enqueueAction(action);    
        
    },
    
    getPhoneNumber : function(component, event, helper){
        var name = component.find("contactName").get("v.value");
        var action = component.get("c.fetchPhone");        
        var RecorId = component.get("v.recordId");
        
        if(name != ''){
             component.set("v.isButtonActive", false);
        }
        else{
            component.set("v.isButtonActive", true);
        }
        action.setParams({
            iddata : RecorId,
            Name : name
        });
        
        action.setCallback(this, function(response){     
            component.set("v.getPhone",response.getReturnValue());              
        });
        $A.enqueueAction(action);
    },
    
    SendSMS : function(component, event, helper){
        
        var name = component.find("contactName").get("v.value");
        var phone = component.get("v.getPhone");
        var action = component.get("c.resendSMS");        
        var RecorId = component.get("v.recordId");
        var type = component.get("v.opp.VOI_type__c");
        //alert(type);
        
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
            voiType : type
        });
        
        action.setCallback(this, function(response){     
            var toastEvent = $A.get("e.force:showToast");
            if(response.getReturnValue() == 'Success'){
                component.set("v.spinnerShow", false);
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "SMS Sent Successfully" ,
                    "type" : "success"
                }); 
            }
            else{
                component.set("v.spinnerShow", false);
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