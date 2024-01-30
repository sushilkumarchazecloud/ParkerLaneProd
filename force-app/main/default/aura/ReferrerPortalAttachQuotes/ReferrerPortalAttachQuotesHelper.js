({
    newQtList : function(component, event) {        
        var action = component.get("c.ret");
        action.setCallback(this,function(response){
            var records = response.getReturnValue();
            component.set('v.quoteDetailWrpList', records);
        });
        $A.enqueueAction(action);
    },
    
    groupQuotes : function(component, event) {
        var spinner = component.find("mySpinner2");
        $A.util.removeClass(spinner, 'slds-hide');
        component.set("v.spinner2",true);
        
        var oppId=component.get("v.oppId");
        var action = component.get("c.GroupQuotes");
        action.setParams({OppId : oppId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {                
                var ret = response.getReturnValue();
                var qtValues=[];
                for(var key in ret){
                    qtValues.push(ret[key]);
                }                
                component.set("v.quoteList",qtValues);
                component.set("v.quotesize",qtValues.length);
                var cnt = component.get("v.quotesize");
                cnt = cnt+1;
                component.set("v.quotesize",cnt);
                if(cnt == 5){
                    component.set("v.maxQuote",true);
                }
                component.set("v.isValue",true);
            }
            else if (state === "INCOMPLETE") {
                //console.log("INCOMPLETE RESPONSE");
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //console.log("Error message: " + 
                        // errors[0].message);
                    }
                } else {
                    //console.log("Unknown error");
                }
            }
            component.set("v.spinner2",false);
            $A.util.addClass(spinner, 'slds-hide');   
        });
        $A.enqueueAction(action);
    },
    
    toggleSpinner: function (component, event) {        
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
    
    scrollTop: function (component, event, top){
        var scrollOptions = {
            left: 0,
            top: top,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    },
})