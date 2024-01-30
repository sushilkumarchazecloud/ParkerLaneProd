({
    getrecords : function(component,event,helper){ 
        var filterData = component.find("radioGrp").get("v.value");
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var checkCmp = component.find("tglbtn").get("v.checked");
        var PaginationList = [];
        var pageSize = component.get("v.pageSize");
        var action = component.get("c.getMySettlments");
        action.setParams({ 
            stagenm : filterData,
            searchKey : component.get("v.searchKeyword"),
            contactId : component.get("v.accountId"),
            Str : component.get("v.Sorting")
        });
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                if(checkCmp == null || checkCmp == false){
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
                
                    // Box Values Showing Code.
                    var searchData = component.get("v.searchKeyword");
                    if(filterData == 'All' && (searchData == null || searchData == '')){
                        for(var i=0;i<ret.length;i++){
                            component.set("v.No_of_Action_Required",ret[i].ActionRequired);
                            component.set("v.No_Of_My_Assigned",ret[i].MyAssigned);
                            component.set("v.No_Of_Funded",ret[i].MyFunded);
                            break;
                        } 
                    }
                }  
                if(checkCmp == true){
                    var newret = [];
                    for(var i=0;i<ret.length;i++){
                        component.set("v.OppWrapper",ret[i]);
                        var actList = [];
                        if(ret[i].Opportunity.Line_Chart_JSON__c != null){
                            actList= JSON.parse(ret[i].Opportunity.Line_Chart_JSON__c);
                        }
                        if(actList != null && actList.length > 0){
                            for(var j=0;j<actList.length;j++){
                                if(actList[j].status == "Required Now" &&  actList[j].toDoFor == 'Lender'){
                                    newret.push(ret[i]);
                                }    
                            } 
                        }
                    }
                    component.set("v.dataList",newret);
                    component.set("v.totalRecords", component.get("v.dataList").length);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    
                    for(var j=0;j<pageSize;j++){
                        if(component.get("v.dataList").length>j){
                            PaginationList.push(newret[j]);
                        }else{
                            break;
                        }
                    }
                    component.set("v.PaginationList", PaginationList);
                    component.set("v.totalpages", Math.ceil(component.get("v.totalRecords")/ pageSize)); 
                }   
                $A.util.addClass(spinner, 'slds-hide');
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
    
})