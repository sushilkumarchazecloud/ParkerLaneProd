@isTest
public class UtilityClass_Test {
    @isTest
    static void getRequest(){
        UserRole r = new UserRole(DeveloperName = 'Advisor', Name = 'Advisor');
        insert r;
        User u = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
             LastName = 'last',
             Email = 'bala@parkerlane.com',
             Username = 'bala@parkerlane.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US',
             UserRoleId = r.Id
        );
        insert u;
        System.runAs(u){
            Account ac = new Account(Name='Test Ac');
            insert ac;
            Opportunity opp = new Opportunity( Applicant_1__c = ac.Id,Applicant_2__c = ac.Id, Name='Test', StageName='open', CloseDate= Date.today(), Owner = u);
            Insert opp;
            List<Manage_Document__c> dmList = new List<Manage_Document__c>();
            dmList.add(new Manage_Document__c(Category__c = 'Income',Document__c = 'Payslips',IsJoint__c = false,isDefault__c = true));
            dmList.add(new Manage_Document__c(Category__c = 'Standard If Documents',Document__c = 'Centrelink Statements',IsJoint__c = true,isDefault__c = true));
            insert dmList;
            UtilityClass.createDefualtRequest(opp.Id);
            UtilityClass.sendEmail(opp);
        }
    }
    
    @isTest
    static void createException(){
        UtilityClass.createException( 'recordId',  'className',  'methodName',  'ErrorMessage',  'stackTrace',  'lineNo',
                                        'errorType',  'errorCause');
    }
    
    @isTest
    static void getPicklistValues(){
        List<String> appStagesList = UtilityClass.getPicklistValues('Opportunity', 'StageName'); 
        System.assertNotEquals(0, appStagesList.size(), 'should not be Zero');
    }
}