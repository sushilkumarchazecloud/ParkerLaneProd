({
    getOpp : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getOpp");
        action.setParams({ 
            oppId : recordId
        }); 
        
        action.setCallback(this,function(response) 
                           {
                               var  ret = response.getReturnValue();
                               if(ret.Approved_Date__c == null){
                                   var currentDate = new Date();
                                   component.set("v.DatetimeValue", currentDate.toISOString());    
                               }
                               else if(ret.Approved_Date__c != null){
                                   component.set("v.DatetimeValue",ret.Approved_Date__c); 
                               }
                           });
        $A.enqueueAction(action);
    },
    
    UpdateOpp :function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var dt = component.get("v.DatetimeValue")   
        var action = component.get("c.UpdateOppToApprovedStage");
        action.setParams({ 
            oppId : recordId,
            ApprovedDate : dt
        }); 
        
        action.setCallback(this,function(response) 
                           {
                               var state = response.getState();
                               var  ret = response.getReturnValue();
                               if (state === "SUCCESS"){
                                   if(!ret.includes('Stage Changed Successfully.')){
                                    helper.showMessage(component, "Error", ret, "error");    
                                   }
                                   else{
                                  //  helper.showMessage(component, "Success", ret, "success");
                                    $A.get("e.force:refreshView").fire();
                                   }
                                   component.set("v.openModal",false);
                                   $A.get("e.force:closeQuickAction").fire();
                               }
                           });
        $A.enqueueAction(action); 
    },
    
    showMessage: function(component, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type
        });
        toastEvent.fire();
    }
})