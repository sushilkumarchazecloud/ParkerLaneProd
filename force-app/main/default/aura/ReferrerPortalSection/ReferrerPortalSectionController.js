({
    navHome : function(component, event, helper) {
        component.set("v.navSection", "Home");
        component.set("v.ShowAccount", false);
    },
    
    navRequestQuote : function(component, event, helper) {
        component.set("v.navSection", "RequestQuote");
        component.set("v.ShowAccount", false);
    },
    
    navMyReferrals : function(component, event, helper) {
        component.set("v.navSection", "MyReferrals");
        component.set("v.ShowAccount", false);
    },
    
    navMyTeam : function(component, event, helper) {
        component.set("v.navSection", "MyTeam");
        component.set("v.ShowAccount", false);
    },
    
    navToDo : function(component, event, helper) {
        component.set("v.navSection", "ToDo");
    },
    
    navMyAccount : function(component, event, helper) {
        component.set("v.navSection", "MyAccount");
        component.set("v.ShowAccount", false);
    },
    
    myAction : function(component, event, helper) {
        helper.getdeclarationmodel(component, event);        
        helper.getContactData(component, event);
 
    },
})