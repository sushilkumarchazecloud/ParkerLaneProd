@isTest(seeAllData=true)
private class AutoNumberTest {

  private static testMethod void testAutoNumber() {
      Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Solar').getRecordTypeId();
      Lead objLead = new Lead(lastName='Test Lead', Status='Open',Company='TestLeadAccount', LeadSource='SolarQuotes', RecordTypeId=LeadRecordTypeId);
      
      Test.startTest();
          insert objLead;
          objLead.Status = 'Open';
          update objLead;
        Test.stopTest();

  }

}