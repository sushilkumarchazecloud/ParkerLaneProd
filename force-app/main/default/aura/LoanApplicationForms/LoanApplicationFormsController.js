({
    doInit : function(component, event, helper) {
        let recordId = component.get("v.recordId");
        helper.toggleSpinner(component, event);
        helper.getOppContacts(component, event, recordId);
        helper.scrollTop(component, event, 0);
    },
    
    letsBegin : function(component, event, helper) {
        var applicant1 = component.get("v.applicant1");
        var applicant2 = component.get("v.applicant2");
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        
        var validity = true;
        var emailField = component.find("fieldcheckemail");
        if(!$A.util.isUndefinedOrNull(emailField) && $A.util.isUndefinedOrNull(applicant2.Id)){
            var fValidity = emailField.get("v.validity");
            validity = fValidity.valid;
            emailField.reportValidity();
        }
        
        component.set("v.showError",!(allValid && validity));
        if (allValid && validity) {
            
            var opp = component.get("v.opportunity");
            var selectedPerson = component.get("v.selectedPerson");

            if(selectedPerson == 'joint' && !$A.util.isUndefinedOrNull(opp) ){

                if(opp.Relationship_to_Applicant_2__c === 'Spouse'){
                    applicant1.MaritalStatus__c = 'Married / Defacto (to applicant 2)';
                    applicant2.MaritalStatus__c = 'Married / Defacto (to applicant 1)';
                    component.set("v.applicant1",applicant1);
                    component.set("v.applicant2",applicant2);
                }
            }
            if(selectedPerson == 'joint' && applicant1.Email == applicant2.Email){
                emailField.setCustomValidity("Cannot be same as Applicant 1");
                emailField.reportValidity();
                component.set("v.showError",true);
                component.set("v.errorMsg","For verification purposes, Applicant 1 and Applicant 2 can not have the same email address");
                helper.scrollTop(component, event, 315);
            }else{
                component.set("v.showError",false);
                if(!$A.util.isUndefinedOrNull(emailField) && $A.util.isUndefinedOrNull(applicant2.Id)){
                    emailField.setCustomValidity("");
                    emailField.reportValidity();
                }
                helper.toggleSpinner(component, event);
                helper.checkExistingCustomer(component, event);
            }
            
        } else{
            component.set("v.errorMsg","Please update the form entries highlighted in red and try again");
        }
        
        helper.scrollTop(component, event, 315);
    },
    
    save : function(component, event, helper) {
        var AboutApplicantForm = component.find("AboutApplicantForm");
        var isvalidate = AboutApplicantForm.checkAboutApp();
        var applicantGrpValue = component.get("v.applicantGrpValue");
        var selectedPerson = component.get("v.selectedPerson");
        component.set("v.showError",!isvalidate);
        if (isvalidate) {
            if(applicantGrpValue== 'applicant1' && selectedPerson == 'joint'){
                component.set("v.applicantGrpValue","applicant2");
            }else{
                helper.toggleSpinner(component, event);
                helper.upsertOppCons(component, event, true, false);
            }
        }else{
            component.set("v.errorMsg","Please update the form entries highlighted in red and try again");
        }
        helper.scrollTop(component, event, 315);
    },
    
    saveApplications : function(component, event, helper) {
        var args = event.getParam("arguments");
        var isShare = args.isShare;
        var isNext = args.isNext;
        
        var cTab = component.get("v.selectedTab");
        var isvalidate =true;
        if(cTab =='AboutFormTab'){
            var AboutApplicantForm = component.find("AboutApplicantForm");
            //isvalidate = AboutApplicantForm.checkAboutApp();
        }else{
            isvalidate = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && !inputCmp.get('v.validity').valueMissing;
            }, true);
        }
        
        component.set("v.showError",!isvalidate);
        if (isvalidate) {
            helper.toggleSpinner(component, event);
            helper.upsertOppCons(component, event, isNext, isShare);
        }else{
            component.set("v.errorMsg","Please update the form entries highlighted in red and try again");
        }
        helper.scrollTop(component, event, 315);
    },
    prev : function(component, event, helper) {
        component.set("v.applicantGrpValue","applicant1");
        helper.scrollTop(component, event, 315);
    },
})