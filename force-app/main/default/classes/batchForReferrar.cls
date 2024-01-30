global class batchForReferrar implements Database.Batchable<sObject>,Database.Stateful {
	
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Referrer').getRecordTypeId();
        
        System.debug(devRecordTypeId);
        
        return Database.getQueryLocator('Select Id, Name from Contact WHERE RecordTypeId = : devRecordTypeId');
    }

    global void execute(Database.BatchableContext bc, List<Contact> scope) {
        System.debug(scope);
        Date sixMonth = system.today().addMonths(-6);
        Date twoMonth = system.today().addMonths(-2);
        Date eightMonth = system.today().addMonths(-8);
        Map<id, MAP<string,List<Opportunity>>> opportunityMap = new Map<id, MAP<string,List<Opportunity>>>();
        for(Opportunity op : [Select Id, Name, CreatedDate,FinServ__ReferredByContact__c from opportunity WHERE FinServ__ReferredByContact__c IN: scope order By CreatedDate DESC]){
            if(!opportunityMap.containsKey(op.FinServ__ReferredByContact__c)){
                opportunityMap.put(op.FinServ__ReferredByContact__c, new MAP<string,List<Opportunity>>());              
            }
            
            if(op.CreatedDate >= sixMonth){
                if(opportunityMap.get(op.FinServ__ReferredByContact__c).containsKey('Six_Month')){
                    opportunityMap.get(op.FinServ__ReferredByContact__c).get('Six_Month').add(op);
                }
                else{
                    opportunityMap.get(op.FinServ__ReferredByContact__c).put('Six_Month', new List<Opportunity>{op});
                }
            }
            if(op.CreatedDate >= twoMonth){
                if(opportunityMap.get(op.FinServ__ReferredByContact__c).containsKey('Two_Month')){
                    opportunityMap.get(op.FinServ__ReferredByContact__c).get('Two_Month').add(op);
                }
                else{
                    opportunityMap.get(op.FinServ__ReferredByContact__c).put('Two_Month', new List<Opportunity>{op});
                }
            }
            
            if(op.CreatedDate < twoMonth && op.CreatedDate >=eightMonth){
                if(opportunityMap.get(op.FinServ__ReferredByContact__c).containsKey('For_return')){
                    opportunityMap.get(op.FinServ__ReferredByContact__c).get('For_return').add(op);
                }
                else{
                    opportunityMap.get(op.FinServ__ReferredByContact__c).put('For_return', new List<Opportunity>{op});
                }
            }
            
            if(op.CreatedDate < eightMonth){
                if(opportunityMap.get(op.FinServ__ReferredByContact__c).containsKey('old_Opp')){
                    opportunityMap.get(op.FinServ__ReferredByContact__c).get('old_Opp').add(op);
                }
                else{
                    opportunityMap.get(op.FinServ__ReferredByContact__c).put('old_Opp', new List<Opportunity>{op});
                }
            }
            
        }
         
        List<contact> updateContactList = new List<contact>();
        
        for(contact con : [select id, name,Referrer_Status__c,Last_referral_Date__c from contact where Id IN : opportunityMap.keySet()]){
            string pickList_Value = con.Referrer_Status__c;
            DateTime latestRef = con.Last_referral_Date__c;
            if(opportunityMap.get(con.Id).get('Two_Month') != null && opportunityMap.get(con.Id).get('Two_Month').size() > 0 && 
               opportunityMap.get(con.Id).get('For_return') == null && opportunityMap.get(con.Id).get('Six_Month') == null &&
               opportunityMap.get(con.Id).get('old_Opp') == null 
              ){
                if(opportunityMap.get(con.Id).get('Two_Month').size() >= 1){
                    con.Referrer_Status__c = 'New';
                    con.Last_referral_Date__c = opportunityMap.get(con.Id).get('Two_Month')[0].CreatedDate;
                }
            }
            
            if(opportunityMap.get(con.Id).get('Two_Month') != null && opportunityMap.get(con.Id).get('Two_Month').size() >0){
                if(opportunityMap.get(con.Id).get('For_return') == null && 
                   opportunityMap.get(con.Id).get('old_Opp') != null && opportunityMap.get(con.Id).get('old_Opp').size() > 0){
                    con.Referrer_Status__c = 'Returned';
                    con.Last_referral_Date__c = opportunityMap.get(con.Id).get('Two_Month')[0].CreatedDate;
                }
            }
            if(opportunityMap.get(con.Id).get('Six_Month') != null && opportunityMap.get(con.Id).get('Six_Month').size() > 0){
                if(opportunityMap.get(con.Id).get('Six_Month').size() < 6 && opportunityMap.get(con.Id).get('old_Opp') == null){
                    con.Referrer_Status__c = 'Current';
                    con.Last_referral_Date__c = opportunityMap.get(con.Id).get('Six_Month')[0].CreatedDate;
                }
                System.debug('line 94');
                System.debug(opportunityMap.get(con.Id).get('Six_Month').size() >= 6);
                if(opportunityMap.get(con.Id).get('Six_Month').size() >= 6){
                    con.Referrer_Status__c = 'Active';
                    con.Last_referral_Date__c = opportunityMap.get(con.Id).get('Six_Month')[0].CreatedDate;
                }
            }
            if(opportunityMap.get(con.Id).get('Two_Month') == null && 
               opportunityMap.get(con.Id).get('Six_Month') == null &&
               opportunityMap.get(con.Id).get('For_return') == null 
              ){
                  con.Referrer_Status__c = 'Inactive';
              }
            
            if(pickList_Value != con.Referrer_Status__c || latestRef != con.Last_referral_Date__c){
                updateContactList.add(con);
            }
        }
       	
        System.debug('updateContactList size'+updateContactList.size());
       
        if(updateContactList != null && updateContactList.size() > 0){
            update updateContactList;
        }
    }

    global void finish(Database.BatchableContext bc) {
        system.debug('batch job id = '+bc.getJobId());
    	batchForRefrrerRating obj = new batchForRefrrerRating();
        Database.executeBatch(obj, 200);
    }
	
}