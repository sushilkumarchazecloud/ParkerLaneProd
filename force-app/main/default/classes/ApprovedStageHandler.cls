public class ApprovedStageHandler {
    @AuraEnabled
    public static Opportunity getOpp(String oppId){
      Opportunity opp =[SELECT Id,StageName, Approved_Date__c FROM Opportunity WHERE Id=: oppId LIMIT 1];
            return opp; 
    }
    
    @AuraEnabled
    public static string UpdateOppToApprovedStage(String oppId, Datetime ApprovedDate){
        Opportunity opp =[SELECT Id,StageName, Approved_Date__c,RecordTypeId, RecordType.BusinessProcessId,SyncedQuoteId FROM Opportunity WHERE Id=: oppId LIMIT 1];
        String isMandateStageSkipped = '';   
        List<String> appStagesList = UtilityClass.getPicklistValues('Opportunity', 'StageName'); 
        Id busProcessIds ;
        String ConfigStage = '';
        String rtval = '';
        if(opp.RecordTypeId != Null && opp.RecordType.BusinessProcessId != Null){
            busProcessIds = opp.RecordType.BusinessProcessId;
            BusinessProcess bp =  [SELECT Id, Name FROM BusinessProcess where Id=: busProcessIds];
            Configuration__c config = Configuration__c.getValues(bp.Name + ' Mandatory Stages');
            if(config != NULL) ConfigStage = config.Stages__c;
            
            list<id> recTypeId = new list<id>{'0120o000001lPSGAA2','0120o000001lOfBAAU','0120o000001lPS9AAM','0120o000001lPS7AAM','0120o000001lOfDAAU','0120o000001lOfIAAU'};
                if(busProcessIds != Null && opp.RecordTypeId != Null && ConfigStage != Null){
                    for(String st: ConfigStage.split(';')){ 
                        system.debug('ConfigStage'+st);
                        system.debug('OppStage'+opp.StageName);
                        if(appStagesList.indexOf('Approved') > appStagesList.indexOf(st) && appStagesList.indexOf(st) > appStagesList.indexOf(opp.StageName)){
                            isMandateStageSkipped += st +', ';
                            system.debug('isMandateStageSkipped'+isMandateStageSkipped);
                        }
                    }
                }
            isMandateStageSkipped = isMandateStageSkipped.removeEnd(', ');
            system.debug('isMandateStageSkipped--1'+isMandateStageSkipped);
            if(String.isNotBlank(isMandateStageSkipped)){
               rtval =  'You cant skip mandatory stage: ' + isMandateStageSkipped;
               system.debug('isMandateStageSkipped--2'+isMandateStageSkipped);
            }              
        }    
        if(!rtval.contains('You cant skip mandatory stage: ')){
            List<String> recTypeNames = New List<String>{'Personal Loan', 'Debt Consolidation','Green Loan','Home Improvement','Vehicle loan'};
                if(opp.StageName != 'Approved' && recTypeNames.contains(UtilityClass.allOppRecordTypeNameById.get(opp.recordTypeId))){
                    Map<Id, Boolean> docCheckMap = New Map<Id, Boolean>(); 
                    Map<Id, Id> docIdWithLinkedIdMap = New Map<Id, Id>(); 
                    List<ContentDocumentLink> cdList = [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: oppId];
                    for(ContentDocumentLink Cd : cdList){
                        docIdWithLinkedIdMap.put(Cd.ContentDocumentId, Cd.LinkedEntityId);
                    } 
                    
                    for(ContentVersion cv : [SELECT ContentDocumentId,VersionData,Title FROM ContentVersion WHERE ContentDocumentId =: docIdWithLinkedIdMap.keySet() AND Category__c = 'Lender Credit Contract']){
                        docCheckMap.put(docIdWithLinkedIdMap.get(cv.ContentDocumentId), true);
                    }
                    
                    Id syncQuoteId;
                    syncQuoteId = opp.SyncedQuoteId;
                    
                    Map<Id,boolean> OppIdProductMap= New Map<Id,boolean>();
                    for(Quote qt : [SELECT Id,OpportunityId,Product__c, Product__r.Contract_Required__c FROM Quote WHERE Id =: syncQuoteId]){
                        OppIdProductMap.put(qt.OpportunityId,qt.Product__r.Contract_Required__c);            
                    }
                    if(OppIdProductMap.get(opp.Id)==True && recTypeNames.contains(UtilityClass.allOppRecordTypeNameById.get(opp.recordTypeId)) ){
                        if(!docCheckMap.containsKey(opp.Id)){
                            rtval = 'You can not move to Approved until a Lender Credit Contract document has been uploaded to the opportunity.'; 
                        }
                    }
                } 
        }
        
        if(!rtval.contains('You cant skip mandatory stage: ') && !rtval.contains('You can not move to Approved until a Lender Credit Contract document has been uploaded to the opportunity.')){
            opp.Approved_Date__c = ApprovedDate;
            opp.StageName = 'Approved';
            OpportunityTriggerHandler.isByPassApprovedValidation = true;
            update opp;
            OpportunityTriggerHandler.isByPassApprovedValidation = false;
            rtval =  'Stage Changed Successfully.';
        }
        
        return rtval;
    }
}