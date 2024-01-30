@isTest
public class testForUpdateLead {
    @isTest
    public static void testBatch(){
        Lead Ld = new lead();
        Ld.LastName = 'Test';
        Ld.Phone = '1234455667';
        Ld.MobilePhone = '1092837645';
        insert Ld;
        
        Test.startTest();
        BatchForUpdateLead ba = new BatchForUpdateLead();
        Id jobid= Database.executeBatch(ba,5);
        Test.stopTest();
        
    }
}