@isTest
public class EzeeAPIWithDocTest {

    @isTest
    public static void methodOne(){
        opportunity op1 = new Opportunity()	;
        op1.Name = 'testing';
        op1.Preferred_repayment_frequency__c = 'Monthly';  
        op1.Loan_Amount__c = 560;
        op1.StageName = 'Working';
        op1.Lender_Application_ID__c = '12345678dgy4567';
        op1.Application_Supporting_Notes__c = 'hello';
        op1.CloseDate = System.today();
        insert op1;      
        
        
        EzeeAPIWithDOc.makeCallout(op1.Id);
        
        Document_Requested__c dc1 = new Document_Requested__c();
        dc1.Category__c = 'Credit Report';
        dc1.Opportunity__c = op1.Id;
      	insert dc1;  
        
        
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        
        ContentVersion cvv=new Contentversion();
        cvv.title='text';
        cvv.PathOnClient ='text.png';
        cvv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cvv.IsMajorVersion = false;
        cvv.Document_Requested__c = dc1.id;
        cvv.Send_to_Lender__c = true;
       	insert cvv;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LImit 5];
        
        System.debug('documents_+'+documents);
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        
        cdl.LinkedEntityId = op1.id;
        
        cdl.ContentDocumentId = documents[0].Id;
        
        cdl.shareType = 'V';
        
        Insert cdl;        

        EzeeAPIWithDoc.uploadDocu(op1.Id);
    }
    
    @isTest
    public static void methodTwo(){
        opportunity op1 = new Opportunity()	;
        op1.Name = 'testing';
        op1.Preferred_repayment_frequency__c = 'Monthly';  
        op1.Loan_Amount__c = 560;
        op1.StageName = 'Working';
        op1.Lender_Application_ID__c = '12345678dgy4567';
        op1.Application_Supporting_Notes__c = 'hello';
        op1.CloseDate = System.today();
        insert op1;      
        
        
        
        Document_Requested__c dc1 = new Document_Requested__c();
        dc1.Category__c = 'Identification';
        dc1.Opportunity__c = op1.Id;
      	insert dc1;  
        
        
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        
        ContentVersion cvv=new Contentversion();
        cvv.title='text';
        cvv.PathOnClient ='text.png';
        cvv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cvv.IsMajorVersion = false;
        cvv.Document_Requested__c = dc1.id;
        cvv.Send_to_Lender__c = true;
       	insert cvv;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LImit 5];
        
        System.debug('documents_+'+documents);
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        
        cdl.LinkedEntityId = op1.id;
        
        cdl.ContentDocumentId = documents[0].Id;
        
        cdl.shareType = 'V';
        
        Insert cdl;        

        EzeeAPIWithDoc.uploadDocu(op1.Id);
    }
    
    
    @isTest
    public static void methodThree(){
        opportunity op1 = new Opportunity()	;
        op1.Name = 'testing';
        op1.Preferred_repayment_frequency__c = 'Monthly';  
        op1.Loan_Amount__c = 560;
        op1.StageName = 'Working';
        op1.Lender_Application_ID__c = '12345678dgy4567';
        op1.Application_Supporting_Notes__c = 'hello';
        op1.CloseDate = System.today();
        insert op1;      
        
        contact con = new Contact();
        con.FirstName = 'test';
        con.LastName = 'test';
        insert con;
        
        try{
        	EzeeAPIWithDOc.makeCallout(con.Id);    
        }Catch(Exception ex){
            System.debug('mesage '+ex.getMessage());
        }
        
        
        Document_Requested__c dc1 = new Document_Requested__c();
        dc1.Category__c = 'Assets';
        dc1.Opportunity__c = op1.Id;
      	insert dc1;  
        
        
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        
        ContentVersion cvv=new Contentversion();
        cvv.title='text';
        cvv.PathOnClient ='text.png';
        cvv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cvv.IsMajorVersion = false;
        cvv.Document_Requested__c = dc1.id;
        cvv.Send_to_Lender__c = true;
       	insert cvv;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LImit 5];
        
        System.debug('documents_+'+documents);
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        
        cdl.LinkedEntityId = op1.id;
        
        cdl.ContentDocumentId = documents[0].Id;
        
        cdl.shareType = 'V';
        
        Insert cdl;        

        EzeeAPIWithDoc.uploadDocu(op1.Id);
    }
    
    
}