trigger DocumentRequestedTrigger on Document_Requested__c (after insert, after update, after delete) {
	Set<Id> oppIds = New Set<Id>();
    if(Trigger.isDelete){
        for (Document_Requested__c dr : Trigger.Old){
            if(dr.Opportunity__c != NULL ){
                oppIds.add(dr.Opportunity__c );
            }
        }
    }else{
        for (Document_Requested__c dr : Trigger.New){
            if(dr.Opportunity__c != NULL ){
                oppIds.add(dr.Opportunity__c );
            }
        }
    }
    List<Opportunity> oppListToUpdate = New List<Opportunity>();
    
    for(Opportunity opp : [SELECT Id, Documents_Outstanding__c, Documents_Received__c,Docs_Outstanding__c, (SELECT Id, isComplete__c, Document__c, Person_Account__c, Person_Account__r.Name FROM Documents_Requested__r) FROM Opportunity WHERE Id in: oppIds]){
        String docOutstanding = '';
        Double count = 0;
        for(Document_Requested__c dr : opp.Documents_Requested__r){
            if(!dr.isComplete__c){
                //docOutstanding += dr.Document__c + ', ' + (dr.Person_Account__c !=Null ? dr.Person_Account__r.Name: 'General') + '\n';
                docOutstanding += dr.Document__c + (dr.Person_Account__c !=Null ? + ' (' + dr.Person_Account__r.Name +'); ' : '; ') ;
                count+= 1;
            }  
        }
        if(String.isBlank(docOutstanding)){
            docOutstanding = 'No more documents outstanding';
        }
        opp.Documents_Outstanding__c = docOutstanding;
        opp.Docs_Outstanding__c = count;
        oppListToUpdate.add(opp);
    }
    if(!oppListToUpdate.isEmpty() && OpportunityTriggerHandler.check){
        update oppListToUpdate;
    }
        
}