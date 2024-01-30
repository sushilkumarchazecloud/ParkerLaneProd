({
    doInit : function(component, event, helper) {
        var Oppr = component.get("v.getOppList");
        var fundlist = component.get("v.fundList");
        //var statusWithColor = component.get("v.getOppList.Status__c");
        //var fundingStatus = component.get("v.getOppList.Request_Status__c");
        var lenderName = component.get("v.getOppList.Lender_Agent__r.Name");
        //var sendQuote = component.get("v.getOppList.Send_the_quote_to__c");
        var nme = component.get("v.getOppList.Name");
        var name = nme.split(',');
        component.set("v.getOppList.Name",name[0]);
        var datetime = component.get("v.getOppList.Last_Stage_Change_Date__c");
        var cDate = new Date(datetime);
        var month = cDate.toLocaleString('default', { month: 'short' });        
        var dateval = month + ' ' +cDate.getDate();
        var AMPM = cDate.getHours() >= 12 ? "PM" : "AM";
        var hours;
        if(cDate.getHours() == 0){
            hours = cDate.getHours() + 12;
        } else if (cDate.getHours() > 12) {
            hours = cDate.getHours() - 12;
        } else {
            hours = cDate.getHours();
        }
        var min = (cDate.getMinutes()<10?'0':'') + cDate.getMinutes();
        var newFormatTime = hours + ":" + min + " " + AMPM;
        var d = new Date();
        var datecheck = d.getDate();
        var monthcheck = d.getMonth();
        if(cDate.getDate()+1 == datecheck && monthcheck == cDate.getMonth()){
            dateval = 'Yesterday';
            component.set("v.time",dateval);
        }
        if(datecheck == cDate.getDate() && monthcheck == cDate.getMonth()){
            component.set("v.time",newFormatTime);
        }
        else{
            component.set("v.time",dateval);
        }
        if(Oppr.StageName == 'Approved'){
            component.set("v.desc",'Approved');
            component.set("v.status",'Approved');
            component.set("v.statusCode",'#3BE8B0');
        }
        else if(fundlist != null){
            for(var i=0;fundlist.length;i++){
                var fundingStatus = fundlist[i].Request_Status__c;
                if(fundingStatus == 'Payment requested by customer'){
                    component.set("v.desc",'Funding requested by customer');
                }
                else if(fundingStatus == 'Payment requested by supplier'){
                    component.set("v.desc",'Funding requested by supplier');
                }
                    else if(fundingStatus == 'Payment requested by customer (pending contract)' || fundingStatus == 'Payment requested by supplier (pending contract)'){
                        component.set("v.desc",'Funding requested - issue credit contract');
                    }
                        else if(fundingStatus == 'Payment authorised by customer'){
                            component.set("v.desc",'Funding authorised - disburse funds');
                            component.set("v.status",'Funding Required');
                            component.set("v.statusCode",'#FD636B');
                        }
                            else if(component.get("v.getOppList.Funding_On_Hold__c")){
                                component.set("v.desc",'Funding placed on hold until ' + component.get("v.getOppList.Funding_Hold_Expiry_Date__c"));
                            }
                                else if(fundingStatus == 'Payment funded'){
                                    component.set("v.desc",'Funded! Thank you ' +  lenderName + ':)');
                                }
                if(fundlist[i].Request_Type__c == 'Part payment before installation' && fundlist[i].Request_Status__c == 'Payment funded'){
                    component.set("v.status",'Part Funded');
                    component.set("v.statusCode",'#D063D3');
                }
                break;
            }
        }
        if(Oppr.StageName == 'Settled (closed won)'){
            component.set("v.status",'Funded');
            component.set("v.statusCode",'#4A154B');
        } 
        
        /*var apexDateTime = component.get("v.getOppList.Approved_Date__c");
        var apexDate = new Date(apexDateTime);
        var today = new Date();
        var timeDiff = today.getTime() - apexDate.getTime();
        var daysDiff = Math.floor(timeDiff / (1000 * 60 * 60 * 24));*/
        
        /*if(statusWithColor){
            var statusWithColorList = statusWithColor.split('-');
            if(statusWithColorList[0] == 'Quote' && sendQuote == 'Me and my customer'){
                component.set("v.desc",'Received your quote');
            }
            else if(statusWithColorList[0] == 'Quote' && sendQuote == 'Me only'){
                component.set("v.desc",'Quote sent to you only');
            }
                else if(statusWithColorList[0] == 'Applying'){
                    component.set("v.desc",'Started their application');
                }
                    else if(statusWithColorList[0] == 'Verifying'){
                        component.set("v.desc",'Completing their application');
                    }
                        else if(statusWithColorList[0] == 'Credit'){
                            component.set("v.desc",'Pending credit decision');
                        }
                            else if(statusWithColorList[0] == 'Approved'){
                                if(daysDiff == 80){
                                    component.set("v.desc",'Approval expires in 10 days!');
                                }
                                else{
                                    component.set("v.desc",'Is approved!');
                                }
                            }
                                else if(statusWithColorList[0] == 'Funding'){
                                    if(daysDiff == 80){
                                        component.set("v.desc",'Approval expires in 10 days!');
                                    }
                                    else{
                                        component.set("v.desc",'Being funded');
                                    }
                                }
                                    else if(statusWithColorList[0] == 'Funded'){
                                        component.set("v.desc",'Funded!');
                                    }
                                        else if(statusWithColorList[0] == 'Closed'){
                                            component.set("v.desc",'Not proceeding');
                                        }
            component.set("v.status",statusWithColorList[0]);
            component.set("v.statusCode",statusWithColorList[1]);
        }*/
        
        
        //Added by Pawan
        var Name = component.get("v.getOppList.Name");
        if(Name){
            var OppName = Name.split(',');
            component.set("v.OpportunityName",OppName[0]); 
        }
        var lender_agent_onOpp = component.get("v.getOppList.Lender_Agent__c");
        var conID = component.get("v.accountId");
        if(lender_agent_onOpp == conID){
            component.set("v.ExpandDisable",false);
        }
        else{
            component.set("v.ExpandDisable",true);
        }
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