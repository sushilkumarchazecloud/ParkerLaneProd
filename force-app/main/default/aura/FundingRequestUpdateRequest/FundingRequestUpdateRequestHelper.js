({ 
    Submit : function(component, event, helper, cmbBoxVal){
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        
        var recordId = component.get("v.recordId"); 
        var invcAmt = component.get("v.invoiceAmount");
        var part_pmt_Amt = component.get("v.partPaymentAmt");
        var instln_dt = component.get("v.AnticipatedInstDate");
        var req_amt;
        
        if(cmbBoxVal == 'Part payment before installation' || cmbBoxVal == 'Remainder of payment after installation'){
            req_amt = part_pmt_Amt;
        }   
        else if(cmbBoxVal != null){
            req_amt = invcAmt;
        }
        
        var action = component.get("c.UpdateFundingRequest");
        action.setParams({ recId : recordId,
                          invoice_amount : invcAmt,
                          reqType : cmbBoxVal, 
                          req_amount : req_amt,
                          Inst_Date : instln_dt,
                         });
        
        action.setCallback(this,function(response){
            var ret = response.getReturnValue();
            var state = response.getState(); 
            if (state === "SUCCESS") {
                var msg = 'Funding Rquest Successfully Updated.';
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
    
    getFunding : function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var recordId = component.get("v.recordId");
        var action = component.get("c.getFundingOnHandOverPopUp");
        action.setParams({ 
            recId : recordId
        }); 
        action.setCallback(this,function(response) 
                           {
                               var  ret = response.getReturnValue();
                               if(ret != null && ret.Request_Type__c != 'Remainder of payment after installation'){
                                   component.set("v.openModal",true);
                                   component.set("v.remainderRequest",false);
                                   component.set("v.CustomerAmount",ret.Opportunity__r.SyncedQuote.Customer_Amount__c);
                                   component.set("v.invoiceAmount",ret.Invoice_Amount__c);
                                   component.set("v.comboBoxValue",ret.Request_Type__c);
                                   if(ret.Request_Type__c == 'Part payment before installation'){
                                       component.set("v.partPaymentAmt",ret.Request_Amount__c); 
                                   }
                                   component.set("v.AnticipatedInstDate",ret.Installation_Date__c);
                                   if(ret.Request_Type__c != 'Variation'){
                                       helper.inVoiceChange(component, event, helper);
                                   }
                                   else if(ret.Request_Type__c == 'Variation'){
                                       helper.addVariation(component, event, helper);
                                   }
                               }
                               else if(ret != null && ret.Request_Type__c == 'Remainder of payment after installation'){
                                   helper.getPreviousFundingRequest(component, event, helper,ret.Opportunity__c);
                                   component.set("v.openModal",true);
                                   component.set("v.remainderRequest",true);
                                   component.set("v.partPaymentAmt",ret.Request_Amount__c);
                               }
                               $A.util.addClass(spinner, 'slds-hide');
                           });
        $A.enqueueAction(action);
    },
    
    getPreviousFundingRequest : function(component, event, helper,oppId) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var recordId = component.get("v.recordId");
        var action = component.get("c.getOldRequest");
        action.setParams({ 
            oppId : oppId,
            recId : recordId
        }); 
        
        action.setCallback(this,function(response) 
                           {
                               var  ret = response.getReturnValue();
                               if(ret != null){
                                   component.set("v.fundsPaidToDate",ret.Request_Amount__c);
                                   component.set("v.fundsRemaining",ret.Net_Funds_after_Request__c);
                                   component.set("v.invoiceAmount",ret.Invoice_Amount__c);
                                   helper.partpaymentError(component, event, helper);
                               }
                           });
        $A.enqueueAction(action);
    }, 
    
    addVariation : function(component, event, helper) {
        var comboOBoxptions = component.get("v.comboOBoxptions");
        // Check if "Variation" option already exists in the options
        var variationExists = comboOBoxptions.some(function (option) {
            return option.value === "Variation";
        });
        
        if (!variationExists) { 
            // Add "Variation" option to comboOBoxptions
            comboOBoxptions.push({ label: "Variation", value: "Variation" });
            component.set("v.comboOBoxptions", comboOBoxptions);
        }
    },
    
    inVoiceChange : function(component, event, helper) {
        var fund_available = component.get("v.CustomerAmount");
        var invoiceAmount = component.get("v.invoiceAmount");
        var comboOBoxptions = component.get("v.comboOBoxptions");
        if (invoiceAmount > fund_available) {
            // Check if "Variation" option already exists in the options
            var variationExists = comboOBoxptions.some(function (option) {
                return option.value === "Variation";
            });
            
            if (!variationExists) {
                // Add "Variation" option to comboOBoxptions
                comboOBoxptions.push({ label: "Variation", value: "Variation" });
                component.set("v.comboOBoxptions", comboOBoxptions);
            }
        } 
        else {
            // Remove "Variation" option from comboOBoxptions
            var updatedOptions = comboOBoxptions.filter(function (option) {
                return option.value !== "Variation";
            });
            component.set("v.comboOBoxptions", updatedOptions);
        }  
        
    },
    
    partpaymentError : function(component, event, helper) {
     var full_amt = component.get("v.fundsRemaining");
        var part_amt = component.get("v.partPaymentAmt");  
        
        if(full_amt != null && part_amt > full_amt && part_amt != null ){
            component.set("v.partPmtError",true);
        }
        else{
            component.set("v.partPmtError",false);
        } 
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