({
    doInit : function(component, event, helper) {
        helper.scrollTop(component, event);
        var quote = component.get("v.quote");
        component.set("v.gettingCustomerAmount", parseFloat(quote.Customer_Amount__c) + parseFloat(quote.Total_Setup_Fees__c));
        if(!$A.util.isUndefinedOrNull(quote.Product__r.Summary_Page_What_You_ll_Get__c) && quote.Product__r.Summary_Page_What_You_ll_Get__c != null){
            var whatYouGet = quote.Product__r.Summary_Page_What_You_ll_Get__c.split(";");
        }
        if(!$A.util.isUndefinedOrNull(quote.Product__r.What_document_needs_to_apply__c) && quote.Product__r.What_document_needs_to_apply__c != null){
            var whatYouNeed = quote.Product__r.What_document_needs_to_apply__c.split(";");
        }
       	component.set("v.whatYouNeed", whatYouNeed);
        component.set("v.whatYouGet", whatYouGet);
        component.set("v.quote",quote); 
    },
    
    SaveNext: function(component, event, helper) {
        helper.toggleSpinner(component, event);
        helper.scrollTop(component, event);
        helper.SaveAndConfirm(component, event);
    },
    
    onChange : function(component, event, helper) {
        
        var quote = component.get("v.quote");
        var opp = component.get("v.opportunity");
        
        var isPrivacyCreditGuide = component.get("v.isPrivacyCreditGuide");
        var productDisclosure = quote.Affordability_Confirmation__c;
        var timeInfo = component.get("v.timeInfo");

        if(isPrivacyCreditGuide == 'Yes' && productDisclosure == 'Yes' && timeInfo == 'Yes'){
            opp.Id = component.get("v.recordId");
            opp.Privacy_and_Credit_Guide__c = 'Yes';
            opp.Product_Disclosure__c = 'Yes';
            
            component.set("v.opportunity", opp);
            component.set("v.isDisabled", false);
        }else{
            component.set("v.isDisabled", true);
        }
    },
    
    updateSec : function(component, event, helper){
        helper.toggleSpinner(component, event);
        helper.scrollTop(component, event);
        helper.updateApplicationSection(component, event);
    }
})