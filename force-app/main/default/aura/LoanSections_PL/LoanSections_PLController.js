({
    doInit : function(component, event, helper) {    
        var recordId =component.get("v.recordId");
        if(recordId=='' || recordId==null){
            component.set("v.applicationSection","Priorities");
        }else{
            helper.getSelPerson(component, event);
			helper.getSectionStatus(component, event, recordId);  
            helper.getOppRec(component, event, recordId);
        }
        var applicationSection = component.get("v.applicationSection");
        if(applicationSection === 'Getting Started'){
            component.set('v.isShowPreFor', true);
        }else{
            component.set('v.isShowPreFor', false);
        }
    },
    
    changePath: function(component, event, helper) {
        var selectedPath = event.getParam("selectedPath");
        var recordId =component.get("v.recordId");
        helper.toggleSpinner(component, event);
        helper.setSelectedSections(component, event, recordId, selectedPath);

    },
    
    SaveApplication : function(component, event, helper) {
        helper.saveAndShareApplication(component, event, true);
    },
    
    SendEmail: function(component, event, helper) {
        var recordId =component.get("v.recordId");
        var email =component.get("v.email");
        var emailDetail =component.get("v.emailDetail");

         var allValid = component.find('emailfieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);

        if (allValid){
            helper.shareAppByEmail(component, event, recordId, email, emailDetail);
            component.set("v.isShowEmail", false );
        }
        
    },
    
    SendEmailPopup: function(component, event, helper) {
        component.set("v.isShowEmail", true );
    },
    
    closeEmailPopup: function(component, event, helper) {
        component.set("v.isShowEmail", false );
    }
    
})