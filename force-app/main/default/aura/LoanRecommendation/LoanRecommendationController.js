({
	doInit : function(component, event, helper) {
        helper.getQuotes(component, event);
        helper.getLead(component, event);
        helper.scrollTop(component, event, 0);
    },
    
    onAmountChange : function(component, event, helper) {
        var csmtrAmt = component.get("v.customerAmount");      
        var timer = component.get('v.timer');
        clearTimeout(timer);

        var timer = setTimeout(function(){
            component.set("v.customerAmountnew", csmtrAmt);
            clearTimeout(timer);
            component.set('v.timer', null);
        }, 1000);

        component.set('v.timer', timer);
    },
    
    addSpinner : function(component, event, helper){
        var spinner = component.find("inItSpinner");
        var spin = component.get("v.isSpinner");
        console.log('spinner '+spin);
        if(spin){
            $A.util.removeClass(spinner, 'slds-hide');
        }
        else{
            $A.util.addClass(spinner, 'slds-hide');
        }        
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