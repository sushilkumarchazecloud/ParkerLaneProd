({
	ShowEditButtons : function(component, event, helper) { 
        // Code for Edit Button Showing on Condition based.
        var oppApplicationSection = component.get("v.oppWrapper.Current_Application_Sections__c");
        var oppStage = component.get("v.oppWrapper.StageName");
        if(oppApplicationSection == 'Priorities' || oppApplicationSection == 'Loan Recommendation' || oppApplicationSection == 'Getting Started')
        {
            if(oppStage != 'CPA Done' && oppStage != 'Packs Out' && oppStage != 'Application'
               && oppStage != 'Submitted' && oppStage != 'Conditionally Approved' 
               && oppStage != 'Conditional' && oppStage != 'Unconditional' && oppStage != 'Approved'
               && oppStage != 'Funding' && oppStage != 'Docs Signed' && oppStage != 'Settlement Booked'
               && oppStage != 'Settled (closed won)' && oppStage != 'Closed Lost' ){
                
                component.set("v.EditButtonShow",true);
            }
        } 
        component.set("v.showSpinner",false);
	},
})