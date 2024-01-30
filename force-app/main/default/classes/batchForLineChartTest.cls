@isTest
public class batchForLineChartTest {
    @testsetup
    static void setUpData(){
        Account testAcc = new Account();
        testAcc.Name = 'Test acc'; 
        insert testAcc;
        
        Opportunity testOpp1 = new Opportunity();
        testOpp1.Name = 'Test Opp';
        testOpp1.StageName ='Quote';
        testOpp1.CloseDate = System.Today();
        testOpp1.Applicant_1__c = testAcc.Id;
        insert testOpp1; 
        
        Contact testCon = new Contact();
        testCon.FirstName = 'Test';
        testCon.LastName = 'Con';
        testCon.Phone = '1234567890';
        insert testCon;        
    }
    
    public static testMethod void testfillActivity(){
        Opportunity Opp = [SELECT Id,Name,StageName FROM Opportunity WHERE Name = 'Test Opp' LIMIT 1];        
        batchForLineChart obj = new batchForLineChart(new List<opportunity>{Opp});
        database.executeBatch(obj,5);
         
    }
    
}