({
	validateLoanPurpose : function(component, event, helper) {
		var isvalidate =false;
        var fieldcheck = component.find('fieldcheck');
        /*var inputField = component.find('fieldcheckType');
        var value = inputField.get('v.value');
        
        if(value != 'foo') {
            inputField.set('v.validity', {valid:false, badInput :true});
            inputField.showHelpMessageIfInvalid();
            isvalidate =false;
        }*/
        
        if(!$A.util.isUndefinedOrNull(fieldcheck) && !$A.util.isUndefinedOrNull(fieldcheck.length)){
             isvalidate = fieldcheck.reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && !inputCmp.get('v.validity').valueMissing;
            }, true);
        
        }

        component.set("v.showError",!isvalidate);
        component.set("v.errorMsg", "Please update the form entries highlighted in red and try again");
        
        return isvalidate;
    },
})