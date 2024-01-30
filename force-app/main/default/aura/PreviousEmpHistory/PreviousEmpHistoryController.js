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
        var index = component.get("v.index");
        if(index == 0){
            helper.setOccupation(component, event);

        }
    },
    
    checkEmployment : function(component, event, helper) {
		var checkEmpHistory = component.getEvent("monthYearChangeEvent");
        checkEmpHistory.setParams({"years" : component.get("v.years"),
                                   "months" : component.get("v.months"),
                                   "applicantNo" : component.get("v.applicantNo")});
        checkEmpHistory.fire();
    },
    
    deletePreEmp : function(component, event, helper) {
        var deleteEvent = component.getEvent("SolarDeleteRowEvent");
        deleteEvent.setParams({"indexVar" : component.get("v.index"),
                               "rowType" : "preEmpHistory" + component.get("v.applicantNo")});
        deleteEvent.fire();
    }, 
    
    occupationChanged: function(component, event, helper) {
        var index = component.get("v.index");
        if(index == 0){
            helper.setOccupation(component, event);
            component.set("v.incomeFrom", "");
        }
    },
    
    validatePreEmp : function(component, event, helper) {

        var isvalidate = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);

        return isvalidate;
    },
})