({   
    doInit : function(component, event, helper) {  
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var action = component.get("c.getFundingOnHandOverPopUp");
        action.setParams({ 
            recId : component.get("v.recordId"),
        }); 
        action.setCallback(this,function(response){
            var record = response.getReturnValue();
            if(record != null){
                component.set("v.nameOfApp1",record.Applicant_1_A1__r.Name);
                if(record.A1_Funding_Call_Handover__c != null){
                    component.set("v.app1Handover",true);  
                }
                if(record.Applicant_2_A2__c != null){
                    component.set("v.app2Exist",true);
                    component.set("v.nameOfApp2",record.Applicant_2_A2__r.Name);
                    if(record.A2_Funding_Call_Handover__c != null){
                        component.set("v.app2Handover",true);  
                    }
                }
                $A.util.addClass(spinner, 'slds-hide'); 
            }
        });       
        $A.enqueueAction(action);
        
    },
    
    Cancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    Submit : function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        
        var action = component.get("c.UpdateFundingHandOver");
        action.setParams({ 
            recId : component.get("v.recordId"),
            app1HandOver : component.get("v.app1Handover"),
            app2HandOver : component.get("v.app2Handover")
        }); 
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var msg = 'Success !!';
                helper.showMessage(component, "Success",msg , "success");
            }
            else if (state === "ERROR") {
                console.log('Error');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } 
            } 
            $A.util.addClass(spinner, 'slds-hide'); 
            $A.get("e.force:closeQuickAction").fire();
            $A.get("e.force:refreshView").fire();
        });       
        $A.enqueueAction(action); 
    }
})