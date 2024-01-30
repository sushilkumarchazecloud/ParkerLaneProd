({
	doInit: function(component, event, helper){
        helper.toggleSpinner(component, event);
        helper.getGoals(component, event);
        helper.scrollTop(component, event, 70);
       /* if(component.get("v.selectedPerson") == 'joint')
        {
            component.set("v.selectedPerson",'How would you rate the security of your income is joint applicants?')
        }*/
    },
    
    prevSave: function(component, event, helper) {
        var recordId =component.get("v.recordId");
        helper.SavePrev(component, event, recordId);
    },

    handlelifeEvents: function (component, event) {
        var goal = component.get('v.goal');
        var lifeEvents ='';
        var lifeEvent1 = component.get('v.lifeEvents');
        var lifeEvent2 = component.get('v.lifeEvents2');

        if(!$A.util.isUndefinedOrNull(lifeEvent1) && lifeEvent1.length > 0){
            lifeEvents += lifeEvent1.join(";") +';';
        }
        if(!$A.util.isUndefinedOrNull(lifeEvent2) && lifeEvent2.length > 0){
            lifeEvents += lifeEvent2.join(";");
        }
        
        if( lifeEvent1.length == 0 && lifeEvent2.length == 0){
            component.set('v.isLifeEventRequired', true);
		}else{
            component.set('v.isLifeEventRequired', false);
        }
        
        goal.Which_life_events_are_relevant_to_you__c = lifeEvents;
        component.set('v.goal', goal);
    },
    
    handleFinancialPriorities: function (component, event) {
        var goal = component.get('v.goal');
        var financialPriorities ='';
        var financialPriorities1 = component.get('v.financialPriorities');
        var financialPriorities2 = component.get('v.financialPriorities2');

        if(!$A.util.isUndefinedOrNull(financialPriorities1) && financialPriorities1.length > 0){
            financialPriorities += financialPriorities1.join(";") +';';
        }
        if(!$A.util.isUndefinedOrNull(financialPriorities2) && financialPriorities2.length > 0){
            financialPriorities += financialPriorities2.join(";") +';';
        }
        
        if( financialPriorities1.length == 0 && financialPriorities2.length == 0){
            component.set('v.isFinPriorityRequired', true);
		}else{
            component.set('v.isFinPriorityRequired', false);
        }
        
        goal.Which_financial_priorities_relevant_you__c = financialPriorities;
        component.set('v.goal', goal);
    }, 
    
    save: function(component, event, helper) {
        var recordId =component.get("v.recordId");
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        
        var validity = true;
        var fieldcheckLifeEvent = component.find("fieldcheckLifeEvent");
        if($A.util.isUndefinedOrNull(fieldcheckLifeEvent)){
            var fValidity = fieldcheckLifeEvent.get("v.validity");
            validity = fValidity.valid;
            fieldcheckLifeEvent.reportValidity();
        }
        var lifeEvent1 = component.get('v.financialPriorities2');
        if (allValid ) {
            helper.toggleSpinner(component, event);
            helper.upsertFinGoals(component, event, true, false);
            component.set("v.showError",false);
        }else{
            component.set("v.showError",true);
            component.set("v.errorMsg", "Please update the form entries highlighted in red and try again");
        }
        helper.scrollTop(component, event, 300);
    },
    
    saveApplication: function(component, event, helper) {
        var args = event.getParam("arguments");
        var isShare = args.isShare;
        var isNext = args.isNext;
        var recordId =component.get("v.recordId");
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        
		var lifeEvent1 = component.get('v.financialPriorities2');
         
        if (allValid ) {
            helper.toggleSpinner(component, event);
            helper.upsertFinGoals(component, event, isNext, isShare);
            component.set("v.showError",false);
        }else{
            component.set("v.showError",true);
            component.set("v.errorMsg", "Please update the form entries highlighted in red and try again");
        }
        helper.scrollTop(component, event, 70);
    },
    
    handleNotApp: function(component, event, helper) {
        var goal = component.get('v.goal');
        var fieldName = event.getSource().get("v.value");
        if(event.getSource().get("v.checked") ==true){
            goal[fieldName] = 'Not applicable';
        }else{
            goal[fieldName] = '';
        }
		component.set('v.goal', goal);
    },
})