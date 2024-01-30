({      getOppExpand : function(component,event,helper){
        var oppId = component.get("v.oppWrapper.Id");
        console.log('oppId'+oppId);
        var action = component.get("c.GetOppOnExpand");
        action.setParams({
            oppId : oppId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                if(ret != null){
                    component.set("v.oppWrapper",ret);
                    var Name = component.get("v.oppWrapper.Name")
                    if(Name){
                        var OppName = Name.split(',');
                        component.set("v.OpportunityName",OppName[0]); 
                    }
                    var statusWithColor = component.get("v.oppWrapper.Status__c");
                    if(statusWithColor){
                        var statusWithColorList = statusWithColor.split('-');
                        component.set("v.status",statusWithColorList[0]);
                        component.set("v.statusCode",statusWithColorList[1]);
                    } 
                    var actList = [];
                    if(component.get("v.oppWrapper.Line_Chart_JSON__c") != null){
                        actList= JSON.parse(component.get("v.oppWrapper.Line_Chart_JSON__c"));
                    }
                    var newactList = [];
                    var count = 1;
                    if(actList != null){
                        for(var i=0; i<actList.length; i++){
                            if(actList[i].toDoFor == 'Referrer' && actList[i].status == 'Required Now' && count == 1){
                                component.set("v.NextStep1",actList[i].doneText);
                                component.set("v.icon1",actList[i].iconName);
                                count++;
                                break;
                            }
                        }
                    }
                    if(actList != null ) { 
                        for(var i=0;i<actList.length;i++){
                                if(actList[i].status == "Required Now"){   
                                    newactList.push(actList[i]);
                                }                          
                        }
                        component.set("v.todoList",newactList);
                    }
                    
                    var stageCheck = component.get("v.oppWrapper.StageName");
                    var sectionCheck = component.get("v.oppWrapper.Current_Application_Sections__c");
                    console.log('sectionCheck'+sectionCheck);
                    if((stageCheck == 'CPA Started' || stageCheck == 'CPA Done') && (sectionCheck != 'Getting Started' && sectionCheck != 'Loan Recommendation')){
                        component.set("v.OpenFactFind",false);
                    }
                    else{
                        component.set("v.OpenFactFind",true);
                    }
                    
                    //Code for Showing Address.
                    var address = component.get("v.oppWrapper.installationAddressLineOne__c");
                    component.set("v.searchString",address);
                    
                    helper.ShowEditButtons(component, event, helper);
                    helper.getVoiList(component, event, helper);
                }
            }
        });
        $A.enqueueAction(action);
    },
  
	openForm : function(component,event,helper){ 
        var label = $A.get("$Label.c.baseUrl");
        var oppId = component.get("v.oppWrapper.Id");        
        var qt = component.get("v.GroupName");
        var redirect = label+'?id='+oppId+'&master='+qt;
        window.open(redirect);
    },
    
    sendOsMail : function(component,event,helper){
        if (confirm("Are you sure you want to Resend O/S Request") == true){
            var oppId = component.get("v.oppWrapper.Id");        
            var action = component.get("c.sendMail");
            
            action.setParams({
                recId : oppId
            });
            action.setCallback(this, function(response){
                var state = response.getState();
            });
            $A.enqueueAction(action);
        }
    },
    
    sendVoiSms1 : function(component,event,helper){
        if (confirm("Are you sure you want to Resend VOI SMS (P1)") == true){
            var oppId = component.get("v.oppWrapper.Id"); 
            //alert(oppId);
            var phone = component.get("v.oppWrapper.Applicant_1__r.Phone");
            //alert(phone);
            var name = component.get("v.oppWrapper.Applicant_1_Name__c");
            //alert(name);
            var voiType = component.get("v.VoiType1");
            //alert(voiType);
            var action = component.get("c.sendVoi1");
            
            action.setParams({
                phoneNo : phone,
                OppId : oppId,
                contactName : name,
                voiType : voiType            
            });
            action.setCallback(this, function(response){
                var state = response.getState();
            });
            $A.enqueueAction(action);
        }
    },
    
    sendVoiSms2 : function(component,event,helper){
        if (confirm("Are you sure you want to Resend VOI SMS (P2)") == true){
            var oppId = component.get("v.oppWrapper.Id");     
            //alert(oppId);
            var phone = component.get("v.oppWrapper.Applicant_2__r.Phone");
            //alert(phone);
            var name = component.get("v.oppWrapper.Applicant_2_Name__c"); 
            //alert(name);
            var voiType = component.get("v.VoiType2");
            //alert(voiType);
            var action = component.get("c.sendVoi2");
            
            action.setParams({
                phoneNo : phone,
                OppId : oppId,
                contactName : name,
                voiType : voiType
            });
            action.setCallback(this, function(response){
                var state = response.getState();
            });
            $A.enqueueAction(action);
        }
    },
    
    getVoiList : function(component,event,helper){
        var oppId = component.get("v.oppWrapper.Id");
        console.log('oppId'+oppId);                      
        var action = component.get("c.GetVoiRelToOpp");
        action.setParams({
            oppId : oppId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                if(ret.quote != null){
                    component.set("v.GroupName",ret.quote.Gruop_Name__c);                
                }
                var docs = component.get("v.oppWrapper.Docs_Outstanding__c");
                if(ret != null){              
                    var voi1 = ret.Voi1;
                    var voi2 = ret.Voi2;                     
                    if(docs > 0 || voi1 != null || voi2 != null){
                        component.set("v.ResendOSRequest",false);
                    }
                    else{
                        component.set("v.ResendOSRequest",true);
                    }
                    if(ret.Opportunity.Applicant_2__c == null){
                        component.set("v.hideSms2",true);
                    }
                    if(voi1 != null){
                        component.set("v.ResendVOISMSP1",false);  
                        component.set("v.VoiType1",ret.Voi1.VOI_Type_For__c);
                    }
                    else{
                        component.set("v.ResendVOISMSP1",true);
                    }
                    if(voi2 != null){
                        component.set("v.ResendVOISMSP2",false);  
                        component.set("v.VoiType2",ret.Voi2.VOI_Type_For__c);
                    }
                    else{
                        component.set("v.ResendVOISMSP2",true);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
        ShowEditButtons : function(component, event, helper) { 
        // Code for Edit Button Showing on Condition based.
        var oppApplicationSection = component.get("v.oppWrapper.Current_Application_Sections__c");
        var oppStage = component.get("v.oppWrapper.StageName");
        if(oppApplicationSection == 'Priorities' || oppApplicationSection == 'Loan Recommendation' || oppApplicationSection == 'Getting Started')
        {
            if(oppStage != 'CPA Done' && oppStage != 'Packs Out' && oppStage != 'Application'
               && oppStage != 'Submitted' && oppStage != 'Conditionally Approved' 
               && oppStage != 'Conditional' && oppStage != 'Unconditional' && oppStage != 'Approved'
               && oppStage != 'Funding' && oppStage != 'Docs Signed' && oppStage != 'Settlement Booked'
               && oppStage != 'Settled (closed won)' && oppStage != 'Closed Lost' ){
                
                component.set("v.EditButtonShow",true);
            }
        } 
    },
    
    showSpinnerForThreeSeconds: function(component, event, helper) {
        component.set("v.showSpinner", true);
        setTimeout(function() {
            component.set("v.showSpinner", false);
        }, 1200); 
    },
})