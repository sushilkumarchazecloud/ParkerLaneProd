@isTest
public class customLookUpControllerTest {
    @isTest
    static void testMethod1(){
        Account acc = New Account(Name='test account');
        insert acc;
        
        List < sObject > listValue = customLookUpController.fetchLookUpValues('test', 'Account');
        System.assertEquals(1, listValue.size(), 'size should be same');
    }
}