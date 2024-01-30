({
	doInit : function(component, event, helper) {
		var years = [];
        for (var i = 50; i <= 80; i++) {
            var yearStr=' Years';
            var year = {
                "label": i + yearStr,
                "value": i + yearStr
            };
            years.push(year);
        }
        component.set("v.retireYearOptions", years);
        helper.toggleSpinner(component, event);
        helper.getAnticipateDetails(component, event);
        helper.scrollTop(component, event);
	},
    
    saveNext: function(component, event, helper) {
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        
		var retAgeValid = true;
        var planAnticipateChangesValid = false;
        var retireAgeApp1 = component.get("v.retireAgeApp1");
        var retireAgeApp2 = component.get("v.retireAgeApp2");
        var aCCircumstance = component.get("v.aCCircumstance");
        
        if(aCCircumstance.Do_you_plan_or_anticipate_changes__c == "No" || (aCCircumstance.Do_you_plan_or_anticipate_changes__c == "Yes" && 
           (aCCircumstance.Extended_unpaid_Leave__c || aCCircumstance.Reduced_income__c || aCCircumstance.End_of_contract_loss_of_emp__c ||
           aCCircumstance.Leaving_employment__c || aCCircumstance.Increased_debt_repayment__c || aCCircumstance.Large_expenditure__c ||
           aCCircumstance.Medical_treatment_illness__c || aCCircumstance.Other_anticipate_changes__c) && (aCCircumstance.Additional_income_source__c ||
           aCCircumstance.Reduce_expenditure__c || aCCircumstance.Sale_of_assets__c || aCCircumstance.Savings_and_or_Superannuation__c || 
           aCCircumstance.Co_applicant_s_income__c || aCCircumstance.Relevant_options_Other__c))){
            planAnticipateChangesValid = true;
        }
        
        if(retireAgeApp1<0 || (aCCircumstance.Opportunity__r.Number_of_applicants__c ==2 && retireAgeApp2<0)){
            retAgeValid = false;
        }

        component.set("v.showError",!allValid || !retAgeValid || !planAnticipateChangesValid);
        if (allValid && retAgeValid && planAnticipateChangesValid) {
            helper.toggleSpinner(component, event);
            helper.upsertAnticipatedDetails(component, event, true, false);
        }else if(!allValid){
            component.set("v.errorMsg", "Please update the form entries highlighted in red and try again");
        }else if(!planAnticipateChangesValid){
            component.set("v.errorMsg", "You have selected 'Yes' to anticipated changes. If this is correct, please check at least one anticipated change and how you intended to meet loan repayments during this period of change.");
        }else{
            component.set("v.errorMsg", "Retirement age should not be lower than your current age");
        }
        helper.scrollTop(component, event);
    },
    
    saveApplication: function(component, event, helper) {
        var args = event.getParam("arguments");
        var isShare = args.isShare;
        var isNext = args.isNext;
        component.set("v.showError",false);
        helper.toggleSpinner(component, event);
        helper.upsertAnticipatedDetails(component, event, isNext, isShare);
        helper.scrollTop(component, event);
    },
    
    prevSave: function(component, event, helper) {
        var recordId =component.get("v.recordId");
        helper.toggleSpinner(component, event);
        helper.SavePrev(component, event, recordId);
    },
    
    changeAgeApp1: function(component, event, helper) {
        helper.changeAge(component, event, "1");
    },
    
    changeAgeApp2: function(component, event, helper) {
        helper.changeAge(component, event, "2");
    },
    
})