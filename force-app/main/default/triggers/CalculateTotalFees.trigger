Trigger CalculateTotalFees on Loan_Fees__c (after insert, after update, before delete, after delete, after undelete) {
    Set<Id> productIds = New Set<Id>();
    Set<Id> quoteIds = New Set<Id>();
    Set<Id> deletedIds = New Set<Id>();
    Map<String, Decimal> freqMap = New Map<String, Decimal>{
        'Monthly' => 1,
        'Weekly'=> (52.0/12.0),
        'Fortnightly'=> 26.0/12.0,
        'Annual'=> 1/12.0
    };
    List<Product2> productList = New List<Product2>();
    List<Quote> quoteList = New List<Quote>();
    if (Trigger.isBefore) {
        if(Trigger.isDelete) {
            for (Loan_Fees__c fee : Trigger.old) {
                if (String.isNotBlank(fee.Product__c)) {
                    productIds.add(fee.Product__c);
                }
                
                if (String.isNotBlank(fee.Quote__c)) {
                    productIds.add(fee.Quote__c);
                } 
                deletedIds.add(fee.Id);
            }
        }
    } else if(!Trigger.isDelete){
        for (Loan_Fees__c fee : Trigger.new) {
            if (String.isNotBlank(fee.Product__c)) {
                productIds.add(fee.Product__c);
            }else if (String.isNotBlank(fee.Quote__c)) {
                quoteIds.add(fee.Quote__c);
            } 
        
        }
    }  
    
    for(Product2 pro : [SELECT Id, Total_Fees__c, (SELECT Id, Amount__c FROM Loan_Fees__r WHERE NOT(Id IN :deletedIds)) FROM Product2 WHERE Id in: productIds]){
        Decimal totalFees = 0;
        for(Loan_Fees__c fee : pro.Loan_Fees__r){
            totalFees += fee.Amount__c;
        }
        pro.Total_Fees__c = totalFees;
        productList.add(pro);
    }
    if(!productList.isEmpty()){update productList;}
    
    
    for(Quote qt : [SELECT Id, Opportunity.SyncedQuoteId, Total_Fees__c, Monthly_Account_Keeping_Fees__c, Loan_Term__c,
                    (SELECT Id, Amount__c, Fee_Type__c, Frequency__c FROM Loan_Fees__r WHERE NOT(Id IN :deletedIds)) 
                    FROM Quote WHERE Id in: quoteIds]){
        Decimal totalFees = 0;
        Decimal totalAccKeepingFees = 0;

        for(Loan_Fees__c fee : qt.Loan_Fees__r){
            if(('Account Keeping').equalsIgnoreCase(fee.Fee_Type__c)){
                totalAccKeepingFees += fee.Amount__c * (freqMap.containsKey(fee.Frequency__c) ? freqMap.get(fee.Frequency__c) : 0);
            }else{
                totalFees += fee.Amount__c;
            }            
        }
        qt.Monthly_Account_Keeping_Fees__c = totalAccKeepingFees.setScale(2);
        qt.Up_Front_Fees__c = totalFees.setScale(2);
        qt.Total_Fees__c = (totalFees + (qt.Loan_Term__c * totalAccKeepingFees)).setScale(2);
        quoteList.add(qt);
    }

    update quoteList;
}