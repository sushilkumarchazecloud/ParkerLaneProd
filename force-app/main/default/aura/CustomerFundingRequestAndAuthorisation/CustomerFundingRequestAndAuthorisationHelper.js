({
    getFunding : function(component, event) {
        var self = this;
        var spinner = component.find("mySpinner");
        var op = component.get("v.opportunityId");
        //alert(op);
        var action = component.get("c.getfundRequest2");
        action.setParams({
            oppId : op
        });
        action.setCallback(this, function(response) {
            var ret = response.getReturnValue();
            var fundingList = ret.fundReqlist;
            component.set("v.totalFunds",ret.totalFunds);
            component.set("v.opp",ret.Opportunity);
            if(ret.Opportunity.Referred_by_Company__c != null){
                component.set("v.referedCompany",ret.Opportunity.Referred_by_Company__r.Name);
            }
            var applicantId = component.get("v.applicantId");
            if(ret.app2 == null){
                component.set("v.isTwoPerson",false);
            }
            if(applicantId == ret.app1){
                component.set("v.applicant1",true);
            }
            else if(applicantId == ret.app2){
                component.set("v.applicant2",true);
            }
            if(ret.isLenderCredit){
                component.set("v.isCreditLender",true);
            }
            else{
                component.set("v.isCreditLender",false);
            }
            //alert(component.get("v.isCreditLender"));
            if(fundingList.length == 0 ){
                //alert(ret.isExpired);
                if(ret.isExpired){
                    var successmsg = 'Oops! Ours records indicate that your loan approval has expired. But don\'t stress, if you\'d like to resurrect your approval, simply reach out to us via any of these methods:';
                    component.set("v.isformDisabled",true);
                    component.set("v.successMessage",successmsg);
                    component.set("v.imageName",'ReferrerTODO.png');
                    component.set("v.isFormView",false);
                    component.set("v.isSucessView",true);
                    component.set("v.isApproved",true); 
                }
                else{
                    component.set("v.fundingRequest",{ sobjectType: "Funding_Request__c"});
                    component.set("v.isCustomer",true);
                    component.set("v.isFormView",true);
                    component.set("v.isSecond",false);
                    component.set("v.requestType",'Payment in full after installation');
                    component.set("v.requestedBy",'Request payment to your supplier.');
                    var message ='Complete this form to authorise payment to your chosen supplier. Be sure to read the form carefully and make certain that the uploaded invoice has the correct payment details.';
                    component.set("v.welcomeMessage",message);
                    var signAllowed = ret.authoType;
                    var auth_type;
                    if(signAllowed != null && signAllowed.includes('Both to sign') && !signAllowed.includes('Either to sign')){
                        auth_type = 'Both to sign';  
                    }
                    else if((signAllowed != null && signAllowed.includes('Either to sign')) || signAllowed == null){ 
                        var Opp_Signs = ret.tmcu;
                        if(Opp_Signs == null || Opp_Signs == '' || Opp_Signs== 'either to sign'){
                            auth_type = 'Either to sign'; 
                        } 
                        else if(Opp_Signs== 'both to sign'){
                            auth_type = 'Both to sign';
                        }
                    }
                    component.set("v.toSign",auth_type);
                }
            }
            else if(fundingList.length == 1 ){
                if(!ret.isExpired){
                    var isVariationBefore;
                    if(fundingList[0].Surplus_Shortfall_Treatment__c == 'Variation to contract (requires re-approval)'){
                        isVariationBefore = true;
                    }
                    component.set("v.fundingRequest",fundingList[0]);
                    var op = component.get("v.opp");
                    var reqType = fundingList[0].Request_Type__c;
                    var reqStatus = fundingList[0].Request_Status__c;
                    var reqBy = fundingList[0].Requested_by__c;
                    var authoStatus = fundingList[0].Customer_Authorisation_Status__c;
                    var personReq = fundingList[0].Person_Requesting__r.Name;
                    component.set("v.requestType",reqType);
                    if(reqBy == 'Customer'){
                        component.set("v.requestedBy",'Request payment to your supplier.');
                    }
                    if(reqType != 'Variation'){
                        self.SurplusShow(component, event);
                    }
                    if(reqType == 'Part payment before installation'){
                        component.set("v.isPartpayment",true);
                    }
                    if(reqType == 'Remainder of payment after installation'){
                        component.set("v.isSecond",true);
                    }
                    if((reqType == 'Payment in full before installation' || reqType == 'Payment in full after installation' || reqType == 'Part payment before installation' || reqType == 'Remainder of payment after installation')){
                        if(authoStatus == 'Pending Applicant 2' && applicantId == ret.app1){
                            var successmsg = 'Action Required! Your co-applicant '+op.Applicant_2__r.Name+' is also required to authorise funding. We’ve sent them an email - please prompt them to authorise funding so we can make payments as per your instructions.';
                            component.set("v.isformDisabled",true);
                            component.set("v.successMessage",successmsg);
                            component.set("v.imageName",'ReferrerTODO.png');
                            component.set("v.isFormView",false);
                            component.set("v.isSucessView",true);   
                        }
                        else if(authoStatus == 'Pending Applicant 1' && applicantId == ret.app2){
                            var successmsg = 'Action Required! Your co-applicant '+op.Applicant_1__r.Name+' is also required to authorise funding. We’ve sent them an email - please prompt them to authorise funding so we can make payments as per your instructions.';
                            component.set("v.isformDisabled",true);
                            component.set("v.successMessage",successmsg);
                            component.set("v.imageName",'ReferrerTODO.png');
                            component.set("v.isFormView",false);
                            component.set("v.isSucessView",true);
                        }
                            else if((authoStatus == 'Pending Applicant 1' && applicantId == ret.app1) || (authoStatus == 'Pending Applicant 2' && applicantId == ret.app2)){
                                var welmsg = personReq+' has requested '+reqType+' and your consent is also required. Please read the following carefully and if you agree, authorise payment by submitting this form.';
                                component.set("v.welcomeMessage",welmsg);
                                component.set("v.isFormView",true);
                                component.set("v.isSucessView",false);
                                component.set("v.isformDisabled",true);   
                            }
                        
                                else if(authoStatus == 'Request sent to customer(s)'){
                                    var message;
                                    if(reqBy == 'Customer'){
                                         message ='Complete this form to authorise payment to your chosen supplier. Be sure to read the form carefully and make certain that the uploaded invoice has the correct payment details.';
                                    }
                                    else{
                                        var company = component.get("v.referedCompany");
                                        message ='The team at '+company+' have now requested '+reqType+'.'+' Please read the following carefully and if you agree, authorise payment by submitting this form.'
                                    }
                                    component.set("v.welcomeMessage",message);
                                    component.set("v.isFormView",true);
                                    component.set("v.isSucessView",false);
                                    component.set("v.isformDisabled",false);
                                }
                                    else if(authoStatus == 'Authorised'){
                                        var successmsg = 'Relax! There’s nothing else you need to do. Your authorisation has been sent to '+ret.Opportunity.SyncedQuote.Lender__c+'.'+' We’ll let you know when funds have been transferred.';
                                        component.set("v.successMessage",successmsg);
                                        component.set("v.imageName",'Greentick.png');
                                        component.set("v.isFormView",false);
                                        component.set("v.isSucessView",true);
                                        component.set("v.isformDisabled",true);
                                    }  
                    }
                    else if(fundingList[0].Request_Type__c == 'Variation'){
                        if(fundingList[0].Variation_Requested_By__c == applicantId && op.Applicant_2__c!=null){
                            var applicantName;
                            if(fundingList[0].Variation_Requested_By__c == op.Applicant_1__c){
                                applicantName = op.Applicant_2__r.Name;
                            }
                            else if(fundingList[0].Variation_Requested_By__c == op.Applicant_2__c){
                                applicantName = op.Applicant_1__r.Name;
                            }
                            var msg = 'Your file has been sent back to our credit team and we’ve let '+applicantName+' know. We may require more information from you to complete your request. We’ll be in touch shortly with an update.';
                            component.set("v.successMessage",msg);
                            component.set("v.imageName",'Greentick.png');
                            component.set("v.isFormView",false);
                            component.set("v.isSucessView",true);
                            component.set("v.isformDisabled",true);
                        } 
                        if(op.Applicant_2__c == null){
                            var msg = 'Your file has been sent back to our credit team. We may require more information from you to complete your request. We’ll be in touch shortly with an update.';
                            component.set("v.successMessage",msg);
                            component.set("v.imageName",'Greentick.png');
                            component.set("v.isFormView",false);
                            component.set("v.isSucessView",true);
                            component.set("v.isformDisabled",true);
                        }
                        if((fundingList[0].Variation_Requested_By__c != applicantId) && (applicantId == op.Applicant_1__c || applicantId == op.Applicant_2__c)){
                            var msg = fundingList[0].Variation_Requested_By__r.Name+' has requested to increase your approved limit and there’s nothing required from you at the moment. Your variation details are below. We’ll let you know when it’s time to authorise payment.';
                            component.set("v.totalFunds",fundingList[0].Request_Amount__c - fundingList[0].Variation_Amount__c);
                            component.set("v.welcomeMessage",msg);
                            component.set("v.isFormView",true);
                            component.set("v.isSucessView",false);
                            component.set("v.isformDisabled",true);
                            component.set("v.isvarBtnDisabled",false);
                            component.set("v.istoggleDisabled",true);
                            component.find("tglbt4").set("v.checked",true);
                        }
                    }
                }
                else{
                    var successmsg = 'Oops! Ours records indicate that your loan approval has expired. But don\'t stress, if you\'d like to resurrect your approval, simply reach out to us via any of these methods:';
                    component.set("v.isformDisabled",true);
                    component.set("v.successMessage",successmsg);
                    component.set("v.imageName",'ReferrerTODO.png');
                    component.set("v.isFormView",false);
                    component.set("v.isSucessView",true);
                    component.set("v.isApproved",true);
                }
            }
            $A.util.addClass(spinner, "slds-hide");
        });
        $A.enqueueAction(action);
    },
    
    SurplusShow : function(component, event) {
        var shorfallInstructions = component.get("v.opp.SyncedQuote.Product__r.Short_Fall_Instructions__c");
        var SurplusInstructions = component.get("v.opp.SyncedQuote.Product__r.Surplus_Instructions__c");
        var invoiceamount = component.get("v.fundingRequest.Invoice_Amount__c");
        var customerAmt = component.get("v.totalFunds");
        
        var srpamt = customerAmt - invoiceamount;
        if(invoiceamount ==  null || invoiceamount == 0){
            var newsrpamt = '$0';
            component.set("v.surplusAmount",newsrpamt);
            component.set("v.isShortfall",false);
            component.set("v.isSurplus",false);
            component.set("v.fundingRequest.Surplus_Shortfall_Treatment__c",null);
            component.set("v.fundingRequest.Variation_Type__c",null);
        }
        else if(srpamt > 1){
            var newsrpamt = '+$'+srpamt.toLocaleString();
            component.set("v.surplusAmount",newsrpamt);
            component.set("v.isShortfall",false);
            component.set("v.isSurplus",true);
            component.set("v.fundingRequest.Surplus_Shortfall_Treatment__c",null);
            component.set("v.fundingRequest.Variation_Type__c",null);
        }
            else if(srpamt < 1 && srpamt != 0){
                var newsrpamt = '-$'+(srpamt * -1).toLocaleString();
                component.set("v.surplusAmount",newsrpamt);
                component.set("v.isShortfall",true);
                component.set("v.isSurplus",false);
                //component.set("v.CmbBoxValcontract",null);
            }
                else if (srpamt == 0){
                    var newsrpamt = '$0';
                    component.set("v.surplusAmount",newsrpamt); 
                    component.set("v.isShortfall",false);
                    component.set("v.isSurplus",false);
                    component.set("v.fundingRequest.Surplus_Shortfall_Treatment__c",null);
                    component.set("v.fundingRequest.Variation_Type__c",null);
                }
        // Code for Showing ShortFall/Surplus Instructions Condition Based.
        if(srpamt < 0){
            component.set("v.Surplus_ShortFallInstruction",shorfallInstructions);
        }
        else if(srpamt > 0){
            component.set("v.Surplus_ShortFallInstruction",SurplusInstructions);  
        }
    },
    
    getret : function(component, event, helper){
        var action = component.get("c.ret");
        action.setCallback(this,function(response){
            var records = response.getReturnValue();
            component.set('v.quoteDetailWrpList', records);
            component.get('v.quoteDetailWrpList');
        });       
        $A.enqueueAction(action); 
        
    },
    
    getdocument : function(component, event, helper){
        var action1 = component.get("c.getDocument");
        var opp = component.get("v.opportunityId");
        action1.setParams({
            OppId: opp
        });
        action1.setCallback(this, function(response) {
            var records = response.getReturnValue();
            if (response.getState() === "SUCCESS") {
                //  alert(JSON.stringify(records));
                if(records !=null ){
                    var NameList = records.NmList;
                    if(NameList.length > 0){
                        component.set("v.DocExistsORNot",true);
                        component.set("v.DocExist",true);
                        component.set("v.DocWrapper",records);
                    }
                    else{
                        component.set("v.DocExistsORNot",false);
                        component.set("v.DocExist",false);
                    }
                }
                else{
                    component.set("v.DocExistsORNot",false);
                    component.set("v.DocExist",false);
                }
            }
            else if (response.getState() === "ERROR") {
                //alert('Error');
            }
        });
        $A.enqueueAction(action1); 
    },
    
    setSuccessMsg : function(component,event,fundReq,op){
        var msg;
        if(fundReq.Customer_Authorisation_Status__c == 'Pending Applicant 1'){
            msg = 'Action Required! Your co-applicant '+op.Applicant_1__r.Name+' is also required to authorise funding. We’ve sent them an email - please prompt them to authorise funding so we can make payments as per your instructions.';
            component.set("v.successMessage",msg);
            component.set("v.imageName",'ReferrerTODO.png');
            component.set("v.isFormView",false);
            component.set("v.isSucessView",true);
        }
        if(fundReq.Customer_Authorisation_Status__c == 'Pending Applicant 2'){
            msg = 'Action Required! Your co-applicant '+op.Applicant_2__r.Name+' is also required to authorise funding. We’ve sent them an email - please prompt them to authorise funding so we can make payments as per your instructions.';
            component.set("v.successMessage",msg);
            component.set("v.imageName",'ReferrerTODO.png');
            component.set("v.isFormView",false);
            component.set("v.isSucessView",true);
        }
        if(fundReq.Customer_Authorisation_Status__c == 'Authorised'){
            var msg = 'Relax! There’s nothing else you need to do. Your authorisation has been sent to '+op.SyncedQuote.Lender__c+'.'+' We’ll let you know when funds have been transferred.';
            component.set("v.successMessage",msg);
            component.set("v.imageName",'Greentick.png');
            component.set("v.isFormView",false);
            component.set("v.isSucessView",true);
            component.set("v.isformDisabled",true);
        }
    },
    
    variationSuccessMsg : function(component,event,fundReq,op){
        if(op.Applicant_2__c == null){
            var msg = 'Your file has been sent back to our credit team. We may require more information from you to complete your request. We’ll be in touch shortly with an update.';
            component.set("v.successMessage",msg);
            component.set("v.imageName",'Greentick.png');
            component.set("v.isFormView",false);
            component.set("v.isSucessView",true);
            component.set("v.isformDisabled",true);
        }
        else{
            var applicantName;
            if(fundReq.Variation_Requested_By__c == op.Applicant_1__c){
                applicantName = op.Applicant_2__r.Name;
            }
            else if(fundReq.Variation_Requested_By__c == op.Applicant_2__c){
                applicantName = op.Applicant_1__r.Name;
            }
            var msg = 'Your file has been sent back to our credit team and we’ve let '+applicantName+' know. We may require more information from you to complete your request. We’ll be in touch shortly with an update.';
            component.set("v.successMessage",msg);
            component.set("v.imageName",'Greentick.png');
            component.set("v.isFormView",false);
            component.set("v.isSucessView",true);
            component.set("v.isformDisabled",true);
        }
    },
    
    createAuthocertificate : function(component, event, helper){
        var action1 = component.get("c.insertAuthorisationCertificate");
        var opp = component.get("v.opportunityId");
        action1.setParams({
            oppId: opp
        });
        action1.setCallback(this, function(response) {
            var records = response.getReturnValue();
            if (response.getState() === "SUCCESS"){
                console.log('Certificate created');
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
        });
        $A.enqueueAction(action1);
    }
})