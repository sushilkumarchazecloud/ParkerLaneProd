({
    doInit : function(component, event, helper) {  
        helper.getPreviousFundingRequest(component, event);
        helper.getret(component, event, helper);
        helper.getdocument(component, event, helper);

    },
    
    comboboxchange : function(component, event, helper){
        component.set("v.partPaymentAmt",null);
        component.set("v.CustomerAgreedOrNot",null); 
        component.set("v.AnticipatedInstDate",null); 
        component.set("v.AntDateBeforeError",false);
        component.set("v.partPmtError",false);
        component.set("v.isSubmitBtnDisabled",true);
        component.set("v.CsmtAgreedNullError",false);
        component.set("v.DocError",false);
    },
    
    submitRequest : function(component, event, helper){
        var cmbBoxVal = component.get("v.comboBoxValue");
        var docExist = component.get("v.DocExist");
        if(docExist){
            component.set("v.DocError",false); 
            helper.Submit(component, event, helper, cmbBoxVal);
        }
        else{
            component.set("v.DocError",true);   
        }
        
    },
    
    submitRemainderRequest : function(component, event, helper){
        var docExist = component.get("v.DocExist");
        if(docExist){
            component.set("v.DocError",false); 
            helper.SubmitRemainderRequest(component, event, helper);
        }
        else{
            component.set("v.DocError",true);   
        }  
    },
    
    Errors :  function(component, event, helper){
        var sourceField = event.getSource().getLocalId();
        
        if(sourceField == 'invoiceAmtCheck'){
        helper.SurplusORShortfallShow(component, event, helper);
        }
        
        // Code for CustomerAgreedOrNot rGroup Null Error.
        if (sourceField == 'DateInst' || sourceField == 'CsmtAgreedrGroup') {
            helper.CsmtAgreedNullErrorShow(component, event, helper);
        }
        
        //Code for giving error(If part payemnt is 50% above from total invoice amount
        if(sourceField == 'partpmtamt'){
            var full_amt = component.get("v.invoiceAmount");
            var part_amt = component.get("v.partPaymentAmt");
         helper.PartPaymentErrorShow(component, event, helper, full_amt, part_amt);
        }
        if(sourceField == 'rempartpmt'){
            var full_amt = component.get("v.fundsRemaining");
            var part_amt = component.get("v.partPaymentAmt");
         helper.RemainderpaymentError(component, event, helper, full_amt, part_amt);   
        }
        
        if(sourceField == 'DateInst'){
            helper.InstalltionDateErrorsShow(component, event, helper);
        }
        
        //code for Submit Button on/off functionality.
        helper.SubmitButtonOn_Off(component, event, helper);
    },
    
})