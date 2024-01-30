@istest
class AccountContactSchedulerTest{
	public static testMethod void testschedule() {
		Test.StartTest();
		AccountContactScheduler testsche = new AccountContactScheduler();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
	}
}