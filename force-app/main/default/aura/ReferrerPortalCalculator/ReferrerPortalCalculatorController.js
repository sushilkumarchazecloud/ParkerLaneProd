({  
    doInit : function(component, event, helper) {
       component.set("v.spinner", true);
        setTimeout(function() {
            component.set("v.spinner", false);
        }, 2000); 
    },
  
    onEnterSearch : function(component, event, helper){
        if(event.which == 13 ){
            component.set("v.navSection",'MyReferrals');
        }
    },
    
    onChangeSearch : function(component, event, helper){
        var searchvalue = component.find("enter-search").get("v.value");        
        component.set('v.searchKeyword', searchvalue);
        if(searchvalue.length > 0){
            component.set("v.stopItrt",true);
            helper.getRet(component, event);
        }
        else{
            component.set("v.stopItrt",false);
        }
    },
    
})