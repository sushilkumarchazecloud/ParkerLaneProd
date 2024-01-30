({    
    doInit : function(component, event, helper) {
        var label = $A.get("$Label.c.loginMessage");        
        component.set("v.WelcomeNote",label);
    },  
    
    handleKeyPress : function(component, event, helper) {
        if(event.which == 13 ){
            var a = component.get("c.checkpassword");
            $A.enqueueAction(a);
         }
    },

    handleUpdateKey : function(component, event, helper) {
        if(event.which == 13 ){
            var a = component.get("c.updatePassword");
            $A.enqueueAction(a);
         }
    },
    
    moveNext : function(component, event, helper) {
        var otp = component.find("otp_verified2");
        var check1 = component.find("otp_verified1").get("v.value");
        if(check1 != null){
            if(check1.length > 0){
                otp.focus();        
            }
        }
        if(check1 == null || check1 == ''){
            var goback1 = component.find("otp_verified1");
            goback1.focus();
        }
    },
    moveNext2 : function(component, event, helper) {
        var otp = component.find("otp_verified3");
        var check2 = component.find("otp_verified2").get("v.value");
        if(check2 != null){
            if(check2.length > 0){
                otp.focus();        
            }
        }
        if(check2 == null || check2 == ''){
            var goback2 = component.find("otp_verified1");
            goback2.focus();
        }
    },
    moveNext3 : function(component, event, helper) {
        var otp = component.find("otp_verified4");
        var check3 = component.find("otp_verified3").get("v.value");
        if(check3 != null){
            if(check3.length > 0){
                otp.focus();
            }
        }
        if(check3 == null || check3 == ''){
            var goback3 = component.find("otp_verified2");
            goback3.focus();
        }
    },
    moveNext4 : function(component, event, helper) {
        var check4 = component.find("otp_verified4").get("v.value");
        if(check4 != null){
            if(check4.length < 1){
                var goback4 = component.find("otp_verified3");
                goback4.focus();            
            }
            else{
                var a = component.get("c.checkOtp");
                $A.enqueueAction(a);
            }
        }
        if(check4 == null || check4 == ''){
            var goback4 = component.find("otp_verified3");
            goback4.focus();
        }
    },
    
    checkpassword : function(component, event, helper) {
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing && inputCmp.checkValidity();
        }, true);
        if(allValid){
            var action = component.get("c.login");
            helper.toggleSpinner(component, event);   
            component.set("v.error",'');
            var username = component.get("v.username");
            var sendPassword = component.get("v.password");
            
            action.setParams({
                getPassword : sendPassword,
                username : username
            });
            
            action.setCallback(this,function(response){
                var state = response.getState();
                var returnValue = response.getReturnValue();
                if(returnValue != null){
                    var conId = returnValue.Id;
                    component.set("v.conEmail",returnValue.Email);
                    component.set("v.conId",returnValue.Id);
                    var label = $A.get("$Label.c.baseUrl");
                    window.location.replace(label + 'LenderDashboard?id=' + conId);
                }
                else{
                    component.set("v.error",'The username and password you have entered are not correct.');
                }
                helper.toggleSpinner(component, event);
            });       
            $A.enqueueAction(action);   
        }
    },
    
    updatePassword : function(component, event, helper) {
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing && inputCmp.checkValidity();
        }, true);
        if(allValid){
            var action = component.get("c.updatePasswordEmail");
            helper.toggleSpinner(component, event);   
            var username = component.get("v.newusername");
            action.setParams({
                username : username
            });
            
            action.setCallback(this,function(response){
                var state = response.getState();
                var ret = response.getReturnValue();
                if(ret){
                  component.set("v.emailSuccessMsg",true); 
                }
                helper.toggleSpinner(component, event);
            });       
            $A.enqueueAction(action);   
        }
        else{
            component.set("v.noUser",false);
        }
    },
    
    forgotPassword : function(component, event, helper) {
        component.set("v.path",'UpdatePassword');
    },
    
    cancel : function(component, event, helper) {
        component.set("v.path",'login');
        component.set("v.error",'');
        component.set("v.username",'');
        component.set("v.password",'');
    },
    
    /*checkpassword : function(component, event, helper) {

        var action = component.get("c.SendMessage");
        helper.toggleSpinner(component, event);   
        var sendPassword = component.get("v.password");
        if(sendPassword != null){
            sendPassword = sendPassword.replace(/[^+\d]+/g, "");
        }
        
        action.setParams({
            getPassword : sendPassword
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            component.set("v.conWrp",returnValue);
            var random = component.get("v.conWrp.rndNum");
            alert(random);
            component.set("v.saveOtp",random);
            if(random != null){                
                component.set("v.path", 'enterOtp');
                helper.toggleSpinner(component, event);   
                window.setTimeout(
                    $A.getCallback(function() {
                        if(component.get("v.navSection") != 'referralHome'){
                            location.reload();
                        }
                    }), 300000
                );
            } 
            else{
                component.set("v.path",'notRegistered');
                helper.toggleSpinner(component, event);   
            }
        });       
        $A.enqueueAction(action);        
    },*/
    
    sendMail : function(component, event, helper) {
        var mailId = component.get("v.conWrp.conData.Email"); 
        var recId = component.get("v.conWrp.conData.Id");
        /*if(sendPhone != null){
            sendPhone = sendPhone.replace(/[^+\d]+/g, "");
        }*/
        var action = component.get("c.emailForOtp");
        
        action.setParams({
            mailId : mailId,
            recId : recId
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            component.set("v.saveOtp",returnValue);
        });
        $A.enqueueAction(action);
    },
    
    handleOTP : function(component, event, helper) {
        if(event.which == 13 ){
            var a = component.get("c.checkOtp");
            $A.enqueueAction(a);
        }
    },
    
    checkOtp : function(component, event, helper) {        
       var accId;
        var inp1 = component.get("v.emptyOtp1");
        var inp2 = component.get("v.emptyOtp2");
        var inp3 = component.get("v.emptyOtp3");
        var inp4 = component.get("v.emptyOtp4");
        var label = $A.get("$Label.c.baseUrl"); 
        var sum = inp1 + inp2 + inp3 + inp4;
        component.set("v.otp",sum);
        
        var getOtp = component.get("v.otp");
        var checkOtp = component.get("v.saveOtp");
        
        if(getOtp == checkOtp){
            component.set("v.emptyOtp1",'');
            component.set("v.emptyOtp2",'');
            component.set("v.emptyOtp3",'');
            component.set("v.emptyOtp4",'');
            
            var splitId = JSON.stringify(component.get("v.conWrp.ReferrerContact.Id"));
            splitId = splitId.replace(/^"(.*)"$/, '$1');
            //var isPhone = true;
            
            //var contId = component.get("v.conId");
            var action = component.get("c.otpMatched");
            helper.toggleSpinner(component, event, helper);
            
            action.setParams({
                conId : splitId
            });
            
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state == 'SUCCESS'){                    
                    //helper.UpdateLogs(component, event, helper, splitId);
                    window.location.replace(label+'/LenderDashboard?id='+splitId);
                    //helper.toggleSpinner(component, event);
                }
            });       
            $A.enqueueAction(action);
        }
        else{
            component.set("v.isResendButtonActive",false);
            component.set("v.emptyOtp1",'');
            component.set("v.emptyOtp2",'');
            component.set("v.emptyOtp3",'');
            component.set("v.emptyOtp4",'');
            var goback1 = component.find("otp_verified1");
            goback1.focus();
        }        
    },
})