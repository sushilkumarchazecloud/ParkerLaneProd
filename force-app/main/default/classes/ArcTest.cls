/*
* @Description       : This is the test class for Arc Apex Class.
* @Author            : Sumit Mahawar
* @Created on        : 21-2-2024
* @Last Modified By  : Sumit Mahawar
* @Last Modified On  : 21-2-2024
*/
@isTest
public class ArcTest {
    
    /**
    * @description Initial data setup method
    * @author Sumit Mahawar
    * @Created on : 21-2-2024 
    **/
    @testSetup 
    static void testGetAllObject() {
        
        List<User> adminsUsers = TestDataFactory.createUsers(new Map<String,String>{'Henry' => 'System Administrator'});
        insert adminsUsers; 
        
        List<Account> accountList = TestDataFactory.createAccounts(1);
        insert accountList; 
        
        List<Contact> contactList = TestDataFactory.createContacts(1,accountList[0].id);
        insert contactList;
        
        List<Opportunity> opportunityList = TestDataFactory.createOpportunities(1,accountList[0].id);
        insert opportunityList;
    }
    
    /**
    * @description this will test the parent record
    * @author Sumit Mahawar
    * @Created on : 21-2-2024 
    **/
    @isTest
    static void testInvalidParentObjectId() {
        List<Account> accList = [SELECT Id, Name FROM Account limit 1];
        User admin = [Select Id from user where lastname = 'Henry' LIMIT 1];
        System.runAs(admin) {
            Test.startTest();
            Map<String, List<sObject>> recordsMap = Arc.getAllObject(accList[0].Id);
            Test.stopTest();
            System.assertNotEquals(null, recordsMap);
        }
    }
    
    /**
    * @description this will test the multiple child records
    * @author Sumit Mahawar
    * @Created on : 21-2-2024 
    **/
    @isTest
    static void testMultipleChildRelationships() {
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        User admin = [Select Id from user where lastname = 'Henry' LIMIT 1];
        System.runAs(admin) {
            Test.startTest();
            Map<String, List<sObject>> recordsMap = Arc.getAllObject(accList[0].Id);
            Test.stopTest();
            // Assertions for the parent record
            List<sObject> parentRecords = recordsMap.get('ParentRecord');
            System.assertEquals(1, parentRecords.size(), 'Should have one parent record');
            Account returnedAccount = (Account)parentRecords[0];
            System.assertEquals(accList[0].Name, returnedAccount.Name, 'Parent record name should match');
            // Assertions for child records (Contacts)
            List<Contact> conList = [SELECT Id, FirstName, LastName, AccountId FROM Contact WHERE accountId =: accList[0].Id];
            List<sObject> contactRecords = recordsMap.get('Contacts');
            System.assertEquals(1, contactRecords.size(), 'Should have one contact record');
            Contact returnedContact = (Contact)contactRecords[0];
            System.assertEquals(conList[0].FirstName, returnedContact.FirstName, 'Contact first name should match');
            // Assertions for child records (Opportunity)
            List<Opportunity> oppList = [SELECT Id, Name, AccountId FROM Opportunity WHERE accountId =: accList[0].Id];
            List<sObject> opportunityRecords = recordsMap.get('Opportunities');
            System.assertEquals(1, opportunityRecords.size(), 'Should have one opportunity record');
            Opportunity returnedOpportunity = (Opportunity)opportunityRecords[0];
            System.assertEquals(oppList[0].Name, returnedOpportunity.Name, 'Opportunity name should match');
        }
    }
}