({
	doInit : function(component, event, helper) {
        helper.showSpinnerForThreeSeconds(component, event, helper);
        var oldFundingRequests =  component.get("v.PreviousData");
        if(oldFundingRequests != null){
            for(var i=0;i<oldFundingRequests.length;i++){
                component.set("v.frRequest",oldFundingRequests[i]);
                if(oldFundingRequests[i].Request_Status__c != 'Payment funded' && !oldFundingRequests[i].Funding_On_Hold__c){ 
                    component.set("v.request",true);
                }
                else{
                    component.set("v.request",false);
                }
                break;
            }
        }
        
        //Showing application Fee.
        var loanfee = component.get("v.loanFeesList");
        if(loanfee != null){
            var applicationFee = 0;
            var lender_memFee = 0;
            for(var i=0;i<loanfee.length;i++){
                if(loanfee[i].Fee_Type__c == 'Application'){
                    applicationFee += loanfee[i].Amount__c; 
                }
                if(loanfee[i].Fee_Type__c == 'Refundable Lender Membership Fee'){
                    lender_memFee += loanfee[i].Amount__c; 
                }
            }
            component.set("v.memberShipFee",lender_memFee);
            component.set("v.applicationFees",applicationFee);
        }
    },
    
    fieldCheck : function(component, event, helper) {
        var amt_funded_val = component.get("v.amount_funded");
        var paid_to_val = component.get("v.paidTo");
        if(amt_funded_val != '' && paid_to_val != null){
            component.set("v.isSubmitBtnDisabled",false); 
        }
        else{
            component.set("v.isSubmitBtnDisabled",true); 
        }
    },
    
    submitRequest : function(component, event, helper) {
        var spinner = component.find("mySpinner2");
        $A.util.removeClass(spinner, 'slds-hide');
        component.set("v.spinner2",true);
        
        var funding_reqId = component.get("v.frRequest.Id");
        var amt_funded_val = component.get("v.amount_funded");
        var paid_to_val = component.get("v.paidTo");
        var agent_id = component.get("v.accountId");
        var action = component.get("c.updateFundingByLender");
        action.setParams({
            frId : funding_reqId,
            amtFunded : amt_funded_val,
            paidTo : paid_to_val,
            lender_conId : agent_id 
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var ret = response.getReturnValue();
                if(ret != null){
                  component.set("v.frRequest",ret.frq); 
                  component.set("v.opp",ret.opp);
                  component.set("v.request",false);
                    helper.getPreviousFundingRequests(component, event, helper);  
                    var frqReqType = component.get("v.frRequest.Request_Type__c");
                    var oppStage = component.get("v.opp.StageName");
                    if(frqReqType== 'Part payment before installation'){
                        component.set("v.status",'Part Funded');
                        component.set("v.statusCode",'#D063D3');
                    }
                    else if(oppStage == 'Settled (closed won)'){
                        component.set("v.status",'Funded');
                        component.set("v.statusCode",'#4A154B');
                    }
                    var callInitEvent = component.getEvent("callInitEvent");
                    // Fire the event to call the init function in the parent component
                    callInitEvent.fire();
                }
            }
            component.set("v.spinner2",false);
            $A.util.addClass(spinner, 'slds-hide');
        });
        $A.enqueueAction(action);
    },
})