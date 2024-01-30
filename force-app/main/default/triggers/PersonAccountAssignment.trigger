trigger PersonAccountAssignment on Lead (after update) {
    
    Id householdAccRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
    Id OppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Green Loan').getRecordTypeId();
    List<Opportunity> oppList = new List<Opportunity> ();
    Map<Id, Account> houseHoldMap = new Map<Id, Account>();
    List<Lead> changedOwner = new List<Lead>();
    
        
    if(Trigger.isAfter && Trigger.isUpdate){
        for(Lead lead : Trigger.New){
            if(lead.OwnerId != Trigger.oldMap.get(lead.Id).OwnerId && (Trigger.oldMap.get(lead.Id).OwnerName__c == 'Chris White' || Trigger.oldMap.get(lead.Id).OwnerName__c == 'Lanecorp Site Guest User')){
                changedOwner.add(lead);            
            }
            
            if (lead.IsConverted && lead.convertedOpportunityId != null){
                Account householdAccount = new Account(Name = lead.FirstName + ' ' + lead.LastName +' Household', RecordTypeId = householdAccRTId);
                houseHoldMap.put(lead.convertedOpportunityId,householdAccount);
                oppList.add(new Opportunity(Id = lead.convertedOpportunityId,RecordTypeId = OppRTId, Applicant_1__c = lead.convertedAccountId, StageName = 'Working'));
            }
            
        }
        if(changedOwner.size() > 0){
            if(UserInfo.getUserId() != Trigger.oldMap.get(changedOwner[0].Id).OwnerId){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'chris.white@parkerlane.com.au'];
                
                if ( owea.size() > 0 ) {
                    message.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                message.toAddresses = new String[] {'chris.white@parkerlane.com.au'};
                message.subject = UserInfo.getName()+' has changed a Lead from '+Trigger.oldMap.get(changedOwner[0].Id).OwnerName__c+' to '+changedOwner[0].OwnerName__c;
                message.setHTMLBody('Dear Chris,<br/><br/>'+UserInfo.getName()+' changed the following Lead:<br/>Previous Owner: '+Trigger.oldMap.get(changedOwner[0].Id).OwnerName__c+'<br/>New Owner: '+changedOwner[0].OwnerName__c+'<br/> Lead Name: <a href="https://lanecorp.my.salesforce.com/'+changedOwner[0].Id+'" target="_blank">'+changedOwner[0].FirstName+' '+changedOwner[0].LastName+'</a><br/><br/>Thanks.');
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }
        }
        if(houseHoldMap.values().size() > 0){
            insert houseHoldMap.values();
        }
        if(oppList.size() > 0){
            for(Opportunity opp : oppList){
                if(houseHoldMap.get(opp.Id).Id != null){
                    opp.FinServ__Household__c = houseHoldMap.get(opp.Id).Id;
                    opp.AccountId = houseHoldMap.get(opp.Id).Id;
                }
            }
            update oppList;
        }
    }
    
}