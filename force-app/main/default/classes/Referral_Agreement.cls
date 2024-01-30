public without sharing class Referral_Agreement {
    
    public static final String accId = apexpages.currentpage().getparameters().get('id');
    public static final string ConId = ApexPages.currentPage().getParameters().get('ConId');
    public Account acc{get;Set;}
    public static string ImageSrc {get; set;} 
    public Referral_Agreement(){
        
        acc = New Account();
        if(String.isNotBlank(accId)){
            acc = [SELECT Id, ABN__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Company_Legal_Name__c, 
                   (SELECT Id, FirstName, LastName, Name, Position__c FROM Contacts WHERE id =: ConId LIMIT 1)
                   FROM Account WHERE id =: accId];
        }
    }
    
    public static void generateImageURL(){
        ImageSrc = sendImageDataToComponent();
    }
    
    public static string sendImageDataToComponent(){
        String imgURL = '';
        Contact conDet = [Select Id, Name from Contact Where id =: ConId order by createddate DESC LIMIT 1];        
        
        List<ContentDocumentLink> CDLList = [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = : conDet.Id AND ContentDocument.Title = 'Sign' LIMIT 1];
        
        if(!CDLList.isEmpty()){
            String cdId = CDLList[0].ContentDocumentId;
            
            List<ContentVersion> conVerList = [SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId = : cdId AND Title = 'Sign' LIMIT 1];
            
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