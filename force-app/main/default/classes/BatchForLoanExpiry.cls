global class BatchForLoanExpiry implements Database.Batchable<sObject>,Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {  
        List<string> recordTypes = new List<string>{'Solar','Green Loan','Commercial Solar Purchase','Debt Consolidation','Home Improvement','Personal Loan','Vehicle Purchase','Commercial Asset Finance'};
            List<string> stageNm = new List<string>{'Approved','Funding'};
                Set<id> recordTypeIds = new Set<id>();
        for(string st : recordTypes){
            recordTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(st).getRecordTypeId());
        } 
        
        return Database.getQueryLocator('SELECT Id, Name,Purpose__c,Contact_1__c,Customer_Support_Person__c,Customer_Support_Person_Name__c,FinServ__ReferredByContact__c,Applicant_1_FirstName__c,FinServ__ReferredByContact__r.Email,FinServ__ReferredByContact__r.AccountId,StageName,Applicant_1__c,Applicant_2__c,Applicant_1_Email__c,Applicant_2_Email__c ,Applicant_1__r.Phone,Approved_Date__c,Applicant_1__r.personContactId FROM opportunity WHERE RecordTypeId IN : recordTypeIds AND StageName IN: stageNm AND Approved_Date__c != Null '); 
    } 
    
    global void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        Date today = Date.today();
        String Accountid;
        map<id, list<string>> accIdconEmailMap = new map<id, list<string>>(); 
        set<id> refIds = new set<id>();
        for(Opportunity op :scope){
            Integer ExpDays = (op.Approved_Date__c.Date()).daysBetween(today);
            if(op.FinServ__ReferredByContact__c != null && (ExpDays == 60 || ExpDays == 80)){
                Accountid = op.FinServ__ReferredByContact__r.AccountId;
                if(!accIdconEmailMap.containsKey(Accountid )){
                    accIdconEmailMap.put(Accountid, new list<string>());
                }
                refIds.add(op.FinServ__ReferredByContact__r.id);
            }
        } 
        if(!refIds.isEmpty()){
            for(Contact con : [SELECT id,Accountid, Email FROM Contact WHERE AccountId =: accIdconEmailMap.keyset() AND id NOT IN:refIds AND Admin__c=True]){
                if(accIdconEmailMap.containskey(con.Accountid)){
                    if(con.Email != null){
                        accIdconEmailMap.get(con.Accountid).add(con.Email);
                    }
                }
            } 
        }
        Map<String, Id> emailTempIdMap = New Map<String, Id>();
        List<String>  emailTemplateNames = New List<String>{'Customer Email Approved Date 30Days','Customer Email Approved Date 60Days','Customer Email Approved Date 80Days','Ref Email ApprovalExpire 10Days','Ref Email Approved Date 30Days',
            'Customer Email Approved Date 60Days For App2','Customer Email Approved Date 80Days For App2'};    
                for(EmailTemplate emailTemp: [SELECT id, Name  FROM EmailTemplate WHERE Name IN: emailTemplateNames]){
                    emailTempIdMap.put(emailTemp.Name, emailTemp.Id);
                }
        OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address =:UtilityClass.adminEmail];
        List<Messaging.Email> emailList = new List<Messaging.Email>();
        list<task> tklist = new list<task>();
        for(opportunity opp : scope){
            system.debug('Opp'+opp);
            Integer ExpDays = (opp.Approved_Date__c.Date()).daysBetween(today);
            system.debug('ExpDays'+ExpDays);
            if(opp.StageName == 'Approved' && ExpDays == 30){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(emailTempIdMap.get('Customer Email Approved Date 30Days'));
                mail.setTargetObjectId(opp.Contact_1__c);
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setUseSignature(false);
                mail.Setwhatid(opp.Id);
                if( owea.size() > 0){
                    mail.setorgWideEmailAddressId(Owea.get(0).Id);
                }
                List<string> sendTo = new List<string>();
                if(opp.Applicant_1__c != null){
                    SendTo.add(opp.Applicant_1_Email__c);
                }
                mail.setToAddresses(sendTo);
                system.debug('SenTo'+sendTo);
                mail.setReplyTo(UtilityClass.adminEmail);
                system.debug('mail'+mail);
                emailList.add(mail);       
            }  
            if(opp.StageName == 'Approved' && ExpDays == 60){
                List<String> applicantEmailList = new List<String>();
                if(opp.Applicant_1__c !=Null && opp.Applicant_2__c != null){
                    applicantEmailList.add(opp.Applicant_1_Email__c);
                    applicantEmailList.add(opp.Applicant_2_Email__c);
                }
                if(opp.Applicant_1__c != null && opp.Applicant_2__c == null){
                    applicantEmailList.add(opp.Applicant_1_Email__c);
                }
                if(!applicantEmailList.isEmpty()){
                    for(String eml : applicantEmailList){
                        Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
                        if(eml == opp.Applicant_1_Email__c){
                            mail1.setTemplateId(emailTempIdMap.get('Customer Email Approved Date 60Days'));
                        }
                        if(eml == opp.Applicant_2_Email__c){
                            mail1.setTemplateId(emailTempIdMap.get('Customer Email Approved Date 60Days For App2'));
                        }
                        mail1.setTargetObjectId(opp.Contact_1__c);
                        mail1.setTreatTargetObjectAsRecipient(false);
                        mail1.setUseSignature(false);
                        mail1.Setwhatid(opp.Id);
                        if( owea.size() > 0){
                            mail1.setorgWideEmailAddressId(Owea.get(0).Id);
                        }
                        List<string> sendTo = new List<string>();
                        sendTo.add(eml);
                        system.debug('SendToooo---'+SendTo);
                        mail1.setToAddresses(sendTo);
                        mail1.setReplyTo(UtilityClass.adminEmail);
                        emailList.add(mail1); 
                    }
                }
                if(opp.FinServ__ReferredByContact__c != null) {
                    Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage(); 
                    mail2.setTemplateId(emailTempIdMap.get('Ref Email Approved Date 30Days'));
                    mail2.setTargetObjectId(opp.Contact_1__c);
                    mail2.setTreatTargetObjectAsRecipient(false);
                    mail2.setUseSignature(false);
                    mail2.Setwhatid(opp.Id);
                    if( owea.size() > 0){
                        mail2.setorgWideEmailAddressId(Owea.get(0).Id);
                    }
                    List<string> sendList = new List<string>();
                    SendList.add(opp.FinServ__ReferredByContact__r.Email);
                    if(!accIdconEmailMap.isEmpty()){
                        SendList.addAll(accIdconEmailMap.get(opp.FinServ__ReferredByContact__r.AccountId));
                    }
                    system.debug(accIdconEmailMap.get(opp.FinServ__ReferredByContact__r.AccountId));
                    system.debug('sendList is==='+SendList);
                    mail2.setToAddresses(SendList);
                    mail2.setReplyTo(UtilityClass.adminEmail);
                    emailList.add(mail2); 
                } 
            }  
            if((opp.StageName == 'Approved' || opp.StageName == 'Funding') && (ExpDays == 80)){
                List<String> applicantEmailList = new List<String>();
                if(opp.Applicant_1__c !=Null && opp.Applicant_2__c != null){
                    applicantEmailList.add(opp.Applicant_1_Email__c);
                    applicantEmailList.add(opp.Applicant_2_Email__c);
                }
                if(opp.Applicant_1__c != null && opp.Applicant_2__c == null){
                    applicantEmailList.add(opp.Applicant_1_Email__c);
                }
                if(!applicantEmailList.isEmpty()){
                    for(String eml : applicantEmailList){
                        Messaging.SingleEmailMessage mail3 = new Messaging.SingleEmailMessage();
                        if(eml == opp.Applicant_1_Email__c){
                            mail3.setTemplateId(emailTempIdMap.get('Customer Email Approved Date 80Days'));
                        }
                        if(eml == opp.Applicant_2_Email__c){
                            mail3.setTemplateId(emailTempIdMap.get('Customer Email Approved Date 80Days For App2'));
                        }
                        mail3.setTargetObjectId(opp.Contact_1__c);
                        mail3.setTreatTargetObjectAsRecipient(false);
                        mail3.setUseSignature(false);
                        mail3.Setwhatid(opp.Id);
                        if( owea.size() > 0){
                            mail3.setorgWideEmailAddressId(Owea.get(0).Id);
                        }
                        List<string> sendTo = new List<string>();
                        sendTo.add(eml);
                        mail3.setToAddresses(sendTo);
                        mail3.setReplyTo(UtilityClass.adminEmail);
                        emailList.add(mail3); 
                    }
                }
                if(opp.FinServ__ReferredByContact__c != null) {
                    Messaging.SingleEmailMessage mail4 = new Messaging.SingleEmailMessage(); 
                    mail4.setTemplateId(emailTempIdMap.get('Ref Email ApprovalExpire 10Days'));
                    mail4.setTargetObjectId(opp.Contact_1__c);
                    mail4.setTreatTargetObjectAsRecipient(false);
                    mail4.setUseSignature(false);
                    mail4.Setwhatid(opp.Id);
                    if( owea.size() > 0){
                        mail4.setorgWideEmailAddressId(Owea.get(0).Id);
                    }
                    List<string> sendList = new List<string>();
                    SendList.add(opp.FinServ__ReferredByContact__r.Email);
                    if(!accIdconEmailMap.isEmpty()){
                        SendList.addAll(accIdconEmailMap.get(opp.FinServ__ReferredByContact__r.AccountId));
                    }
                    system.debug(accIdconEmailMap.get(opp.FinServ__ReferredByContact__r.AccountId));
                    system.debug('sendList is==='+SendList);
                    mail4.setToAddresses(SendList);
                    mail4.setReplyTo(UtilityClass.adminEmail);
                    emailList.add(mail4); 
                } 
                if(opp.Customer_Support_Person_Name__c != null){
                    String SmsTempText = 'Action Required! Hi'+opp.Applicant_1_FirstName__c+', your'+opp.Purpose__c+' finance approval expires in 10 days. Reply here or refer to email for details. \n';
                    SmsTempText+= opp.Customer_Support_Person_Name__c+' @ Parker Lane.';
                    String SenderId = system.label.SMS_Sender_Id;
                    SMSController.sendApproveExpireMessage('Contact', SenderId,opp.Applicant_1_FirstName__c, opp.Applicant_1__r.Phone, SmsTempText,opp.Id,opp.Contact_1__c );
                }
            }
            if(opp.Customer_Support_Person__c != Null){
                Task tk = new Task();
                if(opp.StageName == 'Approved' && ExpDays == 31){
                    tk.Subject = '31 day check-in call';
                    tk.Description = 'Purely a service call. Check in to see if you can offer any assistance. Ask how the '+Opp.Purpose__c+' process is going. Identify wallet share opportunities. Offer help with anything else.';  
                    tk.WhatId = opp.id;
                    tk.OwnerId = opp.Customer_Support_Person__c;
                    tk.Status = 'Not Started';
                    tk.Priority = 'Low';
                    tklist.add(tk); 
                }  
                else if(opp.StageName == 'Approved' && ExpDays == 61){ 
                    tk.Subject = '61 day reminder';
                    tk.Description = 'Friendly reminder that their approval is set to expire in the next 30 days. Inquire about the status of their '+opp.Purpose__c+' project. Discuss next steps. Close with any wallet share opportunities then offer help with anything else.';  
                    tk.WhatId = opp.id;
                    tk.OwnerId = opp.Customer_Support_Person__c;
                    tk.Status = 'Not Started';
                    tk.Priority = 'Medium';
                    tklist.add(tk); 
                } 
                else if((opp.StageName == 'Approved' || opp.StageName == 'Funding') && ExpDays == 81){  
                    tk.Subject = '9 days to expiry - Call customer AND referrer';
                    tk.Description = 'Call to ascertain the status of their '+opp.purpose__c+' project and keep customer & make appropriate arrangements with your manager and Credit Analyst. As always please keep the referrer updated.';
                    tk.WhatId = opp.id;
                    tk.OwnerId = opp.Customer_Support_Person__c;
                    tk.Status = 'Not Started';
                    tk.Priority = 'High';
                    tklist.add(tk); 
                } 
            } 
        } 
        if(!emailList.isEmpty()){
            system.debug('emailList'+emailList);
            Messaging.sendEmail(emailList);
        } 
        if(!tklist.isEmpty()){ 
            insert tklist;
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