global class batchForSendingMailToRefererAdmin implements Database.Batchable<sObject>,Database.Stateful {
	
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Referrer').getRecordTypeId();
        
        System.debug(devRecordTypeId);
        
        return Database.getQueryLocator('Select Id,AccountId,email, Name from Contact WHERE RecordTypeId = : devRecordTypeId AND Admin__c = true AND HasOptedOutOfEmail = false');
    }

    global void execute(Database.BatchableContext bc, List<Contact> scope) {
        set<id> Accid = new Set<id>();
        for(contact con : scope){
            Accid.add(con.AccountId);  
        }
        Map<id, List<Opportunity>> oppMap = new  Map<id, List<Opportunity>>();
        for(Opportunity op : [Select Id,StageName, Name,Time_at_current_stage__c,FinServ__ReferredByContact__r.AccountId, CreatedDate,FinServ__ReferredByContact__c from opportunity WHERE FinServ__ReferredByContact__r.AccountId IN: Accid order By CreatedDate DESC]){
            if(((op.stageName == 'Working' || op.stageName == 'Nurturing') && op.Time_at_current_stage__c <= 7) 
               || (op.StageName == 'Closed Lost' && op.Time_at_current_stage__c <= 7)
               || ((op.StageName != 'Settled (closed won)' && op.stageName != 'Working' && op.stageName != 'Nurturing' && op.StageName != 'Closed Lost') && op.Time_at_current_stage__c <= 120)
               || (op.StageName == 'Settled (closed won)') 
              ){
                if(!oppMap.containsKey(op.FinServ__ReferredByContact__c)){
                    oppMap.put(op.FinServ__ReferredByContact__r.AccountId, new List<opportunity>{op});
                }   
                else{
                    oppMap.get(op.FinServ__ReferredByContact__r.AccountId).add(op);
                }
              }
            
        }
        
        System.debug(oppMap);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [SELECT Id,Subject, Body FROM EmailTemplate WHERE DeveloperName = 'Daily_Referral_Report_Admin' ];
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = : system.label.Personal_App_Email];
        for(contact con : Scope){
            Blob PdfData;
            Blob PdfData2;
            
            if(oppMap.get(con.AccountId) != null && oppMap.get(con.accountId).size() > 0){
                PageReference pdf1 = Page.CreditReportForLenderPDF;
                pdf1.getParameters().put('AccId',con.AccountId);
                pdf1.getParameters().put('ConId',con.id);
                pdf1.setRedirect(true);
                
                PageReference pdf2 = Page.CreditReportForLenderExcel;
                pdf2.getParameters().put('AccId',con.AccountId);
                pdf2.getParameters().put('ConId',con.id);
                pdf2.setRedirect(true);
                
                if (Test.IsRunningTest())
                {
                    PdfData = Blob.valueOf('UNIT.TEST');
                    PdfData2 = Blob.valueOf('UNIT.TEST');
                }
                else
                {
                    PdfData = pdf1.getContent();
                    PdfData2 = pdf2.getContent();
                }
                
                string title = con.Name + ' Referral Update Report ' + System.today();
                try{                    
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(title+'pdf');
                    efa.setContentType('application/pdf');
                    efa.setBody(pdfData);
                    Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
                    efa1.setFileName(title+'.xls');
                    efa1.setContentType('application/vnd.ms-excel');
                    efa1.setBody(PdfData2);
                    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                    email.setTemplateId(emailTemplate.id);         
                    email.setTargetObjectId(con.id);
                    email.setWhatId(con.AccountId);
                    
                    if(owea != null){
                        if ( owea.size() > 0 ) {
                            email.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                    }
                    System.debug('email++'+con.email);
                    email.setReplyTo(system.label.Personal_App_Email);
                    //email.setFileAttachments(PdfData);
                    email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa, efa1});
                    email.saveAsActivity = true;  
                    string[] to = new string[] {con.email};  
                        email.setToAddresses(to);
                    email.setBccAddresses(new String[]{'chris.white@parkerlane.com.au'});
                    mails.add(email);
                }catch(Exception ex){
                    Exception__c eror = new Exception__c();
                    eror.Class_Name__c = 'BatchAdmin For Referrer Report';
                    eror.Method_Name__c = 'Generating Mail';
                    eror.Error_Message__c = ex.getMessage() + '' + ex.getLineNumber();
                    insert eror;
                }
            }
        }
        
        try{
            if(mails != null && mails.size() > 0){
                System.debug('size of Mails'+mails.size());
            	Messaging.sendEmail(mails);
            }
        }catch(Exception ex){
            Exception__c eror = new Exception__c();
            eror.Class_Name__c = 'BatchD For Referrer Report';
            eror.Method_Name__c = 'sending Mail';
            eror.Error_Message__c = ex.getMessage() + '' + ex.getLineNumber();
            insert eror;
        }
    }

    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations - send emails, notify clients,
        // give a call to another batch class
        // Can give to another batch class
        // Can give callout request
        system.debug('batch job id = '+bc.getJobId());
        
        BatchForReferrersReport obj = new BatchForReferrersReport();
        Database.executeBatch(obj, 5);
    }
	
}