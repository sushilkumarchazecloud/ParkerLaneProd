({
    navHome : function(component, event, helper) {
        component.set("v.navSection", "Home");
    },
    
    navMyReferrals : function(component, event, helper) {
        component.set("v.navSection", "MySettlements");
    },
    
    navMyTeam : function(component, event, helper) {
        component.set("v.navSection", "MyTeam");
    },
    
    navToDo : function(component, event, helper) {
        component.set("v.navSection", "ToDo");
    },
    
    navMyAccount : function(component, event, helper) {
        component.set("v.navSection", "MyAccount");
    },
    
    myAction : function(component, event, helper) {
        //helper.getdeclarationmodel(component, event);        
        helper.getContactData(component, event);
 
    },
})