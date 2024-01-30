public without sharing class ResendSMSController {
	@auraEnabled
    public static List<string> fetchContacts(ID iddata) {
        opportunity opp = [select Id, Applicant_1__c, Applicant_2__c, Applicant_1__r.Name, Applicant_2__r.Name from opportunity WHERE id =: iddata LIMIT 1];
        
        list<string> conList = new List<string>();
        
        conlist.add(opp.Applicant_1__r.Name);
        conlist.add(opp.Applicant_2__r.Name);
        
        return conList;
    }
    
    @auraEnabled
    public static string fetchPhone(ID iddata, string Name) {
        opportunity opp = [select Id, Applicant_1__c,Applicant_1__r.Phone,Applicant_2__r.Phone, Applicant_2__c, Applicant_1__r.Name, Applicant_2__r.Name from opportunity WHERE id =: iddata LIMIT 1];
        
        string Phone = '';
        if(Name == opp.Applicant_1__r.Name){
            Phone = opp.Applicant_1__r.Phone;
        }
        if(Name == opp.Applicant_2__r.Name){
            Phone = opp.Applicant_2__r.Phone;
        }
        
        return Phone;
    }
    
    @auraEnabled
    public static string resendSMS(String phoneNo, String OppId, String contactName, string voiType, string viaMethod){       
        
        opportunity opp = [select Id,Current_Application_Sections__c,Application_Sections__c,Document_Redirect_URL__c,Applicant_2__r.personContactId,Applicant_1__r.personContactId, Applicant_1__c,Applicant_1__r.Phone,Applicant_2__r.Phone, Applicant_2__c, Applicant_1__r.Name, Applicant_2__r.Name from opportunity WHERE id =: OppId LIMIT 1];     
        
        Boolean isAppOne = false;
        string conid = '';
        if(contactName == opp.Applicant_1__r.Name){
            conid = opp.Applicant_1__r.personContactId;
        }
        if(contactName == opp.Applicant_2__r.Name){
            conid = opp.Applicant_2__r.personContactId;
        }

        if(conid == opp.Applicant_1__r.personContactId){
            isAppOne = true;
        }
        if(conid == opp.Applicant_2__r.personContactId){
            isAppOne = false;
        }
                
        
        string IntrandomNumber = string.valueOf(Math.round((Math.random() * (900000) + 100000)));
        Set<id> vioIdSet = new Set<id>();
        for(VOi_status__c vois : [select Id,link_Expire_code__c, Name,Case_Status__c, contact__c, contact__r.name from VOi_status__c WHERE contact__r.id =: conid AND Opportunity__r.Id =: OppId AND Case_Status__c != 'Verified' AND Case_Status__c != 'Rejected' order by createddate DESC LIMIT 1]){
            if(vois.Case_Status__c == 'Submitted'){
               	string msg = vois.Contact__r.name + ' has already completed the VOI. To send again, you must first update the status of the current VOI record to either Verified or Rejected.';
                return msg;
            }
            else if(vois.Case_Status__c == 'Delivered' || vois.Case_Status__c == 'Sent'){
                vioIdSet.add(vois.id);            
            }
        }
        
        List<string> smsText = new List<string>();
        string voiSId= '';
        for(smagicinteract__smsMagic__c obj : [select ID, name,VOI_Status__c,VOI_Status__r.id,smagicinteract__SMSText__c, smagicinteract__Contact__c from smagicinteract__smsMagic__c WHERE VOI_Status__r.id IN: vioIdSet order by createddate DESC LIMIT 1]){
            smsText.add(obj.smagicinteract__SMSText__c);
            voiSId = obj.VOI_Status__r.id;
        }
	
        if(smsText != null && smsText.size() > 0){
        	SMSController.SendMessageWithOpportunityAndContact('Contact', 'Parkerlane', phoneNo, OppId, conid, IntrandomNumber, smsText[0], voiSId);    
        	return 'SMS Sent Successfully';
        }	
        else{
            string SecureCodeOriginal = string.valueOf(Math.round((Math.random() * (9000) + 1000)));
            VOI_Detail__c voi  = new VOI_Detail__c();
            voi.Secure_Code_Orignal__c = SecureCodeOriginal;
            voi.Contact__c = ConId;
            voi.opportunity__c = opp.Id;
            voi.VOI_type__c = voiType;
            insert voi;  

            string URL = System.Label.baseUrl + 'DigitalSigning?oppId=' + opp.Id + '&conId=' + ConId + '&r='+ IntrandomNumber;  
            VOI_Status__c obj = new VOI_Status__c();
            obj.Opportunity__c = opp.Id;
            obj.Contact__c = conid;
            obj.Case_Status__c = 'Sent';
            obj.link_Expire_code__c = IntrandomNumber;
            obj.VOI_Type_For__c = voiType;
            if(voiType == 'E-SIGN'){
                obj.Current_VOI_section__c = 'CQP';
            }
            else if(voiType == 'FULL' || voiType == 'VOI'){
                obj.Current_VOI_section__c = 'Id Upload';
            }
            obj.VOI_Detail__c = voi.id;
            obj.VOI_URL__c = URL;
            insert obj;   


            if(isAppOne){
                opp.Document_Redirect_URL__c = URL;
               	OpportunityTriggerHandler.isByPassValidation = true;
                    opp.Current_Application_Sections__c = 'VOI';
                    opp.Application_Sections__c = 'VOI';
                    update opp;
            	OpportunityTriggerHandler.isByPassValidation = false;
            }
            
            string message = '';
            if(viaMethod == 'SMS and email'){
            	SMSController.SendMessageWithOpportunityAndContact('Contact', 'Parkerlane', phoneNo, OppId, conid, IntrandomNumber, '', obj.Id);    
                sendEmailOfVOI(obj.id);
                message = 'SMS and email sent Successfully';
            }
            if(viaMethod == 'SMS only'){
                SMSController.SendMessageWithOpportunityAndContact('Contact', 'Parkerlane', phoneNo, OppId, conid, IntrandomNumber, '', obj.Id);    
                 message = 'SMS Sent Successfully';
            }
            if(viaMethod == 'Email only'){
                sendEmailOfVOI(obj.id);
                message = 'Email Sent Successfully';
            }
            
          	
            
            return message;
        }
        
        
      }
    
    public static void sendEmailOfVOI(String VOiId) {
        VOI_status__c voi = [SELECT Id, Contact__r.id, opportunity__r.Applicant_1__r.name, opportunity__r.Purpose__c, VOI_Detail__r.id, VOI_URL__c, contact__r.Email, contact__r.FirstName, Current_VOI_section__c, VOI_Type_For__c, name, VOI_Detail__c, contact__r.name, Skip_VOI__c FROM VOI_status__c WHERE Id = :VOiId ORDER BY CreatedDate DESC LIMIT 1];
        
        Contact con = [SELECT Id, Name, Session_Start_Time__c, voi_Email_Verification_Code__c, Email, Count__c, Phone, PhoneForPortal__c FROM Contact WHERE Id = :voi.Contact__r.id LIMIT 1];
        
        String dynamicSubject = 'Action required! ';
        if (voi.VOI_Type_For__c == 'FULL') {
            dynamicSubject += 'verify your details';
        }
        if (voi.VOI_Type_For__c == 'VOI') {
            dynamicSubject += 'verify your identity';
        }
        if (voi.VOI_Type_For__c == 'E-SIGN') {
            dynamicSubject += 'authorize your documents';
        }
        
        EmailTemplate et = [SELECT Id, Subject FROM EmailTemplate WHERE Name = 'CustomVOIMail'];
        
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :UtilityClass.adminEmail];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        
        if (con.Email != null) {
            sendTo.add(con.Email);
        }
        
        if (owea.size() > 0) {
            mail.setOrgWideEmailAddressId(owea[0].Id);
        }
        
        System.debug('sendTo->' + sendTo);
        mail.setTemplateId(et.Id);
        mail.setTargetObjectId(con.Id);
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setSubject(dynamicSubject);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(true);
        mail.setToAddresses(sendTo);
        
        // Render the email template content into the email body
        mail.setHtmlBody(Messaging.renderStoredEmailTemplate(et.Id, con.Id, voi.Id).getHtmlBody());
        
        mails.add(mail);
        
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(mails);
        }
    }

    
    
    @auraEnabled
    public static List<string> fetchAccount(ID AccID) {
        System.debug('id-====='+AccID);
       
        List<Contact> con = [select Id,Phone, name from Contact WHERE AccountId =: AccID AND Is_Authorised_Signatory__c = true LIMIT 1];
        
        List<string> temp = new List<string>();
        
        if(!con.isEmpty()){
            temp.add(con[0].name);
            temp.add(con[0].Phone);
            
            return temp;
        }else{
            return null;
        }
        
    }
    
    @auraEnabled
    public static string sendSmsFromReferrer(Id AccID, string Name, string phone){
        
        List<Contact> con = [select Id,Phone, name from Contact WHERE AccountId =: AccID AND Is_Authorised_Signatory__c = true LIMIT 1];
        
        string IntrandomNumber = string.valueOf(Math.round((Math.random() * (900000) + 100000)));
        Set<id> vioIdSet = new Set<id>();
        for(VOi_status__c vois : [select Id,link_Expire_code__c, Name,Case_Status__c, contact__c, contact__r.name from VOi_status__c WHERE contact__r.id IN: con AND Case_Status__c != 'Verified' AND Case_Status__c != 'Rejected' order by createddate DESC LIMIT 1]){
            if(vois.Case_Status__c == 'Submitted'){
                string msg = vois.Contact__r.name + ' has already completed the VOI. To send again, you must first update the status of the current VOI record to either Verified or Rejected.';
                System.debug('mesgae+'+msg);
                return msg;
            }
            else if(vois.Case_Status__c == 'Delivered' || vois.Case_Status__c == 'Sent'){
                vioIdSet.add(vois.id);            
            }
        }
        List<string> smsText = new List<string>();
        string voiSId= '';
        for(smagicinteract__smsMagic__c obj : [select ID, name,VOI_Status__c,VOI_Status__r.id,smagicinteract__SMSText__c, smagicinteract__Contact__c from smagicinteract__smsMagic__c WHERE VOI_Status__r.id IN: vioIdSet order by createddate DESC LIMIT 1]){
            smsText.add(obj.smagicinteract__SMSText__c);
            voiSId = obj.VOI_Status__r.id;
        }
        
        if(smsText != null && smsText.size() > 0){
            SMSController.SendMessageToReferr('Contact', 'Parkerlane', con[0].id, AccID, IntrandomNumber, smsText[0], voisId);
            System.debug('firstSuccess');
            return 'Success';
        }	
        else{
            VOI_Status__c obj = new VOI_Status__c();
            obj.Account__c = AccID;
            obj.Contact__c = con[0].id;
            obj.Case_Status__c = 'Sent';
            obj.link_Expire_code__c = IntrandomNumber;            
            
            insert obj;     
            
            SMSController.SendMessageToReferr('Contact', 'Parkerlane', con[0].id, AccID, IntrandomNumber, '', obj.id);
            
            System.debug('secSuccess');
            return 'Success';
        }   
        
    }
    
    @auraEnabled
    public static string getVoiStatus(String OppId, String contactName){
        opportunity opp = [select Id,Applicant_2__r.personContactId,Applicant_1__r.personContactId, Applicant_1__c,Applicant_1__r.Phone,Applicant_2__r.Phone, Applicant_2__c, Applicant_1__r.Name, Applicant_2__r.Name from opportunity WHERE id =: OppId LIMIT 1];
        
        System.debug('contactNamecontactName'+contactName);
        System.debug('opp.Applicant_1__r.Name'+opp.Applicant_1__r.Name);
        
        string conid = '';
        if(contactName == opp.Applicant_1__r.Name){
            conid = opp.Applicant_1__r.personContactId;
        }
        if(contactName == opp.Applicant_2__r.Name){
            conid = opp.Applicant_2__r.personContactId;
        }
        
        
        string voi;
        for(VOi_status__c vois : [select Id,link_Expire_code__c, Name,Case_Status__c, contact__c, contact__r.name from VOi_status__c WHERE contact__r.id= : conid order by createddate DESC LIMIT 1]){
         	voi = vois.Case_Status__c;
        }
        
        if(voi != null){
            return voi;
        }
        else{
            return '';
        }
       
        
    }
    
    
}