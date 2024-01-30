public without sharing class UtilityClass {
    public static final String adminEmail = 'personalapplications@parkerlane.com.au';
    public static Map<String, Id> mortgageRTMap = New Map<String, Id>{
         'Commercial Mortgage' => Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commercial Mortgage').getRecordTypeId(),
         'Commercial Property Purchase' => Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commercial Property Purchase').getRecordTypeId(),
         'Debt Consolidation' => Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Debt Consolidation').getRecordTypeId(),
         'First Home Purchase' => Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('First Home Purchase').getRecordTypeId(),
         'Home Loan Construction' => Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Home Loan Construction').getRecordTypeId(),
         'Home Loan Purchase' => Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Home Loan Purchase').getRecordTypeId(),
         'Home Loan Refinance' => Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Home Loan Refinance').getRecordTypeId(),
         'Investment Property Purchase' => Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investment Property Purchase').getRecordTypeId(),
         'Next Home Purchase' => Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Next Home Purchase').getRecordTypeId()
   };
       
   public static Map<Id, String> allOppRecordTypeNameById = New Map<Id, String>{
          Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commercial Mortgage').getRecordTypeId() => 'Commercial Mortgage' ,
          Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commercial Property Purchase').getRecordTypeId() => 'Commercial Property Purchase',
          Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Debt Consolidation').getRecordTypeId() => 'Debt Consolidation',
          Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('First Home Purchase').getRecordTypeId() => 'First Home Purchase',
          Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Home Loan Construction').getRecordTypeId() => 'Home Loan Construction',
          Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Home Loan Purchase').getRecordTypeId() => 'Home Loan Purchase',
          Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Home Loan Refinance').getRecordTypeId() => 'Home Loan Refinance',
          Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Investment Property Purchase').getRecordTypeId() => 'Investment Property Purchase',
          Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Next Home Purchase').getRecordTypeId() => 'Next Home Purchase',
          Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Green Loan').getRecordTypeId() => 'Green Loan',
          Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vehicle Purchase').getRecordTypeId() => 'Vehicle Purchase',
          Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Home Improvement').getRecordTypeId() => 'Home Improvement',
          Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Personal Loan').getRecordTypeId() => 'Personal Loan'    
   };
    
    public static Map<String, Id> leadRecordTypeMap = New Map<String, Id>{
        'Solar' => Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Green Loan').getRecordTypeId(),
        'Home Improvement' => Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Home Improvement').getRecordTypeId(),
        'Debt Consolidation' => Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Debt Consolidation').getRecordTypeId()
    };
    public static boolean createDefualtRequest(ID oppId){
        List<Manage_Document__c> dmList = [SELECT Application_Type__c, Category__c, Description__c, Document__c, IsJoint__c, isBankStatment__c
                                           FROM Manage_Document__c where isDefault__c = true];
        boolean isSuccess = false; 
        try{
            Opportunity op = [Select Applicant_1__c , Applicant_2__c ,Applicant_1__r.PersonEmail ,Applicant_2__r.PersonEmail, Applicant_1__r.Firstname, Applicant_1__r.PersonContactId,Owner.Id,RecordType.Name  FROM Opportunity WHERE ID =: oppId];
            boolean scndryPrsn = String.isNotBlank(op.Applicant_2__c);
            List<Document_Requested__c> dRList = new List<Document_Requested__c>();
            for(Manage_Document__c item : dmList){
                if(item.IsJoint__c){
                    dRList.add(
                        new Document_Requested__c(
                            Document__c = item.Document__c,
                            Description__c = item.Description__c,
                            Category__c = item.Category__c,
                            Opportunity__c = oppId 
                        )
                    );
                }else{
                    dRList.add(
                        new Document_Requested__c(
                            Document__c = item.Document__c,
                            Description__c = item.Description__c,
                            Category__c = item.Category__c,
                            Person_Account__c = op.Applicant_1__c,
                            Opportunity__c = oppId 
                        )
                    );
                    if(scndryPrsn){
                        dRList.add(
                            new Document_Requested__c(
                                Document__c = item.Document__c,
                                Description__c = item.Description__c,
                                Category__c = item.Category__c,
                                Person_Account__c = op.Applicant_2__c,
                                Opportunity__c = oppId 
                            )
                        );
                    }
                }
                
            }
            if(dRList.size()>0){
                insert dRList;
                //sendEmail(op);
                isSuccess = true;
            } 
        }catch(exception ex){
            isSuccess = false;
            System.debug('error ===>'+ex.getMessage());
        }
        return isSuccess;
    }
    
    public static void sendEmail(Opportunity op){
        System.debug('==> '+op.Owner.Id);
        User us = [Select Name, FirstName, MobilePhone from User where ID=: op.Owner.Id][0];
        
        PageReference pageRef = new PageReference('/apex/Request_raised_by_Adviser_Email');
        pageRef.getParameters().put('RFN',op.Applicant_1__r.Firstname);
        pageRef.getParameters().put('UFN',us.FirstName);
        pageRef.getParameters().put('UN',us.Name);
        pageRef.getParameters().put('oppId',op.Id);
        pageRef.getParameters().put('UMN',us.MobilePhone);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(us.FirstName+' @ Parker Lane needs some document from you');
        string[] to = new string[] {op.Applicant_1__r.PersonEmail};
            mail.setToAddresses(to);
        if(String.isNotBlank(op.Applicant_2__r.PersonEmail))
            mail.setCcAddresses(new string[] {op.Applicant_2__r.PersonEmail});
        
        
        //added 2-3-22
        List<String>  personalRecTypeNameList = New List<String>{'Green Loan','Asset Finance','Commercial Solar Purchase','Commercial Asset Finance','Debt Consolidation','Home Improvement','Personal Loan','Vehicle Purchase'};
        List<String>  mortgageRecTypeNameList = New List<String>{'Commercial Mortgage','Commercial Property Purchase','Home Loan Construction','Home Loan Purchase','Home Loan Refinance','Opportunity (Wallet Share)'};
        String fromEmailAddress = 'hello@parkerlane.com.au';
        if(personalRecTypeNameList.contains(op.RecordType.Name)){
            fromEmailAddress = 'personalapplications@parkerlane.com.au';
            mail.setReplyTo('personalapplications@parkerlane.com.au');
        }else if(mortgageRecTypeNameList.contains(op.RecordType.Name)){
            //added 16-2-22
            if(String.isNotBlank(op.Credit_Analyst__c)){
                mail.setCcAddresses(new string[] {op.Credit_Analyst__r.Email});
            }
            fromEmailAddress = 'mortgageapplications@parkerlane.com.au';
            mail.setReplyTo(op.Owner.Email);
        }
        OrgWideEmailAddress[] getID = [select Id from OrgWideEmailAddress where Address =:fromEmailAddress];
        System.debug('id' + getID);
        if ( getID.size() > 0 ) {
            mail.setOrgWideEmailAddressId(getID.get(0).Id);
        }
        //END added 2-3-22
        mail.setSaveAsActivity(false);
        String mbody = '';
        if(!Test.isRunningTest()){
            mail.setHtmlBody(pageRef.getContent().toString());
            mbody = pageRef.getContent().toString();
        }
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(mail);
        try {
            System.debug(mail);
            
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(allmsg,false);
            
            insert new Task( Subject = us.FirstName+' @ Parker Lane needs some document from you',
                            WhoId = op.Applicant_1__r.PersonContactId, 
                            WhatId = op.Id, 
                            Status = 'Completed', 
                            TaskSubtype = 'Email', 
                            ActivityDate = System.Today(),
                            Description = mbody);
            
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
    
    public static void createException(String recordId, String className, String methodName, String ErrorMessage, String stackTrace, String lineNo,
                                       String errorType, String errorCause){
       Exception__c exe = New Exception__c(Record_Id__c = recordId,
                                           Method_Name__c = methodName, 
                                           Class_Name__c = className,
                                           Error_Message__c = ErrorMessage,
                                           Error_Cause__c = errorCause,
                                           Line_Number__c = lineNo,
                                           Stack_Trace__c = stackTrace,
                                           Error_Type__c = errorType);
       try{
           insert exe;
       } catch (Exception e) {
           System.debug(e.getMessage());
       }
   }
    
    public static List<String> getPicklistValues(String objectName, String fieldName){
        List<String> pickList = new List<String>();
        DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        DescribeFieldResult fieldResult = objResult.fields.getMap().get(fieldName).getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            pickList.add(f.getLabel());
        }   
        return pickList;
    }
}