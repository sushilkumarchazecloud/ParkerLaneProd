({
    doInit : function(component, event, helper) { 
        var cnt = component.get("v.count");
        if(cnt >= 1){
            component.set("v.isDisabled",false);
        }
        else{
        	component.set("v.isDisabled",true);   
        }        
		var url = $A.get('$Resource.SolarLoan ') + '/img/plusimage.png';
        component.set('v.plusImageURL', url);
        var checkurl = $A.get('$Resource.SolarLoan ') + '/img/checkgreen.png';
        component.set('v.checkImageURL', checkurl); 
        var bankStr = component.get("v.CategryName");
        var strr = 'Bank Statement Data';
        if(bankStr == strr){
            component.set("v.bankBtn",'yes');
            if(component.get("v.status") == 'COMPLETE'){
                component.set("v.bankSuccess",true);
                helper.handleSaveClose(component);
            }
        }
        var arrCategory = [];
        var arrDesc = [];
        arrDesc = component.get("v.docDescription");
        arrCategory = component.get("v.CategryName");
        if(arrCategory.length > 25){
            var str =  arrCategory.substr(0, 25);
            str = str + '...';
            component.set("v.category",str);
        }
        else{
            component.set("v.category",component.get("v.CategryName"));
        }
        if(arrDesc !=null){
            if(arrDesc.length >= 50){
                var strDesc =  arrDesc.substr(0, 50);
                strDesc = strDesc + '...';
                component.set("v.document",strDesc);
            }
            else{
                component.set("v.document",component.get("v.docDescription"));
            }
        } 
        var url = $A.get("$Label.c.bankStatementRedirectURL") + component.get("v.recordId");  
        component.set("v.bankRedirectURL",url);
        	
    },
       
    
    showModal : function(component, event, helper) {
        component.set("v.modalShow",true);
    },
    
    handleModal : function(component, event, helper) {
         component.set("v.modalShow",false);
    },
    
    handleCssChange : function(component, event, helper) {
        var yesNo = component.get("v.changeCss");
        if(yesNo == 'yes'){
            var cmpBtn = component.find('myBtn');            
            $A.util.removeClass('changeStyle');  
            var cmpDiv = component.find('docCard-green');
            $A.util.removeClass(cmpDiv,'docCard');            
            $A.util.addClass(cmpDiv, 'docCard-green');
            $A.util.removeClass('uploader');
            $A.util.addClass(cmpBtn, 'myBtnStyle');
        }
    },
    
    handleClickBank : function(component, event, helper) {        
        component.set("v.already",true);
        component.set("v.isDelete",false);
        var cmpDiv = component.find('showUploadid');
        $A.util.removeClass(cmpDiv,'showUploadHide');
        $A.util.addClass(cmpDiv,'showUploadCss');
        var hideCheck = component.get("v.ishideFake");
        if(hideCheck){
            component.set("v.ishideFake", false); 
        }
        else{
            component.set("v.ishideFake", true); 
        }          
        component.set("v.openFake",true);        
    },
    handleClickDownBank : function(component, event, helper) {
        component.set("v.ishideFake", false);
        component.set("v.openFake",false);        
        component.set("v.isDelete",true);    
    },
    
    handleClick : function(component, event, helper) {
        component.set("v.already",false);
        component.set("v.isDelete",false);
        var cmpDiv = component.find('showUploadid');
        $A.util.removeClass(cmpDiv,'showUploadHide');
        $A.util.addClass(cmpDiv,'showUploadCss');
        
        var hideCheck = component.get("v.ishide");
        if(hideCheck){
            component.set("v.ishide", false);
        }
        else{
            component.set("v.ishide", true);
        }            
        component.set("v.isOpen",true);
    },
    handleClickDown : function(component, event, helper) {
        component.set("v.isOpen",false);
        component.set("v.isDelete",true);
        component.set("v.ishide", false);       
    },
    
    addNote : function(component, event, helper) {
        component.set('v.isAddNote', true);
    }, 
    handleFilesChange : function(cmp, event, helper) {
        var file = event.getSource().get("v.files");
        cmp.set("v.isDisabled",true);
        cmp.set("v.ishide", true);
        cmp.set("v.isUploading",true);
        cmp.set("v.already",false);        
        cmp.set("v.isOpen",true);
        helper.uploadDocument(cmp, event,file[0]);
    },
    onDelete: function(component, event, helper){
        helper.onAjexDelete(component,event);
    },
    updateName: function(cmp, event, helper){
       helper.updateName(cmp,event);
        if(!cmp.get("v.isAttachUpdated")){
            cmp.set("v.isAttachUpdated",true);
            helper.updateRequestAjex(cmp,event);
        }
    }        
})