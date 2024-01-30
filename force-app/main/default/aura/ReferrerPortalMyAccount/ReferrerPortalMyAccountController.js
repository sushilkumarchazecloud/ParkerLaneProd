({
    doInIt : function(component, event, helper) {
        helper.getContactData(component, event);
    },
    
    tncChange : function(component, event, helper) {
        var opt1 = component.get("v.opt1");
        var opt2 = component.get("v.opt2");
        var opt3 = component.get("v.opt3");
        if(opt1 && opt2 && opt3){
            component.set("v.isDeclarationBtnDisabled", false);
        }else{
            component.set("v.isDeclarationBtnDisabled", true);
        }
    }, 
    
    submitDeclaration : function(component, event, helper) {
      //  helper.submitDec(component, event);
    },
    
    
    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
    
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    }
})