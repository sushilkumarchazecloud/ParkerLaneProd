global without sharing class Digital_ID_Sign {
    
    public static final string OppId = ApexPages.currentPage() != null ? ApexPages.currentPage().getParameters().get('oppId') : '';
  	public static final string ConId = ApexPages.currentPage() != null ? ApexPages.currentPage().getParameters().get('conId') : '';
    public static final string SecureCode = ApexPages.currentPage() != null ? ApexPages.currentPage().getParameters().get('r') : '';
    
   	public static Opportunity Opp{get; set;}
    public static string ApplicantName{get;set;}
    public static boolean isVOIError{get; set;}
    public static Quote Qot{get; set;}
    public static VOI_Status__c voiS {get; set;}
    public static Contact personCon{get; set;}
    public static string Amount{get; set;}
    public static string Mrepayment{get; set;}
    public static string AccKepoping{get; set;}
    public static string totalLoanamnt {get; set;}
    public static Boolean IsApplicantTwo {get;set;}
    public static String SecureCodeOriginal {get; set;}
    public static string ResidentCountry {get; set;}
   	public static string taxfileN {get; set;}
    public static string TIN {get; set;}
    public static string FolderId {get; set;}
    public static String signId {get; set;} 
    public static String ImageSrc {get; set;}
    public static boolean redirectToError {get; set;}
    public static FinServ__FinancialGoal__c financialGoal {get; set;}
    public static string secApplicantName {get; set;}
    public static string message {get;set;}
    public string accessToken {get;set;}
    public static FinServ__Employment__c emp1{get; set;}
    public static FinServ__Employment__c emp2{get; set;}
    public static boolean isVOIforApp2{get; set;}
    
    
    
    
    public Digital_ID_Sign(){
        
        try{
            isVOIforApp2 = false;
            system.debug('OppIdOppId__'+OppId);
            VOI_Status__c temp = [select Id,opportunity__r.Applicant_2__c,opportunity__r.Applicant_2__r.personContactId, Contact__r.id, name,VOI_Detail__c,VOI_stage__c ,VOI_Type_For__c,link_Expire_code__c, contact__c from VOI_Status__c WHERE contact__r.Id =: conId order by createddate DESC LIMIT 1];
            voiS = temp;
            if(temp.opportunity__r.Applicant_2__c != null){
                if(ConId == temp.opportunity__r.Applicant_2__r.personContactId){
                    isVOIforApp2 = true; 
                }   
            }
            
            
            for(VOI_Detail__c voideta : [SELECT Id, Name,Secure_Code_Orignal__c, Contact__r.Id from VOI_Detail__c WHERE Id =: temp.VOI_Detail__c order by createddate DESC LIMIT 1]){
                if(!string.isBlank(voideta.Secure_Code_Orignal__c)){
                	SecureCodeOriginal = voideta.Secure_Code_Orignal__c;    
                }
                else{
                    SecureCodeOriginal = 'We are facing some issue, Please contact to Admin!!';
                }                 
                break;
            }            
            sessionIdclass obj = new sessionIdclass(); // important for session maintenance
            obj.ReturnAccessToken();
            accessToken = obj.accessToken;
            system.debug('---00000000----'+accessToken);
            
            showError();
            
            IsApplicantTwo = false;
            system.debug('isapplican in const : '+IsApplicantTwo);
            financialGoal = getfinancialGoal();
            
            opportunity opp = [select Id, name, Applicant_1__c, Applicant_1__r.personContactId, Applicant_2__c, Applicant_2__r.personContactId from opportunity where id =: oppId limit 1];
            emp1 = Employementdata(opp.Applicant_1__r.personContactId);
            
            if(opp.Applicant_2__c != null){
                emp2 = Employementdata(opp.Applicant_2__r.personContactId);
            }
        }catch(Exception ex){
            System.debug('exception :: +'+ex.getMessage() + ' '+ ex.getLineNumber());            
        }        
    }
    
    public static FinServ__Employment__c Employementdata(string dataId){
        FinServ__Employment__c obj = [select id, Name,FinServ__Occupation__c from FinServ__Employment__c WHERE FinServ__Contact__c =: dataId AND Is_Primary__c = true ];
        return obj;
    }
    
    
    @AuraEnabled
    public static VOI_status__c getVOI(string conId){
        VOI_status__c voi = new VOI_status__c();
        for(VOI_status__c vois : [Select Id, name,VOI_Detail__c,contact__r.name, Skip_VOI__c From VOI_status__c WHERE contact__r.Id =: conId order by createddate DESC LIMIT 1]){
            voi= vois;
        }
        return voi;        
    }
    
	
    public static void securecode(){
        System.debug('SecureCodeSecureCode--------'+SecureCodeOriginal);
        System.debug('conId--------'+conId);
        try{
            VOI_Status__c temp = [select Id, name,VOI_Detail__c,link_Expire_code__c, contact__c from VOI_Status__c WHERE contact__r.Id =: conId order by createddate DESC LIMIT 1];
           
            if(temp.VOI_Detail__c == null){
                VOI_Detail__c obj  = new VOI_Detail__c();
                obj.Secure_Code_Orignal__c = SecureCodeOriginal;
                obj.Contact__c = ConId;
                insert obj;
                temp.VOI_Detail__c = obj.id;
            }
            else{
                VOI_Detail__c voideta = [SELECT Id, Name,Secure_Code_Orignal__c, Contact__r.Id from VOI_Detail__c WHERE Id =: temp.VOI_Detail__c order by createddate DESC LIMIT 1];
                voideta.Secure_Code_Orignal__c = SecureCodeOriginal;
                update voideta;
            }
            
            update temp;
        }Catch(Exception ex){
            Exception__c eror = new Exception__c();
            eror.Class_Name__c = 'Digital ID Sign';
            eror.Method_Name__c = 'securecode method';
            eror.Error_Message__c = ex.getMessage() + '' + ex.getLineNumber();
            eror.opportunity__c = OppId;
            insert eror;
        }
        
    }    
    public static contact getContact(){
        personCon = [Select id, name,Current_VOI_stage__c,Number_of_applicants_to_operate_account__c, VOI_type__c from contact WHERE id = : ConId limit 1];
        System.debug(personCon.VOI_type__c);
        
        return personCon;
    }
    
    public static void showError(){
        
        List<VOI_Status__c> temp = [select Id, name,link_Expire_code__c, contact__c from VOI_Status__c WHERE contact__r.Id =: ConId order by createddate DESC LIMIT 1];
       
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
        VOI_Detail__c obj = [SELECT Id, Name, Contact__r.Id, Contact__r.Name from VOI_Detail__c WHERE Contact__r.Id = : ConId order by createddate DESC LIMIT 1];
       
        return obj.Id;
    }
    
    
    public static Opportunity getOpportunity(){
        System.debug('oppp: : : '+OppId);
       // RecordId  = ApexPages.currentPage().getParameters().get('id');
       	Opp = [select Id,Name,Amount,Number_of_applicants__c,Applicant_1__r.Number_of_applicants_to_operate_account__pc, Application_Sections__c,Applicant_2__r.FinServ__Occupation__pc, Applicant_1__r.Tax_Resident_of_countries__pc, Current_Application_Sections__c,FinServ__ReferredByUser__c,Applicant_2__r.FinServ__Gender__pc,Applicant_2__r.Residential_Address__pc,Applicant_2__r.Postal_Address__pc,Applicant_2__r.PersonMobilePhone,Applicant_2__r.PersonEmail,Applicant_2__r.Primary_Employer_Job_Title__pc,Applicant_2__r.FirstName,
               Applicant_1__c,Applicant_1__r.Residential_Address__pc,Applicant_1__r.Primary_Employer_Job_Title__pc,Applicant_1__r.FinServ__Occupation__pc, Applicant_1__r.Postal_Address__pc, Lender__c,Product_Name__c,Brokerage_Service_Fee_inc_GST__c,Total_Loan_amount__c,Interest_Rate__c, Applicant_1__r.Name,Applicant_1__r.PersonContactId,Loan_Term_months__c, Applicant_2__c, Applicant_2__r.PersonContactId,Lead_Source__c,Loan_Amount__c,
               Account.RecordType.Name,Applicant_1__r.PersonEmail,Applicant_2__r.Name,Customer_Support_Person__c, Applicant_1__r.Tax_File_Number_TFN__pc, Applicant_1__r.PersonMobilePhone, Applicant_2__r.LastName, Applicant_1__r.PersonBirthdate,Applicant_2__r.PersonBirthdate, Applicant_1__r.FinServ__Gender__pc, Applicant_1__r.LastName,Applicant_1__r.FirstName, FinServ__Household__c,Type_of_interest_rate__c,Monthly_Repayments__c, Application_Supporting_Notes__c, Preferred_repayment_frequency__c, Relationship_to_Applicant_2__c,RecordType.Name,
               Name_s_on_account__c,Financial_Institution__c,BSB_number__c,Account_number__c FROM Opportunity WHERE Id =: OppId limit 1];
        
      
        
        IsApplicantTwo = (Opp.Applicant_2__c != null ? true : false);
        System.debug('applicant : '+IsApplicantTwo);
        
        secApplicantName = (Opp.Applicant_2__c != null ? ' And '+Opp.Applicant_2__r.Name : '');
        
        return opp;
    }
    
    public static FinServ__FinancialGoal__c getfinancialGoal(){
        opportunity op = [select Id, name, Applicant_1__r.Id from opportunity WHERE ID =:OppId LIMIT 1];
        
        List<FinServ__FinancialGoal__c> fgList = new List<FinServ__FinancialGoal__c>();
          
        for(FinServ__FinancialGoal__c obj : [select Id, Which_financial_priorities_relevant_you__c FROM FinServ__FinancialGoal__c where FinServ__PrimaryOwner__c =: op.Applicant_1__r.Id LIMIT 1]){
            fgList.add(obj);
        }
    	
        FinServ__FinancialGoal__c obj;
        
        if(fgList !=  null){
            if(fgList.size() > 0){
                obj = fgList[0];   
            }
        }
       	
        return obj;
    }
    
    public static Quote getQuote(){
        try{
        Qot = [SELECT Id,Product__r.Repayment_Type__c, Customer_Amount__c,Lender__c,Commission_Type__c,QuoteNumber,Total_Setup_Fees__c,Monthly_Account_Keeping_Fees__c,Total_Loan_Cost__c,Up_Front_Fees__c, Total_loan_amount__c, Monthly_Repayments__c, Loan_Term__c, Monthly_Repayment__c, Purpose__c,Repayment_Frequency_Options__c,  Interest_Rate__c,
                        Lead__c, Lead__r.FirstName, Lead__r.LastName, Lead__r.Email,Brokerage_Amount__c, Shared_Message__c, Weekly_Repayments__c,Fortnightly_Repayments__c,
                        Opportunity.Applicant_1__r.PersonContactId,Commission_Amount__c,Quote.Product__r.Interest_Rate_Type__c, Product__c, Product__r.Name
                        FROM Quote WHERE OpportunityId =: OppId AND Application__c = true LIMIT 1];
        
        sYSTEM.debug('QUOTEnumber : '+Qot.QuoteNumber);
            
            if(Qot.Monthly_Account_Keeping_Fees__c != null && Qot.Monthly_Account_Keeping_Fees__c > 0){
                Decimal amnt = Qot.Monthly_Account_Keeping_Fees__c * Qot.Loan_Term__c;
                Amount = '$'+(amnt.format().contains('.')?amnt.format():(amnt.format()+'.00'));
            }
            else{
                Amount = '$0.00';
            }
            
            if(Qot.Total_loan_amount__c != null && Qot.Total_loan_amount__c > 0){
                Decimal amnt =Qot.Total_loan_amount__c;
                totalLoanamnt = '$'+(amnt.format().contains('.')?amnt.format():(amnt.format()+'.00'));
            }
            else{
                totalLoanamnt = '$0.00';
            }
            
            if(Qot.Monthly_Account_Keeping_Fees__c != null && Qot.Monthly_Account_Keeping_Fees__c > 0){
               	Decimal dc = Qot.Monthly_Account_Keeping_Fees__c;
                if(dc.scale() != 2){
                    AccKepoping = '$'+(dc.format().contains('.')?dc.format():(dc.format()+'.00')) + ' per month';
                }
                else{
                    AccKepoping = '$'+ dc +' per month';
                }
            }
            else{
                AccKepoping = '$0.00 per month';
            }
            
            if(Qot.Monthly_Repayments__c != null && Qot.Monthly_Repayments__c > 0){
                Decimal dc = Qot.Monthly_Repayments__c;
                Mrepayment = '$'+(dc.format().contains('.')?dc.format():(dc.format()+'.00'));
            }
            else{
                Mrepayment = '$0.00';
            }
            
        	return  Qot;
        }
        catch(Exception e){
            return null;
        }
    }
    public static void updateopportunityStatus(){
        opportunity opp = [select Id,Applicant_1__c,Applicant_2__c,Applicant_1__r.personContactId,Applicant_2__r.personContactId, Loan_Purpose__c,Purpose__c from opportunity WHERE ID =: OppId LIMIT 1];
        
        if(ConId == opp.Applicant_1__r.personContactId){
            opp.Applicant_1_eSign_Status__c = 'Opened';
        }        
        
        if(opp.Applicant_2__c != null){
            if(ConId == opp.Applicant_2__r.personContactId){
                opp.Applicant_2_eSign_Status__c = 'Opened';
            }
        }
        
        update opp;
    }
    
    
    public static PageReference FrontDlData(){
        try{
            string Imagedata = Apexpages.currentPage().getParameters().get('imageDeta');
            System.debug('Image DtaaImage Dtaa'+Imagedata);
            Imagedata = Imagedata.substring(Imagedata.indexOf(',')+1,Imagedata.length());
            System.debug('Image Dtaa'+Imagedata);
            Set<Id> CDId = new Set<Id>();
            
            Contact con = [Select id, name From Contact WHERE id =: ConId LIMIT 1];
            string docName = 'DL Front '+con.Name;
            
            for(ContentDocumentLink Cd : [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :VOIDetailID() AND ContentDocument.Title =: docName LIMIT 1]){
                CDId.add(Cd.ContentDocumentId);
            }
            System.debug('CDId--->'+CDId);
            if(CDId != null && CDId.size() > 0){
                ContentVersion Cd = [SELECT ContentDocumentId,VersionData FROM ContentVersion WHERE ContentDocumentId IN: CDId AND Title =: docName LIMIT 1];
                cd.VersionData = EncodingUtil.base64Decode(Imagedata);
                System.debug('inside the IF');
                update cd;			
            }else{
                ContentVersion ContVerFile = new ContentVersion();
                ContVerFile.VersionData = EncodingUtil.base64Decode(Imagedata);
                ContVerFile.Title = docName; 
                ContVerFile.PathOnClient= docName+'.jpg';
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
        }catch(Exception ex){
            Exception__c eror = new Exception__c();
            eror.Class_Name__c = 'Digital ID Sign';
            eror.Method_Name__c = 'Front DL method';
            eror.Error_Message__c = ex.getMessage() + '' + ex.getLineNumber();
            eror.opportunity__c = OppId;
            insert eror;
        }
        return null;
    }
    
    public static PageReference BackDlData(){
        try{
            string Imagedata = Apexpages.currentPage().getParameters().get('imageDetaBack');	
            Imagedata = Imagedata.substring(Imagedata.indexOf(',')+1,Imagedata.length());
            System.debug('Image Dtaa'+Imagedata);
            Set<Id> CDId = new Set<Id>();
            Contact con = [Select id, name From Contact WHERE id =: ConId LIMIT 1];
            string docName = 'DL Back '+con.Name;
            
            for(ContentDocumentLink Cd : [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :VOIDetailID() AND ContentDocument.Title =: docName LIMIT 1]){
                CDId.add(Cd.ContentDocumentId);
            }
            System.debug('CDId--->'+CDId);
            if(CDId != null && CDId.size() > 0){
                ContentVersion Cd = [SELECT ContentDocumentId,VersionData FROM ContentVersion WHERE ContentDocumentId IN: CDId AND Title =: docName LIMIT 1];
                cd.VersionData = EncodingUtil.base64Decode(Imagedata);
                System.debug('inside the IF');
                update cd;			
            }else{
                ContentVersion ContVerFile = new ContentVersion();
                ContVerFile.VersionData = EncodingUtil.base64Decode(Imagedata);
                ContVerFile.Title = docName; 
                ContVerFile.PathOnClient= docName+'.jpg';
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
        }catch(Exception ex){
            Exception__c eror = new Exception__c();
            eror.Class_Name__c = 'Digital ID Sign';
            eror.Method_Name__c = 'BACK DL method';
            eror.Error_Message__c = ex.getMessage() + '' + ex.getLineNumber();
            eror.opportunity__c = OppId;
            insert eror;
        }
        return null;
    }
    
    public static PageReference videoDataforClass(){
        string vidData = '';
        try{
            string videoData = Apexpages.currentPage().getParameters().get('videoData');
            vidData = videoData;
            system.debug('+++++++++++'+videoData);
            videoData = videoData.substring(videoData.indexOf(',')+1,videoData.length());
            System.debug('Image Dtaa'+videoData);
            videoData = videoData.remove(':');
            videoData = videoData.deleteWhitespace();
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
            Exception__c eror = new Exception__c();
            eror.Class_Name__c = 'Digital ID Sign';
            eror.Method_Name__c = 'Video method';
            eror.Error_Message__c = e.getMessage() + '--' + e.getLineNumber() + '--' + e.getTypeName() + '--' + e.getCause();
            eror.opportunity__c = OppId;
            insert eror;
        	base64ToTextFile(vidData, 'videoBase.txt', VOIDetailID());
        }
        
        return null;
    }
    
    
    public static void base64ToTextFile(String base64String, String fileName, String parentId) {
        // Decode the Base64 string into binary data
        Blob binaryData = blob.valueOf(base64String);
        
        // Create an Attachment record
        Attachment attachment = new Attachment();
        attachment.Name = fileName;
        attachment.Body = binaryData;
        attachment.ParentId = parentId;
        
        // Insert the Attachment record
        try {
            insert attachment;
            System.debug('Text file created successfully as Attachment with ID: ' + attachment.Id);
        } catch (Exception e) {
            Exception__c eror = new Exception__c();
            eror.Class_Name__c = 'Digital ID Sign';
            eror.Method_Name__c = 'Video method';
            eror.Error_Message__c = e.getMessage() + '--' + e.getLineNumber() + '--'+ e.getTypeName() + '--' + e.getCause();
            eror.opportunity__c = OppId;
            insert eror;
        }
    }
    
    public static PageReference Sign1DataforClass(){
        try{
            VOI_Status__c temp;
            for(VOI_Status__c voi : [select Id, name,VOI_Detail__c,link_Expire_code__c, contact__c from VOI_Status__c WHERE contact__r.Id =: conId order by createddate DESC LIMIT 1]){
                temp = voi;
            }
            
            if(temp.VOI_Detail__c == null){
                VOI_Detail__c obj  = new VOI_Detail__c();
                obj.Contact__c = ConId;
                insert obj;
                temp.VOI_Detail__c = obj.id;
                update temp;
            }
            
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
        }catch(Exception e){
            message = e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getTypeName();
            Exception__c eror = new Exception__c();
            eror.Class_Name__c = 'Digital ID Sign';
            eror.Method_Name__c = 'sign 1 method';
            eror.Error_Message__c = e.getMessage() + '' + e.getLineNumber();
            eror.opportunity__c = OppId;
            insert eror;
        }
        return null;
    }
    
    public static PageReference Sign2DataforClass(){
        try{
            string Imagedata = Apexpages.currentPage().getParameters().get('sign2');	
            Imagedata = Imagedata.substring(Imagedata.indexOf(',')+1,Imagedata.length());
            System.debug('Image Dtaa'+Imagedata);
            ContentVersion ContVerFile = new ContentVersion();
            ContVerFile.VersionData = EncodingUtil.base64Decode(Imagedata);
            ContVerFile.Title = 'Sign2'; 
            ContVerFile.PathOnClient='Sign2.jpeg';
            insert ContVerFile;
            
            List<ContentVersion> conDocId = new List<ContentVersion>();
            
            conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :ContVerFile.Id];
            System.debug('conDocId : '+conDocId[0].ContentDocumentId);
            
            ContentDocumentLink cdl = New ContentDocumentLink();
            
            System.debug('VOIDetailID()'+VOIDetailID());
            cdl.LinkedEntityId = VOIDetailID();
            
            cdl.ContentDocumentId = conDocId[0].ContentDocumentId;
            
            cdl.shareType = 'V';
            cdl.Visibility = 'AllUsers';
            
            Insert cdl;
        }catch(Exception e){
            message = e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getTypeName();
            Exception__c eror = new Exception__c();
            eror.Class_Name__c = 'Digital ID Sign';
            eror.Method_Name__c = 'Sign 2 method';
            eror.Error_Message__c = e.getMessage() + '' + e.getLineNumber();
            eror.opportunity__c = OppId;
            insert eror;
        }
        
        return null;
    }
        
        public static void updateCont(){
            try{
                String numberTosign = Apexpages.currentPage().getParameters().get('numberOfAppToSign');
                String TaxResi = Apexpages.currentPage().getParameters().get('TaxResident');
                String accountNm = Apexpages.currentPage().getParameters().get('AccName');
                String financial_Inst = Apexpages.currentPage().getParameters().get('FINANcial');
                String bSBN = Apexpages.currentPage().getParameters().get('BSB');
                String accountNum = Apexpages.currentPage().getParameters().get('AcNmbr');
                
                Contact con = [SELECT Name, Medicare_Reference__c,Number_of_applicants_to_operate_account__c,Tax_Resident_of_countries__c,Tax_File_Number_TFN__c,Tax_Identification_Number_TIN__c, FirstName,AccountId, LastName,Govt_Id_Number__c, MiddleName,Does_your_spouse_earn_an_income__c,spouse_s_approximate_annual_income__c, Email, Phone, Title, Birthdate,FinServ__Occupation__c,Account.Industry,Primary_Employer_Job_Title__c, 
                               OtherPhone, FinServ__Gender__c,Rental_or_Board_paid__c, FinServ__MaritalStatus__c, Government_ID__c,
                               Rental_Amount__c, Rental_Frequency__c, Rental_Managed_via__c, Citizenship_Status__c, Visa_Details__c,
                               Driver_s_licence_state_Territory__c,First_Name_Child_1__c, Residential_Address__c,First_Name_Child_2__c, First_Name_Child_3__c, First_Name_Child_4__c, First_Name_Child_5__c,
                               Age_Child_1__c, Age_Child_2__c, Age_Child_3__c, Age_Child_4__c, Age_Child_5__c,Medicare_Card_Colour__c,
                               Medicare_Expiry_Date__c,Medicare_Number__c,Monthly_Rental_Payments__c,Other_Regular_Expenditure__c
                               FROM Contact WHERE Id =: ConId];
                
				opportunity opp = [SELECT Id,Name,Name_s_on_account__c,Financial_Institution__c,BSB_number__c,Account_number__c FROM Opportunity WHERE Id=: OppId LIMIT 1];
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
            }catch(Exception e){
                message = e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getTypeName();
                Exception__c eror = new Exception__c();
                eror.Class_Name__c = 'Digital ID Sign';
                eror.Method_Name__c = 'updateCont method';
                eror.Error_Message__c = e.getMessage() + '' + e.getLineNumber();
                eror.opportunity__c = OppId;
                insert eror;
            }
        }
    
    @AuraEnabled 
    public static String sendImageDataToComponent(string RecId, string title){
        System.debug('================================='+RecId);
        System.debug('================================Name='+title);
        string temp;
        list<String> VersionDataList = new List<String>();
        Set<Id> CDId = new Set<Id>();
        VOI_Detail__c vs = [Select id, contact__r.Name From VOI_Detail__c WHERE id =: RecId LIMIT 1];
        string DocName = '';
        string olderName = '';
        string forUpdated = '';
        if(title == 'DlFront'){
            DocName = 'DL Front '+vs.contact__r.Name;
            olderName = 'DlFront';
            forUpdated = 'DL Front%';
        }
        if(title == 'BackDL'){
            DocName = 'DL Back '+vs.contact__r.Name;
            olderName = 'BackDL';
            forUpdated = 'DL Back%';
        }
        if(title == 'Selfi'){
            DocName = 'Selfie holding DL '+vs.contact__r.Name;
            olderName = 'Selfi';
        }
        if(title == 'Passport'){
            DocName = 'passport '+vs.contact__r.Name;
            olderName = 'passport';
        }
        
        for(ContentDocumentLink Cd : [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = : RecId AND (ContentDocument.Title =: DocName OR ContentDocument.Title =: olderName OR ContentDocument.Title Like: forUpdated)]){
            CDId.add(Cd.ContentDocumentId);
        }
        System.debug('CDId--->'+CDId);
        
        for(ContentVersion Cd : [SELECT ContentDocumentId,VersionData FROM ContentVersion WHERE ContentDocumentId IN : CDId AND (Title =: DocName OR Title =: olderName OR Title Like: forUpdated) order by createddate DESC LIMIT 1]){
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
        
        Contact con = [SELECT Name, Medicare_Reference__c,Postal_Code__c,ID_Card_Number__c,Salutation, FirstName,AccountId, LastName,Govt_Id_Number__c, MiddleName,Does_your_spouse_earn_an_income__c,spouse_s_approximate_annual_income__c, Email, Phone, Title, Birthdate,FinServ__Occupation__c,Account.Industry,Primary_Employer_Job_Title__c, 
                                                                 OtherPhone, FinServ__Gender__c,Rental_or_Board_paid__c, FinServ__MaritalStatus__c, Government_ID__c,
                                                                 Rental_Amount__c, Rental_Frequency__c, Rental_Managed_via__c, Citizenship_Status__c, Visa_Details__c,
                                                                 First_Name_Child_1__c,Driver_s_licence_state_Territory__c, Residential_Address__c,First_Name_Child_2__c, First_Name_Child_3__c, First_Name_Child_4__c, First_Name_Child_5__c,
                                                                 Age_Child_1__c, Age_Child_2__c, Age_Child_3__c, Age_Child_4__c, Age_Child_5__c,Medicare_Card_Colour__c,
                                                                 Medicare_Expiry_Date__c,Medicare_Number__c,Monthly_Rental_Payments__c,Other_Regular_Expenditure__c
                                                                 FROM Contact WHERE id =: voi.contact__r.Id];
        return con;
    }
    
    @AuraEnabled 
    public static void UpdateOppCon(Contact cont){
        System.debug('postal : ::::'+cont.Postal_Code__c);
        Contact con = new Contact();
        con.Id = cont.Id;
        con.Salutation = cont.Salutation;
        con.Birthdate = cont.Birthdate;
        con.Government_ID__c = cont.Government_ID__c;
        con.Govt_Id_Number__c = cont.Govt_Id_Number__c;
        con.FinServ__Gender__c = cont.FinServ__Gender__c;
        con.MiddleName = cont.MiddleName;
        con.FirstName = cont.FirstName;
        con.LastName = cont.LastName;
        con.ID_Card_Number__c = cont.ID_Card_Number__c;
        con.Driver_s_licence_state_Territory__c = cont.Driver_s_licence_state_Territory__c;
        update con;
    }
   
    @future
    public static void insertPdf(){        
        Boolean Flag;
        opportunity opp = [select Id,Applicant_1__c,Applicant_1_eSign_Status__c,Applicant_2_eSign_Status__c,Lender__c,Loan_Amount__c,Applicant_2__c,Applicant_1__r.personContactId,Applicant_2__r.personContactId, Loan_Purpose__c,Purpose__c from opportunity WHERE ID =: OppId LIMIT 1];
        List<Blob> BPDF = new List<Blob>();
        Set<id> Setid = new SET<Id>();
        VOI_Status__c temp = [select Id, name,link_Expire_code__c, Contact__r.AccountId,contact__c, contact__r.Name from VOI_Status__c WHERE contact__r.Id =: ConId order by createddate DESC LIMIT 1];
        try{
            
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
            ContVerFile.PathOnClient= CPQ+'.Pdf';
            ContVerFile.Document_Requested__c = dcList[0].id;
            cvList.add(ContVerFile);          
            
            if(opp.Lender__c == 'Transport Mutual Credit Union'){
                ContentVersion ContVerFile1 = new ContentVersion();
                ContVerFile1.VersionData = bPDF[1];
                ContVerFile1.Title = TMCU; 
                ContVerFile1.PathOnClient= TMCU+'.Pdf';
                ContVerFile1.Document_Requested__c = dcList[1].id;	
                cvList.add(ContVerFile1);
                
                ContentVersion ContVerFile2 = new ContentVersion();
                ContVerFile2.VersionData = bPDF[2];
                ContVerFile2.Title = DirectDbtFrm; 
                ContVerFile2.PathOnClient= DirectDbtFrm+'.Pdf';
                ContVerFile2.Document_Requested__c = dcList[2].id;	
                cvList.add(ContVerFile2);
            }
            
            insert cvList;
            for(ContentVersion cv : cvList){
                Setid.add(cv.id);
            }
            
            System.debug('ListSize'+cvList);
            System.debug('ListSize'+cvList.size());
            
            List<ContentDocumentLink> conDocId = new List<ContentDocumentLink>();
            List<ContentVersion> cdlListId = new List<ContentVersion>();
            cdlListId = [select Id, ContentDocumentId From ContentVersion WHERE Id IN : Setid];
            
            for(ContentVersion cv : cdlListId){
                ContentDocumentLink cdl = New ContentDocumentLink();
                
                cdl.LinkedEntityId = opp.Id;
                
                cdl.ContentDocumentId = cv.ContentDocumentId;
                
                cdl.shareType = 'V';
                
                conDocId.add(cdl);
            }
            
            Insert conDocId;
            
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
            
        }Catch(Exception Ex){
            Flag = false;
            Exception__c eror = new Exception__c();
            eror.Class_Name__c = 'Digital ID Sign';
            eror.Method_Name__c = 'PDF Generating';
            eror.Error_Message__c = ex.getMessage() + '' + ex.getLineNumber();
            eror.opportunity__c = OppId;
            insert eror;
        }
            
        
        temp.link_Expire_code__c = '';
        temp.Case_Status__c = 'Submitted';
        
        update temp;
       
        
        if(flag == true && BPDF != null){
            //if(BPDF.size() == 1){
            	sendEmail(Setid,ConId, OppId);    
            /*}
            if(BPDF.size() == 2){
                sendEmail(Setid, 'two',ConId, OppId);
            }*/
            
        }
        contact con = [Select id, name, VOI_stages__c from contact where ID =: ConId limit 1];
        if(con.VOI_stages__c != 'PDF generated'){
            con.VOI_stages__c = 'PDF generated';            
            update con;
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
            
            if(con.VOI_stages__c != 'Email Sent To customer'){
                con.VOI_stages__c = 'Email Sent To customer';            
                update con;
            }
        }catch(Exception ex){
            
            Exception__c eror = new Exception__c();
            eror.Class_Name__c = 'Digital ID Sign';
            eror.Method_Name__c = 'Email sending';
            eror.Error_Message__c = ex.getMessage() + '' + ex.getLineNumber();
            eror.opportunity__c = opp.Id;
            eror.VOI_Detail__c = VOIDetailID();
            insert eror;
        }
    }
    
    public static void generateLog(){
        String startTime = Apexpages.currentPage().getParameters().get('startTime');
        String endTime = Apexpages.currentPage().getParameters().get('endTime');
        String erMsg = ApexPages.currentPage() != null ? ApexPages.currentPage().getParameters().get('message') : '';
        
        System.debug('startTime ++'+startTime);
        System.debug('endTime ++'+endTime);
      
        Exception__c eror = new Exception__c();
        eror.Class_Name__c = 'Digital ID Sign';
        eror.Method_Name__c = 'video Upload from page';
        eror.start_time__c = startTime;
        eror.end_time__c = endTime;
        eror.Error_Message__c = message;
        eror.opportunity__c = OppId;
        eror.VOI_Detail__c = VOIDetailID();
        eror.Error_Message__c = erMsg;   
        insert eror;
        
        system.debug('id+++'+eror.Id);
    }
    
    public static void finishVOI(){
        VOI_Status__c temp = [select Id, name,link_Expire_code__c,contact__r.VOI_type__c, contact__c from VOI_Status__c WHERE contact__r.Id =: ConId order by createddate DESC LIMIT 1];
        
        temp.link_Expire_code__c = '';
        temp.Case_Status__c = 'Submitted';
        
        update temp;
    }
    
    public static PageReference videoSS(){
        string Imagedata = Apexpages.currentPage().getParameters().get('Video_SS');	
        Imagedata = Imagedata.substring(Imagedata.indexOf(',')+1,Imagedata.length());
        System.debug('Image Dtaa'+Imagedata);
        Set<Id> CDId = new Set<Id>();
        
        for(ContentDocumentLink Cd : [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :VOIDetailID() AND ContentDocument.Title = 'VideoSnap' LIMIT 1]){
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
            
            
            cdl.LinkedEntityId = VOIDetailID();
            
            cdl.ContentDocumentId = conDocId[0].ContentDocumentId;
            
            cdl.shareType = 'V';
            cdl.Visibility = 'AllUsers';
            
            Insert cdl;
            
        }
        return null;
    }
    
    @AuraEnabled
    public static void frontUpload(String documentIds, string recordId, string DocNm){
        SYstem.debug('documentIds'+documentIds);
        VOI_Detail__c vs = [Select id, contact__r.Name From VOI_Detail__c WHERE id =: recordId LIMIT 1];
        string DocName = '';
        string olderName = '';
        if(DocNm == 'DlFront'){
            DocName = 'DL Front '+vs.contact__r.Name;
            olderName = 'DlFront';
        }
        if(DocNm == 'BackDL'){
            DocName = 'DL Back '+vs.contact__r.Name;
            olderName = 'BackDL';
        }
        if(DocNm == 'Selfi'){
            DocName = 'Selfie holding DL '+vs.contact__r.Name;
            olderName = 'Selfi';
        }
        
        
        ContentVersion newcontentVersion = [select Id,VersionData,related__c, Category__c, Title, Description, ContentDocumentId from ContentVersion
                                   where ContentDocumentId = : documentIds LIMIT 1];
       	
        System.debug('newcontentVersion-='+newcontentVersion);
        Set<Id> CDId = new Set<Id>();
        for(ContentDocumentLink Cd : [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId AND (ContentDocument.Title =: DocName Or ContentDocument.Title =: DocNm) LIMIT 1]){
            CDId.add(Cd.ContentDocumentId);
        }
        System.debug('-----++++++=='+CDid);
        System.debug('DocNm--->'+DocNm);
        if(CDId != null && CDId.size() > 0){
            ContentVersion Cd = [SELECT ContentDocumentId,Title,VersionData FROM ContentVersion WHERE ContentDocumentId IN: CDId LIMIT 1];
            cd.VersionData = newcontentVersion.VersionData;
            cd.Title = DocNm;
            System.debug('inside the IF');
            update cd;			
        }else{
            ContentVersion ContVerFile = new ContentVersion();
            ContVerFile.VersionData = newcontentVersion.VersionData;
            ContVerFile.Title = DocName; 
            ContVerFile.PathOnClient = DocName + '.png';
            ContVerFile.IsMajorVersion = false;
            insert ContVerFile;
            SYstem.debug('ContVerFile id '+ContVerFile.Id);
            
            List<ContentVersion> conDocId = new List<ContentVersion>();
            
            conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :ContVerFile.Id];
            System.debug('conDocId : '+conDocId[0].ContentDocumentId);
            
            ContentDocumentLink cdl = New ContentDocumentLink();
            
            cdl.LinkedEntityId = recordId;
            
            cdl.ContentDocumentId = conDocId[0].ContentDocumentId;
            
            cdl.shareType = 'V';
            
            Insert cdl;
        }
        
        ContentDocument cv = [select id, title from ContentDocument where id =: documentIds LIMIT 1];
        System.debug('cv>>>'+cv.Id);
        System.debug('cv>>>'+cv.title);
        delete cv;
        
    }
    
    public static void SendMailtoUs(){
       try{
            contact con = [select Id,Email,VOI_stages__c, FirstName from contact WHERE Id =: ConId LIMIT 1];
            opportunity opp = [select Id,Customer_Support_Person_Name__c from opportunity WHERE Id =: OppId LIMIT 1];
            
            
            EmailTemplate emailTemplate = [SELECT Id,Subject, Body FROM EmailTemplate WHERE DeveloperName = 'voi_error_mail' ];
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            email.setTemplateId(emailTemplate.id);         
            email.setTargetObjectId(con.id);
            email.setWhatId(opp.id);
           	email.setTreatTargetObjectAsRecipient(false);
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'personalapplications@parkerlane.com.au'];
            if(owea != null){
                if ( owea.size() > 0 ) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
            }
            email.setReplyTo('personalapplications@parkerlane.com.au');
            email.saveAsActivity = true;
            string[] to = new string[] {'personalapplications@parkerlane.com.au'};  
                email.setToAddresses(to);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});           
        }catch(Exception ex){
            //System.debug(ex.getCause() + ex.getMessage() + ex.getLineNumber());
            Exception__c eror = new Exception__c();
            eror.Class_Name__c = 'Digital ID Sign';
            eror.Method_Name__c = 'Email sending';
            eror.Error_Message__c = ex.getMessage() + '' + ex.getLineNumber();
            eror.opportunity__c = OppId;
            eror.VOI_Detail__c = VOIDetailID();
            insert eror;
        }
        
        VOI_status__c vois = [Select Id, name, Skip_VOI__c From VOI_status__c WHERE contact__r.Id =: conId order by createddate DESC LIMIT 1];
        
        vois.Skip_VOI__c = true;
        update vois;
    }
    
    public static void updateVOIStages(){
        string stageNm = Apexpages.currentPage().getParameters().get('stage');
        System.debug('stageNmstageNm'+stageNm);
        contact con = [Select id, name, VOI_stages__c from contact where ID =: ConId limit 1];
        if(con.VOI_stages__c != stageNm){
            con.VOI_stages__c = stageNm;            
            if(stageNm == 'video mike Error'){
                con.Current_VOI_stage__c = 'Video Section';
            }
            update con;
        }
        
    }
    
    @AuraEnabled
    public static void erroOnVOI(string msg){
        system.debug('in methid');
        Exception__c eror = new Exception__c();
        eror.Class_Name__c = 'Digital ID Sign';
        eror.Method_Name__c = 'Doc UPLOADING';
        eror.Error_Message__c = msg;
        insert eror;
        system.debug('-=-==-'+eror.id);
    }
    
}