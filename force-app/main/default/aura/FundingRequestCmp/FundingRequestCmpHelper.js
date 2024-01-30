({ 
    Submit : function(component, event, helper, cmbBoxVal){
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        
        var oppId = component.get("v.recordId");
        var cstmr_amt = component.get("V.opp.SyncedQuote.Customer_Amount__c"); 
        var invcAmt = component.get("v.invoiceAmount");
        var part_pmt_Amt = component.get("v.partPaymentAmt");
        //  var timing_of_pmt = component.get("v.comboBoxValue");
        var instln_dt = component.get("v.AnticipatedInstDate");
        var req_by = component.get("v.requestBy");
        var req_origin = component.get("v.reqOrigin");
        var cstmr_agree = component.get("v.CustomerAgreedOrNot");
        var person_req =  component.get("v.PersonRquestingValue");
        var req_amt;
        var auth_type;
        
        if(cmbBoxVal == 'Part payment before installation' || cmbBoxVal == 'Remainder of payment after installation'){
            req_amt = part_pmt_Amt;
        }   
        else if(cmbBoxVal != null){
            req_amt = invcAmt;
        }
        
        // Auth Type Code.
        var signAllowed = component.get("v.opp.SyncedQuote.Product__r.No_of_Signatories_allowed__c");
        
        if(signAllowed != null && signAllowed.includes('Both to sign') && !signAllowed.includes('Either to sign')){
            auth_type = 'Both to sign';  
        }
        else if((signAllowed != null && signAllowed.includes('Either to sign')) || signAllowed == null){ 
            var Opp_Signs = component.get("v.opp.Applicant_1__r.Number_of_applicants_to_operate_account__pc");
            if(Opp_Signs == null || Opp_Signs == '' || Opp_Signs== 'either to sign'){
                auth_type = 'Either to sign'; 
            } 
            else if(Opp_Signs== 'both to sign' || signAllowed == null){
                auth_type = 'Both to sign';
            }
        } 
        
        var action = component.get("c.createFundingRequestFromAction");
        action.setParams({ oppId : oppId,
                          invoice_amount : invcAmt,
                          reqType : cmbBoxVal, 
                          req_amount : req_amt,
                          requestBy : req_by,
                          requestOrigin : req_origin,
                          Inst_Date : instln_dt,
                          Csmtr_agreedORSatisfy : cstmr_agree,
                          req_person : person_req,
                          Cstmr_auth_Type : auth_type
                         });
        
        action.setCallback(this,function(response){
            var ret = response.getReturnValue();
            var state = response.getState(); 
            if (state === "SUCCESS") {
                var msg = 'Funding Rquest Successfully created.';
                helper.handleCancel(component, event, helper);
                helper.showMessage(component, "Success",msg , "success");
                component.set("v.openModal",false);
                $A.get("e.force:refreshView").fire();
            }
            else if (state === "ERROR") {
                console.log('Error');
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
    },
    
    checkConditions : function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var recordId = component.get("v.recordId");
        var action = component.get("c.CheckConditions");
        action.setParams({ 
            oppId : recordId
        }); 
        action.setCallback(this,function(response) 
                           {
                               var  ret = response.getReturnValue();
                               if(ret != '' && ret.includes("Success")){
                                   component.set("v.openModal",true);
                                   component.set("v.remainderRequest",false);
                                   helper.getOpp(component, event, helper);
                               }
                               else if(ret != '' && ret.includes("Request for Remainder Payment.")){
                                   component.set("v.openModal",true);
                                   component.set("v.remainderRequest",true);
                                   helper.getOpp(component, event, helper);
                                   helper.getPreviousFundingRequest(component, event, helper);
                               }
                                   else{
                                       component.set("v.openModal",false);
                                       component.set("v.remainderRequest",false);
                                       helper.handleCancel(component, event, helper);
                                       helper.showMessage(component, "Error", ret, "error");   
                                   }
                               $A.util.addClass(spinner, 'slds-hide');
                           });
        $A.enqueueAction(action);
    },
    
    getOpp : function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var recordId = component.get("v.recordId");
        var action = component.get("c.getOpp");
        action.setParams({ 
            oppId : recordId
        }); 
        
        action.setCallback(this,function(response) 
                           {
                               var  ret = response.getReturnValue();
                               if(ret != null){
                                   component.set("v.opp",ret);
                                   
                                   //Removing Supplier option from request By when external Referrer = null. 
                                   var reqByOptions = component.get("v.reqByOptions");
                                   if(ret.FinServ__ReferredByContact__c == null){
                                       var updatedOptions = reqByOptions.filter(function (option) {
                                           return option.value !== "Supplier";
                                       });
                                       component.set("v.reqByOptions", updatedOptions);   
                                   }
                                   
                                   //Code for PersonRquestingOptions Adding Condition Based.
                                   var PersonRquestingOptions = component.get("v.PersonRquestingOptions");
                                   if(ret.Applicant_2__c != null){
                                       PersonRquestingOptions.push({ label: "Applicant 2", value: "Applicant 2" });
                                       component.set("v.PersonRquestingOptions", PersonRquestingOptions);  
                                   }
                                   if(ret.FinServ__ReferredByContact__c != null){
                                       PersonRquestingOptions.push({ label: "Referrer", value: "Referrer" });
                                       component.set("v.PersonRquestingOptions", PersonRquestingOptions);  
                                   }
                               }
                           });
        $A.enqueueAction(action);
    }, 
    
    getPreviousFundingRequest : function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var recordId = component.get("v.recordId");
        var action = component.get("c.getFundingRequest");
        action.setParams({ 
            oppId : recordId
        }); 
        
        action.setCallback(this,function(response) 
                           {
                               var  ret = response.getReturnValue();
                               component.set("v.fundsPaidToDate",ret.Request_Amount__c);
                               component.set("v.fundsRemaining",ret.Net_Funds_after_Request__c);
                               component.set("v.invoiceAmount",ret.Invoice_Amount__c);
                           });
        $A.enqueueAction(action);
    }, 
    
    showMessage: function(component, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type
        });
        toastEvent.fire();
    },
    
    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})