@istest
class BatchForFundingTasksSchedularTest{
    public static testMethod void testschedule() {
        Test.StartTest();
        BatchForFundingTasksSchedular testsche = new BatchForFundingTasksSchedular();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
}