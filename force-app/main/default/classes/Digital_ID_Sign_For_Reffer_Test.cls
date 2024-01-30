@isTest
public class Digital_ID_Sign_For_Reffer_Test {
    @isTest
    public static void TestForDigital(){
        
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referrer (Business)').getRecordTypeId();        
        
        contact con = new contact();
        con.firstname = 'qwert';
        con.lastName = 'testing';
        con.Email = 'tazeem.khan@chazecloud.com';
        insert con;
        
        Account Accnew = new Account();
        Accnew.Name = 'testing';
        Accnew.RecordTypeId = accRTId;
        insert Accnew;
        
        Test.setCurrentPageReference(new PageReference('Page.Digital_ID_Sign')); 
        System.currentPageReference().getParameters().put('id', Accnew.id);
        System.currentPageReference().getParameters().put('conId', con.id);
        System.currentPageReference().getParameters().put('SecureCode', '12345');
        
        
        
        VOI_Status__c voiS = new VOI_Status__c();
        voiS.link_Expire_code__c = '12345';
        voiS.Contact__c = con.Id;
        insert voiS;
        
        
         
        Digital_ID_Sign_For_Reffer.securecode();
        Digital_ID_Sign_For_Reffer.VOIDetailID();
        
        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
        
        
        PageReference pageRef = Page.DIgitalSignReferrer; // Add your VF page Name here
        pageRef.getParameters().put('imageDeta', String.valueOf(cv.Id));
        pageRef.getParameters().put('sign1', String.valueOf(cv.Id));
        pageRef.getParameters().put('videoData', String.valueOf(cv.Id));
        Test.setCurrentPage(pageRef);
        
        Digital_ID_Sign_For_Reffer.ImageDataforClass();
        
        Digital_ID_Sign_For_Reffer.Sign1DataforClass();
        Digital_ID_Sign_For_Reffer.videoDataforClass();
        Digital_ID_Sign_For_Reffer.generateLog();
        
        
        
        VOI_Detail__c obj  = new VOI_Detail__c();
        obj.Secure_Code_Orignal__c = '1234';
        obj.Contact__c = con.Id;
        insert obj;
        
        Digital_ID_Sign_For_Reffer.FetchContact(obj.id);
        Digital_ID_Sign_For_Reffer.sendImageDataToComponent(obj.id);
        
        contact cont = new contact();
        cont.LastName = 'testing';
        cont.AccountId = Accnew.id;
        cont.Birthdate = system.today();
        cont.Government_ID__c = 'card';
        cont.Govt_Id_Number__c = '32417239';
        cont.FinServ__Gender__c = 'male';
        cont.Residential_Address__c = 'testing';
        insert cont;
        
        
        Digital_ID_Sign_For_Reffer.UpdateOppCon(cont);
        
        Digital_ID_Sign_For_Reffer.insertPdf();
        
        Digital_ID_Sign_For_Reffer obj54 = new Digital_ID_Sign_For_Reffer();
        Digital_ID_Sign_For_Reffer.sendEmail();
        
    }
}