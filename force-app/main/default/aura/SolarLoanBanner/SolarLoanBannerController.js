({
	doInit : function(component, event, helper) {
        var url = $A.get('$Resource.SolarLoan')+'/img/fingirl.png';
        component.set('v.bannerImageURL', url);
    },
    
    handleSOLAR : function(component, event, helper) {
        helper.toggleSpinner(component, event);
        helper.getProducts(component, event, 'Solar');
    },
    
    handleHOME : function(component, event, helper) {
        helper.toggleSpinner(component, event);
        helper.getProducts(component, event, 'Home Improvement');
    },
    
    handleDEBT : function(component, event, helper) {
        helper.toggleSpinner(component, event);
        helper.getProducts(component, event, 'Debt Consolidation');
    },
})