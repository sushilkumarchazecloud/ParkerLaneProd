({
	handleComplete : function(cmp, event, index, isComplete){
        var sldUploadList = cmp.get("v.sldUploadList");
        var self = this;
        var sldRecord = sldUploadList[index];
        if(sldRecord.count > 0 || sldRecord.isAlready_provided || sldRecord.isNotApplicable || sldRecord.isComment){
            var action = cmp.get("c.UpdateDocument");
            action.setParams({
                docReId : sldRecord.Id,
                isAlready_provided : isComplete?sldRecord.isAlready_provided :false,
                Details : sldRecord.Details,
                isNotApplicable :isComplete?(sldRecord.isAlready_provided? false : sldRecord.isNotApplicable):false,
                isComplete : isComplete,
                recId : cmp.get("v.recordId")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                var returnValue = response.getReturnValue();
                if (state === "SUCCESS"){
                    cmp.set("v.sendMail",false);
                    cmp.set("v.isDisabled",false);  
                    sldUploadList[index].isComplete = isComplete;
                    
                    sldUploadList[index].Attachments = [];
                    if(isComplete){
                        sldUploadList[index].isOpen = false;
                    }                        
                    cmp.set("v.sldUploadList",sldUploadList);
                    self.toggleSpinner(cmp, event);
                }
            });
            $A.enqueueAction(action);
      		
        }else{
            sldUploadList[index].isOpen = false;
            cmp.set("v.sldUploadList",sldUploadList);
        }
    },
    
    toggleSpinner: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },    
})