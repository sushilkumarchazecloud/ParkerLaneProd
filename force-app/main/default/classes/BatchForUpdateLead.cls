public class BatchForUpdateLead implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT id,Phone,MobilePhone,Aircall_Mobile_Format__c,Aircall_Mobile_Number__c,Aircall_Phone_Format__c,Aircall_Phone_Number__c FROM Lead WHERE IsConverted = false';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Lead> LdList){
        for(Lead Ld : LdList) {        
            if(Ld.Phone != null){
                Ld.Aircall_Phone_Number__c = Ld.Aircall_Phone_Format__c;
            }
            if(Ld.MobilePhone != null){
                Ld.Aircall_Mobile_Number__c = Ld.Aircall_Mobile_Format__c;
            }
        }
        try {
            update LdList;
            
        } catch(Exception e) {
            System.debug(e);
        }
    }
    public void finish(Database.BatchableContext bc){
        System.debug('Successfully Update');
    }
}