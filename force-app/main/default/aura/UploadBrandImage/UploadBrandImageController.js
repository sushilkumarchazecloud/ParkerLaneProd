({
    doInit : function(component, event, helper) {
        var recordIds = component.get("v.recordId");
        var action = component.get("c.getAccountDetails");
        action.setParams({
            'recordId': recordIds
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            var ret = result.getReturnValue(); 
            if(ret.LogoImage__c != null){
                component.set("v.checklogo",true);
                const tempElement = document.createElement('div');
                tempElement.innerHTML = ret.LogoImage__c;
                if(tempElement.innerHTML.startsWith("<p>")){                    
                    const extractedURL = tempElement.querySelector('p').innerText;
                    component.set("v.lgImage", extractedURL);
                }
            }
            if(ret.BackgroundImage__c != null){
                component.set("v.checkbackground",true);
                const tempElement = document.createElement('div');
                tempElement.innerHTML = ret.BackgroundImage__c;
                if(tempElement.innerHTML.startsWith("<p>")){                    
                    const extractedURL = tempElement.querySelector('p').innerText;
                    component.set("v.bgImage", extractedURL);
                }
            } 
        });
        $A.enqueueAction(action);
    },
    
    handleUploadFinished : function(component, event, helper) {
        var index = event.getSource().get("v.name");
        var action = component.get("c.addAccountPhotos");
        var uploadedFiles = event.getParam("files");
        var recordIds = component.get("v.recordId");
        var idContent = [];
        var imgName = '';
        for(var i=0; i < uploadedFiles.length; i++){
            idContent.push(uploadedFiles[i].documentId);
        } 
        action.setParams({
            'cdIds': idContent,
            'recordId': recordIds,
            'name' : index
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            var ret = result.getReturnValue();            
            if (state === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "Document uploaded successfully."
                });
                toastEvent.fire();
                if(ret.LogoImage__c != null){
                    component.set("v.checklogo",true);
                    const tempElement = document.createElement('div');
                    tempElement.innerHTML = ret.LogoImage__c;
                    if(tempElement.innerHTML.startsWith("<p>")){                    
                        const extractedURL = tempElement.querySelector('p').innerText;
                        component.set("v.lgImage", extractedURL);
                    }
                }
                if(ret.BackgroundImage__c != null){
                    component.set("v.checkbackground",true);
                    const tempElement = document.createElement('div');
                    tempElement.innerHTML = ret.BackgroundImage__c;
                    if(tempElement.innerHTML.startsWith("<p>")){                    
                        const extractedURL = tempElement.querySelector('p').innerText;
                        component.set("v.bgImage", extractedURL);
                    }
                }                                
            }
            $A.get("e.force:refreshView").fire();
        });
        $A.enqueueAction(action);
    },
})