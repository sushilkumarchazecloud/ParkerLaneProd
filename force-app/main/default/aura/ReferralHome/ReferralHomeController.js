({
    doInit : function(component, event, helper) {        
        helper.newQtList(component, event);
    },
    
    saveReferral : function(component, event, helper) {        
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing && inputCmp.checkValidity();
        }, true);        
        //component.set("v.showMessage",!(allValid));
        if(allValid){
            var fName = component.get("v.firstName");
            fName = fName.charAt(0).toUpperCase() + fName.slice(1);
            component.set("v.firstName",fName);
            var lName = component.get("v.lastName");            
            lName = lName.charAt(0).toUpperCase() + lName.slice(1);
            component.set("v.lastName",lName);
            var action = component.get("c.submitReferral");
            helper.toggleSpinner(component, event);
            var self = this;
            var testJson = JSON.stringify(component.get('v.quoteDetailWrpList'));
            action.setParams({
                refEmail: component.get('v.referrerEmail'),
                firstName: component.get('v.firstName'),
                lastName: component.get('v.lastName'),
                custEmail: component.get('v.custEmail'), 
                custPhone: component.get('v.custPhone'),
                custAdd: component.get('v.custInstallationAddress'), 
                quoteType: component.get('v.quoteType'),
                sendQuote: component.get('v.sendQuote'), 
                contactId: component.get("v.accountId"),
                isObtainedTheCustomer: component.get('v.isObtainedTheCustomer'),
                quoteDetailWrpList1 : testJson,
                street: component.get('v.street'),
                postalCode: component.get('v.postalCode'),
                suburb: component.get('v.suburb'),
                country: component.get('v.country'),
                state: component.get('v.state'),
                streetNumber: component.get('v.streetNumber'),
                streetType: component.get('v.streetType')
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var ret = response.getReturnValue();
                
                if (ret.errorMessage != null && ret.errorMessage.includes("At least")) {
                    console.log(ret);
                    //component.set('v.showMessage', true);
                    component.set('v.status', 'error');
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
                    helper.toggleSpinner(component, event);
                    //helper.scrollTop(component, event, 10);                    
                }else if (ret.errorMessage != null && ret.errorMessage.includes("Oops")) {
                    component.set('v.ret', false);
                    var spTxt = ret.errorMessage.replace('Oops!','');
                    component.set("v.ret",true);
                    component.set("v.status",'Oops!');
                    component.set('v.message', spTxt);
                    helper.toggleSpinner(component, event);
                }
                else if(ret.errorMessage != null && ret.errorMessage.includes("Success")){
                    component.set('v.ret', false);
                    var spTxt = ret.errorMessage.replace('Success!','');
                    component.set("v.status",'Success!');
                    component.set('v.message', spTxt);
                    component.set('v.referrerEmail','');
                    component.set('v.firstName','');
                    component.set('v.lastName','');
                    component.set('v.custPhone','');
                    component.set('v.custEmail','');
                    component.set('v.custInstallationAddress','');
                    component.set('v.quoteType','');
                    component.set('v.sendQuote','');
                    component.set('v.isObtainedTheCustomer',false);
                    component.set("v.showBtn",true);
                    component.set("v.quoteDetailWrpList",'');
                    helper.newQtList(component, event);
                    helper.generateAndSendPDF(component, event, ret.pdfData);
                    helper.toggleSpinner(component, event);                        
                }
                else if(ret.errorMessage == null){
                    helper.toggleSpinner(component, event);
                }
            });
            $A.enqueueAction(action);
        }        
        else{
            //component.set('v.showMessage', true);
            component.set('v.status', 'error');
            component.set('v.message', 'Error: Please update the form entries highlighted in red and try again.');            
        }        
    },
    
    handleChange : function(component, event, helper) {
        if(event.which == 13 ){
            var a = component.get("c.getReferrer");
            $A.enqueueAction(a);
        }
    },
    
    handleDisable : function(component, event, helper) {
        var mail = component.get("v.referrerEmail");
        var emailInputCmp = component.get('v.referrerEmail');
        var email = emailInputCmp.trim();
        component.set("v.referrerEmail",email);
        if(mail.length > 0){
            component.set("v.isNotNull", false);            
        }
        else{
            component.set("v.isNotNull", true);
        }
    },
    
    checkEmail : function(component, event, helper) {
        var emailInputCmp = component.get('v.custEmail');
        var email = emailInputCmp.trim();
        component.set("v.custEmail",email);
    },
    
    submitable : function(component, event, helper) {
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            return !inputCmp.get('v.validity').valueMissing && validSoFar;
        }, true);      
        //component.set("v.isObtainedTheCustomer",(event.getSource().get('v.checked')));
        var selectedValue = event.getParam("value");
        if(selectedValue != null){
            component.set("v.ret",true);
            component.set("v.status",'');
            component.set('v.message','');
        }
        if(allValid){
            component.set("v.submitcheck", false);
        }
        else{
            component.set("v.submitcheck", true);
        }
    },
    
    getReferrer : function(component, event, helper) {        
        var action = component.get("c.getEmail");
        helper.toggleSpinner(component, event);
        var mail = component.get("v.referrerEmail");        
        var self = this;
        
        action.setParams({
            referrerEmail : mail
        });
        
        action.setCallback(this,function(response){
            var records = response.getReturnValue();
            if(records){
                helper.toggleSpinner(component, event);
                component.set("v.accountId",records);
                component.set("v.showCustomer",false);
                component.set("v.showDetails",true);
                component.set('v.showMessage', false);
                component.set('v.showBtn',false);
                component.set('v.status', '');
                component.set('v.message', '');
            }   
            else{
                helper.toggleSpinner(component, event);
                component.set("v.showCustomer",true);
                component.set("v.showDetails",false);
                component.set('v.showMessage', true);
                component.set('v.status', 'error');
                component.set('v.message', 'Error: Your email is not registered as an authorised referrer. Please check your details or call 1300 13 17 11 to become accredited.');  
            }
            helper.scrollTop(component, event, 10);
            
        }); 
        $A.enqueueAction(action);
    },
    
    submit : function(component, event, helper) {
        var self = this;
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        if(allValid){
            component.set('v.showMessage', false);
            helper.toggleSpinner(component, event);
            helper.saveReferral(component, event);
        }else{
            component.set('v.showMessage', true);
            component.set('v.status', 'error');
            component.set('v.message', 'Error: Please update the form entries highlighted in red and try again.');            
        }
        helper.scrollTop(component, event, 50);
    },
    addProperty : function(component, event, helper) {
        console.log('....'+JSON.stringify(component.get('v.quoteDetailWrpList')));
        var tep = component.get('v.quoteDetailWrpList');
        var action = component.get("c.ret1");
        
        action.setCallback(this,function(response){
            var records = response.getReturnValue();
           
            tep.push(records);
            component.set('v.quoteDetailWrpList', tep);
            console.log(JSON.stringify(tep));
            component.get('v.quoteDetailWrpList');            
        }); 
        $A.enqueueAction(action);
    },
    
    deleteProperty : function(component, event, helper){
        var index = event.getSource().get('v.name');
        var lst = component.get('v.quoteDetailWrpList');
        lst.splice(index, 1);
        component.set('v.quoteDetailWrpList', lst);
    }
})