({
	handleFilesChange: function (cmp, event, helper) {
        // Get the list of uploaded files
        var file = event.getSource().get("v.files");
        cmp.set("v.ShowMeter",true);
        cmp.set("v.showForMetr",true);        
        helper.uploadDocument(cmp, event,file[0],helper);

    },
    
    onDelete: function(component, event, helper){
        var index = event.getSource().get('v.name');
        var lst = component.get('v.NmList');
        lst.splice(index, 1);
        component.set('v.NmList', lst);
        helper.onAjexDelete(component,event,component.get("v.IdList")[index]);
        var lstq = component.get('v.IdList');
        lstq.splice(index, 1);
        component.set('v.IdList', lstq);
    },    
})