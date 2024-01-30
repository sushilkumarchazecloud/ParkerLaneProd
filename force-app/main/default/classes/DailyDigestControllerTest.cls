@istest
public class DailyDigestControllerTest {
    @testsetup
    static void setUpData(){
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last  ',
            FirstName = 'first',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;
        
        Daily_Digest_Images__c ddI1 = New Daily_Digest_Images__c(Name ='Image1',Text__c='abc');
        Daily_Digest_Images__c ddI2 = New Daily_Digest_Images__c(Name ='Image2',Text__c='abc');
        Daily_Digest_Images__c ddI3 = New Daily_Digest_Images__c(Name ='FooterImage',Text__c='abc');
        Daily_Digest_Images__c ddI4 = New Daily_Digest_Images__c(Name ='description',Text__c='abc');
        Daily_Digest_Images__c ddI5 = New Daily_Digest_Images__c(Name ='regards',Text__c='abc');
        insert New List<Daily_Digest_Images__c>{ddI1,ddI2,ddI3,ddI4,ddI5};
            Account acc = New Account(Name = 'acc');
        insert acc;
        
        Contact con = New Contact(FirstName = 'test',LastName = 'contact', AccountId =acc.Id);
        insert con;
        
        Opportunity oppty = new Opportunity ();
        oppty.name = 'test Oppty';
        oppty.StageName='CPA Started'; 
        oppty.CloseDate = Date.today();
        oppty.Confirm_Settlement_Date__c = true;
        oppty.FinServ__ReferredByContact__c = con.Id;
        insert oppty;
        task t1=new task();
        t1.status='Completed';
        t1.Priority='low';
        t1.subject=' has not completed the task within 1 day';
        t1.whatid=oppty.id;
        t1.ActivityDate = Date.today();
        t1.Make_Activity_Private__c = FALSE;
        t1.OwnerId = u.Id;
        t1.WhoId = con.Id;
        insert t1;
        
        Event e = new Event();
        e.whatid=oppty.id;
        e.StartDateTime=system.today();
        e.EndDateTime=system.today()+5;
        e.ActivityDate = Date.today();
        e.WhoId = con.Id;
        e.OwnerId = u.Id;
        e.Make_Activity_Private__c = FALSE;
        insert e;
    }
    
	public static testMethod void testschedule() {
        
        Test.StartTest();
        DailyDigestScheduler testsche = new DailyDigestScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
}