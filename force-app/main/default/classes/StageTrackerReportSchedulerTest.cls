@istest
class StageTrackerReportSchedulerTest{
    public static testMethod void testschedule() {
        Opportunity oppty = new Opportunity ();
        oppty.name = 'test Oppty';
        oppty.StageName='CPA Started'; 
        oppty.CloseDate = Date.today();
        oppty.Confirm_Settlement_Date__c = true;
        insert oppty;
        
        Opportunity oppty1 = new Opportunity ();
        oppty1.name = 'test Oppty1';
        oppty1.StageName='CPA Started'; 
        oppty1.CloseDate = Date.today();
        oppty1.Confirm_Settlement_Date__c = true;
        insert oppty1;
        
        Test.StartTest();
        StageTrackerReportScheduler testsche = new StageTrackerReportScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
}