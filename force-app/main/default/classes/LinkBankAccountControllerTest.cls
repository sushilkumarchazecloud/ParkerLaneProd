@isTest
public class LinkBankAccountControllerTest{
    
    
    @isTest
    public static void testBankAccount(){
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
        
        insert accList;
        
        Account accChild= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test Child',
            LastName='Test LName',
            PersonEmail='test@yahoo.com',
            Is_Sync_with_Household__c=false,
            Relationship_with_Applicant_1__c='Dependent',
            Dependent_Parent__c = accPerson.Id
        );
        
        insert accChild;
        
        
        
        Opportunity oppty = new Opportunity ();
        oppty.applicant_1__c = accPerson.Id;
        oppty.AccountId = acc.Id;
        oppty.name = 'test Oppty';
        oppty.StageName='Assessment Needed'; 
        oppty.CloseDate = Date.today();
        oppty.Application_Sections__c ='Own and Owe'; 
        oppty.Current_Application_Sections__c ='Who is applying';
        oppty.Relationship_to_Applicant_2__c = 'Spouse';
        insert oppty;
        
        Opportunity oppUpdate = [SELECT Id, Applicant_1__r.PersonContactId FROM Opportunity WHERE Id =: oppty.Id];
        System.debug('>>>>>>oppUpdate.Applicant_1__r.PersonContactId;' + oppUpdate.Applicant_1__r.PersonContactId);
        FinServ__Employment__c emp1 =New FinServ__Employment__c();
        emp1.Name = 'test';
        emp1.FinServ__EmploymentStatus__c = 'Part time permanent';
        emp1.FinServ__Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        emp1.Is_Primary__c = true;
        insert emp1;
        
        /*
        Map<String, Contact> conEmpMap = ParkerLaneLoanController.getEmploymentDetails(oppty.Id);
        ParkerLaneLoanController.upsertEmploymentDetails(conEmpMap.get('applicant1'), conEmpMap.get('applicant2'), new List<FinServ__Employment__c>{new FinServ__Employment__c(Name = 'emp1',Is_Primary__c=true)}, new List<FinServ__Employment__c>{new FinServ__Employment__c(Name = 'emp1',Is_Primary__c=true)}, oppty.Id, true, true);
        */
        LinkBankAccountController.makeMOGORequest(oppty.Id);
        
    }
    
}