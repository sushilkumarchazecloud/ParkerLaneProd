({    
	SaveAndConfirm: function (component, event) {
        var action = component.get("c.SaveAndConfirm");
        console.log('++QUOTE__>>>'+JSON.stringify(component.get('v.quote')));
        var self = this;
        action.setParams({
            selectedQuote : component.get('v.quote'),            
            leadId : component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
               //alert('JSON.parse(ret).path)>>> '+JSON.stringify(ret));
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                }else{
                    if(JSON.parse(ret).status == 'Success'){
                        component.set('v.recordId',JSON.parse(ret).recordId);
                        component.set('v.applicationSection', JSON.parse(ret).CurrentSection);
                        component.set('v.appSectionPath', JSON.parse(ret).path);
                        component.set('v.showError', false);
                        
                    }else if(JSON.parse(ret).status == 'Error'){                    
                        component.set('v.errorMsg', JSON.parse(ret).message);
                        component.set('v.showError', true);
                    }
                }
            }
            self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
    },
    
    updateApplicationSection: function (component, event) {
        var action = component.get("c.updateApplicationSection");
        var self = this;
        action.setParams({
            leadId : component.get("v.recordId"),
            appSection : 'Loan Recommendation',
            isChangeSection : 'true'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
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
    
    scrollTop: function (component, event){
        var scrollOptions = {
            left: 0,
            top: 0,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    },
    
    toggleSpinner: function (component, event) {

        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    }
})