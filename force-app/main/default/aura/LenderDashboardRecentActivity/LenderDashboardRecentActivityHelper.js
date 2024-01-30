({
    oppExpand : function(component,event,helper){
    var spinner = component.find("mySpinner");
    $A.util.removeClass(spinner, 'slds-hide');
    var oppId = component.get("v.getOppList.Id");
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
                component.set("v.fundList",FrqList);
                
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
                if(actList != null ) { 
                    for(var i=0;i<actList.length;i++){
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
            }
        }
        $A.util.addClass(spinner, 'slds-hide');
    });
    $A.enqueueAction(action);
},
    
})