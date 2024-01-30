@isTest
public class bankStatementServiceTest {
    
    @istest
    public static void EmailService(){
        Opportunity opp = new Opportunity(Name='Test', StageName='open', CloseDate= Date.today(), RecordTypeId = '0120o000001lPS9AAM');
        Insert opp;
       
		Document_Requested__c Dc = new Document_Requested__c(Opportunity__c = opp.id, isComplete__c = false,Document__c='Test',Category__c='Bank Statements');
        insert Dc;
        
        Document_Requested__c doc = [select id,Category__c,is_bank_fail__c, isComplete__c,Document__c from Document_Requested__c where Opportunity__r.id =:opp.id ];
        SYstem.debug('doc__+_+'+doc.Category__c);
        
        Messaging.InboundEmail testEmail = new Messaging.InboundEmail();
        testEmail.subject = 'Test Subject-' + opp.Id;
        testEmail.htmlBody = '<p>Test Body</p>';
        Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();
        textAttachment.fileName = 'test_file.txt';
        textAttachment.body ='Test Text Attachment';
        testEmail.textAttachments = new List<Messaging.InboundEmail.TextAttachment>{textAttachment};
            Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.fileName = 'test_file.json';
        binaryAttachment.body = Blob.valueOf('{"test": "Test JSON Attachment"}');
        testEmail.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>{binaryAttachment};
            
            test.startTest();
        bankStatementService service = new bankStatementService();
        Messaging.InboundEmailResult result = service.handleInboundEmail(testEmail, null);     
        test.stopTest();
    }
    
    @istest
    public static void EmailServiceAnother(){
        Messaging.InboundEmail testEmail = new Messaging.InboundEmail();
        testEmail.subject = 'Test Subject';
        testEmail.htmlBody = '<p>Test Body</p>';
        Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();
        textAttachment.fileName = 'test_file.txt';
        textAttachment.body ='Test Text Attachment';
        testEmail.textAttachments = new List<Messaging.InboundEmail.TextAttachment>{textAttachment};
            Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.fileName = 'test_file.json';
        binaryAttachment.body = Blob.valueOf('{"test": "Test JSON Attachment"}');
        testEmail.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>{binaryAttachment};
            
            test.startTest();
        bankStatementService service = new bankStatementService();
        Messaging.InboundEmailResult result = service.handleInboundEmail(testEmail, null);     
        test.stopTest();
    }
}