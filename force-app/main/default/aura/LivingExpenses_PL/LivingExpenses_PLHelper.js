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
                    component.set("v.isLimited",ret.isLimited);
                    component.set('v.applicant', ret.con);
                    if($A.util.isUndefinedOrNull(component.get('v.applicant').FinServ__Employment__r)){
                        component.set('v.employmentsList1', []);
                    }
                    else{
                        component.set('v.employmentsList1', component.get('v.applicant').FinServ__Employment__r);
                        var emp = component.get("v.employmentsList1");
                        if(!$A.util.isUndefinedOrNull(emp[0].FinServ__EmploymentStatus__c)){
                            component.set("v.employmentStatus1",emp[0].FinServ__EmploymentStatus__c);
                        }
                    }
                    this.doTotal(component,event);
                }
            }
            self.toggleSpinner(component, event);
            self.scrollTop(component, event, 70);
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
            self.scrollTop(component, event, 70);
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
            self.scrollTop(component, event, 70);
        });
        $A.enqueueAction(action);
    },
    doTotal : function(component, event) {
        var applicant = component.get("v.applicant");
        var total = 0;
        if(component.get("v.isLimited")==true){
            total += ($A.util.isUndefinedOrNull(applicant.Utilities__c) || applicant.Utilities__c == "") ? 0 : parseFloat( applicant.Utilities__c);    
            total += ($A.util.isUndefinedOrNull(applicant.Groceries_transport__c) || applicant.Groceries_transport__c == "") ? 0 : parseFloat( applicant.Groceries_transport__c);
            total += ($A.util.isUndefinedOrNull(applicant.Clothing_and_entertainment__c) || applicant.Clothing_and_entertainment__c == "") ? 0 : parseFloat( applicant.Clothing_and_entertainment__c);
            total += ($A.util.isUndefinedOrNull(applicant.Insurance_and_medical__c) || applicant.Insurance_and_medical__c == "") ? 0 : parseFloat( applicant.Insurance_and_medical__c);
            total += ($A.util.isUndefinedOrNull(applicant.Education_and_childcare__c) || applicant.Education_and_childcare__c == "") ? 0 : parseFloat( applicant.Education_and_childcare__c);
            total += ($A.util.isUndefinedOrNull(applicant.Other_Regular_Expenditure__c) || applicant.Other_Regular_Expenditure__c == "") ? 0 : parseFloat( applicant.Other_Regular_Expenditure__c);
        }
        else{
            total += ($A.util.isUndefinedOrNull(applicant.Utilities__c) || applicant.Utilities__c == "") ? 0 : parseFloat( applicant.Utilities__c); 
            total += ($A.util.isUndefinedOrNull(applicant.Investment_property_utilities__c) || applicant.Investment_property_utilities__c == "") ? 0 : parseFloat( applicant.Investment_property_utilities__c); 
            total += ($A.util.isUndefinedOrNull(applicant.Connections_Phone_Mobile_Internet_C__c) || applicant.Connections_Phone_Mobile_Internet_C__c == "") ? 0 : parseFloat( applicant.Connections_Phone_Mobile_Internet_C__c); 
            total += ($A.util.isUndefinedOrNull(applicant.Education_ChildCare_SchoolFees_Uniform__c) || applicant.Education_ChildCare_SchoolFees_Uniform__c == "") ? 0 : parseFloat( applicant.Education_ChildCare_SchoolFees_Uniform__c); 
            total += ($A.util.isUndefinedOrNull(applicant.Food_Groceries_Meat_Fruit_Vegetabl__c) || applicant.Food_Groceries_Meat_Fruit_Vegetabl__c == "") ? 0 : parseFloat( applicant.Food_Groceries_Meat_Fruit_Vegetabl__c); 
            total += ($A.util.isUndefinedOrNull(applicant.Clothing_and_personal_care__c) || applicant.Clothing_and_personal_care__c == "") ? 0 : parseFloat( applicant.Clothing_and_personal_care__c); 
            total += ($A.util.isUndefinedOrNull(applicant.Transport_Public_Petrol_Registration__c) || applicant.Transport_Public_Petrol_Registration__c == "") ? 0 : parseFloat( applicant.Transport_Public_Petrol_Registration__c); 
            total += ($A.util.isUndefinedOrNull(applicant.Medical_Private_Health_Insurance_Ong__c) || applicant.Medical_Private_Health_Insurance_Ong__c == "") ? 0 : parseFloat( applicant.Medical_Private_Health_Insurance_Ong__c); 
            total += ($A.util.isUndefinedOrNull(applicant.Entertainment_Dining_Out_Movies_Gift__c) || applicant.Entertainment_Dining_Out_Movies_Gift__c == "") ? 0 : parseFloat( applicant.Entertainment_Dining_Out_Movies_Gift__c); 
            total += ($A.util.isUndefinedOrNull(applicant.Gambling_Betting_and_Lottery__c) || applicant.Gambling_Betting_and_Lottery__c == "") ? 0 : parseFloat( applicant.Gambling_Betting_and_Lottery__c);
        }
        
        component.set("v.totalAmount", total);
        applicant.Total_Living_Expenses__c = total;
        component.set("v.applicant", applicant);
    },
    
    validateLivingExpenses: function(component) {
        var applicant = component.get("v.applicant");
        var hasErrors = false;
        var expenseFields = [
            "Utilities","Groceries","Clothing","Insurance"         
        ];
        var expensesFields2 = [
            "Utilities2","Insurance2","Connections2","Groceries2","Transport2","Medical2","Clothing2","Entertainment2","Gambling"
        ];
        
        if(component.get("v.isLimited")){
            for(var i=0;i<expenseFields.length;i++){
                var childCmp = component.find(expenseFields[i]);
                var retnMsg = childCmp.rangeSelectorValidate();
                if(!retnMsg){
                    hasErrors = true; 
                }
            }
        }
        else{
            for(var i=0;i<expensesFields2.length;i++){
                var childCmp = component.find(expensesFields2[i]);
                var retnMsg = childCmp.rangeSelectorValidate();
                if(!retnMsg){
                    hasErrors = true; 
                }
            }
        }
        return !hasErrors; 
    },
    
    checkLivingExpenses: function(component) {
        var self = this;
        var applicant = component.get("v.applicant");
        var totalAmount = component.get("v.totalAmount");
        var primaryIncomeSource = component.get("v.employmentStatus1");
        var Dependents = applicant.FinServ__NumberOfChildren__c;
        var hasErrors = false;
        
        if((applicant.FinServ__MaritalStatus__c == 'Married / defacto' && primaryIncomeSource == 'Pension') && (Dependents == 0)){
            if(totalAmount >= 1310){
                hasErrors = false;
            }
            else{
                var result = 1310 - totalAmount;
                var roundedResult = Math.ceil(result / 100) * 100;
                component.set("v.shortAmount",roundedResult);
                hasErrors = true;
            }
        }
        
        else if(applicant.FinServ__MaritalStatus__c == 'Married / defacto'){
            hasErrors = self.calculateAmount(component, event,totalAmount,Dependents,true);
        }
            else if(applicant.FinServ__MaritalStatus__c != 'Married / defacto'){
                hasErrors = self.calculateAmount(component, event,totalAmount,Dependents,false);
            }
        return !hasErrors;
    },
    
    calculateAmount: function (component, event,totalAmount,Dependents,isMarried){
        var hasErrors = false;
        var amountMap = new Map();
        if(isMarried){
            amountMap.set(0, 1661);
            amountMap.set(1, 2065);
            amountMap.set(2, 2469);
            amountMap.set(3, 2919);
            amountMap.set(4, 3271);
            amountMap.set(5, 3638);
        }
        else{
            amountMap.set(0, 1143);
            amountMap.set(1, 1569);
            amountMap.set(2, 1973);
            amountMap.set(3, 2376);
            amountMap.set(4, 2780);
            amountMap.set(5, 3186);
        }
        var minimumExpense = amountMap.get(Dependents);
        if(totalAmount >= minimumExpense){
            hasErrors = false;
        }
        else{
            var result = minimumExpense - totalAmount;
            var roundedResult = Math.ceil(result / 100) * 100;
            component.set("v.shortAmount",roundedResult);
            hasErrors = true;
        }
        return hasErrors;
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
})