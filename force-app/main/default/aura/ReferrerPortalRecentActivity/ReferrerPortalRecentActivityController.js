({
    doInit : function(component, event, helper) {
        var statusWithColor = component.get("v.getOppList.Status__c");
        var sendQuote = component.get("v.getOppList.Send_the_quote_to__c");
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
        
        var apexDateTime = component.get("v.getOppList.Approved_Date__c");
        var apexDate = new Date(apexDateTime);
        var today = new Date();
        var timeDiff = today.getTime() - apexDate.getTime();
        var daysDiff = Math.floor(timeDiff / (1000 * 60 * 60 * 24));
        
        if(statusWithColor){
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
        }
        
        
        //Added by Pawan
        var Name = component.get("v.getOppList.Name")
        if(Name){
            var OppName = Name.split(',');
            component.set("v.OpportunityName",OppName[0]); 
        }
    },
    
    showModal : function(component, event, helper) {
        component.set("v.modalShow",true);
        component.set("v.isDetail",true);
        component.set("v.isFinanceQt",false);
        component.set("v.isActionCntr",false);
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
        //alert(selectedMenuItemValue);
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