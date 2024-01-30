({
    doInit : function(component, event, helper) {
        helper.ShowEditButtons(component, event, helper);
    },
    
    editModal : function(component, event, helper) {
        component.set("v.ishide",false);
        component.set("v.isSaveBtnDisabled",false);
    },
    
    InstalleditModal : function(component, event, helper) {
        component.set("v.InstallEdit",false);  
        component.set("v.isSaveBtnDisabled",false);
    },
    
    saveModal : function(component, event, helper) {
        component.set("v.showSpinner",true);
        var oppDetails = component.get("v.oppWrapper");
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing && inputCmp.checkValidity();
        }, true);
        component.set("v.showError",!(allValid));
        if(allValid){
            var action = component.get("c.SaveOpportunityOnMyReferralCard");
            action.setParams({ opp : oppDetails});
            action.setCallback(this, function(response) {
                var state = response.getState();          
                if (state === "SUCCESS") {  
                    alert('Successfully Saved');
                    var ret = response.getReturnValue();
                    component.set("v.oppWrapper",ret);
                    
                    var Name = component.get("v.oppWrapper.Name")
                    if(Name){
                        var OppName = Name.split(',');
                        component.set("v.OpportunityName",OppName[0]); 
                    } 
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } 
                } 
                component.set("v.showSpinner",false);
            });
            $A.enqueueAction(action);
            component.set("v.ishide",true);
            component.set("v.isSaveBtnDisabled",true);
        }
        else{
            component.set("v.showSpinner",false);
            component.set("v.errorMsg","Please update the form entries highlighted in red and try again"); 
        }
    },
    
    SaveAddress : function(component, event, helper){
        component.set("v.showSpinner",true);
        var oppp = component.get("v.oppWrapper");
        var addressVal = component.get("v.searchString");
        var action = component.get("c.SaveAddressOnOpp"); 
        action.setParams({
            opp : oppp,                          
            address : addressVal,
            custEmail : component.get('v.oppWrapper.Applicant_1_Email__c'),
            street: component.get('v.street'),
            postalCode: component.get('v.postalCode'),
            suburb: component.get('v.suburb'),
            country: component.get('v.country'),
            state: component.get('v.state'),
            streetNumber: component.get('v.streetNumber'),
            streetType: component.get('v.streetType') 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();          
            if (state === "SUCCESS") {  
                var ret = response.getReturnValue();
                component.set("v.oppWrapper",ret);
                component.set("v.searchString",ret.installationAddressLineOne__c);
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
        component.set("v.InstallEdit",true);
        component.set("v.isSaveBtnDisabled",true);
    },
    
    
})