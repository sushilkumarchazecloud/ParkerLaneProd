({
    getOpp : function(component, event, helper) {
        var action = component.get("c.getOpp");
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        action.setParams({
            contactId : component.get("v.accountId")
        });
        
        action.setCallback(this, function(response) {
            var ret = response.getReturnValue();
            //console.log('retOpp'+ret);
            if(ret != undefined && ret != null && ret.length > 0 && ret[0].getOpp != null){
                component.set("v.funded",ret);
                component.set("v.showAdmin",ret[0].checkAdmin);
                component.set("v.totalRecords",ret[0].Oldrecords);
                var OppList = [];
                var tDate = [];
                for(var i=0;i<ret.length;i++){
                    OppList.push(ret[i].getOpp);
                    tDate.push(ret[i].getOpp.Last_Stage_Change_Date__c);
                }
                component.set("v.getOppList",OppList);
                component.set("v.getOppListTodo",OppList);              
                helper.setOppDetail(component, event, helper);
                if(tDate != null && tDate.length > 0){
                tDate.sort();
                }
                ret.sort((a, b) => tDate.indexOf(a.getOpp.Last_Stage_Change_Date__c) - tDate.indexOf(b.getOpp.Last_Stage_Change_Date__c));
                var desList = ret.reverse();
                component.set("v.descOppList",desList);
            }
            $A.util.addClass(spinner, 'slds-hide');
        });
        $A.enqueueAction(action);        
    },
    
    setOppDetail : function(component, event, helper) {
        var rett = component.get("v.getOppListTodo");   
        var cntt = 1;
        var spinner = component.find("mySpinner");
        for(var i=0;i<rett.length;i++){
            var actList = [];
            if(rett[i].Line_Chart_JSON__c != null){
                actList= JSON.parse(rett[i].Line_Chart_JSON__c);
            }                
            var count = 1;
            if(actList != null){
                for(var j=0;j<actList.length;j++){
                    if(actList[j].status == "Required Now" &&  actList[j].toDoFor == 'Lender' && count == 1){
                        count++;
                        cntt+= 1;
                        break;
                    }    
                } 
            }     
        }
        if(cntt < 10){
            $A.util.removeClass(spinner, "slds-hide");
            var oldOpList = component.get("v.getOppListTodo");
            var action = component.get("c.getOppOnScrollForRecent");
            action.setParams({
                contactId : component.get("v.accountId"),
                oldoppList : oldOpList
            });
            action.setCallback(this, function(response) {
                var ret = response.getReturnValue();
                if(ret !== undefined && ret !== null){
                    //var data = ret.getOppList;
                    var OppList = [];
                    for(var i=0;i<ret.length;i++){
                        OppList.push(ret[i].getOpp);
                    }
                    var newoppList = oldOpList.concat(OppList);
                    component.set("v.getOppListTodo",newoppList);
                    $A.util.addClass(spinner, 'slds-hide');
                    helper.setOppDetail(component, event, helper);
                }
                $A.util.addClass(spinner, 'slds-hide');
            });
            $A.enqueueAction(action);            
        }
        $A.util.addClass(spinner, 'slds-hide');
    },
    
    getRet : function(component, event, helper) {
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