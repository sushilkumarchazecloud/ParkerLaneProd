({
    handleComplete : function(cmp, event, helper) {
        var index = event.getSource().get("v.name");
        console.log('===> '+index);
        helper.handleComplete(cmp, event, index, true);
    },
    handleBankStatement : function(cmp, event, helper) {
        var index = event.getSource().get("v.name");
        console.log(index);
        var sldUploadList = cmp.get("v.sldUploadList");
        //var sldRecord = sldUploadList[index];
        if(sldUploadList[index].isComplete)
            helper.handleComplete(cmp, event, index, false);
        sldUploadList[index].isAlready_provided = sldUploadList[index].isAlready_provided? false : true;
        console.log('isAlready Provided '+sldUploadList[index].isAlready_provided);
        if(sldUploadList[index].isAlready_provided)
            sldUploadList[index].isNotApplicable = false;
        sldUploadList[index].isOpen = true;
        //sldUploadList[index].isComment = sldUploadList[index].isAlready_provided;
        cmp.set("v.sldUploadList",sldUploadList);
        //helper.handleComplete(cmp, event, index, true);
    },
    handleAlready : function(cmp, event, helper) {
        var index = event.getSource().get("v.name");
        var sldUploadList = cmp.get("v.sldUploadList");
        //var sldRecord = sldUploadList[index];
        if(sldUploadList[index].isComplete)
            helper.handleComplete(cmp, event, index, false);
        sldUploadList[index].isNotApplicable = sldUploadList[index].isNotApplicable? false : true;
        //sldUploadList[index].isComment = sldUploadList[index].isNotApplicable;
        if(sldUploadList[index].isNotApplicable)
            sldUploadList[index].isAlready_provided = false;
        sldUploadList[index].isOpen = true;
        cmp.set("v.sldUploadList",sldUploadList);
    },
    handleComment : function(cmp, event, helper) {
        var index = event.getSource().get("v.name");
        var sldUploadList = cmp.get("v.sldUploadList");
        var sldRecord = sldUploadList[index];
        if(sldUploadList[index].isComplete)
            helper.handleComplete(cmp, event, index, false);
        sldUploadList[index].isComment = sldUploadList[index].isComment? false : true;
        console.log('iscomment '+sldUploadList[index].isComment);
        sldUploadList[index].isOpen = true;
        cmp.set("v.sldUploadList",sldUploadList);
    },
    handleHide : function(cmp, event, helper) {
        var index = event.getSource().get("v.name");
        var sldUploadList = cmp.get("v.sldUploadList");
        var sldRecord = sldUploadList[index];
        sldUploadList[index].isOpen = sldUploadList[index].isOpen? false : true;
        console.log(sldUploadList[index].isOpen);
        cmp.set("v.sldUploadList",sldUploadList);
    },
})