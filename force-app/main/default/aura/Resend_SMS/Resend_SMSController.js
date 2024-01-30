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
            helper.helperMethod(component);
        });
        $A.enqueueAction(action);
    },
    
    SendSMS : function(component, event, helper){
        var type = component.get("v.vois");
        var yesNo = true;
        if(type == 'Sent' ||  type == 'Delivered'){
            if(confirm("Do you want to send the same link again? To send a new VOI first Reject or Verify the current VOI")){
                helper.helpersec(component);
            } 
            else{
                return;
            }
        }else{
            helper.helpersec(component);
        }
            
    }
    
     
    
})