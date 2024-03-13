/**
 * @description       : This is a Selector Class for ContentVersion
 * @Author            : Sethu Singh Rawat
 * @Created on        : 26/02/2024
 * @Last Modified By  : Sethu Singh Rawat
 * @Last Modified On  : 26/02/2024
**/
public without sharing class ContentVersionSelector {
	
    /**
     * @description       : This method is used to get the list of ContentDistribution  records that has matched contentDocumentIds
     * @Author            : Sethu Singh Rawat
     * @Created on        : 27/02/2024
     * @param Set<Id> contentDocumentIds
     * @return List<ContentDistribution>
    **/
    public static List<ContentDistribution> getContentDistributions(Set<Id> contentDocumentIds){
        return[Select Id,ContentDocumentId,ContentDownloadUrl,DistributionPublicUrl,ContentVersion.FirstPublishLocationId FROM 
               ContentDistribution WHERE ContentDocumentId IN: contentDocumentIds];
    }
}