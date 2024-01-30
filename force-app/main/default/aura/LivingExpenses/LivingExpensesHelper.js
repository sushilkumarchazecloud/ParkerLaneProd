({
	getLivingExpensesDetails : function(component, event) {
		var action = component.get("c.getLivingExpensesDetails");
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
                    component.set('v.applicant', ret.con);
                    this.doTotal(component,event);
                }
            }
            self.toggleSpinner(component, event);
            self.scrollTop(component, event, 315);
        });
        $A.enqueueAction(action);
	},
    
    upsertLivingExpensesDetails: function (component, event, isNext, isShare) {
        var action = component.get("c.upsertLivingExpensesDetails");
        var self = this;
        var oppId = component.get('v.recordId');
        
     	action.setParams({
            con: component.get('v.applicant'),
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
            self.scrollTop(component, event, 315);
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
                    self.upsertLivingExpensesDetails(component, event, false, false);
                }
            }
            self.toggleSpinner(component, event);
            self.scrollTop(component, event, 315);
        });
        $A.enqueueAction(action);
	},
    doTotal : function(component, event) {
        var applicant = component.get("v.applicant");
        var total = 0.00;
        total += $A.util.isUndefined(applicant.Utilities__c) ? 0 : parseFloat( applicant.Utilities__c); 
        total += $A.util.isUndefined(applicant.Investment_property_utilities__c) ? 0 : parseFloat( applicant.Investment_property_utilities__c); 
        total += $A.util.isUndefined(applicant.Connections_Phone_Mobile_Internet_C__c) ? 0 : parseFloat( applicant.Connections_Phone_Mobile_Internet_C__c); 
        total += $A.util.isUndefined(applicant.Education_ChildCare_SchoolFees_Uniform__c) ? 0 : parseFloat( applicant.Education_ChildCare_SchoolFees_Uniform__c); 
        total += $A.util.isUndefined(applicant.Education_public_and_private__c) ? 0 : parseFloat( applicant.Education_public_and_private__c); 
        total += $A.util.isUndefined(applicant.Food_Groceries_Meat_Fruit_Vegetabl__c) ? 0 : parseFloat( applicant.Food_Groceries_Meat_Fruit_Vegetabl__c); 
        total += $A.util.isUndefined(applicant.Clothing_and_personal_care__c) ? 0 : parseFloat( applicant.Clothing_and_personal_care__c); 
        total += $A.util.isUndefined(applicant.Transport_Public_Petrol_Registration__c) ? 0 : parseFloat( applicant.Transport_Public_Petrol_Registration__c); 
        total += $A.util.isUndefined(applicant.Medical_Private_Health_Insurance_Ong__c) ? 0 : parseFloat( applicant.Medical_Private_Health_Insurance_Ong__c); 
        total += $A.util.isUndefined(applicant.Insurances_Home_Personal_Voluntary__c) ? 0 : parseFloat( applicant.Insurances_Home_Personal_Voluntary__c);
        total += $A.util.isUndefined(applicant.Personal_Insurances_life_and_income_pro__c) ? 0 : parseFloat( applicant.Personal_Insurances_life_and_income_pro__c); 
        total += $A.util.isUndefined(applicant.Entertainment_Dining_Out_Movies_Gift__c) ? 0 : parseFloat( applicant.Entertainment_Dining_Out_Movies_Gift__c); 
        total += $A.util.isUndefined(applicant.Gambling_Betting_and_Lottery__c) ? 0 : parseFloat( applicant.Gambling_Betting_and_Lottery__c); 
        total += $A.util.isUndefined(applicant.Other_Regular_Expenditure__c) ? 0 : parseFloat( applicant.Other_Regular_Expenditure__c);
        applicant.Total_Living_Expenses__c = total;
        component.set("v.applicant", applicant);
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