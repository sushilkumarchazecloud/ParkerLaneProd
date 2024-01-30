({
    doInIt : function(component, event, helper) {
        helper.getContactData(component, event);
    },
    
    sendEmail : function(component, event, helper) {
        component.set("v.successPassMsg",false);
        var recId = component.get("v.con.Id");
        var action = component.get("c.emailForOtp");
        
        action.setParams({
            recId : recId
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            //alert(returnValue);
            component.set("v.enterPassword", true);
            component.set("v.saveOtp",returnValue);
        });
        $A.enqueueAction(action);
    },
    
    checkOtp : function(component, event, helper) {
        var otp = component.get("v.Otp");
        var matchotp = component.get("v.saveOtp");
        if(otp == matchotp){
            component.set("v.rightOtp", false);
        }
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
        var recId = component.get("v.con.Id");
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
    
    tncChange : function(component, event, helper) {
        var opt1 = component.get("v.opt1");
        var opt2 = component.get("v.opt2");
        var opt3 = component.get("v.opt3");
        if(opt1 && opt2 && opt3){
            component.set("v.isDeclarationBtnDisabled", false);
        }else{
            component.set("v.isDeclarationBtnDisabled", true);
        }
    }, 
    
    submitDeclaration : function(component, event, helper) {
      //  helper.submitDec(component, event);
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