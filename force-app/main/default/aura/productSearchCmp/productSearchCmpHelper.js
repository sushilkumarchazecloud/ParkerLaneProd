({
	fetchProductType : function(cmp, event) {
        var action = cmp.get('c.getProductType');
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                cmp.set("v.option",response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
        
    },
    fetchOppStage : function(cmp, event) {
        var action = cmp.get('c.getOppStage');
        action.setParams({
            oppId : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var stage = response.getReturnValue();
                if(stage == 'Working' || stage == 'Quote')
                    cmp.set("v.oppStage",false);
                else
                	cmp.set("v.oppStage",true);
            }
        });
        
        $A.enqueueAction(action);
        
    }
})