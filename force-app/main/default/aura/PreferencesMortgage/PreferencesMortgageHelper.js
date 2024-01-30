({
    getPreferences : function(component, event, recordId) {
        var action = component.get("c.getPreferences");
        var self = this;
        action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                }else{
                    component.set('v.opportunity', ret.opp);

                    if( !$A.util.isUndefinedOrNull(ret.opp.Loan_Purposes__r)){
                        component.set('v.loanPurposesList', ret.opp.Loan_Purposes__r);
                    }
                    if(!$A.util.isUndefinedOrNull(ret.opp.Any_product_types_you_are_interested_in__c)){
                        component.set('v.anyProductTypes', ret.opp.Any_product_types_you_are_interested_in__c.split(';'));
                    }
                    
                    self.calculatePurposeAmount(component);
                    if(ret.opp.Applicant_1__c != null || ret.opp.Applicant_2__c != null){
                        component.set('v.applicant1', ret.contact1);
                        component.set('v.applicant2', ret.contact2);
                        if(ret.opp.Number_of_applicants__c == 1 || !$A.util.isUndefinedOrNull(ret.contact1)){
                            component.set('v.selectedPerson', "single");
                        }
                        if(ret.opp.Number_of_applicants__c == 2 || !$A.util.isUndefinedOrNull(ret.contact2)){
                            component.set('v.selectedPerson', "joint");
                        }
                    }
                }
            }
            self.toggleSpinner(component, event);
            self.scrollTop(component, event);
        });
        $A.enqueueAction(action);
    },
    
    SavePrev : function(component, event, recordId) {
        var action = component.get("c.previous");
        var self = this;
        
        action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue(); 
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                }else{
                    component.set('v.applicationSection', JSON.parse(ret).CurrentSection);
                    component.set('v.appSectionPath', JSON.parse(ret).path);
                    self.upsertPreferences(component, event, false, false);
                }
            }
            self.toggleSpinner(component, event);
            self.scrollTop(component, event);
        });
        $A.enqueueAction(action);
    },
    
    upsertPreferences: function (component, event, isOppUpdate, isShare) {
        var action = component.get("c.upsertPreferences");
        var self = this;
        var opp = component.get('v.opportunity');
        var selectedPerson = component.get('v.selectedPerson', "single");
        if(selectedPerson == 'single'){
           opp.Number_of_applicants__c = '1';
        } else if(selectedPerson == 'joint'){
            opp.Number_of_applicants__c = '2';
        }
        
     	action.setParams({
            con1: component.get('v.applicant1'),
            con2: component.get('v.applicant2'), 
            opp : opp,
            loanPurposesList: component.get('v.loanPurposesList'),
            isOppUpdate : isOppUpdate,
            isShare : isShare
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                }else{
                    component.set('v.applicationSection', JSON.parse(ret).CurrentSection);
                    component.set('v.appSectionPath', JSON.parse(ret).path);
                }
            }
            self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
        
    },
    
    calculatePurposeAmount: function (component){
        var loanPurposesList = component.get('v.loanPurposesList');
        var totalPurposeAmount = 0;
        if(!$A.util.isUndefinedOrNull(loanPurposesList)){
            for(var i=0; i<loanPurposesList.length; i++){
                totalPurposeAmount += parseFloat(loanPurposesList[i].Amount__c);
            }
        }
        component.set('v.totalPurposeAmount', totalPurposeAmount);
	},
    
    deleteRecords: function (component, event, ids) {
        
        var action = component.get("c.deleteRecordsByIds");
        var self = this;
        action.setParams({
            recordIdsList: ids
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "ERROR") {
                component.set("v.showError", true);
                component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
            }
            self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
    },
    
    validateDetails : function(component, event) {
		var isvalidate = true;
        var fieldcheck = component.find('fieldcheck');
        if(!$A.util.isUndefinedOrNull(fieldcheck) && !$A.util.isUndefinedOrNull(fieldcheck.length)){
             isvalidate = fieldcheck.reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && !inputCmp.get('v.validity').valueMissing;
            }, true);
        
        }
        component.set("v.showError",!isvalidate);
        return isvalidate;
    },
    
    scrollTop: function (component, event){
        var top = 0;
        if(component.get("v.isMortgage")){
            top =200;
        }else{
            top = 315;
        }
        var scrollOptions = {
            left: 0,
            top: top,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    },
    
    toggleSpinner: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
})