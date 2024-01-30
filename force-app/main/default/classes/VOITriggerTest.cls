@isTest
public class VOITriggerTest {
    
    @testsetup
    static void setdata(){
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        List<Account> accList= new List<Account>();
        
        VOI_Status__c vs = new VOI_Status__c();
        vs.Case_Status__c = 'Sent';
        vs.Skip_VOI__c = true;
        insert vs;
        
        Account accPerson= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test Person',
            LastName='Test LName',
            Phone ='1234567890',
            PersonEmail='test@yahoo.com',
            Is_Sync_with_Household__c=false,
            Relationship_with_Applicant_1__c='Client'
        );
        accList.add(accPerson);
        
        Account accPerson2= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test Person2',
            LastName='Test LName',
            Phone ='1234567890',
            PersonEmail='test@yahoo.com',
            Is_Sync_with_Household__c=false,
            Relationship_with_Applicant_1__c='Spouse'
        );
        accList.add(accPerson2);
        
        insert accList;
        
        Opportunity oppty = new Opportunity ();
        oppty.applicant_1__c = accPerson.Id;
        oppty.applicant_2__c = accPerson2.Id;
        oppty.name = 'test Oppty';
        oppty.StageName='Assessment Needed'; 
        oppty.CloseDate = Date.today();
        insert oppty;
        
        Opportunity oppty2 = new Opportunity ();
        oppty2.applicant_1__c = accPerson.Id;
        oppty2.applicant_2__c = accPerson2.Id;
        oppty2.name = 'test Oppty2';
        oppty2.StageName='Assessment Needed'; 
        oppty2.CloseDate = Date.today();
        insert oppty2;
        
    }
    
    @isTest
    public static void methodOne(){
        VOI_Status__c vs = [Select id, name from VOI_Status__c where Case_Status__c = 'Sent' LIMIT 1]; 
        vs.Case_Status__c = 'SUbmitted';
        update vs;
    }
    
    @isTest
    public static void OppUpdateTest(){
        Opportunity Opp = [SELECT Id,Applicant_1__r.personcontactId,Applicant_2__r.personcontactId FROM Opportunity WHERE Name= 'test Oppty2' LIMIT 1];
        List<voi_Status__c> voiList = new List<voi_Status__c>();
        voi_Status__c vc = new voi_Status__c();
        vc.Contact__c = Opp.Applicant_1__r.personcontactId;
        vc.Case_Status__c = 'Sent';
        vc.Opportunity__c = Opp.Id;
        vc.link_Expire_code__c ='ttttt';
        vc.VOI_Status__c = 'Sent';
        voiList.add(vc);
        
        voi_Status__c vc1 = new voi_Status__c();
        vc1.Contact__c = Opp.Applicant_2__r.personcontactId;
        vc1.Case_Status__c = 'Sent';
        vc1.Opportunity__c = Opp.Id;
        vc1.link_Expire_code__c ='ttttt';
        vc1.VOI_Status__c = 'Sent';
        voiList.add(vc1);
        
        insert voiList;
        
        List<VOI_Status__c> VsList = [Select id,VOI_Status__c,Contact__c from VOI_Status__c where Id IN: voiList];
        for(VOI_Status__c vss : VsList){
            if(vss.Contact__c == Opp.Applicant_1__r.personcontactId){
                vss.VOI_Status__c = 'Delivered';
            }
            if(vss.Contact__c == Opp.Applicant_2__r.personcontactId){
                vss.VOI_Status__c = 'Submitted';
            }
        }
        update VsList;
    }
    
    @istest
    public static void testAdviserTask(){
        Opportunity Opp = [SELECT Id,Applicant_1__r.personcontactId,Applicant_2__r.personcontactId FROM Opportunity WHERE Name= 'test Oppty2' LIMIT 1];
        List<voi_Status__c> voiList = new List<voi_Status__c>();
        voi_Status__c vc = new voi_Status__c();
        vc.Contact__c = Opp.Applicant_1__r.personcontactId;
        vc.Case_Status__c = 'Sent';
        vc.Opportunity__c = Opp.Id;
        vc.link_Expire_code__c ='ttttt';
        vc.VOI_Status__c = 'Sent';
        vc.VOI_Type_For__c = 'FULL';
        voiList.add(vc);
        insert voiList;
        
        List<VOI_Status__c> VsList = [Select id,VOI_Status__c,Contact__c from VOI_Status__c where Id IN: voiList];
        for(VOI_Status__c vss : VsList){
            vss.Case_Status__c = 'Submitted';
        }
        update VsList;
    }
}