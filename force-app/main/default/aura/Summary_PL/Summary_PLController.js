({
    doInit : function (component, event, helper){
        helper.toggleSpinner(component, event);
        helper.getSummaryDetail(component, event);
    },
    
    saveSummary : function (component, event, helper){
        helper.toggleSpinner(component, event);
        helper.updateSummaryPage(component, event);
    },
    
    uploadManually : function (component, event, helper){
        helper.toggleSpinner(component, event);
        helper.updateManually(component, event);
    },
    
    changeStateQuesion1 : function(component, event, helper) {
        helper.changeState(component,event,"WhatDoesPre",1);
    },
    
    changeStateQuesion2 : function(component, event, helper) {
        helper.changeState(component,event,"WhatisMogo",2);
    }
})