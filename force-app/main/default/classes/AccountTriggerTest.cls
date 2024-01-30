@istest
public class AccountTriggerTest {
   @testsetup
    static void CreateData(){
        list<account> acclist = new list<account>();
        
        Account accPerson= new Account(
            FirstName='Test Person',
            LastName='Test LName'  
        );
        accList.add(accPerson);
        
        Account accPerson2= new Account(
            FirstName='Test Person2',
            LastName='Test LName'  
        );
        accList.add(accPerson2);
        
        insert acclist;
        
        Opportunity oppty = new Opportunity ();
        oppty.applicant_1__c = accPerson.Id;
        oppty.applicant_2__c = accPerson2.Id;
        oppty.name = 'test Oppty';
        oppty.StageName='Assessment Needed'; 
        oppty.CloseDate = Date.today();
        
        insert oppty;  
        
                 
    }
    
    static testmethod void TestAccountTrigger(){
        Account acc = [select id,FirstName,LastName from account where FirstName='Test Person' LIMIT 1];
        acc.FirstName = 'Rakesh';
        update acc;
        
    }
}