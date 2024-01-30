trigger SendNotificationToOpp on dsfs__DocuSign_Status__c (after insert,after update) {

    List<String> appStages = new List<String>();
    Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for( Schema.PicklistEntry f : ple){
        appStages.add(f.getLabel());
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            Set<Id> oppIds = new Set<Id>();
            for(dsfs__DocuSign_Status__c ds : Trigger.New){
                if(ds.dsfs__Envelope_Status__c == 'Sent' && ds.dsfs__Subject__c.contains('Documents For Your e-Signature')){
                    oppIds.add(ds.dsfs__Opportunity__c);
                }
            }
            
            if(oppIds.size() > 0){
                List<Opportunity> oppList = [SELECT Id, Name, StageName FROM Opportunity WHERE Id IN: oppIds];
                if(oppList.size() > 0){
                    for(Opportunity opp : oppList){
                        if(appStages.indexOf(opp.StageName) < appStages.indexOf('Packs Out')){
                            opp.StageName='Packs Out';
                        }
                    }
                    update oppList;
                }
            }
        }
        if(Trigger.isUpdate){
            Set<Id> oppIds = new Set<Id>();
            for(dsfs__DocuSign_Status__c ds : Trigger.New){
                if(ds.dsfs__Envelope_Status__c == 'Completed' && ds.dsfs__Subject__c.contains('Documents For Your e-Signature')){
                    oppIds.add(ds.dsfs__Opportunity__c);
                }
            }
            
            if(oppIds.size() > 0){
                List<Opportunity> oppList = [SELECT Id, Name,Documents_Outstanding__c,App_1_VOI_eSign_Complete__c,App_2_VOI_eSign_Complete__c, StageName, Applicant_1__r.Name,Owner.Name, Owner.Email,
                                (SELECT Purpose__c,Total_loan_amount__c FROM Quotes WHERE Application__c = true)
                               FROM Opportunity WHERE Id IN: oppIds];
                               
                if(oppList.size() > 0){
                    
                    for(Opportunity opp : oppList){
                        if(appStages.indexOf(opp.StageName) < appStages.indexOf('Packs Back')){
                            opp.StageName='Packs Back';
                        }
                    }
                    update oppList;
                    
                    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                    
                    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'chris.white@parkerlane.com.au'];
                    
                    for(Opportunity opp : oppList){
                        
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        if ( owea.size() > 0 ) {
                            message.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        message.toAddresses = new String[] {opp.Owner.Email};
                        message.subject = 'SIGNED: '+opp.Applicant_1__r.Name+' has signed the credit quote and proposal for '+opp.Quotes[0].Purpose__c;
                        message.setHTMLBody(opp.Owner.Name+',<br/><br/>'+opp.Applicant_1__r.Name+' signed the credit proposal at '+System.Now()+'.<br/><br/>TAKE ACTION: Review file and contact the customer immediately.<br/><br/>Opportunity: <a href="https://lanecorp.my.salesforce.com/'+opp.Id+'" target="_blank">'+opp.Name+'</a><br/>Amount: $'+opp.Quotes[0].Total_Loan_Amount__c+'<br/>Purpose: '+opp.Quotes[0].Purpose__c+'<br/>Owner: '+opp.Owner.Name+'<br/><br/>Thanks.');
                        
                        mails.add(message);
                    }
                    
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                                        
                }
                
            }
        }    
    }
    
    
}