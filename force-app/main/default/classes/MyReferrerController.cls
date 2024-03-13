public without sharing class MyReferrerController {
    public static final String adminEmail = 'tazeem.khan@chazecloud.com';
    public static final String guestUserName = 'Lanecorp Site Guest User';
    public static final String personalCreditEmailId = 'tazeem.khan@chazecloud.com';
   /* private static Map<String, Id> oppRecordTypeMap = New Map<String, Id>{
        'Solar' => Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Green Loan').getRecordTypeId(),
            'Home Improvement' => Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Home Improvement').getRecordTypeId(),
            'Debt Consolidation' => Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Debt Consolidation').getRecordTypeId()};*/
                
                @AuraEnabled
                public static List<getMyReferralWrapper> getMyRefferals(String searchKey, String conId, String Str){
                    try{
                        contact con = [SELECT Id, Name,Portal_View__c,Admin__c,AccountId FROM Contact WHERE Id=: conId];
                        List<Contact> conList = new List<Contact>(); 
                        if(con.Portal_View__c == 'Admin View' && con.Admin__c){
                            conList = [SELECT Id, Name FROM Contact WHERE AccountId = : con.AccountId];
                        }
                        else{
                            conList = [SELECT Id, Name FROM Contact WHERE id =: con.Id];
                        }
                        
                        List<Opportunity> oppList = new List<Opportunity>();
                        String query ='SELECT id,Name,Contact_1__c,Contact_2__c,SyncedQuoteId,Docs_Outstanding__c,App_1_VOI_eSign_Complete__c,Applicant_1__r.personContactId,Applicant_2__r.personContactId,App_2_VOI_eSign_Complete__c,Stagename,Applicant_1__c,Applicant_1_Name__c,';
                        query += 'Applicant_2_Name__c, Applicant_1_Email__c,Applicant_1_Phone_Number__c, CreatedDate,Applicant_1__r.FirstName,Applicant_1__r.LastName, Applicant_1__r.PersonEmail, Applicant_1__r.Phone,Applicant_2__c,Applicant_2__r.Phone,Lender__c,LeadId__c,';
                        query +=  'Loan_Amount__c,Status__c,Current_Application_Sections__c,Total_Funds_Available__c, ReferredByContact__r.Name,ReferredByContact__r.Email,ReferredByContact__r.Referrer_Rating__c,ReferredByContact__c,';
                        query += 'Applicant_1__r.Name, Application_Pending_Notes__c,RecordType.Name,Line_Chart_JSON__c,installationAddressLineOne__c,Applicant_1__r.Number_of_applicants_to_operate_account__pc,SyncedQuote.Product__r.Funding_Options_Available__c, ';
                        query +='SyncedQuote.Customer_Amount__c,SyncedQuote.Product__r.No_of_Signatories_allowed__c,SyncedQuote.Product__r.Instruction_In_full_after_installation__c,SyncedQuote.Product__r.Instruction_In_full_before_installation__c, ';
                        query += 'SyncedQuote.Product__r.Instruction_Part_payment_before__c, SyncedQuote.Product__r.Surplus_Instructions__c,SyncedQuote.Product__r.Short_Fall_Instructions__c,Approved_Expire_Date__c FROM Opportunity WHERE ReferredByContact__c IN: conlist';
                        if ( searchKey != Null ) {  
                            if ( Str != null ){
                                String key = '%' + searchKey + '%';
                                query += ' AND Name LIKE :key ORDER BY '+Str;
                                oppList = Database.query(query);
                            }
                            else{
                                String key = '%' + searchKey + '%';
                                query += ' AND Name LIKE :key ORDER By CreatedDate DESC'; 
                                oppList = Database.query(query); 
                            }
                            
                        }
                        else if ( Str != null ){
                            query += ' ORDER BY '+Str;
                            oppList = Database.query(query);
                        }
                        
                        else{
                            oppList = [SELECT id,Name,StageName,Docs_Outstanding__c,SyncedQuoteId,Applicant_2__r.Phone,Contact_1__c, 
                                       Applicant_1__c,Applicant_1_Name__c,Applicant_2_Name__c,App_1_VOI_eSign_Complete__c,Contact_2__c,
                                       Applicant_1_Email__c,Applicant_1_Phone_Number__c, CreatedDate,App_2_VOI_eSign_Complete__c,
                                       Applicant_1__r.FirstName,Applicant_1__r.LastName, Applicant_1__r.PersonEmail,Applicant_2__r.personContactId,
                                       Applicant_1__r.Phone,Lender__c,LeadId__c,Loan_Amount__c,Status__c,Applicant_2__c,
                                       Current_Application_Sections__c,Total_Funds_Available__c,Applicant_1__r.personContactId,
                                       ReferredByContact__r.Name,ReferredByContact__r.Email,ReferredByContact__r.Referrer_Rating__c,
                                       ReferredByContact__c,Applicant_1__r.Name,Application_Pending_Notes__c,RecordType.Name,Line_Chart_JSON__c,installationAddressLineOne__c,
                                       Applicant_1__r.Number_of_applicants_to_operate_account__pc,SyncedQuote.Product__r.Funding_Options_Available__c,SyncedQuote.Customer_Amount__c,
                                       SyncedQuote.Product__r.No_of_Signatories_allowed__c,SyncedQuote.Product__r.Instruction_In_full_after_installation__c,
                                       SyncedQuote.Product__r.Instruction_In_full_before_installation__c,SyncedQuote.Product__r.Instruction_Part_payment_before__c,
                                       SyncedQuote.Product__r.Surplus_Instructions__c,SyncedQuote.Product__r.Short_Fall_Instructions__c,Approved_Expire_Date__c FROM Opportunity WHERE
                                       ReferredByContact__c IN: conlist ORDER By CreatedDate DESC];
                        }
                        
                        list<getMyReferralWrapper> refList = new List<getMyReferralWrapper>();
                        
                        if(OppList.Size() > 0){
                            for(Opportunity opp : oppList){
                                getMyReferralWrapper gmr = new getMyReferralWrapper(); 
                                gmr.Opportunity = opp;
                                gmr.Creationdate =  (opp.CreatedDate.Date()).format();
                                refList.add(gmr);
                            }
                        }                    
                        return refList;
                    }
                    catch(exception e){
                        UtilityClass.createException(conId, 'MyReferrerController', 'getMyRefferals', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                                     e.getTypeName(), ''+e.getCause());
                        return null;
                    }
                }
    
    @AuraEnabled
    public static opportunity SaveOpportunityOnMyReferralCard(Opportunity opp){
        try{
            system.debug('Oppppppp'+opp);
            Account acc = [SELECT id,FirstName,LastName,Phone FROM Account WHERE id =: opp.Applicant_1__c LIMIT 1];
            acc.FirstName = opp.Applicant_1__r.FirstName;
            acc.LastName  = opp.Applicant_1__r.LastName;
            acc.Phone = opp.Applicant_1__r.Phone;
            acc.PersonEmail = opp.Applicant_1__r.PersonEmail;
            update acc;
            Opportunity newOpp = [SELECT id,Name,Stagename,Applicant_1__c,Applicant_1_Name__c,Applicant_2_Name__c,
                                  Applicant_1_Email__c,Applicant_1_Phone_Number__c, CreatedDate,
                                  Applicant_1__r.FirstName,Applicant_1__r.LastName,Applicant_1__r.PersonEmail,
                                  Applicant_1__r.Phone,Lender__c, Loan_Amount__c,Status__c,
                                  Current_Application_Sections__c,Total_Funds_Available__c,
                                  ReferredByContact__r.Name,ReferredByContact__r.Referrer_Rating__c,ReferredByContact__c,Applicant_1__r.Name,
                                  Application_Pending_Notes__c,Line_Chart_JSON__c,installationAddressLineOne__c,Applicant_1__r.Number_of_applicants_to_operate_account__pc,
                                  SyncedQuote.Customer_Amount__c,SyncedQuote.Product__r.Funding_Options_Available__c,SyncedQuote.Product__r.No_of_Signatories_allowed__c,
                                  SyncedQuote.Product__r.Instruction_In_full_after_installation__c,SyncedQuote.Product__r.Instruction_In_full_before_installation__c,
                                  SyncedQuote.Product__r.Instruction_Part_payment_before__c,SyncedQuote.Product__r.Surplus_Instructions__c,
                                  SyncedQuote.Product__r.Short_Fall_Instructions__c,Approved_Expire_Date__c FROM Opportunity WHERE Id = : opp.Id];
            system.debug('Opppppppportuniyyuu'+newOpp);
            return newOpp;
        }
        catch(exception e){
            UtilityClass.createException(opp.Id, 'MyReferrerController', 'SaveOpportunityOnMyReferralCard', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause()); 
            return null;
        } 
    } 
    
    @AuraEnabled
    public static opportunity SaveAddressOnOpp(Opportunity opp, String address, String custEmail, String street, String postalCode, String suburb, String country, String state, String streetNumber, String streetType){
        try{
            Opportunity newopp =  [SELECT id,Name,Stagename,Applicant_1__c,Applicant_1_Name__c,Applicant_2_Name__c,
                                   Applicant_1_Email__c,Applicant_1_Phone_Number__c, CreatedDate,
                                   Applicant_1__r.FirstName,Applicant_1__r.LastName,Applicant_1__r.PersonEmail,
                                   Applicant_1__r.Phone,Lender__c, Loan_Amount__c,Status__c,
                                   Current_Application_Sections__c,Total_Funds_Available__c,
                                   ReferredByContact__r.Name,ReferredByContact__r.Referrer_Rating__c,ReferredByContact__c,Applicant_1__r.Name,
                                   Application_Pending_Notes__c,Line_Chart_JSON__c,installationAddressLineOne__c,Applicant_1__r.Number_of_applicants_to_operate_account__pc,
                                   SyncedQuote.Product__r.Funding_Options_Available__c,SyncedQuote.Product__r.No_of_Signatories_allowed__c,
                                   SyncedQuote.Product__r.Instruction_In_full_after_installation__c,SyncedQuote.Product__r.Instruction_In_full_before_installation__c,
                                   SyncedQuote.Product__r.Instruction_Part_payment_before__c,SyncedQuote.Product__r.Short_Fall_Instructions__c,SyncedQuote.Product__r.Surplus_Instructions__c,
                                   SyncedQuote.Customer_Amount__c,Approved_Expire_Date__c 
                                   FROM Opportunity WHERE Id = : opp.Id LIMIT 1];
            newopp.installationAddressLineOne__c = address;
            update newopp;
            
            lead ld = [SELECT ID,leadAddress__c,email FROM lead WHERE email=:custEmail LIMIT 1];
            if(ld!=null){
                ld.leadAddress__c = address;
                update ld;
            }
            Id personAccRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            Account personAccount = [select id FROM Account where ID=:newopp.Applicant_1__c AND RecordTypeId =:personAccRTId LIMIT 1];
            if(personAccount!=null){
                personAccount.Residential_Address__pc = address;
                personAccount.Street__pc = street;
                personAccount.Postal_Code__pc = postalCode;
                personAccount.Suburb__pc = suburb;
                personAccount.Street_Type__pc = streetType;
                personAccount.CountryOfResidence__pc = country;
                personAccount.State__pc = state;
                personAccount.Street_Number__pc = streetNumber;
                update personAccount;
            }
            return newopp;
        }
        catch(exception e){
            UtilityClass.createException(opp.Id, 'MyReferrerController', 'SaveAddressOnOpp', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause()); 
            return null;
        } 
    }
    
    @AuraEnabled
    public static void sendMail(String recId){
        try{
            Opportunity opp = [select id,Applicant_1__c,Applicant_2__c,Purpose__c,Contact_1__c,Contact_2__c,Applicant_1_Email__c,Applicant_2_Email__c from opportunity where id =: recId];
            /*OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address =:UtilityClass.adminEmail];
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            List<string> sendTo = new List<string>();
            if(opp.Applicant_1__c !=Null && opp.Applicant_2__c != null){
                sendTo.add(opp.Applicant_1_Email__c);
                sendTo.add(opp.Applicant_2_Email__c);
            }
            if(opp.Applicant_1__c != null && opp.Applicant_2__c == null){
                sendTo.add(opp.Applicant_1_Email__c);
            }
            mail.setToAddresses(sendTo);
            if( owea.size() > 0){
                mail.setorgWideEmailAddressId(Owea.get(0).Id);
            }
            mail.setUseSignature(false);
            mail.setTargetObjectId(opp.Contact_1__c);
            mail.Setwhatid(opp.id); 
            //mail.setSubject('We need some information to complete your '+ opp.Purpose__c +' application');
            mail.setTreatTargetObjectAsRecipient(false);
            EmailTemplate et=[Select id, Subject, Body from EmailTemplate where Name = 'CustomerInfoRequiredReferrerPortal']; 
            mail.setTemplateId(et.id);
            mails.add(mail);
            if(!test.isRunningTest()){
                Messaging.sendEmail(mails);   
            }  */
        }catch(exception e){
            UtilityClass.createException(recId,'MyReferrerController', 'sendMail', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
        }
    }
    
    // @AuraEnabled
    // public static void sendVoi1(String phoneNo, String OppId, String contactName, string voiType){
    //     try{
    //         system.debug('enterVoi1');
    //         ResendSMSController.resendSMS(phoneNo,OppId,contactName,voiType,'SMS only');
    //     }
    //     catch(exception e){
    //         UtilityClass.createException(OppId,'MyReferrerController', 'sendVoi1', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
    //                                      e.getTypeName(), ''+e.getCause());
    //     }
    // }
    
    // @AuraEnabled
    // public static void sendVoi2(String phoneNo, String OppId, String contactName, string voiType){
    //     try{
    //         ResendSMSController.resendSMS(phoneNo,OppId,contactName,voiType,'SMS only');
    //     }
    //     catch(exception e){
    //         UtilityClass.createException(OppId,'MyReferrerController', 'sendVoi2', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
    //                                      e.getTypeName(), ''+e.getCause());
    //     }
    // }
    
    @AuraEnabled
    public static List<getMyReferralWrapper> getUpdatedListofOpp(string stagenm, String conId, String searchKey, String Str){
        try{
            contact con = [SELECT Id, Name,Portal_View__c,Admin__c,AccountId FROM Contact WHERE Id=: conId LIMIT 1];
            List<Contact> conlist = new List<Contact>();
            if(con.Portal_View__c == 'Admin View' && con.Admin__c){
                conlist = [SELECT Id, Name FROM Contact WHERE AccountId = : con.AccountId];
            }
            else{
                conlist = [SELECT Id, Name FROM Contact WHERE id =: con.Id];
            }
            
            list<string> srtlst = new List<string>();
            if(stagenm == 'All'){
                srtlst.addALL(getPickListValuesIntoList());
            }
            else if(stagenm == 'Funding'){
                srtlst.add('Funding');
            }
            else if(stagenm == 'Applications'){
                srtlst.add('CPA Started');
                srtlst.add('Packs Out');
                srtlst.add('Packs Back');
                srtlst.add('Application');
                srtlst.add('Conditional');
            }
            else if(stagenm == 'Approved'){
                srtlst.add('Approved');            
            }
            else if(stagenm == 'Funded'){
                srtlst.add('Settled (closed won)');
            }
            else if(stagenm == 'Closed'){
                srtlst.add('Closed Lost');
                srtlst.add('Nurturing');
                srtlst.add('Working');
                srtlst.add('Deciding');
                srtlst.add('Approved');
                srtlst.add('Funding');
            }
            else if(stagenm == 'Quotes'){
                srtlst.add('CPA Started');
                srtlst.add('Quote');
            }
            
            List<Opportunity> oppList = new List<Opportunity>();
            String query ='SELECT id,Name,Stagename,Applicant_1_Name__c,Applicant_2_Name__c,Approved_Date__c,Applicant_1_Email__c,Applicant_1_Phone_Number__c, CreatedDate,Lender__c,';
            query += 'Loan_Amount__c,Status__c,Current_Application_Sections__c,Total_Funds_Available__c,Applicant_1__r.FirstName,Applicant_1__r.LastName,';
            query+='Applicant_1__r.PersonEmail,Applicant_1__r.Phone, ReferredByContact__r.Name,ReferredByContact__r.Referrer_Rating__c,installationAddressLineOne__c,Applicant_1__r.Number_of_applicants_to_operate_account__pc,';
            query+='ReferredByContact__c,Application_Pending_Notes__c,Line_Chart_JSON__c,Applicant_1__r.personContactId,Applicant_2__r.personContactId,SyncedQuote.Product__r.Funding_Options_Available__c,SyncedQuote.Customer_Amount__c, ';
            query+= 'SyncedQuote.Product__r.No_of_Signatories_allowed__c,SyncedQuote.Product__r.Instruction_In_full_after_installation__c,SyncedQuote.Product__r.Instruction_In_full_before_installation__c,Approved_Expire_Date__c, ';
            query+= 'SyncedQuote.Product__r.Instruction_Part_payment_before__c,SyncedQuote.Product__r.Surplus_Instructions__c,SyncedQuote.Product__r.Short_Fall_Instructions__c FROM Opportunity WHERE ReferredByContact__c IN: conlist AND stageName IN: srtlst';
            if ( searchKey != Null ) {
                if ( Str != null ){
                    String key = '%' + searchKey + '%';
                    query += ' AND Name LIKE :key ORDER BY '+Str;
                    oppList = Database.query(query);
                }
                else{
                    String key = '%' + searchKey + '%';
                    query += ' AND Name LIKE :key ORDER By CreatedDate DESC'; 
                    oppList = Database.query(query); 
                }
                
            }
            else if ( Str != null ){
                query += ' ORDER BY '+Str;
                oppList = Database.query(query);
            }
            else{
                oppList =[SELECT id,Name,Stagename,Applicant_1_Name__c,Applicant_2_Name__c,Applicant_1_Email__c,
                          Applicant_1_Phone_Number__c, CreatedDate,Lender__c, Loan_Amount__c,Status__c,Current_Application_Sections__c,
                          Total_Funds_Available__c,Applicant_1__r.FirstName,Applicant_1__r.LastName,
                          Applicant_1__r.PersonEmail,Applicant_1__r.Phone,Approved_Date__c,
                          ReferredByContact__r.Name,ReferredByContact__r.Referrer_Rating__c,ReferredByContact__c,Application_Pending_Notes__c,Line_Chart_JSON__c,
                          Applicant_1__r.personContactId,Applicant_2__r.personContactId,installationAddressLineOne__c,Applicant_1__r.Number_of_applicants_to_operate_account__pc,SyncedQuote.Customer_Amount__c,
                          SyncedQuote.Product__r.Funding_Options_Available__c,SyncedQuote.Product__r.No_of_Signatories_allowed__c,SyncedQuote.Product__r.Instruction_In_full_after_installation__c,
                          SyncedQuote.Product__r.Instruction_In_full_before_installation__c,SyncedQuote.Product__r.Instruction_Part_payment_before__c,SyncedQuote.Product__r.Surplus_Instructions__c,
                          SyncedQuote.Product__r.Short_Fall_Instructions__c,Approved_Expire_Date__c
                          FROM Opportunity WHERE ReferredByContact__c IN: conlist AND stageName IN: srtlst ORDER By CreatedDate DESC ];
            }
            list<getMyReferralWrapper> refList = new List<getMyReferralWrapper>();
            for(Opportunity opp : oppList){
                getMyReferralWrapper gmr = new getMyReferralWrapper(); 
                gmr.Opportunity = opp;
                gmr.Creationdate =  (opp.CreatedDate.Date()).format();
                
                refList.add(gmr);
            }
            return refList;
        }
        catch(exception e){
            UtilityClass.createException(conId,'MyReferrerController', 'getUpdatedListofOpp', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    
    public static List<String> getPickListValuesIntoList(){
        try{
            List<String> pickListValuesList= new List<String>();
            Schema.DescribeFieldResult fieldResult = opportunity.stageName.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            }     
            return pickListValuesList;
        }
        catch(exception e){
            UtilityClass.createException('','MyReferrerController', 'getPickListValuesIntoList', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @AuraEnabled
    public static contact getCondata(String conId){
        try{
            contact con = [SELECT Id, Name,Portal_View__c, AccountId FROM Contact WHERE Id =: conId LIMIT 1];                
            
            return con;
        }
        catch(exception e){
            UtilityClass.createException(conId,'MyReferrerController', 'getCondata', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @AuraEnabled
    public static List<Action_Centre_Request__c> createActionRequest(String Con,String Opp,String QA,String reqBody,String relTo,String Urg,String OppStage){
        try{
            Datetime  datetimeNow = system.now();
            Action_Centre_Request__c acr = new Action_Centre_Request__c();
            acr.Action_DateTime__c = datetimeNow;
            acr.Quick_Action__c = QA;
            acr.Request_Body__c = reqBody;
            acr.Related_to__c = relTo;
            acr.Urgency__c  = Urg;
            acr.Opportunity__c = Opp;
            acr.Opportunity_Stage__c = OppStage;
            acr.Referrer_Contact__c = Con;
            Contact refconn = [SELECT Id,Name,AccountId,Referrer_Rating__c FROM CONTACT WHERE Id=: Con LIMIT 1];
            if(refconn.AccountId != Null){
                acr.Referrer_Account__c = refconn.AccountId;
            }
            insert acr;
            
         /*  EmailTemplate emailTemp = [SELECT id, Name  FROM EmailTemplate WHERE Name =: 'Action Centre Request'];
            OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address =: UtilityClass.adminEmail]; 
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(emailTemp.Id);
            mail.setTargetObjectId(acr.Referrer_Contact__c);
            mail.setTreatTargetObjectAsRecipient(false);
            mail.Setwhatid(acr.Id);
            
            if( owea.size() > 0){
                mail.setorgWideEmailAddressId(Owea.get(0).Id);
            }
            
            String[] toAddress = new String[] {'tazeem.khan@chazecloud.com''};
                mail.setToAddresses(toAddress);
            //mail.setReplyTo('tazeem.khan@chazecloud.com');
            
            if(mail != Null){
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }  
            */
            List<Action_Centre_Request__c> acrList = [SELECT Id,Action_DateTime__c,Quick_Action__c,Request_Body__c,Referrer_Account__r.Name,Related_to__c,
                                                      Opportunity__c,Referrer_Contact__c,Opportunity__r.Name,Urgency__c,Referrer_Contact__r.Name,
                                                      Referrer_Contact__r.Referrer_Rating__c FROM Action_Centre_Request__c
                                                      WHERE Referrer_Contact__c =: Con AND Opportunity__c =: Opp
                                                      Order by Action_DateTime__c DESC];
            Case cs = new Case();
            for(Action_Centre_Request__c ar : acrList){
                cs.ContactId = refconn.Id;
                cs.Opportunity__c = Opp;
                String ratingTime;
                if(ar.Referrer_Contact__r.Referrer_Rating__c == 'Platinum'){
                    ratingTime = '15 minutes';
                }  
                else{
                    ratingTime = '60 minutes'; 
                }
                cs.Subject = QA+' '+refconn.Referrer_Rating__c+' for '+ar.Opportunity__r.Name;
                String text = 'Hi team,\n';
                text += ar.Referrer_Contact__r.Name+' from '+ar.Referrer_Account__r.Name+' has raised a request. Please action the request within SLA’s '+ratingTime+'\n';
                text += 'Request: '+ar.Quick_Action__c+'\n';
                text += 'Opportunity: '+ar.Opportunity__r.Name+'\n';
                text += 'urgency: '+ar.Urgency__c+'\n';
                if(ar.Quick_Action__c == 'Request assistance'){
                    text += 'Related to: '+ar.Related_to__c+'\n';
                } 
                text += 'Request: '+ar.Request_Body__c+'\n';
                cs.Description = text;
                
                break;
            }
            if(cs != null){
                insert cs;
            } 
            return acrList;
        }
        catch(exception e){
            UtilityClass.createException(opp,'MyReferrerController', 'createActionRequest', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @AuraEnabled
    public static List<Action_Centre_Request__c> getActionCentreRequest(String ConId,String OppId){
        try{
            List<Action_Centre_Request__c> acrr = [SELECT Id,Action_DateTime__c,Quick_Action__c,Request_Body__c,
                                                   Opportunity__c,Referrer_Contact__c FROM Action_Centre_Request__c
                                                   WHERE Referrer_Contact__c =: ConId AND Opportunity__c =: OppId
                                                   Order by Action_DateTime__c DESC]; 
            return acrr;
        }
        catch(exception e){
            UtilityClass.createException(OppId,'MyReferrerController', 'getActionCentreRequest', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @AuraEnabled
    public static list<getQuotesWrapper> GroupQuotes(String OppId){
        try{
            Map<String,getQuotesWrapper> mapOfquotes = new Map<String,getQuotesWrapper>();
            list<getQuotesWrapper> quoteWrapperList = new list<getQuotesWrapper>();
            list<Quote> qlist =[SELECT id,Name,QuoteNumber,Customer_Amount__c,Master_Quote_For_URL__c,OpportunityId,Interest_Rate__c,Monthly_Repayment__c,Gruop_Name__c,Quote_Group_Label__c,Application__c,Loan_Term__c,Actual_Comparison_Rate__c FROM Quote WHERE
                                OpportunityId =: OppId];
            decimal minInterest=0;
            decimal minRepayment=0;
            for(Quote qt: qlist){
                getQuotesWrapper quoteWrapper = new getQuotesWrapper();
                if(!mapOfquotes.containskey(qt.Gruop_Name__c)){
                    quoteWrapper.InterestRate = qt.Interest_Rate__c;
                    minInterest = qt.Interest_Rate__c;
                    quoteWrapper.Repayment = qt.Monthly_Repayment__c;
                    minRepayment = qt.Monthly_Repayment__c;
                    quoteWrapper.ComparsionRate= qt.Actual_Comparison_Rate__c;
                    quoteWrapper.Loanterm = qt.Loan_Term__c;
                    quoteWrapper.Amount=qt.Customer_Amount__c;
                    quoteWrapper.GroupName = qt.Gruop_Name__c;
                    quoteWrapper.GroupLabel = qt.Quote_Group_Label__c;
                    quoteWrapper.isChecked = false;
                    quoteWrapper.masterQuoteForURL = qt.Master_Quote_For_URL__c;
                    quoteWrapper.oppId = qt.OpportunityId;
                    mapOfquotes.put(qt.Gruop_Name__c,quoteWrapper);
                }
                else{
                    if(qt.Interest_Rate__c < minInterest){
                        quoteWrapper.InterestRate = qt.Interest_Rate__c;
                        quoteWrapper.ComparsionRate= qt.Actual_Comparison_Rate__c;
                        minInterest = qt.Interest_Rate__c;
                    }
                    else if(qt.Interest_Rate__c == minInterest){
                        if(mapOfquotes.get(qt.Gruop_Name__c).ComparsionRate > qt.Actual_Comparison_Rate__c){
                            quoteWrapper.ComparsionRate= qt.Actual_Comparison_Rate__c;
                        }
                        quoteWrapper.InterestRate = qt.Interest_Rate__c;
                        quoteWrapper.ComparsionRate= qt.Actual_Comparison_Rate__c;
                        minInterest = qt.Interest_Rate__c;
                    }
                    else{
                        quoteWrapper.InterestRate = mapOfquotes.get(qt.Gruop_Name__c).InterestRate;
                        quoteWrapper.ComparsionRate= mapOfquotes.get(qt.Gruop_Name__c).ComparsionRate;
                    }
                    if(qt.Monthly_Repayment__c < minRepayment){
                        quoteWrapper.Repayment = qt.Monthly_Repayment__c;
                        quoteWrapper.Loanterm  = qt.Loan_Term__c;
                        minRepayment = qt.Monthly_Repayment__c;
                    }
                    else{
                        quoteWrapper.Repayment = mapOfquotes.get(qt.Gruop_Name__c).Repayment;
                        quoteWrapper.Loanterm  = mapOfquotes.get(qt.Gruop_Name__c).Loanterm;
                    }
                    quoteWrapper.Amount = mapOfquotes.get(qt.Gruop_Name__c).Amount;
                    quoteWrapper.GroupName = mapOfquotes.get(qt.Gruop_Name__c).GroupName;
                    quoteWrapper.GroupLabel = mapOfquotes.get(qt.Gruop_Name__c).GroupLabel;
                    quoteWrapper.isChecked = false;
                    quoteWrapper.masterQuoteForURL = mapOfquotes.get(qt.Gruop_Name__c).masterQuoteForURL;
                    quoteWrapper.oppId = mapOfquotes.get(qt.Gruop_Name__c).oppId;
                    mapOfquotes.put(qt.Gruop_Name__c,quoteWrapper);
                }
            }
            // system.debug('Map->>'+mapOfquotes);
            //system.Assert(false);
            return mapOfquotes.values();
        }
        catch(exception e){
            UtilityClass.createException(OppId,'MyReferrerController', 'GroupQuotes', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @AuraEnabled
    public static getQuotesWrapper updateQuotes(String quoteWrapperList, String quoteType, string OppId, string leadId) {
        try{
            list<getQuotesWrapper> quoteDetailWrpList = (list<getQuotesWrapper>)JSON.deserialize(quoteWrapperList, list<getQuotesWrapper>.class);
            
            getQuotesWrapper newWrp = new getQuotesWrapper();
            boolean flg = true;
            decimal minAmount,maxAmount;
            list<String> groupnames = new list<string>();
            for(getQuotesWrapper qdw:quoteDetailWrpList){
                if(flg){
                    minAmount = qdw.Amount;
                    maxAmount = qdw.Amount;
                    flg= false;
                }
                if(minAmount > qdw.Amount){
                    minAmount = qdw.Amount;
                }
                if(maxAmount < qdw.Amount){
                    maxAmount = qdw.Amount;
                }
                groupnames.add(qdw.GroupName);
            }
            
            Map<Id,Product2> productsMap = New Map<Id,Product2>([SELECT Id, IsActive, Actual_Comparison_Rate__c, Commission_Amount__c,Brokerage_Amount__c,
                                                                 Comparison_Rate_Disclaimer__c, Comparison_Rate_Warning__c, Eligibility__c, Acceptable_Loan_Purpose__c,
                                                                 Features__c, Interest_Rate__c, Interest_Rate_Type__c, Lender__c, Loan_Amount__c, Is_Feature_Product__c,
                                                                 Loan_Term__c, Name, Security__c, Min_Loan_Term__c, Max_Loan_Term__c, Product_Type__c, Default_Loan_Term_Months__c,
                                                                 Interest_Rate_Based_On__c,Maximum_Loan_Amount__c,Minimum_Loan_Amount__c,
                                                                 (SELECT ID, Active__c, Amount__c,Description__c, Fee_From__c, Fee_Type__c, Frequency__c,
                                                                  Notes__c, Override_allowed__c, Product__c, Product_Loan_Fees__c, Quote__c FROM Loan_Fees__r),
                                                                 (SELECT id,From_amount__c,Interest_rate__c,To_amount__c,Comparison_rate__c,Product__c FROM Loan_Rates__r)
                                                                 FROM Product2 WHERE isActive = TRUE AND Acceptable_Loan_Purpose__c INCLUDES (:quoteType) AND Maximum_Loan_Amount__c >=: maxAmount 
                                                                 AND Minimum_Loan_Amount__c <=: minAmount ORDER BY Product_Order__c ASC limit 20]);
            //system.debug('products are:'+productsMap.size());
            for(integer i=0; i< quoteDetailWrpList.size(); i++){
                if(productsMap.isEmpty()){
                    newWrp.errorMessage = 'At least one of the amounts you entered is below the minimum or above the maximum of all our lenders. Please review the form and try again';
                    return newWrp;
                }
            }
            boolean isMinError = false;
            boolean isMaxError = false;
            for(integer i=0; i< quoteDetailWrpList.size(); i++){
                quoteDetailWrpList[i].errorMessage = '';
                Decimal minPrAmount = 0;
                Decimal maxPrAmount = 0;  
                boolean flgPr = true;
                for(Product2 pr: productsMap.values()){
                    if(flgPr){
                        minPrAmount = pr.Minimum_Loan_Amount__c;
                        maxPrAmount = pr.Maximum_Loan_Amount__c;
                        flgPr= false;
                    }
                    if(minPrAmount > pr.Minimum_Loan_Amount__c){
                        minPrAmount = pr.Minimum_Loan_Amount__c;
                    }
                    if(maxPrAmount < pr.Maximum_Loan_Amount__c){
                        maxPrAmount = pr.Maximum_Loan_Amount__c;
                    }                    
                }
                
                if(quoteDetailWrpList[i].Amount < minPrAmount){
                    isMinError = true;
                    newWrp.minAmt = minPrAmount;
                }
                else if(quoteDetailWrpList[i].Amount > maxPrAmount){
                    isMaxError = true;
                    newWrp.maxAmt = maxPrAmount;
                }
            }
            //system.debug('errList'+errList);
            if(isMaxError && !isMinError){
                newWrp.errorMessage = 'At least one of the amounts you entered is above the maximum of all our lenders. Please review the form and try again';
                return newWrp;
                
            }
            else if(isMinError && !isMaxError){
                newWrp.errorMessage = 'At least one of the amounts you entered is below the minimum of all our lenders. Please review the form and try again';
                return newWrp;
                
            }
            else if(isMinError && isMaxError){
                newWrp.errorMessage = 'At least one of the amounts you entered is below the minimum or above the maximum of all our lenders. Please review the form and try again';
                return newWrp;
            }
            
            list<Quote> quoteTodelete = new list<Quote>();
            list<quote>  qtlist = [select id,name,Customer_Amount__c,Actual_Comparison_Rate__c,Quote_Group_Label__c,Gruop_Name__c,Product__c from quote where Gruop_Name__c IN: groupnames AND OpportunityId=:oppId];
            for(Quote qt : qtlist){
                quoteTodelete.add(qt);
            }
            if(quoteTodelete.size()>0){
                delete quoteTodelete;
            }
            
            Map<String, List<Quote>> quotesListMap = New Map<String, List<Quote>>();
            string nme ='';
            for(integer i=0; i< quoteDetailWrpList.size(); i++){
                string qtName= 'Referral-';          
                Integer j=1;
                list<Quote> quotesList = new list<Quote>();
                for(Product2 pr: productsMap.values()){
                    if(j>3)break;
                    else if(pr.Maximum_Loan_Amount__c >= quoteDetailWrpList[i].Amount &&  pr.Minimum_Loan_Amount__c <= quoteDetailWrpList[i].Amount ){
                        Quote quote = New Quote();
                        quote.Lead__c = leadId;
                        quote.OpportunityId = oppId;
                        quote.Actual_Comparison_Rate__c = pr.Actual_Comparison_Rate__c;
                        quote.Name = pr.Name;
                        quote.Interest_Rate__c = pr.Interest_Rate__c;
                        quote.Loan_Term__c = pr.Max_Loan_Term__c;
                        quote.Product__c = pr.Id;
                        quote.Purpose__c = quoteType;
                        quote.Is_Featured__c = pr.Is_Feature_Product__c;
                        quote.Customer_Amount__c = quoteDetailWrpList[i].Amount;
                        quote.Gruop_Name__c = quoteDetailWrpList[i].GroupLabel;
                        quote.Quote_Group_Label__c = quoteDetailWrpList[i].GroupLabel;
                        quote.Commission_Amount__c = pr.Commission_Amount__c;
                        quote.Brokerage_Amount__c = pr.Brokerage_Amount__c;
                        quote.Lender__c = pr.Lender__c;
                        if(pr.Interest_Rate_Based_On__c =='Tiered Rate' && pr.Loan_Rates__r.size()>0 ){
                            for(Loan_Rate__c  lr: pr.Loan_Rates__r){
                                if(lr.From_amount__c <= quoteDetailWrpList[i].Amount && lr.To_amount__c >= quoteDetailWrpList[i].Amount){
                                    quote.Actual_Comparison_Rate__c = lr.Comparison_rate__c;
                                    quote.Interest_Rate__c = lr.Interest_rate__c;
                                    break;
                                }
                            }
                        }
                        quotesList = quotesListMap.get(quote.Gruop_Name__c);
                        if(quotesList == NULL)quotesList = New list<Quote>();
                        quotesList.add(quote);
                        quotesListMap.put(quote.Gruop_Name__c, quotesList);                           
                        j++;
                        //quotesList.add(quote);
                    }
                }   
            } 
            
            List<Quote> quotesListToInsert = New List<Quote>();
            for(String qName: quotesListMap.keySet()){
                Boolean isFeature = false;
                String lowRatePrId = '';
                decimal lowestRate = 100;
                for(Quote qt: quotesListMap.get(qName)){
                    if(qt.Is_Featured__c)
                        isFeature = true;
                    if(lowestRate > qt.Interest_Rate__c){
                        lowestRate = qt.Interest_Rate__c;
                        lowRatePrId = qt.Product__c;
                    }
                }
                
                for(Quote qt: quotesListMap.get(qName)){
                    if(!isFeature && lowRatePrId.equals(qt.Product__c)){
                        qt.Is_Featured__c = true; // NEED TO UNCOMMENT IN UAT
                    }
                    
                    quotesListToInsert.add(qt);
                }
            }
            insert quotesListToInsert;
            
            String featuredQuote;
            list<Loan_Fees__c> loanFees = new list<Loan_Fees__c>();
            Id loanfeeRT = Schema.SObjectType.Loan_Fees__c.getRecordTypeInfosByName().get('Quote Loan Fees').getRecordTypeId();
            for(Quote qt : quotesListToInsert){
                Product2 pr = productsMap.get(qt.Product__c);
                if(qt.Is_Featured__c){
                    featuredQuote = qt.Id;
                }
                for(Loan_Fees__c fees: pr.Loan_Fees__r){    
                    Loan_Fees__c fee = New Loan_Fees__c();  
                    fee.Active__c = fees.Active__c; 
                    fee.Amount__c = fees.Amount__c; 
                    fee.Description__c = fees.Description__c;   
                    fee.Fee_From__c = fees.Fee_From__c; 
                    fee.Product_Loan_Fees__c =fees.Id;  
                    fee.Fee_Type__c =fees.Fee_Type__c;  
                    fee.Frequency__c =fees.Frequency__c;    
                    fee.Notes__c =fees.Notes__c;    
                    fee.Override_allowed__c =fees.Override_allowed__c;  
                    fee.RecordTypeId = loanfeeRT;   
                    fee.Quote__c = qt.Id;   
                    loanFees.add(fee);  
                }
            }
            if(String.isBlank(featuredQuote)){
                featuredQuote = quotesListToInsert[0].Id;
            }
            insert loanFees;
            
            return newWrp;
        }
        catch(exception e){
            UtilityClass.createException(OppId,'MyReferrerController', 'updateQuotes', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @AuraEnabled
    public static void sendQuotes(String wrapperList,String OppId,String conId, String custEmail, String refEmail, String isPdf){
        try{
            //system.Assert(false);
            list<getQuotesWrapper> quoteDetailWrpList = (list<getQuotesWrapper>)JSON.deserialize(wrapperList, list<getQuotesWrapper>.class);
            list<string> groupnames = new list<string>();
            for(getQuotesWrapper qtw : quoteDetailWrpList){
                groupnames.add(qtw.GroupName);
            }
            
            Lead ld = [SELECT Id, FirstName, LastName, Email, Status, ReferredByContact__c, RelatedAccount__c, OwnerId, 
                       Point_of_Origin__c, Phone, LeadSource, Referred_by_Company__c
                       FROM Lead WHERE Email =: custEmail LIMIT 1];
            if(isPdf == 'No'){
                sendApplication(OppId, ld.Id, conId, new list<string>{custEmail,refEmail}, 'Quotation_from Referral_ReferrerPortal', false);}
            else{
                sendApplication(OppId, ld.Id, conId, new list<string>{refEmail}, 'Quotation_from Referrer_ReferrerPortal', true);
            }
            
            list<Quote> quoteList = [select id,name,IsSelected__c from quote where IsSelected__c=true AND OpportunityId=:OppId AND Gruop_Name__c IN:groupnames];
            for(Quote qtt : quoteList){
                qtt.IsSelected__c = false;
            }
            if(quoteList.size()>0){
                update quoteList;
            }
        } 
        catch(exception e){
            UtilityClass.createException(OppId,'MyReferrerController', 'sendQuotes', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
        }
    }
    
    @AuraEnabled
    public static void selectedQuotes(String wrapperList, String OppId){
        try{
            list<getQuotesWrapper> quoteDetailWrpList = (list<getQuotesWrapper>)JSON.deserialize(wrapperList, list<getQuotesWrapper>.class);
            list<string> groupnames = new list<string>();
            for(getQuotesWrapper qtw : quoteDetailWrpList){
                groupnames.add(qtw.GroupName);
            }
            list<quote> qttlist = [select id,name,IsSelected__c from quote where opportunityId=:OppId];
            for(quote qt : qttlist){
                qt.isSelected__c = false;
            }
            update qttlist; //to false the all quotes
            list<quote> qtList = [select id,name,IsSelected__c from quote where OpportunityId=:OppId AND Gruop_Name__c IN:groupnames];
            for(Quote qt : qtList){
                qt.IsSelected__c = true;
            }
            if(qtList.size()>0){
                update qtList; //to true selected quotes
            }
        }
        catch(exception e){
            UtilityClass.createException(OppId,'MyReferrerController', 'selectedQuotes', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
        }
    }
    
    @AuraEnabled
    public static void sendApplication(String oppId, String leadId, String conId, List<String> emails, String templateName, Boolean isPDFAttach){
        try{
            
            Opportunity opp = [SELECT Id, Purpose__c, Applicant_1__r.Name, ReferredByContact__r.Name, 
                               How_much_do_you_need__c, Applicant_1__r.Phone, Send_the_quote_to__c,
                               Owner.Name, Owner.Email,Credit_Analyst__c, Credit_Analyst__r.Email,RecordType.Name,RecordTypeId
                               FROM Opportunity WHERE Id =: oppId LIMIT 1];
            /*List<String>emailBCCList = New List<String>();
            List<String>emailCCList = new List<String>();
            List<String>  personalRecTypeNameList = New List<String>{'Green Loan','Asset Finance','Commercial Solar Purchase','Commercial Asset Finance','Debt Consolidation','Home Improvement','Personal Loan','Vehicle Purchase'};
                List<String>  mortgageRecTypeNameList = New List<String>{'Commercial Mortgage','Commercial Property Purchase','Home Loan Construction','Home Loan Purchase','Home Loan Refinance','Opportunity (Wallet Share)'};
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            mail.setToAddresses(emails);
            mail.setWhatId(oppId); 
            mail.setUseSignature(false); 
            mail.setTargetObjectId(conId);
            mail.setTreatTargetObjectAsRecipient(false);
            if(mortgageRecTypeNameList.contains(opp.RecordType.Name) || oppRecordTypeMap.get('Debt Consolidation') == opp.RecordTypeId){
                if(opp.Credit_Analyst__c!=null){
                    emailCCList.add(opp.Credit_Analyst__r.Email);
                }
                if(guestUserName.equalsIgnoreCase(opp.Owner.Name)){
                    emailBCCList.add(adminEmail);
                    
                }else{
                    emailBCCList.add(opp.Owner.Email);
                }
                
                mail.setBccAddresses(emailBCCList);
                //added 16-2-22
                if(emailCCList.size()>0){
                    mail.setCcAddresses(emailCCList);
                }
                emailBCCList.add(personalCreditEmailId);
            }
            mail.setSaveAsActivity(true); 
            EmailTemplate et=[Select id, Subject, Body from EmailTemplate where Name=:templateName]; 
            //System.debug('et>>' + et);
            mail.setTemplateId(et.id); 
            String fromEmailAddress = 'sethu.rawat@chazecloud.com';
            if(personalRecTypeNameList.contains(opp.RecordType.Name)){
                fromEmailAddress = UtilityClass.adminEmail;
            }else if(mortgageRecTypeNameList.contains(opp.RecordType.Name)){
                fromEmailAddress = 'tazeem.khan@chazecloud.com';
            }
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:fromEmailAddress];
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }            
            
            if(isPDFAttach){
                
                PageReference pdf = Page.QuotationTemplatePDF;
                pdf.getParameters().put('id',oppId);
                pdf.getParameters().put('isSelected','yes');
                pdf.setRedirect(true);
                Blob bPDF;
                if(Test.isRunningTest()){
                    bPDF = Blob.valueOf('Unit Test Body');
                }else{
                    bPDF = pdf.getContent();
                }
                String dateSTR = Date.today().day() + '-' + Date.today().month() + '-' + Date.today().year();
                String pdfName = opp.Purpose__c + ' Finance Options for ' + opp.Applicant_1__r.Name + ', ' + dateSTR +'.pdf';
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(pdfName);
                efa.setBody(bPDF);
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            }
            
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
            
        }catch(exception e){
            UtilityClass.createException(oppId, 'MyReferrerController', 'sendApplication', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
        }
    }
    
    @auraEnabled
    public static list<QuoteDetailWrapper> ret(List<QuoteDetailWrapper> qtwrapper){
        try{
            system.debug('qtwrapper'+qtwrapper);
            QuoteDetailWrapper quoteDetailWrpList2 = New QuoteDetailWrapper();
            qtwrapper.add(quoteDetailWrpList2);
            system.debug('newwqtwrapper'+qtwrapper);
            return qtwrapper;
        }
        catch(exception e){
            UtilityClass.createException('', 'MyReferrerController', 'ret', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return Null;
        }
    }
    
    @auraEnabled
    public static QuoteDetailWrapper ret1(){
        return New QuoteDetailWrapper();
    }
    
    @auraEnabled
    public static QuoteDetailWrapper newQuotes(string quoteType, string leadId, string oppId, string quoteDetailWrpList1){
        try{
            list<QuoteDetailWrapper> quoteDetailWrpList = (list<QuoteDetailWrapper>)JSON.deserialize(quoteDetailWrpList1, list<QuoteDetailWrapper>.class);
            system.debug('quoteDetailWrpList>>>>'+quoteDetailWrpList);
            system.debug('quoteType'+quoteType);
            system.debug('leadId'+leadId);
            system.debug('oppId'+oppId);
            QuoteDetailWrapper newWrp = new QuoteDetailWrapper();
            Decimal minAmount = 0;
            Decimal maxAmount = 0;  
            String description ='';
            boolean flg = true;
            for(QuoteDetailWrapper qdw:quoteDetailWrpList){
                if(flg){
                    minAmount = qdw.Amount;
                    maxAmount = qdw.Amount;
                    flg= false;
                }
                if(minAmount > qdw.Amount){
                    minAmount = qdw.Amount;
                }
                if(maxAmount < qdw.Amount){
                    maxAmount = qdw.Amount;
                }
            }
            Map<Id,Product2> productsMap = New Map<Id,Product2>(
                [SELECT Id, IsActive, Actual_Comparison_Rate__c, Acceptable_Loan_Purpose__c,  Commission_Amount__c,
                 Comparison_Rate_Disclaimer__c, Comparison_Rate_Warning__c, Eligibility__c, Is_Feature_Product__c,
                 Features__c, Interest_Rate__c, Interest_Rate_Type__c, Lender__c, Loan_Amount__c, Brokerage_Amount__c,Maximum_Loan_Amount__c, Minimum_Loan_Amount__c,
                 Loan_Term__c, Name, Security__c, Min_Loan_Term__c, Max_Loan_Term__c, Product_Type__c,Interest_Rate_Based_On__c,
                 (SELECT ID, Active__c, Amount__c,Description__c, Fee_From__c, Fee_Type__c, Frequency__c,
                  Notes__c, Override_allowed__c, Product__c, Product_Loan_Fees__c, Quote__c FROM Loan_Fees__r),
                 (SELECT id,From_amount__c,Interest_rate__c,To_amount__c,Comparison_rate__c,Product__c FROM Loan_Rates__r)
                 FROM Product2 WHERE isActive = TRUE AND Acceptable_Loan_Purpose__c INCLUDES (:quoteType) AND Maximum_Loan_Amount__c >=: minAmount 
                 AND Minimum_Loan_Amount__c <=: maxAmount ORDER BY Product_Order__c ASC limit 20]); 
            system.debug('productsMap'+productsMap);
            
            for(integer i=0; i< quoteDetailWrpList.size(); i++){
                if(productsMap.isEmpty()){
                    newWrp.errorMessage = 'At least one of the amounts you entered is below the minimum or above the maximum of all our lenders. Please review the form and try again';
                    return newWrp;
                }
            }
            boolean isMinError = false;
            boolean isMaxError = false;
            for(integer i=0; i< quoteDetailWrpList.size(); i++){
                quoteDetailWrpList[i].errorMessage = ''; 
                Decimal minPrAmount = 0;
                Decimal maxPrAmount = 0;  
                boolean flgPr = true;
                for(Product2 pr: productsMap.values()){ 
                    if(flgPr){
                        minPrAmount = pr.Minimum_Loan_Amount__c;
                        maxPrAmount = pr.Maximum_Loan_Amount__c;
                        flgPr= false;
                    }
                    if(minPrAmount > pr.Minimum_Loan_Amount__c){
                        minPrAmount = pr.Minimum_Loan_Amount__c;
                    }
                    if(maxPrAmount < pr.Maximum_Loan_Amount__c){
                        maxPrAmount = pr.Maximum_Loan_Amount__c;
                    }                    
                }
                
                if(quoteDetailWrpList[i].Amount < minPrAmount){
                    isMinError = true;
                    newWrp.minAmt = minPrAmount;
                }
                else if(quoteDetailWrpList[i].Amount > maxPrAmount){
                    isMaxError = true;
                    newWrp.maxAmt = maxPrAmount;
                }
            }
            if(isMaxError && !isMinError){
                newWrp.errorMessage = 'At least one of the amounts you entered is above the maximum of all our lenders. Please review the form and try again';
                return newWrp;
                
            }
            else if(isMinError && !isMaxError){
                newWrp.errorMessage = 'At least one of the amounts you entered is below the minimum of all our lenders. Please review the form and try again';
                return newWrp;
                
            }
            else if(isMinError && isMaxError){
                newWrp.errorMessage = 'At least one of the amounts you entered is below the minimum or above the maximum of all our lenders. Please review the form and try again';
                return newWrp;
            }
            
            Map<String, List<Quote>> quotesListMap = New Map<String, List<Quote>>();
            List<Loan_Fees__c> loanFees = New List<Loan_Fees__c>();
            string nme='';
            for(integer i=0; i< quoteDetailWrpList.size(); i++){
                string qtName= 'Referral-';  
                Integer sum = i+1;
                Integer j=1;
                List<Quote> quotesList = New List<Quote>();
                for(Product2 pr: productsMap.values()){
                    if(j>3)break;
                    else if(pr.Maximum_Loan_Amount__c >= quoteDetailWrpList[i].Amount &&  pr.Minimum_Loan_Amount__c <= quoteDetailWrpList[i].Amount ){
                        Quote quote = New Quote();
                        quote.Lead__c = leadId;
                        quote.OpportunityId = oppId;
                        quote.Actual_Comparison_Rate__c = pr.Actual_Comparison_Rate__c;
                        quote.Name = pr.Name;
                        quote.Interest_Rate__c = pr.Interest_Rate__c;
                        quote.Loan_Term__c = pr.Max_Loan_Term__c;
                        quote.Product__c = pr.Id;
                        quote.Purpose__c = quoteType;
                        quote.Is_Featured__c = pr.Is_Feature_Product__c;
                        quote.Customer_Amount__c = quoteDetailWrpList[i].Amount;
                        quote.Gruop_Name__c = quoteDetailWrpList[i].masterQuote;
                        quote.Quote_Group_Label__c = quoteDetailWrpList[i].masterQuote;
                        /*if(string.isBlank(quoteDetailWrpList[i].masterQuote)){
nme = qtName + sum;
quote.Gruop_Name__c = nme;
quote.Quote_Group_Label__c = nme;
quoteDetailWrpList[i].masterQuote = nme;
}
else{
quote.Gruop_Name__c = quoteDetailWrpList[i].masterQuote;
quote.Quote_Group_Label__c = quoteDetailWrpList[i].masterQuote;
}*/
                        quote.Commission_Amount__c = pr.Commission_Amount__c;
                        quote.Brokerage_Amount__c = pr.Brokerage_Amount__c;
                        quote.Lender__c = pr.Lender__c;
                        if(pr.Interest_Rate_Based_On__c =='Tiered Rate' && pr.Loan_Rates__r.size()>0 ){
                            for(Loan_Rate__c  lr: pr.Loan_Rates__r){
                                if(lr.From_amount__c <= quoteDetailWrpList[i].Amount && lr.To_amount__c >= quoteDetailWrpList[i].Amount){
                                    quote.Actual_Comparison_Rate__c = lr.Comparison_rate__c;
                                    quote.Interest_Rate__c = lr.Interest_rate__c;
                                    break;
                                }
                            }
                        }
                        quotesList = quotesListMap.get(quote.Gruop_Name__c);
                        if(quotesList == NULL)quotesList = New List<Quote>();
                        quotesList.add(quote);
                        quotesListMap.put(quote.Gruop_Name__c, quotesList);                            
                        j++;
                    }
                }           
            }
            List<Quote> quotesListToInsert = New List<Quote>();
            for(String qName: quotesListMap.keySet()){
                Boolean isFeature = false;
                String lowRatePrId = '';
                decimal lowestRate = 100;
                for(Quote qt: quotesListMap.get(qName)){
                    if(qt.Is_Featured__c)
                        isFeature = true;
                    if(lowestRate > qt.Interest_Rate__c){
                        lowestRate = qt.Interest_Rate__c;
                        lowRatePrId = qt.Product__c;
                    }
                }
                
                for(Quote qt: quotesListMap.get(qName)){
                    if(!isFeature && lowRatePrId.equals(qt.Product__c)){
                        qt.Is_Featured__c = true;
                    }
                    
                    quotesListToInsert.add(qt);
                }
            }
            
            insert quotesListToInsert;
            
            map<String,list<id>> newdata= new map<String,list<id>>();
            for(integer i=0; i< quoteDetailWrpList.size(); i++){
                for(integer j=0; j< quoteDetailWrpList[i].cdlId.size(); j++){
                    if(!newdata.containsKey(quoteDetailWrpList[i].masterQuote)){
                        newdata.put(quoteDetailWrpList[i].masterQuote,new LIst<id>{quoteDetailWrpList[i].cdlId[j]});
                    }
                    else{
                        newdata.get(quoteDetailWrpList[i].masterQuote).add(quoteDetailWrpList[i].cdlId[j]);
                    }   
                }                        
            }
            
            
            list<ContentDocumentLink> allCdLinksToIns = new list<ContentDocumentLink> ();
            for(Quote qtlst : quotesListToInsert){
                System.debug('-------'+qtlst.Gruop_Name__c);
                if(newdata != null && newdata.size() > 0){
                    if(newdata.get(qtlst.Gruop_Name__c) != null && newdata.get(qtlst.Gruop_Name__c).size() > 0){
                        for(String s : newdata.get(qtlst.Gruop_Name__c)){
                            system.debug('s--===--=='+s);
                            ContentDocumentLink cdlink = new ContentDocumentLink();
                            cdlink.ContentDocumentId = s;
                            cdlink.LinkedEntityId = qtlst.Id;
                            cdlink.ShareType = 'I';  
                            allCdLinksToIns.add(cdlink);
                        }
                    }
                }
            }
            system.debug('--allCdLinksToIns--'+allCdLinksToIns);
            if(!allCdLinksToIns.isEmpty()){
                Insert allCdLinksToIns;
            }
            
            
            String featuredQuote;
            Id loanfeeRT = Schema.SObjectType.Loan_Fees__c.getRecordTypeInfosByName().get('Quote Loan Fees').getRecordTypeId();
            for(Quote qt : quotesListToInsert){
                Product2 pr = productsMap.get(qt.Product__c);
                if(qt.Is_Featured__c){
                    featuredQuote = qt.Id;
                }
                for(Loan_Fees__c fees: pr.Loan_Fees__r){    
                    Loan_Fees__c fee = New Loan_Fees__c();  
                    fee.Active__c = fees.Active__c; 
                    fee.Amount__c = fees.Amount__c; 
                    fee.Description__c = fees.Description__c;   
                    fee.Fee_From__c = fees.Fee_From__c; 
                    fee.Product_Loan_Fees__c =fees.Id;  
                    fee.Fee_Type__c =fees.Fee_Type__c;  
                    fee.Frequency__c =fees.Frequency__c;    
                    fee.Notes__c =fees.Notes__c;    
                    fee.Override_allowed__c =fees.Override_allowed__c;  
                    fee.RecordTypeId = loanfeeRT;   
                    fee.Quote__c = qt.Id;   
                    loanFees.add(fee);  
                }
            }
            if(String.isBlank(featuredQuote)){
                featuredQuote = quotesListToInsert[0].Id;
            }
            insert loanFees;
            if(loanFees != null){
                newWrp.errorMessage = 'Success!';
                return newWrp;
            }
            return null;
        }catch(exception e){
            UtilityClass.createException(oppId,'MyReferrerController', 'newQuotes', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @AuraEnabled
    public static VoiWrapper GetVoiRelToOpp(String oppId){
        try{
            system.debug('oppid'+oppId);
            Opportunity opp = [SELECT id,Name,StageName,Docs_Outstanding__c,SyncedQuoteId,Applicant_2__r.Phone,Contact_1__c, 
                               Applicant_1__c,Applicant_1_Name__c,Applicant_2_Name__c,App_1_VOI_eSign_Complete__c,Contact_2__c,Applicant_2__r.personContactId, Applicant_1__r.PersonEmail,Applicant_1__r.personContactId,Applicant_2__c from Opportunity where id =: oppId];
            Set<id> conIds = new Set<id>();
            conIds.add(Opp.Applicant_1__r.personContactId);
            if(opp.Applicant_2__c != null){
                conIds.add(Opp.Applicant_2__r.personContactId); 
            }
            Map<id,VOI_Status__c> VOIMap = new Map<id,VOI_Status__c>();
            List<VOI_Status__c> VOIList = new List<VOI_Status__c>();
            for(VOI_Status__c vs : [SELECT Id,Opportunity__c,Contact__c,Contact__r.id, VOI_Type_For__c, Case_Status__c FROM VOI_Status__c where Contact__r.id IN: conIds]){
                if(!VOIMap.containsKey(vs.Contact__r.id)){
                    VOIMap.put(vs.Contact__r.id, vs);
                }
                else{
                    VOIMap.put(vs.Contact__r.id, vs);
                }
            }
            list<Quote> qtDetails = new list<Quote>();
            if(opp.SyncedQuoteId != null){
                qtDetails = [Select id, Gruop_Name__c from Quote where id =: opp.SyncedQuoteId];            
            }         
            VoiWrapper vw = new VoiWrapper();
            vw.Opportunity = opp;
            vw.quote = qtDetails.isEmpty() ? null : qtDetails[0];
            
            if(VOIMap.containsKey(Opp.Applicant_1__r.personContactId)){
                if(VOIMap.get(Opp.Applicant_1__r.personContactId).Case_Status__c == 'Sent' || VOIMap.get(Opp.Applicant_1__r.personContactId).Case_Status__c == 'Delivered'){
                    vw.Voi1 = VOIMap.get(Opp.Applicant_1__r.personContactId);
                }
            }
            if(opp.Applicant_2__c != null){
                if(VOIMap.containsKey(Opp.Applicant_2__r.personContactId)){
                    if(VOIMap.get(Opp.Applicant_2__r.personContactId).Case_Status__c == 'Sent' || VOIMap.get(Opp.Applicant_2__r.personContactId).Case_Status__c == 'Delivered'){
                        vw.Voi2 = VOIMap.get(Opp.Applicant_2__r.personContactId);
                    }
                }   
            }       
            return vw;
        }catch(exception e){
            UtilityClass.createException(oppId,'MyReferrerController', 'GetVoiRelToOpp', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    } 
    
    @AuraEnabled
    public static Opportunity GetOppOnExpand(String oppId){
        try{
            Opportunity opp = [SELECT id,Name,StageName,Docs_Outstanding__c,SyncedQuoteId,Applicant_2__r.Phone,Contact_1__c, 
                               Applicant_1__c,Applicant_1_Name__c,Applicant_2_Name__c,App_1_VOI_eSign_Complete__c,Contact_2__c,
                               Applicant_1_Email__c,Applicant_1_Phone_Number__c, CreatedDate,App_2_VOI_eSign_Complete__c,
                               Applicant_1__r.FirstName,Applicant_1__r.LastName, Applicant_1__r.PersonEmail,Applicant_2__r.personContactId,
                               Applicant_1__r.Phone,Lender__c,LeadId__c,Loan_Amount__c,Status__c,Applicant_2__c,
                               Current_Application_Sections__c,Total_Funds_Available__c,Applicant_1__r.personContactId,
                               ReferredByContact__r.Name,ReferredByContact__r.Email,ReferredByContact__r.Referrer_Rating__c,
                               ReferredByContact__c,Applicant_1__r.Name,Application_Pending_Notes__c,RecordType.Name,Line_Chart_JSON__c,installationAddressLineOne__c,
                               Applicant_1__r.Number_of_applicants_to_operate_account__pc,SyncedQuote.Product__r.Funding_Options_Available__c,SyncedQuote.Customer_Amount__c,
                               SyncedQuote.Product__r.No_of_Signatories_allowed__c,SyncedQuote.Product__r.Instruction_In_full_after_installation__c,
                               SyncedQuote.Product__r.Instruction_In_full_before_installation__c,SyncedQuote.Product__r.Instruction_Part_payment_before__c,
                               SyncedQuote.Product__r.Surplus_Instructions__c,Approved_Expire_Date__c,
                               SyncedQuote.Product__r.Short_Fall_Instructions__c FROM Opportunity WHERE Id=: oppId LIMIT 1];
            return opp;
            
        }
        catch(exception e){
            UtilityClass.createException(oppId,'MyReferrerController', 'GetOppOnExpand', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
        
    }
    
    @AuraEnabled
    public static Document_Requested__c addDocReqOnOppfromFunding(String OppId, String docId) {
        list<ContentDocumentLink> allCdLinks = new list<ContentDocumentLink> ();
        for(ContentDocumentLink cdDoc : [select Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility 
                                         from ContentDocumentLink where LinkedEntityId =: OppId]){
                                             if(cdDoc.ContentDocumentId == docId){
                                                 allCdLinks.add(cdDoc);       
                                             }
                                         }
        Opportunity Opp = [SELECT Id,Applicant_1__c FROM Opportunity WHERE Id =: OppId ];
        list<ContentVersion> cvList = new list<ContentVersion>();                
        List<Document_Requested__c> dcList = new List<Document_Requested__c>();
        
        if(allCdLinks != null && allCdLinks.size() > 0){
            Document_Requested__c dc = new Document_Requested__c();
            dc.Document__c = 'Purchase Quote';
            dc.Category__c = 'Purchase Invoice';
            dc.isComplete__c = true;
            dc.Person_Account__c =  Opp.Applicant_1__c;
            dc.Opportunity__c = Opp.Id;
            dcList.add(dc);
        }
        if(!dcList.isEmpty()){
            upsert dcList;
        }
        Set<id> isds = new Set<id>();
        list<ContentVersion> cdlSet = new list<ContentVersion>();
        for(ContentDocumentLink cv : allCdLinks){   
            isds.add(cv.ContentDocumentId);
        }
        
        for(contentVersion cvs : [select id,contentDocumentId, title from contentVersion where contentDocumentId in: isds]){
            cvs.Document_Requested__c = dcList[0].id;
            //cvs.Current_in_use__c = true;
            cvList.add(cvs); 
        }
        
        update cvList;
        return dcList[0];
    }
    
    @AuraEnabled
    public static void ReplaceDoc(String OppId, String docId,String DocReqId) {
        contentVersion cvs;
        if(docId != null && DocReqId != null){
            cvs = [select id,contentDocumentId, title,Current_in_use__c from contentVersion where contentDocumentId =:docId LIMIT 1];
            // cvs.Current_in_use__c = true;
            cvs.Document_Requested__c = DocReqId;
        } 
        if(cvs != null){
            update cvs;
        }
        list<ContentDocumentLink> allCdLinks = new list<ContentDocumentLink> ();
        list<ContentVersion> cvList = new list<ContentVersion>();                
        Set<id> isds = new Set<id>();
        for(ContentDocumentLink cdDoc : [select Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility 
                                         from ContentDocumentLink where LinkedEntityId =: OppId]){
                                             if(cdDoc.ContentDocumentId != docId){
                                                 allCdLinks.add(cdDoc);       
                                             }
                                         }
        if(allCdLinks.Size() > 0){
            for(ContentDocumentLink cv : allCdLinks){   
                isds.add(cv.ContentDocumentId);
            }
            for(contentVersion oldcv : [select id,contentDocumentId,Category__c,title from contentVersion where contentDocumentId in: isds AND Category__c='Purchase Invoice']){
                if(oldcv != null){
                    //  oldcv.Current_in_use__c = false;
                    cvList.add(oldcv);
                }
            }
        }
        if(cvList.Size() > 0){
            //  update cvList;
        }
    }
    
    @AuraEnabled
    public static QuoteDetailWrapper getDocument(String OppId) {
        QuoteDetailWrapper qtWrapper = new QuoteDetailWrapper();
        list<ContentDocumentLink> allCdLinks = new list<ContentDocumentLink> ();
        ContentDocument doc;
        Document_Requested__c req;
        if(OppId != null){
            for(ContentDocumentLink cdDoc : [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility 
                                             from ContentDocumentLink where LinkedEntityId =: OppId]){
                                                 if(cdDoc != null){
                                                     allCdLinks.add(cdDoc);  
                                                 }
                                             }
        }
        Set<id> ContentDocIds = new Set<id>();
        Set<id> newConDocIds = new Set<id>();
        Set<Id> docReq = new Set<Id>();
        if(allCdLinks.Size() > 0 && allCdLinks != null){
            for(ContentDocumentLink cv : allCdLinks){   
                ContentDocIds.add(cv.ContentDocumentId);
            }
            for(ContentVersion cvs : [SELECT Id,contentDocumentId, title,Category__c,Current_in_use__c,Document_Requested__c from contentVersion where contentDocumentId IN: ContentDocIds ORDER BY CreatedDate DESC]){
                if(cvs != null && cvs.Current_in_use__c ==true && cvs.Category__c=='Purchase Invoice'){
                    newConDocIds.add(cvs.contentDocumentId);  
                    docReq.add(cvs.Document_Requested__c);
                }
            }
        }
        if (!newConDocIds.isEmpty()) {
            doc = [SELECT Id,Title,FileType FROM ContentDocument WHERE Id IN : newConDocIds LIMIT 1];
            ContentVersion Cvv = [SELECT Id,contentDocumentId,Document_Requested__c,CreatedDate,Current_in_use__c from contentVersion where contentDocumentId =: doc.Id AND Current_in_use__c = true ORDER By CreatedDate DESC LIMIT 1];
            if(doc != null && Cvv.Document_Requested__c != null){
                String name = doc.Title;
                if (name.length() > 22) {
                    String truncatedName = name.substring(0, 22) + '...';
                    qtWrapper.NmList.add(truncatedName);
                }
                else{
                   qtWrapper.NmList.add(doc.Title); 
                }
                qtWrapper.cdlId.add(doc.Id);
                qtWrapper.document = doc; 
                qtWrapper.docReqId = Cvv.Document_Requested__c;
            } 
        }
        return qtWrapper;   
    }
    
    @AuraEnabled
    public static boolean deleteDocumentRequest(String OppId, Id reqId) {
        boolean ret=false;
        Set<Id> cntDocIds = new Set<Id>();
        List<ContentVersion> cvList =new  List<ContentVersion>();
        Document_Requested__c docreq;
        system.debug('OppppId'+OppId);
        system.debug('reqId'+reqId);
        if(OppId !=null && reqid !=null ){
            docreq =  [SELECT Id FROM Document_Requested__c WHERE Id=: reqId];
            system.debug('docreq'+docreq);
            List<ContentDocumentLink> CntList = [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=: OppId];
            system.debug('CntListRelatedToOpp'+CntList);
            if(CntList.Size() > 0){
                for(ContentDocumentLink cnt : CntList){
                    cntDocIds.add(cnt.ContentDocumentId); 
                }
            }
            System.debug('CntDocIdsss'+cntDocIds);
            if(cntDocIds.Size() > 0){
                cvList = [SELECT Id,ContentDocumentId,Current_in_Use__c,Document_Requested__c,Category__c FROM ContentVersion WHERE ContentDocumentId In: cntDocIds ORDER By CreatedDate DESC]; 
                for(ContentVersion cv : cvList){
                    if(Cv != null && Cv.Current_in_Use__c == true && cv.Category__c == 'Purchase Invoice'){ 
                        ret = true;
                        break;
                    }
                }
            }
            if(cvList.isEmpty() && ret != true){
                delete docreq;
            }
        }
        return ret;
    }
    
    @AuraEnabled
    public static List<Funding_Request__c> createFundingRequest(String oppId,Decimal invoice_amount,String reqType,Decimal req_amount,String Csmtr_agreedORSatisfy,Date Inst_Date,String Cstmr_auth_Type, Decimal Surplus_Shortfall,String app1, String app2, String refId){
        boolean Lender_Credit_Doc_Exist = false;
        Set<Id> contentDocId = new Set<Id>();
        List<ContentDocumentLink> linkList = [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: oppId];  
        if(!linkList.isEmpty()){
            for(ContentDocumentLink cnt : linkList){
                contentDocId.add(cnt.ContentDocumentId); 
            }
        }
        if(!contentDocId.isEmpty()){
            List<ContentVersion> cvList = [SELECT Id, Title,Category__c,Current_in_use__c, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: contentDocId];
            if(!cvList.isEmpty()){
                for(ContentVersion cvv : cvList){
                    if(cvv.Category__c == 'Lender Credit Contract' && cvv.Current_in_use__c == true){
                       Lender_Credit_Doc_Exist = true;
                        break;
                    }
                }
            }
        }
        
        Funding_Request__c fr = new Funding_Request__c();
        fr.Opportunity__c = oppId;
        fr.Applicant_1_A1__c = app1;
        if(app2 != null){
        fr.Applicant_2_A2__c = app2;   
        }
        fr.Person_Requesting__c = refId;
        fr.Invoice_Amount__c = invoice_amount;
        fr.Request_Type__c = reqType;
        //fr.Previous_Req_Type__c = reqType;
        fr.Request_Amount__c = req_amount;
        fr.Net_Surplus_Shortfall__c = Surplus_Shortfall;
        if(reqType == 'Payment in full before installation' || reqType == 'Part payment before installation' || reqType == 'Remainder of payment after installation'){
            fr.Has_the_customer_agreed_to_this_payment__c = Csmtr_agreedORSatisfy;  
            fr.Installation_Date__c = Inst_Date;
            fr.Installation_Date_Confirmed__c = 'Anticipated';
        }
        else if(reqType == 'Payment in full after installation'){
            fr.System_installed_Customer_Satisfaction__c = Csmtr_agreedORSatisfy;
            fr.Installation_Date__c = Inst_Date;
            fr.Installation_Date_Confirmed__c = 'Confirmed by supplier';  
        }
        fr.Request_Date__c = System.Now();
        fr.Requested_by__c = 'Supplier';
        fr.Request_Origin__c = 'Referrer Portal';
        
        if(Lender_Credit_Doc_Exist == true){
        fr.Request_Status__c = 'Payment requested by supplier';
        }
        else if(Lender_Credit_Doc_Exist == false){
        fr.Request_Status__c = 'Payment requested by supplier (pending contract)';
        }
        
        fr.Customer_Authorisation_Type__c = Cstmr_auth_Type;
        fr.Customer_Authorisation_Status__c = 'Request sent to customer(s)';
        
        system.debug('fundingRequest---->>'+fr);
        insert fr; 
        
        Opportunity opp = [SELECT Id,Name,StageName FROM Opportunity WHERE Id=: oppId LIMIT 1];
        opp.StageName = 'Funding';
        Update opp;
        
        
        List<Funding_Request__c> frList = [SELECT Id,Request_Type__c,Request_Date__c,Request_Amount__c,Request_Status__c,Invoice_Amount__c,
                                           Date_Last_Request_Status_Changes__c,Net_Funds_after_Request__c,Funding_On_Hold__c,Funding_escalation__c,
                                           Net_Funds_Available__c,Funding_On_Hold_Reason__c FROM Funding_Request__c WHERE Opportunity__c =: OppId  
                                           Order by Request_Date__c DESC]; 
        return frList;
    }
    
    @AuraEnabled
    public static List<Funding_Request__c> getPreviousFundingRequests(String OppId){
        List<Funding_Request__c> frList = [SELECT Id,Request_Type__c,Request_Date__c,Request_Amount__c,Request_Status__c,Invoice_Amount__c,
                                           Date_Last_Request_Status_Changes__c,Net_Funds_after_Request__c,Funding_On_Hold__c,Funding_escalation__c,
                                           Net_Funds_Available__c,Funding_On_Hold_Reason__c FROM Funding_Request__c WHERE Opportunity__c =: OppId
                                           Order by Request_Date__c DESC]; 
        return frList;
    }
    
    
    public class VoiWrapper{
        @AuraEnabled public Opportunity Opportunity;
        @AuraEnabled public VOI_Status__c Voi1;
        @AuraEnabled public VOI_Status__c Voi2;
        @AuraEnabled public Quote quote;
    }
    
    public class QuoteDetailWrapper{
        @auraEnabled public String masterQuote {get;set;}
        @auraEnabled public Decimal Amount {get;set;}
        @auraEnabled public String errorMessage {get;set;}
        @auraEnabled public Boolean checkError {get;set;}
        @auraEnabled public Boolean nameError {get;set;}
        @auraEnabled public Decimal minAmt {get;set;}
        @auraEnabled public Decimal maxAmt {get;set;}
        @auraEnabled public list<String> NmList =new List<string>();
        @auraEnabled public list<id> cdlId =new List<id>();
        @auraEnabled public ContentDocument document {get;set;}
        @auraEnabled public Id docReqId {get;set;}
    }
    
    public class getMyReferralWrapper{
        @AuraEnabled public Opportunity Opportunity;
        @AuraEnabled public String Creationdate;
    }
    
    public class getQuotesWrapper{
        @AuraEnabled public Decimal InterestRate;
        @AuraEnabled public Decimal ComparsionRate;
        @AuraEnabled public Decimal Repayment;
        @AuraEnabled public Decimal Loanterm;
        @AuraEnabled public Decimal Amount;
        @AuraEnabled public String errorMessage {get;set;}
        @AuraEnabled public String nameError {get;set;}
        @AuraEnabled public Boolean checkError {get;set;}
        @AuraEnabled public Decimal minAmt {get;set;}
        @AuraEnabled public Decimal maxAmt {get;set;}
        @AuraEnabled public String oppId;
        @AuraEnabled public string masterQuoteForURL;
        @AuraEnabled public String GroupName;
        @AuraEnabled public String GroupLabel;
        @AuraEnabled public Boolean isChecked; 
    }
    
}