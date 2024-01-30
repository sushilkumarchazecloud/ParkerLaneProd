@isTest
public class CustomNotificationFromApexTest {
	@testSetup
    public static void testdata(){
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
            FirstName='Test Person',
            LastName='Test LName',
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
            Relationship_with_Applicant_1__c='Client',
            PersonTitle = 'Mr.',
            Phone = '0400000000',
            Security_Question__pc = 'Mothers maiden name',
            Security_Answer__pc = 'qwerty',
            Rental_Amount__pc = 500,
            Rental_or_Board_paid__pc =  50,
            Education_ChildCare_SchoolFees_Uniform__pc = 12,
            Maintenance_If_pay_child_maintenance__pc =  25,
            Other_loans_and_or_debt_commitments__pc = 24,
            Education_public_and_private__pc  = 10,
            Food_Groceries_Meat_Fruit_Vegetabl__pc = 100,
            Living_Situation__pc = 'Renting',
            Citizenship_Status__pc = 'Australian Citizen',
            FinServ__Gender__pc = 'Male',
            Transport_Public_Petrol_Registration__pc = 100,
            Medical_Private_Health_Insurance_Ong__pc = 100,
            Personal_Insurances_life_and_income_pro__pc = 100,
            Insurances_Home_Personal_Voluntary__pc = 100,
            Utilities__pc = 100,
            Driver_s_licence_state_Territory__pc = 'Queensland',
            Connections_Phone_Mobile_Internet_C__pc = 200,
            FinServ__NumberOfChildren__pc = 3
        );
        
        Account acc2Person= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test Person',
            LastName='Test LName',
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
            Relationship_with_Applicant_1__c='Client',
            PersonTitle = 'Mr.',
            Phone = '0400000000',
            Security_Question__pc = 'Mothers maiden name',
            Security_Answer__pc = 'qwerty',
            Rental_Amount__pc = 500,
            Rental_or_Board_paid__pc =  50,
            Education_ChildCare_SchoolFees_Uniform__pc = 12,
            Maintenance_If_pay_child_maintenance__pc =  25,
            Other_loans_and_or_debt_commitments__pc = 24,
            Education_public_and_private__pc  = 10,
            Food_Groceries_Meat_Fruit_Vegetabl__pc = 100,
            Living_Situation__pc = 'Renting',
            Citizenship_Status__pc = 'Australian Citizen',
            FinServ__Gender__pc = 'Male',
            Transport_Public_Petrol_Registration__pc = 100,
            Medical_Private_Health_Insurance_Ong__pc = 100,
            Personal_Insurances_life_and_income_pro__pc = 100,
            Insurances_Home_Personal_Voluntary__pc = 100,
            Utilities__pc = 100,
            Driver_s_licence_state_Territory__pc = 'Queensland',
            Connections_Phone_Mobile_Internet_C__pc = 200,
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
        
        
        opportunity op1 = new Opportunity()	;
        op1.Name = 'testing';
        op1.AccountId = acc.Id;
        op1.Applicant_1__c = accPerson.Id;
        op1.Applicant_2__c = acc2Person.Id;
        op1.Preferred_repayment_frequency__c = 'Monthly';  
        op1.Loan_Amount__c = 560;
        op1.StageName = 'CPA Started';
        op1.Application_Supporting_Notes__c = 'hello';
        op1.CloseDate = System.today();
        insert op1;
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id
                        ); 
        
        
        insert uu;
    }
    
    @isTest
    public static void firstAttamp(){
        List<opportunity> opp = [select id, name, stageName from opportunity where name = 'testing'];
        List<id> csUser = new List<id>();
        for(user u : [select id from user where firstname = 'ABC']){
            csUser.add(u.id);
        }
        
        test.startTest();
        CustomNotificationFromApex.notifyUsers(opp, csUser, 'test notification', 'notification data body');
        test.stopTest();
        
    }    
}