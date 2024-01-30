global without sharing class newVOIController {
    
    public string accessToken {get;set;}
    public static opportunity oppData {get;set;}
    public static contact contct {get;set;}
    public static VOI_Status__c voiS {get; set;}
    public static string formatedMobile{get; set;}
    public static string formatedEmail{get; set;}
    public static string SecureCodeOriginal{get; set;}
    
    public newVOIController(){           
        string conId = ApexPages.currentPage() != null ? ApexPages.currentPage().getParameters().get('conId') : '';
        string oppId = ApexPages.currentPage() != null ? ApexPages.currentPage().getParameters().get('oppId') : '';
        oppData = new opportunity();
        sessionIdclass obj = new sessionIdclass(); // important for session maintenance
        obj.ReturnAccessToken();
        accessToken = obj.accessToken;
        system.debug('---00000000----'+accessToken);
        oppData = [Select id,Applicant_2__r.personContactId,SyncedQuote.Gruop_Name__c,SyncedQuote.Quote_Group_Label__c,name, Lender__c from opportunity where id =: oppId LIMIT 1];
        contct = [Select id, is_emal_sent_for_VOI__c,name,Current_VOI_stage__c,voi_Email_Verification_Code__c,is_Email_verified_for_VOI__c,Email,Phone,Number_of_applicants_to_operate_account__c, VOI_type__c from contact WHERE id = : conId limit 1];                
        
        VOI_Status__c temp = [select Id,VOI_URL__c,VOI_Detail__r.id, Current_VOI_section__c,opportunity__r.Applicant_2__c,opportunity__r.Applicant_2__r.personContactId, Contact__r.id, name,VOI_Detail__c,VOI_stage__c ,VOI_Type_For__c,link_Expire_code__c, contact__c from VOI_Status__c WHERE contact__r.Id =: conId order by createddate DESC LIMIT 1];
        voiS = temp;                
        
        for(VOI_Detail__c voideta : [SELECT Id, Name,Secure_Code_Orignal__c, Contact__r.Id from VOI_Detail__c WHERE Id =: temp.VOI_Detail__r.id order by createddate DESC LIMIT 1]){
            if(!string.isBlank(voideta.Secure_Code_Orignal__c)){
                SecureCodeOriginal = voideta.Secure_Code_Orignal__c;    
            }
            else{
                SecureCodeOriginal = 'We are facing some issue, Please contact to Admin!!';
            }                 
            break;
        } 
        
       
        contact con = [Select id, name,Current_VOI_stage__c,Email,Phone,Number_of_applicants_to_operate_account__c, VOI_type__c from contact WHERE id = : conId limit 1];
        
        String mobileNumber = con.Phone; 
        string email = con.Email;
        
        if (mobileNumber.length() >= 3) {
            formatedMobile = 'Send SMS to mobile ending in '+mobileNumber.substring(mobileNumber.length() - 3);
            System.debug(formatedMobile);              
        }                
        
        list<string> eml = email.split('@');
        
        system.debug('--'+eml);
        string a = '';
        string b = '';
        if(eml[0].length() == 1){
            a = eml[0] + '...';
            b = eml[1];
        }
        else if(eml[0].length() == 2){
           	a = eml[0].substring(0, 1) + '.';
            b = eml[1];
        }
        else if(eml[0].length() == 3){
            a = eml[0].substring(0, 1) + '..';
            b = eml[1];
        }else{
            a = eml[0].substring(0, 3) + '...';
            b = eml[1];   
        }                
        
        string output = a+'@'+b;
        formatedEmail = 'Send an email to '+output;
        
        
    }
    
    @AuraEnabled
    public static contact sendEmailAndSMSForCode(contact con){
        if(!con.is_emal_sent_for_VOI__c){
            contact cont = emailForOtp(con.Id);                       
            return cont;
        } else{
            return null;
        }      
    }
    
    
    
    @AuraEnabled
    public static string updateContFromLWC(string conId,string oppId, string numberTosign, string TaxResi, string accountNm, string financial_Inst, string bSBN, string accountNum){
        try{           
            Contact con = [SELECT Name, Medicare_Reference__c,Number_of_applicants_to_operate_account__c,Tax_Resident_of_countries__c,Tax_File_Number_TFN__c,Tax_Identification_Number_TIN__c, FirstName,AccountId, LastName,Govt_Id_Number__c, MiddleName,Does_your_spouse_earn_an_income__c,spouse_s_approximate_annual_income__c, Email, Phone, Title, Birthdate,FinServ__Occupation__c,Account.Industry,Primary_Employer_Job_Title__c, 
                           OtherPhone, FinServ__Gender__c,Rental_or_Board_paid__c, FinServ__MaritalStatus__c, Government_ID__c,
                           Rental_Amount__c, Rental_Frequency__c, Rental_Managed_via__c, Citizenship_Status__c, Visa_Details__c,
                           Driver_s_licence_state_Territory__c,First_Name_Child_1__c, Residential_Address__c,First_Name_Child_2__c, First_Name_Child_3__c, First_Name_Child_4__c, First_Name_Child_5__c,
                           Age_Child_1__c, Age_Child_2__c, Age_Child_3__c, Age_Child_4__c, Age_Child_5__c,Medicare_Card_Colour__c,
                           Medicare_Expiry_Date__c,Medicare_Number__c,Monthly_Rental_Payments__c,Other_Regular_Expenditure__c
                           FROM Contact WHERE Id =: ConId];
            
            opportunity opp = [SELECT Id,Name,Name_s_on_account__c,Financial_Institution__c,BSB_number__c,Account_number__c FROM Opportunity WHERE Id=: oppId LIMIT 1];
            if(opp != null){
                opp.Name_s_on_account__c =  (string.isBlank(accountNm) ? opp.Name_s_on_account__c : accountNm); 
                opp.Financial_Institution__c = (string.isBlank(financial_Inst) ? opp.Financial_Institution__c : financial_Inst);
                opp.BSB_number__c = (string.isBlank(bSBN) ? opp.BSB_number__c : bSBN);
                opp.Account_number__c = (string.isBlank(accountNum) ? opp.Account_number__c : accountNum);
                update opp;
            } 
            
            
            Contact cont = new Contact();
            cont.Id = con.Id;
            if(numberTosign == 'either to sign' || numberTosign == 'both to sign'){
                cont.Number_of_applicants_to_operate_account__c = numberTosign;    
            }else{
                System.debug('null value in numberTosign'+numberTosign);
            }
            cont.Tax_Resident_of_countries__c = TaxResi;
            system.debug('Conttttt'+cont);
            update cont;
            
            System.debug('cont++'+cont.id);
            return 'success';
        }catch(Exception ex){
            UtilityClass.createException('','newVOIController', 'updateContFromLWC', ex.getMessage(), ex.getStackTraceString(), ''+ex.getLineNumber(),
                                         ex.getTypeName(), ''+ex.getCause());
            return 'please contact to admin';
        }
    }       
	
    public class dataWrap{
        @AuraEnabled
        public opportunity opp;
        @AuraEnabled
        public contact con;
        @AuraEnabled
        public VOI_Status__c voiSt;
        @AuraEnabled
        public VOI_Detail__c voiDt;
        @AuraEnabled
        public Quote Qt;
        @AuraEnabled
        public FinServ__Employment__c emp1;
        @AuraEnabled
        public FinServ__Employment__c emp2;
        
    }

 	@AuraEnabled
    public static dataWrap dataWrapmethod(string oppId, string conId){
        system.debug('--=-'+oppId);
        opportunity opprt = getOpportunityData(oppId);
        VOI_Status__c VST = getVOI(ConId);
        system.debug('--=-'+opprt);
        dataWrap obj = new dataWrap();
        obj.opp = opprt;
        obj.con = getContactData(conId);
        obj.voiSt = VST;
        obj.voiDt = getVOIDetail(VST);
        obj.Qt = getQUoteData(oppId);        
       	obj.emp1 = Employementdata(opprt.Applicant_1__r.personContactId);
        if(opprt.Applicant_2__c != null){
        	obj.emp2 = Employementdata(opprt.Applicant_2__r.personContactId);    
        }
        else{
            obj.emp2 = null;
        }
        return obj;
    }

    public static VOI_Detail__c getVOIDetail(VOI_Status__c vs){
        VOI_Detail__c voidt = new VOI_Detail__c();
        for(VOI_Detail__c vd : [select id,Secure_Code_Orignal__c, name from VOI_Detail__c where id = : vs.VOI_Detail__r.id limit 1]){            
            voidt = vd;            
        }
        return voidt;
    }

    public static FinServ__Employment__c Employementdata(string dataId){
        try{
            system.debug('-=-=--==-recid-=='+dataId);
            FinServ__Employment__c obj = [select id, Name,FinServ__Occupation__c from FinServ__Employment__c WHERE FinServ__Contact__c =: dataId AND Is_Primary__c = true ];
            return obj;
        }catch(exception ex){
            UtilityClass.createException('','newVOIController', 'Employementdata', ex.getMessage(), ex.getStackTraceString(), ''+ex.getLineNumber(),
                                         ex.getTypeName(), ''+ex.getCause());
            return null;
        }
    }

    @AuraEnabled
    public static opportunity getOpportunityData(string oppId){
        try{
            System.debug('oppId==='+oppId);
            opportunity Opp = [select Id,Name,SyncedQuote.Gruop_Name__c,Applicant_2__r.PersonContactId,Applicant_1__r.Number_of_applicants_to_operate_account__pc, Applicant_2__r.Number_of_applicants_to_operate_account__pc,Amount,Number_of_applicants__c, Application_Sections__c,Applicant_2__r.FinServ__Occupation__pc, Applicant_1__r.Tax_Resident_of_countries__pc, Current_Application_Sections__c,FinServ__ReferredByUser__c,Applicant_2__r.FinServ__Gender__pc,Applicant_2__r.Residential_Address__pc,Applicant_2__r.Postal_Address__pc,Applicant_2__r.PersonMobilePhone,Applicant_2__r.PersonEmail,Applicant_2__r.Primary_Employer_Job_Title__pc,Applicant_2__r.FirstName,
                               Applicant_1__c,Applicant_1__r.Residential_Address__pc,Applicant_1__r.Primary_Employer_Job_Title__pc,Applicant_1__r.FinServ__Occupation__pc, Applicant_1__r.Postal_Address__pc, Lender__c,Product_Name__c,Brokerage_Service_Fee_inc_GST__c,Total_Loan_amount__c,Interest_Rate__c, Applicant_1__r.Name,Applicant_1__r.PersonContactId,Loan_Term_months__c, Applicant_2__c,Lead_Source__c,Loan_Amount__c,
                               Account.RecordType.Name,Applicant_1__r.PersonEmail,Applicant_2__r.Name,Customer_Support_Person__c, Applicant_1__r.Tax_File_Number_TFN__pc, Applicant_1__r.PersonMobilePhone, Applicant_2__r.LastName, Applicant_1__r.PersonBirthdate,Applicant_2__r.PersonBirthdate, Applicant_1__r.FinServ__Gender__pc, Applicant_1__r.LastName,Applicant_1__r.FirstName, FinServ__Household__c,Type_of_interest_rate__c,Monthly_Repayments__c, Application_Supporting_Notes__c, Preferred_repayment_frequency__c, Relationship_to_Applicant_2__c,RecordType.Name,
                               Name_s_on_account__c,Financial_Institution__c,BSB_number__c,Account_number__c FROM Opportunity WHERE Id =: oppId limit 1];
            system.debug('Opp--='+Opp);
            oppData = Opp;
            return Opp;            
        }catch(exception ex){
            UtilityClass.createException('','newVOIController', 'getOpportunityData', ex.getMessage(), ex.getStackTraceString(), ''+ex.getLineNumber(),
                                         ex.getTypeName(), ''+ex.getCause());
            return null;
        }
    }

    public static contact getContactData(string conId){
        try{
            contact personCon = [Select id,is_emal_sent_for_VOI__c, name,Current_VOI_stage__c,voi_Email_Verification_Code__c,is_Email_verified_for_VOI__c,Email,Phone,Number_of_applicants_to_operate_account__c, VOI_type__c from contact WHERE id = : conId limit 1];                            
            return personCon;
        }catch(exception ex){
            UtilityClass.createException('','newVOIController', 'getContactData', ex.getMessage(), ex.getStackTraceString(), ''+ex.getLineNumber(),
                                         ex.getTypeName(), ''+ex.getCause());
            return null;
        }
    }
    
	@AuraEnabled
    public static VOI_status__c getVOI(string conId){
        try{
            system.debug('-----contact=-'+conId);
            VOI_status__c voi = new VOI_status__c();
            for(VOI_status__c vois : [Select Id,VOI_Detail__r.id,VOI_URL__c,contact__r.Email,contact__r.FirstName,Current_VOI_section__c,VOI_Type_For__c, name,VOI_Detail__c,contact__r.name, Skip_VOI__c From VOI_status__c WHERE contact__r.Id =: conId order by createddate DESC LIMIT 1]){
                voi= vois;
            }           
            system.debug('--=opopo-=-'+voi);
            return voi;
        }catch(Exception ex){
           UtilityClass.createException('','newVOIController', 'getVOI', ex.getMessage(), ex.getStackTraceString(), ''+ex.getLineNumber(),
                                         ex.getTypeName(), ''+ex.getCause());
            return null;
        }        
    }

    public static Quote getQUoteData(string OppId){
        try{
          Quote  Qot = [SELECT Id,Gruop_Name__c,Quote_Group_Label__c,Product__r.Repayment_Type__c, Customer_Amount__c,Lender__c,Commission_Type__c,QuoteNumber,Total_Setup_Fees__c,Monthly_Account_Keeping_Fees__c,Total_Loan_Cost__c,Up_Front_Fees__c, Total_loan_amount__c, Monthly_Repayments__c, Loan_Term__c, Monthly_Repayment__c, Purpose__c,Repayment_Frequency_Options__c,  Interest_Rate__c,
                   Lead__c, Lead__r.FirstName, Lead__r.LastName, Lead__r.Email,Brokerage_Amount__c, Shared_Message__c, Weekly_Repayments__c,Fortnightly_Repayments__c,
                   Opportunity.Applicant_1__r.PersonContactId,Commission_Amount__c,Quote.Product__r.Interest_Rate_Type__c, Product__c, Product__r.Name
                   FROM Quote WHERE OpportunityId =: OppId AND Application__c = true LIMIT 1];
            return Qot;
        }catch(Exception ex){
            UtilityClass.createException('','newVOIController', 'getQUoteData', ex.getMessage(), ex.getStackTraceString(), ''+ex.getLineNumber(),
                                         ex.getTypeName(), ''+ex.getCause());
            return null;
        }      
    }
    
     @auraEnabled
    public static contact emailForOtp(string conId){
        try{
            Double randomNum = Math.floor(1000 + Math.random() * 9000);
            Integer num = Math.round(randomNum);
            contact con = [Select id,is_emal_sent_for_VOI__c,Session_Start_Time__c,voi_Email_Verification_Code__c,Email,Count__c, Phone, PhoneForPortal__c from contact where id =: conId LIMIT 1];
            con.voi_Email_Verification_Code__c = String.valueOf(num);
            if(!con.is_emal_sent_for_VOI__c){
                con.is_emal_sent_for_VOI__c = true;
            }
            update con;
            OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address =:UtilityClass.adminEmail];
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<string> sendTo = new List<string>();
            if(con.Email != Null){
                sendTo.add(con.Email);
            }
            mail.setToAddresses(sendTo);
            if(owea.size() > 0){
                mail.setorgWideEmailAddressId(Owea.get(0).Id);
            }
            mail.setUseSignature(false);
            mail.setTargetObjectId(con.id);
            mail.Setwhatid(con.id); 
            mail.setSaveAsActivity(false);
            mail.setTreatTargetObjectAsRecipient(false);
            EmailTemplate et=[Select id, Subject from EmailTemplate where Name = 'senEmailOTPforVOI']; 
            mail.setTemplateId(et.id);
            mails.add(mail);
            if(!test.isRunningTest()){
                Messaging.sendEmail(mails);   
            }
            return con;
        }catch(exception e){
            UtilityClass.createException('','Digital_ID_Sign', 'emailForOtp', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return null;
        }         
    }
    
    @AuraEnabled
    public static string updateForEmailVerify(string conId){
        try{
            contact con = [Select id,is_Email_verified_for_VOI__c from contact where id =: conId LIMIT 1];
            con.is_Email_verified_for_VOI__c = true;
            update con;
            return 'success';
        }catch(Exception ex){
            UtilityClass.createException('','Digital_ID_Sign', 'updateForEmailVerify', ex.getMessage(), ex.getStackTraceString(), ''+ex.getLineNumber(),
                                         ex.getTypeName(), ''+ex.getCause());
            return 'something went wrong!!!';
        }
        
    }
    
     @AuraEnabled
    public static string updateVOIst(VOI_status__c vs){
        try{
            SYstem.debug('vs Data[[[[[[[[==='+vs);        
            update vs;
            return 'success';
        }catch(Exception ex){
            UtilityClass.createException('','Digital_ID_Sign', 'updateVOIst', ex.getMessage(), ex.getStackTraceString(), ''+ex.getLineNumber(),
                                         ex.getTypeName(), ''+ex.getCause());
            return 'something went wrong!!!';
        }
    }
    
    @auraEnabled
    public static string removeContent(string docId){
        try{
            System.debug('====> '+docId);
            Delete [SELECT Id FROM ContentDocument WHERE Id =: docId LIMIT 1];
            return 'success';
        }catch(Exception e){
            UtilityClass.createException('','Digital_ID_Sign', 'removeContent', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
            return 'error';
        }
    }
    
    @AuraEnabled
    public static contact sendCustomEmail(string email, string conId){
        system.debug('email id=='+email);
        try{
            Double randomNum = Math.floor(1000 + Math.random() * 9000);
            Integer num = Math.round(randomNum);
            contact con = [Select id,Session_Start_Time__c,voi_Email_Verification_Code__c,Email,Count__c, Phone, PhoneForPortal__c from contact where id =: conId LIMIT 1];
            con.voi_Email_Verification_Code__c = String.valueOf(num);
            update con;
            OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address =:UtilityClass.adminEmail];
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<string> sendTo = new List<string>();
            sendTo.add(email);
            mail.setToAddresses(sendTo);
            if(owea.size() > 0){
                mail.setorgWideEmailAddressId(Owea.get(0).Id);
            }
            mail.setUseSignature(false);
            mail.setTargetObjectId(con.id);
            mail.Setwhatid(con.id); 
            mail.setSaveAsActivity(false);
            mail.setTreatTargetObjectAsRecipient(false);
            EmailTemplate et=[Select id, Subject from EmailTemplate where Name = 'senEmailOTPforVOI']; 
            mail.setTemplateId(et.id);
            mails.add(mail);
            if(!test.isRunningTest()){
                Messaging.sendEmail(mails);   
            }
            return con;	     	
           
        }catch(Exception ex){
            UtilityClass.createException('','Digital_ID_Sign', 'sendCustomEmail', ex.getMessage(), ex.getStackTraceString(), ''+ex.getLineNumber(),
            ex.getTypeName(), ''+ex.getCause());
            return null;
        }
    }
    
    public static PageReference videoSS(){
        try{
            string Imagedata = Apexpages.currentPage().getParameters().get('Video_SS');	
            Imagedata = Imagedata.substring(Imagedata.indexOf(',')+1,Imagedata.length());
            System.debug('Image Dtaa'+Imagedata);
            Set<Id> CDId = new Set<Id>();
            
            VOI_Detail__c vd = new VOI_Detail__c();
            string conid = ApexPages.currentPage() != null ? ApexPages.currentPage().getParameters().get('conId') : '';
            VOI_Status__c temp = [select Id,VOI_Detail__r.id, Current_VOI_section__c,opportunity__r.Applicant_2__c,opportunity__r.Applicant_2__r.personContactId, Contact__r.id, name,VOI_Detail__c,VOI_stage__c ,VOI_Type_For__c,link_Expire_code__c, contact__c from VOI_Status__c WHERE contact__r.Id =: conId order by createddate DESC LIMIT 1];       
            for(VOI_Detail__c voideta : [SELECT Id, Name,Secure_Code_Orignal__c, Contact__r.Id from VOI_Detail__c WHERE Id =: temp.VOI_Detail__r.id order by createddate DESC LIMIT 1]){
                vd = voideta;
            }
            
            for(ContentDocumentLink Cd : [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = : vd.Id AND ContentDocument.Title = 'VideoSnap' LIMIT 1]){
                CDId.add(Cd.ContentDocumentId);
            }
            System.debug('CDId--->'+CDId);
            if(CDId != null && CDId.size() > 0){
                ContentVersion Cd = [SELECT ContentDocumentId,VersionData FROM ContentVersion WHERE ContentDocumentId IN: CDId AND Title = 'VideoSnap' LIMIT 1];
                cd.VersionData = EncodingUtil.base64Decode(Imagedata);
                System.debug('inside the IF');
                update cd;			
            }else{
                ContentVersion ContVerFile = new ContentVersion();
                ContVerFile.VersionData = EncodingUtil.base64Decode(Imagedata);
                ContVerFile.Title = 'VideoSnap'; 
                ContVerFile.PathOnClient='VideoSnap.jpeg';
                ContVerFile.IsMajorVersion = false;
                insert ContVerFile;
                SYstem.debug('ContVerFile id '+ContVerFile.Id);
                List<ContentVersion> conDocId = new List<ContentVersion>();
                
                
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :ContVerFile.Id];
                System.debug('conDocId : '+conDocId[0].ContentDocumentId);
                
                ContentDocumentLink cdl = New ContentDocumentLink();
                
                
                cdl.LinkedEntityId = vd.Id;
                
                cdl.ContentDocumentId = conDocId[0].ContentDocumentId;
                
                cdl.shareType = 'V';
                cdl.Visibility = 'AllUsers';
                
                Insert cdl;
                
            }
        }catch(Exception ex){	
            UtilityClass.createException('','Digital_ID_Sign', 'videoSS', ex.getMessage(), ex.getStackTraceString(), ''+ex.getLineNumber(),	
                                         ex.getTypeName(), ''+ex.getCause());	
        }
        return null;
    }
    
    public static PageReference videoDataforClass(){
        string vidData = '';
        try{
           	string videoData = Apexpages.currentPage().getParameters().get('videoData');
            vidData = videoData;
            system.debug('+++++++++++'+videoData); 
            VOI_Detail__c vd = new VOI_Detail__c();
            string conid = ApexPages.currentPage() != null ? ApexPages.currentPage().getParameters().get('conId') : '';
            VOI_Status__c temp = [select Id,VOI_Detail__r.id, Current_VOI_section__c,opportunity__r.Applicant_2__c,opportunity__r.Applicant_2__r.personContactId, Contact__r.id, name,VOI_Detail__c,VOI_stage__c ,VOI_Type_For__c,link_Expire_code__c, contact__c from VOI_Status__c WHERE contact__r.Id =: conId order by createddate DESC LIMIT 1];       
            for(VOI_Detail__c voideta : [SELECT Id, Name,Secure_Code_Orignal__c, Contact__r.Id from VOI_Detail__c WHERE Id =: temp.VOI_Detail__r.id order by createddate DESC LIMIT 1]){
                vd = voideta;
            }
            
            
            if(temp.VOI_Type_For__c == 'VOI'){
                temp.link_Expire_code__c = '';
                update temp;
            }

            system.debug('+++++++++++'+vd); 
            videoData = videoData.substring(videoData.indexOf(',')+1,videoData.length());
            System.debug('Image Dtaa'+videoData);
            videoData = videoData.remove(':');
            videoData = videoData.deleteWhitespace();
            Set<Id> CDId = new Set<Id>();
            
            for(ContentDocumentLink Cd : [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = : vd.Id AND ContentDocument.Title = 'video' LIMIT 1]){
                CDId.add(Cd.ContentDocumentId);
            }
            System.debug('CDId--->'+CDId);
            if(CDId != null && CDId.size() > 0){
                ContentVersion Cd = [SELECT ContentDocumentId,VersionData FROM ContentVersion WHERE ContentDocumentId IN: CDId AND Title = 'video' LIMIT 1];
                cd.VersionData = EncodingUtil.base64Decode(videoData);
                System.debug('inside the IF');
                update cd;			
            }else{
                ContentVersion ContVerFile = new ContentVersion();
                ContVerFile.VersionData = EncodingUtil.base64Decode(videoData);
                ContVerFile.Title = 'video'; 
                ContVerFile.PathOnClient='video.mp4';
                ContVerFile.IsMajorVersion = false;
                insert ContVerFile;
                SYstem.debug('ContVerFile id '+ContVerFile.Id);
                List<ContentVersion> conDocId = new List<ContentVersion>();
                
                
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :ContVerFile.Id];
                System.debug('conDocId : '+conDocId[0].ContentDocumentId);
                
                ContentDocumentLink cdl = New ContentDocumentLink();
                
                
                cdl.LinkedEntityId = vd.Id;
                
                cdl.ContentDocumentId = conDocId[0].ContentDocumentId;
                
                cdl.shareType = 'V';
                cdl.Visibility = 'AllUsers';
                
                Insert cdl; 


            }
        }catch(Exception ex){
             UtilityClass.createException('','Digital_ID_Sign', 'videoDataforClass', ex.getMessage(), ex.getStackTraceString(), ''+ex.getLineNumber(),
            ex.getTypeName(), ''+ex.getCause());
            return null;
        }
        
        return null;
    }
    
    public static void sendAnotherDevice(){                
        try{
            String deviceType = Apexpages.currentPage().getParameters().get('type');
            String ConId = Apexpages.currentPage().getParameters().get('conId');
            contact con = [Select id,Name,Session_Start_Time__c,voi_Email_Verification_Code__c,Email,Count__c, Phone, PhoneForPortal__c from contact where id =: ConId LIMIT 1];         
            VOI_Status__c vs = getVOI(con.Id);
        if(deviceType == 'email'){
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: UtilityClass.adminEmail];                   
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<string> sendTo = new List<string>();
            sendTo.add(con.Email);
            mail.setToAddresses(sendTo);
            if(owea.size() > 0){
                mail.setorgWideEmailAddressId(Owea.get(0).Id);
            }
            mail.setUseSignature(false);
            mail.setTargetObjectId(con.id);
            mail.Setwhatid(vs.id); 
            mail.setSaveAsActivity(false);
            mail.setTreatTargetObjectAsRecipient(false);
            EmailTemplate et=[Select id, Subject from EmailTemplate where Name = 'EmailForAnotherDevice']; 
            mail.setTemplateId(et.id);
            mails.add(mail);
            if(!test.isRunningTest()){
                Messaging.sendEmail(mails);   
            }
          	}
            else{
                system.debug('--=-Send SMS--==');      
                string body = 'Complete your verification here: '+vs.VOI_URL__c;
                SMSController.SendMessageForVOI('Contact', con.Name, con.Phone, body);      
            }
        }catch(Exception ex){
            UtilityClass.createException('','Digital_ID_Sign', 'sendAnotherDevice', ex.getMessage(), ex.getStackTraceString(), ''+ex.getLineNumber(),
            ex.getTypeName(), ''+ex.getCause());
        }
        
    }
    
    public static void updateVOIfromesign(){
        string sec = ApexPages.currentPage() != null ? ApexPages.currentPage().getParameters().get('section') : '';
        string ConId = ApexPages.currentPage() != null ? ApexPages.currentPage().getParameters().get('conId') : '';
        try{            
            voi_status__c vs = getVOI(ConId);
            if(vs.VOI_Type_For__c == 'Full'){
                vs.Current_VOI_section__c = sec;
                update vs;
            }            
        }catch(Exception ex){
           UtilityClass.createException('','Digital_ID_Sign', 'updateVOIfromesign', ex.getMessage(), ex.getStackTraceString(), ''+ex.getLineNumber(),
            ex.getTypeName(), ''+ex.getCause());
        }
    }
    
    public static PageReference Sign1DataforClass(){
        try{
            string Imagedata = Apexpages.currentPage().getParameters().get('sign1');	
            string name = Apexpages.currentPage().getParameters().get('name');	
            Imagedata = Imagedata.substring(Imagedata.indexOf(',')+1,Imagedata.length());
            system.debug('-=-=-=-=siganature data--==-'+Imagedata);
            system.debug('-=-=-=-=siganature name--==-'+name);
            VOI_Detail__c vd = new VOI_Detail__c();
            set<id> VOIid = new set<Id>();
            string conid = ApexPages.currentPage() != null ? ApexPages.currentPage().getParameters().get('conId') : '';
            VOI_Status__c temp = [select Id,VOI_Detail__r.id, Current_VOI_section__c,opportunity__r.Applicant_2__c,opportunity__r.Applicant_2__r.personContactId, Contact__r.id, name,VOI_Detail__c,VOI_stage__c ,VOI_Type_For__c,link_Expire_code__c, contact__c from VOI_Status__c WHERE contact__r.Id =: conId order by createddate DESC LIMIT 1];       
            for(VOI_Detail__c voideta : [SELECT Id, Name,Secure_Code_Orignal__c, Contact__r.Id from VOI_Detail__c WHERE Id =: temp.VOI_Detail__r.id order by createddate DESC LIMIT 1]){
                vd = voideta;
                VOIid.add(vd.id);
            }
            Set<Id> CDId = new Set<Id>();
            
            for(ContentDocumentLink Cd : [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: VOIid AND ContentDocument.Title =: name LIMIT 1]){
                CDId.add(Cd.ContentDocumentId);
            }
            System.debug('CDId--->'+CDId);
            if(CDId != null && CDId.size() > 0){
                ContentVersion Cd = [SELECT ContentDocumentId,VersionData FROM ContentVersion WHERE ContentDocumentId IN: CDId AND Title =: name LIMIT 1];
                cd.VersionData = EncodingUtil.base64Decode(Imagedata);
                System.debug('inside the IF');
                update cd;			
            }else{
                ContentVersion ContVerFile = new ContentVersion();
                ContVerFile.VersionData = EncodingUtil.base64Decode(Imagedata);
                ContVerFile.Title = name; 
                ContVerFile.PathOnClient= name+'.png';
                ContVerFile.IsMajorVersion = false;
                insert ContVerFile;
                SYstem.debug('ContVerFile id '+ContVerFile.Id);
                List<ContentVersion> conDocId = new List<ContentVersion>();
                
                
                conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :ContVerFile.Id];
                System.debug('conDocId : '+conDocId[0].ContentDocumentId);
                
                ContentDocumentLink cdl = New ContentDocumentLink();
                
                
                cdl.LinkedEntityId = vd.Id;
                
                cdl.ContentDocumentId = conDocId[0].ContentDocumentId;
                
                cdl.shareType = 'V';
                cdl.Visibility = 'AllUsers';
                
                Insert cdl; 
            }
            
        }catch(Exception ex){
            UtilityClass.createException('','Digital_ID_Sign', 'Sign1DataforClass', ex.getMessage(), ex.getStackTraceString(), ''+ex.getLineNumber(),
            ex.getTypeName(), ''+ex.getCause());
        }
        return null;
    }
    
    @AuraEnabled
    public static string sendAnotherDevByLwc(string deviceType, string conId){
        
        try{
            contact con = [Select id,Name,Session_Start_Time__c,voi_Email_Verification_Code__c,Email,Count__c, Phone, PhoneForPortal__c from contact where id =: conId LIMIT 1];         
            VOI_Status__c vs = getVOI(con.Id);
        if(deviceType == 'email'){
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: UtilityClass.adminEmail];                   
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<string> sendTo = new List<string>();
            sendTo.add(con.Email);
            mail.setToAddresses(sendTo);
            if(owea.size() > 0){
                mail.setorgWideEmailAddressId(Owea.get(0).Id);
            }
            mail.setUseSignature(false);
            mail.setTargetObjectId(con.id);
            mail.Setwhatid(vs.id); 
            mail.setSaveAsActivity(false);
            mail.setTreatTargetObjectAsRecipient(false);
            EmailTemplate et=[Select id, Subject from EmailTemplate where Name = 'EmailForAnotherDevice']; 
            mail.setTemplateId(et.id);
            mails.add(mail);
            if(!test.isRunningTest()){
                Messaging.sendEmail(mails);   
            }
            	return 'success';
        	}
            else{
                system.debug('--=-Send SMS--==');      
                string body = 'Complete your verification here: '+vs.VOI_URL__c;
                SMSController.SendMessageForVOI('Contact', con.Name, con.Phone, body);      
                return 'success';
            }
        }catch(Exception ex){
            UtilityClass.createException('','Digital_ID_Sign', 'sendAnotherDevByLwc', ex.getMessage(), ex.getStackTraceString(), ''+ex.getLineNumber(),
            ex.getTypeName(), ''+ex.getCause());
            return null;
        }
        
    }

    public static void updateOppSection(){
        string oppId = ApexPages.currentPage() != null ? ApexPages.currentPage().getParameters().get('oppId') : ''; 
        string conId = ApexPages.currentPage() != null ? ApexPages.currentPage().getParameters().get('conId') : '';       

        forDocsAndAlldone(oppId, conId);
    }
    
    @AuraEnabled
    public static void insertPDFAndSendEmail(string conId, string oppId){
        forDocsAndAlldone(oppId, conId);
        InsertPDf(oppId,conId);
        //BatchForVoiPdfAndEmail obj = new BatchForVoiPdfAndEmail(oppId,conId);
        //database.executeBatch(obj);     
    }
    
    public static void insertPDFAndSendEmailFromVFCmp(){
        string conId = ApexPages.currentPage() != null ? ApexPages.currentPage().getParameters().get('conId') : '';
        string oppId = ApexPages.currentPage() != null ? ApexPages.currentPage().getParameters().get('oppId') : '';
        forDocsAndAlldone(oppId, conId);  
        InsertPDf(oppId,conId);
        //BatchForVoiPdfAndEmail obj = new BatchForVoiPdfAndEmail(oppId,conId);
        //database.executeBatch(obj);     
    }

    public static void forDocsAndAlldone(string oppId, string conId){
        try{
        Opportunity oppUpdate = [SELECT Id, Name,Applicant_2__c,Application_Sections__c, Current_Application_Sections__c, AccountId, Applicant_1__c,
                                 Applicant_1__r.PersonContactId, Applicant_1__r.PersonContact.Email, StageName, RecordTypeId,
                                 Number_of_applicants__c,
                                 (SELECT Id, Lead__c, Lender__c, Purpose__c  FROM Quotes WHERE Application__c = TRUE)
                                 FROM Opportunity WHERE Id =: oppId];
                                 
        CreateDocumentController.createDocumentRequest(oppId);                                

        Map<String, Contact> empDetail =  new Map<String, Contact>();
        empDetail = ParkerLaneLoanController.getEmploymentDetails(oppUpdate.id);
        boolean isAppStatus = false;
        string url = '';

        List<String> appSectionsList = ParkerLaneLoanController.getApplicationSections();

        if(empDetail.get('applicant1').FinServ__Employment__r != null && empDetail.get('applicant1').FinServ__Employment__r.size() > 0){
            List<FinServ__Employment__c> empList = empDetail.get('applicant1').FinServ__Employment__r;
            for(FinServ__Employment__c emp : empList){
                if(emp.FinServ__EmploymentStatus__c == 'Self Employed / Contractor'){
                	isAppStatus = true;
                    break;
                }        
            }
        }
        
        if(oppUpdate.Applicant_2__c != null && !isAppStatus){
            if(empDetail.get('applicant2').FinServ__Employment__r != null && empDetail.get('applicant2').FinServ__Employment__r.size() > 0){
                List<FinServ__Employment__c> empList = empDetail.get('applicant2').FinServ__Employment__r;
                for(FinServ__Employment__c emp : empList){
                    if(emp.FinServ__EmploymentStatus__c == 'Self Employed / Contractor'){
                        isAppStatus = true;
                        break;
                    }        
                }
            }
        }
        Quote qt = New Quote();  
        qt = oppUpdate.Quotes[0];
        

        if(conId == oppUpdate.Applicant_1__r.PersonContactId){
            String nextSection = oppUpdate.Current_Application_Sections__c;

            if(qt.Lender__c == 'Transport Mutual Credit Union' && !isAppStatus){
                if(oppUpdate.Current_Application_Sections__c == 'VOI'){
                    nextSection = appSectionsList[appSectionsList.indexOf(oppUpdate.Current_Application_Sections__c) + 1];   
                }                
                else{
                    nextSection = appSectionsList[appSectionsList.indexOf(oppUpdate.Current_Application_Sections__c)];
                }
                url = String.valueof(System.URL.getSalesforceBaseURL().toExternalForm()) + '/apex/MogoDocument?oppId=' + oppId;
            }else {
                nextSection = appSectionsList[appSectionsList.indexOf('Standard Document Upload')];
                url = String.valueof(System.URL.getSalesforceBaseURL().toExternalForm()) + '/supportingDocument?oppId=' + oppId;
            }
            
            
                if(oppUpdate.Application_Sections__c == oppUpdate.Current_Application_Sections__c){
                    oppUpdate.Application_Sections__c = nextSection;
                }
                oppUpdate.Current_Application_Sections__c = nextSection;
                
            

                oppUpdate.Document_Redirect_URL__c  = url; 
                    update oppUpdate;
        }

        }catch(Exception ex){
            UtilityClass.createException('','newVOIController', 'forDocsAndAlldone', ex.getMessage(), ex.getStackTraceString(), ''+ex.getLineNumber(),
            ex.getTypeName(), ''+ex.getCause());
        }
        
    }
    
    
    public static void InsertPDf(string oppId, string conId){        
        Boolean Flag;
        try{
            opportunity opp = [select Id,Applicant_1__c,Applicant_1_eSign_Status__c,Applicant_2_eSign_Status__c,Lender__c,Loan_Amount__c,Applicant_2__c,Applicant_1__r.personContactId,Applicant_2__r.personContactId, Loan_Purpose__c,Purpose__c from opportunity WHERE ID =: oppId LIMIT 1];
            List<Blob> BPDF = new List<Blob>();
            Set<id> Setid = new SET<Id>();
            VOI_Status__c temp = [select Id, name,link_Expire_code__c, Contact__r.AccountId,contact__c, contact__r.Name from VOI_Status__c WHERE contact__r.Id =: conId order by createddate DESC LIMIT 1];
            
            
            List<Document_Requested__c> dcList = new List<Document_Requested__c>();
            Document_Requested__c dc = new Document_Requested__c();
            dc.Category__c = 'Credit Proposal';
            dc.Person_Account__c = temp.Contact__r.AccountId;
            dc.Opportunity__c = opp.Id;
            dcList.add(dc);
            
            if(opp.Lender__c == 'Transport Mutual Credit Union'){
                Document_Requested__c dc1 = new Document_Requested__c();
                dc1.Category__c = 'Lender Membership';
                dc1.Person_Account__c = temp.Contact__r.AccountId;
                dc1.Opportunity__c = opp.Id;
                dcList.add(dc1);
            	
                Document_Requested__c dc2 = new Document_Requested__c();
                dc2.Category__c = 'Direct Debit Form';
                dc2.Person_Account__c = temp.Contact__r.AccountId;
                dc2.Opportunity__c = opp.Id;
                dcList.add(dc2);
            }
            
            insert dcList;
            Set<id> Drids = new Set<id>();
            
            for(Document_Requested__c obj : dcList){
                Drids.add(obj.id);
            }
            
            PageReference pdf1 = Page.Generate_PDF_FOR_Application_Doc;
            pdf1.getParameters().put('OppId',OppId);
            pdf1.getParameters().put('ConId',ConId);
            pdf1.setRedirect(true);
            
            PageReference pdf2;
            PageReference pdf3;
            if(opp.Lender__c == 'Transport Mutual Credit Union'){
                pdf2 = Page.TMCUDocPDF;
                pdf2.getParameters().put('OppId',OppId);
                pdf2.getParameters().put('ConId',ConId);
                pdf2.setRedirect(true);
                
                pdf3 = Page.Direct_Debit_Authority_PDF;
                pdf3.getParameters().put('OppId',OppId);
                pdf3.getParameters().put('ConId',ConId);
                pdf3.setRedirect(true);
            }
            
            
            if (Test.IsRunningTest())
            {
                bPDF.add(Blob.valueOf('UNIT.TEST'));
            }
            else
            {
                System.debug('pdf.getContent()'+pdf1.getContent());
                bPDF.add(pdf1.getContent());
                if(opp.Lender__c == 'Transport Mutual Credit Union'){
                    bPDF.add(pdf2.getContent());    
                    bPDF.add(pdf3.getContent());    
                }
                
            }
            
            Datetime dt = System.now();
            List<string> data = string.valueOf(dt).split(' ');
            dateTime tim =  dt;
            string team = data[0]+ ' '+ tim.format('h:mm a');
            
            string len = '';
            if(opp.Lender__c == 'Transport Mutual Credit Union'){
                len = 'TMCU';
            }
            else if(opp.Lender__c == 'Wisr'){
                len = 'W';
            }
            else{
                len = opp.Lender__c;
            }
            string CPQ = 'Singed CQP - '+ temp.Contact__r.Name + ' $'+ getCents(opp.Loan_Amount__c)+ ' ' + '('+len+') '+ team;
            string TMCU = 'Signed TMCU Membership - '+ temp.Contact__r.Name +  ' ' + team;
            string DirectDbtFrm = 'TMCU Direct Debit Authority - '+ temp.Contact__r.Name +  ' ' + team;
            
            List<ContentVersion> cvList = new List<ContentVersion>();
            
            ContentVersion ContVerFile = new ContentVersion();
            ContVerFile.VersionData = bPDF[0];
            ContVerFile.Title = CPQ; 
            ContVerFile.FirstPublishLocationId = opp.Id;
            ContVerFile.PathOnClient= CPQ+'.Pdf';           
            ContVerFile.Document_Requested__c = dcList[0].id;
            cvList.add(ContVerFile);          
            
            if(opp.Lender__c == 'Transport Mutual Credit Union'){
                ContentVersion ContVerFile1 = new ContentVersion();
                ContVerFile1.VersionData = bPDF[1];
                ContVerFile1.Title = TMCU; 
                ContVerFile1.FirstPublishLocationId = opp.Id;
                ContVerFile1.PathOnClient= TMCU+'.Pdf';
                ContVerFile1.Document_Requested__c = dcList[1].id;	
                cvList.add(ContVerFile1);
                
                ContentVersion ContVerFile2 = new ContentVersion();
                ContVerFile2.VersionData = bPDF[2];
                ContVerFile2.Title = DirectDbtFrm; 
                ContVerFile2.FirstPublishLocationId = opp.Id;
                ContVerFile2.PathOnClient= DirectDbtFrm+'.Pdf';
                ContVerFile2.Document_Requested__c = dcList[2].id;	
                cvList.add(ContVerFile2);
            }
            
            if(cvList != null && cvList.size() > 0){
             	insert cvList;   
            }            
            for(ContentVersion cv : cvList){
                Setid.add(cv.id);
            }                       
            
            List<Document_Requested__c> updateDc = new List<Document_Requested__c>();
            for(Document_Requested__c d : [SELECT Id, OwnerId, Name, LastModifiedDate, LastModifiedById, LastActivityDate, Contact__c, Category__c, Description__c, Details__c, Document__c, Opportunity__c, isComplete__c FROM Document_Requested__c WHERE Id IN: drIds]){
                d.isComplete__c = true;
                updateDc.add(d);
            }
            
            if(updateDc != null && updateDc.size() > 0){
                update updateDc;
            }
            
            
            Flag = true;
            
            if(ConId == opp.Applicant_1__r.personContactId){
                opp.Applicant_1_eSign_Status__c = 'Signed';
            }        
            
            if(opp.Applicant_2__c != null){
                if(ConId == opp.Applicant_2__r.personContactId){
                    opp.Applicant_2_eSign_Status__c = 'Signed';
                }
            }
            OpportunityTriggerHandler.isByPassTrigger = true;
            update opp;  
            OpportunityTriggerHandler.isByPassTrigger = false;
             
            temp.link_Expire_code__c = '';
            temp.Case_Status__c = 'Submitted';
            
            update temp;
            
            if(flag == true && BPDF != null){
                sendEmail(Setid,ConId, OppId);                
            }
            
        }Catch(Exception Ex){
            Flag = false;
            UtilityClass.createException('','newVOIController', 'InsertPDf', ex.getMessage(), ex.getStackTraceString(), ''+ex.getLineNumber(),
            ex.getTypeName(), ''+ex.getCause());
        }   
        
    }
    
     public static String getCents(Decimal x){
        String y = String.valueOf(x);
        String z = '.';
        if(y.contains(',')) z = ',';
        y = y.substring(0, y.indexOf(z));
        if(x - Decimal.valueOf(y) == 0)
            return String.valueOf(x.format());
        else return String.valueOf(x.format());
    }
    
    @Future
    public static void sendEmail(Set<id> versionId, string ConId, string OppId){
        System.debug('versionId'+versionId);
        contact con = [select Id,Email,VOI_stages__c, FirstName from contact WHERE Id =: ConId LIMIT 1];
        opportunity opp = [select Id,Customer_Support_Person_Name__c from opportunity WHERE Id =: OppId LIMIT 1];
        
        try{
            Set<id> documentId = new Set<id>();
            List<ContentVersion> conVerList = new  List<ContentVersion>();
            if(versionId != null && versionId.size() > 0){
                for(ContentDocumentLink cdl : [select id, ContentDocumentId from ContentDocumentLink where LinkedEntityId =: OppId]){
                   documentId.add(cdl.ContentDocumentId); 
                }
                if(documentId != null && documentId.size() > 0){
                    for(ContentVersion cv: [SELECT Id,createddate,Current_in_use__c,Category__c,ContentDocumentId, Title,VersionData FROM ContentVersion WHERE ContentDocumentId IN:documentId order by createddate DESC]){
                        if(versionId.contains(cv.Id)){
                            conVerList.add(cv);                            
                        }
                        if(cv.Category__c == 'Preliminary Assessment' && cv.Current_in_use__c == true){
                            conVerList.add(cv);   
                        }                        
                    }
                }
                
            }
            System.debug('conVerList'+conVerList.size());
            List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
            for(ContentVersion cv : conVerList){
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(cv.Title+'.pdf');
                efa.setContentType('application/pdf');
                efa.setBody(cv.VersionData);
                efaList.add(efa);
            }
            
            EmailTemplate emailTemplate = [SELECT Id,Subject, Body FROM EmailTemplate WHERE DeveloperName = 'VOI_email' ];
            System.debug('Email template ID::'+emailTemplate);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            email.setTemplateId(emailTemplate.id);         
            email.setTargetObjectId(con.id);
            email.setWhatId(OppId);
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: UtilityClass.adminEmail]; // 'personalapplications@parkerlane.com.au'
            if(owea != null){
                if ( owea.size() > 0 ) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
            }
            email.setReplyTo('personalapplications@parkerlane.com.au');
            System.debug('efaList+'+efaList.size());
            email.setFileAttachments(efaList);
            //email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            email.saveAsActivity = true;
            string[] to = new string[] {con.Id};  
                email.setToAddresses(to);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                       
        }catch(Exception ex){
             UtilityClass.createException('','newVOIController', 'sendEmail', ex.getMessage(), ex.getStackTraceString(), ''+ex.getLineNumber(),
            ex.getTypeName(), ''+ex.getCause());
        }
    }
    
    
    
}