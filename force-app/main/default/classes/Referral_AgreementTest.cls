@istest
public class Referral_AgreementTest {
    @testsetup
    static void setUpData(){
        
        Account acc= new Account(
            Name='Test Name',
            phone='1234567890',
            ABN__c = 'qwerty'
        );        
        insert acc;
        
        Contact con = New Contact(
            FirstName = 'first',
            LastName = 'last',
            phone = '1234567890',
            email = 'first@last.com',
            Position__c ='Sales',
            AccountId = acc.Id
        );
        insert con;
        
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Sign',
            VersionData = Blob.valueOf('Test Content Data'),
            PathOnClient = 'TestContent.txt',
            ContentLocation = 'S',
            Current_in_use__c = true
        ); 
        insert testContentVersion;
        
        ContentDocumentLink link = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id].ContentDocumentId,
            LinkedEntityId = con.Id,
            ShareType = 'I'
        );
        insert link;
    }
    
    static testmethod void getReferral_Agreement(){
        Contact ConData = [SELECT Id,Name,AccountId FROM Contact where email =: 'first@last.com' order by createddate DESC LIMIT 1];        
        Account accList = [SELECT Id FROM Account Where id =: ConData.AccountId];
        apexpages.currentpage().getparameters().put('id', accList.Id);
        apexpages.currentpage().getparameters().put('ConId', ConData.Id);
        Referral_Agreement rofCtrl = New Referral_Agreement();
        Referral_Agreement.generateImageURL();
    }
}