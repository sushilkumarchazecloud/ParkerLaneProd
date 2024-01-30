@isTest
public class CustomRelatedRecordControllerTest {
    
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
        
        Opportunity oppty = new Opportunity ();
        oppty.applicant_1__c = accPerson.Id;
        oppty.applicant_2__c = accPerson2.Id;
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
    
    static testmethod void getParentIdTest(){
        Opportunity opp = [SELECT Id,applicant_1__c FROM Opportunity WHERE Name ='test Oppty' Limit 1];
        
        String pId = CustomRelatedRecordController.getParentId(opp.Id, 'applicant_1__c', 'FS_Related_Record');
        pId = CustomRelatedRecordController.getParentId(opp.Id, 'self lookup', 'Acknowledgments');
            
    }
    
    static testmethod void fetchRecsTest(){
        Opportunity opp = [SELECT Id,applicant_1__c FROM Opportunity WHERE Name ='test Oppty' Limit 1];
        Account acc = [SELECT Id, (SELECT Id FROM Opportunities__r) FROM Account WHERE Id =: opp.applicant_1__c]; 
        System.debug('acc' + acc);
        System.debug('opp' + acc.Opportunities__r);
        CustomRelatedRecordController.RelatedListResult pId = CustomRelatedRecordController.fetchRecs(opp.Id, 'Opportunity', 'applicant_1__c', 'Acknowledgments', 'Opportunities__r');
            
        
    }

}