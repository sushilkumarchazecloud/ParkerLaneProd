({
    doInit: function(component, event, helper) {
        helper.getDocuments(component, event, helper);
    },
    
    downloadDocument : function(component, event, helper) {
        var contentDocumentId = event.getSource().get('v.name');
        if(contentDocumentId != null){
           var url = "/sfc/servlet.shepherd/document/download/"+contentDocumentId;
           // var url = "https://lanecorp.lightning.force.com/sfc/servlet.shepherd/document/download/"+contentDocumentId;
            window.open(url, "_blank");
        }
    },
    
})