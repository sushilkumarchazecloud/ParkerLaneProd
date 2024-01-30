({
    callDoInit: function(component, recordIds){
        var action = component.get("c.getContentVersion");
        action.setParams({
            'recordIdStr': recordIds
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                component.set("v.cvList",result.getReturnValue());   
            }
        });
        $A.enqueueAction(action);
    },
	downloadSelected: function(component, selectedCV) {
        this.showSpinner(component);
        var action = component.get("c.getZipFile");
        action.setParams({
            'recordIdStr': selectedCV
        });
        action.setCallback(this, function(result){
            console.log('in attachment'+result.getState());
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                
                var attachments = result.getReturnValue();
                console.log('in attachment'+attachments);
                var zip = new JSZip();
                console.log('in attachment');
                var attachmentsFolder = zip.folder("Attachments");
                for(var i=0;i<attachments.length;i++){
                    attachmentsFolder.file(attachments[i].title + '.' + attachments[i].ext, attachments[i].data, {base64: true});
                }
                
                zip.generateAsync({type:"blob"}).then(function(content) {
                    var a = document.createElement("a");
                    document.body.appendChild(a);
                    a.style = "display: none";
                    var url = window.URL.createObjectURL(content);
                    a.href = url;
                    a.download = 'Attachments_files.zip';
                    a.click();
                    window.URL.revokeObjectURL(url);
                   $A.get("e.force:closeQuickAction").fire() 
                    
                });
            }
            else if( state == "ERROR" ){
                var errors = result.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": errors[0].message,
                    "type": "error"
                });
                toastEvent.fire();
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
     
    hideSpinner: function (component, event, helper) {
        console.log('hide spinner');
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    searchHelper: function(component,event,getInputkeyWord){
        var action = component.get("c.getAllObjRecords");
        var sobj = component.get("v.sobjecttype");
        if(sobj == null){
            sobj = 'Opportunity';
        }
        console.log(sobj.toLowerCase());
        action.setParams({
            'objType' : sobj,
            'searchFor': component.get("v.SearchKeyWord"),
            'recId': component.get("v.recordId")
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var storeResponse = result.getReturnValue();
                if (storeResponse.length == 0) {
                    component.set("v.MessageOpp", 'No Result Found...');
                } else {
                    component.set("v.MessageOpp", '');
                }
                component.set("v.listOfSearchOpp",result.getReturnValue());
                component.set("v.IconNameOpp","standard:"+sobj.toLowerCase());
            }
            $A.util.removeClass(component.find("mySpinnerOpp"), 'slds-show');
            $A.util.addClass(component.find("mySpinnerOpp"), "slds-hide");
        });
        $A.enqueueAction(action);
	},
    matchHelper: function(component,event,sId){
        var action = component.get("c.findMatch");
        action.setParams({
            'selectId' : sId,
            'oldId': component.get("v.recordId")
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var storeResponse = result.getReturnValue();
            	console.log(storeResponse);
                if(storeResponse.length > 0){
                    for(var i=0; i<storeResponse.length; i++){
                        if(storeResponse[i]=="Applicant 1"){
                            component.set("v.Applicant1",true);
                        }
                        if(storeResponse[i]=="Applicant 2"){
                            component.set("v.Applicant2",true);
                        }
                    }
                }
            }
        });
        $A.enqueueAction(action);
	},
    copyFiles: function(component, selectedCV) {
        var action = component.get("c.copyFilesToNew");
        action.setParams({
            'newCaseId': component.get("v.selectedOpp.Id"),
            'cvIds': selectedCV,
            'oldOppId': component.get("v.recordId")
        });
        action.setCallback(this, function(result){
            console.log('in attachment'+result.getState());
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success!",
                    "message": "The record has been successfully copied."
                });
                toastEvent.fire();
                var oppId = component.get("v.selectedOpp.Id");
                
                var navService = component.find("navService");
                var pageReference = {    
                    "type": "standard__recordPage",
                    "attributes": {
                        "recordId": oppId,
                        "actionName": "view"
                    }
                }
                navService.generateUrl(pageReference).then($A.getCallback(function(url) {
                    window.open(url,'_blank');
                }), 
                                                           $A.getCallback(function(error) {
                                                               console.log('error: ' + error);
                                                           }));
            }
            else if(state === "ERROR"){
                console.log(result.getError()+'yes');
            	var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": "ERROR:"+result.getError()
                });
                toastEvent.fire();
            }
            $A.util.addClass(component.find("mySpinnerCopy"), 'slds-hide');
            $A.util.removeClass(component.find("mySpinnerCopy"), "slds-show");
            component.set("v.isCopyTo",false);
            component.set("v.isSelected",false);
            component.set("v.SearchKeyWord",'');
            /*component.set("v.isSelectAll",false);
            component.set("v.selectedSize",0);
            $A.get("e.force:refreshView").fire();*/
        });
        $A.enqueueAction(action);
    },
    
    sortHelper: function(component, event, sortFieldName, ids){
        this.showSpinner(component);
        var currentDir = component.get("v.arrowDirection");
        if(currentDir == 'arrowdown'){
            component.set("v.arrowDirection", 'arrowup');
            component.set("v.isAsc", true);
        } 
        else{
            component.set("v.arrowDirection", 'arrowdown');
            component.set("v.isAsc", false);
        }
        var action = component.get('c.sortedList');  
        action.setParams({
            'cvIds': ids,
            'sortField': sortFieldName,
            'isAsc': component.get("v.isAsc")
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS"){
                component.set("v.cvList",result.getReturnValue());   
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    filterHelper: function(component, event, selectedRelated, selectedCategory){
        $A.util.addClass(component.find("mySpinner"), 'slds-show');
        $A.util.removeClass(component.find("mySpinner"), "slds-hide");
        var action = component.get("c.filterRelated");
        action.setParams({
            'recordIdStr': component.get("v.recordId"),
            'listRelated': selectedRelated,
            'listCategory': selectedCategory
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                component.set("v.cvList",result.getReturnValue());   
            }
            $A.util.addClass(component.find("mySpinner"), 'slds-hide');
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
        	component.set("v.selectedSize",0);
            component.set("v.isSelectAll",false);
        });
        $A.enqueueAction(action);
    },
    fetchUploadedFiles: function(component, idContent){
        this.showSpinner(component);
        var action = component.get("c.fetchUploaded");
        component.set("v.isUpload",false);
        action.setParams({
            'documentIds': idContent
        });
        action.setCallback(this, function(result){
            component.set("v.isAfterUpload",true);
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                component.set("v.filesUploaded",result.getReturnValue());
                component.set("v.finalUpload",result.getReturnValue());
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    helperApplicant: function(component){
        this.showSpinner(component);
        var action = component.get("c.getOppDetail");
        action.setParams({
            'recId': component.get("v.recordId")
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var val =[]; 
                console.log(val);
                val = result.getReturnValue();
                var options = [
                    { value: "General", label: "General" },
                    { value: val.Applicant_1__c, label: val.Applicant_1__r.Name }
                ];
                var app2 = val.Applicant_2__c;
                if(app2 != null){
                    var item = {"value": val.Applicant_2__c,"label": val.Applicant_2__r.Name};
                    options.push(item);
                }
                component.set("v.relatedOptions", options);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    finalUploadDocHelper: function(component, uplist){
        $A.util.addClass(component.find("mySpinnerUpload"), 'slds-show');
        $A.util.removeClass(component.find("mySpinnerUpload"), "slds-hide");
        var action = component.get("c.uploadDocuments");
        action.setParams({
            'finalList': uplist,
            'recId': component.get("v.recordId")
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                console.log('yes');
                
            }
            $A.util.removeClass(component.find("mySpinnerUpload"), 'slds-show');
            $A.util.addClass(component.find("mySpinnerUpload"), "slds-hide");
            component.set("v.isAfterUpload",false);
            $A.get("e.force:refreshView").fire();
        });
        $A.enqueueAction(action);
    },
    mergePdf: function(component,selectedCV){
        this.showSpinner(component);
        var action = component.get("c.pdfMerge");
        action.setParams({
            'forInsert': true,
            'oppId': component.get("v.recordId"),
            'ids': selectedCV
        });
        var self = this;
        action.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                console.log('yes');
                self.mergePdf1(component,selectedCV);
            }
        });
        $A.enqueueAction(action);
    },
    mergePdf1: function(component,selectedCV){
        var action1 = component.get("c.pdfMerge");
        action1.setParams({
            'forInsert': false,
            'oppId': component.get("v.recordId"),
            'ids': selectedCV
        });
        action1.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                console.log('yes call');
                window.open(result.getReturnValue(),'_blank');
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action1);
    },
})