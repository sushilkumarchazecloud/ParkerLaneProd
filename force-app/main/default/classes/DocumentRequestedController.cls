public without sharing class DocumentRequestedController{

    @AuraEnabled
    public static List<Document_Requested__c> fetchDocumentRequested(String oppId){
        List<Document_Requested__c> drList = [SELECT Id,Name,Document__c, CreatedDate,isComplete__c, Details__c,Related_To__c,Description__c,Status__c,Category__c FROM Document_Requested__c WHERE Opportunity__c =: oppId AND Document__c != '' ORDER BY Name ASC];
       	system.debug('drListdrList'+drList);
        
        return drList;
    }
    
    @AuraEnabled
    public static void updateDocRequested(String docId, List<String> cdIds){
        Id dr = (Id)docId;
        System.debug(cdIds);
        List<ContentVersion> cv  = new List<ContentVersion>();
        for(ContentVersion c: [select Id, related__c, Category__c, Document_Requested__c, ContentDocumentId from ContentVersion where contentDocumentId In :cdIds]){
            c.Document_Requested__c = dr;
        	cv.add(c);
        }
        update cv;
        Document_Requested__c doc = new Document_Requested__c();
        doc.id = docId;
        doc.isComplete__c = true;
        update doc;        
    }
    
    @AuraEnabled
    public static Account getAccountDetails(String recordId){
        Account acc = [Select id,BackgroundImage__c,LogoImage__c from Account where id =: recordId];
        return acc;
    }
    
    @AuraEnabled
    public static Account addAccountPhotos(List<String> cdIds, String recordId, String name){
        List<ContentDistribution> cd = new List<ContentDistribution>();
        ContentDistribution distribution;
        String distributionLink = '';
        for(ContentVersion c: [select Id, related__c, Category__c, Document_Requested__c, ContentDocumentId from ContentVersion where contentDocumentId In :cdIds]){
             distribution = new ContentDistribution();
            distribution.ContentVersionId = c.Id;
            distribution.Name = 'PublicShare';
            distribution.PreferencesAllowOriginalDownload = true; 
            distribution.PreferencesAllowPDFDownload = true;
            distribution.PreferencesPasswordRequired = false;
            distribution.PreferencesAllowViewInBrowser = true;
            distribution.PreferencesNotifyOnVisit=false;
            distribution.PreferencesLinkLatestVersion = true;
            cd.add(distribution);
        }
        insert cd;
        ContentDistribution cdUrl = [Select Id,ContentDocumentId,ContentDownloadUrl,DistributionPublicUrl from ContentDistribution where ContentDocumentId In: cdIds];
        String picUrl = '';
        picUrl =  cdUrl.ContentDownloadUrl.replace('download/?' , 'renditionDownload?rendition=ORIGINAL_Jpg&');
        picUrl = picUrl.replace('&ids' , '&versionId');
        Account acc = [Select id,BackgroundImage__c,LogoImage__c from Account where id =: recordId];
        if(name == 'Logo'){
            acc.LogoImage__c = '<p>'+picUrl+'</p>';
        }
        else if(name == 'Background'){
            acc.BackgroundImage__c = '<p>'+picUrl+'</p>';
        }
        update acc;
        return acc;
    }
    
    @AuraEnabled
    public static void updateCustomerActivity(string recId){
        Opportunity opp = [select id,Last_Customer_Action__c,isActivityCheck__c,Last_Customer_Activity__c/*,Docs_Last_Uploaded__c*/ from opportunity where id =: recId];
        opp.Last_Customer_Activity__c = system.now(); 
        opp.isActivityCheck__c = false;
        update opp;
        opp.isActivityCheck__c = true;
        opp.Last_Customer_Action__c = 'Documents received';
        opp.Docs_Last_Uploaded__c = System.now();
        update opp;
    }
    
    @AuraEnabled
    public static string sendEmailToCust(string oppId){
       List<Document_Requested__c> drList = [SELECT id,isComplete__c,Details__c,Document__c,Related_To__c,Status__c FROM Document_Requested__c WHERE Opportunity__c =: oppId AND isComplete__c = false AND Document__c != ''];
        
        System.debug('finalList'+drList.size());
        if(drList != null && drList.size() > 0){
            System.debug('in list');    
            Opportunity oppUpdate = [SELECT Id, Application_Sections__c, Current_Application_Sections__c, AccountId, Applicant_1__c,
                                     Applicant_1__r.PersonContactId, Applicant_1__r.PersonContact.Email, StageName, RecordTypeId,
                                     Number_of_applicants__c,
                                     (SELECT Id, Lead__c, Lender__c, Purpose__c  FROM Quotes WHERE Application__c = TRUE)
                                     FROM Opportunity WHERE Id =: oppId];
            
            System.debug('oppUpdate'+oppUpdate);
            System.debug('oppUpdate'+oppUpdate.Applicant_1__r.PersonContact.Email);
            ParkerLaneLoanController.sendApplication(oppId, oppUpdate.Applicant_1__r.PersonContactId, oppUpdate.Quotes[0].id, New List<String>{oppUpdate.Applicant_1__r.PersonContact.Email}, 'Application Form Completion Remainder', false);
            return 'success';
        }else{
            return 'error';
        }
        
    }
    
}