({
    doInit : function(component, event, helper) {
        // helper.toggleSpinner(component, event);
        helper.getProducts(component, event);
        helper.getProductTypes(component, event, helper);
    },
    
    //Start by Sethu
    getSelectedProductType : function(component, event, helper) {
		var selectedProductType = event.getSource().get("v.name");
        var selectedProductTypeId = event.getSource().get("v.value");
        alert(selectedProductTypeId);
        component.set("v.purpose", selectedProductType); 
        component.set("v.selectedProductTypeId", selectedProductTypeId); 
        
        component.set("v.showQuote", true); 
    },
    //End by Sethu
    
    //commented by Sethu
    /*getSolarQuote : function(component, event, helper) {
        component.set("v.purpose", "Solar"); 
        component.set("v.showQuote", true); 
    },
    
    getHomeQuote : function(component, event, helper) {
        component.set("v.purpose", "Home Improvement");
        component.set("v.showQuote", true); 
    },
    
    getConsolidationQuote : function(component, event, helper) {
        component.set("v.purpose", "Debt Consolidation");
        component.set("v.showQuote", true); 
    },*/
    
    SaveNext : function(component, event, helper) {
        var applicationSection = component.get("v.applicationSection");
        var solarLoanGetQoute = component.find("SolarLoanGetQoute");
        var isvalidate = solarLoanGetQoute.checkApplicantDetails();
        if(isvalidate){
            helper.toggleSpinner(component, event);
            helper.createLeadAndQuotes(component, event);
        }
        component.set("v.showError", !isvalidate);
        var scrollOptions = {
            left: 0,
            top: 0,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    },
    
    EnterHandle : function(component, event, helper){
        var isShowGetQuote = component.get("v.isShowGetQuote");
        if (event.keyCode == 13 && isShowGetQuote){
            var applicationSection = component.get("v.applicationSection");
            var solarLoanGetQoute = component.find("SolarLoanGetQoute");
            var isvalidate = solarLoanGetQoute.checkApplicantDetails();
            if(isvalidate){
                helper.toggleSpinner(component, event);
                helper.createLeadAndQuotes(component, event);
            }
            component.set("v.showError", !isvalidate);
            var scrollOptions = {
                left: 0,
                top: 0,
                behavior: 'smooth'
            }
            window.scrollTo(scrollOptions);
        }
    },
})