@isTest
public class TestDocumentRequestedController{
    @isTest
    private static void testFetchDR(){
        Opportunity opp = new Opportunity(Name='Test', StageName='open', CloseDate= Date.today());
        insert opp;
        
        ManageDocumentController.createDocumentRequest('[{"label":"ApplicantOne","value":[{"categry":"Income","selectedItem":[{"label":"Payslips : 2 recent consecutive (no older than 6 weeks)","value":"Payslips","Discription":"","isBankStatment":false}]},{"categry":"Identification","selectedItem":[{"label":"Driver’s license (front and back)","value":"Driver’s license (front and back)","Discription":"","isBankStatment":false},{"label":"Medicare Card","value":"Medicare Card","Discription":"","isBankStatment":false}]}]},{"label":"JointApp","value":[{"categry":"Assets","selectedItem":[{"label":"Recent council rates notice","value":"Recent council rates notice","Discription":"","isBankStatment":false}]},{"categry":"Living Expenses","selectedItem":[{"label":"Last 3 months transaction bank statements","value":"Last 3 months transaction bank statements","Discription":"","isBankStatment":true}]}]}]',true, opp.Id,true);
        
        List<Document_Requested__c> drList = DocumentRequestedController.fetchDocumentRequested(opp.Id);
        System.assert(drList.size() == 5);
    }
    
    @isTest
    private static void testUpdateDR(){
        Opportunity opp = new Opportunity(Name='Test', StageName='open', CloseDate= Date.today());
        insert opp;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = Opp.id;
        cdl.ContentDocumentId = [select contentdocumentid from contentversion where id =: contentVersion.id].contentdocumentid;
        cdl.shareType = 'V';
        insert cdl;
        List<String> cv = new List<String>{cdl.ContentDocumentId};
        ManageDocumentController.createDocumentRequest('[{"label":"ApplicantOne","value":[{"categry":"Income","selectedItem":[{"label":"Payslips : 2 recent consecutive (no older than 6 weeks)","value":"Payslips","Discription":"","isBankStatment":false}]},{"categry":"Identification","selectedItem":[{"label":"Driver’s license (front and back)","value":"Driver’s license (front and back)","Discription":"","isBankStatment":false},{"label":"Medicare Card","value":"Medicare Card","Discription":"","isBankStatment":false}]}]},{"label":"JointApp","value":[{"categry":"Assets","selectedItem":[{"label":"Recent council rates notice","value":"Recent council rates notice","Discription":"","isBankStatment":false}]},{"categry":"Living Expenses","selectedItem":[{"label":"Last 3 months transaction bank statements","value":"Last 3 months transaction bank statements","Discription":"","isBankStatment":true}]}]}]',true, opp.Id,true);
        
        Document_Requested__c dr = [SELECT Id,Name,isComplete__c,Status__c,Category__c FROM Document_Requested__c WHERE Opportunity__c =: opp.Id ORDER BY Name ASC][0];
        
        DocumentRequestedController.updateDocRequested(dr.id,cv);
        Document_Requested__c dr1 = [SELECT Id,Name,isComplete__c,Status__c,Category__c FROM Document_Requested__c WHERE Id =: dr.Id ];
        ContentVersion cvId =  [select contentdocumentid, Document_Requested__c from contentversion where ContentDocumentid =: cdl.contentdocumentid];
        System.assert(dr1.isComplete__c == true);
        System.assert(dr1.Id == cvId.Document_Requested__c);
    }
    
    @isTest
    public static void mothodForDocReq(){
        contact con = new Contact(LastName = 'qwer', Email = 'test@gmail.com');
        insert con;
        Account acc = new Account(name = 'test', FinServ__PrimaryContact__c = con.Id);
        insert acc;
        opportunity opp = new  opportunity(Name='Test', StageName='open', CloseDate= Date.today(), Applicant_1__c = acc.id, contact_1__c = con.Id);
        insert opp;
        Quote Q1 = new Quote();
        Q1.Name = 'tesst';
        Q1.Application__c = true;
        Q1.OpportunityId = opp.Id;
        Q1.Loan_Term__c = 60;
        Q1.Repayment_Frequency_Options__c  = 'Monthly';
        Q1.Application__c = true;
        insert Q1;
        
        Document_Requested__c dc = new Document_Requested__c(Opportunity__c = opp.Id, isComplete__c = false, Document__c = 'test');
        insert dc;
        DocumentRequestedController.sendEmailToCust(opp.Id);
        
    }
}