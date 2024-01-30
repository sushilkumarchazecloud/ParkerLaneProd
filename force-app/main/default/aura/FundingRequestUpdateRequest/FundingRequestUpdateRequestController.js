({
    doInit : function(component, event, helper) {
        helper.getFunding(component, event, helper);
    }, 
    
    Cancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    handleSave : function(component, event, helper) {
        var remainderrequest = component.get("v.remainderRequest");
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing && inputCmp.checkValidity();
        }, true);
        if(allValid){
            if(remainderrequest){
                cmbBoxVal = component.get("v.remainderComboValue");
                var part_amt_Error = component.get("v.partPmtError");
                if(!part_amt_Error){
                    helper.Submit(component, event, helper, cmbBoxVal);
                }     
            }
            else{
                var cmbBoxVal = component.get("v.comboBoxValue");
                helper.Submit(component, event, helper, cmbBoxVal);
            }
        }
    },
    
    Errors : function(component, event, helper) {
        helper.partpaymentError(component, event, helper);
    },
    
    invoiceOnchange : function (component, event, helper) {
        helper.inVoiceChange(component, event, helper);
    },
    
})