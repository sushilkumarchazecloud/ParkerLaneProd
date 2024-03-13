/*
* @Description       : This is the test class for ConvertLead Apex Class.
* @Author            : Sumit Mahawar
* @Created on        : 22-02-2024
* @Last Modified By  : Sumit Mahawar
* @Last Modified On  : 22-02-2024
*/
@isTest
public class ConvertLeadTest {
    
    /**
    * @description Initial data setup method
    * @author Sumit Mahawar
    * @Created on : 22-02-2024
    **/
    @testSetup
    static void convertLeadCreatingData(){
        
        List<User> adminsUsers = TestDataFactory.createUsers(new Map<String,String>{'Henry' => 'System Administrator'});
        insert adminsUsers;
        
        List<Lead> leadList = TestDataFactory.createLeads(2);
        insert leadList;
        
        List<Account> accountList = TestDataFactory.createAccounts(1);
        insert accountList; 
        
        List<Contact> contactList = TestDataFactory.createContacts(1,accountList[0].id);
        insert contactList;
        
        List<Opportunity> opportunityList = TestDataFactory.createOpportunities(1,accountList[0].id);
        insert opportunityList;
    }
    
    /**
    * @description check the getLead method query
    * @author Sumit Mahawar
    * @Created on : 22-02-2024
    **/
    @isTest
    static void getLeadTesting(){
        List<Lead> leList = [SELECT Id, FirstName, LastName, Company, Status FROM Lead LIMIT 1];         
        User admin = [Select Id from user where lastname = 'Henry' LIMIT 1];
        System.runAs(admin) {
            Test.startTest();
            List<Lead> checkLead = ConvertLead.getLead(leList[0].Id);
            Test.stopTest();
            System.assertNotEquals(null, checkLead);   
        }
    }
    
    /**
    * @description check the findAccRelatedOpp method query
    * @author Sumit Mahawar
    * @Created on : 22-02-2024
    **/
    @isTest
    static void findAccRelatedOppTesting(){   
        List<Account> accList = [SELECT Id, Name, Industry, AnnualRevenue FROM Account LIMIT 1];
        List<Opportunity> oppList = [SELECT Id, Name, CloseDate, StageName, AccountId FROM Opportunity WHERE accountId =: accList[0].Id LIMIT 1];
        User admin = [Select Id from user where lastname = 'Henry' LIMIT 1];
        System.runAs(admin) {
            Test.startTest();
            List<Opportunity> checkOpp = ConvertLead.findAccRelatedOpp(opplist[0].id);
            Test.stopTest();
            System.assertNotEquals(null, checkOpp);
        }	
    }
    
    /**
    * @description convert the lead into insert new records of Account, Contact and Opportunity
    * @author Sumit Mahawar
    * @Created on : 22-02-2024
    **/
    @isTest
    static void convertLeadInsertTesting(){
        List<Lead> leList = [SELECT Id, FirstName, LastName, Company, Status FROM Lead LIMIT 1]; 
        User admin = [Select Id from user where lastname = 'Henry' LIMIT 1];
        System.runAs(admin) {
            String leadId = leList[0].Id;
            String leadOwnerId = UserInfo.getUserId();
            String accNewName = 'New Test Account';
            String accExistingId = null;
            String conNewSalutation = 'Dr.';
            String conNewFirstName = 'Jim';
            String conNewLastName = 'Smith';
            String conExistingId = null;
            Boolean conExistingCheckBox = false;
            String oppNewName = 'New Test Opportunity';
            Boolean oppNewCheckBox = false;
            String oppExistingId = null;
            Test.startTest();
            ConvertLead.convertLead(
                leadId, leadOwnerId,
                accNewName, accExistingId,
                conNewSalutation, conNewFirstName, conNewLastName,
                conExistingId, conExistingCheckBox,
                oppNewName, oppNewCheckBox, oppExistingId
            );
            Test.stopTest();
            Lead convertedLead = [SELECT Id, IsConverted FROM Lead WHERE Id =: leList[0].Id LIMIT 1];
            System.assertNotEquals(null, convertedLead.IsConverted, 'Lead should be converted into new records');
        }
    }
    
