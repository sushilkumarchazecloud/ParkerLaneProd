({
    getPreviousAction : function(component, event){
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var action = component.get("c.getActionCentreRequest");
        action.setParams({ 
            ConId : component.get("v.accountId"),
            OppId : component.get("v.WrapperData.Id"),
            
        }); 
        
        action.setCallback(this,function(response) 
                           {
                               var  ret = response.getReturnValue();
                               component.set("v.PreviousData",ret);
                               $A.util.addClass(spinner, 'slds-hide');
                           });
        $A.enqueueAction(action);
    },
    
    SaveRequest : function(component, event){
        var spinner = component.find("mySpinner2");
        $A.util.removeClass(spinner, 'slds-hide');
        component.set("v.spinner2",true);
        
        var req = component.get("v.QuickActionValue");
        var reqInp = component.get("v.RequestBody");
        var related = component.get("v.RelatedtoValue");
        var urgency = component.get("v.UrgencyValue");
        var oppid = component.get("v.WrapperData.Id");
        var oppStage= component.get("v.WrapperData.StageName");
        var refConId = component.get("v.accountId");
        
        var action = component.get("c.createActionRequest");
        action.setParams({ Con : refConId,
                          Opp : oppid,
                          QA : req, 
                          reqBody : reqInp,
                          relTo : related,
                          Urg : urgency,
                          OppStage : oppStage,
                          
                         });
        action.setCallback(this, function(response) { 
            var  ret = response.getReturnValue(); 
            var state = response.getState(); 
            if (state === "SUCCESS") {  
                component.set("v.SuccessShow",true);
                component.set("v.SubmitbuttonShow",false);
                component.set("v.Escalation",false);
                component.set("v.Request",false);
                component.set("v.SuccessQAValue",req);
                component.set("v.QuickActionValue",null);
                
                if(ret != null){
                    component.set("v.PreviousData",ret);
                }  
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } 
            } 
            component.set("v.spinner2",false);
            $A.util.addClass(spinner, 'slds-hide');
        });
        $A.enqueueAction(action);
    }
})