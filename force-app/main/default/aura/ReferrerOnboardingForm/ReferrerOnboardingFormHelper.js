({
    saveAndNextRecords: function (component, event) {
        var acc = component.get("v.acc");
        var con = component.get("v.con");
        var action = component.get("c.saveReferrer");
        var self = this;
        action.setParams({
            acc: acc,
            con: con
        });
        self.toggleSpinner(component, event);
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('@@@@state----------' + state);
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    component.set("v.errorMsg", "Please update the form entries highlighted in red and try again");
                }else{
                    console.log('@@@@@' + JSON.stringify(ret));
                    
                    component.set("v.conList", []);
                    component.set("v.con",ret.Contacts[0]);
                    component.set("v.acc",ret);
                    var conList = component.get("v.conList");
                    var con = component.get("v.con");
                    conList.push(con);
                    self.createEnvelope(component, event);
                    component.set("v.conList", conList);
                    component.set("v.pageNo", 2);
                }
            }else if (state === "ERROR"){
                component.set("v.showError", true);
                component.set("v.errorMsg", "Something went wrong please contact to Administrator");
            }
            self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
    },
  
    submitRecords: function (component, event, isRedirect) {
        var acc = component.get("v.acc");
        var conList = component.get("v.conList");
        var action = component.get("c.submitReferrer");
        var methodCall = component.get("v.NextCall");
        var self = this;
        action.setParams({
            acc: acc,
            conList: conList,
            isNext : methodCall
        });
        self.toggleSpinner(component, event);
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('@@@@state----------' + state);
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    component.set("v.errorMsg", "Please update the form entries highlighted in red and try again");
                }else{
                    var pgNo = component.get("v.pageNo");
                    component.set("v.conList", ret.Contacts);
                    //component.set("v.con",{'sobjectType': 'Contact'});
                    component.set("v.acc",ret);
                    //component.set("v.businessAddress", "");*/
                    component.set("v.pageNo", pgNo + 1);
                    console.log('@@@@@' + JSON.stringify(ret));
                    if(isRedirect){
                        window.location = "https://www.parkerlane.com.au/affiliates";
                    }
                }
            }else if (state === "ERROR"){
                component.set("v.showError", true);
                component.set("v.errorMsg", "Something went wrong please contact to Administrator");
            }
            self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
    },
    
    createEnvelope: function (component, event) {
        var acc = component.get("v.acc");
        var self = this;
        var action = component.get("c.createEnvelope");
        action.setParams({
            accId: acc.Id
        });
        self.toggleSpinner(component, event);
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('@@@@state----------' + state);
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                console.log('@@@@@' + JSON.stringify(ret));
            }else if (state === "ERROR"){
                component.set("v.showError", true);
                component.set("v.errorMsg", "Something went wrong please contact to Administrator");
            }
            self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
    },
    
    deleteRow: function(component, event, index) {
        var ids = [];
        var self = this;
        var deleteList = component.get("v.conList");
        deleteList.splice(index,1);
        component.set("v.conList", deleteList);
    },
    
    toggleSpinner: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
    
    scrollTop: function (component, event, top){
        var scrollOptions = {
            left: 0,
            top: top,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    },
})