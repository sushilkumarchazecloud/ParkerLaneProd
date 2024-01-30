public without sharing class CustomNotificationFromApex {

    public static void notifyUsers(list<opportunity> opList, List<id> csUser, string title, string body) {
	    // Get the Id for our custom notification type
        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='customer_support_tasks'];
        set<string> userSt = new Set<string>();
        for(id ids : csUser){
            userSt.add(ids);
        }
        
        for(opportunity opp : opList){
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle(title);
            notification.setBody(body);
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(opp.Id);
            try {
                notification.send(userSt);
            }
            catch (Exception e) {
                Exception__c eror = new Exception__c(Class_Name__c = 'CustomNotificationFromApex',Method_Name__c = 'notifyUsers',Error_Message__c = e.getMessage() + '' + e.getLineNumber(),opportunity__c = opList[0].id);
                insert eror;
            }    
        }
        
    }
}