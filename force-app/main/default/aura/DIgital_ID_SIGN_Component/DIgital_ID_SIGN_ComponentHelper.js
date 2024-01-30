({
	helperMethod : function(component) {
		var returndata;
        var action = component.get("c.FetchContact");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               returndata = action.getReturnValue();
                //alert(action.getReturnValue());
               component.set('v.Con', action.getReturnValue());
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
	},
    
    FetchDlBack : function(component){
        var returndata = [];
        //alert(component.get("v.recordId"));
        var action = component.get("c.sendImageDataToComponent");
        action.setParams({ 
            RecId : component.get("v.recordId"),
            title : 'BackDL'
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.ImageDataSec', action.getReturnValue());
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
    },
    FetchSelfi : function(component){
        var returndata = [];
        //alert(component.get("v.recordId"));
        var action = component.get("c.sendImageDataToComponent");
        action.setParams({ 
            RecId : component.get("v.recordId"),
            title : 'Selfi'
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.SelfiData', action.getReturnValue());
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
    },
    
    againGetData : function(component,event, helper, face){
        var action = component.get("c.sendImageDataToComponent");
        action.setParams({ 
            RecId : component.get("v.recordId"),
            title : face
        
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(face == 'DlFront'){
                    component.set('v.ImageData', '');
                    component.set('v.ImageData', action.getReturnValue());
                }
                if(face == 'BackDL'){
                    component.set('v.ImageDataSec', ''); 
                    component.set('v.ImageDataSec', action.getReturnValue()); 
                }
                if(face == 'Selfi'){
                    component.set('v.SelfiData', ''); 
                    component.set('v.SelfiData', action.getReturnValue());
                }
                  $A.get('e.force:refreshView').fire();
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
    },
    
    uploadDate : function(component,event, helper, idContent, docName){
        var action = component.get("c.frontUpload");
        action.setParams({ documentIds : idContent, recordId : component.get("v.recordId"), DocNm : docName });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isModalOpen", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Successfully Uploaded" ,
                    "type" : "success"
                });
                toastEvent.fire();
               // alert('in front');
                helper.againGetData(component,event, helper, docName);
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
        
    },
    
    FetchPassport : function(component){
        var returndata = [];
        //alert(component.get("v.recordId"));
        var action = component.get("c.sendImageDataToComponent");
        action.setParams({ 
            RecId : component.get("v.recordId"),
            title : 'Passport'
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(action.getReturnValue() != null){
                 	component.set('v.ImageData', action.getReturnValue());   
                }                
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