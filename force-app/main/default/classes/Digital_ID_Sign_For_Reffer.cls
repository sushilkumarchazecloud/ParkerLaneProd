global without sharing class Digital_ID_Sign_For_Reffer {
    
    public static final string ConId = ApexPages.currentPage() != null ? ApexPages.currentPage().getParameters().get('conId') : '';
    public static final string SecureCode = ApexPages.currentPage() != null ? ApexPages.currentPage().getParameters().get('r') : '';
    public static final string accId = ApexPages.currentPage() != null ? apexpages.currentpage().getparameters().get('id') : '';
    
    
    public Account acc{get;Set;}
    public static string ApplicantName{get;set;}
    
    public static string Amount{get; set;}
    public static Boolean IsApplicantTwo {get;set;}
    public static String SecureCodeOriginal {get; set;}
    public static string FolderId {get; set;}
    //public static string ApplicantsToSign {get; set;}
    public static String signId {get; set;} 
    public static String ImageSrc {get; set;}
    public static boolean redirectToError {get; set;}
    public static string secApplicantName {get; set;}
     public static string message {get;set;}
    
    
    //upload video to drive
    
    
    public Digital_ID_Sign_For_Reffer(){
        try{
            
            acc = New Account();
            if(String.isNotBlank(accId)){
                acc = [SELECT Id, ABN__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Company_Legal_Name__c, 
                       (SELECT Id, FirstName, LastName, Name, Position__c FROM Contacts WHERE Is_Authorised_Signatory__c =true LIMIT 1)
                       FROM Account WHERE id =: accId];
            }
            showError();
            IsApplicantTwo = false;
            
        }catch(Exception ex){
        	System.debug('exception>>>'+ex.getMessage() + ' ' + ex.getLineNumber());
        }
    }
    
    public static void securecode(){
        System.debug('SecureCodeSecureCode --------'+SecureCodeOriginal);
        //opportunity opp = [select id, Name, Applicant_1__r.PersonContactId from opportunity where Id = : OppId];
        
        VOI_Detail__c obj  = new VOI_Detail__c();
        obj.Secure_Code_Orignal__c = SecureCodeOriginal;
        obj.Contact__c = ConId;
        insert obj;
        
        VOI_Status__c temp = [select Id, name,link_Expire_code__c, contact__c from VOI_Status__c WHERE Contact__r.Id =: ConId order by createddate DESC LIMIT 1];
        
        temp.VOI_Detail__c = obj.id;
        
        update temp;
    }
    
    
    public static void showError(){
        
        List<VOI_Status__c> temp = [select Id, name,link_Expire_code__c, contact__c from VOI_Status__c WHERE Contact__r.Id =: ConId order by createddate DESC LIMIT 1];
        
        if(temp != null){
            if(temp.size() > 0){
                if(SecureCode != temp[0].link_Expire_code__c){
                    redirectToError = true;
                }
                else{
                    redirectToError = false;
                }        
            }
        }
        
        
    }
    
    
    
    
    public static id VOIDetailID(){
        VOI_Detail__c obj = [SELECT Id, Name, Contact__r.Id from VOI_Detail__c WHERE Contact__r.Id = : ConId order by createddate DESC LIMIT 1];
        
        return obj.Id;
    }
    
    
    
    
    public static PageReference ImageDataforClass(){
        string Imagedata = Apexpages.currentPage().getParameters().get('imageDeta');	
        Imagedata = Imagedata.substring(Imagedata.indexOf(',')+1,Imagedata.length());
        System.debug('Image Dtaa'+Imagedata);
        Set<Id> CDId = new Set<Id>();
        
        for(ContentDocumentLink Cd : [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :VOIDetailID() AND ContentDocument.Title = 'DlFront' LIMIT 1]){
            CDId.add(Cd.ContentDocumentId);
        }
        System.debug('CDId--->'+CDId);
        if(CDId != null && CDId.size() > 0){
            ContentVersion Cd = [SELECT ContentDocumentId,VersionData FROM ContentVersion WHERE ContentDocumentId IN: CDId AND Title = 'DlFront' LIMIT 1];
            cd.VersionData = EncodingUtil.base64Decode(Imagedata);
            System.debug('inside the IF');
            update cd;			
        }else{
            ContentVersion ContVerFile = new ContentVersion();
            ContVerFile.VersionData = EncodingUtil.base64Decode(Imagedata);
            ContVerFile.Title = 'DlFront'; 
            ContVerFile.PathOnClient='DlFront.jpeg';
            ContVerFile.IsMajorVersion = false;
            insert ContVerFile;
            SYstem.debug('ContVerFile id '+ContVerFile.Id);
            List<ContentVersion> conDocId = new List<ContentVersion>();
            
            
            conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :ContVerFile.Id];
            System.debug('conDocId : '+conDocId[0].ContentDocumentId);
            
            ContentDocumentLink cdl = New ContentDocumentLink();
            
            
            cdl.LinkedEntityId = VOIDetailID();
            
            cdl.ContentDocumentId = conDocId[0].ContentDocumentId;
            
            cdl.shareType = 'V';
            cdl.Visibility = 'AllUsers';
            
            Insert cdl;
            
        }
        return null;
    }
    
    public static PageReference videoDataforClass(){
       try{
            string videoData = Apexpages.currentPage().getParameters().get('videoData');
            system.debug('+++++++++++'+videoData);
            videoData = videoData.substring(videoData.indexOf(',')+1,videoData.length());
            System.debug('Image Dtaa'+videoData);
            Set<Id> CDId = new Set<Id>();
            
            for(ContentDocumentLink Cd : [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = : VOIDetailID() AND ContentDocument.Title = 'video' LIMIT 1]){
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
                
                
                cdl.LinkedEntityId = VOIDetailID();
                
                cdl.ContentDocumentId = conDocId[0].ContentDocumentId;
                
                cdl.shareType = 'V';
                cdl.Visibility = 'AllUsers';
                
                Insert cdl; 
            }
        }catch(Exception e){
             message = e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getTypeName();
        }
        
        return null;
    }
    
    public static PageReference Sign1DataforClass(){
        string Imagedata = Apexpages.currentPage().getParameters().get('sign1');	
        Imagedata = Imagedata.substring(Imagedata.indexOf(',')+1,Imagedata.length());
        ContentVersion ContVerFile = new ContentVersion();
        ContVerFile.VersionData = EncodingUtil.base64Decode(Imagedata);
        ContVerFile.Title = 'Sign1'; 
        ContVerFile.PathOnClient='Sign1.jpeg';
        insert ContVerFile;
        SYstem.debug('ContVerFile id '+ContVerFile.Id);
        List<ContentVersion> conDocId = new List<ContentVersion>();
        
        conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :ContVerFile.Id];
        System.debug('conDocId : '+conDocId[0].ContentDocumentId);
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        
        cdl.LinkedEntityId = VOIDetailID();
        
        cdl.ContentDocumentId = conDocId[0].ContentDocumentId;
        
        cdl.shareType = 'V';
        cdl.Visibility = 'AllUsers';
        
        Insert cdl;
        
        return null;
    }
    
    
    @AuraEnabled 
    public static String sendImageDataToComponent(string RecId){
        System.debug('================================='+RecId);
        string temp;
        list<String> VersionDataList = new List<String>();
        Set<Id> CDId = new Set<Id>();
        
        for(ContentDocumentLink Cd : [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = : RecId AND ContentDocument.Title = 'title' LIMIT 1]){
            CDId.add(Cd.ContentDocumentId);
        }
        System.debug('CDId--->'+CDId);
        
        for(ContentVersion Cd : [SELECT ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN : CDId AND Title = 'title' order by createddate DESC LIMIT 1]){
            VersionDataList.add(Cd.ContentDocumentId);
        }
        System.debug('VersionDataList'+VersionDataList);
        if(VersionDataList != null){
            if(VersionDataList.size() > 0){
                temp = VersionDataList[0];
            }
        }
        
        
        return temp;
    }
    
    
    
    @AuraEnabled 
    public static Contact FetchContact(Id recordId){
        system.debug('recordId'+recordId);
        
        VOI_Detail__c voi = [select Id, Name, contact__r.Id From VOI_Detail__c WHERE Id = : recordId];
        
        system.debug('recordId'+voi.contact__r.Id);
        
        Contact con = [SELECT Name, Medicare_Reference__c, FirstName,AccountId, LastName,Govt_Id_Number__c, MiddleName,Does_your_spouse_earn_an_income__c,spouse_s_approximate_annual_income__c, Email, Phone, Title, Birthdate,FinServ__Occupation__c,Account.Industry,Primary_Employer_Job_Title__c, 
                       OtherPhone, FinServ__Gender__c,Rental_or_Board_paid__c, FinServ__MaritalStatus__c, Government_ID__c,
                       Rental_Amount__c, Rental_Frequency__c, Rental_Managed_via__c, Citizenship_Status__c, Visa_Details__c,
                       First_Name_Child_1__c, Residential_Address__c,First_Name_Child_2__c, First_Name_Child_3__c, First_Name_Child_4__c, First_Name_Child_5__c,
                       Age_Child_1__c, Age_Child_2__c, Age_Child_3__c, Age_Child_4__c, Age_Child_5__c,Medicare_Card_Colour__c,
                       Medicare_Expiry_Date__c,Medicare_Number__c,Monthly_Rental_Payments__c,Other_Regular_Expenditure__c
                       FROM Contact WHERE id =: voi.contact__r.Id];
        con.birthdate = null;
        con.Government_ID__c = '';
        con.Govt_Id_Number__c = '';
        con.FinServ__Gender__c = '';
        
        return con;
    }
    
    @AuraEnabled 
    public static void UpdateOppCon(Contact cont){
        System.debug('contId : ::::'+cont.AccountId);
        System.debug('contId : ::::'+cont.Government_ID__c);
        Contact con = new Contact();
        con.Id = cont.Id;
        con.Birthdate = cont.Birthdate;
        con.Government_ID__c = cont.Government_ID__c;
        con.Govt_Id_Number__c = cont.Govt_Id_Number__c;
        con.FinServ__Gender__c = cont.FinServ__Gender__c;
        con.Residential_Address__c = cont.Residential_Address__c;
        con.Driver_s_licence_state_Territory__c = cont.Driver_s_licence_state_Territory__c;
        update con;
    }
    
    public static void insertPdf(){
        PageReference pdf = Page.Digital_Reffer_PDF;
        pdf.getParameters().put('id',accId);
        pdf.getParameters().put('ConId',ConId);
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
        SYstem.debug('ContVerFile id '+ContVerFile.Id);
        List<ContentVersion> conDocId = new List<ContentVersion>();
        
        conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :ContVerFile.Id];
        System.debug('conDocId : '+conDocId[0].ContentDocumentId);
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        
        cdl.LinkedEntityId = accId;
        
        cdl.ContentDocumentId = conDocId[0].ContentDocumentId;
        
        cdl.shareType = 'V';
        
        Insert cdl;
      
        
        VOI_Status__c temp = [select Id, name,link_Expire_code__c, contact__c from VOI_Status__c WHERE contact__r.Id =: ConId order by createddate DESC LIMIT 1];
        
        temp.link_Expire_code__c = '';
        temp.Case_Status__c = 'Submitted';
        
        update temp;
        
        System.debug('pdf data : '+bPDF);
        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referrer (Business)').getRecordTypeId();    
        
        Account acount = [select Id, Name, Onboarded_referrer__c from Account WHERE Id=: accId AND RecordTypeId =: recordTypeId];
        acount.On_Board_Referral__c = true;
        update acount;
        
    }
    
    public static void sendEmail(){
         
        try{
            contact con = [select Id,Email, FirstName, AccountId from contact WHERE Id =: ConId LIMIT 1];
            Account acc = [select id, name from Account WHERE id =: con.AccountId LIMIT 1];
            List<ContentDocumentLink> CDLList = [Select Id,ContentDocumentId from ContentDocumentLink WHERE LinkedEntityId =: accId LIMIT 1];        
            
            Blob b;
            if(CDLList != null){
                if(CDLList.size() > 0){
                    String cdId = CDLList[0].ContentDocumentId;
                    List<ContentVersion> conVerList = [SELECT Id, Title,VersionData FROM ContentVersion WHERE ContentDocumentId = : cdId order by createddate LIMIT 1];
                    b = conVerList[0].VersionData;
                }
            }
            
            
            EmailTemplate emailTemplate = [SELECT Id,Subject, Body FROM EmailTemplate WHERE DeveloperName = 'VOI_referrer_Email' ];
            System.debug('Email template ID::'+emailTemplate);
            //Get templete id for set the templete.
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName('Signed Compliance Documents.pdf');
            efa.setContentType('application/pdf');
            efa.setBody(b);
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            email.setTemplateId(emailTemplate.id);         
            email.setTargetObjectId(con.id);
          	email.setWhatId(acc.id);
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'personalapplications@parkerlane.com.au'];
            if(owea != null){
                if ( owea.size() > 0 ) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
            }
            email.setReplyTo('personalapplications@parkerlane.com.au');
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            email.saveAsActivity = true;
            string[] to = new string[] {con.Id};  
                email.setToAddresses(to);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }catch(Exception ex){
            Exception__c eror = new Exception__c();
            eror.Class_Name__c = 'Digital ID Sign for Referrer';
            eror.Method_Name__c = 'Email sending';
            eror.Error_Message__c = ex.getMessage() + '' + ex.getLineNumber();
            eror.VOI_Detail__c = VOIDetailID();
            insert eror;
        }
    }
    
    
    public static void generateLog(){
        String startTime = Apexpages.currentPage().getParameters().get('startTime');
        String endTime = Apexpages.currentPage().getParameters().get('endTime');
        System.debug('startTime ++'+startTime);
        System.debug('endTime ++'+endTime);
        
        Exception__c eror = new Exception__c();
        eror.Class_Name__c = 'Digital ID Sign';
        eror.Method_Name__c = 'video Upload from page';
        eror.start_time__c = startTime;
        eror.end_time__c = endTime;
        eror.Error_Message__c = message;
        eror.VOI_Detail__c = VOIDetailID();
        eror.Account__c = accId;
        insert eror;
        
        system.debug('id+++'+eror.Id);
    }
    
}