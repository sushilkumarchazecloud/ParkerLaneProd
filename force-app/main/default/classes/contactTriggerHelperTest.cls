@isTest
public class contactTriggerHelperTest {
    
    @istest
    private static void testContactTrigger(){  
        
        Account acc = new Account(); 
        acc.Name ='Test';
        acc.On_Board_Referral__c = true;
        insert acc;
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referrer').getRecordTypeId(); 
        Contact con = new contact(); 
        con.AccountId = acc.Id;
        con.recordTypeId  = recordTypeId;
        con.lastName = 'Test';
        con.Email ='rdxrakesh345@gmail.com';
        con.Referrer_Status__c = 'Active';
        con.Referrer_Rating__c = 'Gold';
        test.startTest();
        insert con;
        test.stopTest();
        Contact cont = [select id,Referrer_Status__c,Referrer_Rating__c from contact LIMIT 1];
        cont.Referrer_Rating__c = 'Silver';
        cont.Referrer_Status__c = 'Current';
        update cont;
    }
}