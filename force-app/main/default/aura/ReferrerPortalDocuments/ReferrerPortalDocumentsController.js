({
    doInit : function(component, event, helper) {  
     helper.showSpinner(component, event, helper);
	},
    
    OpenUploadDocs : function(component, event, helper) {    
        var oppId = component.get("v.WrapperData.Id");
        var label = $A.get("$Label.c.baseUrl");
        var redirect = label+'supportingDocument?oppId='+oppId; 
        window.open(redirect);
	},
    
})