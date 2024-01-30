({
    FundingDocUpload : function (cmp, event, helper) {
        var isUploadOrReplace ='Upload';
        // Get the list of uploaded files
        var file = event.getSource().get("v.files");
        var arr = [];
        arr = file[0].name;
        if(arr.length > 18){
            var str =  arr.substr(0, 18); 
            str = str + '...';
            cmp.set("v.Name",str);
        }
        cmp.set("v.ShowMeter",true);
        cmp.set("v.showForMetr",true);
        helper.FundingUpload(cmp, event,file[0],helper,isUploadOrReplace);
    },
    
    Replace : function (cmp, event, helper) {
        var isUploadOrReplace ='Replace';
        var index = event.getSource().get('v.name');
        var lst = cmp.get('v.NmList');
        // cmp.set("v.NmList",[]);
        lst.splice(index, 1);
        cmp.set('v.NmList', lst);
        var lstq = cmp.get('v.IdList');
        lstq.splice(index, 1);
        cmp.set('v.IdList', lstq);
        // Get the list of uploaded files  
        var file = event.getSource().get("v.files"); 
        var arr = [];
        arr = file[0].name;
        if(arr.length > 18){
            var str =  arr.substr(0, 18); 
            str = str + '...';
            cmp.set("v.Name",str);
        }
        cmp.set("v.ShowMeter",true);
        cmp.set("v.showForMetr",true);
        helper.FundingUpload(cmp, event,file[0],helper,isUploadOrReplace);
        
    },
    
    onFundingDelete : function(component, event, helper){
        var index = event.getSource().get('v.name');
        var lst = component.get('v.NmList');
        lst.splice(index, 1);
        component.set('v.NmList', lst);
        helper.fundingCrossDelete(component,event,component.get("v.IdList")[index], helper);
        var lstq = component.get('v.IdList');
        lstq.splice(index, 1);
        component.set('v.IdList', lstq);
    },  
    
    downloadDocument : function(component, event, helper) {
        var contentDocumentId = component.get("v.requestId");
        if(contentDocumentId != null){
            var url = "https://lanecorp.lightning.force.com/sfc/servlet.shepherd/document/download/"+contentDocumentId;
            window.open(url, "_blank");
        }
        
    },
    
    /*   ReplaceDocument : function(component, event, helper){
        
        // Get the list of uploaded files
        var file = event.getSource().get("v.files");
        component.set("v.ShowMeter",true);
        component.set("v.showForMetr",true);        
        helper.uploadnewDocument(component, event,file[0],helper);
        
        var index = event.getSource().get('v.name');
        var lst = component.get('v.NmList');
        lst.splice(index, 1);
        component.set('v.NmList', lst);
        helper.deleteDocument(component, event, helper);
        var lstq = component.get('v.IdList');
        lstq.splice(index, 1);
        component.set('v.IdList', lstq);
        
    }, */
    
})