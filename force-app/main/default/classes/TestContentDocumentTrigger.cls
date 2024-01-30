@IsTest
public class TestContentDocumentTrigger {
	@IsTest
    public static void testBeforeInsert(){
        List<String> Cids = new List<String>();
        Account acct = new Account(FirstName='Test',LastName='Acct');
        insert acct;
        Account acct1 = new Account(FirstName='Test1',LastName='Acct1');
        insert acct1;
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND Name = 'Green Loan'];
        Date dt = date.today();
        Opportunity testOpp = new Opportunity(RecordType = rt,
                                         Name = 'Test',
                                         StageName = 'Quote',
                                         CloseDate = dt,
                                         Applicant_1__c = acct.Id,
                                         Applicant_2__c = acct1.Id);
        insert testOpp;
        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'Penguins1',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion2;
        
        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = testOpp.Id;
        cdl2.ContentDocumentId = [select contentdocumentid from contentversion where id =: contentVersion2.id].contentdocumentid;
        cdl2.shareType = 'V';
        insert cdl2;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = testOpp.Id;
        cdl.ContentDocumentId = [select contentdocumentid from contentversion where id =: contentVersion.id].contentdocumentid;
        cdl.shareType = 'V';
        insert cdl;
        List<ContentDocumentLink> getcdl = [Select Id, ContentDocumentId, Visibility, ShareType FROM ContentDocumentLink where LinkedEntityId=:testOpp.Id];
        for(ContentDocumentLink c: getcdl){
            System.assert(c.ShareType!='I');
            System.assert(c.Visibility=='Allusers');    
        } 
        
    }
}