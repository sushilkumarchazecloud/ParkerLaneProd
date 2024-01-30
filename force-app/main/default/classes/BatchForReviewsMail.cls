global class BatchForReviewsMail implements Database.Batchable<sObject>,Database.Stateful,Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date startDate = System.today().addDays(-7);
        Date endDate = System.today().addDays(-1);
        return Database.getQueryLocator('SELECT Id, Name, Purpose__c,FinServ__ReferredByContact__c, FinServ__ReferredByContact__r.Email,FinServ__ReferredByContact__r.Name,FinServ__ReferredByContact__r.FirstName, FinServ__ReferredByContact__r.AccountId, Review_message__c, Review_stars__c, Review_title__c, Review_updated__c, Review_URL__c FROM Opportunity WHERE Review_updated__c >= :startDate AND Review_updated__c <= :endDate AND (Review_stars__c = \'4 stars\' OR Review_stars__c = \'5 stars\') AND FinServ__ReferredByContact__c != null');
      
    }

    global void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        Map<id,string> contentMap = new Map<id,string>();
        Map<id,string> referrerNameMap = new Map<id,string>();
        Map<id,boolean> pluralOrSingularMap = new Map<id,boolean>();
        Set<id> refIds = new Set<id>();
        for(Opportunity op :scope){
            if(!contentMap.containskey(op.FinServ__ReferredByContact__r.AccountId)){
                String reviewTitle = op.Review_title__c;
                String reviewStars = op.Review_stars__c;
                String opportunityName = op.Name;
                string[] nmlist = opportunityName.split(',');               
                String reviewMessage = op.Review_message__c;
                if (reviewMessage != null && reviewMessage.length() > 150) {
                    reviewMessage = reviewMessage.substring(0, 150) + '...';
                }
                
                String reviewURL = op.Review_URL__c;
                String externalReferrer = op.FinServ__ReferredByContact__r.name;
                
                String reviewLink = 'Read the review';
                if (!String.isBlank(reviewURL)) {
                    reviewLink = '<a href="' + reviewURL + '">' + reviewLink + '</a>';
                }
                string body = '<b>'+reviewTitle+'</b>'+'<br/>'+'<span style="color : #808080;">'+reviewStars+' '+'review by '+nmlist[0]+'</span><br/>'+reviewMessage+' '+reviewLink+'<br/>'+'Referred by: '+'<b>'+externalReferrer+'</b>'+'<br/><br/>';
                contentMap.put(op.FinServ__ReferredByContact__r.AccountID, body);
                pluralOrSingularMap.put(op.FinServ__ReferredByContact__r.AccountID,false);
                referrerNameMap.put(op.FinServ__ReferredByContact__r.AccountID,op.FinServ__ReferredByContact__r.Name);
            }
            else{
                String reviewTitle = op.Review_title__c;
                String reviewStars = op.Review_stars__c;
                String opportunityName = op.Name;
                string[] nmlist = opportunityName.split(',');
                
                String reviewMessage = op.Review_message__c;
                if (reviewMessage != null && reviewMessage.length() > 150) {
                    reviewMessage = reviewMessage.substring(0, 150) + '...';
                }
                
                String reviewURL = op.Review_URL__c;
                String externalReferrer = op.FinServ__ReferredByContact__r.name;
                
                String reviewLink = 'Read the review';
                if (!String.isBlank(reviewURL)) {
                    reviewLink = '<a href="' + reviewURL + '">' + reviewLink + '</a>';
                }
                string body = '<b>'+reviewTitle+'</b>'+'<br/>'+'<span style="color : #808080;">'+reviewStars+' '+'review by '+nmlist[0]+'</span><br/>'+reviewMessage+' '+reviewLink+'<br/>'+'Referred by: '+'<b>'+externalReferrer+'</b>'+'<br/><br/>';

                string previous = contentMap.get(op.FinServ__ReferredByContact__r.AccountID);
                string fullbody = body+previous;
                contentMap.put(op.FinServ__ReferredByContact__r.AccountID, fullbody);
                pluralOrSingularMap.put(op.FinServ__ReferredByContact__r.AccountID,true);
                string str = referrerNameMap.get(op.FinServ__ReferredByContact__r.AccountID);
                if(!str.contains(op.FinServ__ReferredByContact__r.Name)){
                    referrerNameMap.put(op.FinServ__ReferredByContact__r.AccountID,str+', '+op.FinServ__ReferredByContact__r.Name);
                }
            }
            refIds.add(op.FinServ__ReferredByContact__r.AccountID);
        }
         
        list<contact> conlist = [select id,AccountID,name,account.name,firstname,email from contact where AccountID IN:refIds ];
        OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address =: UtilityClass.adminEmail];
        EmailTemplate et=[Select id, Subject, Body,Markup from EmailTemplate where Name= 'ReviewsMailToReferrer'];
        List<Messaging.Email> emailList = new List<Messaging.Email>();
        for(contact con : conlist){
            String body = 'Congratulations this week to ';
            string strValue = referrerNameMap.get(con.AccountId);
                List<String> namesList = strValue.split(', ');
                if (namesList.size() == 2) {
                    body += namesList[0] + ' and ' + namesList[1];
                } else {
                    if (namesList.size() > 1) {
                        body += strValue.substring(0, strValue.lastIndexOf(',')) + ' and' + strValue.substring(strValue.lastIndexOf(',') + 1);
                    } else {
                        body += namesList[0];
                    }
                }
            if (pluralOrSingularMap.get(con.AccountId)) {
                body += '! Your customers are so happy that they went to the trouble of writing a review about your referral:';
            } else {
                body += '! Your customer was so happy that they went to the trouble of writing a review about your referral:';
            }
            string subject = 'New review activity for '+con.Account.Name;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String templateBody = et.Markup;
            if(String.isBlank(con.firstname)){
               templateBody = templateBody.replace('{!relatedTo.FinServ__ReferredByContact__r.Name}',con.name);
            }
            else{
                templateBody = templateBody.replace('{!relatedTo.FinServ__ReferredByContact__r.Name}',con.firstname);
            }
            templateBody = templateBody.replace('[Account name]',con.account.name);
            templateBody = templateBody.replace('[message]',body);
            templateBody = templateBody.replace('[dynamic element]',contentMap.get(con.AccountID));
            mail = Messaging.renderStoredEmailTemplate(et.Id, con.id, con.AccountID);
            mail.setSubject(subject);
            mail.setHtmlBody(templateBody);
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setSaveAsActivity(false);
            mail.setUseSignature(false);
            if(owea.size() > 0){
                mail.setorgWideEmailAddressId(Owea.get(0).Id);
            }
            List<string> sendTo = new List<string>();
            sendTo.add(con.Email);
            mail.setToAddresses(sendTo); 
            mail.setBccAddresses(new String[] {'personalapplications@parkerlane.com.au'});
            emailList.add(mail);
        }
        if(!emailList.isEmpty()){
            if(!Test.isRunningTest()){
                Messaging.sendEmail(emailList);   
            }           
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        system.debug('batch job id = '+bc.getJobId());
    }
    
    global void execute(SchedulableContext ctx) {
        BatchForReviewsMail obj = new BatchForReviewsMail();
        Id batchId = Database.executeBatch(obj, 200);     
    }
}