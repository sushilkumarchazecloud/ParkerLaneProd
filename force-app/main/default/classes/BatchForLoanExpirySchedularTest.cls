@istest
class BatchForLoanExpirySchedularTest{
	public static testMethod void testschedule() {
		Test.StartTest();
		BatchForLoanExpirySchedular testsche = new BatchForLoanExpirySchedular();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
	}
}