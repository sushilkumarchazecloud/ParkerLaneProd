public class Show_Video_controller {
    public static final string voiId = ApexPages.currentPage() != null ? ApexPages.currentPage().getParameters().get('id') : '';
    public static String VideoDataToVf {get; set;}
    public static String VideoURL {get; set;}
    
    public Show_Video_controller(){
        VideoDataToVf = sendVideoDataToComponent(voiId);
        
        System.debug('VideoDataToVf'+VideoDataToVf);
        VideoURL = '/sfc/servlet.shepherd/version/download/'+VideoDataToVf;
    }
    
    
    
    public static String sendVideoDataToComponent(string RecId){
        System.debug('================================='+RecId);
        
        
        list<ContentVersion> CVList = new List<ContentVersion>();
        list<String> VersionDataList = new List<String>();
        String Temp;
        Set<Id> CDId = new Set<Id>();
        for(ContentDocumentLink Cd : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: RecId]){
            CDId.add(Cd.ContentDocumentId);
        }
        System.debug('CDId--->'+CDId);
        
        CVList = [SELECT Id FROM ContentVersion WHERE ContentDocumentId = : CDId AND Title = 'video' order by createddate DESC LIMIT 1];
        //System.debug('CVListCVList'+CVList);
        
        for(ContentVersion Cd : CVList){
            VersionDataList.add(Cd.Id);
        }
        System.debug('VersionDataList'+VersionDataList);
        if(VersionDataList != null){
            if(VersionDataList.size() > 0){
                Temp = VersionDataList[0];
            }    
        }
        return Temp;
    }
    
    @AuraEnabled
    public static VOI_Detail__c FetchVoiDetail(Id recId){
        system.debug('recId'+recId);
        VOI_Detail__c voi = [select Id,verified_by__c,Secure_Code__c,contact__c,verified_by_selfie_ID__c,matchVerification__c,contact__r.Name,contact__r.AccountID, Code_Not_Required__c,Code_Match_Status__c,Identity_Certified_By__c,Secure_Code_Orignal__c,Video_and_Photo_ID_of_the_same_person__c,Identity_Verification_Status__c From VOI_Detail__c WHERE Id = : recId];
        return voi;
    }
    
    @AuraEnabled
    public static VOI_Detail__c UpdateVOI(VOI_Detail__c voiDt){
        System.debug('video id : '+voiDt.verified_by_selfie_ID__c);
        boolean isWantPDF = false;
        System.debug('Video_and_Photo_ID_of_the_same_person__c----'+voiDt.Video_and_Photo_ID_of_the_same_person__c);
        if(string.isBlank(voiDt.verified_by__c)){
         	voiDt.verified_by__c = voiDt.Identity_Certified_By__c;   
        }        
        if(voiDt.Secure_Code__c == voiDt.Secure_Code_Orignal__c){
            voiDt.Code_Match_Status__c = 'MATCH(Success)';
        }
        else {
            voiDt.Code_Match_Status__c = 'NOT-MATCH(Failed)';
        }
        
        if((voiDt.Secure_Code__c == voiDt.Secure_Code_Orignal__c || voiDt.Code_Not_Required__c == true || voiDt.verified_by_selfie_ID__c == true) && voiDt.Video_and_Photo_ID_of_the_same_person__c == 'Facial match (success)') {
            
            voiDt.Identity_Verification_Status__c = 'Verified';
            
        }
        else{
            
            voiDt.Identity_Verification_Status__c = 'Not-Verified';
        }
        update voiDt;
        
        return voiDt;
    }
    
    @AuraEnabled
    public static void GenrateIdentityCertificate(VOI_Detail__c voiDt){
        
        Voi_status__c vois = [select id, name,Opportunity__c,Opportunity__r.id, VOI_detail__c from VOI_Status__c WHERE VOI_detail__r.id = : voidt.id LIMIT 1];
        opportunity opp = [select id, name,Packs_Out_Date__c from opportunity WHERE id =: vois.Opportunity__r.id LIMIT 1];
        contact cnt = [select id, Name from contact where id=: voidt.Contact__c LImit 1];
        
        
        string name = 'Identity Certificate for '+cnt.Name;
        
        Document_Requested__c dc = new Document_Requested__c();
        dc.Category__c = 'Identification';
        dc.Person_Account__c = voiDt.Contact__r.AccountId;
        dc.Opportunity__c = opp.Id;
        insert dc;
        
        PageReference pdf = Page.IdentityVerificationCertificatePDF;
        pdf.getParameters().put('id',voiDt.Id);
        pdf.setRedirect(true);
        Blob bPDF;
        
        if (Test.IsRunningTest())
        {
            bPDF=Blob.valueOf('UNIT.TEST');
        }
        else
        {
            System.debug('pdf.getContent()'+pdf.getContent());
            bPDF = pdf.getContent();
        }
       
        System.debug('voi.Contact__r'+cnt.Name);
        System.debug('voi.Contact__r.name'+cnt.Name);
        ContentVersion ContVerFile = new ContentVersion();
        ContVerFile.VersionData = bPDF;
        ContVerFile.Title = name; 
        ContVerFile.PathOnClient= name+'.pdf'; 
        ContVerFile.Document_Requested__c = dc.Id;
        insert ContVerFile;
        
        SYstem.debug('ContVerFile id '+ContVerFile.Id);
        List<ContentVersion> conDocId = new List<ContentVersion>();
        
        conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :ContVerFile.Id];
        System.debug('conDocId : '+conDocId[0].ContentDocumentId);
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        
        cdl.LinkedEntityId = opp.id;
        cdl.ContentDocumentId = conDocId[0].ContentDocumentId;
        
        cdl.shareType = 'V';
        
        Insert cdl;
        System.debug('content+'+cdl.Id);
        
        if(cdl != null){
            Document_Requested__c doc = new Document_Requested__c();
            doc.id = dc.Id;
            doc.isComplete__c = true;
            update doc;
        }
    }    
    
}