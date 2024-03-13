({
    doInit : function(component, event, helper) {
        helper.scrollTop(component, event);
        var quote = component.get("v.quote");
        component.set("v.gettingCustomerAmount", parseFloat(quote.Customer_Amount__c) + parseFloat(quote.Total_Setup_Fees__c));
        if(!$A.util.isUndefinedOrNull(quote.Product__r.Summary_Page_What_You_ll_Get__c) && quote.Product__r.Summary_Page_What_You_ll_Get__c != null){
            var whatYouGet = quote.Product__r.Summary_Page_What_You_ll_Get__c.split(";");
        }
        if(!$A.util.isUndefinedOrNull(quote.Product__r.What_document_needs_to_apply__c) && quote.Product__r.What_document_needs_to_apply__c != null){
            var whatYouNeed = quote.Product__r.What_document_needs_to_apply__c.split(";");
        }
       	component.set("v.whatYouNeed", whatYouNeed);
        component.set("v.whatYouGet", whatYouGet);
        component.set("v.quote",quote); 
    },
    
    SaveNext: function(component, event, helper) {
        helper.toggleSpinner(component, event);
        helper.scrollTop(component, event);
        helper.SaveAndConfirm(component, event);
    },
    
    onChange : function(component, event, helper) {
        
        var quote = component.get("v.quote");
        var opp = component.get("v.opportunity");
        
        var isPrivacyCreditGuide = component.get("v.isPrivacyCreditGuide");
        var productDisclosure = quote.Up_Front_Costs_Applicable__c;
        var timeInfo = component.get("v.timeInfo");

        if(isPrivacyCreditGuide == 'Yes' && productDisclosure == 'Yes' && timeInfo == 'Yes'){
            opp.Id = component.get("v.recordId");
            opp.Privacy_and_Credit_Guide__c = 'Yes';
            opp.Product_Disclosure__c = 'Yes';
            
            component.set("v.opportunity", opp);
            component.set("v.isDisabled", false);
        }else{
            component.set("v.isDisabled", true);
        }
    },
    
    updateSec : function(component, event, helper){
        helper.toggleSpinner(component, event);
        helper.scrollTop(component, event);
        helper.updateApplicationSection(component, event);
    },
    
    // Start by sethu
    sendOtpHandleClick : function(component, event, helper){
        helper.toggleSpinner(component, event);
        var randomNum = Math.floor(1000 + Math.random() * 9000);
		var num = Math.round(randomNum);
        alert(num);
        var email = component.get("v.applicantEmail");
        var action  = component.get("c.sendOtpMail");
        action.setParams({
            otp : num,
            email : email
        })
        action.setCallback(this, function(response){
            var state = response.getState();
	
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                component.set("v.isOtpSent",true);
        		component.set("v.otpValue",num);
                
            }
			helper.toggleSpinner(component, event);
        })
        $A.enqueueAction(action);
        
    },
    submitSendOtpHandleClick:function(component, event,helper){
        var enteredOtp = component.get("v.enteredOTP");
        var expectedOtp = component.get("v.otpValue");
        
        if (enteredOtp == expectedOtp) {
            component.set("v.isOtpVerified", true);
            component.set("v.otpErrorMessage", "");
        }else if (enteredOtp == null) {
            component.set("v.otpErrorMessage", "Please enter OTP");
        }else {
            component.set("v.isOtpVerified", false);
            component.set("v.otpErrorMessage", "OTP does not match.");
        }
    }
    // End by sethu
})