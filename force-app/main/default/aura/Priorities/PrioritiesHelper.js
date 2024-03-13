({
    createLeadAndQuotes : function(component, event, secName) {
        var action = component.get("c.createLeadAndQuotes");
        var self = this;
        action.setParams({
            productType: component.get('v.purpose'),
            cFName: component.get('v.applicantFName'),
            cLName: component.get('v.applicantLName'),
            cEmail: component.get('v.applicantEmail'),
            cAmount: component.get('v.customerAmount'),
            myPriority: component.get('v.myPriority'),
            repayOverTerm: component.get('v.repayOverTerm'),
            homeOwner: component.get('v.homeOwner'),
            ProductTypeId : component.get('v.selectedProductTypeId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
			if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                console.log('-->>>ret-->>'+JSON.stringify(ret));
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showErrorParent", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                }else{
                    if(JSON.parse(ret).status == 'Success'){
                        component.set('v.recordId', JSON.parse(ret).recordId);
                        component.set('v.masterQuote', JSON.parse(ret).quoteGrpName);
                        component.set('v.applicationSection', JSON.parse(ret).CurrentSection);
                        component.set('v.appSectionPath', JSON.parse(ret).path);
                        component.set('v.showErrorParent', false);
                        
                    }else if(JSON.parse(ret).status == 'Error'){ 
                        console.log('-errorMsg->>'+JSON.parse(ret).message);
                        component.set('v.errorMsg', JSON.parse(ret).message);
                        component.set('v.showErrorParent', true);
                    }
                    
                    if(!$A.util.isUndefinedOrNull(JSON.parse(ret).recordId) && !$A.util.isUndefinedOrNull(JSON.parse(ret).leadId)){
                       // self.sendEmail(component, event, JSON.parse(ret).recordId, JSON.parse(ret).leadId, JSON.parse(ret).quoteId);
                    }
                }
            }
            self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
    },
    
    getProducts : function(component, event, secName) {
		var action = component.get("c.getFeaturedProducts");
        var self = this;
        action.setParams({
            isFeatured: true,
            purpose: ''
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
			console.log('@@@@@state--' + state);
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                component.set('v.featuredProducts',ret);
            }
        });
        $A.enqueueAction(action);
	},
    
    sendEmail : function(component, event, oppId, leadId, quoteId) {
        var action = component.get("c.sendApplication");
        var self = this;
        var emails = [];
        emails.push(component.get('v.applicantEmail'));
        action.setParams({
            oppId: oppId,
            leadId: leadId,
            quoteId: oppId,  //for changing the info. on quote email
            emails: emails,
            templateName: 'Quotation From Application VF', //new template by rakesh
            isPDFAttach : false
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
			console.log('@@@@@state--' + state);
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
            }
        });
        $A.enqueueAction(action);
	},
    
    toggleSpinner: function (component, event) {

        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
    
    // Start by Sethu
    getProductTypes : function(component, event, helper) {
		var action = component.get("c.getAllProductTypes");
        action.setCallback(this, function(response) {
            var state = response.getState();
			console.log('@@@@@state--' + state);
            if (state === "SUCCESS") {
                var productData = response.getReturnValue();
                console.log('productData>>>>> '+JSON.stringify(productData));
                component.set('v.productTypeList',productData);
                helper.toggleSpinner(component, event);
            }
        });
        $A.enqueueAction(action);
	},
    // End by Sethu

})