@isTest
public class Digital_Reffer_Test {
	@isTest
    public static void testForPDF(){
        contact con = new contact();
        con.firstname = 'qwert';
        con.lastName = 'testing';
        insert con;
        
        Account Accnew = new Account();
        Accnew.LastName = 'testing';
        insert Accnew;
        
        VOI_Detail__c obj  = new VOI_Detail__c();
        obj.Secure_Code_Orignal__c = '1234';
        obj.Contact__c = con.Id;
        insert obj;
        
        
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
        
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='Sign1', 
            PathOnClient ='Sign1.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                           FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = obj.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
        
        Test.setCurrentPageReference(new PageReference('Page.Digital_Reffer_PDF')); 
        System.currentPageReference().getParameters().put('id', Accnew.id);
        System.currentPageReference().getParameters().put('ConId', con.id);
        
        Digital_Reffer DR = new Digital_Reffer();
        
        
        Digital_Reffer.generateImageURL();
        
        
    }
}