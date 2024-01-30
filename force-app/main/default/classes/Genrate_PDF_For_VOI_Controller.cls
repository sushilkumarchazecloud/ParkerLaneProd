public class Genrate_PDF_For_VOI_Controller {
   
    public static final string  OppId = ApexPages.currentPage().getParameters().get('OppId');
    public static final string ConId = ApexPages.currentPage().getParameters().get('ConId');
    public static Opportunity Opp {get; set;}
    public static string Amount{get; set;}
    public static decimal amt{get; set;}
    public static Quote Qot {get; set;}
    public static Boolean IsApplicantTwo {get;set;}
    public static String signId {get; set;} 
    public static string ImageSrc {get; set;} 
    public static imageWrapper imgWrap{get;set;}
    public static FinServ__FinancialGoal__c financialGoal {get; set;}
    public static string secApplicantName {get; set;}
    public static string Mrepayment{get; set;}
    public static string AccKepoping{get; set;}
    public static string totalLoanamnt {get; set;}
    public static FinServ__Employment__c emp1{get; set;}
    public static FinServ__Employment__c emp2{get; set;}
    public static Boolean isApp2{get; set;} 
    public static string appOneAddress{get; set;}
    public static string appTwoAddress{get; set;}
    
    public Genrate_PDF_For_VOI_Controller(){
        isApp2 = false;
        financialGoal = getfinancialGoal();
        opportunity opp = [select Id, name, Applicant_1__c, Applicant_1__r.personContactId, Applicant_2__c, Applicant_2__r.personContactId from opportunity where id =: oppId limit 1];
        emp1 = Employementdata(opp.Applicant_1__r.personContactId);
        if(opp.Applicant_2__c != null &&  ConId == opp.Applicant_2__r.PersonContactId){
            isApp2 = true;
        }
        if(opp.Applicant_2__c != null){
            emp2 = Employementdata(opp.Applicant_2__r.personContactId);
        }
    }
	
    
    public static FinServ__Employment__c Employementdata(string dataId){
        try{
        	FinServ__Employment__c obj = [select id,Job_Title__c, Name,FinServ__Occupation__c from FinServ__Employment__c WHERE FinServ__Contact__c =: dataId AND Is_Primary__c = true ];
        	return obj;
        }catch(Exception ex){
            System.debug('exception : '+ex);	
        	return null;
        }
    }
    
    
    
    public static Opportunity getOpportunity(){
        // RecordId  = ApexPages.currentPage().getParameters().get('id');
        Opp = [select Id,Applicant_1__r.MiddleName,Applicant_2__r.MiddleName,Applicant_1__r.Postal_Code__pc,Applicant_1__r.Salutation,Applicant_2__r.Salutation,Applicant_2__r.Postal_Code__pc,Name,Referral_Fee_inc_GST__c,Referral_Fee_Recipient__r.Name,Amount,Number_of_applicants__c,Name_s_on_account__c,BSB_number__c,Financial_Institution__c,Account_number__c,Applicant_1__r.Tax_Identification_Number_TIN__pc,Applicant_1__r.Number_of_applicants_to_operate_account__pc, Application_Sections__c,Applicant_2__r.FinServ__Occupation__pc, Applicant_1__r.Tax_Resident_of_countries__pc, Current_Application_Sections__c,FinServ__ReferredByUser__c,Applicant_2__r.FinServ__Gender__pc,Applicant_2__r.Residential_Address__pc,Applicant_2__r.Postal_Address__pc,Applicant_2__r.PersonMobilePhone,Applicant_2__r.PersonEmail,Applicant_2__r.Primary_Employer_Job_Title__pc,Applicant_2__r.FirstName,
               Purpose__c,Applicant_1__c,Applicant_1__r.Residential_Address__pc,Applicant_1__r.Primary_Employer_Job_Title__pc,Applicant_1__r.FinServ__Occupation__pc, Applicant_1__r.Postal_Address__pc, Lender__c,Product_Name__c,Brokerage_Service_Fee_inc_GST__c,Total_Loan_amount__c,Interest_Rate__c, Applicant_1__r.Name,Applicant_1__r.PersonContactId,Loan_Term_months__c, Applicant_2__c, Applicant_2__r.PersonContactId,Lead_Source__c,Loan_Amount__c,
               Account.RecordType.Name,Applicant_1__r.PersonEmail,Applicant_2__r.Name, Applicant_1__r.Tax_File_Number_TFN__pc, Applicant_1__r.PersonMobilePhone, Applicant_2__r.LastName, Applicant_1__r.PersonBirthdate,Applicant_2__r.PersonBirthdate, Applicant_1__r.FinServ__Gender__pc, Applicant_1__r.LastName,Applicant_1__r.FirstName, FinServ__Household__c,Type_of_interest_rate__c,Monthly_Repayments__c, Application_Supporting_Notes__c, Preferred_repayment_frequency__c, Relationship_to_Applicant_2__c,RecordType.Name FROM Opportunity WHERE Id =: OppId limit 1];
        
        
        if(Opp.Applicant_2__c != null){
            IsApplicantTwo = true;
            System.debug('applicant inside iff  : '+IsApplicantTwo);
        }
        
        secApplicantName = (Opp.Applicant_2__c != null ? ' And '+Opp.Applicant_2__r.Name : '');
        
        System.debug('applicant : '+IsApplicantTwo);
        if(Opp.Applicant_2__c != null &&  ConId == Opp.Applicant_2__r.PersonContactId){
            appTwoAddress = Opp.Applicant_2__r.Residential_Address__pc + ' ' + Opp.Applicant_2__r.Postal_Code__pc;
        }
        appOneAddress = Opp.Applicant_1__r.Residential_Address__pc + ' ' + Opp.Applicant_1__r.Postal_Code__pc;
        
        return opp;
    }
    
    public static contact getcontact(){
        contact con = [select Id, Name,resident_of_country__c,Tax_File_Number_TFN__c,Number_of_applicants_to_operate_account__c,Tax_Resident_of_countries__c,Tax_Identification_Number_TIN__c,Email,Phone from contact WHERE Id =:  ConId LIMIT 1];
        return con;
    }
    
    public static FinServ__FinancialGoal__c getfinancialGoal(){
        opportunity op = [select Id, name, Applicant_1__r.Id from opportunity WHERE ID =: OppId LIMIT 1];
        
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
        Qot = [SELECT Id,Product__r.Repayment_Type__c, Customer_Amount__c,Lender__c,Commission_Type__c,QuoteNumber,Total_Setup_Fees__c,Monthly_Account_Keeping_Fees__c,Total_Loan_Cost__c,Up_Front_Fees__c, Total_loan_amount__c, Monthly_Repayments__c, Loan_Term__c, Monthly_Repayment__c, Purpose__c,Repayment_Frequency_Options__c,  Interest_Rate__c,
                        Lead__c, Lead__r.FirstName, Lead__r.LastName, Lead__r.Email,Brokerage_Amount__c,Quote.Product__r.Interest_Rate_Type__c, Shared_Message__c, Weekly_Repayments__c,Fortnightly_Repayments__c,
                        Opportunity.Applicant_1__r.PersonContactId,Commission_Amount__c, Product__c, Product__r.Name
                        FROM Quote WHERE OpportunityId =: OppId AND Application__c = true LIMIT 1];
        
        sYSTEM.debug('QUOTEnumber : '+Qot.QuoteNumber);
        if(Qot.Monthly_Account_Keeping_Fees__c != null && Qot.Monthly_Account_Keeping_Fees__c > 0){
            Amount = '$'+String.valueOf(Qot.Monthly_Account_Keeping_Fees__c * Qot.Loan_Term__c);
            amt = Qot.Monthly_Account_Keeping_Fees__c * Qot.Loan_Term__c;
        }
        else{
            Amount = '$0.00';
            amt = 0.00;
        }
        
        if(Qot.Monthly_Repayments__c != null && Qot.Monthly_Repayments__c > 0){
            Decimal dc = Qot.Monthly_Repayments__c;
            Mrepayment = '$'+(dc.format().contains('.')?dc.format():(dc.format()+'.00'));
        }
        else{
            Mrepayment = '$0.00';
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
        if(Qot.Total_loan_amount__c != null && Qot.Total_loan_amount__c > 0){
            Decimal amnt =Qot.Total_loan_amount__c;
            totalLoanamnt = '$'+(amnt.format().contains('.')?amnt.format():(amnt.format()+'.00'));
        }
        else{
            totalLoanamnt = '$0.00';
        }
        
        return  Qot;
        
    }
    
    public static void generateImageURL(){
        imgWrap = sendImageDataToComponent();
    }
    
    public static imageWrapper sendImageDataToComponent(){
        String imgURL = ''; 
        VOI_Detail__c voiDet = [Select Id, Name, contact__r.id from VOI_Detail__c Where contact__r.id =: ConId order by createddate DESC LIMIT 1];
        
        System.debug(voiDet);
             
        List<ContentDocumentLink> CDLList = [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = : voiDet.Id AND ContentDocument.Title = 'Sign1' order by ContentDocument.createddate DESC LIMIT 1];

        if(!CDLList.isEmpty()){
            String cdId = CDLList[0].ContentDocumentId;

            List<ContentVersion> conVerList = [SELECT Id,CreatedDate, Title FROM ContentVersion WHERE ContentDocumentId = : cdId AND Title = 'Sign1' LIMIT 1];

            if(!conVerList.isEmpty()){
                
                List<ContentDistribution> cdList = [select ID,DistributionPublicUrl ,ContentDownloadURL  from ContentDistribution where ContentVersionId= :conVerList[0].Id and ContentDocumentId =: cdId ];

                if(cdList.size()>0){
                    imageWrapper obj = new imageWrapper();
                    obj.imageURl = cdList.get(0).ContentDownloadUrl;
                    Datetime dt = conVerList[0].CreatedDate;
                    List<string> data = string.valueOf(dt).split(' ');
                    dateTime tim =  dt;
                    string timeCorrect = dt.day()+ '-' + dt.Month() + '-' + dt.Year() + ' ' + tim.format('h:mm a');
                    obj.DateOfsign = timeCorrect;
                    
                    return obj;
                }else{
                    ContentDistribution conDis = new ContentDistribution();
                    conDis.Name = conVerList[0].Title;
                    conDis.ContentVersionId = conVerList[0].Id;
                    conDis.PreferencesAllowViewInBrowser= true;
                    conDis.PreferencesLinkLatestVersion=true;
                    conDis.PreferencesNotifyOnVisit=false;
                    conDis.PreferencesPasswordRequired=false;
                    conDis.PreferencesAllowOriginalDownload= true;
                    Insert conDis;
                    
                    conDis = [SELECT ID,DistributionPublicUrl, ContentDownloadURL FROM ContentDistribution WHERE ID= :conDis.Id];
						
                    imageWrapper obj = new imageWrapper();
                    obj.imageURl = conDis.ContentDownloadURL;
                    Datetime dt = conVerList[0].CreatedDate;
                    List<string> data = string.valueOf(dt).split(' ');
                    dateTime tim =  dt;
                    string timeCorrect = data[0]+ ' '+ tim.format('h:mm a');
                    obj.DateOfsign = timeCorrect;
                    
                    return obj;
                }
            }
        }

        return null;
    }
	
    public class imageWrapper{
        public string imageURl{get;set;}
        public string DateOfsign{get;set;}
    }
    
    
}