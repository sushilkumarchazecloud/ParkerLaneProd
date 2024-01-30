({
    getContactsHelper : function(component,event,helper){
        var stop = component.get("v.StopBoxNmbers");
        var PaginationList = [];
        var pageSize = component.get("v.pageSize");
        var action = component.get("c.getMyTeam");
        action.setParams({ 
            searchKey : component.get("v.searchKeyword"),
            conId : component.get("v.accountId"),
            Str : component.get("v.Sorting")
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                component.set("v.dataList",ret);
                component.set("v.totalRecords", component.get("v.dataList").length);
                component.set("v.startPage",0);
                component.set("v.endPage",pageSize-1);
                
                for(var j=0;j<pageSize;j++){
                    if(component.get("v.dataList").length>j){
                        PaginationList.push(response.getReturnValue()[j]);
                    }else{
                        break;
                    }
                }
                component.set("v.PaginationList", PaginationList);
                component.set("v.totalpages", Math.ceil(component.get("v.totalRecords")/ pageSize));
                if(stop){
                    var map1=[];
                    var map2=[];
                    var map3=[];
                    for(var i=0;i<ret.length;i++){
                        if(ret[i].ReferrerContact.Status__c=='Active'){
                            map1.push(ret[i]);
                        }
                        if(ret[i].ReferrerContact.Status__c=='Active' && ret[i].ReferrerContact.Admin__c==true){
                            map2.push(ret[i]);
                        }
                        if(ret[i].ReferrerContact.Status__c=='Hold' || ret[i].ReferrerContact.Status__c=='Retired'){
                            map3.push(ret[i]);
                        } 
                        
                    } 
                    component.set("v.No_Of_ActiveCon",map1.length);
                    component.set("v.No_Of_AdminCon",map2.length);
                    component.set("v.No_Of_retiredCon",map3.length); 
                } 
            }});
        $A.enqueueAction(action);
    },
    
    setData : function (component, event, startPage, endPage, pageNumber){
        var pageSize = component.get("v.pageSize");
        var dataList = component.get("v.dataList");
        var PaginationList = [];
        
        for(var i=startPage; i<=endPage; i++){   
            if(dataList.length<=i){
                break;
            }
            PaginationList.push(dataList[i]);
        }
        component.set("v.PaginationList",PaginationList); 
        component.set("v.startPage", startPage);
        component.set("v.endPage",endPage);
        component.find("pageNumber").set("v.value", ""+pageNumber);
    },
    
    addMore : function(component, event) {
        var conList = component.get("v.conList");
        var contact = {
            'sobjectType': 'Contact'
        };
        conList.push(contact);
        component.set("v.conList", conList);
    },
})