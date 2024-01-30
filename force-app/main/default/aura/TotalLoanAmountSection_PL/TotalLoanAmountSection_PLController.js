({
	doInit : function(component, event, helper) {
        var quote = component.get("v.selectedQuote");
        if(!$A.util.isUndefinedOrNull(quote) && quote != null){
            component.set("v.totalAmount", quote.Monthly_Repayment__c);
            component.set("v.totalCustomerAmount", parseFloat(quote.Customer_Amount__c) + parseFloat(quote.Total_Setup_Fees__c));
        }
        var isGettingStarted = component.get("v.isGettingStarted");

        if(!isGettingStarted){
            helper.getSelectedQuote(component, event);
        }
    },
    
    changeCustomerAmount : function changeState (component){ 
        var quote = component.get("v.selectedQuote");
        var total = Math.ceil(((quote.Interest_Rate__c/1200 * quote.Customer_Amount__c) * (Math.pow((1 + (quote.Interest_Rate__c/1200)),quote.Loan_Term__c ))) / (Math.pow((1 + (quote.Interest_Rate__c/1200)),quote.Loan_Term__c) - 1));
        component.set("v.totalAmount", total);
        component.set("v.quote", quote);
    },
    
})