@isTest
public class ServiceAnnouncementControllerTest {
	@isTest
    static void testShowMessage(){
        Configuration__c config = New Configuration__c(Name = 'test', isShowMessage__c = true);
        insert config;
        
        Configuration__c config1 = New Configuration__c(Name = 'test1', isShowMessage__c = false);
        insert config1;
        
        ServiceAnnouncementController sACtrl = new ServiceAnnouncementController();
        sACtrl.nameOfService = 'test';
        System.assert(sACtrl.isShowMessage, 'should be true');
        
        sACtrl.nameOfService = 'test1';
        System.assert(!sACtrl.isShowMessage, 'should be false');
    }
    
}