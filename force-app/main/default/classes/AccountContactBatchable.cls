global class AccountContactBatchable implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT id, Is_Sync_with_Household__c, Relationship_with_Applicant_1__c, Dependent_Parent__c, PersonContactId '; 
        query += ' FROM account '; 
        query += 'WHERE Is_Sync_with_Household__c = false and recordtype.name = \'person account\'';
        System.debug('@@@@@accList     ' + Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accList) {
        System.debug('@@@@@accList     ' + accList);
        List<AccountContactRelation> accConRelationList = new List<AccountContactRelation>();
        List<Account> accUpdateList = new List<Account>();
        Set<Id> accIds =  New Set<Id>();
        for(Account acc: accList){
            accIds.add(acc.Id);
            if(String.isNotBlank(acc.Dependent_Parent__c)){
                accIds.add(acc.Dependent_Parent__c);
            }
        }
        System.debug('@@@@@accIds     ' + accIds);
        List<Opportunity> oppList = [SELECT Id, Name, Applicant_1__r.Name, Applicant_2__c, Applicant_2__r.Name, AccountId, 
                                     Account.Name, Account.RecordType.Name, FinServ__Household__c
                                     FROM Opportunity 
                                     WHERE Applicant_1__c in: accIds OR Applicant_2__c in: accIds ];
        System.debug('@@@@@oppList     ' + oppList);
        Map<Id,Id> accHouseholdAcc = New Map<Id,Id>();
        List<Opportunity> oppListToUpdate = New List<Opportunity>();
        for(Opportunity opp: oppList){
            String householdId = '';
            if(String.isNotBlank(opp.FinServ__Household__c)){
                householdId = opp.FinServ__Household__c;
            }else if(String.isNotBlank(opp.AccountId) && ('Household').equalsIgnoreCase(opp.Account.RecordType.Name)){
                householdId = opp.AccountId;
                opp.AccountId = opp.Applicant_1__c;
                oppListToUpdate.add(opp);
            }
            System.debug('@@@@@householdId     ' + householdId);
            if(String.isNotBlank(householdId)){
                accHouseholdAcc.put(opp.Applicant_1__c, householdId);
                if(String.IsNotBlank(opp.Applicant_2__c)){
                    accHouseholdAcc.put(opp.Applicant_2__c, householdId);
                }
            }
        }
        System.debug('@@@@@accList     ' + accList);
        for(Account acc: accList){
            System.debug('@@@@@acc     ' + acc);
            String accId = '';
            if(accHouseholdAcc.containsKey(acc.Id)){
                accId = accHouseholdAcc.get(acc.Id);
            }else if(accHouseholdAcc.containsKey(acc.Dependent_Parent__c)){
                accId = accHouseholdAcc.get(acc.Dependent_Parent__c);
            } 
            System.debug('@@@@@accId     ' + accId);
            if(String.IsNotBlank(accId)){
                accConRelationList.add(new AccountContactRelation(AccountId = accId, 
                                                                  ContactId = acc.PersonContactId,
                                                                  Roles = acc.Relationship_with_Applicant_1__c,
                                                                  FinServ__PrimaryGroup__c = true,
                                                                  FinServ__Primary__c = acc.Relationship_with_Applicant_1__c=='Client',
                                                                  FinServ__Rollups__c='All'));
                acc.Is_Sync_with_Household__c = true;
                accUpdateList.add(acc);
            }
        }
        
        try {
            System.debug('@@@@@accUpdateList     ' + accUpdateList);
            System.debug('@@@@@accConRelationList     ' + accConRelationList);
            System.debug('@@@@@oppListToUpdate     ' + oppListToUpdate);
            update accUpdateList;
            insert accConRelationList;
            update oppListToUpdate;
        } catch(Exception e) {
            System.debug(e);
        }
    }

    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
}