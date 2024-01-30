@isTest(SeeAllData=true)
public class TestSendHttpRequest{
  static testMethod void LH_Testmethod() {
       SchedulerManager schmng = new SchedulerManager();
       Test.starttest();
       schmng.StartScheduler();
       schmng.StopScheduler();
       ImportLeadScheduler impleadsch = new ImportLeadScheduler();
       impleadsch.execute(null);
       Test.stoptest();
    }
}