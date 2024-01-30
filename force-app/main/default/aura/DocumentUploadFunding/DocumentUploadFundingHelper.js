({
    FundingUpload: function(cmp, event, file, helper, isUploadOrReplace){
        console.log("---fiel+"+file.name);  
        var ids = [];        
        var idofData = [];
        var FileUploading = 0;  
        var FileUploaded = 0;  
        
        var self = this;
        uploadSelectedFile(file,function(err, res){   
            FileUploading += 1;  
            if (FileUploading === FileUploaded){  
                console.log('upload completed intellimail/');
                console.log('opopooop--',res);
                console.log('opopooop--',JSON.stringify(res));
                
            }  
        }); 
        function uploadSelectedFile(file, callback) {  
            filetoBase64(file, function(err, content){  
                var conVer_object = { 
                    ContentLocation : 'S',
                    VersionData : content,   
                    PathOnClient : file.name,
                    Title : file.name, 
                    FirstPublishLocationId : cmp.get("v.accountId") // record id
                };  
                console.log('>>>>>>>'+cmp.get("v.sessionId"));
                $.ajax({  
                    url: $A.get("$Label.c.SiteUrl").split("''").join("")+'/services/data/v39.0/sobjects/ContentVersion',  
                    data: JSON.stringify(conVer_object),  
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
                                console.log('-----'+percentCompletex);
                                cmp.set("v.percent",percentCompletex);                                
                            }  
                        }, false);
                        return xhr;  
                    },  
                    success: function(res) { 
                        console.log('name==='+JSON.stringify(res));
                        FileUploaded += 1;
                        cmp.set("v.AttachId",res.id); 
                        var arr = [];
                        arr = cmp.get("v.Name");
                        if(arr.length > 22){
                            var str =  arr.substr(0, 22); 
                            str = str + '...';
                            console.log("arr>>>"+str);
                            cmp.set("v.Name",str);
                            
                        }
                        var self = this;
                        var arr;
                        var nms = cmp.get("v.NmList");
                        nms.push(cmp.get("v.Name"));
                        arr = nms;
                        cmp.set("v.NmList",arr);
                        console.log('list-NMMNNM---'+cmp.get("v.NmList"));
                        cmp.set("v.UploadButtonFunding",false);
                        cmp.set("v.upload",true);
                        cmp.set("v.showForMetr",false);
                        cmp.set("v.DocExist",true);
                        cmp.set("v.DocError",false);
                        helper.getDocumentIdFunding(cmp,event,helper,isUploadOrReplace);
                        cmp.set("v.count", cmp.get("v.count")+1);
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
    
    getDocumentIdFunding: function(cmp, event, helper, isUploadOrReplace){
        $.ajax({  
            url: $A.get("$Label.c.SiteUrl").split("''").join("")+'/services/data/v39.0/sobjects/ContentVersion/'+cmp.get("v.AttachId"), 
            type: 'GET', 
            processData: false,  
            contentType: false,  
            headers: {'Authorization': 'Bearer '+cmp.get("v.sessionId"), 'Content-Type': 'application/json'},   
            success: function(res) {
                console.log(res);
                
                var ids = cmp.get("v.IdList");
                ids.push(res.ContentDocumentId);
                cmp.set("v.IdList",ids);
                console.log('list----'+cmp.get("v.IdList"));
                if(isUploadOrReplace == 'Upload'){
                helper.AddDocReq(cmp, event, helper);
                }
                else if(isUploadOrReplace == 'Replace'){
                  helper.ReplaceFunction(cmp, event, helper);
                }
                var cdId;
                var docList = cmp.get("v.cdlId");
                docList.push(res.ContentDocumentId);
                cdId = docList;
                cmp.set("v.cdlId",cdId);
                cmp.set("v.requestId",res.ContentDocumentId);
                cmp.set("v.contentBodyId",res.FileType ==='JPG'? 'ORIGINAL_Jpg':'SVGZ');
                
            }, 
            
            error: function (res) {  
                console.log('Error in Operation'); 
                console.log('doc=='+res);
            }
            
        }); 
        
    },
    
    
    AddDocReq : function (cmp, event, helper){
        var oppId = cmp.get("v.opp.Id");
        var docuIdList = cmp.get("v.IdList");
        var documentId = docuIdList[0];
        if(documentId != null){
            var action = cmp.get("c.addDocReqOnOppfromFunding");
            action.setParams({ OppId: oppId, docId: documentId });
            action.setCallback(this, function(response) {
                var record = response.getReturnValue();
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("Document Uploaded Succesfully");
                   // alert("Document Uploaded Succesfully");
                    var docreqId;
                    if(record){
                        cmp.set("v.docreqId",record.Id);
                    }
                } else {
                    console.log("Error in Uploading Document");
                   // alert("Error");
                }
            });
            $A.enqueueAction(action); 
        }
    },
    
    ReplaceFunction : function(cmp, event, helper){
        var oppId = cmp.get("v.opp.Id");
        var docuIdList = cmp.get("v.IdList");
        var docReqId = cmp.get("v.docreqId");
        var documentId = docuIdList[0];
        if(documentId != null){
            var action = cmp.get("c.ReplaceDoc");
            action.setParams({ OppId: oppId, docId: documentId, DocReqId: docReqId});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("Document Replaced Succesfully");
                   // alert("Document Replaced Succesfully");
                } else {
                    console.log("Error in Replacing Document");
                   // alert("Error");
                }
            });
            $A.enqueueAction(action); 
        }
        
    },
    
    fundingCrossDelete : function(cmp,event,id,helper){
        if(cmp.get("v.requestId")){   
            $.ajax({  
                url: $A.get("$Label.c.SiteUrl").split("''").join("")+'/services/data/v39.0/sobjects/ContentDocument/'+id, 
                type: 'DELETE',  
                processData: false,  
                contentType: false,  
                headers: {'Authorization': 'Bearer '+cmp.get("v.sessionId"), 'Content-Type': 'application/json'},   
                success: function(res) { 
                    helper.docreqDeleteandUpdate(cmp, event, helper);
                    cmp.set("v.count", cmp.get("v.count")-1);
                    cmp.set("v.UploadButtonFunding",true);
                }, 
                error: function (res) {  
                    console.log('Error in Operation'); 
                    console.log('dele'+res);
                }  
            });
        }
    },
    
    docreqDeleteandUpdate : function(cmp, event, helper){
           var oppId = cmp.get("v.opp.Id");
           var docreqId = cmp.get("v.docreqId");
           // alert('OppppId----'+oppId);
           // alert('DocccIdddd----'+docreqId)
            var action = cmp.get("c.deleteDocumentRequest");
            action.setParams({ OppId: oppId , reqId : docreqId});
            action.setCallback(this, function(response) {
                var state = response.getState();
                var ret = response.getReturnValue();
                if (state === "SUCCESS") {
                 //   alert(ret);
                    if(ret == true){
                        cmp.set("v.DocExist",true);
                        cmp.set("v.DocError",false);
                        helper.getdocument(cmp, event, helper);   
                    }
                    else if(ret == false){
                        cmp.set("v.DocExist",false);
                        cmp.set("v.UploadButtonFunding",true);  
                    }
                } 
                else {
                    console.log("Error deleting document.");
                }
            });
            $A.enqueueAction(action);
    }, 
    
    getdocument : function(cmp, event, helper){
        var opp = cmp.get("v.opp.Id");
        var action1 = cmp.get("c.getDocument");
        action1.setParams({OppId: opp});
        action1.setCallback(this, function(response) {
            var records = response.getReturnValue();
            if (response.getState() === "SUCCESS") {
                if(records !=null ){
                    var NameList = records.NmList;
                    if(NameList.length > 0){
                        cmp.set("v.NmList",records.NmList);
                        cmp.set("v.cdlId",records.cdlId);
                        cmp.set("v.docreqId",records.docReqId);
                        var num = '1';
                        cmp.set("v.count",num);
                        cmp.set("v.requestId",records.document.Id);
                        cmp.set("v.IdList",records.cdlId);
                        cmp.set("v.Name",records.document.Title);
                        cmp.set("v.upload",true);
                        cmp.set("v.showForMetr",false);
                        cmp.set("v.fundingpage",true);
                        cmp.set("v.UploadButtonFunding",false);
                    }
                    else{
                        cmp.set("v.UploadButtonFunding",true);    
                    }
                }
                else{
                    cmp.set("v.UploadButtonFunding",true);    
                }
            }
            else if (response.getState() === "ERROR") {
                console.log('Error');
            }
        });
        $A.enqueueAction(action1); 
    }
    
    
    /* uploadnewDocument: function(component, event, file, helper){
        console.log("---fiel+"+file.name);        
        //component.set("v.isDisabled",true);
        var ids = [];        
        var idofData = [];
        var FileUploading = 0;  
        var FileUploaded = 0;  
        component.set("v.Name",file.name);
        
        var self = this;
        uploadSelectedFile(file,function(err, res){   
            FileUploading += 1;  
            if (FileUploading === FileUploaded){  
                console.log('upload completed intellimail/');
                //self.updateName(component, event); 
            }  
        }); 
        alert(component.get("v.accountId"));
        function uploadSelectedFile(file, callback) {  
            filetoBase64(file, function(err, content){  
                var conVer_object = { 
                    ContentLocation : 'S',
                    VersionData : content,   
                    PathOnClient : file.name,
                    Title : file.name, 					                    
                    FirstPublishLocationId : component.get("v.accountId") // record id
                };  
                console.log('>>>>>>>'+component.get("v.sessionId"));
                $.ajax({  
                    url: $A.get("$Label.c.SiteUrl").split("''").join("")+'/services/data/v39.0/sobjects/ContentVersion',  
                    data: JSON.stringify(conVer_object),  
                    type: 'POST',  
                    processData: false,  
                    contentType: false,  
                    headers: {'Authorization': 'Bearer '+component.get("v.sessionId"), 'Content-Type': 'application/json'},  
                    xhr: function(){  
                        var xhr = new window.XMLHttpRequest(); 
                        xhr.upload.addEventListener("progress", function(evt){  
                            if (evt.lengthComputable) { 
                                var percentComplete = evt.loaded / evt.total; 
                                var percentCompletex= percentComplete*100;
                                console.log('-----'+percentCompletex);
                                component.set("v.percent",percentCompletex);                                
                            }  
                        }, false);
                        return xhr;  
                    },  
                    success: function(res) { 
                        console.log('name==='+JSON.stringify(res));
                        FileUploaded += 1;
                        component.set("v.AttachId",res.id); 
                        var arr = [];
                        arr = component.get("v.Name");
                        if(arr.length > 15){
                            var str =  arr.substr(0, 15);
                            str = str + '...';
                            console.log("arr>>>"+str);
                            component.set("v.Name",str);
                            
                        }
                        
                        var arr;
                        var nms = component.get("v.NmList");
                        nms.push(component.get("v.Name"));
                        arr = nms;
                        component.set("v.NmList",arr);
                        console.log('list-NMMNNM---'+component.get("v.NmList"));
                        component.set("v.UploadButtonFunding",false);
                        component.set("v.upload",true);
                        component.set("v.showForMetr",false);  
                        helper.getDocumentId(component,event);    
                        component.set("v.count", component.get("v.count")+1);
                        console.log('---======'+component.get("v.count"));
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
    
    deleteDocument: function(component, event, helper) {
        // Make a server call to delete the old document
        var docId = component.get("v.requestId");
        var action = component.get("c.deleteDocumentById");
        action.setParams({ documentId: docId });
        action.setCallback(this, function(response) {
            // Handle the response
            var state = response.getState();
            if (state === "SUCCESS") {
                //   alert("Document deleted successfully.");
            } else {
                alert("Error deleting document.");
            }
        });
        $A.enqueueAction(action);
    }, */
    
})