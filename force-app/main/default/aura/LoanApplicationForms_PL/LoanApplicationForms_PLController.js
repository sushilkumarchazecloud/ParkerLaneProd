({
    doInit : function(component, event, helper) {
        let recordId = component.get("v.recordId");
        helper.toggleSpinner(component, event);
        helper.getOppContacts(component, event, recordId);
        helper.scrollTop(component, event, 70);
        var highlight = component.find('changeIt');
        $A.util.addClass(highlight, 'customclass');
        
        
    },
    
    letsBegin : function(component, event, helper) {
        var applicant1 = component.get("v.applicant1");
        var applicant2 = component.get("v.applicant2");
        var opp = component.get("v.opportunity");
        
        var selectedPerson = component.get("v.selectedPerson");
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);

        var validity = true;
        var emailField = component.find("fieldcheckemail");
        if(!$A.util.isUndefinedOrNull(emailField) && $A.util.isUndefinedOrNull(applicant2.Id)){
           	emailField.setCustomValidity(""); 
            var fValidity = emailField.get("v.validity");
            validity = fValidity.valid;
            emailField.reportValidity();
        }
        
        var isSamehouseHold = true;
        if(opp.Do_you_both_live_at_the_same_address__c == "No" && selectedPerson == 'joint' && opp.Relationship_to_Applicant_2__c != 'Spouse'){
            isSamehouseHold = false;
        }
     
        component.set("v.showError",!(allValid && validity && isSamehouseHold));
        if (allValid && validity && isSamehouseHold) {
            if(selectedPerson == 'joint' && !$A.util.isUndefinedOrNull(opp) ){

                if(opp.Relationship_to_Applicant_2__c === 'Spouse'){
                    applicant1.FinServ__MaritalStatus__c = 'Married / Defacto (to applicant 2)';
                    applicant2.FinServ__MaritalStatus__c = 'Married / Defacto (to applicant 1)';
                    component.set("v.applicant1",applicant1);
                    component.set("v.applicant2",applicant2);
                }
            }
            if(applicant1.Phone.substring(0, 2) != '04' || (selectedPerson == 'joint' && applicant2.Phone.substring(0, 2) != '04')){
                component.set("v.showError",true);
                component.set("v.errorMsg","Please check Applicant 1 and/or Applicant 2 phone number, it should start with 04");
                helper.scrollTop(component, event, 70);
            }else if(selectedPerson == 'joint' && applicant1.Email == applicant2.Email){
                emailField.setCustomValidity("Can not be same as Applicant 1");
                emailField.reportValidity();
                component.set("v.showError",true);
                component.set("v.errorMsg","For verification purposes, Applicant 1 and Applicant 2 can not have the same email address");
                helper.scrollTop(component, event, 70);
            }else{
                component.set("v.showError",false);
                if(!$A.util.isUndefinedOrNull(emailField) && $A.util.isUndefinedOrNull(applicant2.Id)){
                    emailField.setCustomValidity("");
                    emailField.reportValidity();
                }
                helper.toggleSpinner(component, event);	
                helper.checkExistingCustomer(component, event);
                //Added By Pawan.
                helper.getUpdatedQuote(component, event, helper);
                //Pawan Code End.
            }
            
        } else{
            component.set("v.errorMsg","Please update the form entries highlighted in red and try again");
        }
        
        helper.scrollTop(component, event, 70);
    },
    
    verifyApp1Email: function(component, event, helper) {
        var applicant = component.get("v.applicant1");
    	component.set("v.isShowOTPValidator",true);
        component.set("v.applicantIdForVerification",applicant.Id);
        component.set("v.applicantEmailForVerification",applicant.Email);
        component.set("v.applicantNoForVerification","1");
    },
    
    verifyApp2Email: function(component, event, helper) {
        var applicant = component.get("v.applicant2");
    	component.set("v.isShowOTPValidator",true);
        component.set("v.applicantIdForVerification",applicant.Id);
        component.set("v.applicantEmailForVerification",applicant.Email);
        component.set("v.applicantNoForVerification","2");
    },
    

    save : function(component, event, helper) {
        var AboutApplicantForm = component.find("AboutApplicantForm");
        var isvalidate = AboutApplicantForm.checkAboutApp();
        var applicantGrpValue = component.get("v.applicantGrpValue");
        var selectedPerson = component.get("v.selectedPerson");
        component.set("v.showError",!isvalidate);
        if (isvalidate) {
            helper.toggleSpinner(component, event);
            helper.upsertOppCons(component, event, true, false);
        }else{
            component.set("v.errorMsg","Please update the form entries highlighted in red and try again");
        }
        helper.scrollTop(component, event, 70);
    },
    
    saveApplications : function(component, event, helper) {
        var args = event.getParam("arguments");
        var isShare = args.isShare;
        var isNext = args.isNext;
        
        var cTab = component.get("v.selectedTab");
        var isvalidate =true;
        if(cTab =='AboutFormTab'){
            var AboutApplicantForm = component.find("AboutApplicantForm");

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
        helper.scrollTop(component, event, 70);
    },
    prev : function(component, event, helper) {
        component.set("v.applicantGrpValue","applicant1");
        helper.scrollTop(component, event, 70);
    },
    removeEfect:function(component, event, helper){
        
        var highlight = component.find('changeIt');
        $A.util.removeClass(highlight, 'customclass');
        
    }
})