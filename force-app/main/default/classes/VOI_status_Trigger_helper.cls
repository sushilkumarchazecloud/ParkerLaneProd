public class VOI_status_Trigger_helper {
    public void updateStatus(List<VOI_Status__c> VOIList,Map<id, VOI_status__c> oldMap){
        list<VOI_Status__c> voi = [Select id, name,VOI_Type_For__c,Skip_VOI__c,Case_Status__c from VOI_status__c WHERE id in: VOIList];
        List<VOI_status__c> vsList = new List<VOI_status__c>();
        for(VOI_status__c vs : voi){
            if(vs.Case_Status__c != oldMap.get(vs.Id).Case_Status__c){
                if(vs.VOI_Type_For__c == 'E-SIGN' && vs.Case_Status__c == 'Submitted'){
                    vs.VOI_Status__c = 'eSign Complete';
                }
                else if(vs.VOI_Type_For__c == 'FULL' && vs.Skip_VOI__c == true && vs.Case_Status__c == 'Submitted'){
                    vs.VOI_Status__c = 'VOI Failed, eSign Complete';
                }
                else{
                    vs.VOI_Status__c = vs.Case_Status__c;
                }
                vs.Skip_VOI__c = false;
                vsList.add(vs);
            }
            
        }
        
        if(vsList != null && vsList.size() > 0){     
            update vsList;   
        }
    }
    
     public void UpdateOpp(List<VOI_Status__c> VOIList,Map<id, VOI_status__c> oldMap) {
        Set<Id> conIds = new Set<Id>();
        Set<Id> OppIds = new Set<Id>();
        for (VOI_Status__c vs : VOIList) {
            if (vs.VOI_Status__c != oldMap.get(vs.Id).VOI_Status__c || vs.VOI_Type_For__c != oldMap.get(vs.Id).VOI_Type_For__c){
                if (vs.Contact__c != null) {
                    conIds.add(vs.Contact__c);
                }
                if (vs.Opportunity__c != null) {
                    OppIds.add(vs.Opportunity__c);
                }
            }
        }
        
        Set<String> newConIds = new Set<String>();
        Set<String> conIdsfalse = new Set<String>();
        Map<Id,String> ConIdWithStatus = new Map<Id, String>();
        if (!conIds.isEmpty()) {
            for(VOI_Status__c vs : [SELECT Id, VOI_Status__c,VOI_Type_For__c, Contact__c FROM VOI_Status__c WHERE Contact__c IN :conIds]) {
                if(vs.VOI_Status__c == 'Sent' || vs.VOI_Status__c == 'Delivered'){
                    newConIds.add(vs.Contact__c);
                    Datetime now = System.now();
                    String formattedNow = now.format('dd/MM/yy h:mm a');
                    String type = vs.VOI_Type_For__c;
                    String Status = vs.VOI_Status__c;
                    String value = type +' (' +Status+ ' ' +formattedNow+ ');';
                    ConIdWithStatus.put(vs.Contact__c,value);
                }
                else{
                    conIdsfalse.add(vs.Contact__c);
                    Datetime now = System.now();
                    String formattedNow = now.format('dd/MM/yy h:mm a');
                    String type = vs.VOI_Type_For__c;
                    String Status = vs.VOI_Status__c;
                    String value = type +' (' +Status+ ' ' +formattedNow+ ');';
                    ConIdWithStatus.put(vs.Contact__c,value);
                }
            }
        }
        List<Opportunity> OldOppList = new List<Opportunity>();
        List<Opportunity> oppList = new List<Opportunity>();
        if(!OppIds.isEmpty()){
            OldOppList =  [SELECT Id, Applicant_1__r.personContactId, Applicant_2__r.personContactId,
                           App_1_VOI_eSign_Complete__c, App_2_VOI_eSign_Complete__c,App_1_VOI_Details__c,
                           App_2_VOI_Details__c FROM Opportunity WHERE Id IN :OppIds];
        }
        if (!newConIds.isEmpty() && !OldOppList.isEmpty()) {
            for(Opportunity op : OldOppList) {
                if (newConIds.contains(op.Applicant_1__r.personContactId)) {
                    op.App_1_VOI_eSign_Complete__c = false;
                    if(!ConIdWithStatus.isEmpty()){
                        if(op.App_1_VOI_Details__c == null){
                            op.App_1_VOI_Details__c = ConIdWithStatus.get(op.Applicant_1__r.personContactId);
                        }
                        else{
                            String OldStatusOnOpp = op.App_1_VOI_Details__c;
                            op.App_1_VOI_Details__c = ConIdWithStatus.get(op.Applicant_1__r.personContactId)+' '+OldStatusOnOpp;    
                        } 
                    }
                } if (newConIds.contains(op.Applicant_2__r.personContactId)) {
                    op.App_2_VOI_eSign_Complete__c = false;
                    if(!ConIdWithStatus.isEmpty()){
                        if(op.App_2_VOI_Details__c == null){
                            op.App_2_VOI_Details__c = ConIdWithStatus.get(op.Applicant_2__r.personContactId);
                        }
                        else{
                            String OldStatusOnOpp = op.App_2_VOI_Details__c;
                            op.App_2_VOI_Details__c = ConIdWithStatus.get(op.Applicant_2__r.personContactId)+' '+OldStatusOnOpp;   
                        }
                    }
                }
                oppList.add(op); 
            }
        }
        
        else if (!conIdsfalse.isEmpty() && !OldOppList.isEmpty()) {
            for(Opportunity op : OldOppList) {
                if (conIdsfalse.contains(op.Applicant_1__r.personContactId)) {
                    op.App_1_VOI_eSign_Complete__c = true;
                    if(!ConIdWithStatus.isEmpty()){
                        if(op.App_1_VOI_Details__c == null){
                            op.App_1_VOI_Details__c = ConIdWithStatus.get(op.Applicant_1__r.personContactId);
                        }
                        else{
                            String OldStatusOnOpp = op.App_1_VOI_Details__c;
                            op.App_1_VOI_Details__c = ConIdWithStatus.get(op.Applicant_1__r.personContactId)+' '+OldStatusOnOpp;    
                        }
                    }
                } 
                if (conIdsfalse.contains(op.Applicant_2__r.personContactId)) {
                    op.App_2_VOI_eSign_Complete__c = true;
                    if(!ConIdWithStatus.isEmpty()){
                        if(op.App_2_VOI_Details__c == null){
                            op.App_2_VOI_Details__c = ConIdWithStatus.get(op.Applicant_2__r.personContactId);
                        }
                        else{
                            String OldStatusOnOpp = op.App_2_VOI_Details__c;
                            op.App_2_VOI_Details__c = ConIdWithStatus.get(op.Applicant_2__r.personContactId)+' '+OldStatusOnOpp;   
                        }
                    }
                }
                oppList.add(op); 
            }
        }
        if (!oppList.isEmpty()) {
            update oppList;
        }
    }
    
    public void UpdateOppAfterInsert(List<VOI_Status__c> VOIList){
        Set<Id> conIds = new Set<Id>();
        Set<Id> OppIds = new Set<Id>();
        Map<Id,String> ConIdWithStatus = new Map<Id, String>();
        Map<Id,String> ConWithstatusforTrueFalse = new Map<Id,String>();
        List<Opportunity> oppList = new List<Opportunity>(); 
        
        for(VOI_Status__c vs : VOIList){
            if(vs.VOI_Status__c != null && vs.Contact__c != null && vs.Opportunity__c != null){
                conIds.add(vs.Contact__c);
                OppIds.add(vs.Opportunity__c);
                Datetime now = System.now();
                String formattedNow = now.format('dd/MM/yy h:mm a');
                String type = vs.VOI_Type_For__c;
                String Status = vs.VOI_Status__c;
                String value = type +' (' +Status+ ' ' +formattedNow+ ');';
                ConIdWithStatus.put(vs.Contact__c,value);
                ConWithstatusforTrueFalse.put(vs.Contact__c,Status);
            } 
        }
        if(!OppIds.isEmpty() && !conIds.isEmpty()){
            for(Opportunity op : [SELECT Id, Applicant_1__r.personContactId, Applicant_2__r.personContactId,
                                  App_1_VOI_eSign_Complete__c, App_2_VOI_eSign_Complete__c,App_1_VOI_Details__c,
                                  App_2_VOI_Details__c FROM Opportunity WHERE Id IN :OppIds]){
                                      if (conIds.contains(op.Applicant_1__r.personContactId)) {
                                          if(!ConWithstatusforTrueFalse.isEmpty() && ConWithstatusforTrueFalse.containsKey(op.Applicant_1__r.personContactId)){
                                              String Status = ConWithstatusforTrueFalse.get(op.Applicant_1__r.personContactId);
                                              if(Status == 'Sent' || Status == 'Delivered'){
                                                  op.App_1_VOI_eSign_Complete__c = false; 
                                              }
                                          }
                                          if(!ConIdWithStatus.isEmpty()){
                                              if(op.App_1_VOI_Details__c == null){
                                                  op.App_1_VOI_Details__c = ConIdWithStatus.get(op.Applicant_1__r.personContactId);
                                              }
                                              else{
                                                  String OldStatusOnOpp = op.App_1_VOI_Details__c;
                                                  op.App_1_VOI_Details__c = ConIdWithStatus.get(op.Applicant_1__r.personContactId)+' '+OldStatusOnOpp;    
                                              }
                                          }
                                      } 
                                      if (conIds.contains(op.Applicant_2__r.personContactId)) {
                                          if(!ConWithstatusforTrueFalse.isEmpty() && ConWithstatusforTrueFalse.containsKey(op.Applicant_2__r.personContactId)){
                                              String Status = ConWithstatusforTrueFalse.get(op.Applicant_2__r.personContactId);
                                              if(Status == 'Sent' || Status == 'Delivered'){
                                                  op.App_2_VOI_eSign_Complete__c = false; 
                                              }
                                          }
                                          if(!ConIdWithStatus.isEmpty()){
                                              if(op.App_2_VOI_Details__c == null){
                                                  op.App_2_VOI_Details__c = ConIdWithStatus.get(op.Applicant_2__r.personContactId);
                                              }
                                              else{
                                                  String OldStatusOnOpp = op.App_2_VOI_Details__c;
                                                  op.App_2_VOI_Details__c = ConIdWithStatus.get(op.Applicant_2__r.personContactId)+' '+OldStatusOnOpp; 
                                              }
                                          }
                                      }
                                      oppList.add(op); 
                                  }
            if (!oppList.isEmpty()) {
                update oppList;
            }
        }
    }
    
    public void createAdviserTask(List<VOI_Status__c> VOIList,Map<id, VOI_status__c> oldMap){
        list<String> recordTypes = new list<string>{'Home Improvement','Solar','Green Loan','Debt Consolidation','Personal Loan','Vehicle Purchase'};
        Id siteUser = [select id from user where username =: System.Label.Admin_User_Name].id;
        list<id> idlist = new list<id>();
        list<task> oldtasklist = new list<task>();
        list<task> tklist = new list<task>();
        list<opportunity> opplist = new list<opportunity>();
        Set<Id> conIds = new Set<Id>();
        Set<Id> OppIds = new Set<Id>();
        map<id,string> statusMap = new map<id,string>();
        for(VOI_Status__c vs : VOIList){
            if ( vs.Case_Status__c == 'Submitted' &&  vs.Case_Status__c != oldMap.get(vs.Id).Case_Status__c && vs.Contact__c != null && vs.Opportunity__c != null && vs.VOI_Type_For__c!=null) {
                conIds.add(vs.Contact__c);
                statusMap.put(vs.Opportunity__c, vs.VOI_Type_For__c);
            }
        }
        if(statusMap.keySet() != null && !statusMap.keySet().isEmpty()){
            opplist = [select id,name,applicant_1__r.personcontactID,applicant_2__r.personcontactID,Credit_Analyst__r.id from opportunity where ID IN:statusMap.keySet() AND recordType.Name IN:recordTypes];
            oldtasklist = [select id,status from task where whatId IN :statusMap.keySet() AND Status != 'Completed' AND Subject like 'Verify P%'];
        }
        if(!opplist.isEmpty() && oldtasklist.isEmpty()){
            date dueDate = OpportunityTriggerHandler.checkForDuedate(Date.today());
            system.debug('DUEDATE '+dueDate);
           string body = '';
            string title='';
            string notificationBody = '';
            for(Opportunity opp : opplist){
                if(conIds.contains(opp.applicant_1__r.personcontactID)){
                    title = 'Verify P1 VOI '+statusMap.get(opp.Id)+' '+'Submitted '+system.now().format('dd/MM/yy h:mm a', 'Australia/Sydney');
                    notificationBody = 'Verify P1 VOI '+statusMap.get(opp.Id)+' '+'Submitted ';
                }
                else if(conIds.contains(opp.applicant_2__r.personcontactID)){
                    title = 'Verify P2 VOI '+statusMap.get(opp.Id)+' '+'Submitted '+system.now().format('dd/MM/yy h:mm a', 'Australia/Sydney');
                    notificationBody = 'Verify P2 VOI '+statusMap.get(opp.Id)+' '+'Submitted ';
                }
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
                body = notificationBody+'for'+' '+opp.Name;
                tklist.add(tk);
                //opp.Application_Pending_Status__c = 'Adviser Action'; /*Commented by tazeem for 1057*/
            }
            system.debug('tkkklist'+tklist.size());
            insert tklist;
            //update opplist; /*Commented by tazeem for 1057*/
            CustomNotificationFromApex.notifyUsers(opplist,idlist,title,body);
        }   
    }
}