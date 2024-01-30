({
    doInit : function (component, event, helper){
        helper.toggleSpinner(component, event);
        helper.getSummaryDetail(component, event);
        var url = $A.get("$Label.c.bankStatementRedirectURL") + component.get("v.recordId"); 
        component.set("v.bankURL",url);
    },
    
    saveSummary : function (component, event, helper){
        helper.toggleSpinner(component, event);
        
        //helper.updateSummaryPage(component, event);
    },
    
    uploadManually : function (component, event, helper){
        helper.toggleSpinner(component, event);
        helper.updateManually(component, event);
        //helper.updateSummaryPage(component, event);
    },
    
    changeStateQuesion1 : function(component, event, helper) {
        helper.changeState(component,event,"WhatDoesPre",1);
    },
    
    changeStateQuesion2 : function(component, event, helper) {
        helper.changeState(component,event,"WhatisMogo",2);
    },
    
    updateSumary : function(component, event, helper){
        var url = component.get("v.bankURL");
        window.location = url;
        //alert('in');
        /*helper.toggleSpinner(component, event);
        var action = component.get("c.updateForBankStmnt");
        var oppId = component.get('v.recordId');
        
        action.setParams({
            oppId : oppId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('@@@@' + JSON.stringify(response));
            if (state === "SUCCESS") {
                var url = component.get("v.bankURL");
                window.location = url;
            }            
        });
        $A.enqueueAction(action);*/
    }
})