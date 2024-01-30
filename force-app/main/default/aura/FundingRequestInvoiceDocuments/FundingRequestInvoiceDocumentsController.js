({
    doInit: function(component, event, helper) {
        var recordIds = component.get("v.recordId");
        helper.getDocuments(component, recordIds);
    },
    
    navigateToRecord : function(component , event, helper){
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
    
    openModalUpload: function(component, event, helper){
        helper.helperApplicant(component);
        component.set("v.isUpload",true);
        
    },
    
    closeModalUpload: function(component, event, helper){
        component.set("v.isUpload",false);            
    },
    
    handleDocUploadFinished: function(component, event, helper){
        var uploadedFiles = event.getParam("files");
        var idContent = [];
        for(var i=0; i<uploadedFiles.length; i++){
            idContent.push(uploadedFiles[i].documentId);
        }
        helper.fetchUploadedFiles(component, idContent);
    },
    
    closeIsAfter: function(component, event, helper){
        component.set("v.isAfterUpload",false);
        component.set("v.docExistError",false);
    },
    
    titleChange: function(component, event, helper){
        var cid = event.getSource().get("v.name");	            
        var ctxt =  event.getSource().get("v.value");
        var list = [];
        list = component.get("v.finalUpload")
        for(var i=0; i<list.length; i++){
            if(cid == list[i].Id){
                list[i].Title = ctext;
            }
            console.log(list[i].Title);
        }
        console.log(list);
        component.set("v.finalUpload",list);
    },
    
    handleCmbRelated: function(component, event, helper){
        var cid = event.getSource().get("v.name");	            
        var selectedOptionValue = event.getParam("value");
        console.log(selectedOptionValue);
        var list = [];
        list = component.get("v.finalUpload")
        for(var i=0; i<list.length; i++){
            if(cid == list[i].ContentDocumentId){
                console.log("yes");
                list[i].Related__c = selectedOptionValue;
            }
        }
        console.log(list);
        component.set("v.finalUpload",list);
    },
    
    handleCmbCategory: function(component, event, helper){
        var cid = event.getSource().get("v.name");	            
        var selectedOptionValue = event.getParam("value");
        console.log('====> '+selectedOptionValue);
        var list = [];
        list = component.get("v.finalUpload")
        for(var i=0; i<list.length; i++){
            if(cid == list[i].ContentDocumentId){
                console.log("yes");
                list[i].Category__c = selectedOptionValue;
            }
            console.log(list[i].Category__c);
        }
        console.log(list);
        component.set("v.finalUpload",list);
        
        //Added by Pawan PDO-1019--
        var olddocs = component.get("v.oldDocExist");
        var cmbList = component.get("v.finalUpload");
        if(olddocs){
            for(var j=0; j< cmbList.length; j++){
                if(cmbList[j].Category__c == 'Lender Credit Contract'){
                    component.set("v.docExistError",true); 
                    break;
                }
                else{
                    component.set("v.docExistError",false);  
                }
            }
            
        } 
        else{
            component.set("v.docExistError",false);  
        }
        //Pawan Code End.
    },
    
    descriptionChange: function(component, event, helper){
        var cid = event.getSource().get("v.name");	            
        var cdes =  event.getSource().get("v.value");
        var list = [];
        list = component.get("v.finalUpload")
        for(var i=0; i<list.length; i++){
            if(cid == list[i].Id){
                list[i].Description = cdes;
            }
        }
        console.log(list);
        component.set("v.finalUpload",list);
    },
    
    preview: function(component, event, helper) {
        var index = event.getSource().get("v.name");
        var fireEvent = $A.get("e.lightning:openFiles");
        fireEvent.fire({
            recordIds: [index]
        });
    },
    
    handleFinalUploadDoc: function(component, event, helper){
        component.set("v.docExistError",false);
        
        var list = [];
        list = component.get("v.finalUpload")
        for(var i=0; i<list.length; i++){
            if(list[i].Category__c == null){
                list[i].Category__c = '';
            }
        }
        helper.finalUploadDocHelper(component, list);             
    },
    
    deleteNewContent: function(component, event, helper){
        var index = event.getSource().get("v.name");
        if(confirm('Are you sure?')){
            $A.util.addClass(component.find("mySpinnerUpload"), 'slds-show');
            $A.util.removeClass(component.find("mySpinnerUpload"), "slds-hide");
            var list = [];
            list = component.get("v.finalUpload")
            for(var i=0; i<list.length; i++){
                if(list[i].ContentDocumentId == index){
                    list.splice(i,1);
                }
            }
            var action = component.get("c.deleteContent");
            action.setParams({
                'recordIdStr': index
            });
            action.setCallback(this, function(result){
                var state = result.getState();
                if(component.isValid() && state === "SUCCESS"){
                    component.set("v.filesUploaded",list);
                    component.set("v.finalUpload",list);
                    console.log("yes deleted");
                }
                if(!list.length>0){
                    component.set("v.isAfterUpload",false);
                }
                $A.util.removeClass(component.find("mySpinnerUpload"), 'slds-show');
                $A.util.addClass(component.find("mySpinnerUpload"), "slds-hide");
            });
            $A.enqueueAction(action);
        }	            
    },
       
})