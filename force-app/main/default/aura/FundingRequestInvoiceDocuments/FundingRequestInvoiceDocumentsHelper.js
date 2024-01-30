({  
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
     hideSpinner: function (component, event, helper) {
        console.log('hide spinner');
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    
    getDocuments: function(component, recordIds){
         var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var action = component.get("c.getFundingDocs");
        action.setParams({
            'recordIdStr': recordIds
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var ret = result.getReturnValue();
                component.set("v.Opp",ret.oppp);
                if(ret.cvListt != null){
                    component.set("v.cvList",ret.cvListt);
                    component.set("v.recordsFound",true);
                }
                else{
                    component.set("v.recordsFound",false);   
                }
                
            }
            $A.util.addClass(spinner, 'slds-hide');
        });
        $A.enqueueAction(action);
    },
    
    helperApplicant: function(component){
        this.showSpinner(component);
        var action = component.get("c.getOppDetail");
        action.setParams({
            'recId': component.get("v.Opp.Id")
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
    
    fetchUploadedFiles: function(component, idContent){
        this.showSpinner(component);
        var self = this;
        var action = component.get("c.fetchUploaded");
        var oppId = component.get("v.Opp.Id");
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
                self.getOldDocs(component);
                self.updateActivity(component, oppId);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    getOldDocs : function(component){
        var action = component.get("c.fetchPreviousDocs");
        var recordIds = component.get("v.Opp.Id");
        action.setParams({
            'recordId': recordIds
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (state == "SUCCESS"){
                component.set("v.oldDocExist",result.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }, 
    
    updateActivity: function(component, recordIds){
        var action = component.get("c.updateCustomerActivity");
        action.setParams({
            recId : recordIds
        });
        action.setCallback(this, function(result){});                           
        $A.enqueueAction(action);
    },
    
    finalUploadDocHelper: function(component, uplist){
        $A.util.addClass(component.find("mySpinnerUpload"), 'slds-show');
        $A.util.removeClass(component.find("mySpinnerUpload"), "slds-hide");
        
        var action = component.get("c.uploadDocuments");
        action.setParams({
            'finalList': uplist,
            'recId': component.get("v.Opp.Id")
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
})