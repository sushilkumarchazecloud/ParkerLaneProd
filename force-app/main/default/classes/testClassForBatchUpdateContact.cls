@isTest
public class testClassForBatchUpdateContact {
	@isTest
    public static void testBatch(){
        Contact con = new Contact();
        con.LastName = 'Test';
        con.Phone = '1234455667';
        con.MobilePhone = '1092837645';
        insert con;
        
        Test.startTest();
        BatchForUpdateContactAircallPhone ba = new BatchForUpdateContactAircallPhone();
        Id jobid= Database.executeBatch(ba,5);
        Test.stopTest();
        
    }
}