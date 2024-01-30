({
	getOppContacts : function(component, event, recordId) {
		var action = component.get("c.getOppContacts");
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
                    if(ret.opp.Applicant_1__c != null || ret.opp.Applicant_2__c != null){
                        component.set('v.applicant1', ret.contact1);
                        component.set('v.applicant2', ret.contact2);
                        component.set('v.app1Children', ret.app1Children);
                        component.set('v.app2Children', ret.app2Children);
                        if(ret.opp.Number_of_applicants__c == 1 || !$A.util.isUndefinedOrNull(ret.contact1)){
                            component.set('v.selectedPerson', "single");
                            if(ret.contact1.FirstName !='' && ret.contact1.LastName !='' && ret.contact1.Email !='' && 
                               ret.contact1.Phone !='' && !$A.util.isUndefinedOrNull(ret.contact1.FirstName) && 
                               !$A.util.isUndefinedOrNull(ret.contact1.LastName) && !$A.util.isUndefinedOrNull(ret.contact1.Email) && 
                               !$A.util.isUndefinedOrNull(ret.contact1.Phone)){
                            }
                            
                        }
                        if(ret.opp.Number_of_applicants__c == 2 || !$A.util.isUndefinedOrNull(ret.contact2)){
                            component.set('v.selectedPerson', "joint");
                        }
                    }
                }
            }
            self.toggleSpinner(component, event);
            self.scrollTop(component, event, 315);
        });
        $A.enqueueAction(action);
	},
    
    upsertOppCons: function (component, event, isOppUpdate, isShare) {
        var action = component.get("c.upsertOppContacts");
        var self = this;
        var opp = component.get('v.opportunity');
        
        var applicant1= component.get('v.applicant1');
        var applicant2= component.get('v.applicant2');
        if(!$A.util.isUndefinedOrNull(applicant1) && !$A.util.isUndefinedOrNull(applicant1.Medicare_Expiry_Year__c) && !$A.util.isUndefinedOrNull(applicant1.Medicare_Expiry_Month__c)){
            applicant1.Medicare_Expiry_Date__c = new Date(applicant1.Medicare_Expiry_Year__c, applicant1.Medicare_Expiry_Month__c, "01");
        }
        if(!$A.util.isUndefinedOrNull(applicant2) && !$A.util.isUndefinedOrNull(applicant2.Medicare_Expiry_Year__c) && !$A.util.isUndefinedOrNull(applicant2.Medicare_Expiry_Month__c)){
            applicant2.Medicare_Expiry_Date__c = new Date(applicant2.Medicare_Expiry_Year__c, applicant2.Medicare_Expiry_Month__c, "01");
        }
        applicant1.FinServ__NumberOfChildren__c = parseInt(applicant1.FinServ__NumberOfChildren__c);
        if(!$A.util.isUndefinedOrNull(applicant2)) {
            applicant2.FinServ__NumberOfChildren__c = parseInt(applicant2.FinServ__NumberOfChildren__c);
        }
       
     	action.setParams({
            con1 : component.get('v.applicant1'),
            con2 : component.get('v.applicant2'), 
            app1Children : component.get('v.app1Children'),
            app2Children : component.get('v.app2Children'),
            opp : opp,
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
    
    checkExistingCustomer : function(component, event, emailIds) {
		var action = component.get("c.checkExistingCustomer");
        var self = this;
        var con1 = component.get('v.applicant1');
        var con2 = component.get('v.applicant2');
        var opp = component.get('v.opportunity');
        var selectedPerson = component.get('v.selectedPerson');
        var Number_of_applicants = 0;
        if(selectedPerson == 'single'){
           Number_of_applicants = '1';
        } else if(selectedPerson == 'joint'){
            Number_of_applicants = '2';
        }
     	action.setParams({
            con1 : con1,
            con2 : con2,
            opp : opp,
            Number_of_applicants : Number_of_applicants
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var ret = response.getReturnValue();
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                }else{
                    if(JSON.parse(ret).status == 'Success'){
                        component.set('v.showError', false);
                        component.set("v.selectedTab", "AboutFormTab");
                        component.set("v.isDisableNext", false);
                        if(!$A.util.isUndefinedOrNull(con2) && $A.util.isUndefinedOrNull(con2.Id) && !$A.util.isUndefinedOrNull(JSON.parse(ret).con2Id)){
                            con2.Id = JSON.parse(ret).con2Id;
                            component.set("v.applicant2", con2);
                        }                        
                    }else if(JSON.parse(ret).status == 'Error'){                    
                        component.set('v.errorMsg', JSON.parse(ret).message);
                        component.set('v.showError', true);
                    }
                }
            }
            self.toggleSpinner(component, event);
            self.scrollTop(component, event, 315);
        });
        $A.enqueueAction(action);
	},
    
    scrollTop: function (component, event, top){
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