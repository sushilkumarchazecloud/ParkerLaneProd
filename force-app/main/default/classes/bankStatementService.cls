global class bankStatementService implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        System.debug('------name Email1=+++'+email.subject);
        System.debug('------name Email1=+++----'+email.htmlBody); 
        string opId = '';
        boolean flag = false;
        try{
            opId = email.subject.split('-')[1];
            System.debug('oppp'+opId);
        }catch(Exception ex){
            flag = true;
            Exception__c eror = new Exception__c();
            eror.Class_Name__c = 'Email service';
            eror.Method_Name__c = 'split email';
            eror.Error_Message__c = ex.getMessage() + '' + ex.getLineNumber();
            insert eror;
        }        
        List<Document_Requested__c> docRList = new List<Document_Requested__c>();
        if(opId != ''){
            for(Document_Requested__c dc : [select id,Category__c,is_bank_fail__c, isComplete__c,Document__c from Document_Requested__c where Opportunity__r.id =: opId]){
                if(dc.Category__c == 'Bank Statements'){
                    docRList.add(dc);
                }
            }
            
        }
       	
        List<ContentVersion> cvList = new List<ContentVersion>();
        for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
            ContentVersion ContVerFile = new ContentVersion();
            ContVerFile.VersionData = Blob.valueOf(tAttachment.body);
            ContVerFile.Title = tAttachment.fileName; 
            ContVerFile.PathOnClient= tAttachment.fileName+'.html';
            if(docRList != null && docRList.size() > 0){
            	ContVerFile.Document_Requested__c = docRList[0].id;    
            }
            cvList.add(ContVerFile);
        }
        
        for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
            ContentVersion ContVerFile = new ContentVersion();
            ContVerFile.VersionData = bAttachment.body;
            ContVerFile.Title = bAttachment.fileName; 
            ContVerFile.PathOnClient= bAttachment.fileName+'.json';
            if(docRList != null && docRList.size() > 0){
                ContVerFile.Document_Requested__c = docRList[0].id;
            }            
            cvList.add(ContVerFile);
        }
        
        if(cvList != null && cvList.size() > 0){
            insert cvList;
            Set<id> Setid = new Set<id>();
            for(ContentVersion cv : cvList){
                Setid.add(cv.id);
            }
            
            List<ContentDocumentLink> conDocId = new List<ContentDocumentLink>();
            List<ContentVersion> cdlListId = new List<ContentVersion>();
            cdlListId = [select Id, ContentDocumentId From ContentVersion WHERE Id IN : Setid];
            
            if(opId != ''){
                for(ContentVersion cv : cdlListId){
                    ContentDocumentLink cdl = New ContentDocumentLink();
                    cdl.LinkedEntityId = opId;
                    cdl.ContentDocumentId = cv.ContentDocumentId;
                    cdl.shareType = 'V';
                    conDocId.add(cdl);
                }               
            }
            
            if(conDocId != null && conDocId.size() > 0){
                Insert conDocId;    
             }
            
        }  
        System.debug('---=-'+flag);
        if(flag){
            List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
            for(ContentVersion cv : cvList){
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(cv.Title);
                string typeOf = 'application/'+cv.FileType;
                efa.setContentType(typeOf);
                efa.setBody(cv.VersionData);
                efaList.add(efa);
            }
            Messaging.SingleEmailMessage emailone = new Messaging.SingleEmailMessage();
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'personalapplications@parkerlane.com.au']; //
            if(owea != null){
                if ( owea.size() > 0 ) {
                    emailone.setOrgWideEmailAddressId(owea.get(0).Id);
                }
            }
            string body = 'Hi Team,\n\n A BankStatements.com.au submission for BZPK has been received and the system has been unable to add it to an opportunity.\n\n Please review, add it to the appropriate opportunity and assign a task for the owner.';
            string[] to = new string[] {'personalapplications@parkerlane.com.au'};
            emailone.setToAddresses(to);
            emailone.setUseSignature(false);
            emailone.setSubject('BankStatements.com.au submission for BZPK');
            emailone.setPlainTextBody(body);
            emailone.setFileAttachments(efaList);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailone});
                        
        }
        
        return result;
    }
}