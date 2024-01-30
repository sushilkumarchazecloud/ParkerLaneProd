({
	getParentId : function(component, event) {
        console.log('>>>>>');
		var action = component.get("c.getParentId");
        var self = this;
        
        action.setParams({
            recordId: component.get('v.recordId'),
            parentFieldName: component.get('v.parentRecordAPIName'),
            fieldSetName: component.get('v.fieldSetName')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                console.log('>>>>>' + ret);
                ret = JSON.parse(response.getReturnValue());
                console.log('>>>>>' + ret);
                //console.log('>>>>>' + JSON.stringify(ret));
                if(! $A.util.isUndefinedOrNull(ret)){
                    console.log('>>>>>' + ret.parentId);
                    console.log('>>>>>' + ret.parentObjectName);
                    console.log('>>>>' + ret.fieldSetList);
                    component.set("v.objectName", ret.parentObjectName);
                    component.set("v.fieldsList", ret.fieldSetList);
                    component.set("v.iconName", ret.iconName);
                    component.set("v.fieldLabel", ret.fieldLabel);
                    component.set("v.parentRecordId", ret.parentId);
                    console.log('>>>>>' + component.get("v.parentRecordId"));
                    //console.log('>>>>>' + component.get("v.objectName"));
                }
            }
        });
        $A.enqueueAction(action);
	}
})