({
    getSectionStatus : function(component, event, recordId) {
		var action = component.get("c.getSelectedSection");
        var self = this;

     	action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                component.set('v.isMortgage', JSON.parse(ret).isMortgage);
                
                if(JSON.parse(ret).CurrentSection == 'Standard Document Upload'){
                    ret = "/SupportingDocument?oppId=" + recordId;
                    window.location = ret;
                }else if(JSON.parse(ret).CurrentSection == 'Mogo Bank Link' || JSON.parse(ret).CurrentSection == 'Mogo Document Error'){
                    ret = "/apex/MogoDocument?oppId=" + recordId;
                    window.location = ret;
                }else if(JSON.parse(ret).CurrentSection == 'Mogo Document Upload'){
                    ret = "/apex/MogoSupportingDocument?oppId=" + recordId;
                    window.location = ret;
                }
            }
        });
        $A.enqueueAction(action);
	},
})