@isTest
public class SchedularForRefReportbatchTest {
	
    @isTest
    public static void methodOne(){
        //SchedularForRefReportbatch.execute();
        Test.StartTest();
        SchedularForRefReportbatch sh1 = new SchedularForRefReportbatch();
        
        String sch = '0 0 23 * * ?';
        system.schedule('Test Territory Check', sch, sh1);
        Test.stopTest(); 
    }
}