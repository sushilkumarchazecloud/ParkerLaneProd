({
    doinit : function(component, event, helper) {
        var label = $A.get("$Label.c.loginMessage");        
        component.set("v.WelcomeNote",label);
        var getCon = component.get("c.getContact");  
        var conId = component.get("v.conId");
        
		getCon.setParams({
            contactId : conId
        });
        
        getCon.setCallback(this,function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue(); 
			console.log(returnValue)            
            component.set("v.conList",returnValue);
            var phoneno = [];
            phoneno = component.get("v.conList[0].PhoneForPortal__c");
            var str = '';
            for(var i=0; i<phoneno.length; i++){
                if(i>5){
                    str+= phoneno[i];
                }
            }            
            component.set("v.lastFour",str);
        });
        $A.enqueueAction(getCon);
    },
    
    handleOTP : function(component, event, helper) {
        if(event.which == 13 ){
            var a = component.get("c.checkOtp");
            $A.enqueueAction(a);
        }
    },
    
    sendMail : function(component, event, helper) {
        var mailId = component.get("v.conList[0].Email");  
        var recId = component.get("v.conWrp.conData.Id");
        component.set("v.showspinner",true);
        component.set("v.showmessage",false);
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
            component.set("v.showspinner",false);
            component.set("v.showmessage",true);
            component.set("v.saveOtp",returnValue);
        });
        $A.enqueueAction(action);
    },
    
    submit : function(component, event, helper) {
        helper.toggleSpinner(component, event);
        var phone = component.get("v.conList[0].PhoneForPortal__c");
        var recId = component.get("v.conId");
        var action = component.get("c.SendMessage");
        
        action.setParams({
            getPhone : phone,
            recId : recId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            component.set("v.conWrp",returnValue);
            component.set("v.checkSize",component.get("v.conWrp.listSize"));
            var random = component.get("v.conWrp.rndNum");
            component.set("v.saveOtp",random);
            console.log(random);
            
            if(random != null){                
                component.set("v.path", 'Otp');
                helper.toggleSpinner(component, event);
                window.setTimeout(
                    $A.getCallback(function() {
                        if(component.get("v.path") != 'HomePage'){ 
                            location.reload();
                        }
                    }), 300000
                );
            } 
            else{
                component.set("v.path", 'Otp');
                helper.toggleSpinner(component, event);
            }
        });       
        $A.enqueueAction(action); 
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
    checkOtp : function(component, event, helper) {
        
        var inp1 = component.get("v.emptyOtp1");
        var inp2 = component.get("v.emptyOtp2");
        var inp3 = component.get("v.emptyOtp3");
        var inp4 = component.get("v.emptyOtp4");
        
        var sum = inp1 + inp2 + inp3 + inp4;
        component.set("v.otp",sum);
        
        var getOtp = component.get("v.otp");
        var checkOtp = component.get("v.saveOtp");
        
        if(getOtp == checkOtp){
            component.set("v.emptyOtp1",'');
            component.set("v.emptyOtp2",'');
            component.set("v.emptyOtp3",'');
            component.set("v.emptyOtp4",'');
            var contId = component.get("v.conId");
            helper.toggleSpinner(component, event);
            var action = component.get("c.otpMatched");
            
            action.setParams({
                conId : contId
            });
            
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state == 'SUCCESS'){
                    //helper.toggleSpinner(component, event);
                    helper.UpdateLogs(component, event, helper);
                    window.location.replace('https://lanecorp.my.salesforce-sites.com/ReferrerPortal?id='+contId);                    
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
    resend : function(component, event, helper) {
        helper.toggleSpinner(component, event);
        var action = component.get("c.resendOtp");
        var sendPhone = component.get("v.conList[0].PhoneForPortal__c");
        
        action.setParams({
            getPhone : sendPhone
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            component.set("v.saveOtp",returnValue.rndNum);
            helper.toggleSpinner(component, event);
            if(returnValue.count == 4){
                component.set("v.isResendButtonActive",true);
                component.set("v.emptyOtp1",'');
                component.set("v.emptyOtp2",'');
                component.set("v.emptyOtp3",'');
                component.set("v.emptyOtp4",'');
            }
            else{
                component.set("v.emptyOtp1",'');
                component.set("v.emptyOtp2",'');
                component.set("v.emptyOtp3",'');
                component.set("v.emptyOtp4",'');
            }
        });
        $A.enqueueAction(action);
    },
})