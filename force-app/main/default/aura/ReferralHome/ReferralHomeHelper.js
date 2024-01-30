({
    newQtList : function(component, event, pdfData) {        
        var action = component.get("c.ret");
        action.setCallback(this,function(response){
            var records = response.getReturnValue();
            component.set('v.quoteDetailWrpList', records);
        });
        $A.enqueueAction(action);
    },
    
    generateAndSendPDF : function(component, event, pdfData) {
        var action = component.get("c.generateAndSendPDF");
        var self = this;
        
        action.setParams({
            pdfData: pdfData
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
			console.log('@@@@@state--' + state);
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
               console.log('@@@@@res--' + JSON.stringify(ret));
            }
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