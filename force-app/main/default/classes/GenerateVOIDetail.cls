public class GenerateVOIDetail {
	
    @AuraEnabled 
    public static string GenerateVOI(id recId){
       
        VOI_status__c voiS = [Select id,Contact__c,Opportunity__c, name,VOI_Detail__c from VOI_status__c WHERE id =: recId];
        
        if(voiS.VOI_Detail__c != null){
            return 'Error';
        }
        else{
            VOI_detail__c obj = new VOI_detail__c();
            obj.Contact__c = vois.Contact__c;
			insert obj;    
            voiS.VOI_Detail__c = obj.id;
            update vois;
            return '';
        }
        
        
    }
    
}