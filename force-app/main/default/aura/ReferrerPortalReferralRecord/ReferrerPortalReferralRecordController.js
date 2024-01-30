({
    doInit : function(component, event, helper) {
        // Code For StatusColumn(for Colouring) Spliting.
        var statusWithColor = component.get("v.oppWrapper.Opportunity.Status__c");
        if(statusWithColor){
            var statusWithColorList = statusWithColor.split('-');
            component.set("v.status",statusWithColorList[0]);
            component.set("v.statusCode",statusWithColorList[1]);
        }
        
        // Code for OppName Spliting(Spliting Comma and RecordTypeName From Name)
        var Name = component.get("v.oppWrapper.Opportunity.Name")
        if(Name){
            var OppName = Name.split(',');
            component.set("v.OpportunityName",OppName[0]); 
        }
        
        // Code for Edit Button Showing on Condition based.
        var oppApplicationSection = component.get("v.oppWrapper.Opportunity.Current_Application_Sections__c");
        var oppStage = component.get("v.oppWrapper.Opportunity.StageName");
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
                            component.set("v.icon1",actList[i].iconName);
                        }else if(count == 1){
                            component.set("v.NextStep2",actList[i].doneText);
                            component.set("v.icon2",actList[i].iconName);
                            break;
                        }
                        count++;
                    }
                }
                else{
                    if(actList[i].status == "Required Now" &&  actList[i].toDoFor == 'Referrer'){   
                        console.log('>>>>>' + actList[i].status + '>>>>' + count);
                        if(count == 0){
                            component.set("v.NextStep1",actList[i].doneText);
                            component.set("v.icon1",actList[i].iconName);
                        }else if(count == 1){
                            component.set("v.NextStep2",actList[i].doneText);
                            component.set("v.icon2",actList[i].iconName);
                            break;
                        }
                        count++;
                    }
                }  
            } 
        }  
        
        //Code for hiding Funding Section.
        let stage_List = ['CPA Started', 'CPA Done', 'Packs Out', 'Packs Back','Application','Submitted','Conditionally Approved','Conditional','Unconditional','Approved','Funding','Docs Signed','Settlement Booked','Settled (closed won)','Closed Lost'];
        var opp_Stage = component.get("v.oppWrapper.Opportunity.StageName");
        if(stage_List.includes(opp_Stage)){
            component.set("v.ShowFunding",true);
        }
        else{
            component.set("v.ShowFunding",false);   
        }
        /*   // Code for getting Lender Field First Letters Only.
        var inputString = component.get("v.oppWrapper.Opportunity.Lender__c");
        if(inputString !=null){
        var words = inputString.split(' ');
        var resultString = '';
        for (var i = 0; i < words.length; i++) {
            resultString += words[i].charAt(0);
        }
        alert(resultString);
        } */
        
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
    
    showModal : function(component, event, helper) {
        component.set("v.modalShow",true);
        helper.getOppExpand(component, event, helper);
    },
    
    closeModal : function(component, event, helper) {
        component.set("v.modalShow",false);
        component.set("v.ishide",true);
        component.set("v.InstallEdit",true);
        component.set("v.isSaveBtnDisabled",true);
        component.set("v.isDetail",true);
        component.set("v.isDocument",false);
        component.set("v.isFinanceQt",false);
        component.set("v.isActionCntr",false);
        component.set("v.showError",false);
        component.set("v.isFunding",false);
    },
    
    editModal : function(component, event, helper) {
        component.set("v.ishide",false);
        component.set("v.isSaveBtnDisabled",false);
    },
    
    InstalleditModal : function(component, event, helper) {
        component.set("v.InstallEdit",false);  
        component.set("v.isSaveBtnDisabled",false);
    },
    
    saveModal : function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var oppDetails = component.get("v.oppWrapper.Opportunity");
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing && inputCmp.checkValidity();
        }, true);
        component.set("v.showError",!(allValid));
        if(allValid){
            var action = component.get("c.SaveOpportunityOnMyReferralCard");
            action.setParams({ opp : oppDetails});
            action.setCallback(this, function(response) {
                var state = response.getState();          
                if (state === "SUCCESS") {  
                    alert('Successfully Saved');
                    var ret = response.getReturnValue();
                    component.set("v.oppWrapper.Opportunity",ret);
                    
                    var Name = component.get("v.oppWrapper.Opportunity.Name")
                    if(Name){
                        var OppName = Name.split(',');
                        component.set("v.OpportunityName",OppName[0]); 
                    } 
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } 
                } 
                $A.util.addClass(spinner, 'slds-hide');
            });
            $A.enqueueAction(action);
            component.set("v.ishide",true);
            component.set("v.isSaveBtnDisabled",true);
        }
        else{
            $A.util.addClass(spinner, 'slds-hide');
            component.set("v.errorMsg","Please update the form entries highlighted in red and try again"); 
        }
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
        component.set("v.isFunding",false);
    },
    
    isDetailShow : function(component, event, helper) {
        component.set("v.ishide",true);
        component.set("v.InstallEdit",true);
        component.set("v.isDetail",true);
        component.set("v.isDocument",false);
        component.set("v.isFinanceQt",false);
        component.set("v.isActionCntr",false);
        component.set("v.isFunding",false);
    },
    
    ActionCentreShow : function(component, event, helper){
        component.set("v.ishide",true);
        component.set("v.InstallEdit",true);
        component.set("v.isActionCntr",true);
        component.set("v.isDocument",false);
        component.set("v.isDetail",false);
        component.set("v.isFinanceQt",false);
        component.set("v.isFunding",false);
    },
    
     FundingShow : function(component, event, helper){
        component.set("v.ishide",true);
        component.set("v.InstallEdit",true);
        component.set("v.isFunding",true);
        component.set("v.isActionCntr",false);
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
        component.set("v.isFunding",false);
    },
    
    SaveAddress : function(component, event, helper){
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var oppp = component.get("v.oppWrapper.Opportunity");
        var addressVal = component.get("v.searchString");
        var action = component.get("c.SaveAddressOnOpp"); 
        action.setParams({
            opp : oppp,                          
            address : addressVal,
            custEmail : component.get('v.oppWrapper.Opportunity.Applicant_1_Email__c'),
            street: component.get('v.street'),
            postalCode: component.get('v.postalCode'),
            suburb: component.get('v.suburb'),
            country: component.get('v.country'),
            state: component.get('v.state'),
            streetNumber: component.get('v.streetNumber'),
            streetType: component.get('v.streetType') 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();          
            if (state === "SUCCESS") {  
                var ret = response.getReturnValue();
                component.set("v.oppWrapper.Opportunity",ret);
                component.set("v.searchString",ret.installationAddressLineOne__c);
            }
            $A.util.addClass(spinner, 'slds-hide');
        });
        $A.enqueueAction(action);
        component.set("v.InstallEdit",true);
        component.set("v.isSaveBtnDisabled",true);
    }
})