public class TaskTriggerHandler {
    public void UpdateFundingHandOverTasks(List<Task> newTasks){ 
        List<Funding_Request__c> frListToUpdate = new List<Funding_request__c>();
        map<Id,Id> mapOfTaskFunding = new Map<Id,Id>();
        String FundingHandoverTskDesc = 'IMPORTANT: If the funding handover call is successful, you must mark ‘Sales outcome’ fields = Successful. An SMS will automatically be sent if you save this task as successful with instructions to call the lender back and to let you know if the call was successful.';
        for(Task tk : newTasks){
            system.debug('tkDescription'+tk.Description);
            if(tk.Description != null && FundingHandoverTskDesc.contains(tk.Description) && tk.Status == 'Completed' && tk.Outcome__c == 'Successful'){
                mapOfTaskFunding.put(tk.WhatId,tk.WhoId);
            }  
        } 
        
        if(!mapOfTaskFunding.isEmpty()){
            List<Funding_Request__c> frList = [SELECT Id,Opportunity__c,Applicant_1_A1__r.Name,Applicant_2_A2__r.Name,Applicant_1_A1__r.PersonContactId,Applicant_2_A2__r.PersonContactId,A1_Funding_Call_Handover__c,
                                               Opportunity__r.Customer_Support_Person__r.Name,A2_Funding_Call_Handover__c,Opportunity__r.SyncedQuote.Product__r.Lender_phone_number__c,Applicant_1_A1__r.Phone,
                                               Opportunity__r.Contact_1__c,Opportunity__r.Contact_2__c,Applicant_2_A2__r.Phone FROM Funding_Request__c WHERE Id IN: mapOfTaskFunding.keySet()];
            if(!frList.isEmpty()){
                for(Funding_Request__c fr : frList){
                    if(mapOfTaskFunding.get(fr.Id) == fr.Applicant_1_A1__r.PersonContactId){
                        fr.A1_Funding_Call_Handover__c = System.now();
                        frListToUpdate.add(fr);
                        String smsTextforApp1 = 'Hi '+fr.Applicant_1_A1__r.Name+', '+fr.Opportunity__r.Customer_Support_Person__r.Name+ ' here at Parker Lane.';
                        smsTextforApp1 += ' As promised here the number to call back in case the call gets disconnected ';
                        smsTextforApp1 += fr.Opportunity__r.SyncedQuote.Product__r.Lender_phone_number__c+'. Please shoot me a reply once you’ve ';
                        smsTextforApp1 += 'authorised payment so you don’t receive anymore reminders. And have a great day! ';
                        String SenderId = system.label.SMS_Sender_Id;
                        SMSController.sendApproveExpireMessage('Contact', SenderId,fr.Applicant_1_A1__r.Name,fr.Applicant_1_A1__r.Phone, smsTextforApp1,fr.Opportunity__c,fr.Opportunity__r.Contact_1__c );
                    }  
                    if(fr.Applicant_2_A2__c != null && mapOfTaskFunding.get(fr.Id) == fr.Applicant_2_A2__r.PersonContactId){
                        system.debug('Heloooo2');
                        fr.A2_Funding_Call_Handover__c = System.now();
                        frListToUpdate.add(fr);
                        String smsTextforApp2 = 'Hi '+fr.Applicant_2_A2__r.Name+', '+fr.Opportunity__r.Customer_Support_Person__r.Name+ ' here at Parker Lane.';
                        smsTextforApp2 += ' As promised here the number to call back in case the call gets disconnected ';
                        smsTextforApp2 += fr.Opportunity__r.SyncedQuote.Product__r.Lender_phone_number__c+'. Please shoot me a reply once you’ve ';
                        smsTextforApp2 += 'authorised payment so you don’t receive anymore reminders. And have a great day! ';
                        String SenderId = system.label.SMS_Sender_Id;
                        SMSController.sendApproveExpireMessage('Contact', SenderId,fr.Applicant_2_A2__r.Name,fr.Applicant_2_A2__r.Phone, smsTextforApp2,fr.Opportunity__c,fr.Opportunity__r.Contact_2__c );
                    }  
                }
            }
        }
        
        if(!frListToUpdate.isEmpty()){
            Update frListToUpdate;
        } 
    }
}