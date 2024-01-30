global class BatchForFundingTasks implements Database.Batchable<sObject>,Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        String query = 'SELECT Id, Opportunity__c,Opportunity__r.SyncedQuote.Product__r.Funding_Authorisation_Type__c,Funding_On_Hold__c,Request_Status__c,';
        query += 'Applicant_1_A1__c,Applicant_2_A2__c,Opportunity__r.Customer_Support_Person__c,Date_Last_Request_Status_Changes__c,Customer_Authorisation_Type__c,Opportunity__r.Lender__c, ';
        query += 'Applicant_1_A1__r.PersonContactId,Applicant_2_A2__r.PersonContactId, Customer_Authorisation_Status__c,BusinessDays__c,Opportunity__r.Approved_Expire_Date__c, A1_Funding_Call_Handover__c,A2_Funding_Call_Handover__c,';
        query += 'Opportunity__r.FinServ__ReferredByContact__c,Opportunity__r.Referred_by_Company__c,Opportunity__r.Referred_by_Company__r.Account_manager__c, Opportunity__r.Name FROM Funding_Request__c WHERE Opportunity__c != null';
        return Database.getQueryLocator(query); 
        //Opportunity__c = \'0069h000004awuPAAQ\''
    } 
    
    global void execute(Database.BatchableContext bc, List<Funding_Request__c> frList) {
        boolean managed = false;
        boolean unmanaged = false;
        Datetime today = System.Now();
        String Description1 = 'Contact the applicant to assist them with funding. Ensure they are aware that they may face interest and penalties from the supplier if they delay payment. If there is a reason, place the funding on hold and notify the referrer immediately.';
        String Description2 = 'Make contact with the referrer to inform them of our activity and suggest what they can do to assist with funding.';
        String Description3 = 'Call to the referrer (contact or account contact) to give them an update and explain what they can do to assist.';
        //Kunal Sir Code for Business Days logic Starts.
        DateTime myDateTime = DateTime.now();
        String dayOfWeek = myDateTime.format('EEEE');
        List<Funding_Request__c> frListToUpdate = new List<Funding_Request__c>();
        for(Funding_Request__c fundReq : frList){
            Integer days = (fundReq.Date_Last_Request_Status_Changes__c.Date()).daysBetween(system.today());
            Datetime dt = fundReq.Date_Last_Request_Status_Changes__c;
            fundReq.BusinessDays__c = 0;
            for(integer i=1; i<=days; i++){
                Datetime diff = dt + i;
                if(diff.format('EEEE') != 'Saturday' && diff.format('EEEE') != 'Sunday'){
                    fundReq.BusinessDays__c += 1;
                }
            }
            frListToUpdate.add(fundReq);
        }
        if(!frListToUpdate.isEmpty()){
            update frListToUpdate; 
        }
        
        map<id,decimal> fundMap = new map<id,decimal>();
        for(Funding_Request__c fReq : frList){
            fundMap.put(fReq.id,fReq.BusinessDays__c);   
        }
        // Kunal Sir Code End.
        
        map<Id,Id> mapOfFundingandOppCsmtrSupport = new map<Id,Id>();
        map<Id,Id> mapofAppandFundingForManaged = new map<Id,Id>();
        map<Id,String> mapOfFundingandTaskTitle = new map<Id,String>();
        map<Id,String> mapOfFundingandTaskDesc = new map<Id,String>();
        map<Id,String> mapforUnManagedTask = new Map<Id,String>();
        map<Id,Id> mapofAppandFunding = new Map<Id,Id>();
        map<Id,Id> mapOfAppandappPersonContact = new Map<Id,Id>();
        
        for(Funding_Request__c fr :frList){
            integer daysBtwnnTdyAndLstReqSts = integer.valueOf(fundMap.get(fr.Id));
            if(fr.Opportunity__r.SyncedQuote.Product__r.Funding_Authorisation_Type__c == 'Managed via Parker Lane' && !fr.Funding_On_Hold__c 
               && (fr.Request_Status__c == 'Payment requested by supplier' || fr.Request_Status__c == 'Payment requested by customer') && fr.Opportunity__r.Approved_Expire_Date__c > today.Date() 
               && fr.Customer_Authorisation_Status__c != 'Authorised' && fr.Customer_Authorisation_Status__c != null && fr.Opportunity__r.Customer_Support_Person__c != null){
                   managed = true;
                   mapOfFundingandOppCsmtrSupport.put(fr.Id,fr.Opportunity__r.Customer_Support_Person__c);
                   List<Integer> daysForTasks1 = new List<Integer>{1,2,3,4,5};
                       if(fr.Customer_Authorisation_Type__c == 'Either to sign' && fr.Customer_Authorisation_Status__c != 'Authorised'){
                           if(daysForTasks1.Contains(daysBtwnnTdyAndLstReqSts)){
                               mapofAppandFundingForManaged.put(fr.Applicant_1_A1__c, fr.Id);
                               mapOfFundingandTaskDesc.put(fr.Id,Description1);  
                               Integer i = daysBtwnnTdyAndLstReqSts; 
                               String taskTitle = 'Day '+i+' Funding Authorisation Outstanding A1';
                               mapOfFundingandTaskTitle.put(fr.Applicant_1_A1__c,taskTitle);
                           }
                       }
                   else if (fr.Customer_Authorisation_Type__c == 'Both to sign'){
                       if(daysForTasks1.Contains(daysBtwnnTdyAndLstReqSts)){
                           mapOfFundingandTaskDesc.put(fr.Id,Description1);
                           Integer i = daysBtwnnTdyAndLstReqSts; 
                           if(fr.Customer_Authorisation_Status__c == 'Request sent to customer(s)'){ 
                               if(fr.Applicant_2_A2__c == null){
                                   mapofAppandFundingForManaged.put(fr.Applicant_1_A1__c, fr.Id);
                                   String taskTitle = 'Day '+i+' Funding Authorisation Outstanding A1';
                                   mapOfFundingandTaskTitle.put(fr.Applicant_1_A1__c,taskTitle);
                               } 
                               else if(fr.Applicant_2_A2__c != null){
                                   mapofAppandFundingForManaged.put(fr.Applicant_1_A1__c, fr.Id);
                                   mapofAppandFundingForManaged.put(fr.Applicant_2_A2__c, fr.Id);
                                   String taskTitle = 'Day '+i+' Funding Authorisation Outstanding A1';
                                   mapOfFundingandTaskTitle.put(fr.Applicant_1_A1__c,taskTitle);
                                   String taskTitleForapp2 = 'Day '+i+' Funding Authorisation Outstanding A2';
                                   mapOfFundingandTaskTitle.put(fr.Applicant_2_A2__c,taskTitleForapp2);
                               }
                           }
                           else if(fr.Customer_Authorisation_Status__c == 'Pending Applicant 1'){
                               String taskTitle = 'Day '+i+' Funding Authorisation Outstanding A1';
                               mapofAppandFundingForManaged.put(fr.Applicant_1_A1__c, fr.Id);
                               mapOfFundingandTaskTitle.put(fr.Applicant_1_A1__c,taskTitle);
                           }
                           else if(fr.Customer_Authorisation_Status__c == 'Pending Applicant 2'){
                               String taskTitleForapp2 = 'Day '+i+' Funding Authorisation Outstanding A2';
                               mapofAppandFundingForManaged.put(fr.Applicant_2_A2__c, fr.Id);
                               mapOfFundingandTaskTitle.put(fr.Applicant_2_A2__c,taskTitleForapp2);
                           }
                       }    
                   }
                   
               }
            if(fr.Opportunity__r.SyncedQuote.Product__r.Funding_Authorisation_Type__c == 'Managed via Parker Lane' && !fr.Funding_On_Hold__c && fr.Opportunity__r.Customer_Support_Person__c != null
               && (fr.Request_Status__c == 'Payment requested by supplier' || fr.Request_Status__c == 'Payment requested by customer') && fr.Opportunity__r.Approved_Expire_Date__c > today.Date()){
                   managed = true;
                   mapOfFundingandOppCsmtrSupport.put(fr.Id,fr.Opportunity__r.Customer_Support_Person__c);
                   List<Integer> daysForTasks2 = new List<Integer>{6,7,8,9,10};
                       if(daysForTasks2.Contains(daysBtwnnTdyAndLstReqSts)){
                           Integer i = daysBtwnnTdyAndLstReqSts;
                           String taskTitle = 'Day '+i+' Funding Outstanding Referrer Update Call';
                           mapofAppandFundingForManaged.put(fr.Applicant_1_A1__c, fr.Id);
                           mapOfFundingandTaskTitle.put(fr.Applicant_1_A1__c,taskTitle); 
                           mapOfFundingandTaskDesc.put(fr.Id,Description2);
                       }
               }
            
            //Unmanaged Tasks.
            if(fr.Opportunity__r.SyncedQuote.Product__r.Funding_Authorisation_Type__c == 'Direct with lender' && !fr.Funding_On_Hold__c && fr.Opportunity__r.Customer_Support_Person__c != null
               && (fr.Request_Status__c == 'Payment requested by supplier' || fr.Request_Status__c == 'Payment requested by customer') && fr.Opportunity__r.Approved_Expire_Date__c > today.Date()){
                   List<Integer> daysForTasks3 = new List<Integer>{0,1,2,4,6,8,10,13,16,19,22,25,30,40,50,60};
                       mapOfFundingandOppCsmtrSupport.put(fr.Id,fr.Opportunity__r.Customer_Support_Person__c);
                   if(fr.Customer_Authorisation_Type__c == 'Either to sign'){
                       if(daysForTasks3.Contains(daysBtwnnTdyAndLstReqSts)){
                           unmanaged = true;
                           Integer i = daysBtwnnTdyAndLstReqSts;
                           String ttl =  'Day '+i+' Funding Handover Call '+fr.Opportunity__r.Lender__c;
                           if(fr.A1_Funding_Call_Handover__c == null && fr.A2_Funding_Call_Handover__c == null){
                               mapforUnManagedTask.put(fr.Applicant_1_A1__c,ttl); 
                               mapofAppandFunding.put(fr.Applicant_1_A1__c,fr.Id);
                               mapOfAppandappPersonContact.put(fr.Applicant_1_A1__c,fr.Applicant_1_A1__r.PersonContactId);
                           } 
                       }
                   }
                   
                   else if(fr.Customer_Authorisation_Type__c == 'Both to sign'){
                       if(daysForTasks3.Contains(daysBtwnnTdyAndLstReqSts)){
                           unmanaged = true;
                           Integer i = daysBtwnnTdyAndLstReqSts;
                           String ttl =  'Day '+i+' Funding Handover Call '+fr.Opportunity__r.Lender__c;
                           if(fr.Applicant_2_A2__c != null){
                               if(fr.A1_Funding_Call_Handover__c == null){
                                   mapforUnManagedTask.put(fr.Applicant_1_A1__c,ttl); 
                                   mapofAppandFunding.put(fr.Applicant_1_A1__c,fr.Id);
                                   mapOfAppandappPersonContact.put(fr.Applicant_1_A1__c,fr.Applicant_1_A1__r.PersonContactId);
                               } 
                               if(fr.A2_Funding_Call_Handover__c == null){
                                   mapforUnManagedTask.put(fr.Applicant_2_A2__c,ttl); 
                                   mapofAppandFunding.put(fr.Applicant_2_A2__c,fr.Id);
                                   mapOfAppandappPersonContact.put(fr.Applicant_2_A2__c,fr.Applicant_2_A2__r.PersonContactId);
                               }
                           }
                           else if(fr.Applicant_2_A2__c == null && fr.A1_Funding_Call_Handover__c == null){
                               mapforUnManagedTask.put(fr.Applicant_1_A1__c,ttl); 
                               mapofAppandFunding.put(fr.Applicant_1_A1__c,fr.Id);
                               mapOfAppandappPersonContact.put(fr.Applicant_1_A1__c,fr.Applicant_1_A1__r.PersonContactId);
                           }
                           
                       }  
                   }
               }
            
            //Unmanaged 4th.
            if(fr.Opportunity__r.SyncedQuote.Product__r.Funding_Authorisation_Type__c == 'Direct with lender' && fr.Opportunity__r.FinServ__ReferredByContact__c != null 
               && (fr.Request_Status__c == 'Payment requested by supplier' || fr.Request_Status__c == 'Payment requested by customer') && fr.Opportunity__r.Approved_Expire_Date__c > today.Date()){
                   managed = true;
                   List<Integer> daysForTasks4 = new List<Integer>{5,10,20,30,40,50,60};
                       if(daysForTasks4.Contains(daysBtwnnTdyAndLstReqSts)){
                           Integer i = daysBtwnnTdyAndLstReqSts; 
                           mapOfFundingandTaskDesc.put(fr.Id,Description3);
                           mapofAppandFundingForManaged.put(fr.Applicant_1_A1__c, fr.Id);
                           String taskTitle = 'Day '+i+' call to referrer - funding not authorised';
                           mapOfFundingandTaskTitle.put(fr.Applicant_1_A1__c,taskTitle);
                           if(fr.Opportunity__r.Referred_by_Company__c != null && fr.Opportunity__r.Referred_by_Company__r.Account_manager__c != null){
                               mapOfFundingandOppCsmtrSupport.put(fr.Id,fr.Opportunity__r.Referred_by_Company__r.Account_manager__c);
                           }
                           else if(fr.Opportunity__r.Customer_Support_Person__c != null){
                               mapOfFundingandOppCsmtrSupport.put(fr.Id,fr.Opportunity__r.Customer_Support_Person__c );
                           }  
                       }
               }
        }
        
        
        List<Task> tasksToInsert = new List<Task>();
        //Managed Tasks.
        if(!mapofAppandFundingForManaged.isEmpty() && !mapOfFundingandTaskTitle.isEmpty() && !mapOfFundingandOppCsmtrSupport.isEmpty() && managed == true){
            for (Id appId : mapofAppandFundingForManaged.keySet()) {
                Id Funding_reqId = mapofAppandFundingForManaged.get(appId);
                Task tk = new Task();
                tk.WhatId = mapofAppandFundingForManaged.get(appId); 
                tk.Subject = mapOfFundingandTaskTitle.get(appId); 
                tk.Description = mapOfFundingandTaskDesc.get(Funding_reqId);  
                tk.OwnerId = mapOfFundingandOppCsmtrSupport.get(Funding_reqId);
                tk.ActivityDate =  Date.today();
                tk.Type = 'Call';
                tk.Priority = 'Medium';
                tasksToInsert.add(tk);
            }
        }
        //Unmanaged Tasks.
        if(!mapforUnManagedTask.isEmpty() && !mapOfFundingandOppCsmtrSupport.isEmpty() && unmanaged == true){
            for (Id appId : mapforUnManagedTask.keySet()) {
                Id Funding_reqId = mapofAppandFunding.get(appId);
                Task tk = new Task();
                tk.WhatId = mapofAppandFunding.get(appId); 
                tk.WhoId = mapOfAppandappPersonContact.get(appId);
                tk.Subject = mapforUnManagedTask.get(appId); 
                /* Task trigger is depends on Description for the functionality */
                tk.Description = 'IMPORTANT: If the funding handover call is successful, you must mark ‘Sales outcome’ fields = Successful. An SMS will automatically be sent if you save this task as successful with instructions to call the lender back and to let you know if the call was successful.';  
                tk.OwnerId = mapOfFundingandOppCsmtrSupport.get(Funding_reqId);
                tk.ActivityDate =  Date.today();
                tk.Type = 'Call';
                tk.Priority = 'Medium';
                tasksToInsert.add(tk);
            }
        } 
        
        if (!tasksToInsert.isEmpty()){ 
            insert tasksToInsert; 
        } 
    }  
    
    
    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations - send emails, notify clients,
        // give a call to another batch class
        // Can give to another batch class
        // Can give callout request
    }
}