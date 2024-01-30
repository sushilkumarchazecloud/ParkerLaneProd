({
	getAnticipateDetails : function(component, event) {
		var action = component.get("c.getAnticipatedChangesCircumstancesDetails");
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
                    component.set('v.aCCircumstance', ret);
                    if(!$A.util.isUndefinedOrNull(ret.Opportunity__r.Applicant_1__r.PersonBirthdate)){
                        var applicant1Age = this.calculate_age( new Date(ret.Opportunity__r.Applicant_1__r.PersonBirthdate));
                        component.set("v.applicant1Age", applicant1Age);
                        this.changeAge(component, event, "1");

                    }
                    if(ret.Opportunity__r.Number_of_applicants__c == 2 && !$A.util.isUndefinedOrNull(ret.Opportunity__r.Applicant_2__r.PersonBirthdate)){
                        var applicant2Age = this.calculate_age( new Date(ret.Opportunity__r.Applicant_2__r.PersonBirthdate));
                        component.set("v.applicant2Age", applicant2Age);
                        this.changeAge(component, event, "2");

                    }
                }
            }
            self.toggleSpinner(component, event);
            self.scrollTop(component, event);
        });
        $A.enqueueAction(action);
	},
    
    upsertAnticipatedDetails: function (component, event, isNext, isShare) {
        var action = component.get("c.upsertAnticipatedChangesCircumstancesDetails");
        var self = this;
        var oppId = component.get('v.recordId');
        
     	action.setParams({
            acCircumtanceDetail: component.get('v.aCCircumstance'),
            oppId : oppId,
            isOppUpdate : isNext, 
            isShare :  isShare
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
                    self.upsertAnticipatedDetails(component, event, false, false);
                }
            }
            self.toggleSpinner(component, event);
            self.scrollTop(component, event);
        });
        $A.enqueueAction(action);
    },
    
    changeAge: function(component, event, appNo) {
        var aCCircumstance = component.get("v.aCCircumstance");
        var applicantAge = component.get("v.applicant" + appNo + "Age");
        var retireAge = parseInt(aCCircumstance["Applicant_" + appNo + "_planning_to_retire_Age__c"])-parseInt(applicantAge);
        component.set("v.retireAgeApp" + appNo, retireAge);
    },
    
    calculate_age: function (dob) { 
        var diff_ms = Date.now() - dob.getTime();
        var age_dt = new Date(diff_ms); 
        return Math.abs(age_dt.getUTCFullYear() - 1970);
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