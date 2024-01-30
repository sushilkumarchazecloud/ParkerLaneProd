global class batchForRefrrerRating implements Database.Batchable<sObject>,Database.Stateful {
	
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Referrer').getRecordTypeId();
        
        System.debug(devRecordTypeId);
        
        return Database.getQueryLocator('Select Id, Name from Contact WHERE RecordTypeId = : devRecordTypeId');
    }

    global void execute(Database.BatchableContext bc, List<Contact> scope) {
        MAP<id, Decimal> oppMap = new MAP<id, Decimal>();
        MAP<id, List<opportunity>> oppMapNdList = new MAP<id, List<opportunity>>();
        for(opportunity opp : [Select Id, Name,Amount, StageName,CreatedDate,FinServ__ReferredByContact__c from opportunity WHERE FinServ__ReferredByContact__c IN: scope order By CreatedDate DESC]){
            if(!oppMap.containsKey(opp.FinServ__ReferredByContact__c)){
                if(opp.Amount == null){
                    opp.Amount = 0;
                    oppMap.put(opp.FinServ__ReferredByContact__c, opp.Amount);
                }
                else{
                    if(opp.StageName == 'Application' || opp.StageName == 'Approved' || opp.StageName == 'Funding' || opp.StageName == 'Settled (closed won)'){
                        if(opp.CreatedDate >= System.today().addmonths(-6)){
                            oppMap.put(opp.FinServ__ReferredByContact__c, opp.Amount);
                        }
                    }
                }
            }
            else{
                if(opp.StageName == 'Application' || opp.StageName == 'Approved' || opp.StageName == 'Funding' || opp.StageName == 'Settled (closed won)'){
                    if(opp.CreatedDate >= System.today().addmonths(-6)){
                        decimal count=oppMap.get(opp.FinServ__ReferredByContact__c);
                        count  = count + (opp.Amount != null ? opp.Amount : 0);
                        oppMap.put(opp.FinServ__ReferredByContact__c,count);
                    }
                }
            }
            
            if(!oppMapNdList.containsKey(opp.FinServ__ReferredByContact__c)){
                oppMapNdList.put(opp.FinServ__ReferredByContact__c, new List<opportunity>{opp});
            }
            else{
                if(opp.StageName == 'Application' || opp.StageName == 'Approved' || opp.StageName == 'Funding' || opp.StageName == 'Settled (closed won)'){
                    if(opp.CreatedDate >= System.today().addmonths(-6)){
                        oppMapNdList.get(opp.FinServ__ReferredByContact__c).add(opp);
                    }
                }
            }
            
            
        }
        system.debug('map '+ oppMap);
        system.debug('map sizew '+ oppMap.size());
        
        system.debug('oppMapNdList '+ oppMapNdList);
        system.debug('oppMapNdList sizew '+ oppMapNdList.size());
        
        List<contact> conToUpdate = new List<contact>();
        for(contact con : [select id,Referrers_Amount__c,Referrer_Rating__c, name from contact where Id IN : oppMap.keySet()]){
            string val = con.Referrer_Rating__c;
            con.Referrers_Amount__c = oppMap.get(con.id);
            con.Referrer_Rating__c = 'Blue';
            decimal dc;
            if(oppMapNdList.get(con.id).size() > 0){
                dc  = oppMap.get(con.id) / oppMapNdList.get(con.id).size();
            }
            if((con.Referrers_Amount__c >= 400 && con.Referrers_Amount__c < 800) ||
              	(con.Referrers_Amount__c >= 200 && con.Referrers_Amount__c < 600 && dc >= 30) 
              ){
                con.Referrer_Rating__c = 'Silver';
            }
            if((con.Referrers_Amount__c >= 800 && con.Referrers_Amount__c < 1200) || 
               (con.Referrers_Amount__c >= 600 && con.Referrers_Amount__c < 1000 && dc >= 25) ||
              (con.Referrers_Amount__c >= 400 && con.Referrers_Amount__c < 800 && dc >= 100)
              ){
                 con.Referrer_Rating__c = 'Gold';
            }
            if(con.Referrers_Amount__c >= 1200 || (con.Referrers_Amount__c >= 1000 && dc >= 25) || (con.Referrers_Amount__c >= 800 && dc >= 130)){
                con.Referrer_Rating__c = 'Platinum';
            }
            
            if(val != con.Referrer_Rating__c){
                conToUpdate.add(con);
            }
            
        }
        
        System.debug('size of List++'+conToUpdate.size());
        System.debug('size of List++'+conToUpdate);
        
        if(conToUpdate.size() > 0){
            update conToUpdate;
        }
        
    }

    global void finish(Database.BatchableContext bc) {
        system.debug('batch job id = '+bc.getJobId());
    }
	
}