({
	assignShow : function(component,event,helper){
        component.set("v.assignCmbOptions",[]);
        var agent_conId = component.get("v.accountId");
        var conAgentList = component.get("v.ConWrapper.contactList");
        var assignCmbOptions = component.get("v.assignCmbOptions");
        if(conAgentList != null){
            for(var i=0;i<conAgentList.length;i++){
                var unassignExists = assignCmbOptions.some(function (option) {
                    return option.label === "Unassign";
                });
                if (!unassignExists) {
                    assignCmbOptions.push({label: "Unassign", value: null });
                }
                
                if(conAgentList[i].Id == agent_conId){
                    assignCmbOptions.push({label: "Myself", value: conAgentList[i].Id});
                }
                if(conAgentList[i].Id != agent_conId){
                    assignCmbOptions.push({label: conAgentList[i].Name , value: conAgentList[i].Id});
                }
            }
            component.set("v.assignCmbOptions",assignCmbOptions);
        }
	}
})