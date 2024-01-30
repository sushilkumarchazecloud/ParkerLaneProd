({
    doInit: function(component, event, helper) {
        helper.toggleSpinner(component, event);
        helper.getLivingExpensesDetails(component, event);
        helper.scrollTop(component, event, 70);
    },
    
    save: function(component, event, helper) {
        var isValid = helper.validateLivingExpenses(component);
        if (isValid) {
            var isRightAmount = helper.checkLivingExpenses(component);
            if(isRightAmount){
                helper.toggleSpinner(component, event);
                helper.upsertLivingExpensesDetails(component, event, true, false);
                helper.scrollTop(component, event, 70);
            }
            else{
                component.set("v.showError",false);
                component.set("v.showAmountError",true);
                var targetElement = component.find("scrollTarget").getElement().offsetTop;
                if (targetElement) {
                    window.scrollTo({ top: targetElement-4, behavior: 'smooth'});
                }
            }
        }else{
            component.set("v.showError",true);
            component.set("v.showAmountError",false);
            component.set("v.errorMsg", "Please update the form entries highlighted in red and try again");
            helper.scrollTop(component, event, 70);
        }
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