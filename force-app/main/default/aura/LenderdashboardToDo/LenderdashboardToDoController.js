({
    doInit : function(component, event, helper) { 
        
        // Code for OppName Spliting(Spliting Comma and RecordTypeName From Name)
        var Name = component.get("v.oppWrapper.Name")
        //alert(Name);
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
                if(getOpp[i].toDoFor == 'Lender' && getOpp[i].status == 'Required Now' && count == 1){
                    component.set("v.NextStep1",getOpp[i].doneText);
                    component.set("v.icon1",'ReferrerTODO');
                    count++;
                    break;
                }
            }
        }
        var lender_agent_onOpp = component.get("v.oppWrapper.Lender_Agent__c");
        var conID = component.get("v.accountId");
        if(lender_agent_onOpp == conID){
            component.set("v.ExpandDisable",false);
        }
        else{
            component.set("v.ExpandDisable",true);
        }
        helper.showSpinnerForThreeSeconds(component, event, helper);
    },
    
    showModal : function(component, event, helper) {
        helper.oppExpand(component, event, helper);
        component.set("v.modalShow",true);
    },
    
    closeModal : function(component, event, helper) {
        component.set("v.modalShow",false);
        component.set("v.isDetail",true);
        component.set("v.isFunding",false);
        component.set("v.isDocument",false);
    },
    
    isDetailShow : function(component, event, helper) {
        component.set("v.isDetail",true);
        component.set("v.isFunding",false);
        component.set("v.isDocument",false);
    },   
    
    FundingShow : function(component, event, helper){
        component.set("v.isFunding",true);
        component.set("v.isDetail",false);
        component.set("v.isDocument",false);
    },
    
    DocumentsShow : function(component, event, helper) {
        component.set("v.isDocument",true);
        component.set("v.isDetail",false);
        component.set("v.isFunding",false);
    }, 
    
})