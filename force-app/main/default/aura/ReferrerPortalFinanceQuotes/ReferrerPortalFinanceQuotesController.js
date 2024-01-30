({  
    doInit : function(component, event, helper){
        //code for showing edit button on conditions
        var quoteType=component.get("v.WrapperData.RecordType.Name");
        if(quoteType=='Green Loan'){
            quoteType='Solar';
            component.set("v.quoteType",quoteType);
        }
        component.set("v.quoteType",quoteType);
        var oppApplicationSection = component.get("v.WrapperData.Current_Application_Sections__c");
        var oppStage = component.get("v.WrapperData.StageName");
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
        helper.getGroupQuotes(component, event);
    },
    
    editModal : function(component, event, helper) {
        component.set("v.ishide",false);
        component.set("v.isSaveBtnDisabled",false);
        component.set("v.isResendBtnDisabled",true);
        component.set("v.ResendsuccessMsg",false);
        component.set("v.DownloadsuccessMsg",false);
        component.set("v.ResedDownLoadDefaultBtn",true);
    },
    
    submitQuotes : function(component, event, helper){
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            return !inputCmp.get('v.validity').valueMissing && validSoFar;
        }, true);      

        if(allValid){
            component.set("v.isSaveBtnDisabled", false);
        }
        else{
            component.set("v.isSaveBtnDisabled", true);
        }
    },
    
    saveModal : function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var quoteType=component.get("v.WrapperData.RecordType.Name");
        if(quoteType=='Green Loan'){
                quoteType='Solar';
            }
            var oppId=component.get("v.WrapperData.Id");
            var quotes = component.get("v.quoteList"); 
            var leadId = component.get("v.WrapperData.LeadId__c");
            var cc = JSON.stringify(quotes);
            var action = component.get("c.updateQuotes");
            action.setParams({
                quoteWrapperList: cc,
                quoteType:quoteType,
                OppId:oppId,
                leadId:leadId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var ret = response.getReturnValue();
                if (ret.errorMessage != null && ret.errorMessage.includes("At least")) {
                    component.set("v.showError",true);
                    component.set("v.message",ret.errorMessage); 
                }else{
                    component.set("v.ishide",true);
                    component.set("v.isSaveBtnDisabled",true);
                    component.set("v.showError",false);
                    helper.getGroupQuotes(component,event);
                } 
               $A.util.addClass(spinner, 'slds-hide');
            });
            $A.enqueueAction(action);
        helper.scrollTop(component, event, 50);    
    }, 
    
    ResendQuote: function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var isDownloadOrResend = 'Resend';
        var quoteList = component.get("v.quoteList");
        var selectedQuotesList = JSON.stringify(component.get("v.selectedQuotes"));
        var oppId=component.get("v.WrapperData.Id");
        var isPdf = 'No';
        var action = component.get("c.selectedQuotes");
        action.setParams({wrapperList : selectedQuotesList,
                          OppId : oppId});
        action.setCallback(this, function(response){
            var state = response.getState();  
            if(state === "SUCCESS"){
                helper.sendEmail(component, event, isPdf, isDownloadOrResend);
            }
        });
        $A.enqueueAction(action);
   
    },
    
    DownloadButton : function(component, event, helper){
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var isDownloadOrResend = 'Download';
        var quoteList = component.get("v.quoteList");
        var selectedQuotesList = JSON.stringify(component.get("v.selectedQuotes"));
        var oppId=component.get("v.WrapperData.Id");
        var isPdf = 'Yes';
        var action = component.get("c.selectedQuotes");
        action.setParams({wrapperList : selectedQuotesList,
                          OppId : oppId});
        action.setCallback(this, function(response){
            var state = response.getState();  
            if(state === "SUCCESS"){
                helper.sendEmail(component, event, isPdf, isDownloadOrResend);
            }
        });
        $A.enqueueAction(action);
        
    },
    
    handleOnchange : function(component, event, helper){
        var selectedQuotes = component.get("v.quoteList");
        var selectedQuotesCount = component.get("v.selectedQuotesCount");
        var selectedOption = event.getSource().get("v.value");
        var selectedQuotesList = component.get("v.selectedQuotes");
        var values =[];
        
        for (var i = 0; i < selectedQuotes.length; i++) {
            if (selectedQuotes[i].isChecked) {
                values.push(selectedQuotes[i]);
            }
            
        }
        component.set("v.selectedQuotes",values);
        if(values.length > 0){
            component.set("v.isResendBtnDisabled",false);
        }
        else{
            component.set("v.isResendBtnDisabled",true);
        }

        component.set("v.selectedQuotesCount", selectedQuotesCount);
        component.set("v.ResendsuccessMsg",false);
        component.set("v.DownloadsuccessMsg",false);
        component.set("v.ResedDownLoadDefaultBtn",true);
        
    },
    
    
})