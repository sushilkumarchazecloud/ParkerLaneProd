public class groupQuoteController {
    public static List<String>  personalRecTypeNameList = New List<String>{'Green Loan','Asset Finance','Commercial Solar Purchase','Commercial Asset Finance','Debt Consolidation','Home Improvement','Personal Loan','Vehicle Purchase'};
        public static List<String>  mortgageRecTypeNameList = New List<String>{'Commercial Mortgage','Commercial Property Purchase','Home Loan Construction','Home Loan Purchase','Home Loan Refinance','Opportunity (Wallet Share)'};
            
            /*@auraEnabled
            public static void resendGenerateAndSendPDF(String oppId){ 
                
                list<opportunity> opp = [SELECT Id,ReferredByContact__r.id,Send_the_quote_to__c,AccountId,Contact_1__c,Contact_2__c,Contact_1__r.id,Contact_2__r.id from Opportunity where id =: oppId LIMIT 1];
                system.debug('opportunity'+opp);
                
                List<Contact> con = [SELECT Id, Name, Email, Account.Name, AccountId, Account.Referrer_Business_Type__c 
                                     FROM Contact WHERE id=: opp[0].ReferredByContact__r.id AND Account.On_Board_Referral__c = TRUE AND  Account.RecordType.developerName = 'Referrer_Business' limit 1];
                system.debug('contact'+con);
                String conId = '';
                String referrerEmail = '';
                referrerEmail = con[0].Email;
                conId = con[0].Id;
                
                list<quote> leadList = [Select id, Lead__c, Lead__r.id, Lead__r.Email, OpportunityId from Quote where OpportunityId =: oppId LIMIT 1];
                system.debug('lead'+leadList);
                String leadId = '';
                String sendQuote = '';
                String customerEmail = '';
                customerEmail = leadList[0].Lead__r.Email;
                sendQuote = opp[0].Send_the_quote_to__c;
                leadId = leadList[0].Lead__r.id;
                
                ParkerLaneLoanController.sendApplication(oppId, conId, leadId, new List<String>{referrerEmail}, 'Quotation From Referrer VF', true);
                if(sendQuote.equalsIgnoreCase('Me and my customer')){            
                    ParkerLaneLoanController.sendApplication(oppId, conId, leadId, New List<String>{customerEmail}, 'Quotation From Referral VF', false);
                }                
            }*/
    
    @AuraEnabled
    public static  Map<String, List<groupWrapper>> getQuoteName(String oppID){
        boolean isApp = true;
        boolean isFnn = true;
        Opportunity opp = [Select StageName 
                           FROM opportunity 
                           WHERE id =: oppId];
        if(opp.StageName == 'Application' || 
           opp.StageName == 'CPA Started' ||
           opp.StageName == 'Packs Out' ||
           opp.StageName == 'Packs Back' ||
           opp.StageName == 'Submission Summary'){
               isApp = false;
           }
        if(opp.StageName == 'Settled (closed won)'){
            isFnn = false;
        }
        boolean isconverted = false;
        Map<String, List<groupWrapper>> GroupOfQuote = new Map<String, List<groupWrapper>>();
        for( Quote var : [Select Id, Name, QuoteNumber,Customer_Amount__c,Interest_Rate__c,Monthly_Repayment__c, 
                          Total_Setup_Fees__c,Subtotal,TotalPrice, CreatedBy.Name, CreatedDate, ExpirationDate,
                          IsSyncing,Gruop_Name__c, Application__c,Financial_Account__c, Up_Front_Fees__c, Total_Loan_Cost__c,
                          Brokerage_Amount__c,
                          (SELECT Amount__c, Fee_Type__c, Frequency__c FROM Loan_Fees__r)
                          from Quote where OpportunityId=: oppId ORDER By Gruop_Name__c ASC]){
                              if( !GroupOfQuote.containsKey(var.Gruop_Name__c) ){
                                  GroupOfQuote.put(var.Gruop_Name__c, new List<groupWrapper>());
                              }
                              if(var.Financial_Account__c)
                                  isconverted = true;
                              GroupOfQuote.get(var.Gruop_Name__c).add(new groupWrapper(var,var.Gruop_Name__c, isFnn, isApp));
                          }
        if(isconverted){
            for(String var : GroupOfQuote.keySet()){
                for(groupWrapper var1 : GroupOfQuote.get(var)){
                    var1.isFnAccDisable = true;
                }
            }
        }
        System.debug(GroupOfQuote);
        return GroupOfQuote;
    }
    
    @AuraEnabled
    public static void deleteApplication(String oppId, String mast){
        List<Quote> qut = [Select Id, Gruop_Name__c from Quote where OpportunityId=: oppId and Gruop_Name__c =: mast];
        delete [Select Id from Loan_Fees__c where  Quote__c in :qut];
        delete qut;
    }
    
    // @AuraEnabled
    // public static void updateQuote(String quotId, String oppId){
    //     Opportunity opp = [Select StageName, Applicant_1__c,FinancialAccount__c
    //                        FROM opportunity 
    //                        WHERE id =: oppId];
    //     if(opp.StageName == 'Settled (closed won)'){
    //         Id loanAccountRTId = Schema.SObjectType.FinancialAccount__c.getRecordTypeInfosByName().get('Loan Account').getRecordTypeId();
    //         Quote qut = new Quote();
    //         qut.Id = quotId;
    //         qut.Financial_Account__c = true;
    //         update qut;
    //         Quote quote= [Select Id,Loan_Term__c,Customer_Amount__c,Interest_Rate__c,Product__c, Name,Gruop_Name__c from Quote where id=:quotId];
    //         FinancialAccount__c finAccount = New FinancialAccount__c();
    //         finAccount.RecordTypeId = loanAccountRTId;
    //         finAccount.LoanTermMonths__c = quote.Loan_Term__c;
    //         finAccount.LoanAmount__c = quote.Customer_Amount__c;
    //         finAccount.InterestRate__c = quote.Interest_Rate__c;
    //         finAccount.ProductName__c = quote.Product__c;
    //         finAccount.Name = quote.Name;
    //         finAccount.Quote__c = quote.Id;
    //         finAccount.PrimaryOwner__c = opp.Applicant_1__c;
    //         insert finAccount;
    //         opp.FinancialAccount__c = finAccount.Id;
    //         update opp;
    //     }else{
    //         throw new AuraHandledException('Stage is not closed won');
    //     } 
    // }
    //NO FINANCIALACCOUNT
    @AuraEnabled
    public static void updateQuoteApplication(String quotId, String oppId, String oldQutId){
        Opportunity opp = [Select StageName 
                           FROM opportunity 
                           WHERE id =: oppId];
        System.debug('oldQutId '+oldQutId);
        System.debug('quotId '+quotId);
        if(opp.StageName == 'Application' || 
           opp.StageName == 'CPA Started' ||
           opp.StageName == 'Packs Out' ||
           opp.StageName == 'Packs Back' ||
           opp.StageName == 'Submission Summary'){
               List<Quote> temp = new List<Quote>();
               if(oldQutId != '')
                   temp.add(new Quote(ID = oldQutId, Application__c = false));
               temp.add(new Quote(ID = quotId, Application__c = true));
               update temp;
           }else{
               throw new AuraHandledException('Stage is not Application');
           } 
    }
    
    @AuraEnabled
    public static void sendApplication(String oppId, String quote){
        //added 16-2-22
        Opportunity op = [Select Name,Owner.Email, Applicant_1__c, Applicant_2__c, Applicant_1__r.PersonEmail, Applicant_2__r.PersonEmail, Applicant_1__r.Firstname, Applicant_1__r.PersonContactId, StageName,Application_Sections__c,Current_Application_Sections__c,Credit_Analyst__c,Credit_Analyst__r.Email,RecordType.Name,RecordTypeId   FROM Opportunity WHERE ID =: oppId];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        mail.setToAddresses(new string[] {op.Applicant_1__r.PersonEmail});
        
        String fromEmailAddress = 'sethu.rawat@chazecloud.com';
        if(personalRecTypeNameList.contains(op.RecordType.Name)){
            fromEmailAddress = 'tazeem.khan@chazecloud.com';
            mail.setReplyTo('tazeem.khan@chazecloud.com');
        }else if(mortgageRecTypeNameList.contains(op.RecordType.Name)){
            fromEmailAddress = 'tazeem.khan@chazecloud.com';
            mail.setReplyTo(op.Owner.Email);
            if(String.isNotBlank(op.Credit_Analyst__c)){
                mail.setCcAddresses(new string[] {op.Credit_Analyst__r.Email});
            }
        }
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:fromEmailAddress];
        System.debug('owea' + owea);
        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        //added 2-3-22
        
        mail.setWhatId(quote); 
        //mail.setSenderDisplayName('The Parker Lane Team'); 
        mail.setUseSignature(false); 
        mail.setTargetObjectId(op.Applicant_1__r.PersonContactId);
        mail.setBccSender(false);
        
        mail.setSaveAsActivity(false); 
        EmailTemplate et=[Select id,Subject,Body from EmailTemplate where Name= 'Application From Adviser']; 
        mail.setTemplateId(et.id); 
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        /*op.StageName = 'CPA Started';
        op.Application_Sections__c = 'Getting Started';
        op.Current_Application_Sections__c  = 'Getting Started';
        update op;*/
        String purpose = [select Id,Purpose__c from Quote where Id =: quote][0].Purpose__c;
        String ebody = et.Body;
        ebody = ebody.replace('Chris White', op.Name);
        String subject = et.Subject;
        subject = subject.replace('{!Quote.Purpose__c}', purpose);
        insert new Task( Subject = subject,
                        WhoId = op.Applicant_1__r.PersonContactId, 
                        WhatId = op.Id, 
                        Status = 'Completed', 
                        TaskSubtype = 'Email', 
                        ActivityDate = System.Today(),
                        Description = ebody);
        
    }
    
    @AuraEnabled
    public static void sendQuotation(String oppId, String quote, String master){
        /*Quote qt = new Quote();
        if(master.contains('Website')){
            qt = [SELECT Id, Purpose__c FROM Quote WHERE Gruop_Name__c =: master AND OpportunityId =: oppId][0];
            System.debug(qt);
        }else{
            qt = [select Id,Purpose__c from Quote where Id =: quote][0];
        }*/
        list<quote> qtlist = [select id,isSelected__c from quote where OpportunityId =: oppId];
        if(!qtlist.isEmpty()){
            for(quote qt : qtlist){
                qt.isSelected__c = false;
            }
            update qtlist;
        }
        list<quote> quotelist = [select id,isSelected__c,Purpose__c from quote where Gruop_Name__c =: master AND OpportunityId =: oppId];
          if(!quotelist.isEmpty()){
            for(quote qt : quotelist){
                qt.isSelected__c = true;
            }
            update quotelist;
        }
        Opportunity op = [Select Name, Owner.Email, Applicant_1__c, Applicant_2__c, Applicant_1__r.PersonEmail, 
                          Applicant_2__r.PersonEmail, Applicant_1__r.Firstname, Applicant_1__r.PersonContactId, 
                          StageName,Application_Sections__c,Current_Application_Sections__c, Credit_Analyst__c, Credit_Analyst__r.Email,ReferredByContact__c,Send_the_quote_to__c,RecordType.Name,RecordTypeId   
                          FROM Opportunity WHERE ID =: oppId];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        mail.setToAddresses(new string[] {op.Applicant_1__r.PersonEmail});
        
        String fromEmailAddress = utilityclass.adminEmail;
        if(personalRecTypeNameList.contains(op.RecordType.Name)){
            fromEmailAddress = utilityclass.adminEmail;
            mail.setReplyTo(utilityclass.adminEmail);
        }else if(mortgageRecTypeNameList.contains(op.RecordType.Name)){
            fromEmailAddress = 'tazeem.khan@chazecloud.com';
            if(String.isNotBlank(op.Credit_Analyst__c)){
                mail.setCcAddresses(new string[] {op.Credit_Analyst__r.Email});
            }
            mail.setReplyTo(op.Owner.Email);
        }
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:fromEmailAddress];
        System.debug('owea' + owea);
        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        //added 2-3-22
        
        mail.setWhatId(oppId); 
        mail.setUseSignature(false); 
        mail.setTargetObjectId(op.Applicant_1__r.PersonContactId);
        mail.setBccSender(false); 
        mail.setSaveAsActivity(true); 
        EmailTemplate et=[Select id,Subject,Body from EmailTemplate where Name= 'Quotation From Application VF']; 
        mail.setTemplateId(et.id); 
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        op.StageName = 'Quote';
        op.Application_Sections__c = 'Loan Recommendation';
        op.Current_Application_Sections__c  = 'Loan Recommendation';
        if(op.ReferredByContact__c != null && op.Send_the_quote_to__c != 'Me and my customer'){ //Created by Rakesh For update 'send quote to' field when sending Quote to Customer
           op.Send_the_quote_to__c = 'Me and my customer';
        }
        update op;   
    }
    
    public class groupWrapper{
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String QNumber;
        @AuraEnabled
        public boolean Syncing;
        @AuraEnabled
        public Date ExpDate;
        @AuraEnabled
        public Decimal Subtotal;
        @AuraEnabled
        public Decimal TotalPrice;
        @AuraEnabled
        public Decimal brokerageAmount;
        @AuraEnabled
        public String ongoingFees;
        @AuraEnabled
        public String CreatedBy;
        @AuraEnabled
        public String CreatedDate;
        @AuraEnabled
        public Decimal TotalSetup;
        @AuraEnabled
        public Decimal LoanAmount;
        @AuraEnabled
        public Decimal InterestRate;
        @AuraEnabled
        public Decimal MonthlyRepayment; 
        @AuraEnabled
        public Decimal TotalCost;
        @AuraEnabled
        public String groupName;
        @AuraEnabled
        public boolean application;
        @AuraEnabled
        public boolean isAppDisable;
        @AuraEnabled
        public boolean fnAcc;
        @AuraEnabled
        public boolean isFnAccDisable;
        
        public groupWrapper(Quote var, String groupName, boolean isFnAccDisable, boolean isAppDisable){
            Name = var.Name;
            LoanAmount = var.Customer_Amount__c;
            InterestRate = var.Interest_Rate__c;
            MonthlyRepayment = var.Monthly_Repayment__c; 
            TotalCost = var.Total_Loan_Cost__c ;
            TotalSetup = var.Up_Front_Fees__c;
            brokerageAmount = var.Brokerage_Amount__c ;
            QNumber = var.QuoteNumber;
            Syncing = var.IsSyncing;
            ExpDate = var.ExpirationDate;
            Subtotal = var.Subtotal;
            TotalPrice = var.TotalPrice;
            CreatedBy = var.CreatedBy.Name;
            CreatedDate = var.CreatedDate.format('dd/MM/yyyy, hh:mm a', UserInfo.getTimeZone().toString());
            Id = var.Id;
            groupName = groupName;
            application = var.Application__c;
            fnAcc = var.Financial_Account__c;
            this.isFnAccDisable = isFnAccDisable;
            this.isAppDisable = isAppDisable;
            ongoingFees = '';
            for(Loan_Fees__c lf : var.Loan_Fees__r){
                if(lf.Fee_Type__c == 'Account Keeping'){
                    ongoingFees += '$'+lf.Amount__c + ' ' + lf.Frequency__c + '; ';
                }
            }
            
        }
    }
    
}