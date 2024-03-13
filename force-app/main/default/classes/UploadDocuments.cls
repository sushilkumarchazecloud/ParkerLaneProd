public without sharing class UploadDocuments {
    
    @AuraEnabled
    public static String getOpportunityId(String apId, String pgUrl){
        
        ApexPages.PageReference pgRef = new ApexPages.PageReference(pgUrl);
        Map<String, String> params = pgRef.getParameters();

        Opportunity opp = [Select Id,Applicant_1__c,Applicant_2__c,Report_Ready_Access_Ids__c, Last_Report_Ready_Access_Id__c, Document_Redirect_URL__c  from Opportunity where Access_Id__c=:apId Limit 1];
        if(params.containsKey('MGACCESSID') && params.get('MGACCESSID') != opp.Last_Report_Ready_Access_Id__c){
            opp.Last_Report_Ready_Access_Id__c = params.get('MGACCESSID');
            update opp;
        }
        
        //ADDED BY TAZEEM
        Map<string, contact> conEmpMap = new Map<string, contact>();
        conEmpMap = CreateDocumentController.fetchEmpDetails(opp.id);
        Boolean applicantOneEmp = false;
        Boolean applicantTwoEmp = false;
        
        if(conEmpMap.get('applicant1').Employment__r.size() > 0){
            for(Employment__c emp : conEmpMap.get('applicant1').Employment__r){
                if(emp.EmploymentStatus__c == 'Full time permanent' || emp.EmploymentStatus__c == 'Part time permanent' || emp.EmploymentStatus__c == 'Casual / Temporary'){
                    applicantOneEmp = true;
                    break;
                }
            }
        }
        if(opp.Applicant_2__c != null){
            if(conEmpMap.get('applicant2').Employment__r.size() > 0){
                for(Employment__c emp : conEmpMap.get('applicant2').Employment__r){
                    if(emp.EmploymentStatus__c == 'Full time permanent' || emp.EmploymentStatus__c == 'Part time permanent' || emp.EmploymentStatus__c == 'Casual / Temporary'){
                        applicantTwoEmp = true;
                        break;
                    }
                }
            } 
        }
       //ADDED BY TAZEEM 
        
        
        Quote qt = [SELECT Id, Purpose__c, Product__c, Product__r.Name, Product__r.Ongoing_Fees__c, Lender__c, Application__c
                    FROM Quote WHERE OpportunityId =: opp.Id AND Application__c = true LIMIT 1];
        
        List<Document_Requested__c> docList = new List<Document_Requested__c>();
        List<Document_Requested__c> dList = new List<Document_Requested__c>();
        
        dList = [SELECT Document__c,Opportunity__c FROM Document_Requested__c WHERE Opportunity__c =: opp.Id AND Document__c = 'Payslips']; 
        
        List<Document_Requested__c> dListApp2 = new List<Document_Requested__c>();
        if(opp.Applicant_2__c != null){
            dListApp2 = [SELECT Document__c,Opportunity__c FROM Document_Requested__c WHERE Opportunity__c =: opp.Id AND Document__c = 'Payslips' AND Person_Account__c =: opp.Applicant_2__c]; 
        }
        
        //ADDED BY TAZEEM   
        if(pgUrl.contains('/SupportingDocument') && qt.Lender__c == 'Transport Mutual Credit Union'){
            if((qt.Purpose__c == 'Solar' || qt.Purpose__c == 'Home Improvement') && applicantOneEmp  && dList.size() == 0){
                docList.add(CreateDocumentController.createDocumentRequest(opp.Applicant_1__c, new RuleEngine__mdt(Document__c='Payslips', Category__c='Income', Description__c='Two (2) consecutive most recent payslips.'), opp.Id));
            }
            if(opp.Applicant_2__c != null){
                if((qt.Purpose__c == 'Solar' || qt.Purpose__c == 'Home Improvement') && applicantTwoEmp  && dListApp2.size() == 0){
                    docList.add(CreateDocumentController.createDocumentRequest(opp.Applicant_2__c, new RuleEngine__mdt(Document__c='Payslips', Category__c='Income', Description__c='Two (2) consecutive most recent payslips.'), opp.Id));
                }   
            }
        }
        //ADDED BY TAZEEM 
        if(pgUrl.contains('/MogoSupportingDocument') && params.containsKey('MGACCESSID') && qt.Lender__c == 'Transport Mutual Credit Union' && dList.size() == 0){
            List<Document_Requested__c> dcList = [SELECT Document__c,Opportunity__c FROM Document_Requested__c WHERE Opportunity__c =: opp.Id AND Document__c = 'Centrelink Statements'];
            if(dcList.size() > 0){
                delete dcList;
            }
        }
        
        if(docList.size() > 0){
            insert docList;
        }
        
        dList = [SELECT Document__c,Opportunity__c FROM Document_Requested__c WHERE Opportunity__c =: opp.Id];
        if(dList.size() == 0){
            opp.Document_Redirect_URL__c  = System.Label.BaseURL + '?Id=' + opp.Id; 
            opp.Application_Sections__c ='All Done';
            opp.Current_Application_Sections__c ='All Done';
            update opp;
        }
        
        return opp.Id;         
    }
    
    @AuraEnabled
    public static void updateActivity(Boolean updateField, string recId){
        Opportunity opp = [select id,Last_Customer_Activity__c,Last_Customer_Action__c,isActivityCheck__c/*,Docs_Last_Uploaded__c*/ from opportunity where id =: recId];
        if(updateField){
            opp.isActivityCheck__c = false;
            update opp;
        }
        opp.Last_Customer_Activity__c = system.now();
        opp.isActivityCheck__c = true;
        opp.Last_Customer_Action__c = 'Documents received';
        opp.Docs_Last_Uploaded__c = System.now();
        update opp;
        
    }    
    
    @AuraEnabled
    public static void finishLater(String recId){
        Opportunity opp = [select id,Applicant_1__c,Applicant_2__c,Contact_1__c,Contact_2__c,Applicant_1_Email__c,Applicant_2_Email__c from opportunity where id =: recId];
        OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address =:UtilityClass.adminEmail];
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
        mail.setTreatTargetObjectAsRecipient(false);
        EmailTemplate et=[Select id, Subject, Body from EmailTemplate where Name = 'CustomerInfoRequired']; 
        mail.setTemplateId(et.id);
        mails.add(mail);
        if(!test.isRunningTest()){
            Messaging.sendEmail(mails);   
        }        
    }    
    
    @AuraEnabled
    public static Map<String, Map<String, Map<String ,docWrapp>>> getContacts(String oppId, String pgUrl){
        
        Opportunity opp = [Select Id,Applicant_1__c,Applicant_2__c,RecordTypeId  from Opportunity where Id=:oppId Limit 1];
        
        if(!ApplicationFormController.mortgageRTList.contains(opp.RecordTypeId)){
            ApexPages.PageReference pgRef = new ApexPages.PageReference(pgUrl);
            Map<String, String> params = pgRef.getParameters();
            
            List<Document_Requested__c> dcList = new List<Document_Requested__c>();
            List<Document_Requested__c> dList = new List<Document_Requested__c>();
            
            dList = [SELECT Document__c,Opportunity__c FROM Document_Requested__c WHERE Opportunity__c =: oppId AND Document__c = 'Payslips']; 
            
            
            List<Document_Requested__c> dListApp2 = new List<Document_Requested__c>();
            if(opp.Applicant_2__c != null){
                dListApp2 = [SELECT Document__c,Opportunity__c FROM Document_Requested__c WHERE Opportunity__c =: opp.Id AND Document__c = 'Payslips' AND Person_Account__c =: opp.Applicant_2__c]; 
            }

            Quote qt = [SELECT Id, Purpose__c, Product__c, Product__r.Name, Product__r.Ongoing_Fees__c, Lender__c, Application__c   
                        FROM Quote WHERE OpportunityId =: oppId AND Application__c = true LIMIT 1]; 
              
            //ADDED BY TAZEEM
            Map<string, contact> conEmpMap = new Map<string, contact>();
            conEmpMap = CreateDocumentController.fetchEmpDetails(opp.id);
            Boolean applicantOneEmp = false;
            Boolean applicantTwoEmp = false;
            
            if(conEmpMap.get('applicant1').Employment__r.size() > 0){
                for(Employment__c emp : conEmpMap.get('applicant1').Employment__r){
                    if(emp.EmploymentStatus__c == 'Full time permanent' || emp.EmploymentStatus__c == 'Part time permanent' || emp.EmploymentStatus__c == 'Casual / Temporary'){
                        applicantOneEmp = true;
                        break;
                    }
                }
            }
            if(opp.Applicant_2__c != null){
                if(conEmpMap.get('applicant2').Employment__r.size() > 0){
                    for(Employment__c emp : conEmpMap.get('applicant2').Employment__r){
                        if(emp.EmploymentStatus__c == 'Full time permanent' || emp.EmploymentStatus__c == 'Part time permanent' || emp.EmploymentStatus__c == 'Casual / Temporary'){
                            applicantTwoEmp = true;
                            break;
                        }
                    }
                } 
            }
            
            
            if(pgUrl.contains('/MogoSupportingDocument') && params.containsKey('oppId') && qt.Lender__c == 'Transport Mutual Credit Union'){    
                if((qt.Purpose__c == 'Solar' || qt.Purpose__c == 'Home Improvement') && applicantOneEmp && dList.size() == 0){
                    dcList.add(CreateDocumentController.createDocumentRequest(opp.Applicant_1__c, new RuleEngine__mdt(Document__c='Payslips', Category__c='Income', Description__c='Two (2) consecutive most recent payslips.'), opp.Id));
                }
                if(opp.Applicant_2__c != null){
                    if((qt.Purpose__c == 'Solar' || qt.Purpose__c == 'Home Improvement') && applicantTwoEmp && dListApp2.size() == 0){
                        dcList.add(CreateDocumentController.createDocumentRequest(opp.Applicant_2__c, new RuleEngine__mdt(Document__c='Payslips', Category__c='Income', Description__c='Two (2) consecutive most recent payslips.'), opp.Id));
                    }   
                }
            }
            //ADDED BY TAZEEM 
            
            if(dcList.size() > 0){
                insert dcList;
            }
        }
        Map<String, Map<String, Map<String ,docWrapp>>> mapOfDocs = new Map<String, Map<String, Map<String ,docWrapp>>>();
        
        // updated by tazeem on 21-nov-2022 added Document__c based condition in Query
        for(Document_Requested__c docList : 
            [SELECT ID, Category__c,reason__c, Person_Account__c,Person_Account__r.Name, Description__c,Details__c, isComplete__c , isAlready_provided__c,  Document__c, IsJoint__c, Opportunity__c , isBankStatement__c,
             (SELECT Id, Name  FROM Document_Request_Items__r)
             FROM Document_Requested__c 
             WHERE Opportunity__c =: oppId AND Document__c != null AND isComplete__c = false
             ORDER BY Person_Account__c NULLS LAST]){  
                 //system.debug(docList.Document_Request_Items__r);
                 String key = docList.Person_Account__c == null ? 'General Documents' : docList.Person_Account__r.Name;
                 if(!mapOfDocs.containsKey(key)){
                     Map<String ,docWrapp> document = new  Map<String ,docWrapp>();
                     document.put(docList.Document__c+'@'+docList.Id,new docWrapp(docList.Description__c, docList.isBankStatement__c,docList.Description__c, docList.isAlready_provided__c, docList.isComplete__c, docList.Document_Request_Items__r.size()>0? docList.Document_Request_Items__r: new List<Document_Request_Item__c>()));
                     Map<String, Map<String ,docWrapp>> category = new Map<String, Map<String ,docWrapp>>();
                     category.put(docList.Category__c, document);
                     mapOfDocs.put(key, category);
                 }else{
                     if(!mapOfDocs.get(key).containsKey(docList.Category__c)){
                         Map<String ,docWrapp> document = new  Map<String ,docWrapp>();
                         document.put(docList.Document__c+'@'+docList.Id, new docWrapp(docList.Description__c, docList.isBankStatement__c, docList.Description__c, docList.isAlready_provided__c, docList.isComplete__c, docList.Document_Request_Items__r.size()>0? docList.Document_Request_Items__r: new List<Document_Request_Item__c>()));
                         mapOfDocs.get(key).put(docList.Category__c, document);
                     }else{
                         if(!mapOfDocs.get(key).get(docList.Category__c).containsKey(docList.Document__c+'@'+docList.Id)){
                             mapOfDocs.get(key).get(docList.Category__c).put(docList.Document__c+'@'+docList.Id,new docWrapp(docList.Description__c, docList.isBankStatement__c, docList.Description__c, docList.isAlready_provided__c, docList.isComplete__c, docList.Document_Request_Items__r.size()>0? docList.Document_Request_Items__r: new List<Document_Request_Item__c>()));
                         }else{
                             mapOfDocs.get(key).get(docList.Category__c).get(docList.Document__c+'@'+docList.Id).AttachId.addAll(docList.Document_Request_Items__r);
                         }
                     }
                 }
                 //System.debug(mapOfDocs);
             }
        if(mapOfDocs.isEmpty()){
            Opportunity op = New Opportunity();
            op.Id = oppId;
            op.Document_Redirect_URL__c  = System.Label.BaseURL + '?Id=' + oppId; 
            op.Application_Sections__c ='All Done';
            op.Current_Application_Sections__c ='All Done';
            update op;
        }
        System.debug(mapOfDocs);
        return mapOfDocs;
        
    }
    @AuraEnabled
    public static boolean UpdateDocument(String docReId, boolean isAlready_provided, String Details,boolean isNotApplicable, boolean isComplete, String recId){
        Document_Requested__c doc = new Document_Requested__c();
        doc.id = docReId;
        System.debug('====> '+isComplete);
        doc.isComplete__c = isComplete;
        doc.Details__c = Details;
        doc.isAlready_provided__c = isAlready_provided;
        doc.isApplicable__c = isNotApplicable;
        doc.Received_Date__c = System.Datetime.now();
        //att.Description = Description;
        update doc;
        boolean flag = false;
        list<Document_Requested__c> docReq = [SELECT ID, name,isComplete__c from Document_Requested__c where Opportunity__c =: recId AND Document__c != ''];
        for(Document_Requested__c docList : docReq){    
            if(!docList.isComplete__c){
            	flag = false;
                break;
            }
            else{
                flag = true;                
            }
        }
        return flag;
    } 
    @AuraEnabled
    public static void sendMail(String oppId, String remaining, String updateList){
        Opportunity op = new Opportunity();
        System.debug('oop=='+oppId);
        System.debug('oop=='+oppId.trim().length());
        String temp = oppId.trim();
        oppId = temp;
        List<Opportunity> opList = [Select Name, Owner.Email, Applicant_1__c , Applicant_2__c, Applicant_1__r.PersonEmail ,Applicant_2__r.PersonEmail, remaining__c, Applicant_1__r.Firstname, Applicant_1__r.PersonContactId, Owner.Id, Documents_Received__c,
                                    Credit_Analyst__c, Credit_Analyst__r.Email,RecordType.Name,RecordTypeId,
                                    (SELECT Id, Document__c, Person_Account__c, Person_Account__r.Name FROM Documents_Requested__r)
                                    FROM Opportunity
                                    WHERE ID =:temp ];//deployment//, Contact_1_full_name__c
        System.debug(opList);
        if(opList.size()>0)
            op = opList[0];
        else
            throw new AuraHandledException('error! Please contact to Administrator');
        
        Map<Id,String> mapReceived = New Map<Id,String>();
        for(Document_Requested__c dr: op.Documents_Requested__r){
            String docRec = dr.Document__c + ', ' + (dr.Person_Account__c !=Null ? dr.Person_Account__r.Name: 'General');
            mapReceived.put(dr.Id, docRec);
        }
        
        op.remaining__c = remaining.containsOnly('0')?'No more' : remaining;
        
        List<updateDocItem> listOfDocs = (List<updateDocItem>) JSON.deserialize(updateList, List<updateDocItem>.class);
        List<Document_Requested__c> updateDatabaseList = new List<Document_Requested__c>();
        String docReceived = '';
        for(updateDocItem var : listOfDocs){
            docReceived += mapReceived.get(var.Id) + '\n';
            updateDatabaseList.add(new Document_Requested__c(
                id = var.Id,
                isComplete__c = true,
                Details__c = var.Details,
                isAlready_provided__c = var.isAlready_provided,
                isApplicable__c = var.isNotApplicable,
                Received_Date__c = System.Datetime.now()
            ));
        }
        
        if(String.isBlank(docReceived)){
            docReceived = 'No documents Received';
        }
        op.Documents_Received__c = docReceived;
        op.Application_Sections__c ='All Done';
        op.Current_Application_Sections__c ='All Done';
        
        try{
            System.debug('==updateDatabaseList=>'+updateDatabaseList);
            update op;
            if(updateDatabaseList.size()>0)
                update updateDatabaseList;
        }catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException('Please contact to Administrator, error!'+e.getMessage());
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        EmailTemplate et = [SELECT Id,Subject,htmlValue FROM EmailTemplate WHERE DeveloperName = 'receivedDocuments'];
        
        string[] to = new string[] {op.Applicant_1__r.PersonEmail};
            mail.setToAddresses(to);
        
        if(String.isNotBlank(op.Applicant_2__r.PersonEmail))
            mail.setCcAddresses(new string[] {op.Applicant_2__r.PersonEmail});
        
        //added 2-3-22
        List<String>  personalRecTypeNameList = New List<String>{'Green Loan','Asset Finance','Commercial Solar Purchase','Commercial Asset Finance','Debt Consolidation','Home Improvement','Personal Loan','Vehicle Purchase'};
        List<String>  mortgageRecTypeNameList = New List<String>{'Commercial Mortgage','Commercial Property Purchase','Home Loan Construction','Home Loan Purchase','Home Loan Refinance','Opportunity (Wallet Share)'};
        String fromEmailAddress = 'sethu.rawat@chazecloud.com';
        
        if(personalRecTypeNameList.contains(op.RecordType.Name)){
            fromEmailAddress = 'tazeem.khan@chazecloud.com';
            mail.setReplyTo('tazeem.khan@chazecloud.com');
        }else if(mortgageRecTypeNameList.contains(op.RecordType.Name)){
            //added 16-2-22
            if(String.isNotBlank(op.Credit_Analyst__c)){
                mail.setCcAddresses(new string[] {op.Credit_Analyst__r.Email});
            }
            fromEmailAddress = 'tazeem.khan@chazecloud.com';
            mail.setReplyTo(op.Owner.Email);
        }
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:fromEmailAddress];
        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        
        // end added 2-3-22
        
        mail.setSaveAsActivity(true);
        mail.setWhatId(op.Id);
        mail.setTargetobjectid((ID)op.Applicant_1__r.PersonContactId );
        mail.setTemplateId(et.Id);
        
        //
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(mail);
        
        Messaging.SingleEmailMessage ownerMail = new Messaging.SingleEmailMessage();
        EmailTemplate et2 = [SELECT Id,Subject,htmlValue FROM EmailTemplate WHERE DeveloperName = 'Owner_Notification_on_upload_document'];
        ownerMail.setToAddresses(new string[] {op.Owner.Email});
        
        /*/added 16-2-22
        if(String.isNotBlank(op.Credit_Analyst__c)){
            ownerMail.setCcAddresses(new string[] {op.Credit_Analyst__r.Email});
        }*/
        //added 2-3-22
        
        if ( owea.size() > 0 ) {
            ownerMail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        // end added 2-3-22
        
        
        ownerMail.setSaveAsActivity(false);
        //ownerMail.setSenderDisplayName('The Parker Lane Team'); 
        ownerMail.setWhatId(op.Id);
        ownerMail.setTreatTargetObjectAsRecipient(false); 
        ownerMail.setTargetobjectid((ID)op.Applicant_1__r.PersonContactId );
        ownerMail.setTemplateId(et2.Id);
        ownerMail.setReplyTo('tazeem.khan@chazecloud.com');
        //ownerMail.setReplyTo(op.Owner.Email);
        List<Messaging.SingleEmailMessage> allmsg2 = new List<Messaging.SingleEmailMessage>();
        allmsg2.add(ownerMail);
        try {
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(allmsg,false);
            List<Messaging.SendEmailResult> results2 = Messaging.sendEmail(allmsg2,false);
            
            System.debug(results[0].success);
            if(!results[0].success){
                System.debug(results[0].getErrors()[0].getMessage());
                System.debug(results[0].getErrors()[0].getStatusCode());
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException('Please contact to Administrator, error!'+e.getMessage());
        }
    }
    @AuraEnabled
    public static String getBankStmtUrl(String oppId){
        String RecordtypeName = [SELECT Id, RecordType.name FROM Opportunity where Id =:oppId].RecordType.name;
        Map<String,Opportunity_Config__c> lst = Opportunity_Config__c.getall();
        String UrlName = lst.get('Default').BankStmtURL__c;
        for(String var : lst.keySet()){
            System.debug(var); 
            if(String.isNotBlank(lst.get(var).Record_Type__c)){
                List<String> RecordTypeCst = lst.get(var).Record_Type__c.split(',');
                if(RecordTypeCst.contains(RecordtypeName)){
                    UrlName = lst.get(var).BankStmtURL__c;
                }
            }
        }
        return UrlName;
    }
    @AuraEnabled
    public static void generateerrorTypeDoc(string recId){
        System.debug('---+_+'+recid);
        Document_Requested__c docu = new Document_Requested__c();
        for(Document_Requested__c doc : [Select id, name,is_bank_fail__c from Document_Requested__c where Opportunity__c = : recId AND Category__c = 'Bank Statements' LIMIT 1])
        if(!doc.is_bank_fail__c){
            doc.is_bank_fail__c = true;
            docu = doc;
        }
        update docu;
    }
    
    @AuraEnabled
    public static void completeBankstatement(string recId){
        System.debug('---+_+'+recid);
        Document_Requested__c doc = [Select id, name,isComplete__c,is_bank_fail__c from Document_Requested__c where Opportunity__c = : recId AND (Category__c = 'Bank Statements' OR Category__c = 'Living Expenses') LIMIT 1];
        doc.isComplete__c = true;
        doc.is_bank_fail__c = false;
        update doc;       
    }
    
     @AuraEnabled
    public static string getUserId(){
        User userid = [select id,username from user where username=: system.label.site_User][0];
        return userid.Id;
        //system.debug('userid'+userid.Id);
    }
    
    public class docWrapp{
        @AuraEnabled
        public String Discription;
        @AuraEnabled
        public String reason;
        @AuraEnabled
        public String Details;
        @AuraEnabled
        public boolean isAlready_provided;
        @AuraEnabled
        public boolean isNotApplicable;
        @AuraEnabled
        public boolean isComplete;
        @AuraEnabled
        public boolean isDisabled;
        @AuraEnabled
        public boolean upload;
        @AuraEnabled
        public List<Document_Request_Item__c> AttachId;
        public docWrapp(String reason, boolean isBankStatement, String Name,boolean isAlready_provided, boolean isComplete, List<Document_Request_Item__c> AttachId ){
            this.isNotApplicable = isBankStatement;
            this.Discription = Name;
            this.AttachId = AttachId;
            this.isAlready_provided = isAlready_provided;
            this.isComplete = isComplete;
            this.isDisabled = true;
            this.upload = false;
            this.reason = reason;
        }
    }
    public class updateDocItem{
        @AuraEnabled
        public String Discription ;
        @AuraEnabled
        public String Details ;
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public boolean isAlready_provided;
        @AuraEnabled
        public boolean isComplete ;
        @AuraEnabled
        public boolean isNotApplicable ;
        @AuraEnabled
        public String   isComment ;
        
    }
}