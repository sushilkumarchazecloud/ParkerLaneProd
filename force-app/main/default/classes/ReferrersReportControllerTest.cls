@isTest
public class ReferrersReportControllerTest {
    @isTest
    private static void testReferrerReportController(){
        Account acc = new Account();
        acc.name='Findev2';
        insert acc;
       
        Contact con = new Contact();
        con.lastname = 'findev3';
        con.AccountId=acc.Id;
        insert con;
       
        Test.setCurrentPageReference(new PageReference('Page.ReferrersReport'));
        System.currentPageReference().getParameters().put('conId', con.id);
       
       
        Opportunity opp = new Opportunity();
        opp.FinServ__ReferredByContact__c = con.Id;
        opp.Name='findevOpp';
        opp.StageName='Working';
        opp.CloseDate= System.today();
        insert opp;
       
        Test.startTest();
        ReferrersReportController obj = new ReferrersReportController();
        Test.stopTest();
       
       
    }

}