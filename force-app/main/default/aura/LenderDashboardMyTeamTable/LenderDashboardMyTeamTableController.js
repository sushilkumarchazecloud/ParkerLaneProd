({
    
    doInit: function(component, event, helper){
       var status = component.get("v.ConWrapper.ReferrerContact.Status__c");
        if(status=='Active'){
            component.set("v.StatusIcon",'Green');
        }
        if(status=='Retired'){
            component.set("v.StatusIcon",'Red');
        }
        if(status=='Hold'){
            component.set("v.StatusIcon",'Orange');
        }
        helper.assignShow(component, event, helper);
    },
    showModal : function(component, event, helper) {
        
        component.set("v.referrerContact","");
        console.log(JSON.stringify(component.get("v.referrerContact")));
        var oldCon = component.get("v.ConWrapper.ReferrerContact");
        component.set("v.referrerContact",oldCon);
        console.log(JSON.stringify(component.get("v.referrerContact")));
        component.set("v.modalShow",true);
    },
    
    closeModal : function(component, event, helper) {
        component.set("v.modalShow",false);
        component.set("v.ishide",true);
        component.set("v.isSaveBtnDisabled",true);
        component.set("v.showError",false);
      //  var newcon = component.get("v.referrerContact");
      //  component.set("v.ConWrapper.ReferrerContact",newcon); 
    },
    
    editModal : function(component, event, helper) {
        component.set("v.ishide",false);
        component.set("v.isSaveBtnDisabled",false);
    },
    
    saveModal : function(component, event, helper) {
        var conDetails = component.get("v.referrerContact");
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing && inputCmp.checkValidity();
        }, true); 
        component.set("v.showError",!(allValid));
        if(allValid){
        var action = component.get("c.SaveContactOnMyTeamCard");
        action.setParams({con  : conDetails});
        action.setCallback(this, function(response) {
            var state = response.getState();          
            if (state === "SUCCESS") { 
                //alert('Successfully Saved');
                var ret = response.getReturnValue();
                component.set("v.ConWrapper.ReferrerContact",conDetails);
                component.set("v.referrerContact",ret); 
                if(component.get("v.referrerContact.Admin__c")===true){
                    component.set("v.ConWrapper.AdministratorCheck",'Yes');
                    component.set("v.ConWrapper.Role",'Administrator');
                }
                else{
                    component.set("v.ConWrapper.AdministratorCheck",'No');
                    component.set("v.ConWrapper.Role",'Agent');
                }
                 //Code for Status Color Updation according Status Field Value.
                var status = component.get("v.ConWrapper.ReferrerContact.Status__c"); 
                if(status=='Active'){
                    component.set("v.StatusIcon",'Green');
                }
                if(status=='Retired'){
                    component.set("v.StatusIcon",'Red');
                }
                if(status=='Hold'){
                    component.set("v.StatusIcon",'Orange');
                } 
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } 
            } 
        });
        $A.enqueueAction(action);
        component.set("v.isSaveBtnDisabled",true);
        component.set("v.ishide",true);
        }
        else{
            component.set("v.errorMsg","Please update the form entries highlighted in red and try again");
        }
    },
    
    handleChange : function(component, event, helper){
     var val= event.getParam("value");
     if(val=='true'){
        component.set("v.referrerContact.Admin__c",true);
     }
     else{
        component.set("v.referrerContact.Admin__c",false);
     }
    
    },
    
    assignModalYesClick : function(component, event, helper) {
        component.set("v.assignSpinner",true);
        var selectedAgentId = component.get("v.assignCmbValue");
        var agentId = component.get("v.ConWrapper.ReferrerContact.Id");
        var action = component.get("c.ReassignAgent");
        
        action.setParams({
            SelectedCon : selectedAgentId,
            AgentCon : agentId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                component.set("v.showPopup",false);
                component.set("v.assignCmbValue",''); 
            }
            component.set("v.assignSpinner",false);
        });
        $A.enqueueAction(action);
    },
    
    closeassignBtnModal : function(component, event, helper) {
        component.set("v.showPopup",false);
    },
    
    showContacts : function(component, event, helper){
        component.set("v.showPopup",true);
        component.set("v.modalShow",false);
    },
    
    closePopup : function(component, event, helper){
        component.set("v.showPopup",false);
    }

})