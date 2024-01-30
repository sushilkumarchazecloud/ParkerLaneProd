({
    afterScriptsLoaded : function(component, event, helper){
        helper.getStages(component, event);
    }, 
    /*
    stageChange: function(component, event, helper){
        component.set("v.isStagesChange", false);
        helper.toggleSpinner(component, event);
        helper.doInit(component,event,helper);
    }, */
    
    filterChange: function(component, event, helper){
        /*var stage = [];
        component.set("v.selectedStageName",stage);
        component.set("v.isStagesChange", true);*/
        helper.toggleSpinner(component, event);
        helper.doInit(component,event,helper);
    }, 
})