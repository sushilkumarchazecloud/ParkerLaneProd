@isTest
public class groupQuoteController_Test {
    @isTest
    static void testMethod1(){
       
        
        User user = new User( ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, LastName = 'last', Email = 'puser000@amamama.com', Username = 'puser000@amamama.com' + System.currentTimeMillis(), CompanyName = 'TEST', Title = 'title', Alias = 'alias', TimeZoneSidKey = 'America/Los_Angeles', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US' );
        insert user;
        System.runAs(user){
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            Account ac = new Account(FirstName='Test Ac',PersonEmail = 'puser000@amamama.com', LastName='test', RecordTypeID = recordTypeId );
            insert ac;
            Account acc = new account();
            acc.RecordTypeId= recordTypeId;
            acc.FirstName = 'Test';
            acc.LastName = 'Testr'; 
            acc.PersonEmail='rakesh@gmail.com';
            insert acc;
            //List<String> typeList = productSearch.getProductType();
            Product2 pd = new Product2();
            pd.Interest_Rate__c = 5.6;
            pd.Interest_Rate_Override__c = true;
            pd.Interest_Rate_Type__c = 'Fixed';
            pd.Name = 'Test product';
            insert pd;
            Opportunity opp = new Opportunity( Applicant_1__c = ac.Id,Applicant_2__c = ac.Id, Name='Test', StageName='Settled (closed won)', CloseDate= Date.today(), Confirm_Settlement_Date__c = true);
            Insert opp;
             Opportunity opp1 = new Opportunity( Applicant_1__c = ac.Id,Applicant_2__c = ac.Id, Name='Test', StageName='Application', CloseDate= Date.today(), Confirm_Settlement_Date__c = true);
            Insert opp1;
            Opportunity opp3 = new Opportunity( Applicant_1__c = ac.Id,Applicant_2__c = ac.Id, Name='Test', StageName='Settled (closed won)', CloseDate= Date.today(), Confirm_Settlement_Date__c = true);
            Insert opp3;
            Opportunity opp4 = new Opportunity( Applicant_1__c = acc.Id,Applicant_2__c = ac.Id, Name='Test', StageName='Settled (closed won)', CloseDate= Date.today(), Confirm_Settlement_Date__c = true);
            Insert opp4;
            
            List<Quote> temQuote = new List<Quote>();
            temQuote.add(new Quote(Name ='test', Gruop_Name__c = 'test',Purpose__c='Solar', OpportunityId=opp.Id));
            temQuote.add(new Quote(Name ='test1', Gruop_Name__c = 'test2',Purpose__c='Solar', OpportunityId=opp.Id));
            temQuote.add(new Quote(Name ='test1', Gruop_Name__c = 'test1',Purpose__c='Solar', OpportunityId=opp.Id));
            temQuote.add(new Quote(Name ='test3', Gruop_Name__c = 'test3',Purpose__c='Solar', OpportunityId=opp4.Id));
            insert temQuote;
            
            lead jd = new lead();
            jd.Email ='rakesh@gmail.com';
            jd.LastName='test';
            insert jd;
            
            Map<String, List<Object>> temp = groupQuoteController.getQuoteName(opp.ID);
            test.startTest();
            groupQuoteController.sendApplication(opp.id,temQuote[0].id);
            groupQuoteController.sendQuotation(opp4.id,temQuote[0].id,temQuote[3].Gruop_Name__c);
            groupQuoteController.updateQuoteApplication(temQuote[1].id ,opp1.id, temQuote[0].id);
            groupQuoteController.updateQuote(temQuote[0].id, opp3.Id);
            groupQuoteController.deleteApplication(opp.Id, temQuote[0].Gruop_Name__c);
            test.stopTest();
            
        }
    }
}