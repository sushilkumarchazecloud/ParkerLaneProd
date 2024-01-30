({
	callDoInit: function(component, recordIds){
        var action = component.get("c.fetchDocumentRequested");
        action.setParams({
            'oppId': recordIds
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                component.set("v.rdList",result.getReturnValue());
               	
                /*//Added by tazeem
                var List1 = component.get("v.rdList")
                var finalList = [];
				for(var i=0; i<List1.length; i++){
                    if(List1[i].isComplete__c != true){
                    	finalList.push(List1[i]);  
                    }
                }
                component.set("v.rdList",finalList);*/
            }
        });
        $A.enqueueAction(action);
    },
})