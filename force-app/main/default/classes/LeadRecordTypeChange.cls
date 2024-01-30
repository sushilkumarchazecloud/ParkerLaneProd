public class LeadRecordTypeChange {
	
    Public Static String recTypName = 'Home Loan General';
    Public Static RecordType recordTypeObj = [SELECT Id,Name FROM RecordType WHERE Name = :recTypName];
    
    
    Public Static Void changeRecordType(List<Lead> leadList){
        for(Lead newLead : leadList){
            if(newLead.LeadSource == 'outgrow'){
                //System.debug('Old Id - '+newLead.RecordTypeId);
				newLead.RecordTypeId = recordTypeObj.Id;  
                //System.debug('New ID - '+newLead.RecordTypeId);
            }
            
        }
    }
}