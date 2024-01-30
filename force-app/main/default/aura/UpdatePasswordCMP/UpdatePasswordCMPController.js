({
    doInit : function(component, event, helper) {
        var action = component.get("c.getMyAccount");
        action.setParams({
            conId : component.get("v.conId")
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            if (state === "SUCCESS"){
               component.set("v.saveOtp",returnValue.LoginOtp__c);
            }
        });
        $A.enqueueAction(action); 
    },
    
    handleKeyPress : function(component, event, helper) {
        if(event.which == 13 ){
            var a = component.get("c.checkPassword");
            $A.enqueueAction(a);
         }
    },
    
    checkOtp : function(component, event, helper) {
        var otp = component.get("v.Otp"); 
        var matchotp = component.get("v.saveOtp");
        if(otp === matchotp){
            component.set("v.rightOtp", false);
        }    
        else{
            component.set("v.rightOtp", true);
        }
    },
    
    loginpage : function(component, event, helper) {
        var label = $A.get("$Label.c.baseUrl");
        window.location.replace(label + 'LenderDashboardLogin');
    },
    
    checkPassword : function(component, event, helper) {
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing && inputCmp.checkValidity();
        }, true);
        var password = component.get("v.newPassword");
        var newPassword = component.get("v.checkNewPassword");
        if(password === newPassword && allValid){
            component.set("v.updateButton", false);
        }
        else{            
            component.set("v.updateButton", true);
        }
    },
    
    togglePassword : function(component, event, helper) {
        if(component.get("v.showpassword",true)){
            component.set("v.showpassword",false);
        }else{
            component.set("v.showpassword",true);
        }
    },
    
    toggleNewPassword : function(component, event, helper) {
        if(component.get("v.shownewpassword",true)){
            component.set("v.shownewpassword",false);
        }else{
            component.set("v.shownewpassword",true);
        }
    },

    updatePassword : function(component, event, helper) {
        var newPassword = component.get("v.checkNewPassword");
        var recId = component.get("v.conId");
        var action = component.get("c.passwordUpdate");
        action.setParams({
            recId : recId,
            newPassword : newPassword
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();    
            if (state === "SUCCESS"){
                component.set("v.enterPassword",false);
                component.set("v.successPassMsg",true);
                component.set("v.checkNewPassword",'');
                component.set("v.Otp",'');
                component.set("v.newPassword",''); 
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
    },
    
    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
    
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    }
})