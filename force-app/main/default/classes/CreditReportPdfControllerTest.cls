@isTest
public class CreditReportPdfControllerTest {
	
    @isTest
    public static void methodOne(){
        Account acc = new Account();
        acc.Name = 'tesinnt';
        insert Acc;
        
        contact con = new contact();
        con.AccountId = Acc.Id;
        con.firstname = 'qwert';
        con.lastName = 'testing';
        insert con;
        
        opportunity op = new Opportunity();
        op.name = 'opportunity';
		op.CloseDate = SYstem.today();
        op.StageName = 'Packs Back';
        op.FinServ__ReferredByContact__c = con.id;
        insert op;
	        
        Test.setCurrentPageReference(new PageReference('Page.CreditRepoortForLenderPDF')); 
        System.currentPageReference().getParameters().put('AccId', Acc.id);
        System.currentPageReference().getParameters().put('ConId', con.id);
        
        
        CreditReportPdfController obj = new CreditReportPdfController();
        
        
        
    }
}