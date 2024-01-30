@isTest
public class MassCaseDeleteTest {
    
    static testMethod void testCaseDelete(){
        List<Case> lstCase = new List<Case>();
        
        Case testCase = new Case();
        testCase.Origin = 'Email';
        testCase.Status = 'New';
        lstCase.add(testCase);
        Case testCase1 = new Case();
        testCase1.Origin = 'Email';
        testCase1.Status = 'New';
        lstCase.add(testCase1);
        
        insert lstCase;
        
        Test.startTest();
        Test.setCurrentPage(Page.MassDelete);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstCase);
        stdSetController.setSelected(lstCase);
        MassCaseDelete ext = new MassCaseDelete(stdSetController);
        ext.deleteRecords();
        ext.ret();
        Test.stopTest();
    }
}