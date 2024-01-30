({
    getQuotes : function(component, event) {
        
        var action = component.get("c.getQuotaions");
        var self = this;
        console.log('master quote>>' +component.get("v.masterQuote"));
        action.setParams({
            oppId : component.get("v.recordId"),
            masterQuote : component.get("v.masterQuote")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                console.log('>>>>>' + JSON.stringify(ret));
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                }else{
                    component.set('v.quotesWpr', ret);
                    component.set('v.customerAmount', ret[0].quote.Customer_Amount__c);
                    component.set('v.purpose', ret[0].quote.Purpose__c);
                }
            }
            self.scrollTop(component, event, 465);
        });
        $A.enqueueAction(action);
    },
    
    getLead : function(component, event) {

        var action = component.get("c.getLead");
        var self = this;
        action.setParams({
            oppId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                }else{
                    component.set('v.applicantFName', ret.FirstName);
                    component.set('v.applicantLName', ret.LastName);
                    component.set('v.applicantEmail', ret.Email);
                }
            }
            
            self.scrollTop(component, event, 465);

        });
        $A.enqueueAction(action);
    },
    
    updateQuotes : function(component, event, quotes, selectedId) {
		var action = component.get("c.UpdateQuote");
        var self = this;
        
     	action.setParams({
            quotesList: quotes,
            selectedQuoteId: selectedId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();   
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                }else{
                    component.set('v.applicationSection', JSON.parse(ret).CurrentSection);
                    component.set('v.appSectionPath', JSON.parse(ret).path);
                }
            }
            self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
	},
    
    toggleSpinner: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
    
    scrollTop: function (component, event, top){
        var scrollOptions = {
            left: 0,
            top: top,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    },
})