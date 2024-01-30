({
    doInit : function(component, event, helper) {
        helper.checkConditions(component, event, helper);
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
        var full_amt = component.get("v.fundsRemaining");
        var part_amt = component.get("v.partPaymentAmt");  
        
        if(full_amt != null && part_amt > full_amt && part_amt != null ){
            component.set("v.partPmtError",true);
        }
        else{
            component.set("v.partPmtError",false);
        }
    },
    
    invoiceOnchange : function (component, event, helper) {
        var fund_available = component.get("v.opp.SyncedQuote.Customer_Amount__c");
        var invoiceAmount = component.get("v.invoiceAmount");
        var comboOBoxptions = component.get("v.comboOBoxptions");
        if (invoiceAmount > fund_available) {
            // Check if "Variation" option already exists in the options
            var variationExists = comboOBoxptions.some(function (option) {
                return option.value === "Variation";
            });
            
            if (!variationExists) {
                // Add "Variation" option to comboOBoxptions
                comboOBoxptions.push({ label: "Variation", value: "Variation" });
                component.set("v.comboOBoxptions", comboOBoxptions);
            }
        } 
        else {
            // Remove "Variation" option from comboOBoxptions
            var updatedOptions = comboOBoxptions.filter(function (option) {
                return option.value !== "Variation";
            });
            component.set("v.comboOBoxptions", updatedOptions);
        }
    },
    
    reqByOnChange : function (component, event, helper) {
        var req_by = component.get("v.requestBy");
        var PersonRquestingOptions = component.get("v.PersonRquestingOptions");
        var app2 = component.get("v.opp.Applicant_2__c");
         if(req_by == 'Customer'){
            // Check if "Applicants" option already exists in the options
            if(app2 != null){
                var ApplicantsExists = PersonRquestingOptions.some(function (option) {
                    return option.value === "Applicant 1" && "Applicant 2";
                });
                
                if(!ApplicantsExists){
                    PersonRquestingOptions.push({ label: "Applicant 1", value: "Applicant 1" },
                                                { label: "Applicant 2", value: "Applicant 2" });
                    component.set("v.PersonRquestingOptions", PersonRquestingOptions);  
                }
            }
            else{
               var ApplicantsExists = PersonRquestingOptions.some(function (option) {
                    return option.value === "Applicant 1";
                });
                
                if(!ApplicantsExists){
                    PersonRquestingOptions.push({ label: "Applicant 1", value: "Applicant 1" });
                    component.set("v.PersonRquestingOptions", PersonRquestingOptions);  
                } 
            }
            // Remove "Referrer" option from comboOBoxptions
             var updatedOptions = PersonRquestingOptions.filter(function (option) {
                return option.value !== "Referrer";
            });
            component.set("v.PersonRquestingOptions", updatedOptions);
        }
        else if (req_by == 'Supplier') {
            // Check if "Referrer" option already exists in the options
            var ref_valNotExists = PersonRquestingOptions.some(function (option) {
                return option.value === "Referrer";
            });
            
            if(!ref_valNotExists){
                PersonRquestingOptions.push({ label: "Referrer", value: "Referrer" });
                component.set("v.PersonRquestingOptions", PersonRquestingOptions);  
            }
            
            // Remove "Applicants" option from comboOBoxptions
            var updatedOptions = PersonRquestingOptions.filter(function (option) {
                return option.value !== "Applicant 1" && option.value !== "Applicant 2";
            });
            component.set("v.PersonRquestingOptions", updatedOptions);
        } 
    },
})