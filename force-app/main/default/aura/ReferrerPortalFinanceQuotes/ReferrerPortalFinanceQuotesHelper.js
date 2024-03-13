({
	getGroupQuotes : function(component, event) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
		var oppId=component.get("v.WrapperData.Id");
        var action = component.get("c.GroupQuotes");
        action.setParams({OppId : oppId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                var qtValues=[];
                for(var key in ret){
                    qtValues.push(ret[key]);
                }
                component.set("v.quoteList",qtValues);
                component.set("v.quotesize",qtValues.length);
                component.set("v.isValue",true);
            }
            else if (state === "INCOMPLETE") {
                //console.log("INCOMPLETE RESPONSE");
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //console.log("Error message: " + 
                                   // errors[0].message);
                    }
                } else {
                    //console.log("Unknown error");
                }
            }
           $A.util.addClass(spinner, 'slds-hide');
        });
        $A.enqueueAction(action);
	},
    
    sendEmail : function(component, event, isPdf, isDownloadOrResend){
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var quoteList = component.get("v.quoteList");
        var selectedQuotesList = JSON.stringify(component.get("v.selectedQuotes"));
        var oppId=component.get("v.WrapperData.Id");
        var leadId=component.get("v.WrapperData.LeadId__c");
        //alert(leadId);
        var conId = component.get("v.WrapperData.ReferredByContact__c");
        var custEmail = component.get("v.WrapperData.Applicant_1_Email__c");
        var refEmail = component.get("v.WrapperData.ReferredByContact__r.Email");
        var action = component.get("c.sendQuotes");
        action.setParams({wrapperList : selectedQuotesList,
                          OppId : oppId,
                          conId : conId,
                          custEmail : custEmail,
                          refEmail : refEmail,
                          isPdf : isPdf
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(isDownloadOrResend == 'Resend'){
                    quoteList.forEach(function(item) {
                        item.isChecked = false;
                    });
                    component.set("v.quoteList", quoteList);
                    component.set("v.DownloadsuccessMsg",false);
                    component.set("v.ResendsuccessMsg",true);
                    component.set("v.ResedDownLoadDefaultBtn",false);
                }
                else if(isDownloadOrResend == 'Download'){
                    quoteList.forEach(function(item) {
                        item.isChecked = false;
                    });
                    component.set("v.quoteList", quoteList);
                    component.set("v.DownloadsuccessMsg",true);
                    component.set("v.ResendsuccessMsg",false);
                    component.set("v.ResedDownLoadDefaultBtn",false);
                }
            }
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE RESPONSE");
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            } 
            $A.util.addClass(spinner, 'slds-hide');
        });
        $A.enqueueAction(action);
        component.set("v.selectedQuotes",[]);
    },
    
    scrollTop: function (component, event, top){
        var scrollOptions = {
            left: 0,
            top: top,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    }
})