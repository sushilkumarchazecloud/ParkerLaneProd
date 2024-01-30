({
    doInit : function(component, event, helper) {
        var recordIds = component.get("v.recordId");
        helper.callDoInit(component, recordIds);
        
    },
    handleUploadFinished : function(component, event, helper) {
        var index = event.getSource().get("v.name");
        var action = component.get("c.updateDocRequested");
        var uploadedFiles = event.getParam("files");
        var recordIds = component.get("v.recordId");
        var idContent = [];
        for(var i=0; i < uploadedFiles.length; i++){
            idContent.push(uploadedFiles[i].documentId);
        }
        console.log(idContent);
        action.setParams({
            'docId': index,
            'cdIds': idContent
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "Document uploaded successfully."
                });
                toastEvent.fire(); 
				helper.updateActivity(component);                
            }
            var recordIds = component.get("v.recordId");
            helper.callDoInit(component, recordIds);
            $A.get("e.force:refreshView").fire();
        });
        $A.enqueueAction(action);
    },
    editController :function(component,event,helper){
        component.set("v.isEditOpen", true);
        component.set("v.docId",event.getSource().get("v.name"));
        component.set("v.docName",event.getSource().get("v.value"));        
    },
    closeEditModel: function(component, event, helper) {
        component.set("v.isEditOpen", false);
    },
    handleSubmit: function(component, event, helper) {
    },
    handleSuccess: function(component, event, helper) {
        component.set('v.isEditOpen', false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type": "success",
            "message": "Document edited successfully."
        });
        toastEvent.fire();
        var recordIds = component.get("v.recordId");
        helper.callDoInit(component, recordIds);
        $A.get("e.force:refreshView").fire();
        
    },
    handleDeleteDocument: function(component, event, helper) {
        if (confirm("Are you sure you want to delete Document?") ) {
            component.set("v.deleteDocId",event.getSource().get("v.name"));
            component.find("docDeleter").reloadRecord();
        }
    },
    handleDocUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        console.log(eventParams.changeType);
        if(eventParams.changeType === "LOADED") {
            component.find("docDeleter").deleteRecord($A.getCallback(function(deleteResult) {
                if (deleteResult.state === "SUCCESS" || deleteResult.state === "DRAFT") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Document deleted successfully."
                    });
                    toastEvent.fire();  
                    
                } else if (deleteResult.state === "INCOMPLETE") {
                    alert("User is offline, device doesn't support drafts.");
                } else if (deleteResult.state === "ERROR") {
                    alert('Problem deleting record, error: ' + JSON.stringify(deleteResult.error));
                } else {
                    alert('Unknown problem, state: ' + deleteResult.state + ', error: ' + JSON.stringify(deleteResult.error));
                }
            }));
        } else if(eventParams.changeType === "REMOVED") {
            var recordIds = component.get("v.recordId");
            helper.callDoInit(component, recordIds);
            $A.get("e.force:refreshView").fire();
        }
    },
    requestDocument : function(component, event, helper) {
		var recordIds = component.get("v.recordId");
        window.open("/apex/requestedDocuments?oppId="+recordIds);
	},
    sendEmail : function(component, event, helper) {
        if (confirm("Are you sure? This will send a reminder email to the customer requesting the outstanding documents") ) {
            $A.util.removeClass(component.find("mySpinner"), 'slds-hide');
            $A.util.addClass(component.find("mySpinner"), "slds-show");
            var action = component.get("c.sendEmailToCust");
            var recordId = component.get("v.recordId");
            action.setParams({
                'oppId': recordId
            });
            action.setCallback(this, function(result){
                $A.util.removeClass(component.find("mySpinner"), "slds-show");
                $A.util.addClass(component.find("mySpinner"), 'slds-hide');
                var res = result.getReturnValue();
                if (res == "success"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Email sent successfully."
                    });
                    toastEvent.fire();                 
                }
                else if(res == "error"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "error!",
                        "type": "error",
                        "message": "Error! You can not send a reminder because there are no documents in ‘Requested’ Status"
                    });
                    toastEvent.fire(); 
                }
            });
            
        }
        
        $A.enqueueAction(action);
    }
    
})