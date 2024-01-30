@istest
public class HLHCOpportunityControllerTest {
    
    @testsetup
    static void setUpData(){
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String recordHTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Household').getRecordTypeId();
        List<Account> accList= new List<Account>();
        Account acc= new Account(
            RecordTypeID=recordHTypeId ,
            Name='Test Name'
        );
        accList.add(acc);
        
        Account accPerson= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test Person',
            LastName='Test LName',
            PersonEmail='test@yahoo.com',
            Is_Sync_with_Household__c=false,
            Relationship_with_Applicant_1__c='Client'
        );
        accList.add(accPerson);
        
        Account accPerson2= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test Person2',
            LastName='Test LName',
            Phone ='1234567890',
            PersonEmail='test@yahoo.com',
            Is_Sync_with_Household__c=false,
            Relationship_with_Applicant_1__c='Spouse'
        );
        accList.add(accPerson2);
        
        insert accList;
        
        Map<Id,Account> mapAccounts = New Map<Id,Account>([SELECT Id, PersonContactId FROM Account WHERE Id IN: accList]);
        
        Opportunity oppty = new Opportunity ();
        oppty.applicant_1__c = accPerson.Id;
        oppty.applicant_2__c = accPerson2.Id;
        oppty.Contact_1__c = mapAccounts.get(accPerson.Id).PersonContactId;
        oppty.Contact_2__c = mapAccounts.get(accPerson2.Id).PersonContactId;
        oppty.AccountId = acc.Id;
        oppty.name = 'test Oppty';
        oppty.StageName='Assessment Needed'; 
        oppty.CloseDate = Date.today();
        oppty.Application_Sections__c ='Own and Owe'; 
        oppty.Current_Application_Sections__c ='Who is applying';
        oppty.Relationship_to_Applicant_2__c = 'Spouse';
        oppty.Confirm_Settlement_Date__c = true;
        insert oppty;        
    }
    static testmethod void createNewOpportunityTest(){
        Test.startTest();
            Opportunity opp = [SELECT Id ,Application_Sections__c, Current_Application_Sections__c 
                               FROM Opportunity WHERE Name ='test Oppty' Limit 1];
            
            Id oppId = HLHCOpportunityController.Save(opp.Id, 'Commercial Property Purchase', 'Sold', UserInfo.getUserId());
        Test.stopTest();
        Opportunity oppHL = [SELECT Id, Name FROM Opportunity WHERE Id =: oppId Limit 1];
        System.assertEquals('Test Person and Test Person2 Test LName, Commercial Property Purchase', oppHL.Name, 'value should be Same');
        
    }
}