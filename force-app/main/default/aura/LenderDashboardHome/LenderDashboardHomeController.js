({
    doInit : function(component, event, helper) {
        helper.getOpp(component, event, helper);
        var label = $A.get("$Label.c.WelcomeNote");
        component.set("v.WelcomeNote",label);
    },
    
    onChangeSearch : function(component, event, helper){
        var searchvalue = component.find("enter-search").get("v.value");        
        component.set('v.searchKeyword', searchvalue);
        if(searchvalue.length > 0){
            component.set("v.stopItrt",true);
            helper.getRet(component, event, helper);
        }
        else{
            component.set("v.stopItrt",false);
        }
    },
    
    onEnterSearch : function(component, event, helper){
        if(event.which == 13 ){
            component.set("v.navSection",'MyReferrals');
        }
    },
    
    selectOp : function(component, event, helper){
        console.log(component.get("v.searchKey"));
        var str  = event.currentTarget.dataset.record;
        
        if(str != null){
            component.set("v.searchKeyword",str);
            component.set("v.navSection",'MySettlements');
        }
    },
    
    updateView : function(component, evt, helper){
        var val = component.get("v.cont.Portal_View__c");
        var listMain = component.get("v.typesOptions");
        var action = component.get("c.updateViewofPortal");
        action.setParams({
            con : component.get("v.cont"),
            val : val
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert('SUCCESS');
                component.set("v.cont.Portal_View__c",val);                      
            }else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE RESPONSE");
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }     
            location.reload();
        });
        $A.enqueueAction(action);
    },
    
    loadMoreData: function(component, event, helper) {
        var oldOpList = component.get("v.getOppList");
        var scrollContainer = event.target;
        var scrollTop = scrollContainer.scrollTop;
        var scrollHeight = scrollContainer.scrollHeight;
        var clientHeight = scrollContainer.clientHeight;
        
        if (scrollTop + clientHeight >= scrollHeight) {
            var spinner = component.find("mySpinner2");
            var len = component.get("v.descOppList");
            var len2 = component.get("v.totalRecords");
            if(len.length < len2){
                component.set("v.spinner",true);
                $A.util.removeClass(spinner, "slds-hide");
                var action = component.get("c.getOppOnScrollForRecent");
                action.setParams({
                    contactId : component.get("v.accountId"),
                    oldoppList : oldOpList
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS"){
                        var ret = response.getReturnValue();
                        var existingdescOppList = component.get("v.descOppList");
                        if(ret !== undefined && ret !== null){
                            var newdescOppList = existingdescOppList.concat(ret);
                            var OppList = [];
                            var tDate = [];
                            for(var i=0;i<newdescOppList.length;i++){
                                OppList.push(newdescOppList[i].getOpp);
                                tDate.push(newdescOppList[i].getOpp.Last_Stage_Change_Date__c);
                            }
                            var newoppList = oldOpList.concat(OppList);
                            tDate.sort();
                            newdescOppList.sort((a, b) => tDate.indexOf(a.getOpp.Last_Stage_Change_Date__c) - tDate.indexOf(b.getOpp.Last_Stage_Change_Date__c));
                            var newdislist = newdescOppList.reverse();
                            component.set("v.descOppList",newdislist);
                            component.set("v.getOppList",newoppList);
                        }
                    }
                    else{
                        console.error("Error: " +state);
                    }
                    component.set("v.spinner",false);
                    $A.util.addClass(spinner, "slds-hide");
                });
                $A.enqueueAction(action); 
            }
        }
    },
    
    loadMoreOpp: function(component, event, helper) {
        var oldOpList = component.get("v.getOppListTodo");
        var scrollContainer = event.target;
        var scrollTop = scrollContainer.scrollTop;
        var scrollHeight = scrollContainer.scrollHeight;
        var clientHeight = scrollContainer.clientHeight;
        
        if (scrollTop + clientHeight >= scrollHeight) {
            var spinner = component.find("mySpinner3");
            var len = component.get("v.getOppListTodo");
            var len2 = component.get("v.totalRecords");
            
            if(len.length < len2){
                component.set("v.todoSpinner",true);
                $A.util.removeClass(spinner, "slds-hide");
                var action = component.get("c.getOppOnScrollForRecent");
                action.setParams({
                    contactId : component.get("v.accountId"),
                    oldoppList : oldOpList
                });
                action.setCallback(this, function(response) {
                    var ret = response.getReturnValue();
                    if(ret !== undefined && ret !== null){
                        var OppList = [];
                        for(var i=0;i<ret.length;i++){
                            OppList.push(ret[i].getOpp);
                        }
                        var newoppList = oldOpList.concat(OppList);
                        component.set("v.getOppListTodo",newoppList);
                        component.set("v.todoSpinner",false);
                        $A.util.addClass(spinner, "slds-hide");
                    }
                });
                $A.enqueueAction(action);
            }
        }
    }
    
})