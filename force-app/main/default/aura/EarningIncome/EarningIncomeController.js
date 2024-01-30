({
    doInit : function(component, event, helper) {
        helper.setMonthsYearsHours(component, event);
        
        var index = component.get("v.index");
        var emp = component.get("v.emp");
        emp.Years__c = '' + emp.Years__c;
        emp.Months__c = '' + emp.Months__c;
        if(!$A.util.isUndefinedOrNull(emp.Minimum_hours_per_week__c)){
            emp.Minimum_hours_per_week__c = '' + emp.Minimum_hours_per_week__c;
        }
        
        if(index == 0){
            emp.Is_Primary__c = true;
            if(!$A.util.isUndefinedOrNull(emp.FinServ__EmploymentStatus__c) && emp.FinServ__EmploymentStatus__c != ''){
                var checkEmpHistory = component.getEvent("monthYearChangeEvent");
                checkEmpHistory.setParams({"years" : component.get("v.years"),
                                           "months" : component.get("v.months"),
                                           "applicantNo" : component.get("v.applicantNo")});
                checkEmpHistory.fire();
            }
            helper.setOccupation(component, event);
        }
        component.set("v.emp", emp);
    },
    
    occupationChanged: function(component, event, helper) {
        var index = component.get("v.index");
        if(index == 0){
            helper.setOccupation(component, event);
            component.set("v.emp.FinServ__EmploymentStatus__c", "");
        }
    },
    
    doValidate : function(component, event, helper) {

        var result = component.getEvent("validateResultCmpEvent");
        var appNo = event.getParam("applicantNo");
        var fieldcheck = component.find('fieldcheck');
        var inputField = component.find('fieldcheckIncome');
        var value = inputField.get('v.value');
        var isvalidate =false;
        if(value != 'foo') {
            inputField.set('v.validity', {valid:false, badInput :true});
            inputField.showHelpMessageIfInvalid();
            isvalidate =false;
        }
        
        if(!$A.util.isUndefinedOrNull(fieldcheck) && !$A.util.isUndefinedOrNull(fieldcheck.length)){
             isvalidate = fieldcheck.reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && !inputCmp.get('v.validity').valueMissing;
            }, true);
        
        }
        var addressTool = component.find("addressTool");
        var isvalidateAdd = true;
        if(!$A.util.isUndefinedOrNull(addressTool)){
            isvalidateAdd = addressTool.checkAddress();
        }
        var emp = component.get("v.emp");
        if(emp.Is_Find_Address__c && isvalidateAdd){
            var searchString = '';
            var unitNumber = emp.Unit_Number__c;
            var streetNumber = emp.Street_Number__c;
            var street = emp.Street__c;
            var streetType = emp.Street_Type__c;
            var suburb = emp.Suburb__c;
            var state = emp.State__c;
            var postalCode = emp.Postal_Code__c;
            var country = emp.Country__c;
            if(!$A.util.isUndefinedOrNull(unitNumber)){
                searchString = unitNumber + ' ';
            }
            searchString += streetNumber + ' ' + street + ' ' + streetType + ' ' + suburb + ' ' +
                state + ' ' + country + ' ' + postalCode;
            emp.FinServ__EmployerAddress__c = searchString;
            component.set("v.emp", emp);
        }
        
        result.setParams({"result" : isvalidate && isvalidateAdd});
        result.fire();
	},
    
    deleteIncome : function(component, event, helper) {
        var deleteEvent = component.getEvent("SolarDeleteRowEvent");
        deleteEvent.setParams({"indexVar" : component.get("v.index"),
                               "rowType" : "EarningIncome" + component.get("v.applicantNo")});
        deleteEvent.fire();
    }, 
   
    changeMonthYear : function(component, event, helper) {
        var indx = component.get("v.index");
        if(indx == 0){
            var checkEmpHistory = component.getEvent("monthYearChangeEvent");
            checkEmpHistory.setParams({"years" : component.get("v.years"),
                                       "months" : component.get("v.months"),
                                       "applicantNo" : component.get("v.applicantNo")});
            checkEmpHistory.fire();
        }
        
    },
    
    changePercentageBlur : function(component, event, helper) {
		var emp = component.get("v.emp");
        emp.Ownership_Share__c = emp.Ownership_Share__c/100;
        component.set("v.emp", emp);
    },
    changePercentageFocus : function(component, event, helper) {
        var emp = component.get("v.emp");
        emp.Ownership_Share__c = emp.Ownership_Share__c*100;
        component.set("v.emp", emp);
    },  
})