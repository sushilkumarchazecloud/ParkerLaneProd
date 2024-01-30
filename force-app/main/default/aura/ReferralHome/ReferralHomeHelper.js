({
    saveReferral : function(component, event) {
		var action = component.get("c.submitReferral");
        var self = this;

        action.setParams({
            refEmail: component.get('v.referrerEmail'),
            custName: component.get('v.custName'),
            custEmail: component.get('v.custEmail'), 
            custPhone: component.get('v.custPhone'),
            custAmount: component.get('v.quoteAmount'),
            custAdd: component.get('v.custInstallationAddress'), 
            quoteType: component.get('v.quoteType'),
            support: component.get('v.support'),
            sendQuote: component.get('v.sendQuote'), 
            isReferralAgreement: component.get('v.isReferralAgreement'),
            isObtainedTheCustomer: component.get('v.isObtainedTheCustomer')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('@@@@@@' +state);
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                console.log('@@@@@ret--' + JSON.stringify(ret));
                component.set('v.showMessage', true);
                component.set('v.status', JSON.parse(ret).status);
                component.set('v.message', JSON.parse(ret).message);
                if(JSON.parse(ret).status == 'success'){
                    var emails = [component.get('v.referrerEmail')];

                    self.sendEmail(component, event, JSON.parse(ret).recordId, JSON.parse(ret).conId, JSON.parse(ret).leadId, emails, 'Quotation From Referrer VF', true);
                    if(component.get('v.sendQuote') == 'Me and my customer'){
                        var emails1 = [component.get('v.custEmail')];

                        self.sendEmail(component, event, JSON.parse(ret).recordId, JSON.parse(ret).leadId, JSON.parse(ret).quoteId, emails1, 'Quotation From Referral', false);
                    }
                    
                    component.set('v.referrerEmail','');
                    component.set('v.custName','');
                    component.set('v.custEmail','');
                    component.set('v.custPhone','');
                    component.set('v.quoteAmount','');
                    component.set('v.custInstallationAddress','');
                    component.set('v.quoteType','');
                    component.set('v.support','');
                    component.set('v.sendQuote','');
                    component.set('v.isReferralAgreement',false);
                    component.set('v.isObtainedTheCustomer',false);
                }
                
            }
            self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
	},
    
    sendEmail : function(component, event, oppId, leadId, quoteId, emails, templateName, isPDFAttach) {
        var action = component.get("c.sendApplication");
        var self = this;
        
        console.log('@@@@@emails--' + emails);
        action.setParams({
            oppId: oppId,
            leadId: leadId,
            quoteId: quoteId,
            emails: emails,
            templateName: templateName,
            isPDFAttach : isPDFAttach
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
			console.log('@@@@@state--' + state);
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
               console.log('@@@@@featured productes--' + JSON.stringify(ret));
                //component.set('v.featuredProducts',ret);
            	// self.toggleSpinner(component, event);
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