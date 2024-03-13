({
    doInit : function(component, event, helper) {
        var quote = component.get("v.quote");
        component.set("v.showbtn",false);
        var loanRates = component.get("v.loanRates");
        var terms = [];
        if(!$A.util.isUndefinedOrNull(quote) && quote != null){
            for(var i = quote.Product__r.Min_Loan_Term__c; i <= quote.Product__r.Max_Loan_Term__c; i+=12){
                var term = {
                    "label": i.toString() + ' months',
                    "value": i.toString(),
                    "selected": (i == quote.Loan_Term__c?true:false),
                };
                terms.push(term);
            }
            quote.Loan_Term__c = '' + quote.Loan_Term__c;
            component.set("v.quote", quote);
            component.set("v.totalAmount", quote.Monthly_Repayment__c);
            if(!$A.util.isUndefinedOrNull(quote.Product__r.Features__c) && quote.Product__r.Features__c != null){
                component.set("v.features", quote.Product__r.Features__c.split(";"));
            }
            if(!$A.util.isUndefinedOrNull(quote.Product__r.Eligibility_Description__c) && quote.Product__r.Eligibility_Description__c != null){
                component.set("v.eligibilities", quote.Product__r.Eligibility_Description__c.split(";"));
            }
            if(!$A.util.isUndefinedOrNull(quote.Product__r.What_document_needs_to_apply__c) && quote.Product__r.What_document_needs_to_apply__c != null){
                component.set("v.documentsNeeded", quote.Product__r.What_document_needs_to_apply__c .split(";"));
            }
            var index = component.get("v.index");
            if(index == 0){
                component.set("v.cardName", "Option B");
            }else if(index == 1){
                component.set("v.cardName", "Option A");
                component.set("v.isFeature", true);
                
            }else if(index == 2){
                component.set("v.cardName", "Option C");
            }
            
        }
        component.set("v.termOptions", terms);
        
    },
    
    applyNow : function(component, event, helper) {
        var ApplyNowEvent = component.getEvent("ApplyNowEvent");
        var quote = component.get("v.quote");
        var totCustomerAmount = parseFloat(component.get("v.customerAmount")) + parseFloat(quote.Total_Setup_Fees__c);
        quote.Monthly_Repayment__c = Math.ceil((((quote.Interest_Rate__c/1200 * totCustomerAmount) * (Math.pow((1 + (quote.Interest_Rate__c/1200)),quote.Loan_Term__c ))) / (Math.pow((1 + (quote.Interest_Rate__c/1200)),quote.Loan_Term__c) - 1))+ quote.Monthly_Account_Keeping_Fees__c );
        console.log('Monthly repayment '+quote.Monthly_Repayment__c);
        ApplyNowEvent.setParams({"selectedQuote" : quote});
        ApplyNowEvent.fire();
    },
    
    changeState : function (component){ 
        component.set('v.isexpanded',!component.get('v.isexpanded'));
    },
    
    changePurpose : function (component){ 
        var purpose = component.get("v.purpose");
        var quote = component.get("v.quote");
        quote.Purpose__c = purpose;
        component.set("v.quote", quote);
    },
    
    changeCustomerAmount : function (component){ 
        var cAmount = component.get("v.customerAmount");
        var quote = component.get("v.quote");
        var loanRates = component.get("v.loanRates");
        
        if(quote.Product__r.Minimum_Loan_Amount__c > cAmount || quote.Product__r.Maximum_Loan_Amount__c < cAmount){
            component.set("v.show",true);
            component.set("v.showbtn",true);
            
            var cmpTarget = component.find('styleChange');
            $A.util.addClass(cmpTarget, 'changeMe');
            
            if(quote.Product__r.Minimum_Loan_Amount__c > cAmount){
                component.set("v.availableUnder",true);
            }
            else if(quote.Product__r.Maximum_Loan_Amount__c < cAmount){
                component.set("v.availableOver",true);
            }
        }            
        
        else{
            component.set("v.show",false);
            component.set("v.showbtn",false);
            component.set("v.availableUnder",false);
            component.set("v.availableOver",false);
            if(quote.Product__r.Interest_Rate_Based_On__c =='Tiered Rate' && !$A.util.isUndefinedOrNull(loanRates) ){
                for(var i=0; i<loanRates.length; i++){
                    if(parseFloat(loanRates[i].From_amount__c) <= cAmount && parseFloat (loanRates[i].To_amount__c) >= cAmount ){
                        quote.Actual_Comparison_Rate__c = parseFloat(loanRates[i].Comparison_rate__c);
                        quote.Interest_Rate__c = parseFloat(loanRates[i].Interest_rate__c);
                        break;
                    }
                }
            }
            
            if($A.util.isUndefinedOrNull(quote.Monthly_Account_Keeping_Fees__c)){
                quote.Monthly_Account_Keeping_Fees__c = 0;
            }
            quote.Customer_Amount__c = cAmount;
            var total = Math.ceil((((quote.Interest_Rate__c/1200 * quote.Customer_Amount__c) * (Math.pow((1 + (quote.Interest_Rate__c/1200)),quote.Loan_Term__c ))) / (Math.pow((1 + (quote.Interest_Rate__c/1200)),quote.Loan_Term__c) - 1))+ quote.Monthly_Account_Keeping_Fees__c );
            
            component.set("v.totalAmount", total);
            component.set("v.quote", quote);
        }       
    },
    
    changeTerm : function (component){ 
        var quote = component.get("v.quote");
        if($A.util.isUndefinedOrNull(quote.Monthly_Account_Keeping_Fees__c)){
            quote.Monthly_Account_Keeping_Fees__c = 0;            
        }
        var total = Math.ceil((((quote.Interest_Rate__c/1200 * quote.Customer_Amount__c) * (Math.pow((1 + (quote.Interest_Rate__c/1200)),quote.Loan_Term__c ))) / (Math.pow((1 + (quote.Interest_Rate__c/1200)),quote.Loan_Term__c) - 1))+ quote.Monthly_Account_Keeping_Fees__c );
        console.log('total amount '+total);
        component.set("v.totalAmount", total);
    }
    
})