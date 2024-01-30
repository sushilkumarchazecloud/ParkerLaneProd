({  
    assignButtonShow : function(component, event, helper, lender_agent_onOpp,conName,expand){
        component.set("v.assignCmbOptions",[]);
        var view = component.get("v.cont.Portal_View__c");
        var agent_conId = component.get("v.accountId");
        var conAgentList = component.get("v.oppWrapper.contactList");
        var assignCmbOptions = component.get("v.assignCmbOptions");
        
        if(lender_agent_onOpp == null){
            component.set("v.assignBtnLabel",'Assign');
            if(view == 'Agent View'){
                component.set("v.assignModalHeader",'Do you want to assign to yourself? '); 
                component.set("v.assignCmbValue",agent_conId);
                component.set("v.assignComboboxShow",false);
            }
            else if(view == 'Admin View'){
                component.set("v.assignModalHeader",'Who do you want to assign to?');
                component.set("v.assignComboboxShow",true);
                if(conAgentList != null){
                    for(var i=0;i<conAgentList.length;i++){
                        if(conAgentList[i].Id == agent_conId){
                            assignCmbOptions.push({label: "Myself", value: conAgentList[i].Id});  
                        }
                        if(conAgentList[i].Id != agent_conId){
                            assignCmbOptions.push({label: conAgentList[i].Name , value: conAgentList[i].Id});
                        }
                    }
                }
            }
        }
        else if(lender_agent_onOpp != null && lender_agent_onOpp == agent_conId){
            component.set("v.assignBtnLabel",'Leave');
            component.set("v.assignModalHeader",'Do you want to leave this file? ');
            component.set("v.assignCmbValue",null);
            component.set("v.assignComboboxShow",false);
        }
            else if(lender_agent_onOpp != null && lender_agent_onOpp != agent_conId){
                if(view == 'Admin View'){
                    component.set("v.assignModalHeader",'Do you want to unassign or reassign to anyone else?');
                    component.set("v.assignComboboxShow",true);
                    component.set("v.assignBtnLabel",'Reassign');
                    if(conAgentList != null){
                        for(var i=0;i<conAgentList.length;i++){
                            var unassignExists = assignCmbOptions.some(function (option) {
                                return option.label === "Unassign";
                            });
                            if (!unassignExists) {
                                assignCmbOptions.push({label: "Unassign", value: null });
                            }
                            
                            if(conAgentList[i].Id == agent_conId){
                                assignCmbOptions.push({label: "Myself", value: conAgentList[i].Id});
                            }
                            if(conAgentList[i].Id != agent_conId){
                                assignCmbOptions.push({label: conAgentList[i].Name , value: conAgentList[i].Id});
                            }
                        } 
                    }
                }
                else if(view == 'Agent View'){
                    component.set("v.assignComboboxShow",false);
                    //component.set("v.assignModalHeader",'Do you want to assign to yourself? ');  
                }    
            } 
        
        //Code for shwoing Expand button functionality.
        if( lender_agent_onOpp == agent_conId){
            component.set("v.ExpandDisable",false);
            if(expand){
                component.set("v.modalShow",true); 
            } 
        } 
        else{
            component.set("v.ExpandDisable",true);
        } 
    },
    
    updateBoxValues : function(component,event,helper){ 
        var action = component.get("c.getMySettlments");
        action.setParams({ 
            stagenm : component.get("v.selectedTab"),
            searchKey : component.get("v.searchKeyword"),
            contactId : component.get("v.accountId"),
            Str : component.get("v.Sorting")
        });
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                if(ret != null){
                    for(var i=0;i<ret.length;i++){
                        component.set("v.No_of_Action_Required",ret[i].ActionRequired);
                        component.set("v.No_Of_My_Assigned",ret[i].MyAssigned);
                        component.set("v.No_Of_Funded",ret[i].MyFunded);
                        break;
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    oppExpand : function(component,event,helper){
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var oppId = component.get("v.oppWrapper.Opportunity.Id");
        var agent_conId = component.get("v.accountId");                    
        var action = component.get("c.GetOppOnExpand");
        action.setParams({
            contactId : agent_conId,
            oppId : oppId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                if(ret != null){
                    component.set("v.oppWrapper",ret);
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
                                    console.log('>>>>>' + actList[i].status + '>>>>' + count);
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
                    helper.assignButtonShow(component, event, helper, lender_agent_onOpp,name_lender_agent_onOpp,true);
                }
            }
            $A.util.addClass(spinner, 'slds-hide');
        });
        $A.enqueueAction(action);
    },
    
})