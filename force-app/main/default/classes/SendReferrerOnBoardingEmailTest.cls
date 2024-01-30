@istest
public class SendReferrerOnBoardingEmailTest {
    @testsetup
    static void setUpData(){
        Account acc = New Account(Name = 'acc');
        insert acc;
        Contact con = New Contact(LastName = 'Last name', FirstName = 'First Name', Email='test@gmail.com',AccountId = acc.Id);
        insert con;
    }
    
	static testmethod void TestSendReferrerOnBoardingEmailMethod(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name ='acc' Limit 1];
        SendReferrerOnBoardingEmail.SendReferrerOnBoardingEmailMethod(New List<String>{acc.Id});
        System.assertEquals('acc', acc.Name, 'Name should be same');
    }
}