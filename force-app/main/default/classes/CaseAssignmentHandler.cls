public class CaseAssignmentHandler {
    public void assignCaseOwner(list<case> newCase){        
        list<Id> personalList = new list<Id>();
        list<Id> mortgageList = new list<Id>();
        List<Case> CaseUpdate =  new List<Case>();
        List<string> personalRecordTypes = new List<string>{'Solar','Green Loan','Home Improvement','Debt Consolidation','Personal Loan','Vehicle Purchase','Commercial Solar Purchase'};
            List<string> MortgageRecordTypes = new List<string>{'Commercial Mortgage', 'Commercial Property Purchase', 'First Home Purchase', 'Home Loan Construction', 'Home Loan Purchase', 'Home Loan Refinance', 'Investment Property Purchase', 'Next Home Purchase'};
                list<string> emailList = new list<string>();
        for(Case cs : newCase){
            emailList.add(cs.SuppliedEmail);
        } 
        List<opportunity> opp = [Select id, name, Applicant_1__c, Contact_1__c, RecordTypeId from opportunity where Applicant_1_Email__c IN: emailList OR Applicant_2_Email__c IN: emailList Limit 1];
        List<contact> con = [Select id, Name, Email, Referrer_Rating__c from contact where Email IN: emailList AND Account.RecordType.developerName = 'Referrer_Business' Limit 1];
        ID queueId;
        if(con.size() > 0){
            if(con[0].Referrer_Rating__c == 'Platinum'){
                queueId = [SELECT Queue.Id FROM queuesobject WHERE queue.name='Platinum Referrers'].Queue.Id;
            }
            else if(con[0].Referrer_Rating__c == 'Gold'){
                queueId = [SELECT Queue.Id FROM queuesobject WHERE queue.name='Gold Referrers'].Queue.Id;
            }
            else if(con[0].Referrer_Rating__c == 'Blue' || con[0].Referrer_Rating__c == 'Silver'){
                queueId = [SELECT Queue.Id FROM queuesobject WHERE queue.name='Other Referrers'].Queue.Id;
            }
        }
        /*for(opportunity op : opp){
            if(personalRecordTypes.contains(Schema.SObjectType.opportunity.getRecordTypeInfosById().get(op.RecordTypeId).getName())){
                personalList.add(op.Id);
            }
            else if(MortgageRecordTypes.contains(Schema.SObjectType.opportunity.getRecordTypeInfosById().get(op.RecordTypeId).getName())){
                mortgageList.add(op.id);
            }
		}*/
        if(opp != null && opp.size() > 0){
            for(Case cs : newCase){               
                Case cse = new Case();
                cse.Id = cs.Id;
                cse.Opportunity__c = opp[0].id;
                cse.AccountId = opp[0].Applicant_1__c;
                cse.ContactId = opp[0].Contact_1__c;
                CaseUpdate.add(cse);
            }
        }        
        else if((opp == null || opp.size() == 0) && con.size() > 0){
            for(Case cs : newCase){               
                Case cse = new Case();
                cse.Id = cs.Id;
                if(queueId != null){
                    cse.OwnerId = queueId;
                }
                cse.ContactId = con[0].id;
                CaseUpdate.add(cse);
            }
        }
        update CaseUpdate;
        /*if(personalList.size() > 0){
            set<id> grupMem = new Set<id>();
            list<user> userList = new list<user>();
            List<Case> CaseUpdate =  new List<Case>();
            Group gc = [select id, name from group where name = 'PersonalCaseGroup'];            
            for(GroupMember gcM : [select id, UserOrGroupid from GroupMember where GroupId =: gc.id]){
                grupMem.add(gcM.UserOrGroupid);
            }
            if(grupMem != null && grupMem.size() > 0){
                for(user us : [select id, name from user where Id IN: grupMem]){
                    userList.add(us);
                }
                if(userList != null && userList.size() > 0){
                    Integer randomNumber = Integer.valueof((Math.random() * userList.size()));                
                    User usr = userList[randomNumber];
                    for(Case cs : newCase){               
                        Case cse = new Case();
                        cse.Id = cs.Id;
                        //cse.OwnerId = usr.Id;
                        cse.Opportunity__c = opp[0].id;
                        cse.AccountId = opp[0].Applicant_1__c;
                        CaseUpdate.add(cse);
                    }
                    update CaseUpdate;
                }
            }
        }
        if(mortgageList.size() > 0){
            set<id> grupMem = new Set<id>();
            list<user> userList = new list<user>();
            List<Case> CaseUpdate =  new List<Case>();
            Group gc = [select id, name from group where name = 'MortgageCaseGroup'];            
            for(GroupMember gcM : [select id, UserOrGroupid from GroupMember where GroupId =: gc.id]){
                grupMem.add(gcM.UserOrGroupid);
            }
            if(grupMem != null && grupMem.size() > 0){
                for(user us : [select id, name from user where Id IN: grupMem]){
                    userList.add(us);
                }
                if(userList != null && userList.size() > 0){
                    Integer randomNumber = Integer.valueof((Math.random() * userList.size()));                
                    User usr = userList[randomNumber];
                    for(Case cs : newCase){               
                        Case cse = new Case();
                        cse.Id = cs.Id;
                        //cse.OwnerId = usr.Id;
                        cse.Opportunity__c = opp[0].id;
                        cse.AccountId = opp[0].Applicant_1__c;
                        CaseUpdate.add(cse);
                    }
                    update CaseUpdate;
                }
            }
        }*/
    }
}