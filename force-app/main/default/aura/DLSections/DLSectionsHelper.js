({
	uploadDocument: function(cmp, event, file, helper){
       	console.log("---fiel+"+file.name);        
        //cmp.set("v.isDisabled",true);
        var ids = [];        
        var idofData = [];
        var FileUploading = 0;  
        var FileUploaded = 0;  
        var voi = cmp.get("v.VOIID");
        console.log('VOI--',JSON.stringify(voi));
        var conName = '';
        if(cmp.get("v.VOIFOR") == 'Front of ID'){
            conName = 'DL Front ' + voi.Contact__r.Name;   
        }       
        else{
            conName = 'DL Back ' + voi.Contact__r.Name;   
        }
        cmp.set("v.Name",conName);
        console.log('conNaME ==='+cmp.get("v.Name"));
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
                    Title : conName, 					                    
                    FirstPublishLocationId : voi.VOI_Detail__c // record id
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
                        cmp.set("v.doneText", 'UPLOADED');
                        console.log('name==='+JSON.stringify(res));
                        FileUploaded += 1;
                        cmp.set("v.AttachId",res.id); 
                       
                        cmp.set("v.upload",true);
                        helper.getDocumentId(cmp,event);    
                        cmp.set("v.count", cmp.get("v.count")+1);
                        console.log('---======'+cmp.get("v.count"));
                        cmp.set("v.isClickToUpload", false);
                        cmp.set("v.VOIFOR",'Back of ID');
                        cmp.set("v.NameOfUploadFile",'UPLOAD BACK OF ID');
                        cmp.set("v.percent",0);
                        
                        if(cmp.get("v.VOIFOR") == 'Back of ID'){
                            cmp.set("v.times", cmp.get("v.times")+1);
                        }
                        
                        if(cmp.get("v.times") >= 2){
                            cmp.set("v.flag",false);
                            var call = cmp.get("v.callAfter");
                            call();
                        }
                        
                        callback(null, true)  
                    },  
                    error: function (res) {  
                        console.log('Error in Operation'); 
                        console.log('doc=='+JSON.stringify(res));
                        helper.updateForError(cmp, event, JSON.stringify(res));
                    	alert('Please Contact to Admin!!');
					} 
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
    
    updateForError : function(component, event,message){
        var action = component.get("c.erroOnVOI");
        var data = message+ 'RECID++++++'+component.get("V.CON");
        action.setParams({ 
            msg : data
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert("From server: " + action.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert("Error message: " + 
                                  errors[0].message);
                        }
                    } else {
                        alert("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
    }
    
    
})