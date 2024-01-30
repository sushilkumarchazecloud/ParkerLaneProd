public without sharing class Linechartcont {
	/*
		before made changes in Time_Line_Conditions__c records please check the ORDER__C number here also!!!
	
	*/
    @AuraEnabled
    public static List<activityWrapper> fillActivity(id Recid){
        List<activityWrapper> ActList = new List<activityWrapper>();
        List<Time_Line_Conditions__c> tlcList = [Select id, name,Todo_s_For__c,order__c,number_of_condition__c, is_Major__c,Icon_Name__c,Done_Title__c,Status__c,Condition_match__c, Condition_1__c,Operator_1__c,Value_1__c,Condition_2__c,Operator_2__c,Value_2__c,Condition_3__c,Operator_3__c,Value_3__c from Time_Line_Conditions__c order by Order__c, Status__c, Todo_s_For__c];
        opportunity op = [select id,Approved_Date__c, applicant_1__r.name,applicant_2__r.name,Funding_Variation_Request__c, Customer_Response__c,Line_Chart_JSON__c,Applicant_1_Credit_Score__c,Purchase_Price_Funds_Needed__c,Monthly_Repayments__c,Lender__c,Applicant_1__c,Applicant_2__c,Applicant_1__r.personContactId,Applicant_2__r.personContactId, name,Current_Application_Sections__c,Send_the_quote_to__c, stageName from opportunity where id = : Recid];
        string oldOPVal = op.Line_Chart_JSON__c;
        boolean appOnevar = false;
        boolean appTwovar = false;
        VOI_Status__c singleVOI = new VOI_Status__c();    
        List<Funding_Request__c> FundingList = new List<Funding_Request__c>();
        List<VOI_Status__c> voiSList = new List<VOI_Status__c>();
        Map<id, List<VOI_Status__c>> VOIMAP = new Map<id, List<VOI_Status__c>>();
        for(VOI_Status__c vs : [select id, name, Contact__c,Contact__r.name,Case_Status__c, Opportunity__c, VOI_Type_For__c from VOI_Status__c where Opportunity__r.id =: op.Id AND Case_Status__c != 'Rejected' order by createddate ASC]){
            voiSList.add(vs);
            
            if(!VOIMAP.containsKey(vs.Contact__c)){
                VOIMAP.put(vs.Contact__c, new List<VOI_Status__c>{vs});
            }
            else{
                VOIMAP.get(vs.Contact__c).add(vs);
            }            
        }
        for(Funding_Request__c fc : [Select id,Applicant_1_A1__c,Applicant_2_A2__c,Applicant_1_A1__r.FirstName,Applicant_2_A2__r.FirstName,Person_Requesting__r.Name,Person_Requesting__c,Request_Status__c,CreatedDate,Customer_Authorisation_Type__c,Customer_Authorisation_Status__c, name from Funding_Request__c where Opportunity__c =: op.id Order by CreatedDate DESC]){
            FundingList.add(fc);
        }
     
        Set<id> conDocId = new Set<id>();
        for(ContentDocumentLink cdl :[select Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility from ContentDocumentLink where LinkedEntityId =: Recid]){
            conDocId.add(cdl.ContentDocumentId);
        }
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        for(ContentVersion cv : [SELECT Id, ContentDocumentId,Current_in_use__c, Category__c, Related__c FROM ContentVersion WHERE ContentDocumentId IN: conDocId]){
            cvList.add(cv); 
        }
        
        
        
        List<Document_Requested__c> drList = new List<Document_Requested__c>();
        List<Document_Requested__c> FullDoc = new List<Document_Requested__c>();
        List<Document_Requested__c> drListForBankStmnt = new List<Document_Requested__c>();
        for(Document_Requested__c dc : [SELECT Id,Name,Document__c,CreatedDate,isComplete__c, Details__c,Related_To__c,Status__c,Category__c FROM Document_Requested__c WHERE Opportunity__c =: op.Id AND Document__c != '' order by CreatedDate ASC]){
            FullDoc.add(dc);
            if(!dc.isComplete__c){
                drList.add(dc);
            }  
            			
            if(dc.Category__c == 'Bank Statements' || dc.Document__c.equalsIgnoreCase('Bank Statement')){
                drListForBankStmnt.add(dc);
            }

            
        } 
        integer size = 0;
        for(Time_Line_Conditions__c tc : tlcList){
            boolean bankStmnt = false;
            boolean condition = false;
            
            if(!String.isBlank(tc.Operator_1__c)){
                if(tc.Operator_1__c.contains('>')){
                    condition = true;
                    size = (drList != null ? drList.size() : 0);
                }
            } 
            
            if(tc.Order__c == 21 && FundingList != null && FundingList.size() > 0){
                for(Funding_Request__c fr : FundingList){
                    if(fr.Person_Requesting__c != null){
                        activityWrapper obj = new activityWrapper();
                        obj.doneText = tc.Done_Title__c +' ('+fr.Person_Requesting__r.Name+')';
                        obj.status = (tc.Status__c != null ? tc.Status__c : '');
                        obj.iconName = tc.Icon_Name__c;
                        obj.isMajor = tc.is_Major__c;
                        if(fr.Person_Requesting__c == fr.Applicant_1_A1__c || fr.Person_Requesting__c == fr.Applicant_2_A2__c ){
                            obj.toDoFor = 'Customer';
                        }
                        else{
                            obj.toDoFor = 'Referrer';  
                        }
                        ActList.add(obj);
                        break;
                    }
                }
            }
            if(tc.Order__c == 22 && FundingList != null && FundingList.size() > 0){
                for(Funding_Request__c fr : FundingList){
                    if(fr.Customer_Authorisation_Status__c != null && fr.Customer_Authorisation_Status__c != 'Request sent to customer(s)'){
                        if(fr.Customer_Authorisation_Status__c == 'Pending Applicant 1'){
                            activityWrapper obj = new activityWrapper();
                            obj.doneText = tc.Done_Title__c +' ('+fr.Applicant_2_A2__r.FirstName+')';
                            obj.status = (tc.Status__c != null ? tc.Status__c : '');
                            obj.iconName = tc.Icon_Name__c;
                            obj.isMajor = tc.is_Major__c;
                            obj.toDoFor = tc.Todo_s_For__c;
                            ActList.add(obj);
                            break;
                        }
                        else if(fr.Customer_Authorisation_Status__c == 'Pending Applicant 2'){
                            activityWrapper obj = new activityWrapper();
                            obj.doneText = tc.Done_Title__c +' ('+fr.Applicant_1_A1__r.FirstName+')';
                            obj.status = (tc.Status__c != null ? tc.Status__c : '');
                            obj.iconName = tc.Icon_Name__c;
                            obj.isMajor = tc.is_Major__c;
                            obj.toDoFor = tc.Todo_s_For__c;
                            ActList.add(obj);
                            break;
                        }
                        else if(fr.Customer_Authorisation_Status__c == 'Authorised'){
                            if(fr.Applicant_2_A2__c != null){
                                activityWrapper obj = new activityWrapper();
                                obj.doneText = tc.Done_Title__c +' ('+fr.Applicant_1_A1__r.FirstName+')';
                                obj.status = (tc.Status__c != null ? tc.Status__c : '');
                                obj.iconName = tc.Icon_Name__c;
                                obj.isMajor = tc.is_Major__c;
                                obj.toDoFor = tc.Todo_s_For__c;
                                ActList.add(obj);
                                
                                activityWrapper obj1 = new activityWrapper();
                                obj1.doneText = tc.Done_Title__c +' ('+fr.Applicant_2_A2__r.FirstName+')';
                                obj1.status = (tc.Status__c != null ? tc.Status__c : '');
                                obj1.iconName = tc.Icon_Name__c;
                                obj1.isMajor = tc.is_Major__c;
                                obj1.toDoFor = tc.Todo_s_For__c;
                                ActList.add(obj1);
                                break;
                            }
                            if(fr.Applicant_2_A2__c == null){
                                activityWrapper obj = new activityWrapper();
                                obj.doneText = tc.Done_Title__c +' ('+fr.Applicant_1_A1__r.FirstName+')';
                                obj.status = (tc.Status__c != null ? tc.Status__c : '');
                                obj.iconName = tc.Icon_Name__c;
                                obj.isMajor = tc.is_Major__c;
                                obj.toDoFor = tc.Todo_s_For__c;
                                ActList.add(obj);
                                break;
                            }
                        }
                    }
                }
            }
            
            if(tc.Order__c != 35 && tc.Order__c == 34 && !FundingList.isEmpty() && FundingList != null){
                for(Funding_Request__c fr : FundingList){
                    if((fr.Request_Status__c != 'Variation requested by customer') && (fr.Request_Status__c == 'Payment requested by supplier' || fr.Request_Status__c == 'Payment requested by customer')){
                        if(op.Applicant_2__c == null && fr.Customer_Authorisation_Status__c == 'Request sent to customer(s)'){
                            activityWrapper obj = new activityWrapper();
                            obj.doneText = tc.Done_Title__c +' ('+op.Applicant_1__r.Name+')';
                            obj.status = (tc.Status__c != null ? tc.Status__c : '');
                            obj.iconName = tc.Icon_Name__c;
                            obj.isMajor = tc.is_Major__c;
                            obj.toDoFor = tc.Todo_s_For__c;
                            ActList.add(obj);
                            break;
                        } 
                        else if(op.Applicant_2__c != null){
                            if(fr.Customer_Authorisation_Status__c == 'Request sent to customer(s)' && fr.Customer_Authorisation_Type__c == 'Both to sign'){
                                activityWrapper obj = new activityWrapper();
                                obj.doneText = tc.Done_Title__c +' ('+ op.Applicant_1__r.Name+')';
                                obj.status = (tc.Status__c != null ? tc.Status__c : '');
                                obj.iconName = tc.Icon_Name__c;
                                obj.isMajor = tc.is_Major__c;
                                obj.toDoFor = tc.Todo_s_For__c;
                                ActList.add(obj);
                                
                                activityWrapper obj1 = new activityWrapper();
                                obj1.doneText = tc.Done_Title__c +' ('+ op.Applicant_2__r.Name +')';
                                obj1.status = (tc.Status__c != null ? tc.Status__c : '');
                                obj1.iconName = tc.Icon_Name__c;
                                obj1.isMajor = tc.is_Major__c;
                                obj1.toDoFor = tc.Todo_s_For__c;
                                ActList.add(obj1);
                                break;  
                            }
                            else if(fr.Customer_Authorisation_Status__c == 'Pending Applicant 1' && fr.Customer_Authorisation_Type__c == 'Both to sign'){
                                activityWrapper obj1 = new activityWrapper();
                                obj1.doneText = tc.Done_Title__c +' ('+ op.Applicant_1__r.Name +')';
                                obj1.status = (tc.Status__c != null ? tc.Status__c : '');
                                obj1.iconName = tc.Icon_Name__c;
                                obj1.isMajor = tc.is_Major__c;
                                obj1.toDoFor = tc.Todo_s_For__c;
                                ActList.add(obj1);
                                break;  
                            }
                            else if(fr.Customer_Authorisation_Status__c == 'Pending Applicant 2' && fr.Customer_Authorisation_Type__c == 'Both to sign'){
                                activityWrapper obj1 = new activityWrapper();
                                obj1.doneText = tc.Done_Title__c +' ('+ op.Applicant_2__r.Name + ')';
                                obj1.status = (tc.Status__c != null ? tc.Status__c : '');
                                obj1.iconName = tc.Icon_Name__c;
                                obj1.isMajor = tc.is_Major__c;
                                obj1.toDoFor = tc.Todo_s_For__c;
                                ActList.add(obj1);
                                break;  
                            }
                            else if(fr.Customer_Authorisation_Status__c == 'Pending Applicant 1' && fr.Customer_Authorisation_Type__c == 'Either to sign'){
                                activityWrapper obj1 = new activityWrapper();
                                obj1.doneText = tc.Done_Title__c +' (' + op.Applicant_1__r.Name +')';
                                obj1.status = (tc.Status__c != null ? tc.Status__c : '');
                                obj1.iconName = tc.Icon_Name__c;
                                obj1.isMajor = tc.is_Major__c;
                                obj1.toDoFor = tc.Todo_s_For__c;
                                ActList.add(obj1);
                                break;  
                            }
                        }
                    }
                }                
            }
            if(tc.Order__c == 35 && op.Funding_Variation_Request__c == true){
                activityWrapper obj = new activityWrapper();
                obj.doneText = tc.Done_Title__c;
                obj.status = (tc.Status__c != null ? tc.Status__c : '');
                obj.iconName = tc.Icon_Name__c;
                obj.isMajor = tc.is_Major__c;
                obj.toDoFor = tc.Todo_s_For__c;
                ActList.add(obj);
            }
            if(tc.number_of_condition__c == 1){       
                boolean isDocExis = false;
                boolean isFundAuth = false; 
                boolean isFundPending = false; 
                boolean isFund = false; 
                for(Funding_Request__c fc : FundingList){
                    if(op.stageName == 'Funding' && (fc.Request_Status__c == 'Payment requested by customer (pending contract)' || fc.Request_Status__c == 'Payment requested by supplier (pending contract)') ){
                        isFundPending = true;
                        break;
                    }
                }
                for(Funding_Request__c fc : FundingList){
                    if(fc.Request_Status__c == 'Payment authorised by customer'){
                        isFundAuth = true;
                        break;
                    }
                }
                for(Funding_Request__c fc : FundingList){
                    if(fc.Request_Status__c != 'Payment funded' && fc.Request_Status__c != 'Payment authorised by customer'){
                        isFund = true;
                        break;
                    }
                }
                for(ContentVersion cv : cvList){
                    if(cv.Category__c == 'Lender Credit Contract' && cv.Current_in_use__c){
                 		isDocExis = true;
                        break;
                    }
                }
               if(tc.Order__c == 6 && tc.Value_1__c.split(',').contains((string)op.get(tc.Condition_1__c)) && (FundingList.size() == 0)){
                    activityWrapper obj = new activityWrapper();
                    obj.doneText = tc.Done_Title__c;
                    obj.status = (tc.Status__c != null ? tc.Status__c : '');
                    obj.iconName = tc.Icon_Name__c;
                    obj.isMajor = tc.is_Major__c;
                    obj.toDoFor = tc.Todo_s_For__c;
                    ActList.add(obj);
                }
                if(tc.Order__c == 7 && tc.Value_1__c.split(',').contains((string)op.get(tc.Condition_1__c)) && (isDocExis)){
                    activityWrapper obj = new activityWrapper();
                    obj.doneText = tc.Done_Title__c;
                    obj.status = (tc.Status__c != null ? tc.Status__c : '');
                    obj.iconName = tc.Icon_Name__c;
                    obj.isMajor = tc.is_Major__c;
                    obj.toDoFor = tc.Todo_s_For__c;
                    ActList.add(obj);
                }
                if(tc.Order__c != 44 && tc.Order__c != 7 && tc.Order__c != 6 && tc.Order__c != 43 && tc.Order__c != 37 && tc.Order__c != 33 && tc.Order__c != 32 && tc.name != 'Approval expires in 10 days' && tc.Value_1__c.split(',').contains((string)op.get(tc.Condition_1__c))){
                    activityWrapper obj = new activityWrapper();
                    obj.doneText = tc.Done_Title__c;
                    obj.status = (tc.Status__c != null ? tc.Status__c : '');
                    obj.iconName = tc.Icon_Name__c;
                    obj.isMajor = tc.is_Major__c;
                    obj.toDoFor = tc.Todo_s_For__c;
                    ActList.add(obj);
                }
                
                if(tc.Order__c != 37 && tc.Order__c != 33 && tc.Order__c != 32 && tc.name == 'Approval expires in 10 days' && tc.Value_1__c.split(',').contains((string)op.get(tc.Condition_1__c))){
                    if(op.Approved_Date__c != null && (op.Approved_Date__c.date()).daysbetween(system.today()) > 79 && (op.Approved_Date__c.date()).daysbetween(system.today()) < 91){
                        activityWrapper obj = new activityWrapper();
                        obj.doneText = tc.Done_Title__c;
                        obj.status = (tc.Status__c != null ? tc.Status__c : '');
                        obj.iconName = tc.Icon_Name__c;
                        obj.isMajor = tc.is_Major__c;
                        obj.toDoFor = tc.Todo_s_For__c;
                        ActList.add(obj);   
                    }                    
                }
                if(tc.Order__c == 32 && tc.Value_1__c.split(',').contains((string)op.get(tc.Condition_1__c)) && (FundingList.size() == 0)){
                    activityWrapper obj = new activityWrapper();
                    obj.doneText = tc.Done_Title__c;
                    obj.status = (tc.Status__c != null ? tc.Status__c : '');
                    obj.iconName = tc.Icon_Name__c;
                    obj.isMajor = tc.is_Major__c;
                    obj.toDoFor = tc.Todo_s_For__c;
                    ActList.add(obj);
                }                  
                if(tc.Order__c == 33 && tc.Value_1__c.split(',').contains((string)op.get(tc.Condition_1__c)) && (!isDocExis)){
                    activityWrapper obj = new activityWrapper();
                    obj.doneText = tc.Done_Title__c;
                    obj.status = (tc.Status__c != null ? tc.Status__c : '');
                    obj.iconName = tc.Icon_Name__c;
                    obj.isMajor = tc.is_Major__c;
                    obj.toDoFor = tc.Todo_s_For__c;
                    ActList.add(obj);
                }
                if(tc.Order__c == 37 && tc.Value_1__c.split(',').contains((string)op.get(tc.Condition_1__c)) && isFundAuth){
                    activityWrapper obj = new activityWrapper();
                    obj.doneText = tc.Done_Title__c;
                    obj.status = (tc.Status__c != null ? tc.Status__c : '');
                    obj.iconName = tc.Icon_Name__c;
                    obj.isMajor = tc.is_Major__c;
                    obj.toDoFor = tc.Todo_s_For__c;
                    ActList.add(obj);
                } 
                if(tc.Order__c == 43 && (tc.Value_1__c.split(',').contains((string)op.get(tc.Condition_1__c)) || (isFundPending)) ){
                    activityWrapper obj = new activityWrapper();
                    obj.doneText = tc.Done_Title__c; 
                    obj.status = (tc.Status__c != null ? tc.Status__c : '');
                    obj.iconName = tc.Icon_Name__c;
                    obj.isMajor = tc.is_Major__c;
                    obj.toDoFor = tc.Todo_s_For__c;
                    ActList.add(obj);
                }
                if(tc.Order__c == 44 && tc.Value_1__c.split(',').contains((string)op.get(tc.Condition_1__c)) && isFund ){
                    activityWrapper obj = new activityWrapper();
                    obj.doneText = tc.Done_Title__c; 
                    obj.status = (tc.Status__c != null ? tc.Status__c : '');
                    obj.iconName = tc.Icon_Name__c;
                    obj.isMajor = tc.is_Major__c;
                    obj.toDoFor = tc.Todo_s_For__c;
                    ActList.add(obj);
                }
            }
            if(tc.number_of_condition__c == 2){
                if(condition){                    
                    if(FullDoc != null && FullDoc.size() > 0 && size == 0 && tc.order__c == 17){
                        if(tc.Value_2__c.contains((string)op.get(tc.Condition_2__c))){
                            activityWrapper obj = new activityWrapper();
                            obj.doneText = 'Supporting information provided';
                            obj.status = 'Done';//(tc.Status__c != null ? tc.Status__c : '');
                            obj.iconName = 'SmallGreen';
                            obj.isMajor = false;
                            obj.toDoFor = 'Customer';
                            ActList.add(obj);  
                        }                         
                    } 
                    if(size != 0 && tc.order__c == 27){     
                        if(tc.Value_2__c.contains((string)op.get(tc.Condition_2__c))){           
                            activityWrapper obj = new activityWrapper();
                            obj.doneText = 'Provide supporting information';
                            obj.status = 'Required Now';
                            obj.iconName = 'SmallToDo';
                            obj.isMajor = false;
                            obj.toDoFor = 'Customer';
                            ActList.add(obj);                           
                        }
                    }
                    condition = false;
                }    
                else if(tc.order__c == 18){
                    if(tc.Value_1__c.contains((string)op.get(tc.Condition_1__c))){
                        for(Document_Requested__c dc : drListForBankStmnt){
                            if(dc.isComplete__c && tc.Order__c == 18){
                                activityWrapper obj = new activityWrapper();
                                obj.doneText = 'Bank data provided';
                                obj.status = 'Done';
                                obj.iconName = 'SmallGreen';
                                obj.isMajor = false;
                                obj.toDoFor = 'Customer';
                                ActList.add(obj); 
                                if(!test.isRunningTest())
                                    break;
                            }                            
                        }                        
                    }
                }    
                else if(tc.Value_1__c.split(',').contains((string)op.get(tc.Condition_1__c)) && tc.Condition_2__c.contains('Bank Statement Data document request')){
                    if(drListForBankStmnt != null && drListForBankStmnt.size() > 0){
                        if(drListForBankStmnt[0].status__c.contains(tc.Value_2__c)){
                            activityWrapper obj = new activityWrapper();
                            obj.doneText = tc.Done_Title__c;
                            obj.status = (tc.Status__c != null ? tc.Status__c : '');
                            obj.iconName = tc.Icon_Name__c;
                            obj.isMajor = tc.is_Major__c;
                            obj.toDoFor = tc.Todo_s_For__c;
                            ActList.add(obj);
                        }
                    }
                }
                else if(tc.Value_1__c.split(',').contains((string)op.get(tc.Condition_1__c)) && tc.Condition_2__c.contains('Document Requested with category "Purchase Quote or Invoice"')){
                    if(cvList != null && cvList.size() > 0){
                        for(ContentVersion dc : cvList){
                            if( (dc.Category__c == 'Purchase Invoice' ||  dc.Category__c == 'Loan Purpose') && tc.Value_2__c == 'Submitted'){
                                activityWrapper obj = new activityWrapper();
                                obj.doneText = tc.Done_Title__c;
                                obj.status = (tc.Status__c != null ? tc.Status__c : '');
                                obj.iconName = tc.Icon_Name__c;
                                obj.isMajor = tc.is_Major__c;
                                obj.toDoFor = tc.Todo_s_For__c;
                                ActList.add(obj);
                                if(!test.isRunningTest())
                                	break;
                            }
                        }
                        for(Document_Requested__c dc : drList){
                            if((dc.Category__c == 'Purchase Invoice' ||  dc.Category__c == 'Loan Purpose') && tc.Value_2__c == 'Requested'){
                                activityWrapper obj = new activityWrapper();
                                obj.doneText = tc.Done_Title__c;
                                obj.status = (tc.Status__c != null ? tc.Status__c : '');
                                obj.iconName = tc.Icon_Name__c;
                                obj.isMajor = tc.is_Major__c;
                                obj.toDoFor = tc.Todo_s_For__c;
                                ActList.add(obj);
                                if(!test.isRunningTest())
                                    break;
                            }
                        }
                    }                                        
                }
               /* else if(tc.Name == 'Request funding' || tc.Name == 'Issue Credit Contract' || tc.Name == 'Fund' ){                   
                    if(tc.Name == 'Request funding'){                        
                        if(tc.Value_1__c.split(',').contains((string)op.get(tc.Condition_1__c))){
                            activityWrapper obj = new activityWrapper();
                            obj.doneText = tc.Done_Title__c;
                            obj.status = (tc.Status__c != null ? tc.Status__c : '');
                            obj.iconName = tc.Icon_Name__c;
                            obj.isMajor = tc.is_Major__c;
                            obj.toDoFor = tc.Todo_s_For__c;
                            ActList.add(obj);
                        }
                        else if(tc.Value_1__c.split(',').contains((string)op.get(tc.Condition_1__c)) && op.get(tc.Condition_2__c) == null && tc.Operator_2__c == '!='){
                            activityWrapper obj = new activityWrapper();
                            obj.doneText = tc.Done_Title__c;
                            obj.status = (tc.Status__c != null ? tc.Status__c : '');
                            obj.iconName = tc.Icon_Name__c;
                            obj.isMajor = tc.is_Major__c;
                            obj.toDoFor = tc.Todo_s_For__c;
                            ActList.add(obj);
                            
                        }
                        else if(tc.Value_1__c.split(',').contains((string)op.get(tc.Condition_1__c)) && op.get(tc.Condition_2__c) != null && tc.Operator_2__c == '=='){
                            activityWrapper obj = new activityWrapper();
                            obj.doneText = tc.Done_Title__c;
                            obj.status = (tc.Status__c != null ? tc.Status__c : '');
                            obj.iconName = tc.Icon_Name__c;
                            obj.isMajor = tc.is_Major__c;
                            obj.toDoFor = tc.Todo_s_For__c;
                            ActList.add(obj); 
                        }
                    }
                    else if(tc.Name == 'Issue Credit Contract'){
                        if(tc.Value_1__c.split(',').contains((string)op.get(tc.Condition_1__c)) && op.get(tc.Condition_2__c) == null && tc.Operator_2__c == '!='){
                            activityWrapper obj = new activityWrapper();
                            obj.doneText = tc.Done_Title__c;
                            obj.status = (tc.Status__c != null ? tc.Status__c : '');
                            obj.iconName = tc.Icon_Name__c;
                            obj.isMajor = tc.is_Major__c;
                            obj.toDoFor = tc.Todo_s_For__c;
                            ActList.add(obj);
                        }
                        else if(tc.Value_1__c.split(',').contains((string)op.get(tc.Condition_1__c)) && op.get(tc.Condition_2__c) != null && tc.Operator_2__c == '=='){
                            activityWrapper obj = new activityWrapper();
                            obj.doneText = tc.Done_Title__c;
                            obj.status = (tc.Status__c != null ? tc.Status__c : '');
                            obj.iconName = tc.Icon_Name__c;
                            obj.isMajor = tc.is_Major__c;
                            obj.toDoFor = tc.Todo_s_For__c;
                            ActList.add(obj); 
                        }
                    }
                    else if(tc.Name == 'Fund'){                        
                        if(tc.Value_1__c.split(',').contains((string)op.get(tc.Condition_1__c)) && op.get(tc.Condition_2__c) == null && tc.Operator_2__c == '!='){
                            activityWrapper obj = new activityWrapper();
                            obj.doneText = tc.Done_Title__c;
                            obj.status = (tc.Status__c != null ? tc.Status__c : '');
                            obj.iconName = tc.Icon_Name__c;
                            obj.isMajor = tc.is_Major__c;
                            obj.toDoFor = tc.Todo_s_For__c;
                            ActList.add(obj);
                        } 
                    }     				
                    
                }*/
                else{ 
                    if((op.get(tc.Condition_1__c) == null ? false : tc.Value_1__c.contains((string)op.get(tc.Condition_1__c))) && (tc.Condition_2__c == null ? false : (tc.Condition_2__c == null ? false : (tc.name == 'Authorise payment' ? op.get(tc.Condition_2__c) == null : (op.get(tc.Condition_2__c) != null ? tc.Value_2__c.contains((string)op.get(tc.Condition_2__c)) : false))))){
                        activityWrapper obj = new activityWrapper();
                        obj.doneText = tc.Done_Title__c;
                        obj.status = (tc.Status__c != null ? tc.Status__c : '');
                        obj.iconName = tc.Icon_Name__c;
                        obj.isMajor = tc.is_Major__c;
                        obj.toDoFor = tc.Todo_s_For__c;
                        ActList.add(obj);
                    }
                 }
                
                
            }
            if(tc.number_of_condition__c == 3){
                if(condition){
                    if(size > 0 && tc.Value_2__c.contains((string)op.get(tc.Condition_2__c)) && tc.Value_3__c.contains((string)op.get(tc.Condition_3__c))){
                        activityWrapper obj = new activityWrapper();
                        obj.doneText = tc.Done_Title__c;
                        obj.status = (tc.Status__c != null ? tc.Status__c : '');
                        obj.iconName = tc.Icon_Name__c;
                        obj.isMajor = tc.is_Major__c;
                        obj.toDoFor = tc.Todo_s_For__c;
                        ActList.add(obj);
                    }
                }
                else if((tc.Name.contains('Verify Identity') || tc.Name.contains('Sign credit proposal'))){                   
                    if(VOIMAP != null && VOIMAP.size() > 0){
                        if(tc.Value_1__c.split(',').contains((string)op.get(tc.Condition_1__c))){                            
                            string typeOfOne = '';
                            boolean full = false;
                            boolean VOI = false;
                            boolean Esign = false;
                            if(VOIMAP.containsKey(op.Applicant_1__r.personContactid)){
                                for(VOI_Status__c vs : VOIMAP.get(op.Applicant_1__r.personContactid)){
                                    if(vs.VOI_Type_For__c == 'FULL'){
                                        if(vs.Case_Status__c == 'Verified' || vs.Case_Status__c == 'Submitted'){
                                            full = true;
                                            if(!test.isRunningTest())
                                                break;
                                        }
                                    }    
                                    if(vs.VOI_Type_For__c == 'VOI'){
                                        if(vs.Case_Status__c == 'Verified' || vs.Case_Status__c == 'Submitted'){
                                            VOI = true;
                                            if(!test.isRunningTest())
                                                break;
                                        }
                                    }
                                    if(vs.VOI_Type_For__c == 'E-SIGN'){
                                        if(vs.Case_Status__c == 'Verified' || vs.Case_Status__c == 'Submitted'){
                                            Esign = true;
                                            if(!test.isRunningTest())
                                                break;
                                        }
                                    }
                                }
                            }
                            
                            if(VOIMAP.containsKey(op.Applicant_1__r.personContactid)){
                                for(VOI_Status__c vs : VOIMAP.get(op.Applicant_1__r.personContactid)){
                                    if(vs.VOI_Type_For__c == 'FULL'){
                                        if(vs.Case_Status__c == 'Sent' || vs.Case_Status__c == 'Delivered'){
                                            typeOfOne = 'Full-not';
                                        }
                                        else{
                                            typeOfOne = 'Full-done';
                                        }
                                    }
                                    if(vs.VOI_Type_For__c == 'VOI'){
                                        if(vs.Case_Status__c == 'Sent' || vs.Case_Status__c == 'Delivered'){
                                            typeOfOne = 'VOI-not';
                                        }
                                        else{
                                            typeOfOne = 'VOI-done';
                                        }
                                    }
                                    if(vs.VOI_Type_For__c == 'E-SIGN'){
                                        if(vs.Case_Status__c == 'Sent' || vs.Case_Status__c == 'Delivered'){
                                            typeOfOne = 'sign-not';
                                        }
                                        else{
                                            typeOfOne = 'sign-done';
                                        }
                                    }
                                }
                            }
                            if((typeOfOne == 'Full-not' || typeOfOne == 'VOI-not') && tc.Order__c == 28){
                                activityWrapper obj = new activityWrapper();
                                obj.doneText = tc.Done_Title__c + ' for ' + op.Applicant_1__r.name;
                                obj.status = (tc.Status__c != null ? tc.Status__c : '');
                                obj.iconName = tc.Icon_Name__c;
                                obj.isMajor = tc.is_Major__c;
                                obj.toDoFor = tc.Todo_s_For__c;
                                ActList.add(obj);  
                            }
                            else if((typeOfOne == 'Full-not' || typeOfOne == 'sign-not') && tc.Order__c == 29){
                                activityWrapper obj = new activityWrapper();
                                obj.doneText = tc.Done_Title__c + ' for ' + op.Applicant_1__r.name;
                                obj.status = (tc.Status__c != null ? tc.Status__c : '');
                                obj.iconName = tc.Icon_Name__c;
                                obj.isMajor = tc.is_Major__c;
                                obj.toDoFor = tc.Todo_s_For__c;
                                ActList.add(obj);  
                            }
                            else if((typeOfOne == 'Full-done' || typeOfOne == 'VOI-done') && tc.Order__c == 19){
                                activityWrapper obj = new activityWrapper();
                                obj.doneText = tc.Done_Title__c + ' for ' + op.Applicant_1__r.name;
                                obj.status = (tc.Status__c != null ? tc.Status__c : '');
                                obj.iconName = tc.Icon_Name__c;
                                obj.isMajor = tc.is_Major__c;
                                obj.toDoFor = tc.Todo_s_For__c;
                                ActList.add(obj);
                            }
                            else if((typeOfOne == 'Full-done' || typeOfOne == 'sign-done') && tc.Order__c == 20){
                                activityWrapper obj = new activityWrapper();
                                obj.doneText = tc.Done_Title__c + ' for ' + op.Applicant_1__r.name;
                                obj.status = (tc.Status__c != null ? tc.Status__c : '');
                                obj.iconName = tc.Icon_Name__c;
                                obj.isMajor = tc.is_Major__c;
                                obj.toDoFor = tc.Todo_s_For__c;
                                ActList.add(obj);
                            }
                            
                            if(typeOfOne == 'sign-not' && (full || VOI) && tc.Order__c == 19){
                                activityWrapper obj = new activityWrapper();
                                obj.doneText = tc.Done_Title__c + ' for ' + op.Applicant_1__r.name;
                                obj.status = (tc.Status__c != null ? tc.Status__c : '');
                                obj.iconName = tc.Icon_Name__c;
                                obj.isMajor = tc.is_Major__c;
                                obj.toDoFor = tc.Todo_s_For__c;
                                ActList.add(obj); 
                            }
                            if(typeOfOne == 'VOI-not' && (full || Esign) && tc.Order__c == 20){
                                activityWrapper obj = new activityWrapper();
                                obj.doneText = tc.Done_Title__c + ' for ' + op.Applicant_1__r.name;
                                obj.status = (tc.Status__c != null ? tc.Status__c : '');
                                obj.iconName = tc.Icon_Name__c;
                                obj.isMajor = tc.is_Major__c;
                                obj.toDoFor = tc.Todo_s_For__c;
                                ActList.add(obj); 
                            }
                            
                            if(typeOfOne == 'sign-done' && (full || VOI) && tc.Order__c == 19){
                                activityWrapper obj = new activityWrapper();
                                obj.doneText = tc.Done_Title__c + ' for ' + op.Applicant_1__r.name;
                                obj.status = (tc.Status__c != null ? tc.Status__c : '');
                                obj.iconName = tc.Icon_Name__c;
                                obj.isMajor = tc.is_Major__c;
                                obj.toDoFor = tc.Todo_s_For__c;
                                ActList.add(obj); 
                            }
                            if(typeOfOne == 'VOI-done' && (full || Esign) && tc.Order__c == 20){
                                activityWrapper obj = new activityWrapper();
                                obj.doneText = tc.Done_Title__c + ' for ' + op.Applicant_1__r.name;
                                obj.status = (tc.Status__c != null ? tc.Status__c : '');
                                obj.iconName = tc.Icon_Name__c;
                                obj.isMajor = tc.is_Major__c;
                                obj.toDoFor = tc.Todo_s_For__c;
                                ActList.add(obj); 
                            }
                            
                            
                                if(op.Applicant_2__c != null && VOIMAP.get(op.Applicant_2__r.PersonContactId) != null && VOIMAP.get(op.Applicant_2__r.PersonContactId).size() > 0){
                                    string typeOfTwo = '';
                                    boolean fullTwo = false;
                                    boolean VOITwo = false;
                                    boolean EsignTwo = false;
                                    for(VOI_Status__c vs : VOIMAP.get(op.Applicant_2__r.PersonContactId)){
                                        if(vs.VOI_Type_For__c == 'FULL'){
                                            if(vs.Case_Status__c == 'Verified' || vs.Case_Status__c == 'Submitted'){
                                                fullTwo = true;
                                                if(!test.isRunningTest())
                                                    break;
                                            }
                                        }    
                                        if(vs.VOI_Type_For__c == 'VOI'){
                                            if(vs.Case_Status__c == 'Verified' || vs.Case_Status__c == 'Submitted'){
                                                VOITwo = true;
                                                if(!test.isRunningTest())
                                                    break;
                                            }
                                        }
                                        if(vs.VOI_Type_For__c == 'E-SIGN'){
                                            if(vs.Case_Status__c == 'Verified' || vs.Case_Status__c == 'Submitted'){
                                                EsignTwo = true;
                                                if(!test.isRunningTest())
                                                    break;
                                            }
                                        }
                                    }
                                    
                                    for(VOI_Status__c vs : VOIMAP.get(op.Applicant_2__r.personContactid)){
                                        if(vs.VOI_Type_For__c == 'FULL'){
                                            if(vs.Case_Status__c == 'Sent' || vs.Case_Status__c == 'Delivered'){
                                                typeOfTwo = 'Full-not';
                                            }
                                            else{
                                                typeOfTwo = 'Full-done';
                                            }
                                        }
                                        if(vs.VOI_Type_For__c == 'VOI'){
                                            if(vs.Case_Status__c == 'Sent' || vs.Case_Status__c == 'Delivered'){
                                                typeOfTwo = 'VOI-not';
                                            }
                                            else{
                                                typeOfTwo = 'VOI-done';
                                            }
                                        }
                                        if(vs.VOI_Type_For__c == 'E-SIGN'){
                                            if(vs.Case_Status__c == 'Sent' || vs.Case_Status__c == 'Delivered'){
                                                typeOfTwo = 'sign-not';
                                            }
                                            else{
                                                typeOfTwo = 'sign-done';
                                            }
                                        }
                                    }
                                    if((typeOfTwo == 'Full-not' || typeOfTwo == 'VOI-not') && tc.Order__c == 28){
                                        activityWrapper obj = new activityWrapper();
                                        obj.doneText = tc.Done_Title__c + ' for ' + op.Applicant_2__r.name;
                                        obj.status = (tc.Status__c != null ? tc.Status__c : '');
                                        obj.iconName = tc.Icon_Name__c;
                                        obj.isMajor = tc.is_Major__c;
                                        obj.toDoFor = tc.Todo_s_For__c;
                                        ActList.add(obj);  
                                    }
                                    else if((typeOfTwo == 'Full-not' || typeOfTwo == 'sign-not') && tc.Order__c == 29){
                                        activityWrapper obj = new activityWrapper();
                                        obj.doneText = tc.Done_Title__c + ' for ' + op.Applicant_2__r.name;
                                        obj.status = (tc.Status__c != null ? tc.Status__c : '');
                                        obj.iconName = tc.Icon_Name__c;
                                        obj.isMajor = tc.is_Major__c;
                                        obj.toDoFor = tc.Todo_s_For__c;
                                        ActList.add(obj);  
                                    }
                                    else if((typeOfTwo == 'Full-done' || typeOfTwo == 'VOI-done') && tc.Order__c == 19){
                                        activityWrapper obj = new activityWrapper();
                                        obj.doneText = tc.Done_Title__c + ' for ' + op.Applicant_2__r.name;
                                        obj.status = (tc.Status__c != null ? tc.Status__c : '');
                                        obj.iconName = tc.Icon_Name__c;
                                        obj.isMajor = tc.is_Major__c;
                                        obj.toDoFor = tc.Todo_s_For__c;
                                        ActList.add(obj);
                                    }
                                    else if((typeOfTwo == 'Full-done' || typeOfTwo == 'sign-done') && tc.Order__c == 20){
                                        activityWrapper obj = new activityWrapper();
                                        obj.doneText = tc.Done_Title__c + ' for ' + op.Applicant_2__r.name;
                                        obj.status = (tc.Status__c != null ? tc.Status__c : '');
                                        obj.iconName = tc.Icon_Name__c;
                                        obj.isMajor = tc.is_Major__c;
                                        obj.toDoFor = tc.Todo_s_For__c;
                                        ActList.add(obj);
                                    }
                                    
                                    if(typeOfTwo == 'sign-not' && (fullTwo || VOITwo) && tc.Order__c == 19){
                                        activityWrapper obj = new activityWrapper();
                                        obj.doneText = tc.Done_Title__c + ' for ' + op.Applicant_2__r.name;
                                        obj.status = (tc.Status__c != null ? tc.Status__c : '');
                                        obj.iconName = tc.Icon_Name__c;
                                        obj.isMajor = tc.is_Major__c;
                                        obj.toDoFor = tc.Todo_s_For__c;
                                        ActList.add(obj); 
                                    }
                                    if(typeOfTwo == 'VOI-not' && (fullTwo || EsignTwo) && tc.Order__c == 20){
                                        activityWrapper obj = new activityWrapper();
                                        obj.doneText = tc.Done_Title__c + ' for ' + op.Applicant_2__r.name;
                                        obj.status = (tc.Status__c != null ? tc.Status__c : '');
                                        obj.iconName = tc.Icon_Name__c;
                                        obj.isMajor = tc.is_Major__c;
                                        obj.toDoFor = tc.Todo_s_For__c;
                                        ActList.add(obj); 
                                    }
                                    
                                    if(typeOfTwo == 'sign-done' && (fullTwo || VOITwo) && tc.Order__c == 19){
                                        activityWrapper obj = new activityWrapper();
                                        obj.doneText = tc.Done_Title__c + ' for ' + op.Applicant_2__r.name;
                                        obj.status = (tc.Status__c != null ? tc.Status__c : '');
                                        obj.iconName = tc.Icon_Name__c;
                                        obj.isMajor = tc.is_Major__c;
                                        obj.toDoFor = tc.Todo_s_For__c;
                                        ActList.add(obj); 
                                    }
                                    if(typeOfTwo == 'VOI-done' && (fullTwo || EsignTwo) && tc.Order__c == 20){
                                        activityWrapper obj = new activityWrapper();
                                        obj.doneText = tc.Done_Title__c + ' for ' + op.Applicant_2__r.name;
                                        obj.status = (tc.Status__c != null ? tc.Status__c : '');
                                        obj.iconName = tc.Icon_Name__c;
                                        obj.isMajor = tc.is_Major__c;
                                        obj.toDoFor = tc.Todo_s_For__c;
                                        ActList.add(obj); 
                                    }
                                }
                        }
                    }
                }
                else{
                    if((op.get(tc.Condition_1__c) == null ? false : tc.Value_1__c.contains((string)op.get(tc.Condition_1__c))) && (op.get(tc.Condition_2__c) == null ? false : tc.Value_2__c.contains((string)op.get(tc.Condition_2__c)))
                        && (op.get(tc.Condition_3__c) == null ? false : tc.Value_3__c.contains((string)op.get(tc.Condition_3__c)))){
                            activityWrapper obj = new activityWrapper();
                            obj.doneText = tc.Done_Title__c;
                            obj.status = (tc.Status__c != null ? tc.Status__c : '');
                            obj.iconName = tc.Icon_Name__c;
                            obj.isMajor = tc.is_Major__c;
                            obj.toDoFor = tc.Todo_s_For__c;
                            ActList.add(obj);
                        }
                    }                       
            }
        }
        
        string value = '[';
        for(Integer i=0; i<ActList.size(); i++){
            value+= '{';
            value += '"doneText":"'+ActList[i].doneText+'",';
            value += '"status":"'+ActList[i].status+'",';
            value += '"iconName":"'+ActList[i].iconName+'",';
            value += '"isMajor":"'+ActList[i].isMajor+'",';
            value += '"toDoFor":"'+ActList[i].toDoFor+'"';
            value+= '}';
            if(i != ActList.size()-1)
            {
                value += ',';
            }
        }
        value+= ']';
        op.Line_Chart_JSON__c = '';
        op.Line_Chart_JSON__c = value;
        if(op.Line_Chart_JSON__c != oldOPVal){
            OpportunityTriggerHandler.isByPassTrigger = true;
            update op;
            OpportunityTriggerHandler.isByPassTrigger = false;
        }
        return ActList;
        
    } 
    
    public class activityWrapper{
        @AuraEnabled public string doneText;
        @AuraEnabled public string status;
        @AuraEnabled public String iconName;
        @AuraEnabled public Boolean isMajor;
        @AuraEnabled public string toDoFor;
    }
    
}