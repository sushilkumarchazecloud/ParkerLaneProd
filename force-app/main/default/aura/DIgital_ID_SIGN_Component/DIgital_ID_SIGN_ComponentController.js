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
    
    closeModel : function(component, event, helper){
        if(component.get("v.isModalOpen") == true){
            component.set("v.isModalOpen", false);
        }
        if(component.get("v.isModalOpenBack") == true){
             component.set("v.isModalOpenBack", false);
        }
    },
    
    handleDocUploadFinished : function(component, event, helper){
   		var uploadedFiles = event.getParam("files");
        var idContent;
        for(var i=0; i<uploadedFiles.length; i++){
            idContent = uploadedFiles[i].documentId;
        }
        
        var action = component.get("c.frontUpload");
        action.setParams({ documentIds : idContent, recordId : component.get("v.recordId"), DocNm : 'DlFront' });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isModalOpen", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Successfully Uploaded" ,
                    "type" : "success"
                });
                toastEvent.fire();
            	helper.againGetData(component, 'DlFront');
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
    
    handleDocUploadFinishedForBack : function(component, event, helper){
   		var uploadedFiles = event.getParam("files");
        var idContent;
        for(var i=0; i<uploadedFiles.length; i++){
            idContent = uploadedFiles[i].documentId;
        }
        
        var action = component.get("c.frontUpload");
        action.setParams({ documentIds : idContent, recordId : component.get("v.recordId"), DocNm : 'BackDL' });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isModalOpenBack", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Successfully Uploaded" ,
                    "type" : "success"
                });
                toastEvent.fire();
                helper.againGetData(component, 'BackDL');
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
})