({
	doInit : function(cmp, event, helper) {
        cmp.set("v.quoteMainList",[]);
        var action = cmp.get('c.getQuoteName');
        action.setParams({
            oppID: cmp.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var ptr = response.getReturnValue();
                var test = [];
                for(var item in ptr){
                    test.push({
                        label :item,
                        value :ptr[item]
                    });                    
                }
                console.log(test);
                cmp.set("v.quoteMainList",test);
            }
        });
        $A.enqueueAction(action);
    },
    groupEventAction : function(cmp, event){
        var quoteId = event.getParam("quoteId"); 
        var quoteMainList = cmp.get("v.quoteMainList");
        var oldId = '';
        var found = false;

        for(var i in quoteMainList){
            var child = quoteMainList[i].value;
            for(var j in child){
                var check = child[j].application;

                if(check){
                    if(!(child[j].Id === quoteId )){
                        oldId = child[j].Id;
                        found = true;
                        break;
                    }
                }
            }
            if(found){
                break;
            }
        }

        var action = cmp.get('c.updateQuoteApplication');
        action.setParams({
            quotId:quoteId,
            oppId: cmp.get("v.recordId"),
            oldQutId : oldId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "successfuly Updated."
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
        });
        
        $A.enqueueAction(action);
    }
})