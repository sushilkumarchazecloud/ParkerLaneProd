({
    doInit : function(component, event, helper) {
        helper.newQtList(component,event);
        var cnt = component.get("v.quotesize");
        if(cnt == 4){
            component.set("v.submitDisable",true);
            component.set("v.maxQuote",true);
        }
        else{
            cnt = cnt+1;
            component.set("v.quotesize",cnt);
        }
    },
    
    submit : function(component, event, helper) {
        var spinner = component.find("mySpinner2");
        $A.util.removeClass(spinner, 'slds-hide');
        component.set("v.spinner2",true);
        
        var self = this;
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        
        var arr = component.get("v.quoteList");
        var qtList = component.get('v.quoteDetailWrpList');
        var flag=[];
        for(var i=0; i<arr.length; i++){
            if(arr[i].GroupLabel != undefined || arr[i].GroupLabel != null){
                if(arr[i].GroupLabel.startsWith("Referral")){
                    flag.push(arr[i]);
                }
            }
        }
        for(var i=0; i<arr.length; i++){
            var temp;
            var qtName= 'Referral-';
            var count = 1;
            var count2 = 1;
            console.log("grpLb"+arr[i].GroupLabel);
            for(var j=0; j<qtList.length; j++){
                if(qtList[j].masterQuote == null || qtList[j].masterQuote == ''){
                    if(flag.length > 0){
                        var num = 0;
                        num = flag.length+count;
                        qtList[j].masterQuote = qtName+num;
                        count = count+1;
                    }
                    else{
                        qtList[j].masterQuote = qtName+count2;
                        count2 = count2+1;
                    }
                }                 
                if(arr[i].GroupLabel == qtList[j].masterQuote){
                    console.log("mastQt----"+qtList[j].masterQuote);
                    temp = true; 
                    qtList[j].nameError = true;
                    component.set("v.quoteDetailWrpList",qtList);
                    break;
                }
                if(arr[i].GroupLabel != qtList[j].masterQuote){
                    temp = false;
                }
            }
            if(temp){
                break;
            }
        }
        
        if(!temp && allValid){            
            component.set('v.showMessage', false);
            var action = component.get("c.newQuotes");
            var testJson = JSON.stringify(component.get('v.quoteDetailWrpList'));
            action.setParams({
                quoteType : component.get("v.quoteType"),
                leadId : component.get("v.leadId"),
                oppId : component.get("v.oppId"), 
                quoteDetailWrpList1 : testJson
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var ret = response.getReturnValue();
                if (ret.errorMessage != null && ret.errorMessage.includes("At least")) {
                    console.log(ret);
                    component.set('v.ret', true);
                    component.set('v.status', 'error!');
                    component.set('v.message', ret.errorMessage);
                    var arr = component.get('v.quoteDetailWrpList');
                    for(var i=0; i<arr.length; i++){
                        var fieldcheckAmt;
                        if(arr[i].Amount > ret.maxAmt || arr[i].Amount < ret.minAmt) {
                            arr[i].checkError = true;                 
                        }
                        else if(ret.maxAmt == null && ret.minAmt == null){
                            arr[i].checkError = true;                        
                        }
                            else if(arr[i].Amount < ret.maxAmt || arr[i].Amount > ret.minAmt) {
                                arr[i].checkError = false;
                            }
                    }
                    component.set("v.quoteDetailWrpList",arr);
                    component.set("v.spinner2",false);
                    $A.util.addClass(spinner, 'slds-hide');
                }else if (ret.errorMessage != null && ret.errorMessage.includes("Success")) {
                    component.set('v.ret', false);
                    var spTxt = ret.errorMessage.replace('Success!','');
                    //component.set("v.status",'Success!');
                    //component.set('v.message', spTxt);
                    component.set("v.sendQuote",'');
                    component.set('v.isObtainedTheCustomer',false);                    
                    helper.newQtList(component,event);
                    helper.groupQuotes(component,event);
                } 
            });
            $A.enqueueAction(action);
        }/*else{
            component.set('v.ret', true);
            component.set('v.status', 'Oops!');
            component.set('v.message', 'You already have a quote under this name');            
        }*/
        helper.scrollTop(component, event, 50);
    },
    
    submitable : function(component, event, helper) {
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            return !inputCmp.get('v.validity').valueMissing && validSoFar;
        }, true);      
        var selectedValue = event.getParam("value");
        
        if(selectedValue != null){
            component.set("v.ret",true);
            component.set("v.status",'');
            component.set('v.message','');
        }
        if(allValid){
            component.set("v.submitDisable", false);
        }
        else{
            component.set("v.submitDisable", true);
        }
    },
    
    addProperty : function(component, event, helper) {
        var spinner = component.find("mySpinner2");
        $A.util.removeClass(spinner, 'slds-hide');
        component.set("v.spinner2",true);
        console.log('....'+JSON.stringify(component.get('v.quoteDetailWrpList')));
        var tep = component.get('v.quoteDetailWrpList');
        var action = component.get("c.ret1");
        
        action.setCallback(this,function(response){
            var records = response.getReturnValue();
           
            tep.push(records);
            component.set('v.quoteDetailWrpList', tep);
            var cnt = component.get("v.quotesize");
            cnt = cnt+1;
            component.set("v.quotesize",cnt);
            console.log(JSON.stringify(tep));
            component.get('v.quoteDetailWrpList');
            component.set("v.spinner2",false);
            $A.util.addClass(spinner, 'slds-hide');            
        }); 
        $A.enqueueAction(action);
    },
    
    deleteProperty : function(component, event, helper){
        var index = event.getSource().get('v.name');
        var lst = component.get('v.quoteDetailWrpList');
        lst.splice(index, 1);
        var cnt = component.get("v.quotesize");
        cnt = cnt-1;
        component.set("v.quotesize",cnt);
        component.set('v.quoteDetailWrpList', lst);
    }
})