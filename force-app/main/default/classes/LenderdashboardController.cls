public without sharing class LenderdashboardController {
    
    @auraEnabled
    public static void updateViewofPortal(contact con, string val){
        try{
            contact cn = new contact();
            cn.id = con.id;
            if(cn.Portal_View__c != val){
                cn.Portal_View__c = val;    
                update cn;
            }
        }catch(exception e){
            UtilityClass.createException(con.Id,'LenderdashboardController', 'updateViewofPortal', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
        }
    }
    
    @auraEnabled
    public static Contact login(String getPassword, String username){
        list<contact> conList = new list<contact>();
        if(username != null){
            conList = [SELECT Id, Name, Status__c, Password__c, Email, AccountId, Phone, On_Board_Individual__c FROM Contact where Email =: username AND RecordType.Name = 'Lender Contact'];
        }
        if(conList[0].Password__c == getPassword){           
            return conList[0];
        }
        return null;
    }    
    
    @auraEnabled
    public static getMyTeamWrapper SendMessage(String getPassword){
        try{
            Contact conList;
            if(getPassword != null){
                conList=[SELECT Id, Name, Status__c, Password__c, Email, AccountId, Phone, On_Board_Individual__c, PhoneForPortal__c FROM Contact where Password__c =: getPassword AND RecordType.Name = 'Lender Contact'];
            }
            if(conList != Null){
                List<smagicinteract__smsMagic__c> smsObjectList = new List<smagicinteract__smsMagic__c> ();
                Double randomNum = Math.floor(1000 + Math.random() * 9000);
                Integer num = Math.round(randomNum);
                //String senderId = 'Parkerlane'; // Please replace the 'smsMagic' with your relevant sender ID.
                String templateText = 'Your 4-digit verification code is ' + num; // you can fetch the template text by querying the record on smagicinteract__SMS_Template__c object 
                smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
                smsObject.smagicinteract__SenderId__c = 'parkerlane';
                smsObject.smagicinteract__PhoneNumber__c = conList.PhoneForPortal__c;//'61400247471';//contact.MobilePhone;
                smsObject.smagicinteract__Name__c = 'test';//contact.Name; // recordsname
                smsObject.smagicinteract__ObjectType__c = 'Contact';//'Contact'; // record type
                smsObject.smagicinteract__disableSMSOnTrigger__c = 0; // this field either be 0 or 1, if you specify the value as 1 then sms will not get send but entry of sms will get create under SMS History object
                smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
                smsObject.smagicinteract__SMSText__c = templateText;
                smsObject.smagicinteract__Contact__c = conList.Id;
                smsObjectList.add(smsObject);
                Database.SaveResult[] results = Database.insert(smsObjectList, false);
                // iterate over the list of returned results
                for(Database.SaveResult result : results) {
                    if(result.isSuccess()) {
                        //  System.debug('Successfully inserted Accounts : ' + result.getId());
                    } else {
                        // iterate over the failed ones
                        for(Database.Error error : result.getErrors()) {
                            System.debug('Error Status : ' + error.getMessage() + ' : ' + 'Error Fields : ' + error.getFields());
                        }
                    }
                }    
                getMyTeamWrapper gmt = new getMyTeamWrapper();
                gmt.rndNum = randomNum;
                gmt.ReferrerContact = conList;
                return gmt;
            }
            return null;
        }catch(exception e){
            UtilityClass.createException('','LenderdashboardController', 'SendMessage', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @auraEnabled
    public static void passwordUpdate(String recId, String newPassword){
        contact getContact = new contact();
        getContact.id = recId;
        getContact.Password__c = newPassword;
        update getContact;
    }    
    
    @auraEnabled
    public static Integer emailForOtp(String recId){
        try{
            Double randomNum = Math.floor(1000 + Math.random() * 9000);
            Integer num = Math.round(randomNum);
            contact getContact = [Select id,Session_Start_Time__c,Email,LoginOtp__c,Count__c, Phone, PhoneForPortal__c from contact where id =: recId LIMIT 1];
            getContact.LoginOtp__c = String.valueOf(num);
            update getContact;
            OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address =:UtilityClass.adminEmail];
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<string> sendTo = new List<string>();
            if(getContact.Email != Null){
                sendTo.add(getContact.Email);
            }
            mail.setToAddresses(sendTo);
            if(owea.size() > 0){
                mail.setorgWideEmailAddressId(Owea.get(0).Id);
            }
            mail.setUseSignature(false);
            mail.setTargetObjectId(getContact.id);
            mail.Setwhatid(getContact.id); 
            mail.setSaveAsActivity(false);
            mail.setTreatTargetObjectAsRecipient(false);
            EmailTemplate et=[Select id, Subject, Body from EmailTemplate where Name = 'sendEmailOtp']; 
            mail.setTemplateId(et.id);
            mails.add(mail);
            if(!test.isRunningTest()){
                Messaging.sendEmail(mails);   
            }
            return num;
        }catch(exception e){
            UtilityClass.createException(recId,'LenderdashboardController', 'emailForOtp', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @auraEnabled
    public static boolean updatePasswordEmail(String username){
        boolean state;
        try{
            Double randomNum = Math.floor(1000 + Math.random() * 9000);
            Integer num = Math.round(randomNum);
            Contact getContact = [Select id, Email, LoginOtp__c, RecordType.Name from contact where Email =: username AND RecordType.Name = 'Lender Contact' limit 1];
            getContact.LoginOtp__c = String.valueOf(num);
            update getContact;
            OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address =:UtilityClass.adminEmail];
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<string> sendTo = new List<string>();
            if(username != Null){
                sendTo.add(username);
            }
            mail.setToAddresses(sendTo);
            if(owea.size() > 0){
                mail.setorgWideEmailAddressId(Owea.get(0).Id);
            }
            mail.setUseSignature(false);
            mail.setTargetObjectId(getContact.id);
            mail.Setwhatid(getContact.id); 
            mail.setSaveAsActivity(false);
            mail.setTreatTargetObjectAsRecipient(false);
            EmailTemplate et=[Select id, Subject, Body from EmailTemplate where Name = 'OtpToChangePassword']; 
            mail.setTemplateId(et.id);
            mails.add(mail);
            if(!test.isRunningTest()){
                Messaging.sendEmail(mails);   
            }
            state = true;
        }catch(exception e){
            state = false;
            UtilityClass.createException('','LenderdashboardController', 'emailForOtp', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
        }
        return state;
    }
    
    @auraEnabled 
    public static void otpMatched(String conId){
        try{
            Contact con = [Select Id,flag__c,Admin__c,Portal_View__c from contact where id =: conId];
            con.flag__c = true;
            if(con.Admin__c){
                con.Portal_View__c = 'Admin View';   
            }
            update con;
        }catch(exception e){
            UtilityClass.createException(conId,'LenderdashboardController', 'otpMatched', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
        }
    }
    
    @AuraEnabled
    public static list<getOppWrapper> getOpp(String contactId){
        try{
            set<id> oppIds = new set<id>();
            id conid = (id)contactId;
            contact con = [SELECT Id, Name,Portal_View__c,Admin__c,AccountId FROM Contact WHERE Id=: conid];
            List<Contact> conList = new List<Contact>();
            boolean adminCheck;
            list<Opportunity> oppList = new List<Opportunity>();
            list<String> stlist = new list<String>{'Approved','Settled (closed won)', 'Funding'};
                if(con.Portal_View__c == 'Admin View' && con.Admin__c){
                    conList = [SELECT Id, Name, AccountId FROM Contact WHERE AccountId = : con.AccountId];
                    oppList = [SELECT id,Name,Line_Chart_JSON__c,Stagename,Applicant_1_Name__c,Applicant_2_Name__c,Applicant_1_Email__c,Applicant_1_Phone_Number__c, CreatedDate,Lender__c, Loan_Amount__c,Status__c,Lender_Application_ID__c,SyncedQuote.Customer_Amount__c,
                               Current_Application_Sections__c,Last_Stage_Change_Date__c,Total_Funds_Available__c,FinServ__ReferredByContact__r.Name,FinServ__ReferredByContact__c,Lender_Agent__c,Applicant_1__c,Applicant_1__r.Name,Application_Pending_Notes__c,Lender_Agent__r.Name,
                               Applicant_1__r.FirstName,Send_the_quote_to__c,Approved_Date__c,Approved_Expire_Date__c,Applicant_1__r.LastName,RecordType.Name,Applicant_1__r.PersonEmail,Applicant_1__r.Phone,SyncedQuote.Product__r.Lender_Account__c,SyncedQuote.Product__r.Lender_Account__r.Name
                               FROM Opportunity WHERE SyncedQuote.Product__r.Lender_Account__c =: con.AccountId AND Stagename IN:stlist ORDER BY CreatedDate DESC];
                }
            else{
                conList = [SELECT Id, Name,AccountId FROM Contact WHERE id =: con.Id];
                oppList = [SELECT id,Name,Line_Chart_JSON__c,Stagename,Applicant_1_Name__c,Applicant_2_Name__c,Applicant_1_Email__c,Applicant_1_Phone_Number__c, CreatedDate,Lender__c, Loan_Amount__c,Status__c,Lender_Application_ID__c,SyncedQuote.Customer_Amount__c,
                           Current_Application_Sections__c,Last_Stage_Change_Date__c,Total_Funds_Available__c,FinServ__ReferredByContact__r.Name,FinServ__ReferredByContact__c,Lender_Agent__c,Applicant_1__c,Applicant_1__r.Name,Application_Pending_Notes__c,Lender_Agent__r.Name,
                           Applicant_1__r.FirstName,Send_the_quote_to__c,Approved_Date__c,Approved_Expire_Date__c,Applicant_1__r.LastName,RecordType.Name,Applicant_1__r.PersonEmail,Applicant_1__r.Phone,SyncedQuote.Product__r.Lender_Account__c,SyncedQuote.Product__r.Lender_Account__r.Name
                           FROM Opportunity WHERE Lender_Agent__c IN : conList AND Stagename IN:stlist ORDER BY CreatedDate DESC];
            }           
            for(Opportunity op : oppList){
                oppIds.add(op.id);
            }
            
            list<Funding_Request__c> frList = [Select id, Funding_On_Hold__c, Funding_Hold_Expiry_Date__c, Opportunity__r.Lender_Agent__r.Name, Request_Amount__c, Opportunity__r.Last_Stage_Change_Date__c, Opportunity__r.Status__c, Opportunity__r.Name, Opportunity__r.StageName, Request_Type__c, Request_Status__c from Funding_Request__c where Opportunity__c IN: oppIds];
            integer Approved = 0; 
            integer Disbursement = 0;
            integer partfunded = 0;
            decimal totalfunded = 0;
            list<getOppWrapper> refList = new List<getOppWrapper>();
            List<String> stageList = New List<String>{'CPA Started','CPA Done','Packs Out','Packs Back','CPA Done','Application','Submitted','Conditionally Approved'};
                for(opportunity op : oppList){
                    if(op.Stagename == 'Approved' && (op.Approved_Date__c != null ? op.Approved_Date__c.Date().daysBetween(system.today()) < 91 : false)){
                        Approved+= 1;
                    }
                }
            Map<id,list<Funding_Request__c>> mapOfFunding = new Map<id,list<Funding_Request__c>>();
            for(Funding_Request__c fr : frList){
                if(fr.Opportunity__r.StageName == 'Funding' && fr.Request_Status__c == 'Payment authorised by customer'){
                    Disbursement+= 1;
                }
                if(fr.Opportunity__r.StageName == 'Funding' && fr.Request_Status__c == 'Payment funded' && fr.Request_Type__c == 'Part payment before installation'){
                    partfunded+= 1;
                }
                if(fr.Request_Status__c == 'Payment funded'){
                    totalfunded+= (fr.Request_Amount__c != null ? fr.Request_Amount__c : 0);
                }
                if(!mapOfFunding.containsKey(fr.Opportunity__c)){
                    mapOfFunding.put(fr.Opportunity__c, new list<Funding_Request__c>{fr});
                }
                else{
                    mapOfFunding.get(fr.Opportunity__c).add(fr);
                }
            }
            List<getOppWrapper> objlist = new List<getOppWrapper>();
            if(!oppList.isEmpty()){
                for(integer i=0; i<oppList.size(); i++){                
                    if(i == 31){
                        break;
                    }
                    else{
                        getOppWrapper obj = new getOppWrapper();
                        obj.fundingApproved = Approved;
                        obj.fundingDisbursement = Disbursement;
                        obj.fundingpartfunded = partfunded;                        
                        obj.fundingtotalfunded = totalfunded;
                        obj.checkAdmin = con.Admin__c;
                        obj.getFundList = mapOfFunding.containsKey(oppList[i].Id) ? mapOfFunding.get(oppList[i].Id) : null ;
                        obj.getOpp = oppList[i];
                        obj.Oldrecords = oppList.size();
                        objlist.add(obj);
                    }
                }
            }
            else{
                getOppWrapper obj = new getOppWrapper();
                obj.checkAdmin = con.Admin__c;
                objlist.add(obj);
            }
            return objlist;
        }catch(exception e){
            UtilityClass.createException(contactId,'LenderdashboardController', 'getOpp', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @AuraEnabled
    public static list<Opportunity> getSearchData(String contactId, String searchKey){
        try{
            Contact Con = [SELECT Id,AccountId,Admin__c,Portal_View__c FROM Contact WHERE Id=:contactId LIMIT 1];
            Id AccountId = Con.AccountId;
            List<Opportunity> oppList = new List<Opportunity>();
            
            if ( searchKey != Null ) {
                String query ='SELECT id,Name FROM Opportunity WHERE (Lender_Agent__c =: contactId';
                if(con.Admin__c == true && con.Portal_View__c == 'Admin View' && AccountId != null){
                    query += ' OR SyncedQuote.Product__r.Lender_Account__c =: AccountId';   
                }
                String key = '%' + searchKey + '%';
                query += ') AND Name LIKE :key'; 
                oppList = Database.query(query);
                return oppList;
            }
            else{
                return null;
            }
        }catch(exception e){
            UtilityClass.createException(contactId,'LenderdashboardController', 'getSearchData', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @AuraEnabled
    public static list<getOppWrapper> getOppOnScrollForRecent(String contactId, List<Opportunity> oldoppList){
        try{
            id conid = (id)contactId;
            set<id> oppIds = new set<id>();
            contact con = [SELECT Id, Name,Portal_View__c,Admin__c,AccountId FROM Contact WHERE Id=: conid];
            List<Contact> conList = new List<Contact>();
            boolean adminCheck;
            list<Opportunity> oppList = new List<Opportunity>();
            list<String> stlist = new list<String>{'Approved','Settled (closed won)', 'Funding'};
                if(con.Portal_View__c == 'Admin View' && con.Admin__c){
                    conList = [SELECT Id, Name, AccountId FROM Contact WHERE AccountId = : con.AccountId];
                    oppList = [SELECT id,Name,Line_Chart_JSON__c,Stagename,Applicant_1_Name__c,Applicant_2_Name__c,Applicant_1_Email__c,Applicant_1_Phone_Number__c, CreatedDate,Lender__c, Loan_Amount__c,Status__c,Lender_Application_ID__c,SyncedQuote.Customer_Amount__c,
                               Current_Application_Sections__c,Last_Stage_Change_Date__c,Total_Funds_Available__c,FinServ__ReferredByContact__r.Name,FinServ__ReferredByContact__c,Lender_Agent__c,Applicant_1__c,Applicant_1__r.Name,Application_Pending_Notes__c,Lender_Agent__r.Name,
                               Applicant_1__r.FirstName,Send_the_quote_to__c,Approved_Date__c,Approved_Expire_Date__c,Applicant_1__r.LastName,RecordType.Name,Applicant_1__r.PersonEmail,Applicant_1__r.Phone,SyncedQuote.Product__r.Lender_Account__c,SyncedQuote.Product__r.Lender_Account__r.Name
                               FROM Opportunity WHERE SyncedQuote.Product__r.Lender_Account__c =: con.AccountId AND Stagename IN:stlist AND ID NOt IN:oldoppList ORDER BY CreatedDate DESC];
                }
            else{
                conList = [SELECT Id, Name,AccountId FROM Contact WHERE id =: con.Id];
                oppList = [SELECT id,Name,Line_Chart_JSON__c,Stagename,Applicant_1_Name__c,Applicant_2_Name__c,Applicant_1_Email__c,Applicant_1_Phone_Number__c, CreatedDate,Lender__c, Loan_Amount__c,Status__c,Lender_Application_ID__c,SyncedQuote.Customer_Amount__c,
                           Current_Application_Sections__c,Last_Stage_Change_Date__c,Total_Funds_Available__c,FinServ__ReferredByContact__r.Name,FinServ__ReferredByContact__c,Lender_Agent__c,Applicant_1__c,Applicant_1__r.Name,Application_Pending_Notes__c,Lender_Agent__r.Name,
                           Applicant_1__r.FirstName,Send_the_quote_to__c,Approved_Date__c,Approved_Expire_Date__c,Applicant_1__r.LastName,RecordType.Name,Applicant_1__r.PersonEmail,Applicant_1__r.Phone,SyncedQuote.Product__r.Lender_Account__c,SyncedQuote.Product__r.Lender_Account__r.Name
                           FROM Opportunity WHERE Lender_Agent__c IN : conList AND Stagename IN:stlist AND ID NOt IN:oldoppList ORDER BY CreatedDate DESC];
            }
            
            for(Opportunity op : oppList){
                oppIds.add(op.id);
            }
                
            list<Funding_Request__c> frList = [Select id, Funding_On_Hold__c, Funding_Hold_Expiry_Date__c, Opportunity__r.Lender_Agent__r.Name, Request_Amount__c, Opportunity__r.Last_Stage_Change_Date__c, Opportunity__r.Status__c, Opportunity__r.Name, Opportunity__r.StageName, Request_Type__c, Request_Status__c from Funding_Request__c where Opportunity__c IN: oppIds];
            Map<id,list<Funding_Request__c>> mapOfFunding = new Map<id,list<Funding_Request__c>>();
            for(Funding_Request__c fr : frList){
                if(!mapOfFunding.containsKey(fr.Opportunity__c)){
                    mapOfFunding.put(fr.Opportunity__c, new list<Funding_Request__c>{fr});
                }
                else{
                    mapOfFunding.get(fr.Opportunity__c).add(fr);
                }
            }
            List<getOppWrapper> objlist = new List<getOppWrapper>();
            if(!oppList.isEmpty()){
                for(integer i=0; i<oppList.size(); i++){                
                    if(i == 31){
                        break;
                    }
                    else{
                        getOppWrapper obj = new getOppWrapper();
                        obj.getFundList = mapOfFunding.containsKey(oppList[i].Id) ? mapOfFunding.get(oppList[i].Id) : null ;
                        obj.getOpp = oppList[i];
                        objlist.add(obj);
                    }
                }
            }
            
            System.debug('wrapper+++++'+objlist);
            
            return objlist;
        }catch(exception e){
            UtilityClass.createException(contactId,'LenderdashboardController', 'getOppOnScrollForRecent', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @AuraEnabled
    public static Contact getMyAccount(String conId){
        try{
            Contact con=[SELECT Id, Name,MobilePhone,LoginOtp__c,Email,State__c,Account.Name,Referrer_Rating__c,Admin__c,
                         Declaration__c,Declaration_Signed_DateTime__c FROM Contact WHERE Id=: conId LIMIT 1];
            return con;
        }catch(exception e){
            UtilityClass.createException(conId,'LenderdashboardController', 'getMyAccount', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @AuraEnabled
    public static void createContact(list<contact>  contactlist,String conId){
        try{
            contact con2 = [select id,Name,AccountId from contact where id=: conId LIMIT 1];
            list<contact> listToinsert = new list<contact>();
            listToinsert = contactlist;
            for(integer i=0; i<listToinsert.size(); i++){
                listToinsert[i].recordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Lender_Contact').getRecordTypeId();
                listToinsert[i].accountId= con2.AccountId;
            }
            if(!listToinsert.isEmpty()){
                upsert listToinsert;
            }
        }catch(exception e){
            UtilityClass.createException(conId,'LenderdashboardController', 'createContact', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
        }    
    }
    
    @AuraEnabled
    public static contact SaveContactOnMyTeamCard(Contact con){
        try{
            if(con!=null){
                update con;
            }
            return con;
        }
        catch(exception e){
            UtilityClass.createException(con.Id,'LenderdashboardController', 'SaveContactOnMyTeamCard', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @auraEnabled
    public static list<getMyTeamWrapper> getMyTeam(String searchKey, String conId, String Str){
        try{
            contact cont = [select id, AccountId,name from contact where id=:conId LIMIT 1];
            
            list<contact> conlist = new List<contact>();
            
            if(searchKey != null){
                if(Str !=Null){
                    String key = '%' + searchKey + '%';
                    String qry ='select id,AccountId,name,lastname,Account.Name,FirstName,Email,MobilePhone,Referrer_Status__c,Status__c,Admin__c,Referrer_Rating__c,RecordTypeId from contact  where AccountId=\'' + cont.Accountid + '\' AND Name LIKE :key' ;
                    qry += ' ORDER By '+Str;
                    conlist = Database.query(qry);
                }
                else{
                    String key = '%' + searchKey + '%';
                    conlist =[select id,AccountId,name,lastname,Account.Name,FirstName,Email,MobilePhone,Referrer_Status__c,Status__c,Admin__c,Referrer_Rating__c,RecordTypeId from contact where accountid =: cont.AccountId AND Name LIKE :key];
                }
            }
            
            else if(Str !=Null){
                String qry ='select id,AccountId,name,lastname,Account.Name,FirstName,Email,MobilePhone,Referrer_Status__c,Status__c,Admin__c,Referrer_Rating__c,RecordTypeId from contact  where AccountId=\'' + cont.Accountid + '\'';
                qry += ' ORDER By '+Str;
                conlist = Database.query(qry);
            }
            
            else{
                conlist =[select id,AccountId,name,lastname,Account.Name,FirstName,Email,MobilePhone,Referrer_Status__c,Status__c,Admin__c,Referrer_Rating__c,RecordTypeId from contact where accountid =: cont.AccountId];
            }
            
            Map<id, list<opportunity>> MapOfApprovedLoanAmount = new Map<id, list<opportunity>>();
            Map<id, list<opportunity>> MapOfClosedLoanAmount = new Map<id, list<opportunity>>();
            Decimal TotalLoanAmount_Approved = 0;
            Decimal TotalLoanAmount_Settled =0;
            map<id,list<opportunity>> map1=new map<id,list<opportunity>>();
            list<Opportunity> opplist =[select id,name,stagename,Total_Loan_amount__c,FinServ__ReferredByContact__c,Lender_Agent__c from opportunity where Lender_Agent__c IN: conlist ];
            for(opportunity opp : opplist){

                if(opp.stagename =='Approved' || Opp.stagename =='Funding'){
                    if(!MapOfApprovedLoanAmount.containskey(opp.Lender_Agent__c)){
                        MapOfApprovedLoanAmount.put(opp.Lender_Agent__c, new List<opportunity>{opp});
                    }
                    else{
                        MapOfApprovedLoanAmount.get(opp.Lender_Agent__c).add(opp);
                    }
                }    
                
                if(opp.stagename =='Settled (closed won)'){
                    if(!MapOfClosedLoanAmount.containskey(opp.Lender_Agent__c)){
                        MapOfClosedLoanAmount.put(opp.Lender_Agent__c, new List<opportunity>{opp});
                    }
                    else{
                        MapOfClosedLoanAmount.get(opp.Lender_Agent__c).add(opp);
                    }
                }
            }
            
            list<getMyTeamWrapper> GMTlist = new list<getMyTeamWrapper>();
            for(contact con : conlist){
                //    SYstem.debug('con-------'+con.Name);
                getMyTeamWrapper GMT = new getMyTeamWrapper();
                string role = '';
                String AdministratorCheck;
                if(con.Admin__c==true){
                    role = 'Administrator';
                    AdministratorCheck = 'Yes';
                }
                else{
                    role='Agent';
                    AdministratorCheck = 'No';
                }
                GMT.AdministratorCheck = AdministratorCheck;
                GMT.Role=role;
                GMT.ReferrerContact = con;
                GMT.TotalAssigned= (MapOfApprovedLoanAmount.get(con.Id)!=null ? MapOfApprovedLoanAmount.get(con.Id).size() : 0);
                GMT.TotalFunded= (MapOfClosedLoanAmount.get(con.Id)!=null ? MapOfClosedLoanAmount.get(con.Id).size() : 0);
                GMT.contactList = conlist;
                GMTlist.add(GMT);
            }
            
            return GMTlist;
        }catch(exception e){
            UtilityClass.createException(conId,'LenderdashboardController', 'getMyTeam', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
        
    }
    
    @AuraEnabled
    public static contact getContact(String contactId){
        try{
            if(contactId != null){
                contact con = [SELECT Id,Authorised_Credit_Representative__c,PhoneForPortal__c,Account.Name,Email,Portal_View__c,Admin__c,Name,Phone,Position__c,Referrer_Rating__c,AccountId FROM contact where id =: contactId limit 1];
                return con;
            }
            return null;
        }catch(exception e){
            UtilityClass.createException(contactId,'LenderdashboardController', 'getContact', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @AuraEnabled
    public static List<getSettlements> getMySettlments(string stagenm,String searchKey, String contactId, String Str){
        List<getSettlements> wrapperList = new List<getSettlements>();
        List<Opportunity> oppList = new List<Opportunity>();
        Set<Id> oppIds = new Set<Id>();
        List<Contact> conList = new List<Contact>();
        Id conid = (id)contactId;
        boolean adminCheck;
        
        List<String> stagelist = new List<String>();
        if(stagenm == 'All'){
            stagelist.add('Approved');
            stagelist.add('Funding');
            stagelist.add('Settled (closed won)'); 
        }
        else if(stagenm == 'Approved'){
            stagelist.add('Approved');
        }
        else if(stagenm == 'Funded'){
            stagelist.add('Settled (closed won)');
        }
        else if(stagenm == 'Part Funded' || stagenm == 'Funding Requested'){
            stagelist.add('Funding');
        }
        
        Contact con = [SELECT Id, Name,Portal_View__c,Admin__c,AccountId FROM Contact WHERE Id=: conid];
        if(con.Portal_View__c == 'Admin View' && con.Admin__c){
            conList = [SELECT Id, Name, AccountId FROM Contact WHERE AccountId = : con.AccountId];
            oppList = [SELECT Id,Name,StageName,Lender_Agent__c,SyncedQuote.Product__r.Lender_Account__c,
                           SyncedQuote.Product__r.Lender_Account__r.Name FROM Opportunity WHERE
                           SyncedQuote.Product__r.Lender_Account__c =: con.AccountId AND StageName IN: stageList ORDER By CreatedDate DESC];
        }
        else{
            conList = [SELECT Id, Name,AccountId FROM Contact WHERE id =: con.Id];
            oppList = [SELECT Id,Name,StageName,Lender_Agent__c FROM Opportunity WHERE
                       Lender_Agent__c IN: conlist AND StageName IN: stageList ORDER By CreatedDate DESC];          
        }
        
        Integer My_assigned = 0;
        Integer My_Funded = 0;
        if(!oppList.isEmpty()){
            for(Opportunity op : oppList){
                oppIds.add(op.id);
                if(op.Lender_Agent__c == conId){
                    My_assigned = My_assigned + 1;
                }
                if(op.StageName == 'Settled (closed won)' && op.Lender_Agent__c == contactId){
                    My_Funded = My_Funded + 1;
                }
            }
        }
        Set<Id> newOppIds = new Set<Id>();
        Map<Id,List<Funding_Request__c>> mapOfOppandFunding = new Map<Id,List<Funding_Request__c>>();
        Integer Action_Required = 0;
        Map<Id,Date> mapOfOppandDateLastDate = new Map<Id,Date>();
        if(!oppIds.isEmpty()){
            List<Funding_Request__c> frList = [SELECT Id,CreatedDate, Request_Amount__c, Opportunity__r.StageName,Date_Last_Request_Status_Changes__c,Funding_On_Hold__c,
                                               Request_Type__c,Funding_escalation__c,Request_Status__c,Opportunity__r.FinServ__ReferredByContact__r.Referrer_Rating__c,
                                               Invoice_Amount__c,Surplus_Shortfall_Treatment__c,Funded_To_Date__c,Net_Funds_Available__c,Total_Funds_Approved_Customer_Amount__c,
                                               Net_Surplus_Shortfall__c,Net_Funds_after_Request__c,Request_Date__c,Disbursement_amount__c,Funding_Notes_to_Lender__c
                                               FROM Funding_Request__c WHERE Opportunity__c IN: oppIds ORDER By CreatedDate DESC];
            if(!frList.isEmpty()){
                for(Funding_Request__c fr : frList){
                    if(fr.Request_Status__c == 'Payment authorised by customer'){
                        Action_Required = Action_Required +1;
                    }
                    
                    //Code For Filters.
                    if(stagenm == 'Funding Requested'){
                        if(fr.Request_Status__c == 'Payment authorised by customer'){
                            newOppIds.add(fr.Opportunity__c); 
                        }
                    }
                    else if(stagenm == 'Part Funded'){
                        if(fr.Request_Type__c == 'Part payment before installation' && fr.Request_Status__c == 'Payment funded'){
                            newOppIds.add(fr.Opportunity__c); 
                        }
                    }
                    else{
                        newOppIds.addAll(OppIds);
                    }
                    
                    if(fr.Opportunity__r.StageName == 'Funding'){
                        if(!mapOfOppandDateLastDate.containsKey(fr.Opportunity__c)){
                            mapOfOppandDateLastDate.put(fr.Opportunity__c,(fr.Date_Last_Request_Status_Changes__c).Date());
                        }
                    }
                    
                    if(!mapOfOppandFunding.containsKey(fr.Opportunity__c)){
                        mapOfOppandFunding.put(fr.Opportunity__c, new list<Funding_Request__c>{fr});
                    }
                    else{
                        mapOfOppandFunding.get(fr.Opportunity__c).add(fr);
                    }
                }
            }
            else if(frList.isEmpty()){
                newOppIds.addAll(OppIds); 
            }
            List<Opportunity> newOppList = new List<Opportunity>(); 
            String query ='SELECT Id,Name,Line_Chart_JSON__c,Stagename,Applicant_2__c,Applicant_1_Name__c,Applicant_2_Name__c,Applicant_1_Email__c,Applicant_2_Email__c,Applicant_1_Phone_Number__c,Applicant_2_Phone_Number__c, CreatedDate,Lender__c, Loan_Amount__c,Status__c,';	
            query += 'Current_Application_Sections__c,Last_Stage_Change_Date__c,Total_Funds_Available__c,Lender_Agent__c,Lender_Agent__r.Name,Applicant_1__c,Applicant_1__r.Name,Application_Pending_Notes__c,';	
            query += 'Applicant_1__r.FirstName,CloseDate,Send_the_quote_to__c,Approved_Date__c,Approved_Expire_Date__c,Applicant_1__r.LastName,RecordType.Name,Applicant_1__r.PersonEmail,Applicant_1__r.Phone,SyncedQuote.Product__r.Lender_Account__c,';	
            query += 'SyncedQuote.Product__r.Lender_Account__r.Name,SyncedQuote.Customer_Amount__c,FinServ__ReferredByContact__r.Referrer_Rating__c';
            query += ' FROM Opportunity WHERE Id IN: newOppIds ';
            if ( searchKey != Null ) {	
                if ( Str != null ){	
                    String key = '%' + searchKey + '%';	
                    query += ' AND Name LIKE :key ORDER BY '+Str;	
                    newOppList = Database.query(query);	
                }	
                else{	
                    String key = '%' + searchKey + '%';	
                    query += ' AND Name LIKE :key ORDER By CreatedDate DESC';	
                    newOppList = Database.query(query);	
                }	
            }	
            else if ( Str != null ){	
                query += ' ORDER BY '+Str;	
                newOppList = Database.query(query);	
            }	
            else{	
                newOppList = [SELECT Id,Name,Line_Chart_JSON__c,Stagename,Applicant_2__c,Applicant_1_Name__c,Applicant_2_Name__c,Applicant_1_Email__c,Applicant_2_Email__c,Applicant_1_Phone_Number__c,Applicant_2_Phone_Number__c, CreatedDate,Lender__c, Loan_Amount__c,Status__c,
                              Current_Application_Sections__c,Last_Stage_Change_Date__c,Total_Funds_Available__c,Lender_Agent__c,Lender_Agent__r.Name,Applicant_1__c,Applicant_1__r.Name,Application_Pending_Notes__c,
                              Applicant_1__r.FirstName,CloseDate,Send_the_quote_to__c,Approved_Date__c,Approved_Expire_Date__c,Applicant_1__r.LastName,RecordType.Name,Applicant_1__r.PersonEmail,Applicant_1__r.Phone,SyncedQuote.Product__r.Lender_Account__c,
                              SyncedQuote.Product__r.Lender_Account__r.Name,SyncedQuote.Customer_Amount__c,FinServ__ReferredByContact__r.Referrer_Rating__c
                              FROM Opportunity WHERE Id IN: newOppIds ];	
            }	
            
            if(!newOppList.isEmpty()){
                for(Opportunity opp : newOppList){
                    getSettlements gmr = new getSettlements();
                    gmr.Opportunity = opp;
                    gmr.FrqList = mapOfOppandFunding.containsKey(Opp.Id) ? mapOfOppandFunding.get(Opp.Id) : null ;
                    gmr.ActionRequired = Action_Required;
                    gmr.MyAssigned = My_assigned;
                    gmr.MyFunded = My_Funded;  
                    if(opp.StageName == 'Funding'){
                        gmr.Updateddate = mapOfOppandDateLastDate.containsKey(Opp.Id) ? mapOfOppandDateLastDate.get(Opp.Id) : null ;
                    }
                    else if(opp.StageName == 'Approved'){
                        gmr.Updateddate = opp.Approved_Date__c != null ? (opp.Approved_Date__c).Date() : (opp.CreatedDate).Date();
                    }
                    else if(opp.StageName == 'Settled (closed won)'){
                        gmr.Updateddate = opp.CloseDate;
                    }
                    gmr.contactList = conList;
                    wrapperList.add(gmr);
                } 
            }
        }
        return wrapperList;
    }
    
    @AuraEnabled
    public static getSettlements GetOppOnExpand(String contactId, String oppId){
        getSettlements gmr = new getSettlements();
        List<Contact> conList = new List<Contact>();
        Id conid = (id)contactId;
        
        Contact con = [SELECT Id, Name,Portal_View__c,Admin__c,AccountId FROM Contact WHERE Id=: conid];
        Opportunity  opp = [SELECT Id,Name,SyncedQuoteId,Line_Chart_JSON__c,Stagename,Applicant_2__c,Applicant_1_Name__c,Applicant_2_Name__c,Applicant_1_Email__c,Applicant_2_Email__c,Applicant_1_Phone_Number__c,Applicant_2_Phone_Number__c, CreatedDate,Lender__c, Loan_Amount__c,Status__c,
                            Current_Application_Sections__c,Last_Stage_Change_Date__c,Total_Funds_Available__c,Lender_Agent__c,Lender_Agent__r.Name,Applicant_1__c,Applicant_1__r.Name,Application_Pending_Notes__c,
                            Applicant_1__r.FirstName,CloseDate,Send_the_quote_to__c,Approved_Date__c,Approved_Expire_Date__c,Applicant_1__r.LastName,RecordType.Name,Applicant_1__r.PersonEmail,Applicant_1__r.Phone,SyncedQuote.Product__r.Lender_Account__c,
                            SyncedQuote.Product__r.Lender_Account__r.Name,SyncedQuote.Customer_Amount__c,FinServ__ReferredByContact__r.Referrer_Rating__c,SyncedQuote.Product__c,SyncedQuote.Brokerage_Amount__c
                            FROM Opportunity WHERE Id =: oppId ];
        if(con.Portal_View__c == 'Admin View' && con.Admin__c){
            conList = [SELECT Id, Name, AccountId FROM Contact WHERE AccountId = : con.AccountId];
        }
        else{
            conList = [SELECT Id, Name,AccountId FROM Contact WHERE id =: con.Id];  
        }
        if(opp != null){
            List<Loan_Fees__c> ListofLoanFees = [SELECT Id,Fee_Type__c, Amount__c,Quote__c,Product__c FROM Loan_Fees__c WHERE Quote__c =: opp.SyncedQuoteId];
            List<Funding_Request__c> frList = [SELECT Id,CreatedDate, Request_Amount__c, Opportunity__r.StageName,Date_Last_Request_Status_Changes__c,
                                               Request_Type__c,Funding_escalation__c,Request_Status__c,Opportunity__r.FinServ__ReferredByContact__r.Referrer_Rating__c,
                                               Invoice_Amount__c,Surplus_Shortfall_Treatment__c,Funded_To_Date__c,Net_Funds_Available__c,Total_Funds_Approved_Customer_Amount__c,
                                               Net_Surplus_Shortfall__c,Net_Funds_after_Request__c,Request_Date__c,Disbursement_amount__c,Funding_Notes_to_Lender__c,Funding_On_Hold__c
                                               FROM Funding_Request__c WHERE Opportunity__c=: opp.Id ORDER By CreatedDate DESC];
            Map<Id,List<Funding_Request__c>> mapOfOppandFunding = new Map<Id,List<Funding_Request__c>>();
            Map<Id,Date> mapOfOppandDateLastDate = new Map<Id,Date>();
            if(!frList.isEmpty()){
                for(Funding_Request__c fr : frList){
                    if(fr.Opportunity__r.StageName == 'Funding'){
                        if(!mapOfOppandDateLastDate.containsKey(fr.Opportunity__c)){
                            mapOfOppandDateLastDate.put(fr.Opportunity__c,(fr.Date_Last_Request_Status_Changes__c).Date());
                            break;
                        }
                    }
                }
                mapOfOppandFunding.put(opp.Id,frList);
            }
            gmr.Opportunity = opp;
            gmr.FrqList = mapOfOppandFunding.containsKey(opp.Id) ? mapOfOppandFunding.get(opp.Id) : null ;  
            if(opp.StageName == 'Funding'){
                gmr.Updateddate = mapOfOppandDateLastDate.containsKey(opp.Id) ? mapOfOppandDateLastDate.get(opp.Id) : null ;
            }
            else if(opp.StageName == 'Approved'){
                gmr.Updateddate = opp.Approved_Date__c != null ? (opp.Approved_Date__c).Date() : (opp.CreatedDate).Date();
            }
            else if(opp.StageName == 'Settled (closed won)'){
                gmr.Updateddate = opp.CloseDate;
            }
            gmr.contactList = conList;
            gmr.loanFeeList = ListofLoanFees;
        }
        
        return gmr;
    }
    
    @AuraEnabled
    public static List<ContentVersion> getDocs(String oppId){
        system.debug('oppId'+oppId);
        Id recordId = (Id)oppId;
        Opportunity opp;
        List<String> categoryList = new List<String>{'Purchase Invoice','Identification','Direct Debit Form','Lender Membership','Funding Authorisation Certificate'};
        List<ContentDocumentLink> cntList = new List<ContentDocumentLink>();
        if(oppId != null){
            cntList = [SELECT ContentDocument.LatestPublishedVersionId, LinkedEntityId, ContentDocumentId
                       FROM ContentDocumentLink WHERE LinkedEntityId =: oppId];
        }
        Set<Id> cntVersionIds = new Set<Id>();
        List<ContentVersion> cvListToReturn = new List<ContentVersion>();
        system.debug('cntList'+cntList);
        if(!cntList.isEmpty()){
            for(ContentDocumentLink cnt: cntList){            
                cntVersionIds.add(cnt.ContentDocumentId );
            }
            system.debug('cntVersionIds'+cntVersionIds);
            if(!cntVersionIds.isEmpty()){
                List<ContentVersion> cvList  = [SELECT Id,related__c, Category__c,Current_in_use__c, Title, FileExtension, Description, ContentModifiedDate, CreatedDate, ContentSize, ContentDocumentId 
                           FROM ContentVersion WHERE ContentDocumentId IN :cntVersionIds AND Category__c IN: categoryList];
                system.debug('cvList'+cvList);
                if(!cvList.isEmpty()){
                    for(ContentVersion cv : cvList){
                        if(cv.Category__c == 'Purchase Invoice'){
                            if(cv.Current_in_use__c == true){
                                cvListToReturn.add(cv);
                            }
                        }
                        else{
                            cvListToReturn.add(cv);
                        }
                    }
                }
            }
        }
        return cvListToReturn;
    }
    
    @AuraEnabled
    public static Contact LenderAgentAssign(string conId,String OppId){
        Contact con;
        Opportunity  opp = [SELECT Id,Lender_Agent__c FROM Opportunity WHERE Id =: OppId];
        opp.Lender_Agent__c = conId;
        
        Update opp;
        if(conId != null){
            con = [SELECT Id,Name,AccountId FROM Contact WHERE Id =: conId];
        }
        system.debug('con'+con);
        return con; 
        
    }
    
    @AuraEnabled
    public static void  ReassignAgent(string SelectedCon,String AgentCon){
        
        list<Opportunity>  oppList = [SELECT Id,Lender_Agent__c FROM Opportunity WHERE Lender_Agent__c =: AgentCon];
        list<Opportunity>  oppListToUpdate = new list<Opportunity>();
        if(!oppList.isEmpty()){
            for(Opportunity opp : oppList){
                opp.Lender_Agent__c = SelectedCon;
                oppListToUpdate.add(opp);
            }
        }
        if(!oppListToUpdate.isEmpty()){
            Update oppListToUpdate;
        }   
    }
    
    @AuraEnabled
    public static getFundingWrapper  updateFundingByLender(String frId,Decimal amtFunded,String paidTo,String lender_conId){
        getFundingWrapper gfo = new getFundingWrapper();
        if(frId != null){
            Funding_Request__c fr = [SELECT Id,Amount_Funded__c,Paid_To__c,Submitted_By_Lender__c,Request_Status__c,
                                     Request_Type__c,Opportunity__c FROM Funding_Request__c WHERE Id =: frId];
            Opportunity  opp = [SELECT Id,Name,Line_Chart_JSON__c,Stagename,Applicant_2__c,Applicant_1_Name__c,Applicant_2_Name__c,Applicant_1_Email__c,Applicant_2_Email__c,Applicant_1_Phone_Number__c,Applicant_2_Phone_Number__c, CreatedDate,Lender__c, Loan_Amount__c,Status__c,
                                Current_Application_Sections__c,Last_Stage_Change_Date__c,Total_Funds_Available__c,Lender_Agent__c,Lender_Agent__r.Name,Applicant_1__c,Applicant_1__r.Name,Application_Pending_Notes__c,
                                Applicant_1__r.FirstName,CloseDate,Send_the_quote_to__c,Approved_Date__c,Approved_Expire_Date__c,Applicant_1__r.LastName,RecordType.Name,Applicant_1__r.PersonEmail,Applicant_1__r.Phone,SyncedQuote.Product__r.Lender_Account__c,
                                SyncedQuote.Product__r.Lender_Account__r.Name,SyncedQuote.Customer_Amount__c,FinServ__ReferredByContact__r.Referrer_Rating__c,Confirm_Settlement_Date__c
                                FROM Opportunity WHERE Id =: fr.Opportunity__c];
            fr.Amount_Funded__c =  amtFunded;
            fr.Paid_To__c = paidTo;  
            fr.Submitted_By_Lender__c = lender_conId; 
            fr.Request_Status__c = 'Payment funded';
            Update fr;
            
            opp.Lender_Agent__c = null;
            if(fr.Request_Type__c != 'Part payment before installation'){
                opp.StageName = 'Settled (closed won)';
                opp.Confirm_Settlement_Date__c = true;
            }
            Update opp;
            
            gfo.opp = opp;
            gfo.frq = fr;
        }
        return gfo;
    }
    
    @AuraEnabled
    public static List<Funding_Request__c> getPreviousFundingData(String oppId){
        return MyReferrerController.getPreviousFundingRequests(oppId);  
    }
    
    public class getFundingWrapper{
        @AuraEnabled public Opportunity opp;
        @AuraEnabled public Funding_Request__c frq;
    }
    
    public class getMyTeamWrapper{
        @AuraEnabled public contact ReferrerContact;
        @AuraEnabled public Double rndNum;
        @AuraEnabled public Integer TotalAssigned;
        @AuraEnabled public Integer TotalFunded;
        @AuraEnabled public String Role;
        @AuraEnabled public String AdministratorCheck;
        @AuraEnabled public List<Contact> contactList;
    }
    
    public class getOppWrapper{
        @AuraEnabled public Integer fundingApproved;
        @AuraEnabled public Integer fundingDisbursement;
        @AuraEnabled public Integer fundingpartfunded;
        @AuraEnabled public Decimal fundingtotalfunded;
        @AuraEnabled public Boolean checkAdmin;
        @AuraEnabled public Opportunity getOpp;
        @AuraEnabled public list<Funding_Request__c> getFundList;
        @AuraEnabled public Integer Oldrecords;      
    }
    
    public class getRecentActWrapper{
        @AuraEnabled public String status;
    }
    
    public class getSettlements{
        @AuraEnabled public Opportunity Opportunity;
        @AuraEnabled public List<Funding_Request__c> FrqList;
        @AuraEnabled public Integer ActionRequired;
        @AuraEnabled public Integer MyAssigned;
        @AuraEnabled public Integer MyFunded;
        @AuraEnabled public Date Updateddate;
        @AuraEnabled public List<Contact> contactList;
        @AuraEnabled public List<Loan_Fees__c> loanFeeList;
    }
}