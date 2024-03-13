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
                console.log('>>>>' +JSON.stringify(ret));
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                }else if(ret!=''){
                    var goal = ret;
                    //goal.Finish_this_sentance_i_get_annoyed__c = ''+ goal.Finish_this_sentance_i_get_annoyed__c;
                    component.set('v.goal', goal);                    
                    if(!$A.util.isUndefinedOrNull(goal) && !$A.util.isUndefinedOrNull(goal.Which_life_events_are_relevant_to_you__c)){
                        var lifeEvents = goal.Which_life_events_are_relevant_to_you__c.split(';');
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
                    if(!$A.util.isUndefinedOrNull(goal) && !$A.util.isUndefinedOrNull(goal.Which_financial_priorities_relevant_you__c)){
                        var financialPriorities= goal.Which_financial_priorities_relevant_you__c.split(';');
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
                self.getOppCons(component, event);
            }
            //self.toggleSpinner(component, event);
            //self.scrollTop(component, event, 300);
        });
        $A.enqueueAction(action);
    },
    getOppCons : function(component, event) {
        var action = component.get("c.getPreferences");
        var self = this;
        action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                console.log('>>>>' +JSON.stringify(ret));
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                }else if(ret!=''){
                    var oppCons = ret;
                    component.set('v.opportunity', oppCons.opp);
                    console.log('oppCons>>>>>'+ JSON.stringify(oppCons));
                    console.log('oppCons>>>>>'+ JSON.stringify(oppCons.contact2));
                    if(oppCons.opp.Applicant_1__c != null || oppCons.opp.Applicant_2__c != null){
                        component.set('v.applicant1', oppCons.contact1);
                        component.set('v.applicant2', oppCons.contact2);
                    }
                }
            }
            self.toggleSpinner(component, event);
            self.scrollTop(component, event, 70);
        });
        $A.enqueueAction(action);
    },
    
    upsertFinGoals: function (component, event, isOppUpdate, isShare) {
        //var action = component.get("c.upsertGoals");
        var action = component.get("c.upsertGoals");
        var self = this;
        var oppId = component.get('v.recordId');
        var goal= component.get('v.goal');
        
        action.setParams({
            goal : component.get('v.goal'),
            oppId : oppId,
            con1 : component.get('v.applicant1'), 
            con2 : component.get('v.applicant2'),
            isOppUpdate : isOppUpdate,
            isShare : isShare
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('@@@@' + JSON.stringify(response));
            console.log('@@@@' + JSON.stringify(response.getError()));
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){                    
                    component.set("v.showError", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                }else{
                    if(ret !=''){
                        //self.createEnvelope(component, event);
                        component.set('v.applicationSection', JSON.parse(ret).CurrentSection);
                        component.set('v.appSectionPath', JSON.parse(ret).path);                        
                        component.set('v.redirectURL', JSON.parse(ret).url);
                        
                        var isRedirect = JSON.parse(ret).isRedirect;
                        self.GeneratePreliminaryPDF(component, event);
                        if(isRedirect =="Yes"){
                            window.location = JSON.parse(ret).url;
                        }
                    }
                }
            }
            self.toggleSpinner(component, event);
            self.scrollTop(component, event, 300);
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
            console.log('state>>>>' + state)
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
                    self.upsertFinGoals(component, event, false, false);
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
        var isMoile = false;
        if(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)){
            isMoile = true;
            top += 100;
        }else{
            isMoile = false;
        }
        var scrollOptions = {
            left: 0,
            top: top,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    },
    
    GeneratePreliminaryPDF: function (component, event){
        var action = component.get("c.inertPDF");
        var self = this;
        
        action.setParams({
            oppId: component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
           
            self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
    }
})