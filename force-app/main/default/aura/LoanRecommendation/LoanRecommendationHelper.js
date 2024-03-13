({
    getQuotes : function(component, event) {
        var action = component.get("c.getQuotaions");
        var spinner = component.find("inItSpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        var self = this;
        console.log('----------'+component.get("v.masterQuote"));
        action.setParams({
            leadId : component.get("v.recordId"),
            masterQuote : component.get("v.masterQuote")
        });
        action.setCallback(this, function(response) {            
            var state = response.getState();
            console.log("state"+state);
            if(state === "SUCCESS") {
                var ret = response.getReturnValue(); 
                console.log("ret+++"+JSON.stringify(ret));
                
                if(ret.length == 3){                
                    if(ret[0].quote.Product__r.Product_Order__c == null){
                        ret[0].quote.Product__r.Product_Order__c = 10;
                    }
                    if(ret[1].quote.Product__r.Product_Order__c == null){
                        ret[1].quote.Product__r.Product_Order__c = 10;
                    }
                    if(ret[2].quote.Product__r.Product_Order__c == null){
                        ret[2].quote.Product__r.Product_Order__c = 10;
                    }
                }
                else if(ret.length == 2){
                    if(ret[0].quote.Product__r.Product_Order__c == null){
                        ret[0].quote.Product__r.Product_Order__c = 10;
                    }
                    if(ret[1].quote.Product__r.Product_Order__c == null){
                        ret[1].quote.Product__r.Product_Order__c = 10;
                    }
                }
                    else if(ret.length == 1){
                        if(ret[0].quote.Product__r.Product_Order__c == null){
                            ret[0].quote.Product__r.Product_Order__c = 10;
                        } 
                    }
                
                var mainArr = [];
                if(ret.length == 3){
                    if(ret[0].quote.Product__r.Product_Order__c <= ret[1].quote.Product__r.Product_Order__c && ret[0].quote.Product__r.Product_Order__c <= ret[2].quote.Product__r.Product_Order__c){
                        console.log("1st"+JSON.stringify(ret[0].quote.Product__r));
                        mainArr[1] = ret[0];
                        delete ret[0];
                        if(ret[1].quote.Product__r.Product_Order__c < ret[2].quote.Product__r.Product_Order__c){
                            mainArr[0] = ret[1];
                            mainArr[2] = ret[2];
                        }
                        else if(ret[2].quote.Product__r.Product_Order__c < ret[1].quote.Product__r.Product_Order__c){
                            mainArr[0] = ret[2];
                            mainArr[2] = ret[1];
                        }
                        else{
                            mainArr[0] = ret[1];
                            mainArr[2] = ret[2];
                        }
                    }
                    else if(ret[1].quote.Product__r.Product_Order__c <= ret[0].quote.Product__r.Product_Order__c && ret[1].quote.Product__r.Product_Order__c <= ret[2].quote.Product__r.Product_Order__c){
                        console.log("2nd"+ret[1].quote.Product__r.Product_Order__c);
                        mainArr[1] = ret[1];
                        delete ret[1];
                        if(ret[0].quote.Product__r.Product_Order__c < ret[2].quote.Product__r.Product_Order__c){
                            mainArr[0] = ret[0];
                            mainArr[2] = ret[2];
                        }
                        else if(ret[2].quote.Product__r.Product_Order__c < ret[0].quote.Product__r.Product_Order__c){
                            mainArr[0] = ret[2];
                            mainArr[2] = ret[0];
                        }
                        else{
                            mainArr[0] = ret[0];
                            mainArr[2] = ret[2];
                        }
                    }
                    else if(ret[2].quote.Product__r.Product_Order__c <= ret[0].quote.Product__r.Product_Order__c && ret[2].quote.Product__r.Product_Order__c <= ret[1].quote.Product__r.Product_Order__c){
                         console.log("3rd"+ret[2].quote.Product__r.Product_Order__c);
                         mainArr[1] = ret[2];
                         delete ret[2];
                         if(ret[1].quote.Product__r.Product_Order__c < ret[0].quote.Product__r.Product_Order__c){
                                mainArr[0] = ret[1];
                                mainArr[2] = ret[0];
                          }
                          else if(ret[0].quote.Product__r.Product_Order__c < ret[1].quote.Product__r.Product_Order__c){
                                mainArr[0] = ret[0];
                                mainArr[2] = ret[1];
                          }
                          else{
                               mainArr[0] = ret[0];
                               mainArr[2] = ret[1];
                          }
                     }
                }
                else if(ret.length == 2){
                    if(ret[0].quote.Product__r.Product_Order__c <= ret[1].quote.Product__r.Product_Order__c){
                        mainArr[1] = ret[0];
                        mainArr[0] = ret[1];
                    }
                    else if(ret[1].quote.Product__r.Product_Order__c <= ret[0].quote.Product__r.Product_Order__c){
                        mainArr[1] = ret[1];
                        mainArr[0] = ret[0];
                    }
                    else{
                            mainArr[1] = ret[0];
                            mainArr[0] = ret[1];
                    }
                }
                else if(ret.length == 1){
                     mainArr[0] = ret[0];
                }                
                
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    console.log('--ret==-='+JSON.stringify(ret));
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                }else{
                    component.set('v.quotesWpr', mainArr);                    
                    component.set('v.customerAmount', mainArr[0].quote.Customer_Amount__c);                    
                    //component.set('v.purpose', mainArr[0].quote.Purpose__c);
                    component.set('v.purpose', mainArr[0].quote.Product_Type_Lookup__r.Name);// Added by Sethu
                }
            }
            $A.util.addClass(spinner, 'slds-hide');
            self.scrollTop(component, event, 465);
        });
        $A.enqueueAction(action);
    },
    
    getLead : function(component, event) {
        
        var action = component.get("c.getLead");
        var self = this;
        action.setParams({
            leadId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                }else{
                    component.set('v.applicantFName', ret.FirstName);
                    component.set('v.applicantLName', ret.LastName);
                    component.set('v.applicantEmail', ret.Email);
                }
            }
            
            self.scrollTop(component, event, 465);
            
        });
        $A.enqueueAction(action);
    },
    
    updateQuotes : function(component, event, quotes, selectedId) {
        var action = component.get("c.UpdateQuote");
        var self = this;
        
        action.setParams({
            quotesList: quotes,
            selectedQuoteId: selectedId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();   
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                }else{
                    component.set('v.applicationSection', JSON.parse(ret).CurrentSection);
                    component.set('v.appSectionPath', JSON.parse(ret).path);
                }
            }
            self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
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