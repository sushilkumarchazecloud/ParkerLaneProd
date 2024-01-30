({
	getGoals : function(component, event) {
		var action = component.get("c.getGoals");
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
                    component.set('v.goal', ret);
                    if(!$A.util.isUndefinedOrNull(ret) && !$A.util.isUndefinedOrNull(ret.Which_life_events_are_relevant_to_you__c)){
                        var lifeEvents = ret.Which_life_events_are_relevant_to_you__c.split(';');
                        if( lifeEvents.length == 0){
                            component.set('v.isLifeEventRequired', true);
                        }else{
                            component.set('v.isLifeEventRequired', false);
                        }
                        component.set('v.lifeEvents', lifeEvents);
                        component.set('v.lifeEvents2', lifeEvents);
                    }else{
                        component.set('v.isLifeEventRequired', true);
                    }
                    if(!$A.util.isUndefinedOrNull(ret) && !$A.util.isUndefinedOrNull(ret.Which_financial_priorities_relevant_you__c)){
                        var financialPriorities= ret.Which_financial_priorities_relevant_you__c.split(';');
                        if( financialPriorities.length == 0 ){
                            component.set('v.isFinPriorityRequired', true);
                        }else{
                            component.set('v.isFinPriorityRequired', false);
                        }
                        component.set('v.financialPriorities', financialPriorities);
                        component.set('v.financialPriorities2', financialPriorities);
                    }else{
                        component.set('v.isFinPriorityRequired', true);
                    }
                }
            }
            self.toggleSpinner(component, event);
            self.scrollTop(component, event, 315);
        });
        $A.enqueueAction(action);
	},
    
    upsertGoals: function (component, event, isOppUpdate, isShare) {
        var action = component.get("c.upsertGoals");
        var self = this;
        var oppId = component.get('v.recordId');
        
     	action.setParams({
            goal: component.get('v.goal'),
            oppId : oppId,
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
                    if(ret !=''){
                        self.createEnvelope(component, event);
                        window.location = JSON.parse(ret).url;
                    }
                }
            }
            self.toggleSpinner(component, event);
            self.scrollTop(component, event, 315);
        });
        $A.enqueueAction(action);
    },
    
    createEnvelope: function (component, event) {
        var action = component.get("c.createEnvelope");
        var self = this;
        var oppId = component.get('v.recordId');
        
     	action.setParams({
            oppId : oppId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

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
                    self.upsertGoals(component, event, false, false);
                }
            }
            self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
	},
    
    toggleSpinner: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
    
    scrollTop: function (component, event, top){
        var scrollOptions = {
            left: 0,
            top: top,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    },
})