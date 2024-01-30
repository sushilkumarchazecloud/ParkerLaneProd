@istest
public class ReferrerOnboardingFormControllerTest {
	@testsetup
    static void setUpData(){
       
        Account acc= new Account(
            Name='Test Name',
            phone='1234567890',
            ABN__c = 'qwerty'
        );
        
        insert acc;
        
        Contact con = New Contact(
            FirstName = 'first',
            LastName = 'last',
            phone = '1234567890',
            email = 'first@last.com',
            Position__c ='Sales',
            AccountId = acc.Id
        );
        insert con;
    }
    
    static testmethod void getReferrerOnboardingFormTest(){
        Account accList = [SELECT Id FROM Account Where Name = 'Test Name'];
        apexpages.currentpage().getparameters().put('id', accList.Id);
        ReferrerOnboardingFormController rofCtrl = New ReferrerOnboardingFormController();
        
        System.assertEquals(rofCtrl.acc.Id, accList.Id, 'value should be same');
    }
    
    static testmethod void getSaveReferrer(){
        Account acc= new Account(
            Name='Test Name',
            phone='1234567890',
            ABN__c = 'qwerty'
        );
        
        Contact con = New Contact(
            FirstName = 'first',
            LastName = 'last',
            phone = '1234567890',
            email = 'first@last.com',
            Position__c ='Sales'
        );
        Account accResult = ReferrerOnboardingFormController.saveReferrer(acc, con);
        System.assertEquals(accResult.Contacts.size(), 1, 'value should be same');
    }
    
    static testmethod void getSubmitReferrer(){
        Account acctr= new Account(
            Name='Test Name',
            phone='1234567890',
            ABN__c = 'qwerty'
        );
        Contact con = New Contact(
			Account = acctr,
            FirstName = 'first',
            LastName = 'last',
            phone = '1234567890',
            email = 'first@last.com',
            Position__c ='Sales'
        );
        
		Account acc = [SELECT Id, Name, ABN__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Company_Legal_Name__c,
                   Referrer_Business_Type__c, Other_Business_Type_Description__c, Is_Find_Billing_Address__c, Website, Are_you_Clean_Energy_Council_Accredited__c,
                   Listing_URL__c,How_many_new_sales_appointments_per_week__c,How_do_you_conduct_your_appointment__c, Anticipate_intro_finance_to_customer__c,
                   General_Business_Description__c, Unique_Value_Proposition_1__c, Unique_Value_Proposition_2__c, Unique_Value_Proposition_3__c,
                   Key_Accreditations_1__c, Key_Accreditations_2__c, Key_Accreditations_3__c,
                   (SELECT Id, FirstName, LastName, Email, Phone, Position__c FROM Contacts)
                   FROM Account WHERE Name ='Test Name'];
        Account accResult = ReferrerOnboardingFormController.submitReferrer(acc, acc.Contacts, false);
        ReferrerOnboardingFormController.createEnvelope(acc.Id);
    }
}