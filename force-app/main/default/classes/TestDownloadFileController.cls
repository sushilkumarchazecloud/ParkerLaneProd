@isTest
public class TestDownloadFileController{
    @testSetup static void setup() {
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
        
        Opportunity testOpp1 = new Opportunity(RecordType = rt,
                                         Name = 'Test1',
                                         StageName = 'Quote',
                                         CloseDate = dt,
                                         Applicant_1__c = acct1.Id,
                                         Applicant_2__c = acct.Id);
        insert testOpp1;
        
        List<Document_Requested__c> testDr = new List<Document_Requested__c>();
        for(Integer i=0; i<2; i++){
            if(i==1){
                testDr.add(new Document_Requested__c(Opportunity__c = testOpp.Id,
                                                     Category__c = 'Identification',
                                                     Person_Account__c = testOpp.Applicant_2__c));
            }
            else{
                testDr.add(new Document_Requested__c(Opportunity__c = testOpp.Id,
                                                     Category__c = 'Income',
                                                     Person_Account__c = testOpp.Applicant_1__c));
            }
        }
        insert testDr;
        
        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'Penguins1',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion2;
        
        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = testOpp.id;
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
        cdl.LinkedEntityId = testOpp.id;
        cdl.ContentDocumentId = [select contentdocumentid from contentversion where id =: contentVersion.id].contentdocumentid;
        cdl.shareType = 'V';
        insert cdl;
        
        DocumentRequestedController.updateDocRequested(testDr[0].Id,new List<String>{cdl.ContentDocumentId});
        
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'Benguins',
            PathOnClient = 'Benguins.jpg',
            VersionData = Blob.valueOf('Test Content1'),
            IsMajorVersion = true
        );
        insert contentVersion1;
        
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = testOpp.id;
        cdl1.ContentDocumentId = [select contentdocumentid from contentversion where id =: contentVersion1.id].contentdocumentid;
        cdl1.shareType = 'V';
        insert cdl1;
        DocumentRequestedController.updateDocRequested(testDr[1].Id,new List<String>{cdl1.ContentDocumentId});
        
        list<Funding_Request__c> frList = new list<Funding_Request__c>();
        Funding_Request__c fr = new Funding_Request__c();
        fr.Request_Amount__c = 20000;
        fr.Invoice_Amount__c = 20000;
        fr.Request_Type__c = 'Part payment before installation';
        fr.Request_Status__c = 'Payment funded';
        fr.Opportunity__c = testOpp.Id;
        fr.Requested_by__c = 'Supplier';
        fr.Person_Requesting__c = testOpp.Applicant_1__r.personcontactId;
        fr.A1_Funding_Call_Handover__c = system.now();
        fr.A2_Funding_Call_Handover__c = system.now();
        fr.Installation_Date__c = date.today();
        frList.add(fr);
        
