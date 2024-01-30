({
    doInit : function(component, event, helper) {
         //Code for seeting up the previous funding requests.
         var FrqList = component.get("v.oppWrapper.FrqList");
         component.set("v.fundingRequests",FrqList);
        
        // Code For StatusColumn(for Colouring) Spliting.
        var oppStage = component.get("v.oppWrapper.Opportunity.StageName");
        var frList = component.get("v.oppWrapper.FrqList");
        if(oppStage == 'Approved'){
            component.set("v.status",'Approved');
            component.set("v.statusCode",'#3BE8B0');
        }
        else if(oppStage == 'Funding' && frList != null && frList.length > 0){
            for(var i=0;i<frList.length;i++){
                if(frList[i].Request_Status__c == 'Payment authorised by customer'){
                    component.set("v.status",'Funding Required');
                    component.set("v.statusCode",'#FD636B');
                    break;
                }
                else if(frList[i].Request_Type__c == 'Part payment before installation' && frList[i].Request_Status__c == 'Payment funded'){
                    component.set("v.status",'Part Funded');
                    component.set("v.statusCode",'#D063D3');
                }
            }
        } 
        else if(oppStage == 'Settled (closed won)'){
            component.set("v.status",'Funded');
             component.set("v.statusCode",'#4A154B');
        }
        
        //Code for Showing Disbursement type Column.
        if(frList != null && frList.length > 0){
            for(var i=0;i<frList.length;i++){
                var req_type = frList[i].Request_Type__c;
                var lender_notes = frList[i].Funding_Notes_to_Lender__c;
                component.set("v.DisbursementType",req_type);
                component.set("v.lenderNotes",lender_notes);
                break;
            }
        }
        
        // Code for OppName Spliting(Spliting Comma and RecordTypeName From Name)
        var Name = component.get("v.oppWrapper.Opportunity.Name")
        if(Name){
            var OppName = Name.split(',');
            component.set("v.OpportunityName",OppName[0]); 
        }
        
        // Code for Showing Next Steps ColumnData(ToDo's Condition based).
        var actList = [];
        if(component.get("v.oppWrapper.Opportunity.Line_Chart_JSON__c") != null){
            actList= JSON.parse(component.get("v.oppWrapper.Opportunity.Line_Chart_JSON__c"));
        }
        let count = 0;
        var checkboxval = component.get("v.chkboxvalue");
        if(actList != null ) { 
            for(var i=0;i<actList.length;i++){
                if(checkboxval == false){
                    if(actList[i].status == "Required Now" || actList[i].status == "Future"){
                        if(count == 0){
                            component.set("v.NextStep1",actList[i].doneText);
                            if(actList[i].toDoFor == 'Lender'){
                            component.set("v.icon1",'ReferrerTODO');
                            }
                            else{
                             component.set("v.icon1",'SmallToDo');   
                            }
                        }else if(count == 1){
                            component.set("v.NextStep2",actList[i].doneText);
                            if(actList[i].toDoFor == 'Lender'){
                                component.set("v.icon2",'ReferrerTODO');
                            }
                            else{
                                component.set("v.icon2",'SmallToDo');   
                            }
                            break;
                        }
                        count++;
                    }
                }
                else{
                    if(actList[i].status == "Required Now" &&  actList[i].toDoFor == 'Lender'){   
                        console.log('>>>>>' + actList[i].status + '>>>>' + count);
                        if(count == 0){
                            component.set("v.NextStep1",actList[i].doneText);
                            component.set("v.icon1",'ReferrerTODO');
                        }else if(count == 1){
                            component.set("v.NextStep2",actList[i].doneText);
                            component.set("v.icon2",'ReferrerTODO');
                            break;
                        }
                        count++;
                    }
                }  
            } 
        }  
        
        //Code for Showing Priority Section.
        var funding_list = component.get("v.oppWrapper.FrqList");
        var opp_ref_rating = component.get("v.oppWrapper.Opportunity.FinServ__ReferredByContact__r.Referrer_Rating__c");
        var escalation = false;
        if(funding_list != null && funding_list.length > 0){
            for(var i=0;i<funding_list.length;i++){
                if(funding_list[i].Funding_escalation__c == true){
                   component.set("v.PriorityIcon",'Red');
                   component.set("v.priorityText",'Escalation');
                   escalation = true;
                   break;
                }
            }
        }
        if(!escalation){
            if(opp_ref_rating != null && opp_ref_rating == 'Platinum'){
                component.set("v.PriorityIcon",'Orange');
                component.set("v.priorityText",'High');
            }  
            else{
                component.set("v.PriorityIcon",'Green');
                component.set("v.priorityText",'Normal'); 
            }
        }
        
        //Code for Assign Button functionality.
        var lender_agent_onOpp = component.get("v.oppWrapper.Opportunity.Lender_Agent__c");
        var name_lender_agent_onOpp = component.get("v.oppWrapper.Opportunity.Lender_Agent__r.Name");
        helper.assignButtonShow(component, event, helper, lender_agent_onOpp,name_lender_agent_onOpp,false);
    },
    
    assignModalYesClick : function(component, event, helper) {
        component.set("v.assignSpinner",true);
        var agent_id = component.get("v.assignCmbValue");
        var oppId = component.get("v.oppWrapper.Opportunity.Id")
        var action = component.get("c.LenderAgentAssign");
        
        action.setParams({
            conId : agent_id,
            OppId : oppId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
             var ret = response.getReturnValue();
                if(ret != null){
                    helper.assignButtonShow(component, event, helper, ret.Id, ret.Name,false);
                    helper.updateBoxValues(component, event, helper);
                }
                else if(ret == null){
                    helper.assignButtonShow(component, event, helper, null, null,false);
                    helper.updateBoxValues(component, event, helper);
                }
                component.set("v.assignModalShow",false);
            }
            component.set("v.assignSpinner",false);
        });
        $A.enqueueAction(action);
    },
    
    assign : function(component, event, helper) {
      component.set("v.assignModalShow",true);
        
    },
    
    cmbBoxChange : function(component, event, helper) {
     // alert(component.get("v.assignCmbValue"));
    },
    
    closeassignBtnModal : function(component, event, helper) {
        component.set("v.assignModalShow",false);
    },
    
    showModal : function(component, event, helper) {
        helper.oppExpand(component, event, helper);
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