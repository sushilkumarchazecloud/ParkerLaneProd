({
    doInit : function(component, event, helper) {
        var months = [];
        var years = [];
        
        for (var i = 0; i <=12; i++) {
            var month = {
                "label": i.toString(),
                "value": i.toString(),
            };
            months.push(month);
        }
        component.set("v.monthsOptions", months);
        
        for (var i = 0; i <=25; i++) {
            var year = {
                "label": i.toString(),
                "value": i.toString(),
            };
            years.push(year);
        }
        component.set("v.yearsOptions", years);	
    },
    checkAddress : function(component, event, helper) {
		var checkEmpHistory = component.getEvent("monthYearChangeEvent");
        checkEmpHistory.setParams({"years" : component.get("v.years"),
                                  "months" : component.get("v.months")});
        checkEmpHistory.fire();
    },
    
    checkDetailsAddress : function(component, event, helper) {

        var isFindAdd = component.get("v.isFindAdd");
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        
        var addressTool = component.find("addressTool");
        var isvalidate = addressTool.checkAddress();
        if(isFindAdd && isvalidate){
            var searchString = '';
            var unitNumber = component.get("v.unitNumber");
            var streetNumber = component.get("v.streetNumber");
            var street = component.get("v.street");
            var streetType = component.get("v.streetType");
            var suburb = component.get("v.suburb");
            var state = component.get("v.state");
            var postalCode = component.get("v.postalCode");
            var country = component.get("v.country");
            if(!$A.util.isUndefinedOrNull(unitNumber)){
                searchString = unitNumber + ' ';
            }
            searchString += streetNumber + ' ' + street + ' ' + streetType + ' ' + suburb + ' ' +
                state + ' ' + country + ' ' + postalCode;
            component.set("v.searchString", searchString);
        }

        return allValid && isvalidate;
    },
    
    deletePreEmp : function(component, event, helper) {
        var deleteEvent = component.getEvent("SolarDeleteRowEvent");
        deleteEvent.setParams({"indexVar" : component.get("v.index"),
                               "rowType" : "applicantAddress"});
        deleteEvent.fire();
    }, 
    
})