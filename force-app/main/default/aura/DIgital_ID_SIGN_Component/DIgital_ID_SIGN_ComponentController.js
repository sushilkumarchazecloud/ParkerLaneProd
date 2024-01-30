({
	myAction : function(component, event, helper) {
		var returndata = [];
        //alert(component.get("v.recordId"));
        var action = component.get("c.sendImageDataToComponent");
        action.setParams({ 
            RecId : component.get("v.recordId"),
            title : 'DlFront'
        
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.ImageData', action.getReturnValue());
                //alert("From server: " + action.getReturnValue());
               }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        alert("Unknown error");
                    }
                }
        });
        
         $A.enqueueAction(action);
        helper.helperMethod(component);
        helper.FetchDlBack(component);
        helper.FetchSelfi(component);
        helper.FetchPassport(component);
    },
    
    navigateToRecord : function(component, event, helper){
        var recordId = event.currentTarget.dataset.recordId;
        var navService = component.find("navService");
        var pageReference = {    
            "type": "standard__recordPage",
            "attributes": {
                "recordId": recordId,
                "actionName": "view"
            }
        }
        navService.generateUrl(pageReference).then($A.getCallback(function(url) {
            window.open(url,'_blank');
        }), 
        $A.getCallback(function(error) {
            console.log('error: ' + error);
        }));    
    },
    
    UpdateContact : function(component, event, helper){
        var action = component.get("c.UpdateOppCon");
        action.setParams({ cont : component.get("v.Con") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Contact Updated Successfully" ,
                    "type" : "success"
                });
                toastEvent.fire();
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert("Error message: " + 
                                  errors[0].message);
                        }
                    } else {
                        alert("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
    },
    
    openModal : function(component, event, helper){
        component.set("v.isModalOpen", true);
    },
    openModalBack : function(component, event, helper){
        component.set("v.isModalOpenBack", true);
    },
    openModaForSelfi : function(component, event, helper){
        component.set("v.isModalOpenForSelfi", true);
    },
    
    closeModel : function(component, event, helper){
        if(component.get("v.isModalOpen") == true){
            component.set("v.isModalOpen", false);
        }
        if(component.get("v.isModalOpenBack") == true){
             component.set("v.isModalOpenBack", false);
        }
        if(component.get("v.isModalOpenForSelfi") == true){
             component.set("v.isModalOpenForSelfi", false);
        }
    },
    
    handleDocUploadFinished : function(component, event, helper){
   		var uploadedFiles = event.getParam("files");
        var idContent;
        for(var i=0; i<uploadedFiles.length; i++){
            idContent = uploadedFiles[i].documentId;
        }
        helper.uploadDate(component,event, helper, idContent, 'DlFront');  
        
        component.set("v.isModalOpen", false);
    },
    
    backDataUpload : function(component, event, helper){
        var uploadedFiles = event.getParam("files");
   		// = event.getParam("files");
        var idContent;
        for(var i=0; i<uploadedFiles.length; i++){
            idContent = uploadedFiles[i].documentId;
        }
        helper.uploadDate(component,event, helper, idContent, 'BackDL');
        
        component.set("v.isModalOpenBack", false);
    },
    
   
    uploadSelfiData : function(component, event, helper){
        var uploadedFiles = event.getParam("files");
        var idContent;
        for(var i=0; i<uploadedFiles.length; i++){
            idContent = uploadedFiles[i].documentId;
        }
        
        helper.uploadDate(component,event, helper, idContent, 'Selfi');
        
        component.set("v.isModalOpenForSelfi", false);
    }
    
})