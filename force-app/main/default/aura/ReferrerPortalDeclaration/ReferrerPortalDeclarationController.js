({
    tncChange : function(component, event, helper) {
        var opt1 = component.get("v.opt1");
        var opt2 = component.get("v.opt2");
        var opt3 = component.get("v.opt3");
        var checkCmp = component.find("tglbtn").get("v.checked");
        
        if(opt1 && opt2 && opt3 && checkCmp){
            component.set("v.isDeclarationBtnDisabled", false);
        }else{
            component.set("v.isDeclarationBtnDisabled", true);
        }
    },
    
    toggleChange : function(component, event, helper) {
        component.set("v.canvasSpinner",true);
        var opt1 = component.get("v.opt1");
        var opt2 = component.get("v.opt2");
        var opt3 = component.get("v.opt3");
        var checkCmp = component.find("tglbtn").get("v.checked");
        
        if(checkCmp){
            const font = new FontFace('Juliette', 'url(../../resource/signature/Juliette.otf)');
            font.load().then(() => {
                document.fonts.add(font);
                const canvas = document.getElementById('divsign');
                const ctx = canvas.getContext('2d');
                const name = component.get("v.conData.Name");
                ctx.font = '35px Juliette';
                ctx.fillStyle = '#1a2745';
                const canvasWidth = canvas.width;
                const textWidth = ctx.measureText(name).width;
                const xCoordinate = (canvasWidth - textWidth) / 2;
                ctx.fillText(name, xCoordinate, 85);
                var data = canvas.toDataURL();
                component.set("v.storeImg",data);
                component.set("v.canvasSpinner",false);
            });
        }
        else{
            const canvas = document.getElementById('divsign');
            const ctx = canvas.getContext('2d');
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            component.set("v.canvasSpinner",false);
        }
        if(opt1 && opt2 && opt3 && checkCmp){
            component.set("v.isDeclarationBtnDisabled", false);
        }else{
            component.set("v.isDeclarationBtnDisabled", true);
        }        
    },
    
    submitDeclaration : function(component, event, helper) {
        component.set("v.spinner",true);
        var action = component.get("c.updatedeclarationOnMyAccount");
        action.setParams({ conId : component.get("v.accountId"),
                          dec : true,
                          base64Data : component.get("v.storeImg")});
        action.setCallback(this, function(response) { 
            var state = response.getState(); 
            if (state === "SUCCESS") {  
                component.set("v.isDeclarationModalOpen", false);
                component.set("v.ShowAccount",true); 
                component.set("v.navSection",'MyAccount');
                helper.sendEmail(component, event, helper);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } 
            } 
            component.set("v.spinner",false);
        });
        $A.enqueueAction(action); 
    },
    
})