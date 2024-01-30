@isTest
public class GenerateVOIDetailTest {

    @isTest
    public static void mainMethod(){
        contact con = new contact();
		con.LastName = 'testing con';
		insert con;
        
        opportunity opp = new opportunity();
        opp.name = 'test opp';
        opp.StageName = 'Working';
        opp.CloseDate = system.today();
        opp.Contact_1__c = con.Id;
        insert opp;
      
        VOI_Status__c obj = new VOI_Status__c();
        obj.Contact__c = con.Id;
        obj.Opportunity__c = opp.Id;
        insert obj;
        
        
        test.startTest();
        GenerateVOIDetail.GenerateVOI(obj.id);
        test.stopTest();
        
    }
}