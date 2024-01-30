({
    doInIt : function(component, event, helper) {
        helper.getPreviousAction(component, event);
    },
    
    handleChange : function(component, event, helper) {
        var selectedOptionValue = event.getParam("value");
        component.set("v.isSubmitBtnDisabled",true);
        component.set("v.SubmitbuttonShow",true);
        component.set("v.UrgencyValue",null);
        component.set("v.RequestBody",null);
        component.set("v.RelatedtoValue",null);
        component.set("v.SuccessShow",false);
        if(selectedOptionValue =='Escalation request'){
            component.set("v.Escalation",true);
            component.set("v.Request",false);
        }
        else if(selectedOptionValue =='Request assistance'){
            component.set("v.Request",true);
            component.set("v.Escalation",false);
        }
    },
    
    fieldvaluecheck : function(component, event, helper) {
        var escalation = component.get("v.Escalation");
        var request = component.get("v.Request");
        
        if(escalation == true){
            var escInpValue = component.find("EscInp").get("v.value");
            var rGroupValue = component.find("rGroup").get("v.value"); 
            if( escInpValue != '' && rGroupValue != null){
                component.set("v.isSubmitBtnDisabled",false);
            }
            else{
                component.set("v.isSubmitBtnDisabled",true); 
            }
        }
        else if(request == true){
            var reqComboValue = component.find("ReqCombo").get("v.value");
            var reqInpValue = component.find("ReqInp").get("v.value");
            var rGroupValue = component.find("rGroups").get("v.value");
            
            if( reqComboValue != '' && reqInpValue != '' && rGroupValue != null ){
                component.set("v.isSubmitBtnDisabled",false);
            }
            else{
                component.set("v.isSubmitBtnDisabled",true); 
            }
        }
    },
    
    submitRequest : function(component, event, helper){
        helper.SaveRequest(component,event);
    }
    
})