public without sharing class ReferrerPortalController {
    
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
            UtilityClass.createException(con.Id,'ReferrerPortalController', 'updateViewofPortal', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
        }
    }
    
    @auraEnabled
    public static Integer emailForOtp(String mailId, String recId){
        try{
            Double randomNum = Math.floor(1000 + Math.random() * 9000);
            Integer num = Math.round(randomNum);
            contact getContact = [Select id,Session_Start_Time__c,Email,LoginOtp__c,Count__c, Phone, PhoneForPortal__c from contact where id =: recId LIMIT 1];
            getContact.LoginOtp__c = String.valueOf(num);
            update getContact;
            /*OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address =:UtilityClass.adminEmail];
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
            }*/
            return num;
        }catch(exception e){
            UtilityClass.createException(recId,'ReferrerPortalController', 'emailForOtp', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }    
    
    // @auraEnabled
    // public static getConWrapper SendMessage(String getPhone, String recId){
    //     try{
    //         list<Contact> conList;
    //         list<Account> accList;
    //         if(getPhone != null){
    //             conList=[SELECT Id, Name, Status__c, Email, AccountId, Phone, On_Board_Individual__c, PhoneForPortal__c FROM Contact where PhoneForPortal__c =: getPhone and RecordType.Name = 'Referrer' and Status__c = 'Active'];
    //             if(conList != Null && conList.size() > 0){
    //                 accList=[Select id, On_Board_Referral__c from account where id =: conList[0].AccountId limit 1];
    //             }
    //         }
    //         if(conList != Null && conList.size() == 1 && !String.isBlank(recId) && recId != conList[0].Id){
    //             return null;
    //         }
    //         if(conList != Null && conList.size() == 1 && (accList[0].On_Board_Referral__c == true || conList[0].On_Board_Individual__c == true) && conList[0].Status__c == 'Active'){
    //             List<smagicinteract__smsMagic__c> smsObjectList = new List<smagicinteract__smsMagic__c> ();
    //             Double randomNum = Math.floor(1000 + Math.random() * 9000);
    //             Integer num = Math.round(randomNum);
    //             //String senderId = 'Parkerlane'; // Please replace the 'smsMagic' with your relevant sender ID.
    //             String templateText = 'Your 4-digit verification code is ' + num; // you can fetch the template text by querying the record on smagicinteract__SMS_Template__c object 
    //             smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
    //             smsObject.smagicinteract__SenderId__c = 'parkerlane';
    //             smsObject.smagicinteract__PhoneNumber__c = getPhone;//'61400247471';//contact.MobilePhone;
    //             smsObject.smagicinteract__Name__c = conList[0].Name;//contact.Name; // recordsname
    //             smsObject.smagicinteract__ObjectType__c = 'Contact';//'Contact'; // record type
    //             smsObject.smagicinteract__disableSMSOnTrigger__c = 0; // this field either be 0 or 1, if you specify the value as 1 then sms will not get send but entry of sms will get create under SMS History object
    //             smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
    //             smsObject.smagicinteract__SMSText__c = templateText;
    //             smsObject.smagicinteract__Contact__c = conList[0].Id;
    //             smsObjectList.add(smsObject);
    //             Database.SaveResult[] results = Database.insert(smsObjectList, false);
    //             // iterate over the list of returned results
    //             for(Database.SaveResult result : results) {
    //                 if(result.isSuccess()) {
    //                     //  System.debug('Successfully inserted Accounts : ' + result.getId());
    //                 } else {
    //                     // iterate over the failed ones
    //                     for(Database.Error error : result.getErrors()) {
    //                         System.debug('Error Status : ' + error.getMessage() + ' : ' + 'Error Fields : ' + error.getFields());
    //                     }
    //                 }
    //             }    
    //             getConWrapper gcw = new getConWrapper();
    //             gcw.rndNum = randomNum;
    //             gcw.conData = conList[0];
    //             gcw.listSize = false;
    //             return gcw;
    //         }
    //         else if(conList != Null && conList.size() > 1){
    //             getConWrapper gcw = new getConWrapper();
    //             gcw.listSize = true;
    //             return gcw;
    //         }
    //         return null;
    //     }catch(exception e){
    //         UtilityClass.createException(recId,'ReferrerPortalController', 'SendMessage', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
    //                                      e.getTypeName(), ''+e.getCause());
    //         return null;
    //     }
    // }
    
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
            UtilityClass.createException(conId,'ReferrerPortalController', 'otpMatched', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
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
            
            Map<id, decimal> MapOfApprovedLoanAmount = new Map<id, decimal>();
            Map<id, decimal> MapOfClosedLoanAmount = new Map<id, decimal>();
            Decimal TotalLoanAmount_Approved = 0;
            Decimal TotalLoanAmount_Settled =0;
            map<id,list<opportunity>> map1=new map<id,list<opportunity>>();
            list<Opportunity> opplist =[select id,name,stagename,Total_Loan_amount__c,ReferredByContact__c from opportunity where ReferredByContact__c IN: conlist ];
            for(opportunity opp : opplist){
                if(!map1.containskey(opp.ReferredByContact__c)){
                    map1.put(opp.ReferredByContact__c, new List<opportunity>{opp});
                }
                else{
                    map1.get(opp.ReferredByContact__c).add(opp);
                }
                if(opp.stagename =='Approved' || Opp.stagename =='Funding'){
                    if(!MapOfApprovedLoanAmount.containsKey(opp.ReferredByContact__c)){
                        MapOfApprovedLoanAmount.put(opp.ReferredByContact__c, opp.Total_Loan_amount__c); 
                    }
                    else{
                        Decimal dc = MapOfApprovedLoanAmount.get(opp.ReferredByContact__c);
                        dc += opp.Total_Loan_amount__c;
                        MapOfApprovedLoanAmount.put(opp.ReferredByContact__c, dc);
                    }
                }    
                
                if(opp.stagename =='Settled (closed won)'){
                    if(!MapOfClosedLoanAmount.containsKey(opp.ReferredByContact__c)){
                        MapOfClosedLoanAmount.put(opp.ReferredByContact__c, opp.Total_Loan_amount__c); 
                    }
                    else{
                        Decimal dc = MapOfClosedLoanAmount.get(opp.ReferredByContact__c);
                        dc += opp.Total_Loan_amount__c;
                        MapOfClosedLoanAmount.put(opp.ReferredByContact__c, dc);
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
                    role='Referrer';
                    AdministratorCheck = 'No';
                }
                GMT.AdministratorCheck = AdministratorCheck;
                GMT.Role=role;
                GMT.ReferrerContact = con;
                GMT.TotalReferrals = (map1.get(con.Id)!=null ? map1.get(con.Id).size() : 0);
                GMT.TotalLoanAmount_Approved= (MapOfApprovedLoanAmount.get(con.id) !=null ? MapOfApprovedLoanAmount.get(con.id) : 0);
                GMT.TotalLoanAmount_Settled= (MapOfClosedLoanAmount.get(con.id) !=null ? MapOfClosedLoanAmount.get(con.id) : 0);
                GMTlist.add(GMT);
            }
            
            return GMTlist;
        }catch(exception e){
            UtilityClass.createException(conId,'ReferrerPortalController', 'getMyTeam', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
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
            UtilityClass.createException(con.Id,'ReferrerPortalController', 'SaveContactOnMyTeamCard', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @AuraEnabled
    public static void createContact(list<contact>  contactlist,String conId){
        try{
            contact con2 = [select id,Name,AccountId from contact where id=: conId LIMIT 1];
            list<Contact> listofCon = new list<Contact>();
            listofCon = contactlist;
            for(integer i=0;i<listofCon.size();i++){
                listofCon[i].recordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Referrer').getRecordTypeId();
                listofCon[i].accountId= con2.AccountId;
            }
            if(listofCon.size()>0){
                insert listofCon;
            }
        }catch(exception e){
            UtilityClass.createException(conId,'ReferrerPortalController', 'createContact', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
        }    
    }
    
    @AuraEnabled
    public static Contact getMyAccount(String conId){
        try{
            Contact con=[SELECT Id, Name,MobilePhone,Email,State__c,Account.Name,Referrer_Rating__c,Admin__c,
                         Declaration__c,Declaration_Signed_DateTime__c FROM Contact WHERE Id=: conId LIMIT 1];
            return con;
        }catch(exception e){
            UtilityClass.createException(conId,'ReferrerPortalController', 'getMyAccount', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @AuraEnabled 
    public static Datetime updatedeclarationOnMyAccount(String conId, boolean dec, String base64Data){
        try{
            Datetime cr =system.now();
            Contact con = [SELECT Id,FirstName,AccountId,Name,Email,Declaration__c,On_Board_Individual__c FROM Contact WHERE Id=: conId];
            con.Declaration__c = dec;
            con.Declaration_Signed_DateTime__c = cr;
            con.On_Board_Individual__c = true;
            update con;
            //insert signature
            base64Data = base64Data.substring(base64Data.indexOf(',')+1,base64Data.length());
            ContentVersion ContVerFile = new ContentVersion();
            ContVerFile.VersionData = EncodingUtil.base64Decode(base64Data);
            ContVerFile.Title = 'Sign'; 
            ContVerFile.PathOnClient='Sign.png';
            insert ContVerFile;
            
            List<ContentVersion> conDocId = new List<ContentVersion>();            
            conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :ContVerFile.Id];
            
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = con.Id;            
            cdl.ContentDocumentId = conDocId[0].ContentDocumentId;            
            cdl.shareType = 'V';
            cdl.Visibility = 'AllUsers';
            Insert cdl;            
            return cr;
        }catch(exception e){
            UtilityClass.createException(conId,'ReferrerPortalController', 'updatedeclarationOnMyAccount', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @auraEnabled
    public static void insertPdf(String conId){
        Contact con = [SELECT Id,FirstName,AccountId,Name,Email,Declaration__c,On_Board_Individual__c FROM Contact WHERE Id=: conId];
        PageReference pdf = Page.Referral_Agreement_PDF;
        pdf.getParameters().put('id',con.AccountId);
        pdf.getParameters().put('ConId',con.Id);
        pdf.setRedirect(true);
        Blob bPDF;
        
        if (Test.IsRunningTest())
        {
            bPDF=Blob.valueOf('UNIT.TEST');
        }
        else
        {
            bPDF = pdf.getContent();
        }
        
        ContentVersion ContVerFile = new ContentVersion();
        ContVerFile.VersionData = bPDF;
        ContVerFile.Title = 'Signed Referral Agreement'; 
        ContVerFile.PathOnClient='Signed Referral Agreement.Pdf';
        insert ContVerFile;
        List<ContentVersion> conDocId = new List<ContentVersion>();
        
        conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :ContVerFile.Id];
        
        ContentDocumentLink cdl = New ContentDocumentLink();        
        cdl.LinkedEntityId = con.Id;        
        cdl.ContentDocumentId = conDocId[0].ContentDocumentId;        
        cdl.shareType = 'V';
        
        Insert cdl; 
        sendWelcomeMail(conId,cdl.ContentDocumentId);
    }
        
    @future @auraEnabled
    public static void sendWelcomeMail(String conId, id docId){
        try{
            Contact con = [SELECT Id,FirstName,AccountId,Name,Email,Declaration__c,On_Board_Individual__c FROM Contact WHERE Id=: conId];
            OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address =:UtilityClass.adminEmail];
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            Blob b;
            List<ContentVersion> conVerList = [SELECT Id, Title,VersionData FROM ContentVersion WHERE ContentDocumentId = : docId];
            b = conVerList[0].VersionData;
            
            /*Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName('Signed Referral Agreement.pdf');
            efa.setContentType('application/pdf');
            efa.setBody(b);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            List<string> sendTo = new List<string>();
            if(con.Email != Null){
                sendTo.add(con.Email);
            }
            mail.setToAddresses(sendTo);
            if(owea.size() > 0){
                mail.setorgWideEmailAddressId(Owea.get(0).Id);
            }
            mail.setUseSignature(false);
            mail.setTargetObjectId(con.Id);
            mail.setSaveAsActivity(false);
            mail.setTreatTargetObjectAsRecipient(false);
            EmailTemplate et=[Select id, Subject, Body from EmailTemplate where DeveloperName = 'Welcome_For_Referrer']; 
            mail.setTemplateId(et.id);
            mails.add(mail);
            if(mails.size() > 0 && mails != null){
                Messaging.sendEmail(mails);   
            }*/
        }catch(exception e){
            UtilityClass.createException(conId,'ReferrerPortalController', 'sendWelcomeMail', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
        }
    }
    
    @AuraEnabled
    public static List<Account> accountDetails(String getAcc){
        try{
            List<Account> accList = [SELECT Id, Name, Phone, On_Board_Referral__c FROM Account where id =: getAcc];
            //  system.debug(accList);
            return accList;
        }catch(exception e){
            UtilityClass.createException(getAcc,'ReferrerPortalController', 'accountDetails', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @AuraEnabled
    public static id getAccountId(String getPhone){
        try{
            Account accId = [SELECT Id FROM Account where Phone =: getPhone limit 1];
            system.debug(accId);
            return accId.id;
        }catch(exception e){
            UtilityClass.createException('','ReferrerPortalController', 'getAccountId', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
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
            UtilityClass.createException(contactId,'ReferrerPortalController', 'getContact', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @auraEnabled
    public static list<Opportunity> getSearchData(String contactId, String searchKey){
        try{
            Contact Con = [SELECT Id,AccountId,Admin__c,Portal_View__c FROM Contact WHERE Id=:contactId LIMIT 1];
            Id AccountId = Con.AccountId;
            List<Opportunity> oppList = new List<Opportunity>();
            
            if ( searchKey != Null ) {
                String query ='SELECT id,Name FROM Opportunity WHERE (ReferredByContact__c =: contactId';
                if(con.Admin__c == true && con.Portal_View__c == 'Admin View' && AccountId != null){
                    query += ' OR Referred_by_Company__c=: AccountId';   
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
            UtilityClass.createException(contactId,'ReferrerPortalController', 'getSearchData', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @AuraEnabled
    public static getOppWrapper getOpp(String contactId){
        try{
            System.debug('==_+__'+contactId);
            id conid = (id)contactId;
            contact con = [SELECT Id, Name,Portal_View__c,Admin__c,AccountId FROM Contact WHERE Id=: conid];
            List<Contact> conList = new List<Contact>();
            boolean adminCheck;
            if(con.Portal_View__c == 'Admin View' && con.Admin__c){
                conList = [SELECT Id, Name, AccountId FROM Contact WHERE AccountId = : con.AccountId];
            }
            else{
                conList = [SELECT Id, Name,AccountId FROM Contact WHERE id =: con.Id];
            }
            System.debug('tazeems Debug____'+conList);
            list<Opportunity> oppList = [SELECT id,Name,LastModifiedDate,Line_Chart_JSON__c,Stagename,Applicant_1_Name__c,Applicant_2_Name__c,Applicant_1_Email__c,Applicant_1_Phone_Number__c, CreatedDate,Lender__c, Loan_Amount__c,Status__c,
                                         Current_Application_Sections__c,Last_Stage_Change_Date__c,Total_Funds_Available__c,ReferredByContact__r.Name,ReferredByContact__c,Applicant_1__c,Applicant_1__r.Name,Application_Pending_Notes__c,
                                         Applicant_1__r.FirstName,Send_the_quote_to__c,Approved_Date__c,Applicant_1__r.LastName,RecordType.Name,Applicant_1__r.PersonEmail,Applicant_1__r.Phone
                                         FROM Opportunity WHERE ReferredByContact__c IN : conList ORDER BY CreatedDate DESC];
            decimal totalAmt = 0; 
            decimal totalApprovedAmt = 0;
            integer count = 0;
            integer totalOpp = 0;
            list<getOppWrapper> refList = new List<getOppWrapper>();
            List<String> stageList = New List<String>{'CPA Started','CPA Done','Packs Out','Packs Back','CPA Done','Application','Submitted','Conditionally Approved'};
                for(opportunity op : oppList){
                    if(op.Stagename == 'Settled (closed won)'){
                        totalAmt+= (op.Loan_Amount__c != null ? op.Loan_Amount__c : 0);
                    } 
                    if((op.Stagename == 'Approved' || op.Stagename == 'Funding') && (op.Approved_Date__c != null ? op.Approved_Date__c.Date().daysBetween(system.today()) < 91 : false)){
                        totalApprovedAmt+= (op.Loan_Amount__c != null ? op.Loan_Amount__c : 0);
                    }
                    if(stageList.contains( op.Stagename)){
                        count+= 1;
                    }
                    if(op.CreatedDate > system.today().addDays(-30)){
                        totalOpp+= 1;
                    }
                }
            List<opportunity> opl = new List<opportunity>();
            if(!oppList.isEmpty()){
                for(integer i=0; i<oppList.size(); i++){                
                    if(i == 31){
                        break;
                    }
                    else{
                        system.debug('oppList[i]'+oppList[i]);
                        if(oppList[i] != null){ 
                            opl.add(oppList[i]);
                        }
                    }
                }
            }
            
            getOppWrapper obj = new getOppWrapper();
            obj.fundedToDate = totalAmt;
            obj.approvedLoans = totalApprovedAmt;
            obj.applicationsUnderWay = count;
            obj.checkAdmin = con.Admin__c;
            obj.Quotes = totalOpp;
            obj.getOppList = opl;
            obj.Oldrecords = oppList.size();
            
            System.debug('wrapper+++++'+obj);
            
            return obj;
        }catch(exception e){
            UtilityClass.createException(contactId,'ReferrerPortalController', 'getOpp', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @AuraEnabled
    public static getOppWrapper getOppOnScrollForRecent(String contactId, List<Opportunity> oldoppList){
        try{
            id conid = (id)contactId;
            contact con = [SELECT Id, Name,Portal_View__c,Admin__c,AccountId FROM Contact WHERE Id=: conid];
            List<Contact> conList = new List<Contact>();
            boolean adminCheck;
            if(con.Portal_View__c == 'Admin View' && con.Admin__c){
                conList = [SELECT Id, Name, AccountId FROM Contact WHERE AccountId = : con.AccountId];
            }
            else{
                conList = [SELECT Id, Name,AccountId FROM Contact WHERE id =: con.Id];
            }
            System.debug('tazeems Debug____'+conList);
            list<Opportunity> oppList = [SELECT id,Name,Line_Chart_JSON__c,Stagename,Applicant_1_Name__c,Applicant_2_Name__c,Applicant_1_Email__c,Applicant_1_Phone_Number__c, CreatedDate,Lender__c, Loan_Amount__c,Status__c,
                                         Current_Application_Sections__c,Last_Stage_Change_Date__c,Total_Funds_Available__c,ReferredByContact__r.Name,ReferredByContact__c,Applicant_1__c,Applicant_1__r.Name,Application_Pending_Notes__c,
                                         Applicant_1__r.FirstName,Send_the_quote_to__c,Approved_Date__c,Applicant_1__r.LastName,RecordType.Name,Applicant_1__r.PersonEmail,Applicant_1__r.Phone
                                         FROM Opportunity WHERE ReferredByContact__c IN : conList AND Id Not IN: oldoppList ORDER BY CreatedDate DESC];
            
            List<opportunity> opl = new List<opportunity>();
            if(!oppList.isEmpty()){
                for(integer i=0; i<oppList.size(); i++){                
                    if(i == 31){
                        break;
                    }
                    else{
                        system.debug('oppList[i]'+oppList[i]);
                        if(oppList[i] != null){ 
                            opl.add(oppList[i]);
                        }
                    }
                }
            }
            
            getOppWrapper obj = new getOppWrapper();
            obj.getOppList = opl;
            
            System.debug('wrapper+++++'+obj);
            
            return obj;
        }catch(exception e){
            UtilityClass.createException(contactId,'ReferrerPortalController', 'getOppOnScrollForRecent', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }
    }
    
    @AuraEnabled
    public static void UpdateConLoginLogs(String contactId, String loginMethod){
        try{
            Contact con = [SELECT Id,AccountId FROM Contact WHERE Id=: contactId];
            Referrer_Portal_Logs__c log = new Referrer_Portal_Logs__c();
            log.Log_in_Time__c = system.now();
            log.Type_of_login__c = loginMethod;
            log.Referrer_Name__c = con.Id;
            log.Referrer_Account__c = con.AccountId;
            insert log;
        }catch(exception e){
            UtilityClass.createException(contactId,'ReferrerPortalController', 'UpdateConLoginLogs', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
        }
    }
    
    
    public class getMyTeamWrapper{
        @AuraEnabled public contact ReferrerContact;
        @AuraEnabled public Integer TotalReferrals;
        @AuraEnabled public Decimal TotalLoanAmount_Approved;
        @AuraEnabled public Decimal TotalLoanAmount_Settled;
        @AuraEnabled public String Role;
        @AuraEnabled public String AdministratorCheck;
    }
    
    public class getOppWrapper{
        @AuraEnabled public Decimal fundedToDate;
        @AuraEnabled public Decimal approvedLoans;
        @AuraEnabled public Integer applicationsUnderWay;
        @AuraEnabled public Integer Quotes;
        @AuraEnabled public Boolean checkAdmin;
        @AuraEnabled public list<Opportunity> getOppList;
        @AuraEnabled public Integer Oldrecords;
    }
    
    public class getConWrapper{
        @AuraEnabled public Double rndNum;
        @AuraEnabled public Contact conData;
        @AuraEnabled public decimal count;
        @AuraEnabled public boolean listSize;
    }
    
}