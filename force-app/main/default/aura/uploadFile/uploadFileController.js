({
	doInit : function(component, event, helper) {
        //var url = $A.get('$Resource.plusimage');
		var url = $A.get('$Resource.SolarLoan ') + '/img/plusimage.png';
        component.set('v.plusImageURL', url);
        var checkurl = $A.get('$Resource.SolarLoan ') + '/img/checkgreen.png';
        component.set('v.checkImageURL', checkurl);
    }, 
    addNote : function(component, event, helper) {
        component.set('v.isAddNote', true);
    }, 
    handleFilesChange : function(cmp, event, helper) {
        var file = event.getSource().get("v.files");
        cmp.set("v.ishide", true);
        //console.log(file);
        cmp.set("v.isUploading",true);
        cmp.set("v.already",false);
        //cmp.set("v.upload",true);
         helper.uploadDocument(cmp, event,file[0]);
     },
    onDelete: function(component, event, helper){
        helper.onAjexDelete(component,event);
    },
    updateName: function(cmp, event, helper){
        //alert('hello');
       helper.updateName(cmp,event);
        if(!cmp.get("v.isAttachUpdated")){
            cmp.set("v.isAttachUpdated",true);
            helper.updateRequestAjex(cmp,event);
        }
    }
})