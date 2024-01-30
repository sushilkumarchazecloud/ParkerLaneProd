({
	getRet : function(component, event) {
        var action = component.get("c.getSearchData");
        console.log(component.get("v.searchKeyword"));
        action.setParams({
            searchKey : component.get("v.searchKeyword"),
            contactId : component.get("v.accountId")
        });
        
        action.setCallback(this, function(response) {
            var ret = response.getReturnValue();
            ret.join('\r\n');
            component.set("v.oppList",ret);
            var nameoptions=[];
            var place = [];
            for(var i=0;i<ret.length;i++){
                nameoptions.push({label : ret[i].Name, 
                                  value : ret[i].Name });
                place.push(ret[i].Name);
            }
            component.set("v.SearchOption",nameoptions);
            component.set("v.SearchPlaceHolder",place[0]);
        });
        $A.enqueueAction(action);
    }
})