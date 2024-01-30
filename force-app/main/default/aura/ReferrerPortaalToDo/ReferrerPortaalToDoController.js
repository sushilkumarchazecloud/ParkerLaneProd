({
    doInit : function(component, event, helper) { 
        
        // Code for OppName Spliting(Spliting Comma and RecordTypeName From Name)
        var Name = component.get("v.oppWrapper.Name")
        if(Name){
            var OppName = Name.split(',');
            component.set("v.OpportunityName",OppName[0]); 
        }
        
        var getOpp = [];    
        if(component.get("v.opList") != null){
            getOpp = JSON.parse(component.get("v.opList"));
        }
        var count = 1;
        if(getOpp != null){
            for(var i=0; i<getOpp.length; i++){
                if(getOpp[i].toDoFor == 'Referrer' && getOpp[i].status == 'Required Now' && count == 1){
                    component.set("v.NextStep1",getOpp[i].doneText);
                    component.set("v.icon1",getOpp[i].iconName);
                    count++;
                    break;
                }
            }
        }       
    },
    
    showModal : function(component, event, helper) {
        component.set("v.modalShow",true);
        component.set("v.isDetail",false);
        component.set("v.isFinanceQt",false);
        component.set("v.isActionCntr",true);
        component.set("v.isDocument",false);
        helper.getOppExpand(component, event, helper);
    },
    
    closeModal : function(component, event, helper) {
        component.set("v.modalShow",false);
        component.set("v.ishide",true);
        component.set("v.InstallEdit",true);
        component.set("v.isSaveBtnDisabled",true);
        component.set("v.isDetail",false);
        component.set("v.isFinanceQt",false);
        component.set("v.isActionCntr",false);
        component.set("v.isDocument",false);
        component.set("v.showError",false);
    },
    
    
    FinanceQuotesShow : function(component, event, helper) {
        component.set("v.ishide",true);
        component.set("v.InstallEdit",true);
        component.set("v.isFinanceQt",true);
        component.set("v.isDetail",false);
        component.set("v.isDocument",false);
        component.set("v.isActionCntr",false);
        component.set("v.ishide",true);
        component.set("v.isSaveBtnDisabled",true);
    },
    
    isDetailShow : function(component, event, helper) {
        component.set("v.ishide",true);
        component.set("v.InstallEdit",true);
        component.set("v.isDetail",true);
        component.set("v.isDocument",false);
        component.set("v.isFinanceQt",false);
        component.set("v.isActionCntr",false);
        helper.getOppExpand(component, event, helper);
    },
    
    ActionCentreShow : function(component, event, helper){
        component.set("v.ishide",true);
        component.set("v.InstallEdit",true);
        component.set("v.isActionCntr",true);
        component.set("v.isDocument",false);
        component.set("v.isDetail",false);
        component.set("v.isFinanceQt",false);
    },
    
    DocumentsShow : function(component, event, helper){
        component.set("v.ishide",true);
        component.set("v.InstallEdit",true);
        component.set("v.isActionCntr",false);
        component.set("v.isDocument",true);
        component.set("v.isDetail",false);
        component.set("v.isFinanceQt",false);
    },
    
    actions : function(component, event, helper) {
        var selectedMenuItemValue = event.getParam("value");
        if(selectedMenuItemValue == 'Open Fact Find'){
            helper.openForm(component, event, helper); 
        }
        if(selectedMenuItemValue == 'Resend O/S Request'){
            helper.sendOsMail(component, event, helper);
        }
        if(selectedMenuItemValue == 'Resend VOI SMS (P1)'){
            helper.sendVoiSms1(component, event, helper);
        }
        if(selectedMenuItemValue == 'Resend VOI SMS (P2)'){
            helper.sendVoiSms2(component, event, helper);
        }
    },
})