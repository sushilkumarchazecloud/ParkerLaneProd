@isTest
public class batchForRefrrerRatingTest {
    
    @isTest
    public static void method1(){
        Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Referrer').getRecordTypeId();
        
        Contact con = new Contact();
        con.LastName= 'test Data';
        con.RecordTypeId = devRecordTypeId;
        con.Email = 'testqwert@gmail.com';
        insert con;
        
        List<opportunity> oppList = new List<opportunity>();
        opportunity opp = new opportunity();
        opp.name = 'qwerty';
        opp.FinServ__ReferredByContact__c = con.Id;
        opp.StageName = 'Funding';
        opp.CloseDate = System.today();
        oppList.add(opp);
        
        opportunity opp1 = new opportunity();
        opp1.name = 'qwerty';
        opp1.FinServ__ReferredByContact__c = con.Id;
        opp1.StageName = 'Funding';
        opp1.CloseDate = System.today();
        oppList.add(opp1);
        
        opportunity opp2 = new opportunity();
        opp2.name = 'qwerty';
        opp2.FinServ__ReferredByContact__c = con.Id;
        opp2.StageName = 'Funding';
        opp2.CloseDate = System.today().addMonths(-8);
        oppList.add(opp2);
        
        opportunity opp3 = new opportunity();
        opp3.name = 'qwerty';
        opp3.FinServ__ReferredByContact__c = con.Id;
        opp3.StageName = 'Funding';
        opp3.CloseDate = System.today().addMonths(-5);
        oppList.add(opp3);
        
        opportunity opp4 = new opportunity();
        opp4.name = 'qwerty';
        opp4.FinServ__ReferredByContact__c = con.Id;
        opp4.StageName = 'Funding';
        opp4.CloseDate = System.today().addMonths(-5);
        oppList.add(opp4);
        
        opportunity opp5= new opportunity();
        opp5.name = 'qwerty';
        opp5.FinServ__ReferredByContact__c = con.Id;
        opp5.StageName = 'Funding';
        opp5.CloseDate = System.today().addMonths(-5);
        oppList.add(opp5);
        
        
        OpportunityTriggerHandler.isByPassTrigger = true;
        insert oppList;
        OpportunityTriggerHandler.isByPassTrigger = false;
        
        Test.setCreatedDate(oppList[0].id, system.today().addMonths(-1));
        Test.setCreatedDate(oppList[1].id, system.today().addMonths(-2));
        Test.setCreatedDate(oppList[2].id, system.today().addMonths(-10));
        
        batchForRefrrerRating obj = new batchForRefrrerRating();
        DataBase.executeBatch(obj);        
    }
    
    @isTest
    public static void testTwo(){
        Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Referrer').getRecordTypeId();
        
        Contact con = new Contact();
        con.LastName= 'test Data';
        con.RecordTypeId = devRecordTypeId;
        con.Email = 'testqwert@gmail.com';
        insert con;
        
        List<opportunity> oppList = new List<opportunity>();
        opportunity opp = new opportunity();
        opp.name = 'qwerty';
        opp.FinServ__ReferredByContact__c = con.Id;
        opp.StageName = 'Approved';
        opp.CloseDate = System.today();
        oppList.add(opp);
        
        opportunity opp1 = new opportunity();
        opp1.name = 'qwerty';
        opp1.FinServ__ReferredByContact__c = con.Id;
        opp1.StageName = 'Approved';
        opp1.CloseDate = System.today();
        oppList.add(opp1);
        
        opportunity opp2 = new opportunity();
        opp2.name = 'qwerty';
        opp2.FinServ__ReferredByContact__c = con.Id;
        opp2.StageName = 'Approved';
        opp2.CloseDate = System.today().addMonths(-8);
        oppList.add(opp2);
        
        opportunity opp3 = new opportunity();
        opp3.name = 'qwerty';
        opp3.FinServ__ReferredByContact__c = con.Id;
        opp3.StageName = 'Approved';
        opp3.CloseDate = System.today().addMonths(-5);
        oppList.add(opp3);
        
        
        OpportunityTriggerHandler.isByPassTrigger = true;
        insert oppList;
        OpportunityTriggerHandler.isByPassTrigger = false;
        
        Test.setCreatedDate(oppList[2].id, system.today().addMonths(-8));
        
        batchForReferrar obj = new batchForReferrar();
        DataBase.executeBatch(obj);        
    }
}