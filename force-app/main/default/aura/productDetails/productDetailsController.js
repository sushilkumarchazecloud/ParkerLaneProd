({
	backTosearch : function(cmp, event, helper) {
		cmp.set("v.isCompare",true);
	},
    createQuote : function(cmp, event, helper){
        var prod  = cmp.get("v.selectedProduct");
        var checkLoanT = true;
        for (let i = 0; i < prod.length; i++) {
            console.log('====> '+prod[i].LoanTerm);
        	if(prod[i].LoanTerm == 0){
                console.log('====> '+checkLoanT);
                checkLoanT = false;
                break;
            }
            
    	}
        if(checkLoanT){
            var action = cmp.get('c.insertQuote');
            action.setParams({
                prodList : JSON.stringify(prod),
                PType : cmp.get("v.Type"),
                groupName : cmp.get("v.QuoteName"),
                oppId : cmp.get("v.recordId")
            });		
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS"){
                    alert("Success");
                    $A.get('e.force:refreshView').fire();
                }
            });
            $A.enqueueAction(action);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": "error",
                "message": "Error! Please select Loan Terms."
            });
            toastEvent.fire();
        }
        
    }
})