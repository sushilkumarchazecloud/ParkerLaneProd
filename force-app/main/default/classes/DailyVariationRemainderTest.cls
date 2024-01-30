@isTest
public class DailyVariationRemainderTest {
    @testsetup
    static void setUpData(){
        String recordTypePId= Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String recordTypeRefId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Referrer (Business)').getRecordTypeId();
        
        Account testAcc = new Account();
        testAcc.RecordTypeId  = recordTypeRefId;
        testAcc.Name = 'TestRef Account';
        insert testAcc;
        
        Account testAcc1 = new Account();
        testAcc1.RecordTypeId  = recordTypePId;
        testAcc1.FirstName = 'Test';
        testAcc1.LastName = 'Opportunity 1';
        testAcc1.Phone = '1234567890';
        testAcc1.PersonEmail = 'opp1@test.com';
        
        Account testAcc2 = new Account();
        testAcc2.RecordTypeId  = recordTypePId;
        testAcc2.FirstName = 'Test2';
        testAcc2.LastName = 'Opportunity 2';
        testAcc2.Phone = '1234567870';
        testAcc2.PersonEmail = 'opp1@test1.com';
        
        insert testAcc1;
        insert testAcc2;
        
        Contact testCon = new Contact();
        testCon.FirstName = 'TestRef';
        testCon.LastName = 'Contact';
        testCon.AccountId = testAcc.Id;
        testCon.Admin__c = true;
        testCon.Portal_View__c = 'Admin View';
        testCon.Phone ='0412568868';
        testCon.Email ='rakesh@gmail.com';
        insert testCon;
        
        Opportunity testOpp1 = new Opportunity();
        testOpp1.Name = 'Test Opportunity 1';
        testOpp1.FinServ__ReferredByContact__c = testCon.Id;
        testOpp1.Referred_by_Company__c =testAcc.id;
        testOpp1.Contact_1__c = testCon.id;
        testOpp1.StageName ='Approved';
        testOpp1.CloseDate = System.Today();
        testOpp1.Applicant_1__c = testAcc1.Id;
        testOpp1.Applicant_2__c = testAcc2.id;
        insert testOpp1;
        
        Opportunity testOpp2 = new Opportunity();
        testOpp2.Name = 'Test Opportunity 2';
        testOpp2.FinServ__ReferredByContact__c = testCon.Id;
        testOpp2.Referred_by_Company__c =testAcc.id;
        testOpp2.Contact_1__c = testCon.id;
        testOpp2.StageName ='Approved';
        testOpp2.CloseDate = System.Today();
        testOpp2.Applicant_1__c = testAcc1.Id;
        testOpp2.Applicant_2__c = testAcc2.id;
        insert testOpp2;
        
        Opportunity opp = [select id,name,Applicant_1__c,Applicant_2__c,Applicant_1__r.name,Applicant_2__r.name,Applicant_1__r.personcontactId,Applicant_2__r.personcontactId from Opportunity where Name = 'Test Opportunity 1' LIMIT 1];
        list<VOI_Status__c> voiList = new list<VOI_Status__c>();
        VOI_Status__c obj = new VOI_Status__c();
        obj.Opportunity__c = opp.id;
        obj.Contact__c = opp.Applicant_1__r.personContactID;
        obj.Case_Status__c = 'Sent';
        obj.VOI_Type_For__c = 'E-SIGN';
        obj.Current_VOI_section__c = 'CQP';
        voiList.add(obj);
        
        VOI_Status__c obj2 = new VOI_Status__c();
        obj2.Opportunity__c = opp.id;
        obj2.Contact__c = opp.Applicant_2__r.personContactID;
        obj2.Case_Status__c = 'Sent';
        obj2.VOI_Type_For__c = 'E-SIGN';
        obj2.Current_VOI_section__c = 'CQP';
        //voiList.add(obj2);
        
        insert voiList;
        
        list<Funding_Request__c> frlist = new list<Funding_Request__c>();
        Funding_Request__c fr = new Funding_Request__c();
        fr.Request_Type__c = 'Variation';
        fr.Request_Status__c = 'Variation requested by customer';
        fr.Opportunity__c = opp.Id;
        fr.Applicant_1_A1__c = opp.Applicant_1__c;
        fr.Applicant_2_A2__c = opp.Applicant_2__c;
        fr.Requested_by__c = 'Customer';
        fr.Person_Requesting__c = opp.Applicant_1__r.personcontactId;
        fr.Variation_Requested_By__c = opp.Applicant_1__c;
        fr.Customer_Authorisation_Type__c = 'Either to sign';
        fr.Customer_Authorisation_Status__c = 'Pending Applicant 1';
        fr.Date_Last_Request_Status_Changes__c = system.now().addDays(-5);
        frlist.add(fr);
        
        Funding_Request__c fr3 = new Funding_Request__c();
        fr3.Request_Type__c = 'Variation';
        fr3.Request_Status__c = 'Variation requested by customer';
        fr3.Opportunity__c = opp.Id;
        fr3.Applicant_1_A1__c = opp.Applicant_1__c;
        fr3.Applicant_2_A2__c = opp.Applicant_2__c;
        fr3.Requested_by__c = 'Customer';
        fr3.Person_Requesting__c = opp.Applicant_1__r.personcontactId;
        fr3.Variation_Requested_By__c = opp.Applicant_1__c;
        fr3.Customer_Authorisation_Type__c = 'Either to sign';
        fr3.Customer_Authorisation_Status__c = 'Pending Applicant 1';
        fr3.Date_Last_Request_Status_Changes__c = system.now().addDays(-5);
        frlist.add(fr3);
        
        system.debug('personCOnID'+fr.Person_Requesting__c);
        
        Funding_Request__c fr2 = new Funding_Request__c();
        fr2.Request_Type__c = 'Payment in full before installation';
        fr2.Request_Status__c = 'Payment requested by supplier';
        fr2.Opportunity__c = opp.Id;
        fr2.Applicant_1_A1__c = opp.Applicant_1__c;
        fr2.Applicant_2_A2__c = opp.Applicant_2__c;
        fr2.Requested_by__c = 'Supplier';
        fr2.Person_Requesting__c = opp.Applicant_2__r.personcontactId;
        fr2.Customer_Authorisation_Type__c = 'Both to sign';
        fr2.Customer_Authorisation_Status__c = 'Pending Applicant 1';
        fr2.Date_Last_Request_Status_Changes__c = system.now().addDays(-5);
        frlist.add(fr2);
 
        insert frlist;
        
    }
    
