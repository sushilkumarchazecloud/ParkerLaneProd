@istest
public class OppActivitiesTimeLineControllerTest {
	@testsetup
    static void setUpData(){
        Opportunity oppty = New Opportunity();
        oppty.name = 'test Oppty';
        oppty.StageName='Assessment Needed'; 
        oppty.CloseDate = Date.today();
        oppty.Application_Sections__c ='Own and Owe'; 
        oppty.Current_Application_Sections__c ='Who is applying';
        oppty.Relationship_to_Applicant_2__c = 'Spouse';
        oppty.Confirm_Settlement_Date__c = true;
        insert oppty;
        
        ContentNote objCntNote = new ContentNote();
        objCntNote.Title = 'salesforce';
        objCntNote.Content = Blob.valueOf('Welcome to salesforce');
        insert objCntNote; //Insert Content Note   
        
        //create ContentDocumentLink  record to link with parentId 
        ContentDocumentLink objCntDocLink = new ContentDocumentLink();
        objCntDocLink.LinkedEntityId = oppty.Id; // Specify your parent Id 
        objCntDocLink.ContentDocumentId = objCntNote.Id;  //Content Note Id
        objCntDocLink.shareType = 'V'; // Specify your sharing type 
        insert objCntDocLink;
        List<Task> taskList = New List<Task>();
        task t=new task();
        t.status='Completed';
        t.Priority='low';
        t.subject='has not completed the task within 1 day';
        t.whatid=oppty.id;
        t.ActivityDate =Date.today();
        taskList.add(t);
        
        task t1=new task();
        t1.status='Completed';
        t1.Priority='low';
        t1.subject='has not completed the task within 1 day';
        t1.whatid=oppty.id;
        t1.ActivityDate =system.today()+5;
        taskList.add(t1);
        
        task t2=new task();
        t2.status='Open';
        t2.Priority='low';
        t2.subject='has not completed the task within 1 day';
        t2.whatid=oppty.id;
        t2.ActivityDate =Date.today()+5;
        taskList.add(t2);
        
        insert taskList;
        
        List<Event> eventList = New List<Event>();
        Event e = new Event();
        e.WhatId=oppty.id;
        e.StartDateTime=system.today();
        e.EndDateTime=system.today()+5;
        e.ActivityDate =system.today()+1;
        eventList.add(e);
        
        Event e1 = new Event();
        e1.WhatId=oppty.id;
        e1.StartDateTime=Date.today();
        e1.EndDateTime=Date.today();
        e1.ActivityDate =Date.today();
        eventList.add(e1);
        
        insert eventList;

    }
    
    static testmethod void TestGetActivities(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name ='test Oppty' Limit 1];
        List<OppActivitiesTimeLineController.activityWrapper> actList =
            OppActivitiesTimeLineController.getActivities(opp.Id);
    }
}