({
    doInit: function(component, event, helper) {
        helper.toggleSpinner(component, event);
        helper.getLivingExpensesDetails(component, event);
        helper.scrollTop(component, event, 70);
    },
    
    save: function(component, event, helper) {
        var allValid = true; /*= component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        
		component.set("v.showError",!allValid);*/
        /*
        	
        
        */
        if (allValid) {
            helper.toggleSpinner(component, event);
            helper.upsertLivingExpensesDetails(component, event, true, false);
        }else{
            component.set("v.errorMsg", "Please update the form entries highlighted in red and try again");
        }
        helper.scrollTop(component, event, 70);
    },
    
    saveApplication: function(component, event, helper) {
        var args = event.getParam("arguments");
        var isShare = args.isShare;
        var isNext = args.isNext;
        component.set("v.showError",false);
        helper.toggleSpinner(component, event);
        helper.upsertLivingExpensesDetails(component, event, isNext, isShare);
        helper.scrollTop(component, event, 70);
    },
    
    totalExpenses : function(component, event, helper) {
        helper.doTotal(component, event);
    },
     
    prevSave: function(component, event, helper) {
        var recordId =component.get("v.recordId");
        helper.toggleSpinner(component, event);
        helper.SavePrev(component, event, recordId);
		helper.scrollTop(component, event, 70);
    }
    
})