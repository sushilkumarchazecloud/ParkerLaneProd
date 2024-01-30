@isTest
public class LineChartControllerTest {
	@testSetup
    static void setUpData(){
        Opportunity oppty = new Opportunity ();
        oppty.name = 'test Oppty';
        oppty.StageName='Assessment Needed'; 
        oppty.CloseDate = Date.today();
        oppty.Application_Sections__c ='Own and Owe'; 
        oppty.Current_Application_Sections__c ='Who is applying';
        oppty.Relationship_to_Applicant_2__c = 'Spouse';
        oppty.Confirm_Settlement_Date__c = true;
        oppty.Lender__c = 'Lender';
        oppty.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commercial Mortgage').getRecordTypeId();
        insert oppty;
        
        Stage_Tracking__c st = New Stage_Tracking__c();
        st.New_Stage_End_Date__c = Date.today();
        st.Stage_Changing_Date__c = Date.today().addDays(-2);
        st.New_Stage__c = 'Quote';
        st.Opportunity__c = oppty.Id;
        insert st;
        
        Stage_Tracking__c st1 = New Stage_Tracking__c();
        st1.New_Stage_End_Date__c = Date.today().addDays(-7);
        st1.Stage_Changing_Date__c = Date.today().addDays(-2);
        st1.New_Stage__c = 'CPA Done';
        st1.Opportunity__c = oppty.Id;
        insert st1;
        
        Stage_Tracking__c st2 = New Stage_Tracking__c();
        st2.New_Stage_End_Date__c = Date.today().addDays(-19);
        st2.Stage_Changing_Date__c = Date.today().addDays(-7);
        st2.New_Stage__c = 'Packs Back';
        st2.Opportunity__c = oppty.Id;
        insert st2;
        
        
        
    }
    
    static testmethod void selectedSectionTest(){
        String path = LineChartController.getChartData('Lender;lender1', 'chris;bala', 'Commercial;Trans', New List<String>{'Quote','CPA Done','Packs Back'}, Date.today().addDays(-6), Date.today());
        System.assertNotEquals('[]', path, 'value should not be blank');
    }
}