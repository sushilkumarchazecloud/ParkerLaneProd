@isTest
public class ScheduleBatchForReferrerTest {
	
    @isTest
    public static void testOne(){
        ScheduleBatchForReferrer sh1 = new ScheduleBatchForReferrer();
		
            Test.StartTest();        
            String sch = '0 0 23 * * ?'; 
            system.schedule('Test Territory Check', sch, sh1); Test.stopTest(); 
            
    }
}