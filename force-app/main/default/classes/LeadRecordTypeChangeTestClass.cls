@isTest
public class LeadRecordTypeChangeTestClass {
	static testMethod void recordTypeTest() {
        
        String recTypName = 'Home Loan General';
        RecordType recordTypeObj = [SELECT Id,Name FROM RecordType WHERE Name = :recTypName];
        
        Lead leadObj = New Lead();
        
        leadObj.LastName = 'Raghaw Test Class';
        leadObj.LeadSource = 'outgrow';
        leadObj.RecordTypeId = '0120o000001lPRyAAM';
        
        Test.startTest();    // Starts the scope of test
      	Insert leadObj;
      	Test.stopTest();
        
        List<Lead> insertedLead = [SELECT Id,LastName,LeadSource,RecordTypeId FROM Lead WHERE LastName =: leadObj.LastName AND RecordTypeId = :recordTypeObj.Id ];    
        system.assertEquals(1,insertedLead.size());
        
   }
}