@istest
public class EmploymentTriggerTest {

    static testmethod void CreateAndDeleteEmployment(){
        Test.startTest();
        Contact con = New Contact(LastName = 'Last Name');
        insert con;
        List<FinServ__Employment__c> empList = New List<FinServ__Employment__c>();
        empList.add(New FinServ__Employment__c(FinServ__Contact__c = con.Id, FinServ__EmploymentStatus__c='Other',
                                               Name = 'emp', Income_Frequency__c = 'Weekly',
                                               FinServ__AnnualIncome__c = 100)); 
        empList.add(New FinServ__Employment__c(FinServ__Contact__c = con.Id, FinServ__EmploymentStatus__c='Other',
                                               Name = 'emp', Income_Frequency__c = 'Fortnightly',
                                               FinServ__AnnualIncome__c = 100)); 
        empList.add(New FinServ__Employment__c(FinServ__Contact__c = con.Id, FinServ__EmploymentStatus__c='Other',
                                               Name = 'emp', Income_Frequency__c = 'Monthly',
                                               FinServ__AnnualIncome__c = 100)); 
        empList.add(New FinServ__Employment__c(FinServ__Contact__c = con.Id, FinServ__EmploymentStatus__c='Other',
                                               Name = 'emp', Income_Frequency__c = 'Annually',
                                               FinServ__AnnualIncome__c = 100)); 
        insert empList;
        Test.stopTest();
        Contact conResult = [SELECT ID, Other_income_p_a__c FROM Contact WHERE Id =: con.Id];
        System.assertEquals(conResult.Other_income_p_a__c, 9100, 'Value should be 9100');
        
        delete empList[0];
        conResult = [SELECT ID, Other_income_p_a__c FROM Contact WHERE Id =: con.Id];
        System.assertEquals(conResult.Other_income_p_a__c, 9100, 'Value should be 9100');
    }
}