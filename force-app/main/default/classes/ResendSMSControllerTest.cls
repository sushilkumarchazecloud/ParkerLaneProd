@isTest
public class ResendSMSControllerTest {

    @isTest 
    public static void tesrMethod(){
       String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String recordHTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Household').getRecordTypeId();
        List<Account> accList= new List<Account>();
        Account acc= new Account(
            RecordTypeID=recordHTypeId ,
            Name='Test Name'
        );
        accList.add(acc);
        
        System.debug('acc id +++'+acc.Id);
        Account accPerson= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test',
            LastName='Person',
            PersonEmail='test@yahoo.com',
            PersonBirthdate = system.today(),
            Is_Sync_with_Household__c=false,
            Does_your_spouse_earn_an_income__pc = 'Yes',
            spouse_s_approximate_annual_income__pc = 2000,
            FinServ__MaritalStatus__pc = 'Married / Defacto (to applicant 2)',
            Year__pc = '1',            
            Months__pc = '1',
            Year_1__pc = '1',
            Months_1__pc = '1',
            FinServ__NumberOfChildren__pc = 3
        );
        
        Account acc2Person= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test',
            LastName='Test',
            PersonEmail='test@yahoo.com',
            PersonBirthdate = system.today(),
            FinServ__NumberOfChildren__pc = 3
        );
        
        accList.add(accPerson);
        accList.add(acc2Person);
        insert accList;
        
        Account accChild1= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test Child',
            LastName='Test LName',
            PersonEmail='test@yahoo.com',
            Is_Sync_with_Household__c=false,
            Child_Age__pc = '1 Year',
            Relationship_with_Applicant_1__c='Dependent',
            Dependent_Parent__c = accPerson.Id
        );
        
        insert accChild1;
        
        Account Ac = [Select Id,PersonContactId from Account Where Id =: accPerson.Id];
        
        System.debug('acid'+Ac.PersonContactId);
        opportunity op1 = new Opportunity()	;
        op1.Name = 'testing';
        op1.AccountId = acc.Id;
        op1.Applicant_1__c = accPerson.Id;
        op1.Applicant_2__c = acc2Person.Id;
        //op1.Contact_1__c = Ac.PersonContactId;
        //op1.Contact_2__c = accPerson.Id;    
        op1.Preferred_repayment_frequency__c = 'Monthly';  
        op1.Loan_Amount__c = 560;
        op1.StageName = 'Working';
        op1.Application_Supporting_Notes__c = 'hello';
        op1.CloseDate = System.today();
        insert op1;
        
        ResendSMSController.fetchContacts(op1.id);
        ResendSMSController.fetchPhone(op1.id, 'Test Person');
        ResendSMSController.resendSMS('qwert', op1.id, 'Test Person', 'FULL', 'Email only');
        ResendSMSController.getVoiStatus(string.valueOf(op1.Id), 'Test Person');
        
            
    }
    
    @isTest 
    public static void testMethod2(){
        Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referrer (Business)').getRecordTypeId();        
        
        Account Accnew = new Account();
        Accnew.Name = 'testing';
        Accnew.RecordTypeId = accRTId;
        insert Accnew;
        
        contact con = new contact();
        con.AccountId = Accnew.id;
        con.firstname = 'qwert';
        con.lastName = 'testing';
        con.Email = 'tazeem.khan@chazecloud.com';
        con.Is_Authorised_Signatory__c = true;
        insert con;
        
        
        voi_status__c temp = new  voi_status__c();
        temp.Contact__c = con.id;
        temp.Case_Status__c = 'Sent';
        insert temp;
        
        ResendSMSController.fetchAccount(Accnew.Id);
        
        ResendSMSController.sendSmsFromReferrer(Accnew.Id, 'test', '1234567890');       
        
       
    }

}