@isTest
public class TriggerContentDocumentLinkTest {
    @isTest
    public static void testmethodData(){	
        Account acct = new Account(Name='TEST_ACCT');
        insert acct;
        
        //Create contentVersion
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        
        //Get Content Version
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        System.assertEquals(cvList.size(), 1);
        system.debug('ContentVersionID : ' + cvList[0].Id);
        
        List<ContentDocumentLink> tempList = new List<ContentDocumentLink>();
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = acct.id;
        cdl.ContentDocumentId = cvList[0].ContentDocumentId;
        cdl.shareType = 'V';
       	tempList.Add(cdl);
        
        insert tempList;
        
        TriggerContentDocumentLink temp = new TriggerContentDocumentLink();
        temp.OnBeforeInsert(tempList);
    }
}