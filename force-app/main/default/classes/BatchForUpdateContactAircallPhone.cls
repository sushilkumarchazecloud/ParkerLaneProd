public class BatchForUpdateContactAircallPhone implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
         String query = 'SELECT id,Phone,MobilePhone,Aircall_Mobile_Format__c,Aircall_Mobile_Number__c,Aircall_Phone_Format__c,Aircall_Phone_Number__c FROM Contact';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Contact> contactList){
        for(Contact con : contactList) {        
            if(con.Phone != null){
                con.Aircall_Phone_Number__c = con.Aircall_Phone_Format__c;
            }
            if(con.MobilePhone != null){
                con.Aircall_Mobile_Number__c = con.Aircall_Mobile_Format__c;
            }
        }
        try {
            update contactList;
         
        } catch(Exception e) {
            System.debug(e);
        }
    }
    public void finish(Database.BatchableContext bc){
        System.debug('Successfully Update');
    }
}