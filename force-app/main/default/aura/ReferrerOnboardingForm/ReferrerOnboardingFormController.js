({
	prev : function(component, event, helper) {
        var pgNo = component.get("v.pageNo");
        if(pgNo>1){
            component.set("v.pageNo", pgNo - 1);
            helper.scrollTop(component, event, 0);
        }
	},
    
    next : function(component, event, helper) {
        var pgNo = component.get("v.pageNo");
        var conList = component.get("v.conList");
        var allValid = true;
        var isAddValidate = true;
        var isAllValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        if(pgNo == 1){
            
            var addressTool = component.find("addressTool");
            isAddValidate = addressTool.checkAddress();
            
        }
        allValid = isAllValid && isAddValidate;
        component.set("v.showError",!allValid);
        if (allValid) {           
            if(conList.length == 0){
                var con = component.get("v.con");
                conList.push(con);
                component.set("v.conList", conList);
            }
            console.log('@@@@' + JSON.stringify(conList));
            if(pgNo == 1){
                helper.saveAndNextRecords(component, event);
            }else if(pgNo<3){
                component.set("v.NextCall", false);
                helper.submitRecords(component, event, false);
            }
        }else{
            component.set("v.errorMsg", "Please update the form entries highlighted in red and try again");
        }
        helper.scrollTop(component, event, 0);
    },
    
    addMore : function(component, event, helper) {
        var conList = component.get("v.conList");
        var contact = {
            'sobjectType': 'Contact'
        };
        conList.push(contact);
        component.set("v.conList", conList);
	},
    
    submit : function(component, event, helper) {
		component.set("v.NextCall", true);
        helper.submitRecords(component, event, true);
	},
    
    deleteRow : function(component, event, helper) {
        var index = event.currentTarget.id;
        component.set("v.isOpenAlertModal", true);
        component.set("v.deleteIndex", index);
    },
 
    deleteRecord : function(component, event, helper) {
		helper.deleteRow(component, event, component.get("v.deleteIndex"));
        component.set("v.isOpenAlertModal", false);
	},
    
    closeAlertModel: function(component, event, helper) {
        component.set("v.isOpenAlertModal", false);
    },
})