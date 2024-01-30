({
	handleComplete : function(cmp, event, index, isComplete){
        var sldUploadList = cmp.get("v.sldUploadList");
        var sldRecord = sldUploadList[index];
        if(sldRecord.count > 0 || sldRecord.isAlready_provided || sldRecord.isNotApplicable || sldRecord.isComment){
            var action = cmp.get("c.UpdateDocument");
            action.setParams({
                docReId : sldRecord.Id,
                isAlready_provided : isComplete?sldRecord.isAlready_provided :false,
                Details : sldRecord.Details,
                isNotApplicable :isComplete?(sldRecord.isAlready_provided? false : sldRecord.isNotApplicable):false,
                isComplete : isComplete
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS"){
                    sldUploadList[index].isComplete = isComplete;
                    sldUploadList[index].Attachments = [];
                    if(isComplete)
                        sldUploadList[index].isOpen = false;
                    cmp.set("v.sldUploadList",sldUploadList);
                    
                    //if(isBank){
                      //  window.open("https://www.bankstatements.com.au/iframe/start/CMFR-PLU");
                    //}
                }
            });
            
            $A.enqueueAction(action);
        }else{
            sldUploadList[index].isOpen = false;
            cmp.set("v.sldUploadList",sldUploadList);
        }
    }
    
})