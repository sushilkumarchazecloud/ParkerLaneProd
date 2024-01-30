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
        test.startTest();
        insert con;
        test.stopTest();
        
    }
}