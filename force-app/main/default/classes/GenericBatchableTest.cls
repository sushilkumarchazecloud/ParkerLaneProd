@isTest
public class GenericBatchableTest {
	@testsetup
    static void setUpData(){
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String recordHTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Household').getRecordTypeId();
        String oppRecordTypeId  = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Home Loan Refinance').getRecordTypeId();
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
        oppty.FinServ__Household__c  = acc.Id;
        oppty.name = 'test Oppty';
        oppty.StageName='Assessment Needed'; 
        oppty.CloseDate = Date.today();
        oppty.Application_Sections__c ='Own and Owe'; 
        oppty.Current_Application_Sections__c ='Who is applying';
        oppty.Relationship_to_Applicant_2__c = 'Spouse';
        oppty.Confirm_Settlement_Date__c = true;
        oppty.RecordTypeId = oppRecordTypeId;
        insert oppty;
    }
    
    static testmethod void exeBatch(){
        GenericBatchable gb = New GenericBatchable();
        gb.queryStr = 'Select Id, Owner.IsActive, OwnerId, Applicant_1__c, Applicant_2__c,FinServ__Household__c, AccountId from opportunity where  ';  
        gb.queryStr += ' RecordType.Name in (\'Commercial Mortgage\',\'Commercial Property Purchase\',\'First Home Purchase\',\'Home Loan Construction\',\'Home Loan Purchase\',\'Home Loan Refinance\',\'Next Home Purchase\') ' ;
        gb.queryStr +=' ORDER BY Applicant_1__r.Name, LastModifiedDate desc';
        
        database.executeBatch(gb);
    }
}