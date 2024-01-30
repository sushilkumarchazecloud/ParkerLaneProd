({
	callDoInit : function(component, recordIds, obj) {
		var action = component.get("c.changeUnread");
        action.setParams({
            'rId': recordIds,
            'rObj': obj
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS"){
                var storeResponse = result.getReturnValue();
                if(storeResponse.length > 0 && storeResponse === 'yes'){
                    console.log('yes');
                    $A.get('e.force:refreshView').fire();
                }
                else{
                    console.log('no');
                }
            }
        });
        $A.enqueueAction(action);	
	}
})