@isTest
public class IdentityCertificateControllerTest {
	
    @isTest
    public static void methodOne(){
        contact con = new contact();
        con.firstname = 'qwert';
        con.lastName = 'testing';
        con.VOI_type__c = 'VOI';
        insert con;
        
        VOI_Detail__c obj  = new VOI_Detail__c();
        obj.Secure_Code_Orignal__c = '1234';
        obj.Contact__c = con.Id;
        obj.Code_Not_Required__c = true;
        insert obj;
        
        PageReference pageRef1 = Page.IdentityVerificationCertificatePDF; // Add your VF page Name here
        pageRef1.getParameters().put('id', obj.id);
        Test.setCurrentPage(pageRef1);
        
        IdentityCertificateController.getContact();
        contact cont = [Select id, Name From contact WHERE id =: con.id LIMIT 1];
        
        ContentVersion cv=new Contentversion();
        cv.title= 'DL Front '+cont.Name;
        cv.PathOnClient ='DL Front '+cont.Name+'.jpeg';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
        
        ContentVersion cv1 = new Contentversion();
        cv1.title= 'DL Back '+cont.Name;
        cv1.PathOnClient ='DL Back '+cont.Name+'.jpeg';
        Blob b1=Blob.valueOf('Unit Test Attachment Body');
        cv1.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv1;
        
        ContentVersion cv2 = new Contentversion();
        cv2.title='video';
        cv2.PathOnClient ='video.jpeg';
        Blob b2=Blob.valueOf('Unit Test Attachment Body');
        cv2.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv2;
        
        ContentVersion cv3 = new Contentversion();
        cv3.title='video';
        cv3.PathOnClient ='video.jpeg';
        Blob b3=Blob.valueOf('Unit Test Attachment Body');
        cv3.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv3;
        
        System.debug('cv'+cv.Id);
        System.debug('cv1'+cv1.Id);
        System.debug('cv2'+cv2.Id);
        
        List<ContentVersion> conDocId = new List<ContentVersion>();
        conDocId = [SELECT ContentDocumentId FROM ContentVersion LIMIT 4];
        System.debug('-'+conDocId);
        
		
        List<ContentDocumentLink> CLDList = new List<ContentDocumentLink>();
        
        for(ContentVersion cvr : conDocId){
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.ContentDocumentId = cvr.ContentDocumentId;
            contentlink.ShareType= 'I';
            contentlink.LinkedEntityId = obj.Id; 
            contentlink.Visibility = 'AllUsers';     
            
            CLDList.add(contentlink);
        }
        
        upsert CLDList;
        
        opportunity opp = new opportunity();
        opp.name = 'test Opp';
        opp.Purpose__c = 'Home Improvement';
        opp.Packs_Out_Date__c = system.today();
        opp.Contact_1__c = con.id;
        opp.StageName = 'Working';
        opp.CloseDate = System.today();
        
        insert opp;
        
        VOI_Status__c vois = new VOI_Status__c();
        vois.Contact__c = con.id;
        vois.VOI_Detail__c = obj.Id;
        vois.Opportunity__c = opp.id;
        vois.Date_submitted__c = system.now();
        insert vois;
        
        IdentityCertificateController ICC = new IdentityCertificateController();
    }
}