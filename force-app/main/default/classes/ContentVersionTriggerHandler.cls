public class ContentVersionTriggerHandler {
    Public static boolean Stop = false;
    public void afterUpdate(List<ContentVersion> newCntVersion){
        Set<Id> objId = new Set<Id>();
        Set<Id> contIDs = new Set<Id>();
        Set<Id> lenIDs = new Set<Id>();
        if(newCntVersion.Size() > 0){
            for(ContentVersion Cv : newCntVersion){
                if(Cv.ContentDocumentId != null && cv.Document_Requested__c != null && cv.Related__c != null  && cv.Current_in_use__c == false){
                    contIDs.add(Cv.ContentDocumentId);
                }
            }
        }
        updateLenderCredit(newCntVersion);
        List<ContentDocumentLink> linkList = new List<ContentDocumentLink>();
        Set<Id> contIdsRelToOpp = new Set<Id>();
        if(contIDs.Size() > 0){
            linkList = [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN: contIDs]; 
        }
        if(linkList.Size() > 0){
            for(ContentDocumentLink link : linkList){
                if(link.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Opportunity'){
                    objId.add(link.LinkedEntityId);
                    contIdsRelToOpp.add(link.ContentDocumentID);
                }
            }  
        } 
        Set<Id> ContentDocIds = new Set<Id>();
        if(contIdsRelToOpp.Size() > 0){
            List<ContentVersion> cntList = [SELECT Id,ContentDocumentId,Document_Requested__r.Category__c,Current_in_use__c,CreatedDate from ContentVersion where ContentDocumentId IN: contIdsRelToOpp AND Id IN: newCntVersion ORDER BY CreatedDate DESC];
            List<ContentVersion> newcntList = new List<ContentVersion>();
            if(cntList.size() > 0){
                for(ContentVersion cvv : cntList){
                    if(cvv.Document_Requested__r.Category__c != null && (cvv.Document_Requested__r.Category__c == 'Purchase Invoice') ){
                        cvv.Current_in_use__c = true;                       
                        ContentDocIds.add(cvv.ContentDocumentId);
                        newcntList.add(cvv);
                        break;
                    }
                }
                if(newcntList.Size()>0){
                    update newcntList;
                    Set<Id> oldcontIDs = new Set<Id>();
                    if(objId.Size() > 0){
                        List<ContentDocumentLink> oldConLinks = [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility 
                                                                 FROM ContentDocumentLink WHERE LinkedEntityId IN: objId];
                        if(oldConLinks.Size() > 0){
                            for(ContentDocumentLink link : oldConLinks){
                                oldcontIDs.add(link.ContentDocumentId);
                            }  
                            if(oldcontIDs.Size() > 0){
                                List<ContentVersion> oldcntList = [SELECT Id,contentDocumentId,Category__c,Current_in_use__c from contentVersion where contentDocumentId IN:oldcontIDs AND Id NOT IN:newCntVersion AND Current_in_use__c=True];
                                List<ContentVersion> oldCntListToUpdate = new List<ContentVersion>();
                                if(oldcntList.Size() > 0){
                                    for(ContentVersion cvv1 : oldcntList){
                                        if( (cvv1.category__c == 'Purchase Invoice') && cvv1.Current_in_use__c == true){
                                            cvv1.Current_in_use__c = false;
                                            oldCntListToUpdate.add(cvv1);
                                        }
                                    }
                                    if(oldCntListToUpdate.Size() > 0){
                                        Update oldCntListToUpdate; 
                                    }
                                }
                            }
                        }
                    }    
                }  
            }
        }
        updateFundingRequest(newCntVersion);
    }
    
    public void updateLenderCredit(List<ContentVersion> newCntVersion){
        Set<Id> objId = new Set<Id>();
        Set<Id> lenIDs = new Set<Id>();
        Set<Id> contIDs = new Set<Id>();
        if(newCntVersion.Size() > 0){
            for(ContentVersion Cv : newCntVersion){
                if(Cv.ContentDocumentId != null && cv.Document_Requested__c != null && cv.Related__c != null  && cv.Current_in_use__c == true){
                    contIDs.add(Cv.ContentDocumentId);
                }
            }
        }
        List<ContentDocumentLink> linkList = new List<ContentDocumentLink>();
        Set<Id> contIdsRelToOpp = new Set<Id>();
        if(contIDs.Size() > 0){
            linkList = [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN: contIDs]; 
        }
        if(linkList.Size() > 0){
            for(ContentDocumentLink link : linkList){
                if(link.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Opportunity'){
                    objId.add(link.LinkedEntityId);
                    contIdsRelToOpp.add(link.ContentDocumentID);
                }
            }  
        } 
        Set<Id> ContentDocIds = new Set<Id>();
        if(contIdsRelToOpp.Size() > 0){
            List<ContentVersion> cntList = [SELECT Id,ContentDocumentId,Document_Requested__r.Category__c,Current_in_use__c,CreatedDate from ContentVersion where ContentDocumentId IN: contIdsRelToOpp AND Id IN: newCntVersion ORDER BY CreatedDate DESC];
            List<ContentVersion> newcntList = new List<ContentVersion>();
            list<Opportunity> docOpp = [select id,name,Credit_Contract_Date__c from opportunity where ID In : objId];
            if(cntList.size() > 0){
                for(ContentVersion cvv : cntList){
                    if(cvv.Document_Requested__r.Category__c == 'Lender Credit Contract'){
                        docOpp[0].Credit_Contract_Date__c = cvv.CreatedDate;
                        break;
                    }
                }
            }
            update docOpp;
        }
    }
    
    public void afterInsert(List<ContentVersion> newCntVersion){
        User custSupPersonId = [select id,username from user where username=: System.Label.customerSite LIMIT 1];
        list<String> recordTypes = new list<string>{'Home Improvement','Solar','Green Loan','Debt Consolidation','Personal Loan','Vehicle Purchase'};
        Id siteUser = [select id, name from user where username =: System.Label.Admin_User_Name].id;
        list<id> idlist = new list<id>();
        list<opportunity> opplist = new list<opportunity>();
        list<task> newtasklist = new list<task>();
        list<task> oldtasklist = new list<task>();
        Set<Id> contIDs = new Set<Id>();
        Set<Id> objId = new Set<Id>();
        for(ContentVersion Cv : newCntVersion){
            if(Cv.ContentDocumentId != null && Cv.OwnerId == custSupPersonId.Id){
                contIDs.add(Cv.ContentDocumentId);
            }   
        }
        List<ContentDocumentLink> linkList = new List<ContentDocumentLink>();
        if(contIDs.Size() > 0){
            linkList = [SELECT Id,LinkedEntityId,ContentDocumentId,ContentDocument.CreatedDate FROM ContentDocumentLink WHERE ContentDocumentId IN: contIDs]; 
        }
        Map<Id, string> oppDocDateMap = new Map<Id, string>();
        if(linkList.Size() > 0){
            for(ContentDocumentLink link : linkList){
                if(link.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Opportunity'){
                    objId.add(link.LinkedEntityId);
                    Datetime now = link.ContentDocument.CreatedDate;
                    String formattedNow = now.format('dd/MM/yy h:mm a');
                    oppDocDateMap.put(link.LinkedEntityId, formattedNow);
                }
            }  
        }
        if(oppDocDateMap.keySet() != null ){
            opplist = [select id,Application_Pending_Status__c,name,Customer_Support_Person__r.id,Credit_Analyst__r.id from opportunity where recordType.name IN:recordTypes AND ID IN:oppDocDateMap.keySet()];
            oldtasklist = [select id,status from task where whatId IN :oppDocDateMap.keySet() AND Status != 'Completed' AND Subject like 'Review Documents Uploaded%'];
        }
        //Added by tazeem for 1057
        System.debug('--=-oopp==='+opplist);
        if(opplist != null && opplist.size() > 0){
            List<opportunity> updateForAdvisor = new List<opportunity>();
            for(opportunity op: opplist){
                System.debug('--=-op==='+op);
                op.Application_Pending_Status__c = 'Adviser Action';
                updateForAdvisor.add(op);
            }
            if(updateForAdvisor != null && updateForAdvisor.size() > 0){
                System.debug('--=-updateForAdvisor==='+updateForAdvisor);
                update updateForAdvisor;
            }
        }
        ////Added by tazeem for 1057
        
        List<opportunity> oppNewList = new List<opportunity>();
        if(!opplist.isEmpty() && oldtasklist.isEmpty()){
            date dueDate = OpportunityTriggerHandler.checkForDuedate(system.today());
            string body = '';
            string title = '';
            for(Opportunity opp : opplist){
                title = 'Review Documents Uploaded '+oppDocDateMap.get(opp.id);
                Task tk = new Task();
                tk.Subject = title;
                tk.WhatId = opp.Id;
                if(opp.Credit_Analyst__c != null){
                    tk.OwnerId = opp.Credit_Analyst__c;
                    idlist.add(opp.Credit_Analyst__c);
                }
                else{
                    tk.OwnerId = siteUser;
                    idlist.add(siteUser);
                }
                //tk.OwnerId = opp.Credit_Analyst__r.id != null ? opp.Credit_Analyst__r.id : siteUser;
                tk.Status = 'Not Started';
                tk.ActivityDate = dueDate;
                tk.Priority = 'High';
                newtasklist.add(tk);
                body = 'Documents Uploaded for '+opp.Name;                
                oppNewList.add(opp);
            }
            insert newtasklist;
            if(oppNewList != null && oppNewList.size() > 0)
            	update opplist;
            
            CustomNotificationFromApex.notifyUsers(opplist,idlist,title,body);
        }    
    }
    
    public void updateFundingRequest(List<ContentVersion> newCntVersion){
        system.debug('newCntVersion '+newCntVersion);
        boolean LenderCreditDocExist = false;
        Set<Id> contIDs = new Set<Id>();
        Set<Id> objId = new Set<Id>();
        if(newCntVersion.Size() > 0){
            for(ContentVersion Cv : newCntVersion){
                system.debug('caretiry'+cv.Category__c);
                system.debug('cusrent'+cv.Current_in_use__c);
                if(Cv.ContentDocumentId != null && cv.Category__c =='Lender Credit Contract' && cv.Document_Requested__c != null && cv.Related__c != null  && cv.Current_in_use__c == true){
                    LenderCreditDocExist = true;
                    contIDs.add(Cv.ContentDocumentId); 
                    break;
                } 
            }
        }
        if(LenderCreditDocExist){
            List<ContentDocumentLink> linkList = new List<ContentDocumentLink>();
            if(contIDs.Size() > 0){
                linkList = [SELECT Id,LinkedEntityId,ContentDocumentId,ContentDocument.CreatedDate FROM ContentDocumentLink WHERE ContentDocumentId IN: contIDs]; 
            }
            Map<Id, string> oppDocDateMap = new Map<Id, string>();
            if(linkList.Size() > 0){
                for(ContentDocumentLink link : linkList){
                    if(link.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Opportunity'){
                        objId.add(link.LinkedEntityId);
                    }
                }  
            }
            list<Funding_Request__c> fnList = [SELECT ID,Request_Status__c,Opportunity__C,Customer_Authorisation_Status__c,Requested_by__c FROM Funding_Request__c where Opportunity__c IN: objId];
            list<Funding_Request__c> fnListtoUpdate = new list<Funding_Request__c>();
            if(!fnList.isEmpty()){
                //system.Assert(false);
                for(Funding_Request__c fr : fnList){
                    if(fr.Request_Status__c == 'Payment requested by customer (pending contract)'){
                        if(fr.Customer_Authorisation_Status__c == 'Authorised'){
                            fr.Request_Status__c = 'Payment authorised by customer';
                        }
                        else{
                            fr.Request_Status__c = 'Payment requested by customer';
                        }
                        fnListtoUpdate.add(fr);
                    }
                    else if(fr.Request_Status__c == 'Payment requested by supplier (pending contract)'){
                        if(fr.Customer_Authorisation_Status__c == 'Authorised'){
                            fr.Request_Status__c = 'Payment authorised by customer';
                        }
                        else{
                            fr.Request_Status__c = 'Payment requested by supplier';
                        }
                        fnListtoUpdate.add(fr);
                    }                  
                }
                if(!fnListtoUpdate.isEmpty()){
                    update fnListtoUpdate;
                }
            }
        }
    }
}