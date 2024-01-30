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
                var opp = component.get("v.oppData");
                var ret = response.getReturnValue();
                component.set('v.isMortgage', JSON.parse(ret).isMortgage);
                var temp = component.get("v.IsApplicantTwo");
                //alert(temp);
                if(temp != 'true'){
                    if(JSON.parse(ret).CurrentSection == 'Standard Document Upload'){
                        ret = "/supportingDocument?oppId=" + recordId;
                        window.location = ret;
                    }/*else if(JSON.parse(ret).CurrentSection == 'Mogo Bank Link' || JSON.parse(ret).CurrentSection == 'Mogo Document Error'){
                        ret = "/apex/MogoDocument?oppId=" + recordId;   //Commented By tazeem for new REdirection functionality.
                        window.location = ret;
                    }*/else if(JSON.parse(ret).CurrentSection == 'Mogo Document Upload'){
                        ret = "/apex/MogoSupportingDocument?oppId=" + recordId;
                        window.location = ret;
                    }else if(JSON.parse(ret).CurrentSection == 'VOI'){
                        ret = opp.Document_Redirect_URL__c;
                        window.location = ret;
                    }
                }
            }
        });
        $A.enqueueAction(action);
	},
})