    /**
    * @description convert the lead into update existing records of Account, Contact and Opportunity
    * @author Sumit Mahawar
    * @Created on : 23-02-2024
    **/
    @isTest
    static void convertLeadUpdateTesting(){
        
        List<Lead> leList = [SELECT Id, FirstName, LastName, Company, Status FROM Lead LIMIT 1];    
        List<Account> accList = [SELECT Id, Name, Industry, AnnualRevenue FROM Account LIMIT 1];
        List<Contact> conList = [SELECT Id, Salutation, FirstName, LastName, AccountId FROM Contact WHERE accountId =: accList[0].Id LIMIT 1];
        List<Opportunity> oppList = [SELECT Id, Name, CloseDate, StageName, AccountId FROM Opportunity WHERE accountId =: accList[0].Id LIMIT 1];
        
        User admin = [Select Id from user where lastname = 'Henry' LIMIT 1];
        System.runAs(admin) {
            String leadId = leList[0].Id;
            String leadOwnerId = UserInfo.getUserId();
            String accNewName = null;
            String accExistingId = accList[0].Id;
            String conNewSalutation = null;
            String conNewFirstName = null;
            String conNewLastName = null;
            String conExistingId = conList[0].Id;
            Boolean conExistingCheckBox = false;
            String oppNewName = null;
            Boolean oppNewCheckBox = false;
            String oppExistingId = oppList[0].Id;
            
            Test.startTest();
            ConvertLead.convertLead(
                leadId, leadOwnerId,
                accNewName, accExistingId,
                conNewSalutation, conNewFirstName, conNewLastName,
                conExistingId, conExistingCheckBox,
                oppNewName, oppNewCheckBox, oppExistingId
            );
            Test.stopTest();
            
            Lead convertedLead = [SELECT Id, IsConverted FROM Lead WHERE Id =: leList[0].Id LIMIT 1];
            System.assertEquals(true, convertedLead.IsConverted, 'Lead should be converted into existing records');            
        }
    }
    
    /**
    * @description convert the lead into update existing records of Account, Contact and Opportunity with check box value true for Contact and Opportunity
    * @author Sumit Mahawar
    * @Created on : 23-02-2024
    **/
    @isTest
    static void convertLeadUpdateTestinCheckBox(){        
        List<Lead> leList = [SELECT Id, FirstName, LastName, Company, Status FROM Lead LIMIT 1];    
        List<Account> accList = [SELECT Id, Name, Industry, AnnualRevenue FROM Account LIMIT 1];
        List<Contact> conList = [SELECT Id, Salutation, FirstName, LastName, AccountId FROM Contact WHERE accountId =: accList[0].Id LIMIT 1];
        List<Opportunity> oppList = [SELECT Id, Name, CloseDate, StageName, AccountId FROM Opportunity WHERE accountId =: accList[0].Id LIMIT 1];
        User admin = [Select Id from user where lastname = 'Henry' LIMIT 1];
        System.runAs(admin) {
            String leadId = leList[0].Id;
            String leadOwnerId = UserInfo.getUserId();
            String accNewName = null;
            String accExistingId = accList[0].Id;
            String conNewSalutation = null;
            String conNewFirstName = null;
            String conNewLastName = null;
            String conExistingId = conList[0].Id;
            Boolean conExistingCheckBox = true;
            String oppNewName = null;
            Boolean oppNewCheckBox = true;
            String oppExistingId = oppList[0].Id;
            Test.startTest();
            ConvertLead.convertLead(
                leadId, leadOwnerId,
                accNewName, accExistingId,
                conNewSalutation, conNewFirstName, conNewLastName,
                conExistingId, conExistingCheckBox,
                oppNewName, oppNewCheckBox, oppExistingId
            );
            Test.stopTest();
            Lead convertedLead = [SELECT Id, IsConverted FROM Lead WHERE Id =: leList[0].Id LIMIT 1];
            System.assertEquals(true, convertedLead.IsConverted, 'Lead should be converted into existing records wihth checkbox is true in contact and opportunity');            
        }
    }
}