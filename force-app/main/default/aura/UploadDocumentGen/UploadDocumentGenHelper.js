({
	uploadDocument: function(cmp, event, file, helper){
       	console.log("---fiel+"+file.name);        
        //cmp.set("v.isDisabled",true);
        var ids = [];        
        var idofData = [];
        var FileUploading = 0;  
        var FileUploaded = 0;  
        cmp.set("v.Name",file.name);
        cmp.set("v.submitcheck",true);
        
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
                        if(arr.length > 15){
                            var str =  arr.substr(0, 15);
                            str = str + '...';
                            console.log("arr>>>"+str);
                            cmp.set("v.Name",str);
                        }
                        
                        var arr;
                        var nms = cmp.get("v.NmList");
                        nms.push(cmp.get("v.Name"));
                        arr = nms;
                        cmp.set("v.NmList",arr);
                        console.log('list-NMMNNM---'+cmp.get("v.NmList"));
                        cmp.set("v.submitcheck",false);
                        cmp.set("v.upload",true);
                        cmp.set("v.showForMetr",false);  
                        helper.getDocumentId(cmp,event);    
                        cmp.set("v.count", cmp.get("v.count")+1);
                        console.log('---======'+cmp.get("v.count"));
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
    getDocumentId: function(cmp, event){
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
    
    onAjexDelete : function(cmp,event,id){
        if(cmp.get("v.requestId")){   
            $.ajax({  
                url: $A.get("$Label.c.SiteUrl").split("''").join("")+'/services/data/v39.0/sobjects/ContentDocument/'+id, 
                type: 'DELETE',  
                processData: false,  
                contentType: false,  
                headers: {'Authorization': 'Bearer '+cmp.get("v.sessionId"), 'Content-Type': 'application/json'},   
                success: function(res) { 
                   // cmp.set("v.ShowMeter",false);	
                    //cmp.set("v.AttachId",null);
                   // cmp.set("v.upload",false);
                   	//cmp.set("v.percent",0);
                   // cmp.set("v.Name",null);
                    //cmp.set("v.files",null);
                    cmp.set("v.count", cmp.get("v.count")-1);
                    console.log('count:'+cmp.get("v.count"));
                    console.log('list---after-'+cmp.get("v.IdList"));
                    cmp.set("v.cdlId",cmp.get("v.IdList"));
                }, 
                error: function (res) {  
                    console.log('Error in Operation'); 
                    console.log('dele'+res);
                }  
            });
        }
    },    
    
})