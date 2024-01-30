public class ContentDocumentTriggerHandler {
    public void beforeDelete(List<ContentDocument> deletedCntDoc){
        Set<Id> contIDs = new Set<Id>();
        Set<Id> newcontIDS = new Set<Id>();
        Set<Id> objId = new Set<Id>();
        Set<Id> contIdsRelToOpp = new Set<Id>();
        if(deletedCntDoc.Size() > 0){
            for (ContentDocument cv : deletedCntDoc) {
                contIDs.add(cv.Id);
            }
        }
        List<ContentVersion> CnVListOld = new List<ContentVersion>();
        if(contIDs.Size() > 0){
            CnVListOld = [SELECT Id, Title, ContentDocumentId,Related__c, Document_Requested__r.Category__c, Current_in_use__c, CreatedDate FROM ContentVersion WHERE ContentDocumentId IN :contIDs ];
            for(ContentVersion Cv : CnVListOld){
                if(Cv != null && Cv.ContentDocumentId != null && cv.Document_Requested__c != null && cv.Related__c != null  && cv.Current_in_use__c == true &&  cv.Document_Requested__r.Category__c == 'Purchase Invoice'){
                    newcontIDS.add(cv.ContentDocumentId);  
                } 
            }
        }
        if (newcontIDS.size() > 0) {
            List<ContentDocumentLink> linkList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN :newcontIDS];
            // system.debug('linkList'+linkList);
            for (ContentDocumentLink link : linkList) {
                if (link.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Opportunity') {
                    objId.add(link.LinkedEntityId);
                    contIdsRelToOpp.add(link.ContentDocumentID);
                }
            }
            // system.debug('objId'+objId);
            // system.debug('contIdsRelToOpp'+contIdsRelToOpp);
            if (objId.size() > 0 && contIdsRelToOpp.size() > 0) {
                List<ContentDocumentLink> oldCntList = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :objId AND ContentDocumentId NOT IN :contIdsRelToOpp];
                if(oldCntList.Size() > 0){
                    Set<Id> cntSetOfOldIds = new Set<Id>();
                    for (ContentDocumentLink cnt : oldCntList) {
                        cntSetOfOldIds.add(cnt.ContentDocumentId);
                    }
                    //  system.debug('cntSetOfOldIds'+cntSetOfOldIds);
                    List<ContentVersion> cntVersionList = new List<ContentVersion>();
                    List<ContentVersion> cntToUpdate = new List<ContentVersion>();
                    if (cntSetOfOldIds.size() > 0) {
                        cntVersionList = [SELECT Id, Title, ContentDocumentId,Category__c, Current_in_use__c, CreatedDate FROM ContentVersion WHERE ContentDocumentId IN :cntSetOfOldIds ORDER BY CreatedDate DESC];
                        //   system.debug('cntVersionList'+cntVersionList);
                        if (cntVersionList.size() > 0) {
                            for(ContentVersion cntv : cntVersionList){
                                if(cntv.Category__c == 'Purchase Invoice' && cntv.Current_in_use__c == false){
                                    cntv.Current_in_use__c = true;
                                    cntToUpdate.add(cntv);
                                    break;
                                }
                            }
                            //    system.debug('cntttToUpdate'+cntToUpdate.Size());
                            //   system.debug('cntttToUpdate'+cntToUpdate);
                            if(cntToUpdate.Size() > 0){
                                //       system.debug('CntDeleted'+cntToUpdate);
                                update cntToUpdate;
                            }
                        }
                    }
                }
            }
        }
    }
}