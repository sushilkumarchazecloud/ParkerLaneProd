public without sharing class SMSController {
    
    public static void SendMessage(String objType, String senderId, String phoneNo){
        List<smagicinteract__smsMagic__c> smsObjectList = new List<smagicinteract__smsMagic__c> ();
        //String senderId = 'Parkerlane'; // Please replace the 'smsMagic' with your relevant sender ID.
        String templateText = 'test SMS by Sushil from code 2'; // you can fetch the template text by querying the record on smagicinteract__SMS_Template__c object 
        smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
        smsObject.smagicinteract__SenderId__c = senderId;
        smsObject.smagicinteract__PhoneNumber__c = phoneNo;//'61400247471';//contact.MobilePhone;
        smsObject.smagicinteract__Name__c = senderId;//contact.Name; // recordsname
        smsObject.smagicinteract__ObjectType__c = objType;//'Contact'; // record type
        smsObject.smagicinteract__disableSMSOnTrigger__c = 0; // this field either be 0 or 1, if you specify the value as 1 then sms will not get send but entry of sms will get create under SMS History object
        smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
        smsObject.smagicinteract__SMSText__c = templateText;
        smsObjectList.add(smsObject);
        Database.insert(smsObjectList, false);
    }
    
     
    public static void SendMessageWithOpportunityAndContact(String objType, String senderId, String phoneNo, String OppId, String conId, string random, string smsBodyExisting, string voiId){
        /*Added By Tazeem*/
        opportunity opp = [select Id,StageName,Applicant_1__c,Applicant_2__c,Applicant_1__r.personContactId,Applicant_2__r.personContactId, Loan_Purpose__c,Purpose__c from opportunity WHERE ID =: OppId LIMIT 1];
        contact con = [select Id,Name, FirstName from contact WHERE ID =: conId LIMIT 1];
        
        System.debug('voiIdvoiId'+voiId);
        VOI_Status__c  vStatus = [select id,SMS_URL__c,VOI_stage__c,Account__c,Contact__c,VOI_Type_For__c,Opportunity__c, Opportunity__r.Applicant_1__r.FirstName,Opportunity__r.Applicant_2__r.FirstName,Opportunity__r.Applicant_1__r.personcontactId,
                                  Opportunity__r.purpose__c,Opportunity__r.Applicant_1__r.Name,contact__r.VOI_type__c from VOI_Status__c where Id =: voiId LIMIT 1];
        
        /*Added By Tazeem*/
        List<smagicinteract__smsMagic__c> smsObjectList = new List<smagicinteract__smsMagic__c> ();
        String url = Label.baseUrl + 'DigitalSigning?oppId='+ oppId + '&conId=' +conId + '&r=' + random;
      
        String templateText = smsBodyWithConditions(vStatus, url);
        
        smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
        smsObject.smagicinteract__SenderId__c = senderId;
        smsObject.smagicinteract__PhoneNumber__c = phoneNo;
        smsObject.smagicinteract__Name__c = con.name;
        smsObject.smagicinteract__ObjectType__c = objType;
        smsObject.smagicinteract__disableSMSOnTrigger__c = 0; // this field either be 0 or 1, if you specify the value as 1 then sms will not get send but entry of sms will get create under SMS History object
        smsObject.smagicinteract__Opportunity__c = OppId;
        smsObject.smagicinteract__Contact__c = conId;
        smsObject.voi_linkExpire_code__c = random;
        if(voiId != ''){
            smsObject.VOI_Status__c = voiId;
        }
        smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
        smsObject.smagicinteract__SMSText__c = (String.isBlank(smsBodyExisting) && smsBodyExisting == '' ? templateText : smsBodyExisting);
        smsObjectList.add(smsObject);
        Database.SaveResult[] results = Database.insert(smsObjectList, false);
        // iterate over the list of returned results
        for(Database.SaveResult result : results) {
            if(result.isSuccess()) {
                System.debug('Successfully inserted Accounts : ' + result.getId());
            } else {
            // iterate over the failed ones
                for(Database.Error error : result.getErrors()) {
                    System.debug('Error Status : ' + error.getStatusCode() + ' : ' + 'Error Fields : ' + error.getFields());
                }
            }
        }
        
        System.debug('smsObjectListsmsObjectList'+smsObjectList[0].id);
        System.debug('oppOldStage'+opp.StageName);
        
        
        if(smsObjectList[0].id != null){
            if(conId == opp.Applicant_1__r.personContactId){
                opp.Applicant_1_eSign_Status__c = 'Sent';
            }        
            
            if(opp.Applicant_2__c != null){
                if(conId == opp.Applicant_2__r.personContactId){
                    opp.Applicant_2_eSign_Status__c = 'Sent';
                }
            }
            opp.StageName = 'Packs Out';    
            
        }
       
         update opp;
       System.debug('oppStageAfterUpdate'+opp.StageName);
    }
    
    public static void SendMessageToReferr(String objType, String senderId, String ConId, String AccId, string rndm, string smsBodyExisting, string VoiId){
        contact con = [select Id, FirstName,MobilePhone, Name from contact WHERE ID =: ConId LIMIT 1];
        Account acc = [select Id, name from Account WHERE ID=: AccId LIMIT 1];
        
        List<smagicinteract__smsMagic__c> smsObjectList = new List<smagicinteract__smsMagic__c> ();
        //String senderId = 'Parkerlane'; // Please replace the 'smsMagic' with your relevant sender ID.
        String url = Label.baseUrl + 'DIgitalSignReferrer?conId='+ ConId + '&id=' +AccId + '&r=' + rndm;
        String templateText = con.FirstName + ', '; 
        templateText += 'click the link to complete your Parker Lane accreditation for '+ acc.Name + '.\n';
        templateText += 'It takes about 3 minutes and you’ll need a copy of your driver’s license handy: ' + url + '\n\n';
        templateText += 'Regards, The Parker Lane Team. \n';
        templateText += '1300 13 17 11';
        smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
        smsObject.smagicinteract__SenderId__c = senderId;
        smsObject.smagicinteract__PhoneNumber__c = con.MobilePhone;//'61400247471';//contact.MobilePhone;
        smsObject.smagicinteract__Name__c = con.Name;//contact.Name; // recordsname
        smsObject.smagicinteract__ObjectType__c = objType;//'Contact'; // record type
        smsObject.smagicinteract__disableSMSOnTrigger__c = 0; // this field either be 0 or 1, if you specify the value as 1 then sms will not get send but entry of sms will get create under SMS History object
        smsObject.voi_linkExpire_code__c = rndm;
        if(voiId != ''){
            smsObject.VOI_Status__c = voiId;
        }
        smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
        smsObject.smagicinteract__SMSText__c = (String.isBlank(smsBodyExisting) && smsBodyExisting == '' ? templateText : smsBodyExisting);
        smsObjectList.add(smsObject);
        Database.insert(smsObjectList, false);
    }
    
    public static string smsBodyWithConditions(VOI_Status__c vStatus, string URL){
        
  //      VOI_Status__c  vStatus = [select id,Account__c,Contact__c,Opportunity__c, Opportunity__r.Applicant_1__r.FirstName,Opportunity__r.Applicant_2__r.FirstName,Opportunity__r.Applicant_1__r.personcontactId,
    //                              Opportunity__r.purpose__c,Opportunity__r.Applicant_1__r.Name,contact__r.VOI_type__c from VOI_Status__c where Id =: voiId LIMIT 1];
  
        string message = '';
        if(vStatus.VOI_stage__c == 'E-SIGN'){
            if(vStatus.Contact__c == vStatus.Opportunity__r.Applicant_1__r.personcontactId){
            message = 'Hi '+vStatus.Opportunity__r.Applicant_1__r.FirstName+','+ ' please e-Sign the new credit proposal to complete your '+vStatus.Opportunity__r.purpose__c+' application. Click here '+URL;
            }
            else{
            message = 'Hi '+vStatus.Opportunity__r.Applicant_2__r.FirstName+','+ ' please e-Sign the new credit proposal to complete your '+vStatus.Opportunity__r.purpose__c+' application with '+vStatus.Opportunity__r.Applicant_1__r.Name+'.'+' Click here '+URL;
            }
        }
        
        if(vStatus.VOI_stage__c == 'FULL' || vStatus.VOI_stage__c == 'VOI'){
            if(vStatus.Contact__c == vStatus.Opportunity__r.Applicant_1__r.personcontactId){
                message = 'Hi '+vStatus.Opportunity__r.Applicant_1__r.FirstName+','+ ' please verify your identity to complete your '+vStatus.Opportunity__r.purpose__c+' application. Have your driver’s license or photo ID handy then click here '+URL;
            }
            else{
                message = 'Hi '+vStatus.Opportunity__r.Applicant_2__r.FirstName+','+ ' please verify your identity to complete your '+vStatus.Opportunity__r.purpose__c+' application with '+vStatus.Opportunity__r.Applicant_1__r.Name+'.'+' Have your driver’s license or photo ID handy then click here '+URL;
            }
             
        }
        
        return message;
    }
    
    public static void sendApproveExpireMessage(String objType, String senderId,String ConName, String phoneNo, string templateText, String OppId, String conId){
            List<smagicinteract__smsMagic__c> smsObjectList = new List<smagicinteract__smsMagic__c> ();
            smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
            smsObject.smagicinteract__SenderId__c = senderId;
            smsObject.smagicinteract__Opportunity__c = OppId;
            smsObject.smagicinteract__Contact__c = conId;
            smsObject.smagicinteract__PhoneNumber__c = phoneNo;//'61400247471';//contact.MobilePhone;
            smsObject.smagicinteract__Name__c = ConName;//contact.Name; // recordsname
            smsObject.smagicinteract__ObjectType__c = objType;//'Contact'; // record type
            smsObject.smagicinteract__disableSMSOnTrigger__c = 0; // this field either be 0 or 1, if you specify the value as 1 then sms will not get send but entry of sms will get create under SMS History object
            smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
            smsObject.smagicinteract__SMSText__c = templateText;
            smsObjectList.add(smsObject);
            Database.SaveResult[] results = Database.insert(smsObjectList, false);
            // iterate over the list of returned results
            for(Database.SaveResult result : results) {
                if(result.isSuccess()) {
                    //  System.debug('Successfully inserted Accounts : ' + result.getId());
                } else {
                    // iterate over the failed ones
                    for(Database.Error error : result.getErrors()) {
                        System.debug('Error Status : ' + error.getMessage() + ' : ' + 'Error Fields : ' + error.getFields());
                    }
                }
            }
    }
    
    public static void SendMessageForVOI(String objType, String senderId, String phoneNo, string body){
         List<smagicinteract__smsMagic__c> smsObjectList = new List<smagicinteract__smsMagic__c> ();
         //String senderId = 'Parkerlane'; // Please replace the 'smsMagic' with your relevant sender ID.
        //String templateText = 'test SMS by Sushil from code 2'; // you can fetch the template text by querying the record on smagicinteract__SMS_Template__c object 
        smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
        smsObject.smagicinteract__SenderId__c = 'Parkerlane';
        smsObject.smagicinteract__PhoneNumber__c = phoneNo;//'61400247471';//contact.MobilePhone;
        smsObject.smagicinteract__Name__c = senderId;//contact.Name; // recordsname
        smsObject.smagicinteract__ObjectType__c = objType;//'Contact'; // record type
        smsObject.smagicinteract__disableSMSOnTrigger__c = 0; // this field either be 0 or 1, if you specify the value as 1 then sms will not get send but entry of sms will get create under SMS History object
        smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
        smsObject.smagicinteract__SMSText__c = body;
        smsObjectList.add(smsObject);
        Database.SaveResult[] results = Database.insert(smsObjectList, false);
            for(Database.SaveResult result : results) {
                if(result.isSuccess()) {
                    //  System.debug('Successfully inserted Accounts : ' + result.getId());
                }
                else{
                    for(Database.Error e : result.getErrors()) {
                        UtilityClass.createException('', 'SMSCOntroller', 'SendMessageForVOI', e.getMessage(), '', ''+'',
                                                     '', ''+'');                     
                    }
                }
            } 
    }  
}