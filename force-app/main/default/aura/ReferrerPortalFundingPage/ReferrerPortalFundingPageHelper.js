({  
    Submit : function(component, event, helper, cmbBoxVal){
        var spinner = component.find("mySpinner2");
        $A.util.removeClass(spinner, 'slds-hide');
        component.set("v.spinner2",true);
        
        var oppId = component.get("v.opp.Id");
        var app1 = component.get("v.opp.Applicant_1__c");
        var app2 = component.get("v.opp.Applicant_2__c");
        var ext_ref = component.get("v.accountId");
        var cstmr_amt = component.get("V.opp.SyncedQuote.Customer_Amount__c"); 
        var invcAmt = component.get("v.invoiceAmount");
        var part_pmt_Amt = component.get("v.partPaymentAmt");
        var cstmr_agree = component.get("v.CustomerAgreedOrNot");
        var instln_dt = component.get("v.AnticipatedInstDate");
        var suplus_amt = cstmr_amt - invcAmt;
        var req_amt;
        var auth_type;
        
        if(cmbBoxVal == 'Payment in full before installation' || cmbBoxVal == 'Payment in full after installation'){
            req_amt = invcAmt;
        }   
        else if(cmbBoxVal == 'Part payment before installation' || cmbBoxVal == 'Remainder of payment after installation'){
            req_amt = part_pmt_Amt;
        }
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
        
        var action = component.get("c.createFundingRequest");
        action.setParams({ oppId : oppId,
                          invoice_amount : invcAmt,
                          reqType : cmbBoxVal, 
                          req_amount : req_amt,
                          Csmtr_agreedORSatisfy : cstmr_agree,
                          Inst_Date : instln_dt,
                          Cstmr_auth_Type : auth_type,
                          Surplus_Shortfall : suplus_amt,
                          app1 : app1,
                          app2 : app2,
                          refId : ext_ref
                         });
        
        action.setCallback(this,function(response){
            var ret = response.getReturnValue();
            var state = response.getState(); 
            if (state === "SUCCESS") {
                if(ret != null || ret.length() > 0){
                    component.set("v.PreviousData", ret);
                }
                component.set("v.request",false);
                component.set("v.RemainderRequest",false);
                component.set("v.reqSubmitted",true);
                helper.getOpp(component, event, helper);
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
            component.set("v.spinner2",false);
            $A.util.addClass(spinner, 'slds-hide');
        });       
        $A.enqueueAction(action);
    },
    
    SubmitRemainderRequest : function(component, event, helper){
        var spinner = component.find("mySpinner2");
        $A.util.removeClass(spinner, 'slds-hide');
        component.set("v.spinner2",true);
        
        var cmbBoxVal = component.get("v.remainderComboValue");
        var oppId = component.get("v.opp.Id");  
        var app1 = component.get("v.opp.Applicant_1__c");
        var app2 = component.get("v.opp.Applicant_2__c");
        var ext_ref = component.get("v.accountId");
        var cstmr_amt = component.get("V.opp.SyncedQuote.Customer_Amount__c");
        var net_funds_rem_srpls_shrtfl = component.get("v.fundsRemaining");
        var req_amt = component.get("v.partPaymentAmt");
        var invcAmt = component.get("v.invoiceAmount");
        var cstmr_agree = component.get("v.CustomerAgreedOrNot");
        var instln_dt = component.get("v.AnticipatedInstDate");
        var auth_type;
        
        var signAllowed = component.get("v.opp.SyncedQuote.Product__r.No_of_Signatories_allowed__c");
        if(signAllowed != null && signAllowed.includes('Both to sign') && !signAllowed.includes('Either to sign')){
            auth_type = 'Both to sign';  
        }
        else if((signAllowed != null && signAllowed.includes('Either to sign')) || signAllowed == null){ 
            var Opp_Signs = component.get("v.opp.Applicant_1__r.Number_of_applicants_to_operate_account__pc");
            if(Opp_Signs == null || Opp_Signs == '' || Opp_Signs== 'Either to sign'){
                auth_type = 'Either to sign'; 
            } 
            else if(Opp_Signs== 'Both to sign'){
                auth_type = 'Both to sign';
            }
        }
        
        var action = component.get("c.createFundingRequest");
        action.setParams({ oppId : oppId,
                          invoice_amount : invcAmt,
                          reqType : cmbBoxVal, 
                          req_amount : req_amt,
                          Csmtr_agreedORSatisfy : cstmr_agree,
                          Inst_Date : instln_dt,
                          Cstmr_auth_Type : auth_type,
                          Surplus_Shortfall : net_funds_rem_srpls_shrtfl,
                          app1 : app1,
                          app2 : app2,
                          refId : ext_ref
                         });
        
        action.setCallback(this,function(response){
            var ret = response.getReturnValue();
            var state = response.getState(); 
            if (state === "SUCCESS") {
                if(ret != null || ret.length() > 0){
                    component.set("v.PreviousData", ret);
                }
                component.set("v.request",false);
                component.set("v.RemainderRequest",false);
                component.set("v.reqSubmitted",true);
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
           component.set("v.spinner2",false);
           $A.util.addClass(spinner, 'slds-hide');
        });       
        $A.enqueueAction(action);
    },
    
    getPreviousFundingRequest : function(component, event){
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var action = component.get("c.getPreviousFundingRequests");
        action.setParams({ 
            OppId : component.get("v.opp.Id"),
        }); 
        action.setCallback(this,function(response) 
                           {
                               var  ret = response.getReturnValue();
                               component.set("v.PreviousData",ret);
                               var  date = new Date();
                               var year = date.getFullYear();
                               var month = (date.getMonth() + 1).toString().padStart(2, '0');
                               var day = date.getDate().toString().padStart(2, '0');
                               var todaydate = year + '-' + month + '-' + day;
                               if(ret.length == 0){
                                   var oppp = component.get("v.opp");
                                   var fundingOptions = component.get("v.opp.SyncedQuote.Product__r.Funding_Options_Available__c");
                                   var loan_exp_date = component.get("v.opp.Approved_Expire_Date__c");
                                   if(loan_exp_date <= todaydate){
                                       component.set("v.loanExpired",true);  
                                   }
                                   else if(oppp.StageName == 'Approved' || oppp.StageName == 'Funding'){
                                       component.set("v.request",true);
                                       var options = [];
                                       if(fundingOptions != null){
                                       if(fundingOptions.includes('In full before installation')){
                                           options.push({ label: 'Payment in full before installation', value: 'Payment in full before installation'});
                                       }
                                       if(fundingOptions.includes('In full after installation')){
                                           options.push({ label: 'Payment in full after installation', value: 'Payment in full after installation'});
                                       }
                                       if(fundingOptions.includes('Part payment before (and remainder after) installation')){
                                           options.push({ label: 'Part payment before (and remainder after) installation', value: 'Part payment before installation'});
                                       }
                                       component.set("v.comboOBoxptions",options);
                                       }
                                   }
                                   else{
                                       component.set("v.notApproved",true);
                                   }
                               }
                               else if(ret.length == 1){
                                   for(var i=0;i<ret.length;i++){
                                       if(ret[i].Request_Type__c == 'Part payment before installation' && ret[i].Request_Status__c != 'Payment funded'){
                                           component.set("v.reqSubmitted",true);   
                                       }
                                       else if(ret[i].Request_Type__c == 'Part payment before installation' && ret[i].Request_Status__c == 'Payment funded'){
                                           component.set("v.RemainderRequest",true);
                                           component.set("v.fundsPaidToDate",ret[i].Request_Amount__c);
                                           component.set("v.fundsRemaining",ret[i].Net_Funds_after_Request__c);
                                           component.set("v.invoiceAmount",ret[i].Invoice_Amount__c);
                                       }
                                           else{
                                               component.set("v.reqSubmitted",true);    
                                           }
                                   }   
                               }
                                   else if(ret.length == 2){
                                       component.set("v.reqSubmitted",true);  
                                   }
                               $A.util.addClass(spinner, 'slds-hide');
                           });
        $A.enqueueAction(action);
    },
    
    getOpp : function(component, event, helper){
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var action = component.get("c.GetOppOnExpand");
        action.setParams({ 
            oppId : component.get("v.opp.Id"),
        }); 
        action.setCallback(this,function(response){
            var records = response.getReturnValue();
            if(records != null){
                component.set("v.opp", records);
                var Name = component.get("v.opp.Name")
                if(Name != null){
                    var OppName = Name.split(',');
                    component.set("v.OpportunityName",OppName[0]); 
                }
                var statusWithColor = component.get("v.opp.Status__c");
                if(statusWithColor != null){
                    var statusWithColorList = statusWithColor.split('-');
                    component.set("v.status",statusWithColorList[0]);
                    component.set("v.statusCode",statusWithColorList[1]);
                } 
            }
            $A.util.addClass(spinner, 'slds-hide');
        });       
        $A.enqueueAction(action); 
        
    },
    
    getret : function(component, event, helper){
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var action = component.get("c.ret");
        action.setCallback(this,function(response){
            var records = response.getReturnValue();
            component.set('v.quoteDetailWrpList', records);
            component.get('v.quoteDetailWrpList');
            $A.util.addClass(spinner, 'slds-hide');
        });       
        $A.enqueueAction(action); 
        
    },
    
    getdocument : function(component, event, helper){
        var action1 = component.get("c.getDocument");
        var opp = component.get("v.opp.Id");
        action1.setParams({
            OppId: opp
        });
        action1.setCallback(this, function(response) {
            var spinner = component.find("mySpinner");
            $A.util.removeClass(spinner, 'slds-hide');
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
                console.log('Error');
            }
            $A.util.addClass(spinner, 'slds-hide');
        });
        $A.enqueueAction(action1); 
    },
    
    SurplusORShortfallShow : function(component, event, helper ){
        var shorfallInstructions = component.get("v.opp.SyncedQuote.Product__r.Short_Fall_Instructions__c");
        var SurplusInstructions = component.get("v.opp.SyncedQuote.Product__r.Surplus_Instructions__c");
        var invoiceamount = component.get("v.invoiceAmount");
        var customerAmt = component.get("v.opp.SyncedQuote.Customer_Amount__c");
        if(invoiceamount != null  && customerAmt != null && invoiceamount != ''){
            var srpamt = customerAmt - invoiceamount;
            component.set("v.surplusShow",true);
            if(srpamt > 1){
                var newsrpamt = '+$'+srpamt.toLocaleString();
                component.set("v.surplusAmount",newsrpamt);
                component.set("v.amtDifference",true);
            }
            else if(srpamt < 1 && srpamt != 0){
                var newsrpamt = '-$'+(srpamt * -1).toLocaleString();
                component.set("v.surplusAmount",newsrpamt); 
                component.set("v.amtDifference",true);
            }
                else if (srpamt == 0){
                    var newsrpamt = '$0';
                    component.set("v.surplusAmount",newsrpamt);
                    component.set("v.amtDifference",false);
                }
            // Code for Showing ShortFall/Surplus Instructions Condition Based.
            if(srpamt < 0){
                component.set("v.Surplus_ShortFallInstruction",shorfallInstructions);
            }
            else if(srpamt > 0){
                component.set("v.Surplus_ShortFallInstruction",SurplusInstructions);  
            }
        }
        else{
            component.set("v.surplusShow",false);
        }   
    },
    
    CsmtAgreedNullErrorShow : function(component, event, helper ){
        var csmtAgreedvalue = component.get("v.CustomerAgreedOrNot");
        if(csmtAgreedvalue == null){
            component.set("v.CsmtAgreedNullError",true);
        }
        else{
            component.set("v.CsmtAgreedNullError",false); 
        }  
        
    },
    
    PartPaymentErrorShow : function(component, event, helper, full_amt, part_amt ){
        if(full_amt != null){
            var er = full_amt/2;
        }
        if(part_amt > er && part_amt != null && er != null){
            component.set("v.partPmtError",true);
        }
        else{
            component.set("v.partPmtError",false);
        }
    },
    
    RemainderpaymentError : function(component, event, helper, full_amt, part_amt ){
        if(full_amt != null && part_amt > full_amt && part_amt != null ){
            component.set("v.partPmtError",true);
        }
        else{
            component.set("v.partPmtError",false);
        }
    },
    
    InstalltionDateErrorsShow : function(component, event, helper ){
        //Code for giving error(If Anticipated Inst. date is before/After today).  
        var antInstdate = component.get("v.AnticipatedInstDate");
        var  date = new Date();
      //  var todaydate = $A.localizationService.formatDate(date.toLocaleDateString(),"YYYY-MM-DD");
        var year = date.getFullYear();
        var month = (date.getMonth() + 1).toString().padStart(2, '0');
        var day = date.getDate().toString().padStart(2, '0');
        var todaydate = year + '-' + month + '-' + day;
        
        var comboBoxValue = component.get("v.comboBoxValue");
        var remaindercmbvalue = component.get("v.remainderComboValue");
        if(comboBoxValue == 'Payment in full before installation' || comboBoxValue == 'Part payment before installation'){
            if(antInstdate < todaydate && antInstdate !=null){
                component.set("v.AntDateBeforeError",true);
            }
            else{
                component.set("v.AntDateBeforeError",false);
            }
        } 
        else if(comboBoxValue == 'Payment in full after installation' || remaindercmbvalue != null){
            if(antInstdate > todaydate && antInstdate !=null){
                component.set("v.AntDateBeforeError",true);
            }
            else{
                component.set("v.AntDateBeforeError",false);
            } 
            
        }
    },
    
    SubmitButtonOn_Off : function(component, event, helper ){
        //code for Submit Button on/off When CmbBoX Value is Payment in full before installation.
        var request = component.get("v.request");
        var remainderrequest = component.get("v.RemainderRequest");
        var invoiceAmountcheck = component.get("v.invoiceAmount");
        var amountDiff= component.get("v.amtDifference");
        var amtdiffrGroupValue = component.get("v.rGroupValue");
        var cmbBoxValue = component.get("v.comboBoxValue");
        var csmtAgreeNotAgree = component.get("v.CustomerAgreedOrNot");
        var anticipdate = component.get("v.AnticipatedInstDate");
        var dateerror = component.get("v.AntDateBeforeError");
        var docExists = component.get("v.DocExistsORNot");
        var docUploaded = component.get("v.quoteDetailWrpList");
        if(request == true){
            if(cmbBoxValue == 'Payment in full before installation' || cmbBoxValue == 'Payment in full after installation'){
                if(invoiceAmountcheck != null && invoiceAmountcheck != ''){
                    if(csmtAgreeNotAgree != null && csmtAgreeNotAgree == 'Yes' && anticipdate != null && dateerror == false){
                        component.set("v.isSubmitBtnDisabled",false);  
                    } 
                    else{
                        component.set("v.isSubmitBtnDisabled",true); 
                    }
                }
                else{
                    component.set("v.isSubmitBtnDisabled",true); 
                }
            } 
            else if(cmbBoxValue == 'Part payment before installation'){
                var partPmtValue = component.get("v.partPaymentAmt");
                var partpmterror = component.get("v.partPmtError");
                if(invoiceAmountcheck != null && invoiceAmountcheck != ''){
                    if(csmtAgreeNotAgree != null && csmtAgreeNotAgree == 'Yes' && anticipdate != null && dateerror == false && partPmtValue != null && partPmtValue != '' && partpmterror == false){
                        component.set("v.isSubmitBtnDisabled",false);  
                    } 
                    else{
                        component.set("v.isSubmitBtnDisabled",true); 
                    }
                }
                else{
                    component.set("v.isSubmitBtnDisabled",true); 
                }
                
            }
                else{
                    component.set("v.isSubmitBtnDisabled",true);  
                }
        } 
        //Code for showing part payment error on Remainder request if payment is greater then net funds remaining.
        if(remainderrequest){
            var partpmtamountrem = parseInt(component.get("v.partPaymentAmt"));
            var fundsremaining = parseInt(component.get("v.fundsRemaining"));
            var finalPmtError = component.get("v.partPmtError");
            //Code for button Enable for Remainder Request.
            if(partpmtamountrem != null && fundsremaining != null && finalPmtError == false && csmtAgreeNotAgree == 'Yes' && anticipdate != null && dateerror == false){
                component.set("v.isSubmitBtnDisabled",false);
            }
            else{
                component.set("v.isSubmitBtnDisabled",true); 
            }
        }
    },
})