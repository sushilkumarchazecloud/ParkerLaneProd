@isTest
public class AssetTriggerTest {
	static testmethod void CreateAndDeleteEmployment(){
        Test.startTest();
        Account acc = New Account(Name = ' Name');
        insert acc;
        Id assetRTId = Schema.SObjectType.FinServ__AssetsAndLiabilities__c.getRecordTypeInfosByName().get('Asset').getRecordTypeId();
        List<FinServ__AssetsAndLiabilities__c> assetList = New List<FinServ__AssetsAndLiabilities__c>();
        assetList.add(New FinServ__AssetsAndLiabilities__c(FinServ__PrimaryOwner__c = acc.Id, FinServ__AssetsAndLiabilitiesType__c='Commercial Property',
                                               Name = 'emp', Rental_Frequency__c = 'Weekly', RecordTypeId = assetRTId,
                                               Rental_Amount__c = 100, Ownership_Share__c = 100, FinServ__Ownership__c = 'Applicant 1')); 
        assetList.add(New FinServ__AssetsAndLiabilities__c(FinServ__PrimaryOwner__c = acc.Id, FinServ__AssetsAndLiabilitiesType__c='Investment Property',
                                               Name = 'emp', Rental_Frequency__c = 'Fortnightly', RecordTypeId = assetRTId,
                                               Rental_Amount__c = 100, Ownership_Share__c = 100, FinServ__Ownership__c = 'Applicant 2')); 
        assetList.add(New FinServ__AssetsAndLiabilities__c(FinServ__PrimaryOwner__c = acc.Id, FinServ__AssetsAndLiabilitiesType__c='Investment Property',
                                               Name = 'emp', Rental_Frequency__c = 'Monthly', RecordTypeId = assetRTId,
                                               Rental_Amount__c = 100, Ownership_Share__c = 100, FinServ__Ownership__c = 'Joint')); 
        assetList.add(New FinServ__AssetsAndLiabilities__c(FinServ__PrimaryOwner__c = acc.Id, FinServ__AssetsAndLiabilitiesType__c='Commercial Property',
                                               Name = 'emp', Rental_Frequency__c = 'Annually', RecordTypeId = assetRTId,
                                               Rental_Amount__c = 100, Ownership_Share__c = 100, FinServ__Ownership__c = 'Applicant 1')); 
        insert assetList;
        Test.stopTest();
        Account accResult = [SELECT ID, Rent_income_pa__c FROM Account WHERE Id =: acc.Id];
        System.assertEquals(accResult.Rent_income_pa__c, 6500, 'Value should be 6500');
        
        delete assetList[0];
        accResult = [SELECT ID, Rent_income_pa__c FROM Account WHERE Id =: acc.Id];
        System.assertEquals(accResult.Rent_income_pa__c, 6500, 'Value should be 6500');
    }
}