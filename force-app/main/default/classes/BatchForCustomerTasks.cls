global class BatchForCustomerTasks implements Database.Batchable<sObject>,Database.Stateful {
	
    global Database.QueryLocator start(Database.BatchableContext bc) {
        list<string> stage = new List<string>{'CPA Done', 'Packs Out'};
        return Database.getQueryLocator('SELECT Id,RecordTypeId, name,Customer_Support_Person__c,StageName,CPA_Done_Date__c,Packs_Out_Date__c,LastStageChangeDate FROM opportunity WHERE stageName IN : stage');
    }

    global void execute(Database.BatchableContext bc, List<opportunity> scope) {
        System.debug('---+_+'+scope.size());
        Id chris = [select id from user where username =: System.Label.Admin_User_Name].id;
        List<string> bussinessDay = new List<string>{'1', '3', '5', '8', '15', '25', '40'};
            List<task> tskList = new LIst<task>();
        List<string> recordTypes = new List<string>{'Solar','Green Loan','Home Improvement','Debt Consolidation','Personal Loan','Vehicle Purchase'};
        BusinessHours bhs = [select id,MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime from BusinessHours WHERE IsDefault = true LIMIT 1];
        for(opportunity op : scope){
            if(recordTypes.contains(Schema.SObjectType.opportunity.getRecordTypeInfosById().get(op.RecordTypeId).getName()) &&
               op.CPA_Done_Date__c != null){                
                date dueDate = system.today();
                DateTime myDateTime = DateTime.now();
                String dayOfWeek = myDateTime.format('EEEE');
                Time myTime = system.now().time();
                if(!(dayOfWeek.equalsIgnoreCase('Sunday') || dayOfWeek.equalsIgnoreCase('Saturday'))){
                    string startfield = dayOfWeek+'StartTime';
                    string endfield = dayOfWeek+'EndTime';
                    if(myTime >= (time)bhs.get(startfield) && myTime <= (time)bhs.get(endfield)){
                        system.debug('--in-');
                        dueDate = system.today();
                    }
                    else{
                        if(dayOfWeek.equalsIgnoreCase('Saturday')){
                            dueDate = date.valueOf(myDateTime.addDays(2));
                        }
                        if(dayOfWeek.equalsIgnoreCase('Sunday')){
                            dueDate = date.valueOf(myDateTime.addDays(1));
                        }
                    }
                }
                System.debug('due date---'+op.CPA_Done_Date__c.date());
                date dt = op.CPA_Done_Date__c.date();
                integer totalDay = dt.daysBetween(dueDate);
                system.debug('-=-= '+string.valueOf(totalDay));
                if(bussinessDay.contains(string.valueOf(totalDay))){
                    system.debug('--yes today is the day---');
                    string title = 'Day '+ totalDay +' Information Outstanding follow up call.';
                    Task t = new Task();
                    t.Subject = title;
                    t.WhatId = op.Id;
                    t.OwnerId = (op.Customer_Support_Person__c != null ? op.Customer_Support_Person__c : chris);
                    t.Status = 'Not Started';
                    t.ActivityDate = dueDate;
                    t.Priority = 'High';
                    tskList.add(t);
                }
            }           
        }
        System.debug('---'+ tskList);
        if(tskList != null && tskList.size() > 0){
            insert tskList;
        }
    }

    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations - send emails, notify clients,
        // give a call to another batch class
        // Can give to another batch class
        // Can give callout request
        system.debug('batch job id = '+bc.getJobId());
    }
	
}