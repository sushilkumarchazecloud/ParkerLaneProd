({
    submit : function(component, event, helper) {
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        if(allValid){
            component.set('v.showMessage', false);
            helper.toggleSpinner(component, event);
            helper.saveReferral(component, event);
        }else{
            component.set('v.showMessage', true);
            component.set('v.status', 'error');
            component.set('v.message', 'Error: Please update the form entries highlighted in red and try again.');
            
        }
        helper.scrollTop(component, event, 50);
	}
})