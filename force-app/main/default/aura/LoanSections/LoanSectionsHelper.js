({
	getSelPerson : function(component, event) {
        var action = component.get("c.getSelectedPerson");
        var self = this;
        action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                component.set('v.selectedPerson', ret);
            }
        });
        $A.enqueueAction(action);
    },
    
    getSectionStatus : function(component, event, recordId) {
		var action = component.get("c.getSelectedSection");
        var self = this;

     	action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                component.set('v.applicationSection', JSON.parse(ret).CurrentSection);
                component.set('v.appSectionPath', JSON.parse(ret).path);
                component.set('v.isMortgage', JSON.parse(ret).isMortgage);
                self.toggleSpinner(component, event);
            }
        });
        $A.enqueueAction(action);
	},
    
    setSelectedSections : function(component, event, recordId, selectedPath) {
		var action = component.get("c.setSelectedSection");
        var self = this;
     	action.setParams({
            recordId: recordId,
            selectedPath : selectedPath
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                self.saveAndShareApplication(component, event, false);
                component.set('v.applicationSection', JSON.parse(ret).CurrentSection);
                component.set('v.appSectionPath', JSON.parse(ret).path);
                
            }
            self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
	},
    
    shareAppByEmail : function(component, event, recordId, email, emailBody) {
		var action = component.get("c.shareApplicationByEmail");
        var self = this;
     	action.setParams({
            recordId: recordId, 
            email : email, 
            emailBody: emailBody
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                component.set("v.email", "");
                component.set("v.emailDetail", "");
            }
            self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
	},
    
    saveAndShareApplication : function(component, event, isShare) {
        var recordId =component.get("v.recordId");
        var applicationSection = component.get("v.applicationSection");
        var appSectionPath = component.get("v.appSectionPath");
        
        if(applicationSection === 'Who is applying'){
            var whoIsApplying = component.find("whoIsApplying");
            whoIsApplying.upsertOppContacts(isShare, false);
            
        }else if(applicationSection === 'Own and Owe'){
            var ownAndOwe = component.find("ownAndOwe");
            ownAndOwe.saveAssetAndLiability(isShare, false);

        }else if(applicationSection === 'Earn'){
            var ApplicantEanrings = component.find("ApplicantEanrings");
            ApplicantEanrings.saveEmploymentDetails(isShare, false);

        }else if(applicationSection === 'Living Expenses'){
            var LivingExpenses = component.find("LivingExpenses");
            LivingExpenses.saveLivingExpensesDetails(isShare, false);
            
        }else if(applicationSection === 'Preferences'){
            var preferenses = component.find("Preferences");
            preferenses.savePreferensesDetails(isShare, false);
            
        }else if(applicationSection === 'Goals & Objectives'){
            var goals = component.find("GoalsObjectives");
            goals.saveGoalsDetails(isShare, false);
            
        }else if(applicationSection === 'Anticipated Changes to Circumstances'){
            var anticipated = component.find("AnticipatedChangesCircumstances");
            anticipated.saveAnticipatedDetails(isShare, false);
            
        }
        
    },
    
    toggleSpinner: function (component, event) {
        //var spinner = component.find("mySpinner");
        //$A.util.toggleClass(spinner, "slds-hide");
    },
    
    
})