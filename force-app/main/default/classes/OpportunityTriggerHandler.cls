public class OpportunityTriggerHandler {
    Id loanAccountRTId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Loan Account').getRecordTypeId();
    Set<Id> oppIds = new Set<Id>();
    List<Opportunity> changedOwner = new List<Opportunity>();
    public static Boolean isSummarySet;
    public OpportunityTriggerHandler(){}
    public static Boolean check = true;
    public static Boolean isByPassTrigger = false;
    public static Boolean isByPassPDF = false;
    public static Boolean isByPassApprovedValidation = false;
    public static Boolean isByPassValidation = false;
    public void roundRobinFunctionality(List<Opportunity> newOpportunity){
        List<string> recordTypes = new List<string>{'Solar','Green Loan','Home Improvement','Debt Consolidation','Personal Loan','Vehicle Purchase','Commercial Solar Purchase'};
            List<opportunity> oppList = new List<opportunity>();
        for(opportunity op : newOpportunity){
            if(String.isNotBlank(op.RecordTypeId)){
                if(recordTypes.contains(Schema.SObjectType.opportunity.getRecordTypeInfosById().get(op.RecordTypeId).getName())){
                    oppList.add(op);
                }
            }
        }
        if(oppList != null && oppList.size() > 0){
            System.enqueueJob(new roundRobinFunct(oppList));
        }
    }
    public void OnBeforeInsert(List<Opportunity> newOpportunity, Map<ID, Opportunity> newOpportunityMap){
        for(Opportunity opp: newOpportunity){
            if(opp.Total_Revenue__c > 0){
                opp.Amount = opp.Total_Revenue__c;
            }
            if(String.isNotBlank(opp.Lead_Conversion_Record_Type_Id__c)){
                String leadRTName = Schema.SObjectType.Lead.getRecordTypeInfosById().get(opp.Lead_Conversion_Record_Type_Id__c).getName();
                opp.Name = opp.Name + ', ' + leadRTName;
                Id oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(leadRTName).getRecordTypeId();
                opp.RecordTypeId = oppRTId;
                if(UtilityClass.mortgageRTMap.containsKey(leadRTName)){
                    opp.Loan_Amount__c = opp.HLHC_Amount__c;
                    opp.ufc_type__c= 'Percentage';
                    opp.ufc_rate_inc_gst__c = 0.0066;
                }
            }
            opp.Last_Stage_Change_Date__c = DateTime.now();
            if(opp.hlhc_offered__c){
                opp.Date_HLHC_Offered__c = Date.today();
            }
        }
    }
    public void OnAfterInsert(List<Opportunity> newOpportunity, List<Opportunity> oldOpportunity,
                              Map<ID, Opportunity> newOpportunityMap , Map<ID, Opportunity> oldOpportunityMa){
                                  Map<Id,Id> oppRTIdMap = New Map<Id,Id> ();
                                  List<Stage_Tracking__c> stageTrackingList = New List<Stage_Tracking__c>();
                                  for(Opportunity opp: newOpportunity){
                                      if(String.isNotBlank(opp.Lead_Conversion_Record_Type_Id__c) && opp.Lead_Conversion_Record_Type_Id__c != opp.RecordTypeId){
                                          String leadRTName = Schema.SObjectType.Lead.getRecordTypeInfosById().get(opp.Lead_Conversion_Record_Type_Id__c).getName();
                                          Id oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(leadRTName).getRecordTypeId();
                                          oppRTIdMap.put(opp.Id, oppRTId);
                                      }
                                      Stage_Tracking__c stageTracking = New Stage_Tracking__c();
                                      stageTracking.New_Stage__c = opp.StageName;
                                      stageTracking.Opportunity__c  = opp.Id;
                                      stageTracking.Stage_Changing_Date__c = System.Datetime.now();
                                      stageTracking.Expected_Revenue__c = opp.ExpectedRevenue;
                                      stageTracking.Stage_Count__c = 1;
                                      stageTrackingList.add(stageTracking);
                                  }
                                  if(!oppRTIdMap.isEmpty()){
                                      changeRecordTypeOnLeadConversion(oppRTIdMap);
                                  }
                                  if(!stageTrackingList.isEmpty()){
                                      upsert stageTrackingList;
                                  }
                                  InsertSectionTrackingRecord(newOpportunity);
                                  //Added by tazeem for update linechart
                                  if(newOpportunity.size() > 3){
                                      batchForLineChart obj = new batchForLineChart(newOpportunity);
                                      database.executeBatch(obj,5);
                                  }
                                  else{
                                      for(opportunity op : newOpportunity){
                                          Linechartcont.fillActivity(op.id);
                                      }
                                  }
                                  //Added by tazeem for update linechart
                              }
    public static void InsertSectionTrackingRecord(List<Opportunity> newOpp){
        List<Application_Section_Tracking__c > appTrackingList = New List<Application_Section_Tracking__c >();
        for(Opportunity opp : newOpp){
            Application_Section_Tracking__c  newApp = new Application_Section_Tracking__c ();
            newApp.Application_Section__c = opp.Current_Application_Sections__c;
            newApp.Start_Date__c = System.Datetime.now();
            newApp.Opportunity__c = opp.id;
            newApp.Page_Count__c = 1;
            appTrackingList.add(newApp);
        }
        if(!appTrackingList.isEmpty()){
            insert appTrackingList;
        }
    }
    @future
    public static void changeRecordTypeOnLeadConversion(Map<Id,Id> oppRTIdMap){
        List<Opportunity> oppList = New List<Opportunity>();
        for(Id oppId: oppRTIdMap.keySet()){
            Opportunity oppTemp = New Opportunity();
            oppTemp.Id = oppId;
            oppTemp.RecordTypeId = oppRTIdMap.get(oppId);
            oppList.add(oppTemp);
        }
        update oppList;
        List<Supplier__c> suppList = New List<Supplier__c>();
        for(Supplier__c supp: [SELECT Id, Name, Opportunity__c, Lead__r.ConvertedOpportunityId FROM Supplier__c
                               WHERE Lead__r.ConvertedOpportunityId IN: oppRTIdMap.keySet()]){
                                   supp.Opportunity__c = supp.Lead__r.ConvertedOpportunityId;
                                   suppList.add(supp);
                               }
        update suppList;
    }
    public void OnBeforeUpdate(List<Opportunity> newOpportunity, List<Opportunity> oldOpportunity, Map<ID, Opportunity> newOpportunityMap , Map<ID, Opportunity> oldOpportunityMap ){
        List<String> recTypeNames = New List<String>{'Green Loan','Debt Consolidation','Home Improvement','Personal Loan'};
            Map<Id,string> recordTypeMap = New Map<Id,string>();
        for(String str : recTypeNames){
            Id recid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(str).getRecordTypeId();
            string str2 = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosById().get(recid).getName();
            recordTypeMap.put(recid,str2);
        }
        // Map<Id,RecordType> recordTypeMap = New Map<Id,RecordType>([SELECT Id FROM RecordType WHERE Name in:recTypeNames]);
        String isMandateStageSkipped = '';
        List<String> appStagesList = UtilityClass.getPicklistValues('Opportunity', 'StageName');
        Set<Id> busProcessIds = New Set<Id>();
        Map<Id,Opportunity> oppMap = New Map<Id,Opportunity> ([SELECT Id, RecordTypeId, RecordType.BusinessProcessId
                                                               FROM Opportunity WHERE Id IN: newOpportunity]);
        list<Id> oldcdl = new list<Id>();
        list<Id> newcdl = new list<Id>();
        for(Opportunity oldOpp : oldOpportunity){
            oldcdl.add(oldOpp.SyncedQuoteId);
        }
        for(Opportunity newOpp : newOpportunity){
            newcdl.add(newOpp.SyncedQuoteId);
        }
        list<Id> result = new list<Id>();
        result.addAll(newcdl);
        result.addAll(oldcdl);
        if(oldOpportunity[0].SyncedQuoteId == null && newOpportunity[0].SyncedQuoteId != null){
            list<ContentDocumentLink> allCdLinks = new list<ContentDocumentLink> ();
            for(ContentDocumentLink cdDoc : [select Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility
                                             from ContentDocumentLink where LinkedEntityId IN : newcdl]){
                                                 allCdLinks.add(cdDoc);
                                             }
            //list<ContentVersion> cversion = [Select id, title, ContentDocumentId from ContentVersion where ContentDocumentId =: allCdLinks[0].ContentDocumentId];
            list<ContentVersion> cvList = new list<ContentVersion>();
            List<Document_Requested__c> dcList = new List<Document_Requested__c>();
            if(allCdLinks != null && allCdLinks.size() > 0){
                Document_Requested__c dc = new Document_Requested__c();
                //dc.Document__c = 'Purchase Quote';
                dc.Category__c = 'Purchase Invoice';
                dc.isComplete__c = true;
                dc.Person_Account__c =  newOpportunity[0].Applicant_1__c;
                dc.Opportunity__c = newOpportunity[0].Id;
                dcList.add(dc);
            }
            if(check){
                check = false;
                upsert dcList;
            }
            Set<id> isds = new Set<id>();
            list<ContentVersion> cdlSet = new list<ContentVersion>();
            for(ContentDocumentLink cv : allCdLinks){
                isds.add(cv.ContentDocumentId);
            }
            for(contentVersion cvs : [select id,contentDocumentId, title from contentVersion where contentDocumentId in: isds]){
                cvs.Document_Requested__c = dcList[0].id;
                cvs.Current_in_use__c = true;
                cvList.add(cvs);
            }
            update cvList;
            list<ContentDocumentLink> allCdLinksToInsert = new list<ContentDocumentLink> ();
            if(allCdLinks != null && allCdLinks.size() > 0){
                for(ContentVersion cdl : cvList){
                    ContentDocumentLink cdlink = new ContentDocumentLink();
                    cdlink.ContentDocumentId = cdl.ContentDocumentId;
                    cdlink.LinkedEntityId = newOpportunity[0].id;
                    cdlink.ShareType = 'I';
                    allCdLinksToInsert.add(cdlink);
                }
            }
            if(!allCdLinksToInsert.isEmpty()){
                upsert allCdLinksToInsert;
            }
        }
        if(oldOpportunity[0].SyncedQuoteId != null && newOpportunity[0].SyncedQuoteId == null){
            list<ContentDocumentLink> oldlist = [select Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility from ContentDocumentLink
                                                 where LinkedEntityId IN : oldcdl];
            list<ContentDocumentLink> oldopplist = [select Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility from ContentDocumentLink
                                                    where LinkedEntityId =: oldOpportunity[0].id];
            map<Id, ContentDocumentLink> quoteMapOpp = new map<Id, ContentDocumentLink>();
            for(ContentDocumentLink op : oldopplist){
                quoteMapOpp.put(op.ContentDocumentId, op);
            }
            list<ContentDocumentLink> delList = new list<ContentDocumentLink>();
            for(ContentDocumentLink cp : oldlist){
                if(quoteMapOpp.containskey(cp.ContentDocumentId)){
                    delList.add(quoteMapOpp.get(cp.ContentDocumentId));
                }
            }
            oldcdl.clear();
            delete delList;
        }
        for(Opportunity opp: oppMap.values()){
            if(opp.RecordTypeId!=NULL && opp.RecordType.BusinessProcessId !=NULL){
                busProcessIds.add(opp.RecordType.BusinessProcessId);
            }
        }
        Map<Id, String> businessProcessStagesMap = New Map<Id, String>();
        for(BusinessProcess bp: [SELECT Id, Name FROM BusinessProcess where Id IN: busProcessIds]){
            Configuration__c config = Configuration__c.getValues(bp.Name + ' Mandatory Stages');
            if(config != NULL) businessProcessStagesMap.put(bp.Id, config.Stages__c);
        }
        list<opportunity> updateOppList = new list<opportunity>();
        for(opportunity opp : newOpportunity){
            if(opp.StageName == 'Packs Back' && opp.StageName != oldOpportunityMap.get(opp.Id).StageName){
                if(opp.Applicant_1__c != null && opp.Applicant_2__c != null){
                    if(opp.Documents_Outstanding__c != 'No more documents outstanding' || !opp.App_1_VOI_eSign_Complete__c || !opp.App_2_VOI_eSign_Complete__c){
                        opp.addError('You can not move to Packs back until documents and voi are done!');
                    }
                }
                else if(opp.Applicant_1__c != null && opp.Applicant_2__c == null){
                    if(opp.Documents_Outstanding__c != 'No more documents outstanding' || !opp.App_1_VOI_eSign_Complete__c){
                        opp.addError('You can not move to Packs back until documents and voi are done!');
                    }
                }
            }
            else if(opp.StageName == 'Packs Back'){
                if(opp.Applicant_1__c != null && opp.Applicant_2__c != null){
                    if(opp.Documents_Outstanding__c != 'No more documents outstanding' || !opp.App_1_VOI_eSign_Complete__c || !opp.App_2_VOI_eSign_Complete__c){
                        opp.StageName = 'Packs Out';
                    }
                }
                else if(opp.Applicant_1__c != null && opp.Applicant_2__c == null){
                    if(opp.Documents_Outstanding__c != 'No more documents outstanding' || !opp.App_1_VOI_eSign_Complete__c){
                        opp.StageName = 'Packs Out';
                    }
                }
            }
            if(!String.isBlank(opp.Review_message__c) && opp.Review_message__c != oldOpportunityMap.get(opp.Id).Review_message__c){
                opp.Review_updated__c = system.today(); //code for updating reviewUpdated field by rakesh
            }
        }
        list<id> recTypeId = new list<id>{'0120o000001lPSGAA2','0120o000001lOfBAAU','0120o000001lPS9AAM','0120o000001lPS7AAM','0120o000001lOfDAAU','0120o000001lOfIAAU'};
            for(Opportunity opp: newOpportunity){
                Id bpId = oppMap.get(opp.Id).RecordType.BusinessProcessId;
                if(opp.RecordTypeId != NULL && bpId != NULL &&
                   businessProcessStagesMap.containsKey(bpId)){
                       for(String st: businessProcessStagesMap.get(bpId).split(';')){
                           system.debug('ConfigStage'+st);
                           if( !('Closed Lost').equalsIgnoreCase(opp.StageName) &&
                              appStagesList.indexOf(opp.StageName) > appStagesList.indexOf(st) &&
                              appStagesList.indexOf(st) > appStagesList.indexOf(oldOpportunityMap.get(opp.Id).StageName)){
                                  isMandateStageSkipped += st +', ';
                              }
                       }
                   }
                isMandateStageSkipped = isMandateStageSkipped.removeEnd(', ');
                if(opp.Total_Revenue__c != oldOpportunityMap.get(opp.Id).Total_Revenue__c){
                    opp.Amount = opp.Total_Revenue__c;
                }
                if(opp.OwnerId != oldOpportunityMap.get(opp.Id).OwnerId && (oldOpportunityMap.get(opp.Id).OwnerName__c == 'Chris White' || oldOpportunityMap.get(opp.Id).OwnerName__c == 'Lanecorp Site Guest User')){
                    changedOwner.add(opp);
                }
                if(opp.hlhc_offered__c != oldOpportunityMap.get(opp.Id).hlhc_offered__c && opp.hlhc_offered__c){
                    opp.Date_HLHC_Offered__c = Date.today();
                }
                if(opp.StageName != null && opp.StageName != oldOpportunityMap.get(opp.Id).StageName){
                    if(recTypeId.contains(opp.RecordTypeId)){
                        if(opp.StageName == 'Application' || opp.StageName == 'Approved' || opp.StageName == 'Settled (closed won)'){
                            opp.Application_Sections__c = 'All Done';
                            opp.Current_Application_Sections__c = 'All Done';
                        }
                    }
                    if(opp.StageName == 'Quote'){
                        opp.Application_Sections__c = 'Loan Recommendation';
                        opp.Current_Application_Sections__c = 'Loan Recommendation';
                    }
                    if(opp.StageName == 'Settled (closed won)' && recordTypeMap.keySet().contains(opp.recordTypeId)){
                        oppIds.add(opp.Id);
                    }
                    if(opp.StageName == 'Closed Lost'){
                        DocuSignRESTUtility.voidEnvelope(opp.Id);
                    }
                    opp.Last_Stage_Change_Date__c = System.now();
                }
                if(String.isNotBlank(isMandateStageSkipped)){
                    opp.StageName.addError('You cant skip mandatory stage: ' + isMandateStageSkipped);
                }
                if(opp.Last_Report_Ready_Access_Id__c != oldOpportunityMap.get(opp.Id).Last_Report_Ready_Access_Id__c){
                    opp.LRRA_Change__c = TRUE;
                }
                if(String.isNotBlank(opp.Report_Ready_Access_Ids__c) && String.isNotBlank(opp.Last_Report_Ready_Access_Id__c ) && opp.LRRA_Change__c &&
                   opp.Report_Ready_Access_Ids__c.contains(opp.Last_Report_Ready_Access_Id__c ) && opp.Sent_Case_Ready_Request__c == FALSE){
                       opp.Sent_Case_Ready_Request__c  = true;
                       opp.LRRA_Change__c = FALSE;
                       sendCaseReadyRequest( opp.Id, opp.Report_Ready_Access_Ids__c);
                   }
            }
        if(changedOwner.size() > 0){
            if(UserInfo.getUserId() != oldOpportunityMap.get(changedOwner[0].Id).OwnerId){
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'chris.white@parkerlane.com.au'];
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                if ( owea.size() > 0 ) {
                    message.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                message.toAddresses = new String[] {'chris.white@parkerlane.com.au'};
                    message.subject = UserInfo.getName()+' has changed an Opportunity from ' + oldOpportunityMap.get(changedOwner[0].Id).OwnerName__c+' to '+changedOwner[0].OwnerName__c;
                message.setHTMLBody('Dear Chris,<br/><br/>'+UserInfo.getName()+' changed the following Opportunity:<br/>Previous Owner: '+ oldOpportunityMap.get(changedOwner[0].Id).OwnerName__c+'<br/>New Owner: '+changedOwner[0].OwnerName__c+'<br/> Opportunity Name: <a href="https://lanecorp.my.salesforce.com/'+changedOwner[0].Id+'" target="_blank">'+changedOwner[0].Name+'</a><br/><br/>Thanks.');
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }
        }
        if(oppIds.size() > 0){
            List<Quote> quoteList = [Select Id,Loan_Term__c,Customer_Amount__c,Interest_Rate__c,Product__c, Name,Gruop_Name__c, Application__c,OpportunityId from Quote where OpportunityId IN : oppIds AND Application__c = true];
            List<FinServ__FinancialAccount__c> faList = new List<FinServ__FinancialAccount__c>();
            Map<Id,Id> oppToFA = new Map<Id,Id>();
            Map<Id,FinServ__FinancialAccount__c> quoteToFA = new Map<Id,FinServ__FinancialAccount__c>();
            if(quoteList.size() > 0){
                for(Quote quote : quoteList){
                    if(quote.Application__c){
                        FinServ__FinancialAccount__c finAccount = New FinServ__FinancialAccount__c();
                        finAccount.RecordTypeId = loanAccountRTId;
                        finAccount.FinServ__LoanTermMonths__c = quote.Loan_Term__c;
                        finAccount.FinServ__LoanAmount__c = quote.Customer_Amount__c;
                        finAccount.FinServ__InterestRate__c = quote.Interest_Rate__c;
                        finAccount.FinServ__ProductName__c = quote.Product__c;
                        finAccount.Name = quote.Name;
                        finAccount.Quote__c = quote.Id;
                        finAccount.FinServ__PrimaryOwner__c = newOpportunityMap.get(quote.OpportunityId).Applicant_1__c;
                        faList.add(finAccount);
                        quote.Financial_Account__c = true;
                        oppToFA.put(quote.OpportunityId,quote.Id);
                        quoteToFA.put(quote.Id,finAccount);
                    }
                }
                if(faList.size() > 0){
                    insert faList;
                }
                update quoteList;
                for(Opportunity opp: newOpportunity){
                    if(oppToFA.get(opp.Id) != null){
                        Id quoteId = oppToFA.get(opp.Id);
                        if(quoteToFA.get(quoteId) != null){
                            opp.FinServ__FinancialAccount__c = quoteToFA.get(quoteId).Id;
                        }
                    }
                }
            }else{
                Trigger.new[0].addError('We could not find any Application on this Opportunity.');
            }
        }
        LenderCreditContractRequired(newOpportunity, oldOpportunityMap);
        updateOppToFunding(newOpportunity, oldOpportunityMap);
    }
    public void OnAfterUpdate(List<Opportunity> newOpportunity, List<Opportunity> oldOpportunity, Map<ID, Opportunity> newOpportunityMap , Map<ID, Opportunity> oldOpportunityMap){
        Set<Id> oppIds = New Set<Id>();
        Map<Id, Map<String, Decimal>> oppStageCount = New Map<Id, Map<String, Decimal>>();
        Map<Id, Map<String, Decimal>> oppAppSecCount = New Map<Id, Map<String, Decimal>>();
        Map<Id, Map<String, Decimal>> oppAppPenCount = New Map<Id, Map<String, Decimal>>();
        id num;
        for(Opportunity opp: newOpportunity){
            oppIds.add(opp.Id);
            num=opp.Id;
        }
        Map<Id,Opportunity> oppMap = New Map<Id,Opportunity> ([SELECT Id,SyncedQuote.Product__r.Lender_Account__r.Funding_Email_Notifications__c,
                                                               SyncedQuote.Product__r.Lender_Account__r.Funding_Notification_Email_Address__c,StageName,Applicant_1__r.PersonContactId,
                                                               (SELECT Id, New_Stage__c, New_Stage_End_Date__c, Stage_Count__c
                                                                FROM Stage_Tracking__r ORDER BY name DESC, New_Stage_End_Date__c DESC NULLS FIRST),
                                                               (SELECT Id, Application_Section__c, Start_Date__c, End_Date__c, Page_Count__c
                                                                FROM ApplicationSectionTrackings__r ORDER BY name DESC, End_Date__c DESC NULLS FIRST),
                                                               (SELECT Id, Application_Pending__c, Start_Date__c, End_Date__c, Page_Count__c
                                                                FROM Application_Pending_Trackers__r ORDER BY End_Date__c DESC NULLS FIRST)
                                                               FROM Opportunity WHERE Id IN: oppIds]);
        for(Opportunity opp: oppMap.values()){
            Map<String, Decimal> stCount = oppStageCount.get(opp.Id);
            if(stCount == NULL){
                stCount = New Map<String, Decimal>();
            }
            for(Stage_Tracking__c st: opp.Stage_Tracking__r){
                Decimal count = stCount.get(st.New_Stage__c);
                if(count == NULL){
                    count = 0;
                }
                count++;
                stCount.put(st.New_Stage__c, count);
            }
            oppStageCount.put(opp.Id, stCount);
            //App sec count
            Map<String, Decimal> appSecCount = oppAppSecCount.get(opp.Id);
            if(appSecCount == NULL){
                appSecCount = New Map<String, Decimal>();
            }
            for(Application_Section_Tracking__c ast: opp.ApplicationSectionTrackings__r){
                Decimal count = appSecCount.get(ast.Application_Section__c);
                if(count == NULL){
                    count = 0;
                }
                count++;
                appSecCount.put(ast.Application_Section__c, count);
            }
            oppAppSecCount.put(opp.Id, appSecCount);
            //App pending count
            Map<String, Decimal> appPenCount = oppAppPenCount.get(opp.Id);
            if(appPenCount == NULL){
                appPenCount = New Map<String, Decimal>();
            }
            for(Application_Pending_Tracker__c ast: opp.Application_Pending_Trackers__r){
                Decimal count = appPenCount.get(ast.Application_Pending__c);
                if(count == NULL){
                    count = 0;
                }
                count++;
                appPenCount.put(ast.Application_Pending__c, count);
            }
            oppAppPenCount.put(opp.Id, appPenCount);
        }
        CreateStageTrackingRecords(newOpportunity, oldOpportunityMap, oppStageCount, oppMap);
        CreateAppSectionTrackingRecords(newOpportunity, oldOpportunityMap, oppAppSecCount, oppMap);
        CreateAppPendingTrackingRecords(newOpportunity, oldOpportunityMap, oppAppPenCount, oppMap);
        SendApplicationStageEmail(newOpportunity, oppMap, oldOpportunityMap);
        //Added by tazeem for update linechart
        boolean flag = false;
        for(opportunity op : newOpportunity){
            if(op.stageName != oldOpportunityMap.get(op.Id).stageName){
                flag = true;
            }
        }
        if(flag){
            batchForLineChart obj = new batchForLineChart(newOpportunity);
            database.executeBatch(obj,5);
        }
        /*this is for CS user Taks*/
        Set<id> oppId = new Set<id>();
        Id csUser;
        for(opportunity op : newOpportunity){
            if(op.Customer_Support_Person__c != oldOpportunityMap.get(op.id).Customer_Support_Person__c){
                oppId.add(op.Id);
                csUser = op.Customer_Support_Person__c;
            }
        }
        if(oppId != null && oppId.size() > 0 && csUser != null){
            List<task> taskForReasign = new List<task>();
            for(task ts : [select id,subject,OwnerId from task where WhatId IN : oppId AND Status != 'Completed' AND (subject LIKE : 'Welcome Call (application received)' OR subject Like : 'Conversion follow up call to complete application' OR subject LIKE : '%Information Outstanding follow up call.') ]){
                ts.OwnerId = csUser;
                taskForReasign.add(ts);
            }
            if(taskForReasign != null && taskForReasign.size() > 0){
                update taskForReasign;
            }
        }
        createTasksForCsUser(newOpportunity, oldOpportunityMap);
        /*this is for CS user Taks*/
        //Added by tazeem for update linechart
    }
    public static void SendApplicationStageEmail(List<Opportunity> newOpportunity, Map<Id,Opportunity> oppMap, Map<ID, Opportunity> oldOpportunityMap){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(Opportunity opp : oppMap.values()){
            if(opp.SyncedQuote.Product__r.Lender_Account__r.Funding_Email_Notifications__c &&
               opp.SyncedQuote.Product__r.Lender_Account__r.Funding_Notification_Email_Address__c != null
               && opp.StageName == 'Application' && oldOpportunityMap.get(opp.Id).StageName != 'Application'){
                   OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address =:UtilityClass.adminEmail];                   
                   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                   List<string> sendTo = new List<string>();
                   sendTo.add(opp.SyncedQuote.Product__r.Lender_Account__r.Funding_Notification_Email_Address__c);
                   mail.setToAddresses(sendTo);
                   if(owea.size() > 0){
                       mail.setorgWideEmailAddressId(Owea.get(0).Id);
                   }
                   mail.setUseSignature(false);
                   mail.setTargetObjectId(opp.Applicant_1__r.PersonContactId);
                   mail.Setwhatid(opp.id); 
                   mail.setSaveAsActivity(false);
                   mail.setTreatTargetObjectAsRecipient(false);
                   EmailTemplate et=[Select id, Subject, Body from EmailTemplate where Name = 'StageChangedToApplication']; 
                   mail.setTemplateId(et.id);
                   mails.add(mail);
               }
            if(!test.isRunningTest()){
                Messaging.sendEmail(mails);   
            }
        }                                                     
    }
    public static void createTasksForCsUser(List<opportunity> newOpportunity, map<id, opportunity> oldOpportunityMap){
        List<string> recordTypes = new List<string>{'Solar','Green Loan','Home Improvement','Debt Consolidation','Personal Loan','Vehicle Purchase'};
            List<opportunity> oppList = new List<opportunity>();
        List<id> csUser = new List<id>();
        for(opportunity op : newOpportunity){
            if(String.isNotBlank(op.RecordTypeId)){
                if(recordTypes.contains(Schema.SObjectType.opportunity.getRecordTypeInfosById().get(op.RecordTypeId).getName()) &&
                   op.StageName == 'CPA Done' && op.StageName != oldOpportunityMap.get(op.id).stageName
                  ){
                      oppList.add(op);
                  }
                if(op.Customer_Support_Person__c != null){
                    csUser.add(op.Customer_Support_Person__c);
                }
            }
            if(csUser == null || csUser.size() == 0){
                csUser.add([select id, name from user where username =: System.Label.Admin_User_Name].id);
            }
        }
        if(oppList != null && oppList.size() > 0){
            date dueDate = checkForDuedate(system.today());
            List<task> tskList = new List<task>();
            string body = '';
            string title = 'Welcome Call (application received)';
            Boolean flag = false;
            for(Task ts : [select id from task where WhatId IN : oppList AND Status != 'Completed' AND Subject =: title]){
                flag = true;
                break;
            }
            if(!flag){
                for(opportunity op : oppList){
                    Task t = new Task();
                    t.Subject = title;
                    t.WhatId = op.Id;
                    t.OwnerId = csUser[0];
                    t.Status = 'Not Started';
                    t.ActivityDate = dueDate;
                    t.Priority = 'High';
                    tskList.add(t);
                    body = 'Application Completed for '+ op.Name + ' Click here to make a welcome call.';
                }
                insert tskList;
                CustomNotificationFromApex.notifyUsers(oppList,csUser,title,body);
            }
        }
        Set<id> oppId = new Set<id>();
        List<string> stageNm = new List<string>{'Nurturing', 'Working', 'Quote', 'Deciding', 'CPA Started', 'CPA Done'};
            for(opportunity op : newOpportunity){
                if(String.isNotBlank(op.RecordTypeId)){
                    if(recordTypes.contains(Schema.SObjectType.opportunity.getRecordTypeInfosById().get(op.RecordTypeId).getName()) &&
                       !stageNm.contains(op.StageName) && op.StageName != oldOpportunityMap.get(op.id).stageName
                      ){
                          if(!string.isBlank(op.Applicant_1_Phone_Number__c)){
                              oppId.add(op.Id);
                          }
                      }
                }
            }
        if(oppId != null && oppId.size() > 0){
            List<task> tsk = new List<task>();
            for(Task ts : [select id from task where WhatId IN : oppId AND Status != 'Completed' AND Subject = 'Conversion follow up call to complete application']){
                tsk.add(ts);
            }
            system.debug('-=taks size ++'+tsk.size());
            if(tsk != null && tsk.size() > 0){
                delete tsk;
            }
        }
        List<opportunity> opList = new List<opportunity>();
        for(opportunity op : newOpportunity){
            if(String.isNotBlank(op.RecordTypeId)){
                if(recordTypes.contains(Schema.SObjectType.opportunity.getRecordTypeInfosById().get(op.RecordTypeId).getName()) &&
                   op.StageName == 'CPA Started' && op.StageName != oldOpportunityMap.get(op.id).stageName
                  ){
                      if(!string.isBlank(op.Applicant_1_Phone_Number__c)){
                          opList.add(op);
                      }
                  }
            }
        }
        System.debug('-=-test---'+opList);
        if(opList!= null && opList.size() > 0){
            date dueDate = checkForDuedate(system.today());
            List<task> tskList = new List<task>();
            string body = 'Application Abandoned yesterday. Call to offer assistance.';
            string title = 'Conversion follow up call to complete application';
            Boolean flag = false;
            for(Task ts : [select id from task where WhatId IN : opList AND Status != 'Completed' AND Subject =: title]){
                flag = true;
                break;
            }
            if(!flag){
                for(opportunity op : opList){
                    Task t = new Task();
                    t.Subject = title;
                    t.WhatId = op.Id;
                    t.OwnerId = csUser[0];
                    t.Status = 'Not Started';
                    t.ActivityDate = (dueDate == system.today() ? system.today().addDays(1) : dueDate);
                    t.Priority = 'High';
                    tskList.add(t);
                }
                insert tskList;
                CustomNotificationFromApex.notifyUsers(opList,csUser,title,body);
            }
        }
        Set<id> oppIdsforTsk = new Set<Id>();
        for(opportunity opp : newOpportunity){
            if(recordTypes.contains(Schema.SObjectType.opportunity.getRecordTypeInfosById().get(opp.RecordTypeId).getName()) &&
               opp.StageName != oldOpportunityMap.get(opp.id).stageName && (opp.StageName != 'CPA Done' || opp.StageName != 'Packs Out') ){
                   oppIdsforTsk.add(opp.id);
               }
        }
        List<task> taskTodelete = new List<task>();
        for(task tsk : [select id, Subject from task where WhatId IN : oppIdsforTsk AND subject Like '%Information Outstanding follow up call.']){
            taskTodelete.add(tsk);
        }
        if(taskTodelete!= null && taskTodelete.size() > 0){
            delete taskTodelete;
        }
    }
    /*Created by tazeem for create tasks*/
    /*created by tazeem for check weekdays*/
    public static date checkForDuedate(date dt){
        date dueDate = dt;
        BusinessHours bhs = [select id,MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime from BusinessHours WHERE IsDefault = true LIMIT 1];
        DateTime myDateTime = DateTime.now();
        String dayOfWeek = myDateTime.format('EEEE');
        Datetime userTime = datetime.now();
        string datetimeInGmt = userTime.format('dd/MM/yy h:mm a', 'Australia/Sydney');
        Datetime dtime = Datetime.parse(datetimeInGmt);
        Time myTime = dtime.time();
        system.debug('MYTIME '+myTime);
        if(!(dayOfWeek.equalsIgnoreCase('Sunday') || dayOfWeek.equalsIgnoreCase('Saturday'))){
            string startfield = dayOfWeek+'StartTime';
            string endfield = dayOfWeek+'EndTime';
            if(myTime >= (time)bhs.get(startfield) && myTime <= (time)bhs.get(endfield)){
                system.debug('--in-');
                dueDate = system.today();
            }
            else{
                if(dayOfWeek.equalsIgnoreCase('Saturday')){
                    dueDate = date.valueOf(myDateTime.addDays(2));
                }
                else if(dayOfWeek.equalsIgnoreCase('Sunday')){
                    dueDate = date.valueOf(myDateTime.addDays(1));
                }
                else{
                    dueDate = date.valueOf(myDateTime.addDays(1));
                }
            }
        }
        system.debug('-=-='+dueDate);
        return dueDate;
    }
    /*created by tazeem for check weekdays*/
    public static void CreateStageTrackingRecords(List<Opportunity> newOpportunity, Map<ID, Opportunity> oldOpportunityMap,
                                                  Map<Id, Map<String, Decimal>> oppStageCount, Map<Id,Opportunity> oppMap){
                                                      List<Stage_Tracking__c> stageTrackingList = New List<Stage_Tracking__c>();
                                                      for(Opportunity opp: newOpportunity){
                                                          Opportunity oppTemp = New Opportunity();
                                                          String oldStage = oldOpportunityMap.get(opp.Id).StageName;
                                                          if(opp.StageName  != oldStage  ){
                                                              Stage_Tracking__c stageTracking = New Stage_Tracking__c();
                                                              stageTracking.New_Stage__c = opp.StageName;
                                                              stageTracking.Old_Stage__c = oldStage;
                                                              stageTracking.Opportunity__c  = opp.Id;
                                                              stageTracking.Stage_Changing_Date__c = System.Datetime.now();
                                                              stageTracking.New_Stage_End_Date__c = oldOpportunityMap.get(opp.Id).Last_Stage_Change_Date__c;
                                                              if(oppStageCount.ContainsKey(opp.Id) && oppStageCount.get(opp.Id).ContainsKey(opp.StageName)){
                                                                  stageTracking.Stage_Count__c = oppStageCount.get(opp.Id).get(opp.StageName)+1;
                                                              }else{
                                                                  stageTracking.Stage_Count__c = 1;
                                                              }
                                                              stageTracking.Expected_Revenue__c = opp.ExpectedRevenue;
                                                              stageTracking.Change_in_Expected_Revenue__c = 0;
                                                              if(oldOpportunityMap.get(opp.Id).ExpectedRevenue == NULL){
                                                                  stageTracking.Change_in_Expected_Revenue__c = opp.ExpectedRevenue;
                                                              }else{
                                                                  stageTracking.Change_in_Expected_Revenue__c = opp.ExpectedRevenue - oldOpportunityMap.get(opp.Id).ExpectedRevenue;
                                                              }
                                                              stageTrackingList.add(stageTracking);
                                                              if(!oppMap.get(opp.Id).Stage_Tracking__r.isEmpty()){
                                                                  Stage_Tracking__c oldStageTrack = oppMap.get(opp.Id).Stage_Tracking__r[0];
                                                                  oldStageTrack.New_Stage_End_Date__c = System.Datetime.now();
                                                                  stageTrackingList.add(oldStageTrack);
                                                              }
                                                          }
                                                      }
                                                      if(!stageTrackingList.isEmpty()){
                                                          upsert stageTrackingList;
                                                      }
                                                  }
    public static void CreateAppSectionTrackingRecords(List<Opportunity> newOpportunity, Map<ID, Opportunity> oldOpportunityMap,
                                                       Map<Id, Map<String, Decimal>> oppAppSecCount, Map<Id,Opportunity> oppMap){
                                                           List<Application_Section_Tracking__c> appSecTrackingList = New List<Application_Section_Tracking__c>();
                                                           for(Opportunity opp: newOpportunity){
                                                               Opportunity oppTemp = New Opportunity();
                                                               String oldAppSec = oldOpportunityMap.get(opp.Id).Current_Application_Sections__c;
                                                               if(opp.Current_Application_Sections__c != oldAppSec  ){
                                                                   Application_Section_Tracking__c appSecTracking = New Application_Section_Tracking__c();
                                                                   appSecTracking.Application_Section__c = opp.Current_Application_Sections__c;
                                                                   appSecTracking.Previous_Application_Section__c = oldAppSec;
                                                                   appSecTracking.Opportunity__c  = opp.Id;
                                                                   appSecTracking.Start_Date__c = System.Datetime.now();
                                                                   if(oppAppSecCount.ContainsKey(opp.Id) && oppAppSecCount.get(opp.Id).ContainsKey(opp.Current_Application_Sections__c)){
                                                                       appSecTracking.Page_Count__c = oppAppSecCount.get(opp.Id).get(opp.Current_Application_Sections__c)+1;
                                                                   }else{
                                                                       appSecTracking.Page_Count__c = 1;
                                                                   }
                                                                   appSecTrackingList.add(appSecTracking);
                                                                   if(!oppMap.get(opp.Id).ApplicationSectionTrackings__r.isEmpty()){
                                                                       Application_Section_Tracking__c oldAppSecTracking = oppMap.get(opp.Id).ApplicationSectionTrackings__r[0];
                                                                       oldAppSecTracking.End_Date__c = System.Datetime.now();
                                                                       appSecTrackingList.add(oldAppSecTracking);
                                                                   }
                                                               }
                                                           }
                                                           if(!appSecTrackingList.isEmpty()){
                                                               upsert appSecTrackingList;
                                                           }
                                                       }
    public static void CreateAppPendingTrackingRecords(List<Opportunity> newOpportunity, Map<ID, Opportunity> oldOpportunityMap,
                                                       Map<Id, Map<String, Decimal>> oppAppPenCount, Map<Id,Opportunity> oppMap){
                                                           List<Application_Pending_Tracker__c> appPenTrackingList = New List<Application_Pending_Tracker__c>();
                                                           for(Opportunity opp: newOpportunity){
                                                               Opportunity oppTemp = New Opportunity();
                                                               String oldAppPen = oldOpportunityMap.get(opp.Id).Application_Pending_Status__c;
                                                               if(opp.Application_Pending_Status__c != oldAppPen){
                                                                   Application_Pending_Tracker__c appPenTracking = New Application_Pending_Tracker__c();
                                                                   appPenTracking.Application_Pending__c = opp.Application_Pending_Status__c;
                                                                   appPenTracking.Previous_Application_Pending__c = oldAppPen;
                                                                   appPenTracking.Opportunity__c  = opp.Id;
                                                                   appPenTracking.Start_Date__c = System.Datetime.now();
                                                                   if(oppAppPenCount.ContainsKey(opp.Id) && oppAppPenCount.get(opp.Id).ContainsKey(opp.Application_Pending_Status__c)){
                                                                       appPenTracking.Page_Count__c = oppAppPenCount.get(opp.Id).get(opp.Application_Pending_Status__c)+1;
                                                                   }else{
                                                                       appPenTracking.Page_Count__c = 1;
                                                                   }
                                                                   appPenTrackingList.add(appPenTracking);
                                                                   system.debug('oppMap.get(opp.Id)'+oppMap.get(opp.Id));
                                                                   system.debug('oppMap.get(opp.Id).Application_Pending_Trackers__r'+oppMap.get(opp.Id).Application_Pending_Trackers__r);
                                                                   if(!oppMap.get(opp.Id).Application_Pending_Trackers__r.isEmpty()){
                                                                       system.debug('Enter'+oppMap.get(opp.Id).Application_Pending_Trackers__r[0]);
                                                                       Application_Pending_Tracker__c oldAppPenTracking = oppMap.get(opp.Id).Application_Pending_Trackers__r[0];
                                                                       oldAppPenTracking.End_Date__c = System.Datetime.now();
                                                                       appPenTrackingList.add(oldAppPenTracking);
                                                                   }
                                                               }
                                                           }
                                                           if(!appPenTrackingList.isEmpty()){
                                                               upsert appPenTrackingList;
                                                           }
                                                       }
    @future(callout=true)
    public static void sendCaseReadyRequest(String oppId, String reportReadyAccessIds){
        //MOGO api request
        //String body = '{"providerId" : 250,' + '"username" : "ParkerLaneUAT",' + '"password" : "4e6J7ACd",' + '"caseId" : "' + oppId+ '","accessIds" : [' + reportReadyAccessIds + '] }';
        String body = '{"providerId" : 252,' + '"username" : "ParkerLane",' + '"password" : "XxmLe2kN",' + '"caseId" : "' + oppId+ '","accessIds" : [' + reportReadyAccessIds + '] }';
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        //req.setEndpoint('https://api.auuat.mogoplus.com/clovelly/case/reportRequest');
        req.setEndpoint('https://api.aulive.mogoplus.com/clovelly/case/reportRequest');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(body);
        Map<String, Object> rest = new Map<String, Object>();
        HttpResponse res = http.send(req);
        rest = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
    }
    public void updateOppFields(List<opportunity> oppList, Map<id, Opportunity> oldMap){
        List<String> recTypeNames = New List<String>{'Green Loan','Solar','Debt Consolidation','Home Improvement','Personal Loan','Vehicle Purchase', 'Commercial Solar Purchase'};
            List<String> satgeNames = New List<String>{'Application', 'Approved', 'Settled (closed won)', 'Closed Lost'};
                For(opportunity op : oppList){
                    string recordtypename = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(op.RecordTypeId).getname();
                    if(recTypeNames.contains(recordtypename)){
                        if(oldMap.containsKey(op.Id)){
                            if(!oldMap.get(op.Id).StageName.equals(op.StageName)){
                                if(satgeNames.contains(op.StageName)){
                                    string val = op.Previous_Application_Pending_Notes__c;
                                    string valFor = '';
                                    Date d = date.today();
                                    String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('MM-d-YYYY');
                                    system.debug(dt);
                                    if(string.isBlank(val)){
                                        if(op.Escalation__c == true){
                                            valFor = oldMap.get(op.Id).StageName+ ',' + dt + ' - ' + op.Application_Pending_Status__c + ': '+ op.Application_Pending_Notes__c + ' (escalated)\n';
                                            System.debug(valFor);
                                            op.Previous_Application_Pending_Notes__c = valFor;
                                        }
                                        else{
                                            valFor = oldMap.get(op.Id).StageName+ ',' + dt + ' - ' + op.Application_Pending_Status__c + ': '+ op.Application_Pending_Notes__c + '\n';
                                            System.debug(valFor);
                                            op.Previous_Application_Pending_Notes__c = valFor;
                                        }
                                    }
                                    else{
                                        if(op.Escalation__c == true){
                                            valFor = oldMap.get(op.Id).StageName+ ',' + dt + ' - ' + op.Application_Pending_Status__c + ': '+ op.Application_Pending_Notes__c + ' (escalated)\n';
                                            op.Previous_Application_Pending_Notes__c = valFor + oldMap.get(op.Id).Previous_Application_Pending_Notes__c;
                                        }
                                        else{
                                            valFor = oldMap.get(op.Id).StageName+ ',' + dt + ' - ' + op.Application_Pending_Status__c + ': '+ op.Application_Pending_Notes__c + '\n';
                                            op.Previous_Application_Pending_Notes__c = valFor + oldMap.get(op.Id).Previous_Application_Pending_Notes__c;
                                        }
                                    }
                                    op.Application_Pending_Notes__c = '';
                                    op.Application_Pending_Status__c = '';
                                    op.Escalation__c = false;
                                }
                            }
                        }
                    }
                }
            updateReferralFee(oppList, oldMap);
    }
    public void OnAfterUpdate2(List<opportunity> oppList, map<id,opportunity> oldoppmap){
        List<opportunity> oppListToUpdate= new List<opportunity>();
        List<Id> oppIdList= new List<Id>();
        Set<Id> applicant2 = new Set<Id>();
        Set<Id> applicant2Removed = new Set<Id>();
        for(Opportunity opp: oppList){
            if(opp.Applicant_1__c != oldoppmap.get(opp.Id).Applicant_1__c || opp.Applicant_2__c != oldoppmap.get(opp.Id).Applicant_2__c || opp.RecordTypeId != oldoppmap.get(opp.Id).RecordTypeId){
                oppIdList.add(opp.Id);
            }
        }
        if(!oppIdList.isEmpty()){
            list<opportunity> oppnewlist = [select id,name,Applicant_Details_Change__c, Number_of_applicants__c,Applicant_1__c,Applicant_2__c,Applicant_1__r.FirstName,Applicant_1__r.LastName,Applicant_2__r.FirstName,Applicant_2__r.LastName,RecordType.Name from opportunity where id IN: oppIdList];
            For(Opportunity opp: oppnewlist){
                string nm = '';
                system.debug('opp'+opp.Applicant_1__r.FirstName);
                if(opp.Applicant_1__c != oldoppmap.get(opp.Id).Applicant_1__c || opp.Applicant_2__c != oldoppmap.get(opp.Id).Applicant_2__c || opp.RecordTypeId != oldoppmap.get(opp.Id).RecordTypeId){
                    if(opp.Applicant_2__c != null && opp.Applicant_1__c == null){
                        nm = opp.Applicant_2__r.FirstName + ' ' + opp.Applicant_2__r.LastName + ', ' + opp.recordType.Name;
                    }
                    if(opp.Applicant_1__c != null && opp.Applicant_2__c == null){
                        nm = opp.Applicant_1__r.FirstName + ' ' + opp.Applicant_1__r.LastName + ', ' + opp.recordType.Name;
                    }
                    if(opp.Applicant_1__c != null && opp.Applicant_2__c != null){
                        if(opp.Applicant_1__r.LastName.equalsIgnoreCase(opp.Applicant_2__r.LastName)){
                            nm = opp.Applicant_1__r.FirstName + ' and ' + opp.Applicant_2__r.FirstName + ' ' + opp.Applicant_1__r.LastName + ', ' + opp.recordType.Name;
                        }
                        else{
                            nm = opp.Applicant_1__r.FirstName +' ' + opp.Applicant_1__r.LastName +' and ' + opp.Applicant_2__r.FirstName +' ' + opp.Applicant_2__r.LastName + + ', ' + opp.recordType.Name;
                        }
                    }
                    System.debug('name++'+nm);
                    opp.name = nm;
                    opp.Applicant_Details_Change__c = true;
                    oppListToUpdate.add(opp);
                }
            }
            update oppListToUpdate;
        }
    }
    public void sendCustomerEmail(List<opportunity> oppList,map<id,opportunity> oldoppmap){
        boolean ApprovalMailAfterVariation = false;
        List<String>  recordTypeList = New List<String>{'Personal Loan', 'Debt Consolidation','Green Loan','Home Improvement','Vehicle Purchase'};
            Set<string> oppIds = new Set<string>();
        for(opportunity opp : oppList){
            if(recordTypeList.contains(Schema.SObjectType.opportunity.getRecordTypeInfosById().get(opp.RecordTypeId).getName())){
                if(opp.StageName != oldoppmap.get(opp.id).stageName && (opp.StageName == 'Application' || opp.StageName == 'Approved' || opp.StageName == 'Funding')){
                    oppIds.add(opp.Id);
                    if((opp.StageName == 'Funding' && !opp.Funding_Variation_Request__c && oldoppmap.get(opp.id).Funding_Variation_Request__c)){
                        ApprovalMailAfterVariation = true;
                    }
                }
            }
        }
        if(oppIds != null && oppIds.size() > 0){
            sendEmailsToCustomerandReferrers(oppIds,ApprovalMailAfterVariation);
        }
    }
    @future
    public static void sendEmailsToCustomerandReferrers(Set<string> oppids, boolean ApprovalMailAfterVariation){
        List<Opportunity> newOppList = [SELECT Id,Name,StageName,Contact_1__c,Applicant_1__c,Applicant_2__c,Applicant_1_Email__c,Applicant_2_Email__c,
                                        FinServ__ReferredByContact__r.AccountId, FinServ__ReferredByContact__r.Email ,RecordType.Name,SyncedQuote.Id,SyncedQuote.Application__c FROM Opportunity
                                        WHERE Id IN : oppids];
        /*Set<id> oppids = new Set<id>();
if(newOppList.size() > 0){
for(Opportunity opp : newOppList){
if(opp.StageName == 'Application' || opp.StageName == 'Approved'){
oppids.add(opp.id);
}
}
}*/
        if(oppids != null && oppids.size() > 0){
            Set<Id> CDId = new Set<Id>();
            if(oppids.size() > 0){
                for(ContentDocumentLink Cd : [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN : oppids]){
                    CDId.add(Cd.ContentDocumentId);
                }
            }
            List<ContentVersion> cvList = new List<ContentVersion>();
            if(CDId != null  && CDId.size() > 0){
                cvList = [SELECT ContentDocumentId,VersionData,Title,FileType,Current_in_use__c FROM ContentVersion WHERE ContentDocumentId IN: CDId AND Category__c = 'Lender Credit Contract' AND Current_in_use__c = true];
            }
            System.debug('ContentVersion'+CvList.Size());
            List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
            if(!cvList.isEmpty()){
                for(ContentVersion cv : cvList){
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(cv.Title+'.'+cv.FileType);
                    efa.setContentType('Application/'+cv.FileType);
                    efa.setBody(cv.VersionData);
                    efaList.add(efa);
                }
            }
            String Accountid;
            map<id, list<string>> accIdconEmailMap = new map<id, list<string>>();
            set<id> refIds = new set<id>();
            for(Opportunity opp2 :newOppList){
                if(opp2.FinServ__ReferredByContact__c != null){
                    Accountid = opp2.FinServ__ReferredByContact__r.AccountId;
                    if(!accIdconEmailMap.containsKey(Accountid )){
                        accIdconEmailMap.put(Accountid, new list<string>());
                    }
                    refIds.add(opp2.FinServ__ReferredByContact__r.id);
                }
            }
            for(Contact acc : [SELECT id,Accountid, Email FROM Contact WHERE AccountId =: accIdconEmailMap.keyset() AND id NOT IN:refIds AND Admin__c=True]){
                if(accIdconEmailMap.containskey(acc.Accountid)){
                    if(acc.Email != null){
                        accIdconEmailMap.get(acc.Accountid).add(acc.Email);
                    }
                }
            }
            List<String>  emailTemplateNames = New List<String>{'Customer Application Email 1: All Lenders','Customer Approval Email 1: All Lenders','Referrer Approval Email 1: All Lenders','Customer Approval Email for Applicant 2'};
                Map<String, Id> emailTempIdMap = New Map<String, Id>();
            for(EmailTemplate emailTemp: [SELECT id, Name  FROM EmailTemplate WHERE Name IN: emailTemplateNames]){
                emailTempIdMap.put(emailTemp.Name, emailTemp.Id);
            }
            OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address =:UtilityClass.adminEmail];
            List<Messaging.Email> emailList = new List<Messaging.Email>();
            for(Opportunity opp : newOppList ) {
                if(opp.StageName == 'Application' && opp.SyncedQuote.Id !=Null && opp.SyncedQuote.Application__c==True){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateId(emailTempIdMap.get('Customer Application Email 1: All Lenders'));
                    mail.setTargetObjectId(opp.Contact_1__c);
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.setUseSignature(false);
                    mail.Setwhatid(opp.Id);
                    if( owea.size() > 0){
                        mail.setorgWideEmailAddressId(Owea.get(0).Id);
                    }
                    List<string> sendTo = new List<string>();
                    if(opp.Applicant_1__c !=Null && opp.Applicant_2__c != null){
                        SendTo.add(opp.Applicant_1_Email__c);
                        SendTo.add(opp.Applicant_2_Email__c);
                    }
                    if(opp.Applicant_1__c != null  && opp.Applicant_2__c == null){
                        SendTo.add(opp.Applicant_1_Email__c);
                    }
                    //System.debug(SendTo);
                    mail.setToAddresses(sendTo);
                    mail.setBccAddresses(new String[]{'chris.white@parkerlane.com.au'});
                    mail.setReplyTo(UtilityClass.adminEmail);
                    emailList.add(mail);
                }
                if((opp.StageName == 'Approved' && opp.SyncedQuote.Id !=Null && opp.SyncedQuote.Application__c==True) || ApprovalMailAfterVariation){
                    List<String> applicantEmailList = new List<String>();
                    if(opp.Applicant_1__c !=Null && opp.Applicant_2__c != null){
                        applicantEmailList.add(opp.Applicant_1_Email__c);
                        applicantEmailList.add(opp.Applicant_2_Email__c);
                    }
                    if(opp.Applicant_1__c != null && opp.Applicant_2__c == null){
                        applicantEmailList.add(opp.Applicant_1_Email__c);
                    }
                    if(!applicantEmailList.isEmpty()){
                        for(String eml : applicantEmailList){
                            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
                            if(eml == opp.Applicant_1_Email__c){
                                mail1.setTemplateId(emailTempIdMap.get('Customer Approval Email 1: All Lenders'));
                            }
                            if(eml == opp.Applicant_2_Email__c){
                                mail1.setTemplateId(emailTempIdMap.get('Customer Approval Email for Applicant 2'));
                            }
                            mail1.setTargetObjectId(opp.Contact_1__c);
                            mail1.setTreatTargetObjectAsRecipient(false);
                            mail1.Setwhatid(opp.Id);
                            mail1.setUseSignature(false);
                            if( owea.size() > 0){
                                mail1.setorgWideEmailAddressId(Owea.get(0).Id);
                            }
                            List<string> sendTo = new List<string>();
                            SendTo.add(eml);
                            mail1.setToAddresses(sendTo);
                            mail1.setBccAddresses(new String[]{'chris.white@parkerlane.com.au'});
                            mail1.setReplyTo(UtilityClass.adminEmail);
                            if(efaList != Null){
                                mail1.setFileAttachments(efaList);
                            }
                            emailList.add(mail1);
                        }
                    }
                }
                if(opp.StageName == 'Approved' && opp.SyncedQuote.Id !=Null && opp.SyncedQuote.Application__c==True && opp.FinServ__ReferredByContact__c !=Null ){
                    Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();
                    mail2.setTemplateId(emailTempIdMap.get('Referrer Approval Email 1: All Lenders'));
                    mail2.setTargetObjectId(opp.Contact_1__c);
                    mail2.setTreatTargetObjectAsRecipient(false);
                    mail2.Setwhatid(opp.Id);
                    mail2.setUseSignature(false);
                    if( owea.size() > 0){
                        mail2.setorgWideEmailAddressId(Owea.get(0).Id);
                    }
                    List<string> sendList = new List<string>();
                    SendList.add(opp.FinServ__ReferredByContact__r.Email);
                    SendList.addAll(accIdconEmailMap.get(opp.FinServ__ReferredByContact__r.AccountId));
                    system.debug(accIdconEmailMap.get(opp.FinServ__ReferredByContact__r.AccountId));
                    system.debug('sendList is==='+SendList);
                    mail2.setToAddresses(SendList);
                    mail2.setBccAddresses(new String[]{'chris.white@parkerlane.com.au'});
                    mail2.setReplyTo(UtilityClass.adminEmail);
                    emailList.add(mail2);
                }
                if(!emailList.isEmpty()){
                    Messaging.sendEmail(emailList);
                }
            }
        }
    }
    public void LenderCreditContractRequired(List<opportunity> oppList,Map<ID, Opportunity> oldOpportunityMap){
        List<String> recTypeNames = New List<String>{'Personal Loan', 'Debt Consolidation','Green Loan','Home Improvement','Vehicle loan'};
            Set<id> oppIds = new Set<id>();
        for(Opportunity opp : oppList){
            if(opp.StageName == 'Approved' && oldOpportunityMap.get(opp.Id).StageName != 'Approved'){
                oppIds.add(opp.id);
            }
            if((opp.StageName == 'Nurturing' && oldOpportunityMap.get(opp.Id).StageName != 'Nurturing') && recTypeNames.contains(UtilityClass.allOppRecordTypeNameById.get(opp.recordTypeId))){
                if(opp.Closed_Lost_Reason__c == null || String.isBlank(opp.Closed_Reason__c)){
                    opp.addError('You must update Close Lost Reason and Closed Lost Notes before you can proceed to this stage');
                }
            }
            if((opp.StageName == 'Closed Lost' && oldOpportunityMap.get(opp.Id).StageName != 'Closed Lost') && recTypeNames.contains(UtilityClass.allOppRecordTypeNameById.get(opp.recordTypeId))){
                if(opp.Closed_Lost_Reason__c == null || String.isBlank(opp.Closed_Reason__c)){
                    opp.addError('You must update Close Lost Reason and Closed Lost Notes before you can proceed to this stage');
                }
            }
        }
        if(oppIds != null && oppIds.size() > 0){
            Map<Id, Boolean> docCheckMap = New Map<Id, Boolean>();
            Map<Id, Id> docIdWithLinkedIdMap = New Map<Id, Id>();
            List<ContentDocumentLink> cdList = [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: oppIds];
            for(ContentDocumentLink Cd : cdList){
                docIdWithLinkedIdMap.put(Cd.ContentDocumentId, Cd.LinkedEntityId);
            }
            for(ContentVersion cv : [SELECT ContentDocumentId,VersionData,Title FROM ContentVersion WHERE ContentDocumentId =: docIdWithLinkedIdMap.keySet() AND Category__c = 'Lender Credit Contract']){
                docCheckMap.put(docIdWithLinkedIdMap.get(cv.ContentDocumentId), true);
            }
            Set<id> syncQuoteIds = new Set<id>();
            for(Opportunity opp : oppList){
                syncQuoteIds.add(opp.SyncedQuoteId);
            }
            Map<Id,boolean> OppIdProductMap= New Map<Id,boolean>();
            for(Quote qt : [SELECT Id,OpportunityId,Product__c, Product__r.Contract_Required__c FROM Quote WHERE Id IN: syncQuoteIds]){
                OppIdProductMap.put(qt.OpportunityId,qt.Product__r.Contract_Required__c);
            }
            for(Opportunity opp : oppList){
                if(opp.StageName == 'Approved' && OppIdProductMap.get(opp.Id)==True && recTypeNames.contains(UtilityClass.allOppRecordTypeNameById.get(opp.recordTypeId)) ){
                    if(!docCheckMap.containsKey(opp.Id)){
                        opp.addError('You can not move to Approved until a Lender Credit Contract document has been uploaded to the opportunity.');
                    }
                }
            }
        }
    }
    public void createAdviserTask(list<opportunity> newlist, list<opportunity> oldlist, map<id,opportunity> newmap, map<id,opportunity> oldmap){
        list<String> recordTypes = new list<string>{'Home Improvement','Solar','Green Loan','Debt Consolidation','Personal Loan','Vehicle Purchase'};
            set<string> oppids = new set<string>();
        for(opportunity opp : newlist){
            if(recordTypes.contains(Schema.SObjectType.opportunity.getRecordTypeInfosById().get(opp.RecordTypeId).getName()) &&
               opp.StageName == 'Packs Back' && opp.StageName != oldmap.get(opp.id).stageName){
                   oppids.add(opp.id);
               }
        }
        if(oppids != null && oppids.size() > 0){
            Addtask(oppids);
        }
    }
    @future
    public static void Addtask(set<string> oppIds){
        list<opportunity> opplist =[select id,name,Credit_Analyst__c from opportunity where id IN:oppIds];
        list<task> tklist = new list<task>();
        list<task> oldtasklist = new list<task>();
        Id siteUser = [select id from user where username =: System.Label.Admin_User_Name].id;
        list<id> idlist = new list<id>();
        list<Stage_Tracking__c> str = [SELECT Id, New_Stage__c,Opportunity__c, New_Stage_End_Date__c, Stage_Count__c
                                       FROM Stage_Tracking__c where Opportunity__c IN: oppIds ORDER BY createdDate DESC LIMIT 1];
        Map<Id, Stage_Tracking__c> oppIdToStageTracking = new Map<Id, Stage_Tracking__c>();
        for (Stage_Tracking__c stageTracking : str) {
            oppIdToStageTracking.put(stageTracking.Opportunity__c, stageTracking);
        }
        oldtasklist = [select id,status from task where whatId IN :oppids AND Status != 'Completed' AND Subject like 'Review Packs Back%'];
        if(opplist!=null && oldtasklist.isEmpty()){
            date dueDate = OpportunityTriggerHandler.checkForDuedate(Date.today());
            string body = '';
            string title = '';
            list<opportunity> opptoUpdate = new list<opportunity>();
            for(opportunity opp : opplist){
                if(oppIdToStageTracking.containsKey(opp.Id)){
                    if(oppIdToStageTracking.get(opp.Id).New_Stage__c == 'Packs Back' && oppIdToStageTracking.get(opp.id).Stage_Count__c == 2){
                        Task tk = new Task();
                        opportunity oppp = new opportunity();
                        title = 'Review Packs Back '+system.now().format('dd/MM/yy h:mm a');
                        tk.Subject = 'Review Packs Back '+system.now().format('dd/MM/yy h:mm a');
                        tk.WhatId = opp.id;
                        if(opp.Credit_Analyst__c != null){
                            tk.OwnerId = opp.Credit_Analyst__c;
                            idlist.add(opp.Credit_Analyst__c);
                        }
                        else{
                            tk.OwnerId = siteUser;
                            idlist.add(siteUser);
                        }
                        //tk.OwnerId = opp.Credit_Analyst__c != null ? opp.Credit_Analyst__c : siteUser;
                        tk.Status = 'Not Started';
                        tk.Priority = 'High';
                        tk.ActivityDate = dueDate;
                        body = 'Packs Back for '+opp.Name;
                        tklist.add(tk);
                        oppp.Id= opp.id;
                        //oppp.Application_Pending_Status__c = 'Adviser Action';  /*Commented by tazeem for 1057*/
                        opptoUpdate.add(oppp);
                    }
                }
            }
            if(!tklist.isEmpty()){
                insert tklist;
                CustomNotificationFromApex.notifyUsers(opplist,idlist,title,body);
                update opptoUpdate;
            }
        }
    }
    public void PreliminaryAssessmentPDFData(List<opportunity> newList, Map<id, opportunity> oldMap){
        List<opportunity> opList = new List<opportunity>();
        for(opportunity op : newList){
            if(op.StageName != oldMap.get(op.Id).stageName && op.StageName == 'CPA Done'){
                opList.add(op);
            }
        }
        if(opList != null && opList.size() > 0 && !isByPassPDF){
            createPDFFuture(opList[0].id, opList[0].Name);
        }
    }
    @Future(callout=true)
    public static void createPDFFuture(String oppId, String oppName){
        createPDF( oppId,  oppName);
    }
    public static void createPDF(String oppId, String oppName){
        PageReference pdf1 = Page.PreliminaryAssessmentPDF;
        pdf1.getParameters().put('id',oppId);
        pdf1.setRedirect(true);
        Datetime dt = System.now();
        List<string> data = string.valueOf(dt).split(' ');
        dateTime tim =  dt;
        string timeCorrect = data[0]+ ' '+ tim.format('h:mm a');
        system.debug('--'+timeCorrect);
        string title = 'Preliminary Assessment: ' + oppName + '(' + timeCorrect + ')';
        Blob bPDF;
        Document_Requested__c dc = new Document_Requested__c();
        dc.Category__c = 'Preliminary Assessment';
        dc.Opportunity__c = oppId;
        insert dc;
        if (Test.IsRunningTest()){
            bPDF = Blob.valueOf('UNIT.TEST');
        }else{
            System.debug('pdf.getContent()'+pdf1.getContent());
            bPDF = pdf1.getContent();
        }
        set<id> oldcontIDs = new Set<id>();
        for(ContentDocumentLink link : [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId =: oppId]){
            oldcontIDs.add(link.ContentDocumentId);
        }
        List<ContentVersion> oldcntList = new List<ContentVersion>();
        if(oldcontIDs.Size() > 0){
            for(ContentVersion cv : [SELECT Id,contentDocumentId,Category__c,Current_in_use__c from contentVersion where contentDocumentId IN:oldcontIDs AND Current_in_use__c=True AND Category__c = 'Preliminary Assessment']){
                cv.Current_in_use__c = false;
                oldcntList.add(cv);
            }
        }
        update oldcntList;
        ContentVersion ContVerFile = new ContentVersion();
        ContVerFile.VersionData = bPDF;
        ContVerFile.Title = title;
        ContVerFile.PathOnClient= title+'.Pdf';
        ContVerFile.Document_Requested__c = dc.id;
        ContVerFile.Current_in_use__c = true;
        insert ContVerFile;
        ContentVersion cdlListId = [select Id, ContentDocumentId From ContentVersion WHERE Id =: ContVerFile.id LIMIT 1];
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = oppId;
        cdl.ContentDocumentId = cdlListId.ContentDocumentId;
        cdl.shareType = 'V';
        insert cdl;
        List<Document_Requested__c> updateDc = new List<Document_Requested__c>();
        for(Document_Requested__c d : [SELECT Id, OwnerId, Name, LastModifiedDate, LastModifiedById, LastActivityDate, Contact__c, Category__c, Description__c, Details__c, Document__c, Opportunity__c, isComplete__c FROM Document_Requested__c WHERE Id =: dc.id]){
            d.isComplete__c = true;
            updateDc.add(d);
        }
        if(updateDc != null && updateDc.size() > 0){
            update updateDc;
        }
    }
    public void UseApprovedBtnValidation(List<opportunity> oppList,Map<ID, Opportunity> oldOpportunityMap ){
        for(Opportunity opp : oppList){
            if(opp.StageName == 'Approved' && oldOpportunityMap.get(opp.Id).StageName != 'Approved'){
                opp.addError('Please use Approved Button for going to Approved Stage.');
            }
        }
    }
    public void updateOppToFunding(List<opportunity> oppList,Map<ID, Opportunity> oldOpportunityMap ){
        Set<String> oppIdss = new Set<String>();
        for(Opportunity opp : oppList){
            if(opp.StageName == 'Approved' && opp.Funding_Variation_Request__c && oldOpportunityMap.get(opp.Id).StageName != 'Approved'){
                opp.StageName = 'Funding';
                opp.Funding_Variation_Request__c = false;
                oppIdss.add(opp.id);
            }
        }
        if(!oppIdss.isEmpty() && oppIdss.size() > 0){
            Map<Id, Boolean> docCheckMap = New Map<Id, Boolean>();
            Map<Id, Id> docIdWithLinkedIdMap = New Map<Id, Id>();
            List<ContentDocumentLink> cdList = [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: oppIdss];
            if(!cdList.isEmpty()){
                for(ContentDocumentLink Cd : cdList){
                    docIdWithLinkedIdMap.put(Cd.ContentDocumentId, Cd.LinkedEntityId);
                }
                if(!docIdWithLinkedIdMap.isEmpty()){
                    for(ContentVersion cv : [SELECT ContentDocumentId,VersionData,Title,Current_in_use__c FROM ContentVersion WHERE ContentDocumentId =: docIdWithLinkedIdMap.keySet() AND Category__c = 'Lender Credit Contract' AND Current_in_use__c = true]){
                        docCheckMap.put(docIdWithLinkedIdMap.get(cv.ContentDocumentId), true);
                    }
                }
            }
            list<Funding_Request__c> frlist = [select id,name,Request_Status__c,Requested_by__c,Previous_Req_Type__c,Opportunity__c from funding_request__c where Request_Type__c ='Variation' AND Opportunity__c IN:oppIdss];
            list<Funding_Request__c> frlistToupdate = new list<Funding_Request__c>();
            if(!frlist.isEmpty()){
                for(Funding_Request__c fr: frlist){
                    fr.Request_Type__c = fr.Previous_Req_Type__c;
                    if(fr.Requested_by__c == 'Supplier'){
                        if(!docCheckMap.containsKey(fr.Opportunity__c)){
                            fr.Request_Status__c = 'Payment requested by supplier (pending contract)';
                        }
                        else if(docCheckMap.containsKey(fr.Opportunity__c)){
                            fr.Request_Status__c = 'Payment requested by supplier';
                        }
                        frlistToupdate.add(fr);
                    }
                    else if(fr.Requested_by__c == 'Customer'){
                        if(!docCheckMap.containsKey(fr.Opportunity__c)){
                            fr.Request_Status__c = 'Payment requested by customer (pending contract)';
                        }
                        else if(docCheckMap.containsKey(fr.Opportunity__c)){
                            fr.Request_Status__c = 'Payment requested by customer';
                        }
                        frlistToupdate.add(fr);
                    }
                }
                if(!frlistToupdate.isEmpty()){
                    update frlistToupdate;
                }
            }
        }
    }
    public void updateMembershipFee(List<Opportunity> oppList,map<Id,Opportunity> oldoppmap){
        Set<Id> oppIds = new Set<Id>();
        List<Loan_Fees__c> loanFeesList = new List<Loan_Fees__c>();
        Set<Id> applicant2 = new Set<Id>();
        Set<Id> applicant2Removed = new Set<Id>();
        
        if(!oppList.isEmpty()){
            for(opportunity opp : oppList){
                system.debug('oppName'+opp.Name);
                system.debug('OlddNamee'+oldoppmap.get(opp.id).Name);
                if(opp.Number_of_applicants__c == 2 && oldoppmap.get(opp.id).Number_of_applicants__c == 1){
                    applicant2.add(opp.Id);
                }
                else if(opp.Number_of_applicants__c == 1){
                    applicant2Removed.add(opp.Id);
                }
            }
        }
        if(!applicant2.isEmpty() || !applicant2Removed.isEmpty()){
            List<Quote> qtList = [SELECT Id,OpportunityId,(SELECT ID,Active__c, Amount__c,Description__c,
                                                           Fee_From__c, Fee_Type__c, Frequency__c,Notes__c,
                                                           Override_allowed__c, Product__c, Product_Loan_Fees__c,
                                                           Quote__c,Product_Loan_Fees__r.Per_person_twice_for_2_person_apps__c,Product_Loan_Fees__r.Amount__c FROM Loan_Fees__r WHERE Fee_Type__c = 'Refundable Lender Membership Fee')
                                  FROM Quote WHERE OpportunityId IN: applicant2 OR OpportunityId IN: applicant2Removed];
            if(!qtList.isEmpty()){
                for(Quote qt : qtList){
                    if(qt.Loan_Fees__r != null){
                        for(Loan_Fees__c fee: qt.Loan_Fees__r){
                            if(fee.Product_Loan_Fees__r.Per_person_twice_for_2_person_apps__c){
                                if(applicant2.Contains(qt.OpportunityId)){
                                    fee.Amount__c = fee.Product_Loan_Fees__r.Amount__c * 2 ;
                                    loanFeesList.add(fee);
                                }
                                else if(applicant2Removed.Contains(qt.OpportunityId)){
                                    fee.Amount__c = fee.Product_Loan_Fees__r.Amount__c;
                                    loanFeesList.add(fee);
                                }
                            }
                        }
                    }
                }
            } 
        }      
        if(!loanFeesList.isEmpty()){
            Update loanFeesList;
        }
    } 
    
    public void updateReferralFee(List<Opportunity> oppList,map<Id,Opportunity> oldoppmap){
        List<Opportunity> OppListToUpdate = new List<Opportunity>();
        Set<Id> refCompanyIds = new Set<Id>();
        Map<Id,Account> accIdAccMap = new Map<Id,Account>();
        if(!oppList.isEmpty()){
            for(Opportunity oppp : oppList){
                if(oppp.Referred_by_Company__c != null && oppp.Referred_by_aggregator__c != null){
                    system.debug('both');
                    refCompanyIds.add(oppp.Referred_by_Company__c);
                    refCompanyIds.add(oppp.Referred_by_aggregator__c);
                }
                else if(oppp.Referred_by_aggregator__c != null){
                    system.debug('agggg');
                    refCompanyIds.add(oppp.Referred_by_aggregator__c); 
                }
                else if(oppp.Referred_by_Company__c != null){
                    system.debug('reffComp');
                    refCompanyIds.add(oppp.Referred_by_Company__c); 
                }
            }
            system.debug('refCompanyIds'+refCompanyIds);
            if(!refCompanyIds.isEmpty()){
                List<Account> refCompanyList = [SELECT Id,Referral_Fee_Applicable__c,RF_Rate_inc_GST__c,RF_Type__c FROM Account WHERE Id IN: refCompanyIds];
                for(Account acc : refCompanyList){
                    accIdAccMap.put(acc.Id,acc);
                }
                for(Opportunity opp : oppList){
                    if((opp.RF_Rate_inc_GST__c == null || opp.RF_Rate_inc_GST__c <= 0) && (opp.Referred_by_Company__c != null || opp.Referred_by_aggregator__c != null)){
                        system.debug('oldoppmappppp'+oldoppmap);
                        if(accIdAccMap.containsKey(opp.Referred_by_Company__c) && accIdAccMap.containsKey(opp.Referred_by_aggregator__c)){
                            if(accIdAccMap.get(opp.Referred_by_Company__c).Referral_Fee_Applicable__c && accIdAccMap.get(opp.Referred_by_aggregator__c).Referral_Fee_Applicable__c){
                                system.debug('BothhAggregator');
                                opp.RF_Rate_inc_GST__c = accIdAccMap.get(opp.Referred_by_aggregator__c).RF_Rate_inc_GST__c;
                                opp.RF_Type__c = accIdAccMap.get(opp.Referred_by_aggregator__c).RF_Type__c;
                                opp.Referral_Fee_Recipient__c = accIdAccMap.get(opp.Referred_by_aggregator__c).Id;
                            }
                            else if(accIdAccMap.get(opp.Referred_by_aggregator__c).Referral_Fee_Applicable__c){
                                opp.RF_Rate_inc_GST__c = accIdAccMap.get(opp.Referred_by_aggregator__c).RF_Rate_inc_GST__c;
                                opp.RF_Type__c = accIdAccMap.get(opp.Referred_by_aggregator__c).RF_Type__c;
                                opp.Referral_Fee_Recipient__c = accIdAccMap.get(opp.Referred_by_aggregator__c).Id;
                            }
                            else if(accIdAccMap.get(opp.Referred_by_Company__c).Referral_Fee_Applicable__c){
                            opp.RF_Rate_inc_GST__c = accIdAccMap.get(opp.Referred_by_Company__c).RF_Rate_inc_GST__c;
                            opp.RF_Type__c = accIdAccMap.get(opp.Referred_by_Company__c).RF_Type__c;
                            opp.Referral_Fee_Recipient__c = accIdAccMap.get(opp.Referred_by_Company__c).Id;
                            } 
                        }
                        else if(accIdAccMap.containsKey(opp.Referred_by_aggregator__c)){
                             if(accIdAccMap.get(opp.Referred_by_aggregator__c).Referral_Fee_Applicable__c){
                                system.debug('AggreGatorrrr');
                                opp.RF_Rate_inc_GST__c = accIdAccMap.get(opp.Referred_by_aggregator__c).RF_Rate_inc_GST__c;
                                opp.RF_Type__c = accIdAccMap.get(opp.Referred_by_aggregator__c).RF_Type__c;
                                opp.Referral_Fee_Recipient__c = accIdAccMap.get(opp.Referred_by_aggregator__c).Id;
                            }
                        }
                        else if(accIdAccMap.containsKey(opp.Referred_by_Company__c)){
                            if(accIdAccMap.get(opp.Referred_by_Company__c).Referral_Fee_Applicable__c){
                            system.debug('RefCompanyInsIdee');
                            opp.RF_Rate_inc_GST__c = accIdAccMap.get(opp.Referred_by_Company__c).RF_Rate_inc_GST__c;
                            opp.RF_Type__c = accIdAccMap.get(opp.Referred_by_Company__c).RF_Type__c;
                            opp.Referral_Fee_Recipient__c = accIdAccMap.get(opp.Referred_by_Company__c).Id;
                            } 
                        }
                        system.debug('opppnewww+1+'+opp);
                    }
                }
            }
        }
    } 
}