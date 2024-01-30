({
    doInit : function(component, event, helper){
        //alert(component.get("v.sessionId"));
        helper.getFunding(component, event);
        helper.getret(component, event, helper);
        helper.getdocument(component, event, helper);
    },


    checkInvoice :  function(component, event, helper){
        var sourceField = event.getSource().getLocalId();
        if(sourceField == 'cmbid'){
            if(component.get("v.DocExist")){
                helper.getdocument(component, event, helper);
                component.set("v.DocExistsORNot",true);
            }
            else{
                helper.getret(component, event, helper);
                component.set("v.DocExistsORNot",false);
            }
        }
        
        //alert('doc'+component.get("v.DocExistsORNot"));
        //alert('doc'+component.get("v.DocExist"));
        helper.SurplusShow(component, event);
        var invoice = component.get("v.fundingRequest.Invoice_Amount__c");
        var isShortfall = component.get("v.isShortfall");
        if(!isShortfall){
            var tgle1 = component.find("tglbtn1").get("v.checked");
            var tgle2 = component.find("tglbtn2").get("v.checked");
            var tgle3 = component.find("tglbtn3").get("v.checked");
            //alert(tgle1);
            if(invoice && tgle1 && tgle2 && tgle3){
                component.set("v.isSavebtnDisabled",false);
            }
            else{
                component.set("v.isSavebtnDisabled",true);
            }
        }
        else{
            var cmbValue = component.get("v.fundingRequest.Surplus_Shortfall_Treatment__c");
            if(cmbValue != 'Variation to contract (requires re-approval)' && cmbValue!=null){
                var tgle1 = component.find("tglbtn1").get("v.checked");
                var tgle2 = component.find("tglbtn2").get("v.checked");
                var tgle3 = component.find("tglbtn3").get("v.checked");
                if(invoice && tgle1 && tgle2 && tgle3){
                    component.set("v.isSavebtnDisabled",false);
                }
                else{
                    component.set("v.isSavebtnDisabled",true);
                }
            }
            else if(cmbValue == 'Variation to contract (requires re-approval)'){
                var tgle1 = component.find("tglbt4").get("v.checked");
                if(tgle1 && invoice){
                    component.set("v.iscreditbtnDisabled",false);
                }
                else{
                    component.set("v.iscreditbtnDisabled",true);
                }
            }
            else if(cmbValue == null){
                if(component.get("v.isSecond")){
                    var tgle1 = component.find("tglbtn1").get("v.checked");
                    var tgle2 = component.find("tglbtn2").get("v.checked");
                    var tgle3 = component.find("tglbtn3").get("v.checked");
                    if(tgle1 && tgle2 && tgle3){
                        component.set("v.isSavebtnDisabled",false);
                    }
                    else{
                        component.set("v.isSavebtnDisabled",true);
                    }
                }
                else{
                    component.set("v.isSavebtnDisabled",true);
                }       
            }
        }
    },
     
    submitRequest : function(component, event, helper){
        var docExist = component.get("v.DocExist");
        if(docExist){
            var spinner = component.find("mySpinner");
            $A.util.removeClass(spinner, "slds-hide");
            component.set("v.DocError",false); 
            var fundReq = component.get("v.fundingRequest");
            var todayDate = new Date();
            var isCustomerReq = component.get("v.isCustomer");
            var isCreditLender = component.get("v.isCreditLender");
            var isShortfall = component.get("v.isShortfall");
            var isSurplus = component.get("v.isSurplus");
            var surplusAmount = component.get("v.surplusAmount");
            var isApp1 = component.get("v.applicant1");
            var isApp2 = component.get("v.applicant2");
            var appId =  component.get("v.applicantId");
            var op = component.get("v.opp");
            var whoSign = component.get("v.toSign");
            var invoiceamount = component.get("v.fundingRequest.Invoice_Amount__c");
            var customerAmt = component.get("v.totalFunds");
            var line1 = "Yes - I have recived, read and agree to be bound by the terms of credit contract sent to me by LENDER.";
            var line2 = "Yes - The invoice attached contains the correct Supplier and payment details.";
            var line3 = 'Yes - I authorise lender to make ' + component.get("v.requestType") + ' in amount of '+surplusAmount+' to the Supplier.';
            var text = line1 + "\n" + line2 + "\n" + line3;
            if(isCustomerReq){
                fundReq.Opportunity__c = component.get("v.opportunityId");
                fundReq.Request_Type__c = 'Payment in full after installation';
                fundReq.Previous_Req_Type__c = 'Payment in full after installation';
                fundReq.Request_Amount__c = fundReq.Invoice_Amount__c;
                fundReq.Requested_by__c = 'Customer';
                fundReq.Request_Date__c = todayDate.toJSON();
                fundReq.Net_Surplus_Shortfall__c = Math.abs(customerAmt - invoiceamount);
                fundReq.Applicant_1_A1__c = component.get("v.opp.Applicant_1__c");
                fundReq.Applicant_2_A2__c = component.get("v.opp.Applicant_2__c");
                fundReq.Contact_1__c = component.get("v.opp.Applicant_1__r.PersonContactId");
                fundReq.Contact_2__c = component.get("v.opp.Applicant_2__r.PersonContactId");
                if(isShortfall){
                    fundReq.Surplus_Shortfall_Treatment__c = "Shortfall paid with customer’s own funds";
                }
                else if(isSurplus){
                    fundReq.Surplus_Shortfall_Treatment__c = "Retain surplus funds in loan account";
                }
                if(isCreditLender){
                    fundReq.Request_Status__c ='Payment requested by customer';
                }
                else{
                    fundReq.Request_Status__c ='Payment requested by customer (pending contract)';
                }
                fundReq.Variation_Type__c = null;
                if(isApp1){
                    fundReq.Person_Requesting__c = component.get("v.opp.Applicant_1__r.PersonContactId");
                    fundReq.A1_Acknowledgments__c = text;
                    fundReq.A1_Payment_Authorisation_Submitted_Date__c = todayDate.toJSON();
                    if(whoSign == 'Both to sign'){
                        fundReq.Customer_Authorisation_Type__c ='Both to sign';
                        if(component.get("v.isTwoPerson")){
                            fundReq.Customer_Authorisation_Status__c = 'Pending Applicant 2';
                        }
                        else{
                            fundReq.Customer_Authorisation_Status__c = 'Authorised';
                            if(isCreditLender){
                                fundReq.Request_Status__c ='Payment authorised by customer';
                            }
                        }
                    }
                    else if(whoSign == 'Either to sign'){
                        fundReq.Customer_Authorisation_Type__c ='Either to sign';
                        fundReq.Customer_Authorisation_Status__c ='Authorised';
                        if(isCreditLender){
                            fundReq.Request_Status__c ='Payment authorised by customer';
                        }
                    }
                }
                else if(isApp2){
                    //alert(isCreditLender);
                    fundReq.Person_Requesting__c = component.get("v.opp.Applicant_2__r.PersonContactId");
                    fundReq.A2_Acknowledgments__c = text;
                    fundReq.A2_Payment_Authorisation_Submitted_Date__c = todayDate.toJSON();
                    if(whoSign == 'Both to sign'){
                        fundReq.Customer_Authorisation_Type__c ='Both to sign';
                        fundReq.Customer_Authorisation_Status__c ='Pending Applicant 1';
                    }
                    else if(whoSign == 'Either to sign'){
                        fundReq.Customer_Authorisation_Type__c ='Either to sign';
                        fundReq.Customer_Authorisation_Status__c ='Authorised';
                        if(isCreditLender){
                            fundReq.Request_Status__c ='Payment authorised by customer';
                        }
                    }
                }
            }
            else{
                var fundReq = component.get("v.fundingRequest");
                fundReq.Applicant_1_A1__c = component.get("v.opp.Applicant_1__c");
                fundReq.Applicant_2_A2__c = component.get("v.opp.Applicant_2__c");
                fundReq.Variation_Type__c = null;
               //alert(fundReq.Customer_Authorisation_Status__c);
                if(isShortfall){
                    fundReq.Surplus_Shortfall_Treatment__c = "Shortfall paid with customer’s own funds";
                }
                else if(isSurplus){
                    fundReq.Surplus_Shortfall_Treatment__c = "Retain surplus funds in loan account";
                }
                if(isApp1){
                    fundReq.A1_Acknowledgments__c = text;
                    fundReq.A1_Payment_Authorisation_Submitted_Date__c = todayDate.toJSON();
                    if(fundReq.Customer_Authorisation_Status__c == 'Request sent to customer(s)'){
                        if(component.get("v.isTwoPerson")){
                            if(fundReq.Customer_Authorisation_Type__c == 'Either to sign'){
                                fundReq.Customer_Authorisation_Status__c = 'Authorised';
                                if(isCreditLender){
                                    fundReq.Request_Status__c ='Payment authorised by customer';
                                }
                            }
                            else if(fundReq.Customer_Authorisation_Type__c == 'Both to sign'){
                                fundReq.Customer_Authorisation_Status__c = 'Pending Applicant 2';
                            }
                        }
                        else{
                            fundReq.Customer_Authorisation_Status__c = 'Authorised';
                            if(isCreditLender){
                                fundReq.Request_Status__c ='Payment authorised by customer';
                            }
                        }
                    }
                    else if(fundReq.Customer_Authorisation_Status__c == 'Pending Applicant 1'){
                        fundReq.Customer_Authorisation_Status__c = 'Authorised';
                        if(isCreditLender){
                            fundReq.Request_Status__c ='Payment authorised by customer';
                        }
                    }
                }
                else if(isApp2){
                    fundReq.A2_Acknowledgments__c = text;
                    fundReq.A2_Payment_Authorisation_Submitted_Date__c = todayDate.toJSON();
                    if(fundReq.Customer_Authorisation_Status__c == 'Request sent to customer(s)'){
                        if(fundReq.Customer_Authorisation_Type__c == 'Either to sign'){
                            fundReq.Customer_Authorisation_Status__c = 'Authorised';
                            if(isCreditLender){
                                fundReq.Request_Status__c ='Payment authorised by customer';
                            }
                        }
                        else if(fundReq.Customer_Authorisation_Type__c == 'Both to sign'){
                            fundReq.Customer_Authorisation_Status__c = 'Pending Applicant 1'; 
                        }  
                    }
                    else if(fundReq.Customer_Authorisation_Status__c == 'Pending Applicant 2'){
                        fundReq.Customer_Authorisation_Status__c = 'Authorised';
                        if(isCreditLender){
                            fundReq.Request_Status__c ='Payment authorised by customer';
                        }
                    }
                }
            }
            var action = component.get("c.createReqest");
            action.setParams({
                fundRequest : fundReq
            });
            action.setCallback(this, function(response){
                //var ret = response.getReturnValue();
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    if(fundReq.Request_Status__c == 'Payment authorised by customer'){
                        helper.createAuthocertificate(component, event, helper); 
                    }
                    helper.setSuccessMsg(component,event,fundReq,op);
                    //component.set("v.isFormView",false);
                    component.set("v.isSavebtnDisabled",true);
                    component.set("v.isformDisabled",true);
                    component.set("v.istoggleDisabled",true);
                    component.set("v.isCustomer",false);
                }
                else if (state === "ERROR") {
                   // alert('Error');
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } 
                }
                $A.util.addClass(spinner, "slds-hide");
            });
            $A.enqueueAction(action);
        }
        else{
            component.set("v.DocError",true);   
        }
         
    },
    
    submitVariation: function(component, event, helper) {
        var docExist = component.get("v.DocExist");
        if(docExist){
            var spinner = component.find("mySpinner");
            $A.util.removeClass(spinner, "slds-hide");
            component.set("v.DocError",false);
            var fundReq = component.get("v.fundingRequest");
            var todayDate = new Date();
            var invoiceamount = component.get("v.fundingRequest.Invoice_Amount__c");
            var customerAmt = component.get("v.totalFunds");
            var op = component.get("v.opp");
            fundReq.Opportunity__c = component.get("v.opportunityId");
            fundReq.Variation_Type__c = 'Loan amount increase';
            fundReq.Variation_Status__c = 'Requested by customer';
            fundReq.Request_Type__c = 'Variation';
            fundReq.Request_Status__c = 'Variation requested by customer';
            fundReq.Variation_Amount__c = Math.abs(customerAmt - invoiceamount);
            //fundReq.Request_Amount__c = invoiceamount;
            fundReq.Net_Surplus_Shortfall__c = Math.abs(customerAmt - invoiceamount);
            fundReq.New_Customer_Amount__c = invoiceamount;
            fundReq.Variation_Requested_By__c = component.get("v.applicantId");
            fundReq.Applicant_1_A1__c = component.get("v.opp.Applicant_1__c");
            fundReq.Applicant_2_A2__c = component.get("v.opp.Applicant_2__c");
            fundReq.Contact_1__c = component.get("v.opp.Applicant_1__r.PersonContactId");
            fundReq.Contact_2__c = component.get("v.opp.Applicant_2__r.PersonContactId");
            if(component.get("v.isCustomer")){
               //fundReq.Previous_Req_Type__c = 'Payment in full after installation';
               fundReq.Customer_Authorisation_Type__c = component.get("v.toSign");
               fundReq.Customer_Authorisation_Status__c = 'Request sent to customer(s)';
               fundReq.Request_Amount__c = invoiceamount;
               fundReq.Requested_by__c = 'Customer';
               fundReq.Request_Date__c = todayDate.toJSON();
                if(component.get("v.applicant1")){
                    fundReq.Person_Requesting__c = component.get("v.opp.Applicant_1__r.PersonContactId");
                }
                else if(component.get("v.applicant2")){
                    fundReq.Person_Requesting__c = component.get("v.opp.Applicant_2__r.PersonContactId");
                }
            }
            fundReq.A1_Variation_Request_Submitted_Date__c = todayDate.toJSON();
            fundReq.Date_Last_Request_Status_Changes__c = todayDate.toJSON();
            var line1 = 'I/we want to apply to increase the limit to make up the '+'$' +fundReq.Net_Surplus_Shortfall__c.toLocaleString() +' shortfall.';
            var text = line1;
             fundReq.Applicant_acknowledgements__c = text;
            var action = component.get("c.createVariation");
            action.setParams({
                fundRequest : fundReq
            });
            action.setCallback(this, function(response){
                var ret = response.getReturnValue();
                var state = response.getState(); 
                if (state === "SUCCESS") {
                    window.location = ret;
                    //helper.variationSuccessMsg(component,event,fundReq,op);
                    component.set("v.iscreditbtnDisabled",true);
                    component.set("v.isformDisabled",true);
                    component.set("v.istoggleDisabled",true);
                    component.set("v.isCustomer",false);
                    //window.location = ret;
                }
                else if (state === "ERROR") {
                    //alert('Error');
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } 
                }
                $A.util.addClass(spinner, "slds-hide");
            });
            $A.enqueueAction(action);
        }
        else{
            component.set("v.DocError",true);
        }   
    }
    
})