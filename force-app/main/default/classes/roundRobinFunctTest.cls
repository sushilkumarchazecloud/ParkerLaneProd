@isTest
public class roundRobinFunctTest {
	
    @isTest
    public static void methodOne(){
        List<opportunity> oppList = new List<opportunity>(); 
        opportunity opp5= new opportunity();
        opp5.name = 'qwerty';
        opp5.StageName = 'Working';
        opp5.CloseDate = System.today().addMonths(2);
        oppList.add(opp5);
        
        insert oppList;
        
        test.startTest();
        System.enqueueJob(new roundRobinFunct(oppList));       
        test.stopTest();
        
    }
    
}