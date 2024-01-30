({
    doInit : function(component, event, helper){ 
        component.set("v.StopBoxNmbers",true);
        helper.getContactsHelper(component, event, helper); 
    },
    
    addContact : function(component, event, helper) {
        helper.addMore(component, event);
        component.set("v.addContactModal",true);
    },
    
    closeModal : function(component, event, helper) {
        component.set("v.addContactModal",false);
        component.set("v.showError",false);
        component.set("v.isSaveBtnDisabled",true);
        component.set("v.conList",[]);
    },

    handleChange : function(component, event, helper){
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            return !inputCmp.get('v.validity').valueMissing && validSoFar;
        }, true);
        if(allValid){
            component.set("v.isSaveBtnDisabled",false);
        }
        else{
            component.set("v.isSaveBtnDisabled",true);
        }

    },
    
    SaveContact : function(component, event, helper) {
        var conList = component.get("v.conList");
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing && inputCmp.checkValidity();
        }, true);
        component.set("v.showError",!(allValid));
        if(allValid){
            if(conList.length>0){
                var action = component.get("c.createContact");
                action.setParams({contactlist:conList,
                                  conId:component.get("v.accountId")});
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if(state == "SUCCESS"){                        
                        component.set("v.conList",[]);
                        helper.addMore(component, event);
                        component.set("v.isSaveBtnDisabled",true);
                        component.set("v.StopBoxNmbers",true);
                        helper.getContactsHelper(component, event, helper);
                    }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
                            }
                        } 
                    } 
                });
                $A.enqueueAction(action);
            }
            
        }
        else{
            component.set("v.errorMsg","Please update the form entries highlighted in red and try again");
        }
        
        //component.set("v.addContactModal",false);
    },
    
    addMore : function(component, event, helper) {
        helper.addMore(component, event);
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
        /*if(end>=dataList.length){
            end = dataList.length-1;
        }*/
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
    
    onChangeSearch : function(component, event, helper){
        var searchvalue = component.find("enter-search").get("v.value");
        component.set('v.searchKeyword', searchvalue);
        component.set("v.StopBoxNmbers",false);
        helper.getContactsHelper(component, event, helper); 
        
    },
    
    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
    
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    },
    
    SortByLastName : function(component,event,helper){
        var str = 'LastName ASC';
        component.set("v.Sorting",str);
        component.set("v.LastNameDwnBtn",false);
        component.set("v.FirstNameDwnBtn",true);
        component.set("v.StatusDwnBtn",true);    
      helper.getContactsHelper(component, event, helper);   
    },
    
    SortByLNameDESC : function(component,event,helper){
        var str = 'LastName DESC';
        component.set("v.Sorting",str);
        component.set("v.LastNameDwnBtn",false);
        component.set("v.FirstNameDwnBtn",true);
        component.set("v.StatusDwnBtn",true);    
        helper.getContactsHelper(component, event, helper);   
    },
    
    SortByFirstName : function(component,event,helper){
         var str = 'FirstName ASC';
        component.set("v.Sorting",str);
        component.set("v.LastNameDwnBtn",true);
        component.set("v.FirstNameDwnBtn",false);
        component.set("v.StatusDwnBtn",true); 
        helper.getContactsHelper(component, event, helper); 
    },
    
    SortByFirstNameDESC : function(component,event,helper){
         var str = 'FirstName DESC';
        component.set("v.Sorting",str);
        component.set("v.LastNameDwnBtn",true);
        component.set("v.FirstNameDwnBtn",false);
        component.set("v.StatusDwnBtn",true); 
        helper.getContactsHelper(component, event, helper); 
    },
    
    SortByStatus : function(component,event,helper){
        var str = 'Status__c ASC';
        component.set("v.Sorting",str);
        component.set("v.LastNameDwnBtn",true);
        component.set("v.FirstNameDwnBtn",true);
        component.set("v.StatusDwnBtn",false);
        helper.getContactsHelper(component, event, helper); 
    },
    
    SortByStatusDESC : function(component,event,helper){
        var str = 'Status__c DESC';
        component.set("v.Sorting",str);
        component.set("v.LastNameDwnBtn",true);
        component.set("v.FirstNameDwnBtn",true);
        component.set("v.StatusDwnBtn",false);
        helper.getContactsHelper(component, event, helper); 
    },
    
   /*  SortDefault : function(component,event,helper){
        component.set("v.Sorting",null);
        component.set("v.LastNameDwnBtn",true);
        component.set("v.FirstNameDwnBtn",true);
        component.set("v.StatusDwnBtn",true);       
        helper.getContactsHelper(component, event, helper); 
    }, */
})