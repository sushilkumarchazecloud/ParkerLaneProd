({
    getreferrals : function(component,event,helper){ 
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var checkCmp = component.find("tglbtn").get("v.checked");
        var PaginationList = [];
        var pageSize = component.get("v.pageSize");
        var action = component.get("c.getMyRefferals");
        action.setParams({ 
            searchKey : component.get("v.searchKeyword"),
            conId : component.get("v.accountId"),
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
                    
                  /*  var map1=[];
                    var map2=[];
                    for(var i=0;i<ret.length;i++){  
                        if(ret[i].Opportunity.StageName=='Approved'){
                            map1.push(ret[i]);
                        }
                        if(ret[i].Opportunity.StageName=='Settled (closed won)'){
                            map2.push(ret[i]);
                        }
                    } 
                    if(stop){
                    component.set("v.No_Of_Referred",ret.length);
                    component.set("v.No_Of_Approved",map1.length);
                    component.set("v.No_Of_Funded",map2.length); 
                    } */
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
                                if(actList[j].status == "Required Now" &&  actList[j].toDoFor == 'Referrer'){
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
                    
                /*   var map1=[];
                    var map2=[];
                    for(var i=0;i<newret.length;i++){  
                        if(newret[i].Opportunity.StageName=='Approved'){
                            map1.push(newret[i]);
                        }
                        if(newret[i].Opportunity.StageName=='Settled (closed won)'){
                            map2.push(newret[i]);
                        }
                    } 
                    if(stop){
                    component.set("v.No_Of_Referred",newret.length);
                    component.set("v.No_Of_Approved",map1.length);
                    component.set("v.No_Of_Funded",map2.length);
                    }  */ 
                }  
                $A.util.addClass(spinner, 'slds-hide');
            }});
        $A.enqueueAction(action);
    },
    
    ShowBoxValues : function (component, event, helper){
        var action = component.get("c.getMyRefferals");
        action.setParams({ 
            searchKey : null,
            conId : component.get("v.accountId"),
            Str : component.get("v.Sorting")
        }); 
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                var map1=[];
                var map2=[];
                for(var i=0;i<ret.length;i++){  
                    if(ret[i].Opportunity.StageName=='Approved'){
                        map1.push(ret[i]);
                    }
                    if(ret[i].Opportunity.StageName=='Settled (closed won)'){
                        map2.push(ret[i]);
                    }
                } 
                component.set("v.No_Of_Referred",ret.length);
                component.set("v.No_Of_Approved",map1.length);
                component.set("v.No_Of_Funded",map2.length); 
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
    
    Export :  function(component,event,helper){ 
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var exptBtnval = component.get("v.ExportBtnValue");
        var action = component.get("c.getCondata"); 
        action.setParams({ 
            conId : component.get("v.accountId")
        });
        action.setCallback(this, function(response) { 
            var state = response.getState();
            //alert('----',state);
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                component.set("v.cont",ret);
                if(ret.Portal_View__c == 'Admin View'){
                    if(exptBtnval == 'Export to PDF'){
                    window.open('/apex/CreditReportForLenderPDF?AccId='+component.get("v.cont.AccountId")+'&ConId='+component.get("v.cont.Id"));
                    } 
                    else if(exptBtnval == 'Export to Excel'){
                    window.open('/apex/CreditReportForLenderExcel?AccId='+component.get("v.cont.AccountId")+'&ConId='+component.get("v.cont.Id"));    
                    }
                }
                else{
                    if(exptBtnval == 'Export to PDF'){
                    window.open('/apex/ReferrersReport?ConId='+component.get("v.cont.Id")); 
                    }
                    else if(exptBtnval == 'Export to Excel'){
                    window.open('/apex/ReferrersReportExcel?ConId='+component.get("v.cont.Id"));    
                    }
                }                
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
           $A.util.addClass(spinner, 'slds-hide'); 
        });
        $A.enqueueAction(action);
    },
    
    FilterDataWithStage : function(component,event,helper){
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var checkCmp = component.find("tglbtn").get("v.checked");
        var PaginationList = [];
        var pageSize = component.get("v.pageSize");
        //  var changeValue = event.getParam("value");
        var changeValue = component.find("radioGrp").get("v.value");
        //   alert(changeValue); 
        var searchkeyword = component.get("v.searchKeyword")
        var action = component.get("c.getUpdatedListofOpp");
        action.setParams({
            stagenm : changeValue,
            conId : component.get("v.accountId"),
            searchKey : component.get("v.searchKeyword"),
            Str : component.get("v.Sorting")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                var sortedList = [];
                var map1=[];
                var map2=[];
                for(var i=0;i<ret.length;i++){  
                    if(ret[i].Opportunity.StageName=='Approved'){
                        map1.push(ret[i]);
                    }
                    if(ret[i].Opportunity.StageName=='Settled (closed won)'){
                        map2.push(ret[i]);
                    }
                } 
                if(changeValue == 'Approved' && (searchkeyword == null || searchkeyword == 'undefined')){
                component.set("v.No_Of_Approved",map1.length);
                }
                if(changeValue == 'Funded' && (searchkeyword == null || searchkeyword == 'undefined')){
                component.set("v.No_Of_Funded",map2.length); 
                }                
                if(checkCmp == false){
                    if(changeValue == 'Applications'){
                        for(var i=0; i<ret.length; i++){ 
                            if((ret[i].Opportunity.StageName == 'CPA Started' && (ret[i].Opportunity.Current_Application_Sections__c != 'Getting Started' && ret[i].Opportunity.Current_Application_Sections__c != 'Loan Recommendation'))
                              || ret[i].Opportunity.StageName == 'Packs Out' || ret[i].Opportunity.StageName == 'Packs Back' || ret[i].Opportunity.StageName == 'Application' || ret[i].Opportunity.StageName == 'Conditional'){
                                console.log(ret[i].Opportunity.Name);
                                sortedList.push(ret[i]);
                            }                        
                        }
                        component.set("v.dataList",sortedList);
                    }
                    else if(changeValue == 'Approved'){
                        for(var i=0; i<ret.length; i++){
                            var statusWithColor = ret[i].Opportunity.Status__c;
                            var checkExp;
                            if(statusWithColor){
                                var statusWithColorList = statusWithColor.split('-');
                                checkExp = statusWithColorList[0];
                            }                            
                            if(ret[i].Opportunity.StageName == 'Approved' && checkExp != 'Expired'){
                                sortedList.push(ret[i]);
                            }                        
                        }
                        component.set("v.dataList",sortedList);
                    }
                    else if(changeValue == 'Funding'){
                        for(var i=0; i<ret.length; i++){
                            var statusWithColor = ret[i].Opportunity.Status__c;
                            var checkExp;
                            if(statusWithColor){
                                var statusWithColorList = statusWithColor.split('-');
                                checkExp = statusWithColorList[0];
                            }
                            if(ret[i].Opportunity.StageName == 'Funding' && checkExp != 'Expired'){
                                sortedList.push(ret[i]);                           
                            }                        
                        }
                        component.set("v.dataList",sortedList);
                    }
                    else if(changeValue == 'Closed'){
                        for(var i=0; i<ret.length; i++){
                            var statusWithColor = ret[i].Opportunity.Status__c;
                            var checkExp;
                            if(statusWithColor){
                                var statusWithColorList = statusWithColor.split('-');
                                checkExp = statusWithColorList[0];
                            }
                            if(((ret[i].Opportunity.StageName == 'Funding' || ret[i].Opportunity.StageName == 'Approved') && checkExp == 'Expired')
                              || ret[i].Opportunity.StageName == 'Closed Lost' || ret[i].Opportunity.StageName == 'Nurturing' ||
                              ret[i].Opportunity.StageName == 'Working' || ret[i].Opportunity.StageName == 'Deciding'){
                                sortedList.push(ret[i]);
                            }                        
                        }
                        component.set("v.dataList",sortedList);
                    }
                    else if(changeValue == 'Quotes'){
                        for(var i=0; i<ret.length; i++){ 
                            if(((ret[i].Opportunity.StageName == 'CPA Started' || ret[i].Opportunity.StageName == 'Quote')
                                && (ret[i].Opportunity.Current_Application_Sections__c == 'Getting Started' || ret[i].Opportunity.Current_Application_Sections__c == 'Loan Recommendation'))){
                                sortedList.push(ret[i]);
                            }                        
                        }
                        component.set("v.dataList",sortedList);
                    }
                        else{
                            component.set("v.dataList",ret);
                        }
                    
                    component.set("v.totalRecords", component.get("v.dataList").length);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    var newArr = component.get("v.dataList");
                    
                    for(var j=0;j<pageSize;j++){
                        if(component.get("v.dataList").length>j){
                            PaginationList.push(newArr[j]);
                        }else{
                            break;
                        }
                    }
                    component.set("v.PaginationList", PaginationList);
                    component.set("v.totalpages", Math.ceil(component.get("v.totalRecords")/ pageSize));
                    
                    
                }  
                if(checkCmp == true){
                    var newret = [];
                    
                    for(var i=0;i<ret.length;i++){
                        component.set("v.OppWrapper",ret[i]);
                        var actList = [];
                        if(ret[i].Opportunity.Line_Chart_JSON__c != null){
                            actList= JSON.parse(ret[i].Opportunity.Line_Chart_JSON__c);
                        }
                        if(actList != null){
                            for(var j=0;j<actList.length;j++){
                                if(actList[j].status == "Required Now" &&  actList[j].toDoFor == 'Referrer'){
                                    newret.push(ret[i]);
                                }    
                            } 
                        }     
                    }  
                    
                    if(changeValue == 'Applications'){
                        for(var i=0; i<newret.length; i++){ 
                            if((newret[i].Opportunity.StageName == 'CPA Started' && (newret[i].Opportunity.Current_Application_Sections__c != 'Getting Started' && newret[i].Opportunity.Current_Application_Sections__c != 'Loan Recommendation'))
                              || newret[i].Opportunity.StageName == 'Packs Out' || newret[i].Opportunity.StageName == 'Packs Back' || ret[i].Opportunity.StageName == 'Application' || ret[i].Opportunity.StageName == 'Conditional'){
                                console.log(newret[i].Opportunity.Name);
                                sortedList.push(newret[i]);
                            }                        
                        }
                        component.set("v.dataList",sortedList);
                    }
                    else if(changeValue == 'Approved'){
                        for(var i=0; i<newret.length; i++){
                            var statusWithColor = newret[i].Opportunity.Status__c;
                            var checkExp;
                            if(statusWithColor){
                                var statusWithColorList = statusWithColor.split('-');
                                checkExp = statusWithColorList[0];
                            }                            
                            if(newret[i].Opportunity.StageName == 'Approved' && checkExp != 'Expired'){
                                sortedList.push(newret[i]);
                            }                        
                        }
                        component.set("v.dataList",sortedList);
                    }
                    else if(changeValue == 'Funding'){
                        for(var i=0; i<newret.length; i++){
                            var statusWithColor = newret[i].Opportunity.Status__c;
                            var checkExp;
                            if(statusWithColor){
                                var statusWithColorList = statusWithColor.split('-');
                                checkExp = statusWithColorList[0];
                            }
                            if(newret[i].Opportunity.StageName == 'Funding' && checkExp != 'Expired'){
                                sortedList.push(newret[i]);                           
                            }                        
                        }
                        component.set("v.dataList",sortedList);
                    }
                    else if(changeValue == 'Closed'){
                        for(var i=0; i<newret.length; i++){
                            var statusWithColor = newret[i].Opportunity.Status__c;
                            var checkExp;
                            if(statusWithColor){
                                var statusWithColorList = statusWithColor.split('-');
                                checkExp = statusWithColorList[0];
                            }
                            if(((newret[i].Opportunity.StageName == 'Funding' || newret[i].Opportunity.StageName == 'Approved') && checkExp == 'Expired')
                              || newret[i].Opportunity.StageName == 'Closed Lost' || newret[i].Opportunity.StageName == 'Nurturing' ||
                              newret[i].Opportunity.StageName == 'Working' || newret[i].Opportunity.StageName == 'Deciding'){
                                sortedList.push(newret[i]);
                            }                        
                        }
                        component.set("v.dataList",sortedList);
                    }
                    else if(changeValue == 'Quotes'){
                        for(var i=0; i<newret.length; i++){ 
                            if(((newret[i].Opportunity.StageName == 'CPA Started' || newret[i].Opportunity.StageName == 'Quote') &&
                                (newret[i].Opportunity.Current_Application_Sections__c == 'Getting Started' || newret[i].Opportunity.Current_Application_Sections__c == 'Loan Recommendation'))){
                                sortedList.push(newret[i]);
                            }                        
                        }
                        component.set("v.dataList",sortedList);
                    }
                        else{
                            component.set("v.dataList",newret);
                        }
                    
                    component.set("v.totalRecords", component.get("v.dataList").length);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    var newArr = component.get("v.dataList");
                    
                    for(var j=0;j<pageSize;j++){
                        if(component.get("v.dataList").length>j){
                            PaginationList.push(newArr[j]);
                        }else{
                            break;
                        }
                    }
                    component.set("v.PaginationList", PaginationList);
                    component.set("v.totalpages", Math.ceil(component.get("v.totalRecords")/ pageSize));  
                }  
            }
            else if (state === "INCOMPLETE") {
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
          $A.util.addClass(spinner, 'slds-hide');   
        });
        $A.enqueueAction(action);
    },
    
})