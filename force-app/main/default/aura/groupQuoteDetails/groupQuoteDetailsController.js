({
    doInit : function(component, event, helper) {
        var tempList = [];
        tempList = component.get("v.quoteList");
        for(var i in tempList){
            if(tempList[i].application == true){
                component.set("v.appCheck",true);
            }
        }
    },
    
    navigateToRecord : function(component , event, helper){
        var recordId = event.currentTarget.dataset.recordId;
        var navService = component.find("navService");
        var pageReference = {    
            "type": "standard__recordPage",
            "attributes": {
                "recordId": recordId,
                "actionName": "view"
            }
        }
        navService.generateUrl(pageReference).then($A.getCallback(function(url) {
            window.open(url,'_blank');
        }), 
        $A.getCallback(function(error) {
            console.log('error: ' + error);
        }));    
    },
	sendQuote : function(cmp, event, helper) {
        if(confirm('Are you sure you want to send to customer?')){
            var action = cmp.get('c.sendQuotation');
            action.setParams({
                oppId: cmp.get("v.recordId"),
                quote : cmp.get("v.quoteList")[0].Id,
                master : cmp.get("v.masterQuote")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Mail sent successfuly."
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "error!",
                        "type": "error",
                        "message": "Please contact to administrator."
                    });
                    toastEvent.fire(); 
                }
            });
            
            $A.enqueueAction(action);
        }
    },
    sendAppToCustomer : function(cmp, event, helper) {
        var checkApp = false;
        var quoteList = cmp.get("v.quoteList");
        var quoteId = '';
        for(var i in quoteList){
            if(quoteList[i].application){
                console.log('test');
                checkApp = true;
                quoteId = quoteList[i].Id;
            }
        }
        if(checkApp){
            if(confirm('Are you sure you want to send to customer?')){
                var action = cmp.get('c.sendApplication');
                action.setParams({
                    oppId: cmp.get("v.recordId"),
                    quote : quoteId
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS"){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type": "success",
                            "message": "Mail sent successfuly."
                        });
                        toastEvent.fire();
                        $A.get('e.force:refreshView').fire();
                    }else{
                       var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "error!",
                            "type": "error",
                            "message": "Please contact to administrator."
                        });
                        toastEvent.fire(); 
                    }
                });
                
                $A.enqueueAction(action);
            }
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": "error",
                "message": "Error! You must convert one of the Quotes by checking the Application box."
            });
            toastEvent.fire();
        }
    },
    deleteMasterQuote : function(cmp, event){
        if(confirm('Are you sure you want to delete these Quotes?')){
            var action = cmp.get('c.deleteApplication');
            
            action.setParams({
                oppId: cmp.get("v.recordId"),
                mast : cmp.get("v.masterQuote")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "successfuly deleted."
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    viewApplication : function (cmp, event){
        var oppId = cmp.get("v.recordId");
        var masterQuote = cmp.get("v.masterQuote");
        var baseUrl = $A.get("$Label.c.baseUrl");
        window.open(baseUrl+'?id='+oppId+'&master='+masterQuote.replace('&', '%26'), '_blank');
    },
    
    checkApplication : function(cmp, event){
       var qutId =  event.getSource().get("v.name");
        console.log(event.getSource().get("v.checked"));
        console.log(qutId);
        if(event.getSource().get("v.checked")){
            if(confirm('are you sure?')){
                var cmpEvent = cmp.getEvent("groupEventC");
                console.log(cmpEvent);
                cmpEvent.setParams({"quoteId" : qutId});
                console.log(cmpEvent.getParams("quoteId"));
                cmpEvent.fire(); 
            }else{
                event.getSource().set("v.checked",!event.getSource().get("v.checked"));
            }
        }else{
             event.getSource().set("v.checked",!event.getSource().get("v.checked"));
        }
    },
    checkFSC: function(cmp, event){
        var index =  event.getSource().get("v.name");
        var qutList = cmp.get("v.quoteList");
        if(qutList[index].application){
            if(confirm('are you sure...?')){
                var action = cmp.get('c.updateQuote');
                action.setParams({
                    quotId : qutList[index].Id,
                    oppId: cmp.get("v.recordId")               
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS"){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type": "success",
                            "message": "successfuly Converted."
                        });
                        toastEvent.fire();
                        $A.get('e.force:refreshView').fire();
                    }else{
                        event.getSource().set("v.checked",false)
                    }
                });
                $A.enqueueAction(action);
            }
        }else{
            alert('Wrong selection...!');
            event.getSource().set("v.checked",false);
        }
    }
})