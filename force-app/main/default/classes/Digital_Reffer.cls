public without sharing class Digital_Reffer {
    
    public static final String accId = apexpages.currentpage().getparameters().get('id');
    public static final string ConId = ApexPages.currentPage().getParameters().get('ConId');
    public Account acc{get;Set;}
    public static string ImageSrc {get; set;} 
    public Digital_Reffer(){
       
		acc = New Account();
        if(String.isNotBlank(accId)){
            acc = [SELECT Id, ABN__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Company_Legal_Name__c, 
                   (SELECT Id, FirstName, LastName, Name, Position__c FROM Contacts WHERE Is_Authorised_Signatory__c =true LIMIT 1)
                   FROM Account WHERE id =: accId];
        }
    }
    
    public static void generateImageURL(){
        ImageSrc = sendImageDataToComponent();
    }
    
    public static string sendImageDataToComponent(){
        String imgURL = ''; 
        VOI_Detail__c voiDet = [Select Id, Name, contact__r.id from VOI_Detail__c Where contact__r.id =: ConId order by createddate DESC LIMIT 1];
        
        System.debug(voiDet);
        
        List<ContentDocumentLink> CDLList = [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = : voiDet.Id AND ContentDocument.Title = 'Sign1' LIMIT 1];
        
        if(!CDLList.isEmpty()){
            String cdId = CDLList[0].ContentDocumentId;
            
            List<ContentVersion> conVerList = [SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId = : cdId AND Title = 'Sign1' LIMIT 1];
            
            if(!conVerList.isEmpty()){
                
                List<ContentDistribution> cdList = [select ID,DistributionPublicUrl ,ContentDownloadURL  from ContentDistribution where ContentVersionId= :conVerList[0].Id and ContentDocumentId =: cdId ];
                
                if(cdList.size()>0){
                    
                    return cdList.get(0).ContentDownloadUrl;
                }else{
                    ContentDistribution conDis = new ContentDistribution();
                    conDis.Name = conVerList[0].Title;
                    conDis.ContentVersionId = conVerList[0].Id;
                    conDis.PreferencesAllowViewInBrowser= true;
                    conDis.PreferencesLinkLatestVersion=true;
                    conDis.PreferencesNotifyOnVisit=false;
                    conDis.PreferencesPasswordRequired=false;
                    conDis.PreferencesAllowOriginalDownload= true;
                    Insert conDis;
                    
                    conDis = [SELECT ID,DistributionPublicUrl, ContentDownloadURL FROM ContentDistribution WHERE ID= :conDis.Id];
                    
                    return conDis.ContentDownloadURL;
                }
            }
        }
        
        return imgURL;
    }
    
}