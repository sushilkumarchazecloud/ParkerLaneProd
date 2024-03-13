({
    doInit : function(component, event, helper) {
        var applicant1Name = component.get("v.applicant1Name");
        var applicant2Name = component.get("v.applicant2Name");
        var applicant2 = component.get("v.applicant2");
        
       
        component.set("v.appRelationship", component.get("v.relationship"));
        var ops = [];
        ops.push({ label: applicant1Name, value: "applicant1"});
        ops.push({ label: applicant2Name, value: "applicant2"});
        component.set("v.applicantNameOptions",ops);
        helper.scrollTop(component, event);
    },
    
    handleChange : function(component, event, helper) {
        var applicantGrpValue = component.get("v.applicantGrpValue");
        var applicant1 = component.find('applicant1details');
        var applicant2 = component.find('applicant2details');
        if(applicantGrpValue == 'applicant1'){
            $A.util.removeClass(applicant1, 'slds-hide');
            $A.util.addClass(applicant2, 'slds-hide');
        }else if(applicantGrpValue == 'applicant2'){
            $A.util.removeClass(applicant2, 'slds-hide');
            $A.util.addClass(applicant1, 'slds-hide');
        }
        helper.scrollTop(component, event);
    },
    
    checkAboutApp : function(component, event, helper) {
        var selectedApp = component.get("v.applicantGrpValue");
        var applicantDetail;
         console.log('..............................');
        if(selectedApp == 'applicant1'){
            applicantDetail = component.find("applicant1detail");
        }else if(selectedApp == 'applicant2'){
            //applicantDetail = component.find("applicant2detail");
            applicantDetail = component.find("applicant1detail");
        }
        var isvalidate = applicantDetail.checkAboutDetails();
        console.log('..............................');
        component.set("v.showErrorOnApplicant",!isvalidate);
        return isvalidate;
    },
    relationshipChange: function(component, event, helper) {
        var appRelationship = component.get('v.appRelationship');
        var selectedPerson = component.get('v.selectedPerson');
        
        var appNo = appRelationship.split('----')[0];
        
        var applicant1 = component.get('v.applicant1');
        var applicant2 = component.get('v.applicant2');

        if(!$A.util.isUndefinedOrNull(appRelationship) && appNo == '1' && selectedPerson == 'joint'){    
            if(!$A.util.isUndefinedOrNull(applicant1.MaritalStatus__c) && 
               applicant1.MaritalStatus__c == 'Married / Defacto (to applicant 2)'){
                
                applicant2.MaritalStatus__c = 'Married / Defacto (to applicant 1)';
            }else if(!$A.util.isUndefinedOrNull(applicant1.MaritalStatus__c) && 
                     !$A.util.isUndefinedOrNull(applicant2.MaritalStatus__c) && 
                     applicant1.MaritalStatus__c != 'Married / Defacto (to applicant 2)' &&
                     applicant2.MaritalStatus__c == 'Married / Defacto (to applicant 1)'){
                
                applicant2.MaritalStatus__c = '';
            }
        }else if(appNo == '2'){
            if(!$A.util.isUndefinedOrNull(applicant1.MaritalStatus__c) && 
               !$A.util.isUndefinedOrNull(applicant2.MaritalStatus__c) &&
               applicant1.MaritalStatus__c != 'Married / Defacto (to applicant 2)' &&
               applicant2.MaritalStatus__c == 'Married / Defacto (to applicant 1)'){
				
                applicant2.MaritalStatus__c = '';
                component.set('v.showError',true);
                helper.scrollTop(component, event);
            }else{

                component.set('v.showError',false);
            }
        }else{
            component.set('v.showError',false);
        }
        
        component.set('v.applicant2', applicant2);
    }
    
})