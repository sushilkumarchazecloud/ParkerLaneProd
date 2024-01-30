({
    doInit : function(component, event, helper) {
        helper.setMonthsYearsHours(component, event);
        
        var index = component.get("v.index");
        var emp = component.get("v.emp");
        emp.Years__c = '' + emp.Years__c;
        if(emp.Months__c=='6' || emp.Months__c==6){
            emp.Years__c = '' + emp.Months__c;
        }
        emp.Months__c = '' + emp.Months__c;
        var applicant = component.get("v.applicant");
        if(!$A.util.isUndefinedOrNull(applicant.FinServ__NumberOfChildren__c ) && applicant.FinServ__NumberOfChildren__c >0){
            helper.onChangeDependent(component, event);
            applicant.FinServ__NumberOfChildren__c = ''+ applicant.FinServ__NumberOfChildren__c;
            component.set("v.applicant", applicant);
        }
        
        if(!$A.util.isUndefinedOrNull(emp.Minimum_hours_per_week__c)){
            emp.Minimum_hours_per_week__c = '' + emp.Minimum_hours_per_week__c;
        }
        
        if(emp.FinServ__EmploymentStatus__c == ''){
            component.set("v.IsShowAnotherIncome",false);
        }else{
            component.set("v.IsShowAnotherIncome",true);
        }
        component.set("v.emp", emp);
    },
    
    primaryIncomeChanged: function(component, event, helper) {
        var index = component.get("v.index");
        if(index == 0){

            var IsShowAnotherIncome = component.get("v.IsShowAnotherIncome");
            var employment = component.get("v.emp");
            if(employment.FinServ__EmploymentStatus__c == ''){
                component.set("v.IsShowAnotherIncome",false);
            }else{
                component.set("v.IsShowAnotherIncome",true);
            }
        }
    },
    occupationChanged: function(component, event, helper) {
        var index = component.get("v.index");
        if(index == 0){
            helper.setOccupation(component, event);
            component.set("v.emp.FinServ__EmploymentStatus__c", "");
        }
    },
    
    doValidate : function(component, event, helper) {
        var index = component.get("v.index");
        var result = component.getEvent("validateResultCmpEvent");
        var appNo = event.getParam("applicantNo");
        var fieldcheck = component.find('fieldcheck');
        var isvalidate =false;
        var childAgeListedorNot = true;
        var employment = component.get("v.emp");
        var applicant = component.get("v.applicant");
        var applicantChildren = component.get("v.applicantChildren");
        
        if(employment.FinServ__EmploymentStatus__c == 'Family Tax Benefits'){
            if(applicantChildren.length==0){
                childAgeListedorNot = false;
            }
        }
        
        if(index==0){
            var inputField = component.find('fieldcheckIncome');
            var value = inputField.get('v.value');
            if(value != 'foo') {
                inputField.set('v.validity', {valid:false, badInput :true});
                inputField.showHelpMessageIfInvalid();
                isvalidate =false;
            }
        }
        
        if(!$A.util.isUndefinedOrNull(fieldcheck) && !$A.util.isUndefinedOrNull(fieldcheck.length)){
             isvalidate = fieldcheck.reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && !inputCmp.get('v.validity').valueMissing;
            }, true);
        
        }
        var addressTool = component.find("addressTool");
        var isvalidateAdd = true;
        if(!$A.util.isEmpty(addressTool)){
        if (typeof addressTool.checkAddress !== "undefined") { 
            //
                isvalidateAdd = addressTool.checkAddress();
            }
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
        
        result.setParams({"result" : isvalidate && isvalidateAdd && childAgeListedorNot});
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
            if(component.get("v.emp.Years__c") > '0' || component.get("v.emp.Years__c") > 0){
                var checkEmpHistory = component.getEvent("monthYearChangeEvent");
                checkEmpHistory.setParams({"years" : component.get("v.years"),
                                           "months" : component.get("v.months"),
                                           "applicantNo" : component.get("v.applicantNo")});
                checkEmpHistory.fire();
            }
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
    
    changeDependent: function(component, event,helper) {
        helper.onChangeDependent(component, event);
    },
    sameAddressAsApplicant : function(component,event,helper){
        //var sameAshomeAddress = component.get("v.sameAshomeAddress");
        var emp = component.get("v.emp");
        var applicant = component.get("v.applicant");/*Is_Address_Same__c*/

        if(emp.Same_as_home_address__c){
     
            emp.Is_Find_Address__c = applicant.Is_Find_Address__c;
            //emp.Residential_Address__c = applicant.Residential_Address__c;
            emp.Unit_Number__c = applicant.Unit_Number__c;
            emp.Street_Number__c = applicant.Street_Number__c;
            emp.Street__c = applicant.Street__c;
            emp.Street_Type__c = applicant.Street_Type__c;
            emp.Suburb__c = applicant.Suburb__c;
            emp.State__c = applicant.State__c;
            emp.Postal_Code__c = applicant.Postal_Code__c;
            emp.Country__c = applicant.FinServ__CountryOfResidence__c;
            
            emp.FinServ__EmployerAddress__c = applicant.Residential_Address__c;
            component.set("v.emp", emp);
            
        }else{
            emp.Is_Find_Address__c = false;
            emp.Residential_Address__c = "";
            emp.Unit_Number__c = "";
            emp.Street_Number__c = "";
            emp.Street__c = "";
            emp.Street_Type__c = "";
            emp.Suburb__c = "";
            emp.State__c = "";
            emp.Postal_Code__c = "";
            emp.Country__c = "";
            
            emp.FinServ__EmployerAddress__c = null;
            component.set("v.emp", emp);
        }
        
    }
})