@isTest
public class Show_Video_Controller_Test {
	@isTest	
    public static void VideoTestMethod(){
        
        
        VOI_Detail__c obj = new VOI_Detail__c();
        obj.Secure_Code__c = '1234';
        obj.Secure_Code_Orignal__c = '1434';
        insert obj;
        
        Show_Video_controller.FetchVoiDetail(obj.Id);
        
        Show_Video_controller.UpdateVOI(obj);
        Show_Video_controller.sendVideoDataToComponent(obj.Id);
       
    }
    
    @isTest
    public static void videoTestMethodSec(){
        contact con = new contact();
        con.LastName = 'test';
        con.Email = 'test@gmail.com';
        insert con;
        
        opportunity opp = new opportunity();
        opp.Name = 'test oop';
        opp.StageName = 'Working';
        opp.Application_Supporting_Notes__c = 'hello';
        opp.CloseDate = System.today();
        opp.Contact_1__c = con.Id;
        insert opp;
        
        
        VOI_Detail__c obj1 = new VOI_Detail__c();
        obj1.Contact__c = con.Id;
        obj1.Secure_Code__c = '1234';
        obj1.Secure_Code_Orignal__c = '1234';
        obj1.Video_and_Photo_ID_of_the_same_person__c = 'Facial match (success)';
        obj1.Code_Not_Required__c  =true;	
        insert obj1;
        
        VOI_Status__c vois = new VOI_Status__c();
        vois.Contact__c = con.id;
        vois.VOI_Detail__c = obj1.Id;
        vois.Opportunity__c = opp.id;
        insert vois;

        
        PageReference pageRef = Page.Show_Video; // Add your VF page Name here
        pageRef.getParameters().put('id', string.valueOf(obj1.Id));
        Test.setCurrentPage(pageRef);
        
        
        Show_Video_controller.UpdateVOI(obj1);
        
        Show_Video_controller.GenrateIdentityCertificate(obj1);
        
        
    }
}