        insert frList;
    }
    @isTest
    private static void testContentVersion(){
    
        //List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        Account acct = new Account(Name='TEST_ACCT');
        insert acct;
        
        ContentVersion contentVersion = new ContentVersion(
                                                          Title = 'Penguins',
                                                          PathOnClient = 'Penguins.jpg',
                                                          VersionData = Blob.valueOf('Test Content'),
                                                          IsMajorVersion = true
                                                        );
        insert contentVersion;    
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = acct.id; 
        cdl.ContentDocumentId = [select contentdocumentid from contentversion where id =: contentVersion.id].contentdocumentid;
        cdl.shareType = 'V';
        insert cdl;
        
        List<ContentVersion> cvList = DownloadFileController.getContentVersion(acct.Id);
        System.assert(cvList.size() > 0);
        
        List<Map<String,String>> atts = DownloadFileController.getZipFile(new List<String>{contentVersion.Id});
        System.assert(atts.size() > 0);
        
        String url = DownloadFileController.downloadContent(contentVersion.Id);
        System.assert(url != null);
        
        DownloadFileController.deleteContent(cdl.ContentDocumentId);
        
    }
    @isTest
    private static void testgetAllObjRecords(){
        Opportunity testOpp = [Select Id from Opportunity where Name = 'Test'];
        List<SObject> testData = DownloadFileController.getAllObjRecords('Opportunity', 't',testOpp.Id);
        System.assert(testData.size() == 1);
    }
    @isTest
    private static void testcopyFilesToNew(){
        Opportunity testOpp = [Select Id from Opportunity where Name = 'Test'];
        Opportunity testOpp1 = [Select Id from Opportunity where Name = 'Test1'];
        List<ContentVersion> cv = [Select Id from ContentVersion];
        List<String> copy = new List<String>();
        for(ContentVersion c: cv){
            copy.add(c.Id);
        }
        List<ContentDocumentLink> file = [Select Id from ContentDocumentLink where LinkedEntityId =: testOpp1.Id];
        System.assert(file.size() == 0);
        DownloadFileController.copyFilesToNew(testOpp1.Id, copy,testOpp.Id);
        file = [Select Id from ContentDocumentLink where LinkedEntityId =: testOpp1.Id];
        System.assert(file.size() == 3);
    } 
    @isTest
    private static void testSortedList(){
        List<String> passcvid = new List<String>();
        for(ContentVersion c: [Select Id from ContentVersion]){
            passcvid.add(c.Id);
        }
        List<ContentVersion> cvList = DownloadFileController.sortedList(passcvid, 'Title', true);
        System.assert(cvList[0].Title == 'Benguins');
        cvList = DownloadFileController.sortedList(passcvid, 'Title', false);
        System.assert(cvList[0].Title == 'Penguins1');
    }
    @isTest
    public static void testfilterRelated(){
        Opportunity testOpp = [Select Id from Opportunity where Name = 'Test'];
        List<String> rel = new List<String>();
        List<String> cat = new List<String>();
        cat.add('Income');
        cat.add('Identification');
        rel.add('Applicant 1');
        rel.add('Applicant 2');
        List<ContentVersion> cv = DownloadFileController.filterRelated(testOpp.Id, rel, cat);
    	System.assert(cv.size() == 2 );
    }
    @isTest
    public static void testfindMatch(){
        Opportunity testOpp = [Select Id from Opportunity where Name = 'Test'];
        Opportunity testOpp1 = [Select Id from Opportunity where Name = 'Test1'];
        List<String> match = DownloadFileController.findMatch(testOpp1.Id,testOpp.Id);
    	System.assert(match.size() == 2 );
    }
    @isTest
    public static void testgetOppDetail(){
        Opportunity testOpp = [Select Id from Opportunity where Name = 'Test'];
        Opportunity match = DownloadFileController.getOppDetail(testOpp.Id);
    	System.assert(match.Id == testOpp.Id );
    }
    @isTest
    public static void testfetchUploaded(){
        List<ContentVersion> cv = [Select Id, ContentDocumentId from ContentVersion];
    	List<String> cvIds = new List<String>();
        for(ContentVersion a: cv){
            cvIds.add(a.ContentDocumentId);
        }
        List<ContentVersion> getcv = DownloadFileController.fetchUploaded(cvIds);
        System.assert(getcv.size() == 3 );
    }
    
    @isTest
    public static void testuploadDocuments(){
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND Name = 'Green Loan'];
        Date dt = date.today();
        Opportunity testOpp = new Opportunity(RecordType = rt,
                                              Name = 'Test',
                                              StageName = 'Quote',
                                              CloseDate = dt);
        insert testOpp;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Peng',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = testOpp.Id;
        cdl.ContentDocumentId = [select contentdocumentid from contentversion where id =: contentVersion.id].contentdocumentid;
        cdl.shareType = 'V';
        insert cdl;
        List<ContentVersion> fetchcv = [Select Id, ContentDocumentId, Title, Description, Document_Requested__c, Related__c, Category__c from ContentVersion where Id=:contentVersion.Id];
        List<ContentVersion> passcv = new List<ContentVersion>();
        Id cvid;
        for(ContentVersion c: fetchcv){
            cvid = c.Id;
            c.Title = 'PenguinsP';
            c.Description = 'hello';
            passcv.add(c);
        }
        test.startTest();
        DownloadFileController.uploadDocuments(passcv, testOpp.Id);
        test.stopTest();
       	ContentVersion getcv = [Select Id, ContentDocumentId, Title, Description, Document_Requested__c, Related__c, Category__c from ContentVersion where Id=:cvid];
       	System.assert(getcv.Title == 'PenguinsP');
        System.assert(getcv.Description == 'hello');
    }
    
    @isTest
    public static void testpdfMerge(){
    	Opportunity testOpp = [Select Id from Opportunity where Name = 'Test'];
        String forPdf = 'Hello test';
        Blob b = Blob.toPdf(forPdf);
        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'Pdffile',
            PathOnClient = 'Pdffile.pdf',
            VersionData = b
        );
        insert contentVersion2;
        
        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = testOpp.id;
        cdl2.ContentDocumentId = [select contentdocumentid from contentversion where id =: contentVersion2.id].contentdocumentid;
        cdl2.shareType = 'V';
        insert cdl2;
        List<String> sndId = new List<String>();
        sndId.add(contentVersion2.Id);
        String result = DownloadFileController.pdfMerge( true, testOpp.Id, sndId);
        System.assert(result == 'done');
        System.Test.setMock(HttpCalloutMock.class, new Api2PdfClientMockout());
        System.Test.startTest();
        result = DownloadFileController.pdfMerge( false, testOpp.Id, sndId);
        System.assert(result == null);
        System.Test.stopTest();
    } 
    
     
    @isTest
    public static void TestgetFundingDocs(){
        Funding_Request__c fr = [SELECT Id FROM Funding_Request__c LIMIT 1]; 
        DownloadFileController.getFundingDocs(fr.Id);
    }
}