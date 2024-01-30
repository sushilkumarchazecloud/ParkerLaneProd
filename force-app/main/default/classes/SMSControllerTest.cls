@isTest
public class SMSControllerTest {
	@isTest
    public static void smsTest(){
		SMSController.SendMessage('Contact', 'Parkerlane', '1234567890');
        
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        insert acc;
        
        contact con = new contact();
        con.firstname = 'qwert';
        con.lastName = 'testing';
        con.VOI_type__c='FULL';
        insert con;
        
        opportunity op1 = new Opportunity()	;
        op1.Name = 'testing';
        op1.Preferred_repayment_frequency__c = 'Monthly';  
        op1.Loan_Amount__c = 560;
        op1.StageName = 'Working';
        op1.Application_Supporting_Notes__c = 'Hello World';
        op1.CloseDate = System.today();
        op1.Applicant_1__c = acc.Id;
        insert op1;
        
       
        VOI_Status__c vStatus = new VOI_Status__c();
        vStatus.Account__c = acc.Id;
        vStatus.Contact__c = con.Id;
        vStatus.Opportunity__c = op1.Id;
        insert vStatus;
        
        
        string IntrandomNumber = string.valueOf(Math.floor(1000 + Math.random() * 9000));
        
        SMSController.SendMessage('Contact', 'Parkerlane', '0400000000');
        
        SMSController.SendMessageWithOpportunityAndContact('Contact', 'Parkerlane', '1234567890', op1.Id, con.id, IntrandomNumber, '', vStatus.Id);
        
        SMSController.SendMessageToReferr('Contact', 'Parkerlane', con.id, acc.id, IntrandomNumber, '' , ''); 
    	
        SMSController.sendApproveExpireMessage('Contact', 'Parkerlane','testt', '0400000000', 'test', op1.id, con.id);
    }
}