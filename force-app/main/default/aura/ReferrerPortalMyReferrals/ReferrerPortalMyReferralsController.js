({
    doInit : function(component, event, helper){
        helper.getreferrals(component, event, helper);
        helper.ShowBoxValues(component, event, helper);
        
        setInterval($A.getCallback(function() {
            var nav = component.get("v.navSection");
            if (nav == 'MyReferrals'){
                var filterData = component.find("radioGrp").get("v.value");
                if(filterData == 'All'){
                    helper.getreferrals(component, event, helper);
                    helper.ShowBoxValues(component, event, helper);
                }
                else {
                    helper.FilterDataWithStage(component, event, helper);  
                }
            }
        }), 300000);
    },  
    
    getToggleButtonValue : function(component,event,helper){
        var checkCmp = component.find("tglbtn").get("v.checked");
        component.set("v.chkboxvalue",checkCmp);
        
        var filterData = component.find("radioGrp").get("v.value");
        if(filterData == 'All'){
            helper.getreferrals(component, event, helper);
        }
        else {
            helper.FilterDataWithStage(component, event, helper);  
        }
    },
    
    SortByCrDate: function(component, event, helper) {
        var str = 'CreatedDate DESC';
        component.set("v.Sorting",str);
        component.set("v.CrDateDownBtn",false);
        component.set("v.NameDownBtn",true);
        component.set("v.StatusDownBtn",true);
        
        var filterData = component.find("radioGrp").get("v.value");
        if(filterData == 'All'){
            helper.getreferrals(component, event, helper);
            helper.ShowBoxValues(component, event, helper);
        }
        else {
            helper.FilterDataWithStage(component, event, helper);  
        }
    },
    
    sortCrDateASC : function(component, event, helper) {
        var str = 'CreatedDate ASC';
        component.set("v.Sorting",str);
        component.set("v.CrDateDownBtn",false);
        component.set("v.NameDownBtn",true);
        component.set("v.StatusDownBtn",true);
        
        var filterData = component.find("radioGrp").get("v.value");
        if(filterData == 'All'){
            helper.getreferrals(component, event, helper);
            helper.ShowBoxValues(component, event, helper);
        }
        else {
            helper.FilterDataWithStage(component, event, helper);  
        }
    },
    
    SortByName : function(component, event, helper) {
        var str = 'Name ASC';
        component.set("v.Sorting",str);
        component.set("v.NameDownBtn",false);
        component.set("v.CrDateDownBtn",true); 
        component.set("v.StatusDownBtn",true);
        
        var filterData = component.find("radioGrp").get("v.value");
        if(filterData == 'All'){
            helper.getreferrals(component, event, helper);
            helper.ShowBoxValues(component, event, helper);
        }
        else{
            helper.FilterDataWithStage(component, event, helper);  
        }
    }, 
    
    SortByNameDESC : function(component, event, helper) {
        var str = 'Name DESC';
        component.set("v.Sorting",str);
        component.set("v.NameDownBtn",false);
        component.set("v.CrDateDownBtn",true); 
        component.set("v.StatusDownBtn",true);
        
        var filterData = component.find("radioGrp").get("v.value");
        if(filterData == 'All'){
            helper.getreferrals(component, event, helper);
            helper.ShowBoxValues(component, event, helper);
        }
        else{
            helper.FilterDataWithStage(component, event, helper);  
        }
    }, 
    
    SortByStatus  : function(component, event, helper) {
        var str = 'StageName ASC';
        component.set("v.Sorting",str);
        component.set("v.StatusDownBtn",false);
        component.set("v.NameDownBtn",true);
        component.set("v.CrDateDownBtn",true);
        
        var filterData = component.find("radioGrp").get("v.value");
        if(filterData == 'All'){
            helper.getreferrals(component, event, helper);
            helper.ShowBoxValues(component, event, helper);
        }
        else{
            helper.FilterDataWithStage(component, event, helper);  
        }
    },
    
    SortByStatusDESC  : function(component, event, helper) {
        var str = 'StageName DESC';
        component.set("v.Sorting",str);
        component.set("v.StatusDownBtn",false);
        component.set("v.NameDownBtn",true);
        component.set("v.CrDateDownBtn",true);
        
        var filterData = component.find("radioGrp").get("v.value");
        if(filterData == 'All'){
            helper.getreferrals(component, event, helper);
            helper.ShowBoxValues(component, event, helper);
        }
        else{
            helper.FilterDataWithStage(component, event, helper);  
        }
    },
    
    /* SortDefault : function(component, event, helper) {
        component.set("v.Sorting",null);
        component.set("v.NameDownBtn",true);
        component.set("v.CrDateDownBtn",false); 
        component.set("v.StatusDownBtn",true);
        
        var filterData = component.find("radioGrp").get("v.value");
        if(filterData == 'All'){
            helper.getreferrals(component, event, helper);
        }
        else{
            helper.FilterDataWithStage(component, event, helper);  
        }
    },  */
    
    ExportReport : function(component, event, helper){
        helper.Export(component, event, helper);
    },
    
    onChangeSearch : function(component, event, helper){
        var searchvalue = component.find("enter-search").get("v.value");
        component.set('v.searchKeyword', searchvalue);
        var filterData = component.find("radioGrp").get("v.value");
        if(filterData == 'All'){
            helper.getreferrals(component, event, helper);
        }
        else{
            helper.FilterDataWithStage(component, event, helper);  
        }
    },
    
    updateRowswithStage : function(component, event, helper){
        helper.FilterDataWithStage(component, event, helper);
        var filterData = component.find("radioGrp").get("v.value");
        if(filterData == 'All'){
            helper.ShowBoxValues(component, event, helper);   
        }
    },
    
    onPerPageChange : function(component, event, helper){  
        var pageSize = component.find("pageSize").get("v.value");
        component.set("v.pageSize", pageSize);
        component.set("v.startPage", 0);
        component.set("v.endPage", pageSize-1);
        var startPage = component.get("v.startPage");
        var endPage = component.get("v.endPage");
        helper.setData(component, event, startPage, endPage, 1);
        component.set("v.totalpages", Math.ceil(component.get("v.totalRecords")/ pageSize));
    },
    
    handlePrev : function(component, event, helper) {        
        var start = component.get("v.startPage");
        var end = component.get("v.endPage");
        var pageSize = component.get("v.pageSize");
        var startPage = start-pageSize;
        var endPage = end-pageSize;
        var pageNumber = Math.ceil(endPage/pageSize);
        helper.setData(component, event, startPage, endPage, pageNumber);
    },
    
    handleNext : function(component, event, helper) {
        var endPage = component.get("v.endPage");        
        var pageSize = component.get("v.pageSize");        
        var start = endPage + 1;
        var end = endPage + parseInt(pageSize);
        var pageNumber = Math.ceil(end/pageSize);
        var dataList = component.get("v.dataList");
        
        helper.setData(component, event, start, end, pageNumber);   
    },
    
    handleTotalPagesChanged: function(component, event, helper) {
        
        let totalPages = component.get("v.totalpages") || 0;
        var opts = [];
        for (let i = 1; i <= totalPages; i++) {
            opts.push({
                label : i,
                value : i 
            });
        }
        component.find("pageNumber").set("v.options", opts);
    },
    
    onPageNumberChange : function(component, event, helper){
        var pageNumber = component.find("pageNumber").get("v.value");
        var pageSize = component.get("v.pageSize");
        var startPage = pageSize * (pageNumber-1);
        var endPage = (pageSize * pageNumber)-1;        
        helper.setData(component, event, startPage, endPage, pageNumber);
        
    },
    
})