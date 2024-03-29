({
	uploadDocument: function(cmp, event, file){
        cmp.set("v.isDisabled",true);
        var ids = [];
        var FileUploading = 0;  
        var FileUploaded = 0;  
        cmp.set("v.Name",file.name);
        var arr = [];
        arr = cmp.get("v.Name");
        if(arr.length > 20){
            var str =  arr.substr(0, 20);
            str = str + '...';
            console.log("arr>>>"+str);
            cmp.set("v.Name",str);
        }
        var self = this;
        uploadSelectedFile(file,function(err, res){   
            FileUploading += 1;  
            if (FileUploading === FileUploaded){  
                console.log('upload completed intellimail/');
                //self.updateName(cmp, event);
                
            }  
        }); 
        function uploadSelectedFile(file, callback) {  
            filetoBase64(file, function(err, content){  
                var conVer_object = { 
                    ContentLocation : 'S',
                    VersionData : content,   
                    PathOnClient : file.name,
                    Title : file.name,                           
                    FirstPublishLocationId : cmp.get("v.recordId"),
                    OwnerId : cmp.get("v.UserId")
                };  
                $.ajax({  
                    url: $A.get("$Label.c.SiteUrl").split("''").join("")+'/services/data/v39.0/sobjects/ContentVersion',  
                    data: JSON.stringify(conVer_object ),  
                    type: 'POST',  
                    processData: false,  
                    contentType: false,  
                    headers: {'Authorization': 'Bearer '+cmp.get("v.sessionId"), 'Content-Type': 'application/json'},  
                    xhr: function(){  
                        var xhr = new window.XMLHttpRequest(); 
                        xhr.upload.addEventListener("progress", function(evt){  
                            if (evt.lengthComputable) { 
                                var percentComplete = evt.loaded / evt.total; 
                                var percentCompletex= percentComplete*100;
                                cmp.set("v.percent",percentCompletex);  
                            }  
                        }, false);  
                        return xhr;  
                    },  
                    success: function(res) {  
                        FileUploaded += 1;
                        cmp.set("v.AttachId",res.id);
                        cmp.set("v.upload",true);
                        self.updateCustomerActivity(cmp, event);
                        cmp.set("v.showImg",true);
                        cmp.set("v.isDisabled",false);
                        cmp.set("v.isUploading",false);
                        cmp.set("v.count", cmp.get("v.count")+1);
                        var compEvent = cmp.getEvent("UploadFileEvent");
                        compEvent.setParams({
                            "disable" : false 
                        });
                        compEvent.fire();
                        callback(null, true)  
                    },  
                });  
            });  
        }  
        //Read file  
       function filetoBase64(file, callback){  
            var reader = new FileReader();  
            reader.onload = function(){  
                var myFileContents = reader.result;
                var base64Mark = 'base64,';  
                var dataStart = myFileContents.indexOf(base64Mark) + base64Mark.length;  
                myFileContents = myFileContents.substring(dataStart);  
                callback(null, myFileContents);  
            }  
            reader.readAsDataURL(file);  
        } 
    },
    
    updateCustomerActivity : function(cmp, event){
        var self = this;
        var temp = cmp.get("v.upload");
        var check;
        if(temp){
            check = true;
        }
        var action = cmp.get("c.updateActivity");
        action.setParams({
            updateField : check,
            recId : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
        });
        $A.enqueueAction(action);
    },
    
    updateName: function(cmp, event){
        var AttachId =  cmp.get("v.AttachId");
        if(!AttachId)
            return;
        var requestId =  cmp.get("v.requestId");
        if(requestId){
            this.updateNameAjex(cmp, event);
            return;
        }
        this.getDocumentId(cmp,event);
    },
    onAjexDelete : function(cmp,event){
        if(cmp.get("v.requestId")){        
            $.ajax({  
                url: $A.get("$Label.c.SiteUrl").split("''").join("")+'/services/data/v39.0/sobjects/ContentDocument/'+cmp.get("v.requestId"), 
                type: 'DELETE',  
                processData: false,  
                contentType: false,  
                headers: {'Authorization': 'Bearer '+cmp.get("v.sessionId"), 'Content-Type': 'application/json'},   
                success: function(res) {  
                    cmp.set("v.AttachId",null);
                    cmp.set("v.requestId",null);
                    cmp.set("v.upload",false);
                    cmp.set("v.percent",0);
                    cmp.set("v.Name",null);
                    cmp.set("v.files",null);
                    cmp.set("v.error",false);
                    cmp.set("v.isDelete",true);
                    cmp.set("v.isUploading",false);
                    cmp.set("v.count", cmp.get("v.count")-1);
                    console.log('count:'+cmp.get("v.count"));
                }, 
                error: function (res) {  
                }  
            });
        }
    },
    updateNameAjex: function(cmp, event){
        var conVer_object = { 
            Title : cmp.get("v.PersonName") +'-'+cmp.get("v.CategryName")+'('+cmp.get("v.Name")+')',                         
            Description: cmp.get("v.Description")
        };  
        $.ajax({  
            url: $A.get("$Label.c.SiteUrl").split("''").join("")+'/services/data/v39.0/sobjects/ContentDocument/'+cmp.get("v.requestId"), 
            type: 'PATCH',  
            data: JSON.stringify(conVer_object ),
            processData: false,  
            contentType: false,  
            headers: {'Authorization': 'Bearer '+cmp.get("v.sessionId"), 'Content-Type': 'application/json'},   
            success: function(res) {
                
            }, 
            error: function (res) {  
            }  
        }); 
    },
    getDocumentId: function(cmp, event){
        $.ajax({  
            url: $A.get("$Label.c.SiteUrl").split("''").join("")+'/services/data/v39.0/sobjects/ContentVersion/'+cmp.get("v.AttachId"), 
            type: 'GET', 
            processData: false,  
            contentType: false,  
            headers: {'Authorization': 'Bearer '+cmp.get("v.sessionId"), 'Content-Type': 'application/json'},   
            success: function(res) {
                cmp.set("v.requestId",res.ContentDocumentId);
                cmp.set("v.contentBodyId",res.FileType ==='JPG'? 'ORIGINAL_Jpg':'SVGZ');
                
            }, 
            error: function (res) {  
            }  
        }); 
    },
    updateRequestAjex: function(cmp, event){
        var conVer_object = { 
            Document_Requested__c : cmp.get("v.parentId")
        };  
        $.ajax({  
            url: $A.get("$Label.c.SiteUrl").split("''").join("")+'/services/data/v39.0/sobjects/ContentVersion/'+cmp.get("v.AttachId"), 
            type: 'PATCH',  
            data: JSON.stringify(conVer_object ),
            processData: false,  
            contentType: false,  
            headers: {'Authorization': 'Bearer '+cmp.get("v.sessionId"), 'Content-Type': 'application/json'},   
            success: function(res) {
            }, 
            error: function (res) {  
                cmp.set("v.isAttachUpdated",false);
            }  
        }); 
    },
    
    handleSaveClose : function(component) {
        component.set("v.ishideFake", false);  
        component.set("v.isComplete",true); 
        var action = component.get("c.completeBankstatement");
        action.setParams({
            recId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
        });
        $A.enqueueAction(action);
    },
})