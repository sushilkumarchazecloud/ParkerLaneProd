trigger AssetTrigger on FinServ__AssetsAndLiabilities__c (after insert, after update, after undelete, before delete) {
    Id assetRTId = Schema.SObjectType.FinServ__AssetsAndLiabilities__c.getRecordTypeInfosByName().get('Asset').getRecordTypeId();
    Set<Id> pcIds = new Set<Id>();
    if(!Trigger.isDelete){
        for(FinServ__AssetsAndLiabilities__c asset: Trigger.new){
            if((('Investment Property').equalsIgnoreCase(asset.FinServ__AssetsAndLiabilitiesType__c) ||
                ('Commercial Property').equalsIgnoreCase(asset.FinServ__AssetsAndLiabilitiesType__c)) && 
                asset.RecordTypeId == assetRTId ){
                pcIds.add(asset.FinServ__PrimaryOwner__c);
            }
        }
    }
    
    if(Trigger.isDelete){
        for(FinServ__AssetsAndLiabilities__c asset: Trigger.old){
            if((('Investment Property').equalsIgnoreCase(asset.FinServ__AssetsAndLiabilitiesType__c) ||
                ('Commercial Property').equalsIgnoreCase(asset.FinServ__AssetsAndLiabilitiesType__c)) && 
                asset.RecordTypeId == assetRTId ){
                pcIds.add(asset.FinServ__PrimaryOwner__c);
            }
        }
    }
    
    List<FinServ__AssetsAndLiabilities__c> assetsList = [SELECT Id, Rental_Amount__c, FinServ__PrimaryOwner__c,
            Rental_Frequency__c, FinServ__Ownership__c, Ownership_Share__c FROM FinServ__AssetsAndLiabilities__c
        	WHERE RecordTypeId =: assetRTId AND (FinServ__AssetsAndLiabilitiesType__c ='Commercial Property' OR 
        	FinServ__AssetsAndLiabilitiesType__c ='Investment Property') AND FinServ__PrimaryOwner__c in: pcIds];
    Map<Id, Account> accMap = New Map<Id, Account>();
    for(FinServ__AssetsAndLiabilities__c asset: assetsList){
        Account acc = accMap.get(asset.FinServ__PrimaryOwner__c);
        if(acc == Null){
            acc = New Account();
            acc.Rent_income_pa__c = 0;
        }
        Decimal RentalAmount = 0;
        Decimal shareAmount = 0;
        if(asset.Rental_Amount__c != Null){
            if(asset.Rental_Frequency__c == 'Weekly'){
                RentalAmount = asset.Rental_Amount__c * 52;
            }else if(asset.Rental_Frequency__c == 'Fortnightly'){
                RentalAmount = asset.Rental_Amount__c * 26;
            }else if(asset.Rental_Frequency__c == 'Monthly'){
                RentalAmount = asset.Rental_Amount__c * 12;
            }else if(asset.Rental_Frequency__c == 'Annually'){
                RentalAmount = asset.Rental_Amount__c * 1;
            }
        }
        if(asset.FinServ__Ownership__c == 'Applicant 1'){
			RentalAmount = RentalAmount;          
        }else if(asset.FinServ__Ownership__c == 'Applicant 2'){
            RentalAmount = 0;
        }else if(asset.Ownership_Share__c != Null){
            RentalAmount = RentalAmount * asset.Ownership_Share__c / 100;
        }
        acc.Id = asset.FinServ__PrimaryOwner__c;
        acc.Rent_income_pa__c = acc.Rent_income_pa__c + RentalAmount;
            
        accMap.put(asset.FinServ__PrimaryOwner__c, acc);
            
    }
    update accMap.values();
}