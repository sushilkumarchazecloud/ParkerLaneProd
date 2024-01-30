({
	doInit : function(component, event, helper) {
        var pro = component.get("v.product");
        if(!$A.util.isUndefinedOrNull(pro) && pro != null){
            if(!$A.util.isUndefinedOrNull(pro.Features__c) && pro.Features__c != null){
                component.set("v.features", pro.Features__c.split(";"));
            }
            
            if(!$A.util.isUndefinedOrNull(pro.Eligibility_Description__c) && pro.Eligibility_Description__c != null){
                component.set("v.eligibilities", pro.Eligibility_Description__c.split(";"));
            }
        }        
    },
    changeState : function changeState (component){ 
        component.set('v.isexpanded',!component.get('v.isexpanded'));
    },
    
    applyNow : function changeState (component, event, helper){ 

    },
})