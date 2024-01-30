({
    doInit : function(cmp, event, helper) {
        helper.fetchProductType(cmp,event);
        helper.fetchOppStage(cmp,event);
    },
    SearchProduct: function (cmp, evt, helper) {
        cmp.set("v.issearching", true);
        //alert(cmp.find('select').get('v.value'));
        //alert(cmp.get('v.Type'));
        //cmp.set("v.issearching", false);
        var action = cmp.get('c.getProduct');
        action.setParams({
            prdtype : cmp.get("v.Type"),
            amount : cmp.get("v.amount")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var product = [];
                var dataList = new Map();
                var result = response.getReturnValue();
                console.log(result);
                for(var i in result[0])
                    console.log(i); 
                
                for(var i in result){
                    console.log('brokerage = '+result[i].Brokerage_Amount__c);
                    product.push({
                        chk : false,
                        Id : result[i].Id,
                        Lender: result[i].Lender__c,
                        IntRate : result[i].Interest_Rate__c,
                        MaxTerm: result[i].Max_Loan_Term__c,
                        MinTerm : result[i].Min_Loan_Term__c,
                        LoanAmounts:result[i].Loan_Amounts__c,
                        ProductName :result[i].Name,
                        LoanAmount : cmp.get("v.amount"),
                        LoanTerm : result[i].Loan_Term__c != null ? result[i].Loan_Term__c : 0  ,
                        isInterestRate : result[i].Interest_Rate_Override__c,
                        InterestRate: result[i].Interest_Rate__c,
                        InterestRateType : result[i].Interest_Rate_Type__c,
                        ComparisonRate : result[i].Actual_Comparison_Rate__c,
                        Description : result[i].Description,
                        Features : result[i].Features__c,
                        InterestRateFrom : result[i].Interest_Rate_From__c,
                        BrokerageAmount : result[i].Brokerage_Amount__c,
                        BrokerageOverrideAllowed : result[i].Brokerage_Override_Allowed__c,
                        CommissionAmount : result[i].Commission_Amount__c,
                        CommissionOverrideAllowed : result[i].Commission_Override_Allowed__c,
                        fees :result[i].Loan_Fees__r,
                        feesMap : new Map(),
                        feesList : [],
                        termList : []
                    });
                    
                }
                cmp.set("v.productList",product);
                cmp.set("v.issearching", false);
                cmp.set("v.maxItem",0);
            }
        });
        
        $A.enqueueAction(action);
    },
    checkSelectedItem : function(cmp, event, helper){
        var check =  event.getSource().get("v.checked");
        var item = cmp.get("v.maxItem");
        //console.log(check);
        if(!check){
            if(item > 0)
                cmp.set("v.maxItem",--item);
        }else{
            if(item < 3){
                cmp.set("v.maxItem",++item);
            }else{
                alert('you can not select more than 3 products at a time');
                event.getSource().set("v.checked",false);
            }
        }
        //console.log(item);
        //console.log(check);
    },
    getCompare : function(cmp, event, helper){
        cmp.set("v.isCompare",false);
        var selectedProduct = [];
        var FeesSet = new Set();
        var productList = cmp.get("v.productList");
        for(var i in productList){
            if(productList[i].chk){
                productList[i].feesList = [];
                var item = productList[i].fees;
                for(var j in item){
                    if(!FeesSet.has(item[j].Fee_Type__c))
                        FeesSet.add(item[j].Fee_Type__c);
                    if(!productList[i].feesMap.has(item[j].Fee_Type__c)){
                        productList[i].feesMap.set(item[j].Fee_Type__c, item[j]);
                    }
                }
                selectedProduct.push(productList[i]);
            }
            productList[i].termList = [];
            
            for (var j = productList[i].MinTerm; j <= productList[i].MaxTerm; ) {
                productList[i].termList.push(j);
                j = j+12;
            }
        }
        console.log(FeesSet);
        var feeList = [];
        //FeesSet.forEach(i,function());
        FeesSet.forEach((value) => {
            feeList.push({Label:value});
            console.log(value);
            for(var i in selectedProduct){
                if(selectedProduct[i].feesMap.has(value)){
                    selectedProduct[i].feesList.push(selectedProduct[i].feesMap.get(value));
                }else{
                    selectedProduct[i].feesList.push(null);
                }
        	}
        });
        console.log(selectedProduct);  
        cmp.set("v.FeeList",feeList);
    	cmp.set("v.selectedProduct",selectedProduct);
    }
})