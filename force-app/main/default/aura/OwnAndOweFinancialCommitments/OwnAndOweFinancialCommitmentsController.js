({
    doInit : function(component, event, helper) {
        helper.setMonthsYearsTerms(component, event);
        
        var liability = component.get("v.liability");
        if(liability.FinServ__Ownership__c == 'Joint'){
            component.set("v.app1Ownership", "Applicant 1 Ownership Share (%)");
            component.set("v.app2Ownership", "Applicant 2 Ownership Share (%)");
        }else if(liability.FinServ__Ownership__c == 'Joint (non-applicant)'){
            component.set("v.app1Ownership", "Applicant Ownership Share (%)");
            component.set("v.app2Ownership", "Non-Applicant Ownership Share (%)");
        }else if(liability.FinServ__Ownership__c == 'Joint with Spouse'){
            component.set("v.app1Ownership", "Applicant Ownership Share (%)");
            component.set("v.app2Ownership", "Spouse Ownership Share (%)");
        }
		if(!$A.util.isUndefinedOrNull(liability) && !$A.util.isUndefinedOrNull(liability.Rate_Expires_in_Years__c)){
            liability.Rate_Expires_in_Years__c = '' + liability.Rate_Expires_in_Years__c;
        }
        if(!$A.util.isUndefinedOrNull(liability) && !$A.util.isUndefinedOrNull(liability.Rate_Expires_in_Months__c)){
            liability.Rate_Expires_in_Months__c = '' + liability.Rate_Expires_in_Months__c;
        }else{
            liability.Rate_Expires_in_Months__c = '0';
        }
        
        component.set("v.liability", liability);
    },
    
    validateCommitment : function(component, event, helper) {
        var fieldcheck = component.find('fieldcheck');
        var inputField = component.find('fieldcheckType');
        var value = inputField.get('v.value');
		var isvalidate =false;
        var ownShareEle = component.find('ownShare');
        $A.util.removeClass(ownShareEle, 'errMoreThan50');
        if(value != 'foo') {
            inputField.set('v.validity', {valid:false, badInput :true});
            inputField.showHelpMessageIfInvalid();
            isvalidate =false;
        }
        
        if(!$A.util.isUndefinedOrNull(fieldcheck) && !$A.util.isUndefinedOrNull(fieldcheck.length)){
             isvalidate = fieldcheck.reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && !inputCmp.get('v.validity').valueMissing;
            }, true);
        
        }
        
        component.set("v.showError",!isvalidate);
        component.set("v.errorMsg", "Please update the form entries highlighted in red and try again");
        
        var liability = component.get("v.liability");
        if(!$A.util.isUndefinedOrNull(liability) && 
           !$A.util.isUndefinedOrNull(liability.FinServ__Ownership__c) &&
           !$A.util.isUndefinedOrNull(liability.Ownership_Share__c) &&
           !$A.util.isUndefinedOrNull(liability.Other_Ownership_Share__c)){
            var app1Share = parseInt(liability.Ownership_Share__c);
            var app2Share = parseInt(liability.Other_Ownership_Share__c);
            var totalSharing = app1Share + app2Share;
            if(isvalidate && ((totalSharing > 100) || (app1Share < 0) || (app2Share < 0))){
                component.set("v.showError", true);
                component.set("v.errorMsg", "Ownership cannot total more than 100%");
                var ownShareEle = component.find('ownShare');
                $A.util.addClass(ownShareEle, 'errMoreThan50');
                isvalidate = false;
            }
        }
        return isvalidate;
    },
    
    handleOwnership : function(component, event, helper) {
        var liability = component.get("v.liability");
        if(!$A.util.isUndefinedOrNull(liability) && !$A.util.isUndefinedOrNull(liability.FinServ__Ownership__c)){
            var isJoint = false;
            if(liability.FinServ__Ownership__c == 'Joint'){
                component.set("v.app1Ownership", "Applicant 1 Ownership Share (%)");
                component.set("v.app2Ownership", "Applicant 2 Ownership Share (%)");
                isJoint = true;
            }else if(liability.FinServ__Ownership__c == 'Joint (non-applicant)'){
                component.set("v.app1Ownership", "Applicant Ownership Share (%)");
                component.set("v.app2Ownership", "Non-Applicant Ownership Share (%)");
                isJoint = true;
            }else if(liability.FinServ__Ownership__c == 'Joint with Spouse'){
                component.set("v.app1Ownership", "Applicant Ownership Share (%)");
                component.set("v.app2Ownership", "Spouse Ownership Share (%)");
                isJoint = true;
            }
            if(isJoint){
                liability.Other_Ownership_Share__c = 50;
                liability.Ownership_Share__c = 50;
            }else{
                liability.Other_Ownership_Share__c = 0;
                liability.Ownership_Share__c = 0;
            }
            component.set("v.liability", liability);
        }
    },
    
    deleteLiability : function(component, event, helper) {
		var deleyeEvent = component.getEvent("SolarDeleteRowEvent");
        deleyeEvent.setParams({"indexVar" : component.get("v.index"),
                               "rowType" : "Liability"});
        deleyeEvent.fire();
    },
    
    changePercentageBlur : function(component, event, helper) {
		var rate = component.get("v.liability.Interest_Rate__c");
        component.set("v.liability.Interest_Rate__c", rate/100);
    },
    
    changePercentageFocus : function(component, event, helper) {
		var rate = component.get("v.liability.Interest_Rate__c");
        component.set("v.liability.Interest_Rate__c", rate*100);
    },
    
    changePerOwnershipBlur : function(component, event, helper) {
        
		var liability = component.get("v.liability");
        liability.Ownership_Share__c = liability.Ownership_Share__c/100;
        liability.set("v.liability", liability);
    },
    
    changePerOwnershipFocus : function(component, event, helper) {
        var liability = component.get("v.liability");
        liability.Ownership_Share__c = liability.Ownership_Share__c*100;
        component.set("v.liability", liability);
    },
})