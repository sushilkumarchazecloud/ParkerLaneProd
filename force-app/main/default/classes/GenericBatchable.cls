global class GenericBatchable implements Database.Batchable<sObject>{
    global String queryStr; 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('@@@@' + Database.query(queryStr));
        return Database.getQueryLocator(queryStr);
    }
    global void execute(Database.BatchableContext BC, List<opportunity> oppList) { 
        List<Account> accListToUpdate = New List<Account>();
        List<Id> ids = New List<Id>();
        //List<opportunity> oppList = (List<opportunity>)sObjList;
        for(opportunity opp: oppList){
            if(String.isNotBlank(opp.OwnerId) && opp.Owner.IsActive){
                if(String.isNotBlank(opp.applicant_1__c) && !ids.contains(opp.applicant_1__c)){
                    accListToUpdate.add(New Account(Id = opp.applicant_1__c, OwnerId = opp.OwnerId) );
                    Ids.add(opp.applicant_1__c);
                }
                if(String.isNotBlank(opp.applicant_2__c) && !ids.contains(opp.applicant_2__c)){
                    accListToUpdate.add(New Account(Id = opp.applicant_2__c, OwnerId = opp.OwnerId) );
                    Ids.add(opp.applicant_2__c);
                }
                if(String.isNotBlank(opp.finserv__household__c) && !ids.contains(opp.finserv__household__c)){
                    accListToUpdate.add(New Account(Id = opp.finserv__household__c, OwnerId = opp.OwnerId) );
                    Ids.add(opp.finserv__household__c);
                }
                if(String.isBlank(opp.finserv__household__c) && String.isNotBlank(opp.AccountId) && !ids.contains(opp.AccountId)){
                    accListToUpdate.add(New Account(Id = opp.AccountId, OwnerId = opp.OwnerId) );
                    Ids.add(opp.AccountId);
                }
                
            } 
        }
        System.debug('@@@@'+ accListToUpdate.size()+'----'+accListToUpdate);
        update accListToUpdate;
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}