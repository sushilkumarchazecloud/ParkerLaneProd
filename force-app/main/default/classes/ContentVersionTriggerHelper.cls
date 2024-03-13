/**
 * @description	: This is a trigger class for ContentVersion object.
 * @author     	: Sethu Singh Rawat
 * @created on 	: 26-02-2024
 */
public with sharing class ContentVersionTriggerHelper {
    
    public static void iconFieldUpdateOnProductTypeObject(Map<Id, SObject> newCntVersion){
        Set<Id> contIDs = new Set<Id>();
        Set<Id> prIds = new Set<Id>();
        List<Product_type__c> productTypeListUpdate = new List<Product_type__c>();
        List<ContentDistribution> insertContentDistributions = new List<ContentDistribution>();
        for(ContentVersion Cv : (List<ContentVersion>)newCntVersion.values()){
            if(Cv.ContentDocumentId != null &&  Cv.FirstPublishLocationId.getSObjectType().getDescribe().getName() == 'Product_Type__c'){
                ContentDistribution distribution = new ContentDistribution();
                distribution.ContentVersionId = Cv.Id;
                distribution.Name = 'PublicShare';
                distribution.PreferencesAllowOriginalDownload = true; 
                distribution.PreferencesAllowPDFDownload = true;
                distribution.PreferencesPasswordRequired = false;
                distribution.PreferencesAllowViewInBrowser = true;
                distribution.PreferencesNotifyOnVisit=false;
                distribution.PreferencesLinkLatestVersion = true;
                insertContentDistributions.add(distribution);
                contIDs.add(cv.ContentDocumentId);
                prIds.add(cv.FirstPublishLocationId);
            }
        }
        if(!insertContentDistributions.isEmpty()){
            insert insertContentDistributions;
        }
        //List<ContentDistribution> cdUrl = [Select Id,ContentDocumentId,ContentDownloadUrl,DistributionPublicUrl,ContentVersion.FirstPublishLocationId from ContentDistribution where ContentDocumentId In: contIDs];
        Map<Id,String> mapOFProductTypeAndPicUrl = new Map<Id,String>();
        if(contIDs != null){
            for(ContentDistribution contentDistributionRecord : ContentVersionSelector.getContentDistributions(contIDs)){
                String picUrl = '';
                picUrl =  contentDistributionRecord.ContentDownloadUrl.replace('download/?' , 'renditionDownload?rendition=ORIGINAL_Jpg&');
                picUrl = picUrl.replace('&ids' , '&versionId');
                mapOFProductTypeAndPicUrl.put(contentDistributionRecord.ContentVersion.FirstPublishLocationId,picUrl); 
            }
        }
        
        //List<Product_type__c> prTypes = [Select id,Icon__c from Product_type__c where id IN :  prIds];
        if(contIDs != null){
            for(Product_type__c pr : ProductTypeSelector.getAllProductTypes(prIds)){
                String picc = '';
                picc = mapOFProductTypeAndPicUrl.get(pr.Id);
                pr.Icon__c = picc;
                productTypeListUpdate.add(pr);
            }
        }
        if(!productTypeListUpdate.isEmpty()){
            update productTypeListUpdate;
        }
    }
}