    static testMethod void test1(){
        Opportunity opp = [select id,name,Applicant_1__c,Applicant_2__c,Applicant_1__r.name,Applicant_2__r.name,Applicant_1__r.personcontactId,Applicant_2__r.personcontactId from Opportunity where Name = 'Test Opportunity 1' LIMIT 1];
        list<Funding_Request__c> frlist = [select id,Date_Last_Request_Status_Changes__c,Request_Type__c from Funding_Request__c where opportunity__c =:opp.id];
        integer count =-8;
        Boolean ispass = false;
        for(Funding_Request__c fr : frlist){
            if(fr.Request_Type__c == 'Variation'){
                fr.Date_Last_Request_Status_Changes__c = system.now().addDays(count);
            }
            else{
                fr.Date_Last_Request_Status_Changes__c = system.now().addDays(count);
            }
            count = count+1;
        }
        update frlist;
        
        
        Datetime scheduledTime = Datetime.now().addMinutes(1);
        String cronExpression = '' + scheduledTime.second() + ' ' + scheduledTime.minute() + ' ' +scheduledTime.hour() + ' ' + scheduledTime.day() + ' ' + scheduledTime.month() +' ? ' + scheduledTime.year();
        Test.startTest();
        String jobId = System.schedule('Test Job', cronExpression, new DailyVariationReminder()); 
        Test.stopTest();
    }
}