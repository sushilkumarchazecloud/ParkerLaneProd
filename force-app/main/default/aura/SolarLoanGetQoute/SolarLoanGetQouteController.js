({
	getPreferRepay: function (component, event,helper) {
      
        var howMuchFieldcheck = component.get("v.customerAmount");

        if(!$A.util.isUndefinedOrNull(howMuchFieldcheck) && howMuchFieldcheck>0 ){
            var wantBorrow = component.find("want-borrow");
            var preferRepay = component.find("prefer-repay");
            $A.util.addClass(wantBorrow, "slds-hide");
            $A.util.removeClass(preferRepay, "slds-hide");
            component.set("v.showError",false);
        }else{
			/*
            var inputField = component.find('howMuchFieldcheck');
            inputField.set('v.validity', {valid:false, badInput :true});
            inputField.showHelpMessageIfInvalid();
            alert(0);*/
            component.set("v.errorMessage","Error: Please Loan amount");
            component.set("v.showError",true);
            helper.scrollTop(component, event, 315);
        }
    },
    getPreferRepayOnEnter: function (component, event) {
        
        if(event.keyCode === 13){
            var howMuchFieldcheck = component.get("v.customerAmount");
            if(!$A.util.isUndefinedOrNull(howMuchFieldcheck) && howMuchFieldcheck>0 ){
                var wantBorrow = component.find("want-borrow");
                var preferRepay = component.find("prefer-repay");
                $A.util.addClass(wantBorrow, "slds-hide");
                $A.util.removeClass(preferRepay, "slds-hide");
                component.set("v.showError",false);
            }else{
                component.set("v.errorMessage","Error: Please Loan amount");
                component.set("v.showError",true);
                helper.scrollTop(component, event, 315);
            }
        }
    },
    getHomeOwner3y: function (component, event) {
        var homeOwner = component.find("home-owner");
        var preferRepay = component.find("prefer-repay");
        $A.util.removeClass(homeOwner, "slds-hide");
        $A.util.addClass(preferRepay, "slds-hide");
        component.set("v.repayOverTerm", "Less than 3 Years");
    },
    
    getHomeOwner3_5y: function (component, event) {
        var homeOwner = component.find("home-owner");
        var preferRepay = component.find("prefer-repay");
        $A.util.removeClass(homeOwner, "slds-hide");
        $A.util.addClass(preferRepay, "slds-hide");
        component.set("v.repayOverTerm", "Between 3-5 Years");
    },
    
    getHomeOwner5y: function (component, event) {
        var homeOwner = component.find("home-owner");
        var preferRepay = component.find("prefer-repay");
        $A.util.removeClass(homeOwner, "slds-hide");
        $A.util.addClass(preferRepay, "slds-hide");
        component.set("v.repayOverTerm", "More than 5 Years");
    },
    
    getMyPriorityYes: function (component, event) {
        var myPriority = component.find("my-priority");
        var homeOwner = component.find("home-owner");
        $A.util.addClass(homeOwner, "slds-hide");
        $A.util.removeClass(myPriority, "slds-hide");
        component.set("v.homeOwner", "Yes");
    },
    
    getMyPriorityNo: function (component, event) {
        var myPriority = component.find("my-priority");
        var homeOwner = component.find("home-owner");
        $A.util.addClass(homeOwner, "slds-hide");
        $A.util.removeClass(myPriority, "slds-hide");
        component.set("v.homeOwner", "No");
    },
    getSendQuote1: function (component, event) {
        var sendQuote = component.find("send-quote");
        var myPriority = component.find("my-priority");
        $A.util.addClass(myPriority, "slds-hide");
        $A.util.removeClass(sendQuote, "slds-hide");
        component.set("v.isShowGetQuote", true);
    },
    getSendQuote: function (component, event) {
        
        var repayOverTerm = event.getSource().get('v.value');
        
        //var repayOverTermcheck = component.get("v.repayOverTerm");

        if(!$A.util.isUndefinedOrNull(repayOverTerm) && repayOverTerm !=''){
            var sendQuote = component.find("send-quote");
            var preferRepay = component.find("prefer-repay");
            $A.util.addClass(preferRepay, "slds-hide");
            $A.util.removeClass(sendQuote, "slds-hide");
            component.set("v.showError",false);
            component.set("v.isShowGetQuote", true);
        }else{
            
            component.set("v.showError",true);
        }
        
    },
    getSendQuoteOnEnter: function (component, event) {
        
        if(event.keyCode === 13){
            var repayOverTerm = event.getSource().get('v.value');
            //var repayOverTermcheck = component.get("v.repayOverTerm");
            
            if(!$A.util.isUndefinedOrNull(repayOverTerm) && repayOverTerm !=''){
                var sendQuote = component.find("send-quote");
                var preferRepay = component.find("prefer-repay");
                $A.util.addClass(preferRepay, "slds-hide");
                $A.util.removeClass(sendQuote, "slds-hide");
                component.set("v.showError",false);
                component.set("v.isShowGetQuote", true);
            }else{
                
                component.set("v.showError",true);
            }
        }
    },
    
    checkDetails: function (component, event) {
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        component.set("v.showError",!allValid);
        return allValid;
    },
})