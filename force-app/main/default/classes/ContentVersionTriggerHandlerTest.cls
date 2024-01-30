@isTest
public class ContentVersionTriggerHandlerTest {
    @isTest
    static void testAfterUpdate() {
        Id custSupPersonId = [select id,username from user where username=: System.Label.customerSite].id;
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName ='Quote';
        opp.CloseDate = System.Today();
        insert opp;  
        
        Document_Requested__c dc = new Document_Requested__c();
        dc.Category__c = 'Purchase Invoice';
        dc.Opportunity__c = Opp.Id;
        Insert dc;
        
        Document_Requested__c dc2 = new Document_Requested__c();
        dc2.Category__c = 'Lender Credit Contract';
        dc2.Opportunity__c = Opp.Id;
        Insert dc2;
        
        List<ContentVersion> cnvList = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Cv';
        cv.PathOnClient = 'TestPath';
        cv.FirstPublishLocationId = opp.Id;
        cv.VersionData = Blob.valueOf('Test Data');
        cv.Current_in_use__c = true;
        cv.Document_Requested__c = dc.Id;
        cv.OwnerId = custSupPersonId;
        insert cv;
        
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test Cv1';
        cv1.PathOnClient = 'TestPath1';
        cv1.FirstPublishLocationId = opp.Id;
        cv1.VersionData = Blob.valueOf('Test Data 1');
        cv1.Current_in_use__c = false;
        cv1.OwnerId = custSupPersonId;
        insert cv1;
        
        ContentVersion cv2 = new ContentVersion();
        cv2.Title = 'Test Cv1';
        cv2.PathOnClient = 'TestPath1';
        cv2.FirstPublishLocationId = opp.Id;
        cv2.VersionData = Blob.valueOf('Test Data 1');
        cv2.Current_in_use__c = true;
        cv2.OwnerId = custSupPersonId;
        insert cv2;
        
        Funding_Request__c fr = new Funding_Request__c();
        fr.Opportunity__c = opp.Id;
        fr.Request_Status__c = 'Payment requested by customer (pending contract)';
        fr.Customer_Authorisation_Status__c = 'Authorised';
        insert fr;
        
        Funding_Request__c fr2 = new Funding_Request__c();
        fr2.Opportunity__c = opp.Id;
        fr2.Request_Status__c = 'Payment requested by supplier (pending contract)';
        fr2.Customer_Authorisation_Status__c = 'Authorised';
        insert fr2;
          
        Test.startTest();
        cv1.Document_Requested__c = dc.Id;
        cv2.Document_Requested__c = dc2.id;
        list<ContentVersion> cvlist = new list<ContentVersion>{cv1,cv2};
            update cvlist;
        Test.stopTest();
    }
}