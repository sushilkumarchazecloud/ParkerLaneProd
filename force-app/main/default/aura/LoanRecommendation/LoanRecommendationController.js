({
	doInit : function(component, event, helper) {
        console.log('>>>>>');
        helper.getQuotes(component, event);
        helper.getLead(component, event);
        helper.scrollTop(component, event, 0);
    },
    
    Apply : function(component, event, helper) {
        var quote = event.getParam("selectedQuote");
        var purpose = component.get("v.purpose");
        quote.Purpose__c = purpose;
        component.set('v.selectedQuote', quote);
        var quotesWpr = component.get("v.quotesWpr");
        var quotes = [];
        for(var i=0; i< quotesWpr.length; i++){
            var qt = quotesWpr[i].quote;
            qt.Purpose__c = purpose;
            quotes.push(qt);
        }
        helper.toggleSpinner(component, event);
        helper.updateQuotes(component, event, quotes, quote.Id);
    }
})