({
	doInit: function(component, event, helper) {
         jQuery("document").ready(function(){
             console.log('jQuery Uploaded');
         });
        helper.toggleSpinner(component, event);
        console.log('toggle');
        var mgRef = component.get('v.mgRef');
        if(mgRef != null && mgRef.length > 0){
            helper.getOppId(component);
        }else{
        	helper.getContact(component);    
        }
        console.log('contact');
        helper.scrollTop(component, event, 0);
        window.setTimeout(
            $A.getCallback(function() {
                var items = component.get("v.OrignalRecord");
                var activeSections = [];
                for(var item in items){
                    activeSections.push(items[item].label);    
                }
                component.set("v.activeSections", activeSections);
            }), 3000
        );
        
    },
    handleBankAccount : function(cmp, event, helper) {
        helper.toggleSpinner(cmp, event);
        helper.scrollTop(cmp, event, 0);
        var action = cmp.get('c.getBankStmtUrl');
        action.setParams({
            oppId : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS"){
                console.log(response.getReturnValue());
                window.open(response.getReturnValue());
            }else{
                console.log(response.getError());
                window.open($A.get("$Label.c.Bank_Statement_URL"));
            }
            helper.toggleSpinner(cmp, event);
        });
        $A.enqueueAction(action);
    },
    saveAndfinish : function(cmp, event, helper){
        var result = cmp.get("v.OrignalRecord");
        console.log(result);
        var count = 0;
        var toCompleatList = [];
        helper.toggleSpinner(cmp, event);
        helper.scrollTop(cmp, event, 0);
        for(var index in result){
            var value = result[index].value;
            console.log(value);
            for(var y in value){
                value[y].isOpen = false;
                if( (!value[y].isComplete) && (value[y].count > 0 || value[y].isAlready_provided ||value[y].isNotApplicable) ){
                    toCompleatList.push(value[y]);
                }else
                    if(!value[y].isComplete)
                        ++count;
            }
        }
        console.log(count);
        console.log(toCompleatList);
        cmp.set("v.OrignalRecord",result);
        var action = cmp.get('c.sendMail');
        action.setParams({
            oppId : cmp.get("v.recordId"),
            remaining : ''+count,
            updateList: JSON.stringify(toCompleatList)
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS"){
                cmp.set("v.finished",true);
                helper.toggleSpinner(cmp, event);
                window.open('/?Id='+cmp.get("v.recordId"),'_top');
            }
        });
        $A.enqueueAction(action);
    },
    
    
})