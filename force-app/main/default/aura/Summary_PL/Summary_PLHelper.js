({
	getSummaryDetail: function (component, event) {
        var action = component.get("c.getSummary");
        var self = this;
        var oppId = component.get('v.recordId');

     	action.setParams({
            oppId : oppId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var ret = JSON.parse( response.getReturnValue());
                if(ret.retURL != ''){
                    component.set('v.redirectURL', ret.retURL);
                }
                component.set("v.setAddress",ret.applicantState);
            }
            self.scrollTop(component, event, 70);
			self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
    },
    
    
    updateSummaryPage: function (component, event) {
        var action = component.get("c.updateSummary");
        var self = this;
        var oppId = component.get('v.recordId');

     	action.setParams({
            oppId : oppId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = component.get('v.redirectURL');
                if(ret !=''){
                    ret = ret.replace("SupportingDocument/?oppId", "supportingDocument?oppId");
                    window.location = ret;
                }
            }
			self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
    },
    
    updateManually: function (component, event) {
        var action = component.get("c.updateSummary");
        var self = this;
        var oppId = component.get('v.recordId');

     	action.setParams({
            oppId : oppId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('@@@@' + JSON.stringify(response));
            if (state === "SUCCESS") {
                var ret = component.get('v.redirectURL');
                if(ret !=''){
                    ret = ret.replace("/MogoDocument?oppId", "/MogoSupportingDocument?oppId");
                    window.location = ret;
                }
            }
			self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
    },
    
    changeState:function(component, event, Idname,question) {
			 var container = component.find(Idname);
             var isexpanded = component.get("v.isexpanded"+question);
            
        if(!isexpanded){
            $A.util.removeClass(container, "slds-hide");
            component.set("v.isexpanded"+question,true);
        }
        else{
            $A.util.addClass(container, "slds-hide");
            component.set("v.isexpanded"+question,false);
        }
    },
    
    toggleSpinner: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
    
    scrollTop: function (component, event, top){
        var isMoile = false;
        if(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)){
            isMoile = true;
            top += 51.5;
        }else{
            isMoile = false;
        }
        var scrollOptions = {
            left: 0,
            top: top,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    }
})