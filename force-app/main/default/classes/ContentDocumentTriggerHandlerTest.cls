@isTest
public class ContentDocumentTriggerHandlerTest {
    @isTest
    static void testBeforeDelete() {
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName ='Quote';
        opp.CloseDate = System.Today();
        insert opp;  
        
        Document_Requested__c dc = new Document_Requested__c();
        dc.Category__c = 'Purchase Invoice';
        dc.Opportunity__c = Opp.Id;
        Insert dc;
        
        List<ContentVersion> cnvList = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Cv';
        cv.PathOnClient = 'TestPath';
        cv.FirstPublishLocationId = opp.Id;
        cv.VersionData = Blob.valueOf('Test Data');
        cv.Current_in_use__c = true;
        cv.Document_Requested__c = dc.Id;
        insert cv;
        
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test Cv1';
        cv1.PathOnClient = 'TestPath1';
        cv1.FirstPublishLocationId = opp.Id;
        cv1.VersionData = Blob.valueOf('Test Data 1');
        cv1.Current_in_use__c = false;
        cv1.Document_Requested__c = dc.Id;
        insert cv1;
        
        ContentVersion cv2 = [SELECT Id,ContentDocumentId From ContentVersion WHERE Id=: cv.id];
        List<ContentDocument> cntList = [SELECT Id From ContentDocument WHERE Id =: cv2.ContentDocumentId];
        ContentDocumentTriggerHandler handler = new ContentDocumentTriggerHandler();
        test.startTest();
        handler.beforeDelete(cntList);
        test.stopTest();
    }
    
}