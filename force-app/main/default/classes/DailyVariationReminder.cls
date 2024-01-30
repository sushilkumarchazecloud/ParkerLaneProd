global  class DailyVariationReminder implements Schedulable {
    global void execute(SchedulableContext SC){
        Map<integer, String> dayToSubjectMap = new Map<integer, String>{
            1 => 'Friendly reminder!',
                2 => 'Friendly reminder! {!Variation_Requested_By__c} has requested a variation to your approval and your action is required.',
                3 => 'Your urgent action is required! {!Variation_Requested_By__c} has requested a variation to your approval.',
                4 => 'Your urgent action is required! {!Variation_Requested_By__c} has requested a variation to your approval.',
                5 => 'Final reminder! {!Variation_Requested_By__c} has requested a variation to your approval.'
                };
                    Map<integer, String> dayToSubjectMap2 = new Map<integer, String>{
                        1 => 'Friendly reminder! {!Variation_Requested_By__c} has requested payment.',
                            2 => 'Friendly reminder! {!Variation_Requested_By__c} has requested payment and your action is required.',
                            3 => 'Your urgent action is required! {!Variation_Requested_By__c} has requested payment.',
                            4 => 'Your urgent action is required! {!Variation_Requested_By__c} has requested payment.',
                            5 => 'Final reminder! {!Variation_Requested_By__c} has requested payment.'
                            };
                                List<String> emailTemplateNames = New List<String>{'FundingOnHold','FundingNotAuthorised','RequestedByApplicantORReferrer(App2)',
                                    'VariationRequested','VariationRequested2','VariationRequested(EmailToReferrer)','FundingAuthorised(EmailToReferrer)','Funded(EmailToReferrer)'
                                    ,'Funded(EmailToCustomers)','RequestedByApplicantORReferrer','VariationNotAuthorised(EmailToReferrer)','VariationNotAuthorised(EmailToOtherApplicant)'};
                                        Map<String, Id> emailTempIdMap = New Map<String, Id>();
        for(EmailTemplate emailTemp: [SELECT id, Name  FROM EmailTemplate WHERE Name IN: emailTemplateNames]){
            emailTempIdMap.put(emailTemp.Name, emailTemp.Id);
        }
        OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address =: UtilityClass.adminEmail];
        List<Messaging.Email> emailList = new List<Messaging.Email>();
        list<Funding_Request__c> frRec = [select id,Opportunity__r.Applicant_1__c,BusinessDays__c,Opportunity__r.Contact_1__c,Opportunity__r.SyncedQuote.Product__r.Funding_Authorisation_Type__c, Requested_by__c,
                                          Opportunity__r.Referred_by_Company__c,Applicant_2_A2__c,Applicant_2_A2__r.PersonEmail,Applicant_1_A1__c,Applicant_1_A1__r.PersonEmail,
                                          Customer_Authorisation_Type__c,Date_Last_Request_Status_Changes__c,Customer_Authorisation_Status__c,Variation_Requested_By__r.name,Opportunity__c,
                                          Funding_On_Hold__c,Person_Requesting__r.id,Applicant_1_A1__r.PersonContactId,Applicant_2_A2__r.PersonContactId,Person_Requesting__c,Request_Status__c,Opportunity__r.FinServ__ReferredByContact__c,
                                          Opportunity__r.FinServ__ReferredByContact__r.Email from Funding_Request__c where Request_Status__c = 'Variation requested by customer' AND Opportunity__c != null];
        UpdateBusinessDays();
        set<id> oppId = new set<id>();
        for(Funding_Request__c fr : frRec){
            oppId.add(fr.Opportunity__c);
        }
        Map<id, list<id>> conMap = new Map<id, list<id>>();
        Map<id,string> textMap = new Map<id,string>();
        for(VOi_Status__c vs : [select id,Case_Status__c,Contact__c,Contact__r.name,Opportunity__c from VOi_Status__c where opportunity__c IN: oppId AND (Case_Status__c='Sent' OR Case_Status__c='Delivered')]){
            if(!conMap.containsKey(vs.Opportunity__c)){
                conMap.put(vs.Opportunity__c,new list<id>{vs.Contact__c});
                textMap.put(vs.Opportunity__c, vs.Contact__r.name + '<br/>'); 
            }
            else{
                conMap.get(vs.Opportunity__c).add(vs.Contact__c);
                string str = textMap.get(vs.Opportunity__c) + vs.Contact__r.name + '<br/>';
                textMap.put(vs.Opportunity__c, str);
            }
        }
        for(Funding_Request__c fr : [select id,Opportunity__r.Referred_by_Company__r.Name,Request_Type__c,Opportunity__r.Name,Date_Last_Request_Status_Changes__c,Applicant_2_A2__r.PersonEmail,Variation_Requested_By__r.name,Opportunity__c,Applicant_1_A1__c,Applicant_2_A2__c,Applicant_1_A1__r.personContactId,Applicant_2_A2__r.personContactId,Opportunity__r.Applicant_2__r.personContactId,Applicant_1_A1__r.Name,Applicant_2_A2__r.Name,Applicant_1_A1__r.Phone,Applicant_2_A2__r.Phone,Person_Requesting__r.name,Variation_Requested_By__c,Opportunity__r.FinServ__ReferredByContact__c,Opportunity__r.FinServ__ReferredByContact__r.Email,Opportunity__r.Applicant_1__r.personContactId,Opportunity__r.Applicant_2__r.Name,Opportunity__r.Applicant_1__r.Name,Opportunity__r.Applicant_1__c,Opportunity__r.Applicant_2__c,BusinessDays__c,Applicant_1_A1__r.PersonEmail from Funding_Request__c where Opportunity__c IN:conMap.keyset() AND Request_Status__c = 'Variation requested by customer' ]){
            Integer days = integer.valueOf(fr.BusinessDays__c);
            system.debug('days '+days);
            if(days < 6 && days != 0){
                system.debug('variationTT' +fr.Variation_Requested_By__c);
                system.debug('variationTT2' +fr.Variation_Requested_By__r.name);
                system.debug('variationTT3' +fr.Request_Type__c);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                //system.debug('con'+vs.Contact__c);
                system.debug('frcon'+fr.Applicant_1_A1__r.personContactId);
                if(conMap.get(fr.Opportunity__c).contains(fr.Applicant_1_A1__r.personContactId)){
                    system.debug('1st');
                    mail.setTemplateId(emailTempIdMap.get('VariationRequested'));
                    mail.setTargetObjectId(fr.Applicant_1_A1__r.personContactId);
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.setUseSignature(false);
                    mail.Setwhatid(fr.Id);
                    String sub = dayToSubjectMap.get(days);
                    sub = sub.replace('{!Variation_Requested_By__c}', fr.Variation_Requested_By__r.name);
                    //mail.setSubject(sub);
                    system.debug('subject'+sub);
                    
                    mail = Messaging.renderStoredEmailTemplate(emailTempIdMap.get('VariationRequested'), fr.Applicant_1_A1__r.personContactId, fr.Id);
                    mail.setSubject(sub);
                    system.debug('mail'+mail);
                    if(owea.size() > 0){
                        mail.setorgWideEmailAddressId(Owea.get(0).Id);
                    }
                    List<string> sendTo = new List<string>();
                    sendTo.add(fr.Applicant_1_A1__r.PersonEmail);
                    mail.setToAddresses(sendTo);                
                    emailList.add(mail);
                    if(fr.Variation_Requested_By__c == fr.Applicant_1_A1__c){
                        system.debug('istOf1');
                        string txt = 'Hi '+fr.Applicant_1_A1__r.Name+', Action required! We have received your variation request but you must first sign the updated credit proposal before we can process your request. Please refer to your email to review and approve. The Parker Lane team :)';
                        sendMessageForVariation(fr.Applicant_1_A1__r.Phone, txt);
                    }
                    else if(fr.Variation_Requested_By__c == fr.Applicant_2_A2__c){
                        system.debug('2ndOf1');
                        string txt = 'Hi '+fr.Applicant_1_A1__r.Name+', Action required! '+fr.Person_Requesting__r.name+' has requested a variation to your approved limit and we require your authorisation. Please refer to your email to review and approve. The Parker Lane team :)';
                        sendMessageForVariation(fr.Applicant_1_A1__r.Phone, txt);
                    }
                }
                 if(conMap.get(fr.Opportunity__c).contains(fr.Applicant_2_A2__r.personContactId)){
                    system.debug('2nd');
                    mail.setTemplateId(emailTempIdMap.get('VariationRequested2'));
                    mail.setTargetObjectId(fr.Applicant_2_A2__r.personContactId);
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.setUseSignature(false);
                    mail.Setwhatid(fr.Id);
                    String subject = dayToSubjectMap.get(days);
                    subject = subject.replace('{!Variation_Requested_By__c}', fr.Variation_Requested_By__r.name);
                    mail.setSubject(subject);
                    mail = Messaging.renderStoredEmailTemplate(emailTempIdMap.get('VariationRequested2'), fr.Applicant_2_A2__r.personContactId, fr.Id);
                    if(owea.size() > 0){
                        mail.setorgWideEmailAddressId(Owea.get(0).Id);
                    }
                    List<string> sendTo = new List<string>();
                    sendTo.add(fr.Applicant_2_A2__r.PersonEmail);
                    mail.setToAddresses(sendTo);                
                    emailList.add(mail);
                    if(fr.Variation_Requested_By__c == fr.Applicant_2_A2__c){
                        system.debug('2ndOf1');
                        string txt = 'Hi '+fr.Applicant_2_A2__r.Name+', Action required! We have received your variation request but you must first sign the updated credit proposal before we can process your request. Please refer to your email to review and approve. The Parker Lane team :)';
                        sendMessageForVariation(fr.Applicant_2_A2__r.Phone, txt);
                    }
                    else if(fr.Variation_Requested_By__c == fr.Applicant_1_A1__c){
                        system.debug('2ndOf2');
                        string txt = 'Hi '+fr.Applicant_2_A2__r.Name+', Action required! '+fr.Person_Requesting__r.name+' has requested a variation to your approved limit and we require your authorisation. Please refer to your email to review and approve. The Parker Lane team :)';
                        sendMessageForVariation(fr.Applicant_2_A2__r.Phone, txt);
                    }
                }
            }
            else if(days == 6){
                if(fr.Opportunity__r.Referred_by_Company__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateId(emailTempIdMap.get('VariationNotAuthorised(EmailToReferrer)'));
                    mail.setTargetObjectId(fr.Opportunity__r.FinServ__ReferredByContact__c);
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.setUseSignature(false);
                    mail.Setwhatid(fr.Id);
                    EmailTemplate emailTemp = [SELECT id,subject, Name,Markup  FROM EmailTemplate WHERE Name ='VariationNotAuthorised(EmailToReferrer)' limit 1];
                    String templateBody = emailTemp.Markup;
                    templateBody = templateBody.replace('[relatedTo.Opportunity__r.Referred_by_Company__r.Name]',fr.Opportunity__r.Referred_by_Company__r.Name);
                    templateBody = templateBody.replace('[applicant names]', textMap.get(fr.Opportunity__c));
                    templateBody = templateBody.replace('[relatedTo.Opportunity__r.Name]',fr.Opportunity__r.Name);
                    String subject = 'Funding delayed! We’ve been unable to reach your customers to complete the variation requested by '+fr.Variation_Requested_By__r.Name;
                    mail = Messaging.renderStoredEmailTemplate(emailTempIdMap.get('VariationNotAuthorised(EmailToReferrer)'), fr.Opportunity__r.FinServ__ReferredByContact__c, fr.Id);
                    mail.setSubject(subject);
                    mail.setHtmlBody(templateBody);
                    if(owea.size() > 0){
                        mail.setorgWideEmailAddressId(Owea.get(0).Id);
                    }
                    List<string> sendTo = new List<string>();
                    sendTo.add(fr.Opportunity__r.FinServ__ReferredByContact__r.Email);
                    mail.setToAddresses(sendTo);                
                    emailList.add(mail);
                }
                if(fr.Opportunity__r.Applicant_2__c != null && conMap.get(fr.Opportunity__c).size() == 1){
                    string conID = conMap.get(fr.Opportunity__c)[0];
                    String dynmaic1,dynmaic2,targetID;
                    if(conID == fr.Opportunity__r.Applicant_1__r.personContactId){
                        dynmaic1 = fr.Opportunity__r.Applicant_1__r.Name;
                        dynmaic2 = fr.Opportunity__r.Applicant_2__r.Name;
                        targetID = fr.Opportunity__r.Applicant_1__r.personContactId;
                    }
                    else if(conID == fr.Opportunity__r.Applicant_2__r.personContactId){
                        dynmaic1 = fr.Opportunity__r.Applicant_2__r.Name;
                        dynmaic2 = fr.Opportunity__r.Applicant_1__r.Name;
                        targetID = fr.Opportunity__r.Applicant_2__r.personContactId;
                    }
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateId(emailTempIdMap.get('VariationNotAuthorised(EmailToOtherApplicant)'));
                    mail.setTargetObjectId(targetID);
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.setUseSignature(false);
                    mail.Setwhatid(fr.Id);
                    EmailTemplate emailTemp = [SELECT id,subject, Name,Markup  FROM EmailTemplate WHERE Name ='VariationNotAuthorised(EmailToOtherApplicant)' limit 1];
                    String templateBody = emailTemp.Markup;
                    templateBody = templateBody.replace('[dynamic element 1]',dynmaic1);
                    templateBody = templateBody.replace('[dynamic element 2]', dynmaic2);
                    String subject = 'Funding delayed! We’ve been unable to reach '+dynmaic1 +'to authorise payment.';
                    mail = Messaging.renderStoredEmailTemplate(emailTempIdMap.get('VariationNotAuthorised(EmailToOtherApplicant)'), targetID, fr.Id);
                    mail.setSubject(subject);
                    mail.setHtmlBody(templateBody);
                    if(owea.size() > 0){
                        mail.setorgWideEmailAddressId(Owea.get(0).Id);
                    }
                    List<string> sendTo = new List<string>();
                    sendTo.add(fr.Opportunity__r.FinServ__ReferredByContact__r.Email);
                    mail.setToAddresses(sendTo);                
                    emailList.add(mail);
                }
            }
        }
        
        list<Funding_Request__c> frRec2 = [select id,Name,Opportunity__r.Name,Opportunity__r.Applicant_1__c,BusinessDays__c,Opportunity__r.Contact_1__c,Opportunity__r.SyncedQuote.Product__r.Funding_Authorisation_Type__c, Requested_by__c,Applicant_1_A1__r.Phone,Opportunity__r.Purpose__c,
                                           Opportunity__r.Referred_by_Company__c,Applicant_2_A2__c,Applicant_2_A2__r.PersonEmail,Applicant_1_A1__c,Applicant_1_A1__r.PersonEmail,Applicant_1_A1__r.Name,Opportunity__r.Referred_by_Company__r.Name,
                                           Customer_Authorisation_Type__c,Date_Last_Request_Status_Changes__c,Opportunity__r.Contact_2__c,Customer_Authorisation_Status__c,Variation_Requested_By__r.name,Opportunity__c,Applicant_2_A2__r.Name,Applicant_2_A2__r.Phone,Person_Requesting__r.Name,
                                           Funding_On_Hold__c,Person_Requesting__r.id,Applicant_1_A1__r.PersonContactId,Applicant_2_A2__r.PersonContactId,Person_Requesting__c,Request_Status__c,Opportunity__r.FinServ__ReferredByContact__c,
                                           Opportunity__r.FinServ__ReferredByContact__r.Email from Funding_Request__c where Opportunity__c != null];
        
        for(Funding_Request__c frR :frRec2){            
            Integer days = integer.valueOf(frR.BusinessDays__c);
            if((frR.Request_Status__c == 'Payment requested by supplier' || frR.Request_Status__c == 'Payment requested by supplier (pending contract)')
               || (frR.Request_Status__c == 'Payment requested by customer' || frR.Request_Status__c == 'Payment requested by customer (pending contract)') &&
               (frR.Requested_by__c == 'Customer' || frR.Requested_by__c == 'Supplier')){
                   if(days < 6 && days != 0){
                       list<String> sendList = new list<string>();
                       if(frR.Applicant_2_A2__c != null){
                           if(frR.Customer_Authorisation_Type__c == 'Either to sign'){
                               sendList.add(frR.Applicant_1_A1__r.PersonEmail);
                           }
                           else if(frR.Customer_Authorisation_Type__c == 'Both to sign'){
                               sendList.add(frR.Applicant_1_A1__r.PersonEmail);
                               sendList.add(frR.Applicant_2_A2__r.PersonEmail);
                           }
                       }
                       else if(frR.Applicant_2_A2__c == null){
                           sendList.add(frR.Applicant_1_A1__r.PersonEmail);
                       }
                       if(!sendList.isEmpty()){
                           for(String frval : sendList){
                               Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                               if(frval == frR.Applicant_1_A1__r.PersonEmail){
                                   mail = Messaging.renderStoredEmailTemplate(emailTempIdMap.get('RequestedByApplicantORReferrer'), frR.Opportunity__r.Contact_1__c, frR.Id);
                               }
                               if(frval == frR.Applicant_2_A2__r.PersonEmail){
                                   mail = Messaging.renderStoredEmailTemplate(emailTempIdMap.get('RequestedByApplicantORReferrer(App2)'), frR.Opportunity__r.Contact_2__c, frR.Id); 
                               }
                               String subject = dayToSubjectMap2.get(days);
                               subject = subject.replace('{!Variation_Requested_By__c}', frR.Person_Requesting__r.Name);
                               mail.setSubject(subject);
                               mail.setTreatTargetObjectAsRecipient(false);
                               mail.setUseSignature(false);
                               List<string> sendTo = new List<string>();
                               sendTo.add(frval);
                               mail.setToAddresses(sendTo);
                               if(owea.size() > 0){
                                   mail.setorgWideEmailAddressId(Owea.get(0).Id);
                               }  
                               system.debug('mail'+mail);
                               if(!sendTo.isEmpty()){
                                   emailList.add(mail);
                               }
                           } 
                       }                      
                       
                       if(frR.Requested_by__c == 'Supplier'){
                           if(frR.Applicant_2_A2__c != null){
                               if(frR.Customer_Authorisation_Type__c != null && frR.Customer_Authorisation_Type__c == 'Either to sign'){
                                   sendMessage(frR.Requested_by__c, frR.Applicant_1_A1__r.Phone, frR.Applicant_1_A1__r.Name, frR.Person_Requesting__r.Name, frR.Opportunity__r.Referred_by_Company__r.Name, frR.Opportunity__r.Purpose__c);
                               }
                               else if(frR.Customer_Authorisation_Type__c != null && frR.Customer_Authorisation_Type__c == 'Both to sign'){
                                   sendMessage(frR.Requested_by__c, frR.Applicant_1_A1__r.Phone, frR.Applicant_1_A1__r.Name, frR.Person_Requesting__r.Name, frR.Opportunity__r.Referred_by_Company__r.Name, frR.Opportunity__r.Purpose__c);
                                   sendMessage(frR.Requested_by__c, frR.Applicant_2_A2__r.Phone, frR.Applicant_2_A2__r.Name, frR.Person_Requesting__r.Name, frR.Opportunity__r.Referred_by_Company__r.Name, frR.Opportunity__r.Purpose__c);
                               }
                           }
                           else if(frR.Applicant_2_A2__c == null){
                               sendMessage(frR.Requested_by__c, frR.Applicant_1_A1__r.Phone, frR.Applicant_1_A1__r.Name, frR.Person_Requesting__r.Name, frR.Opportunity__r.Referred_by_Company__r.Name, frR.Opportunity__r.Purpose__c);
                           }
                       }                       
                       if(frR.Requested_by__c == 'Customer'){
                           if(frR.Applicant_2_A2__c != null){
                               if(frR.Person_Requesting__c != null){
                                   if(frR.Customer_Authorisation_Type__c != null && frR.Customer_Authorisation_Type__c == 'Both to sign' && frR.Person_Requesting__r.id == frR.Applicant_1_A1__r.PersonContactId){
                                       sendMessage(frR.Requested_by__c, frR.Applicant_2_A2__r.Phone, frR.Applicant_2_A2__r.Name, frR.Person_Requesting__r.Name, frR.Opportunity__r.Referred_by_Company__r.Name, frR.Opportunity__r.Purpose__c);
                                   }
                                   else if(frR.Customer_Authorisation_Type__c != null && frR.Customer_Authorisation_Type__c == 'Both to sign' && frR.Person_Requesting__r.id == frR.Applicant_2_A2__r.PersonContactId){
                                       sendMessage(frR.Requested_by__c, frR.Applicant_1_A1__r.Phone, frR.Applicant_1_A1__r.Name, frR.Person_Requesting__r.Name, frR.Opportunity__r.Referred_by_Company__r.Name, frR.Opportunity__r.Purpose__c);
                                   }
                               }
                           }
                       }
                   }                   
               }else if(days == 6){
                   mailOnCompletion(frRec2);
               }
        }
        if(!emailList.isEmpty()){
            Messaging.sendEmail(emailList);            
        }
    }
    public static void UpdateBusinessDays(){
        //Kunal Sir Code for Business Days logic Starts.
        list<Funding_Request__c> frList = [select id,Opportunity__r.Applicant_1__c,BusinessDays__c,Opportunity__r.Contact_1__c,Opportunity__r.SyncedQuote.Product__r.Funding_Authorisation_Type__c, Requested_by__c,
                                          Opportunity__r.Referred_by_Company__c,Applicant_2_A2__c,Applicant_2_A2__r.PersonEmail,Applicant_1_A1__c,Applicant_1_A1__r.PersonEmail,
                                          Customer_Authorisation_Type__c,Date_Last_Request_Status_Changes__c,Customer_Authorisation_Status__c,Variation_Requested_By__r.name,Opportunity__c,
                                          Funding_On_Hold__c,Person_Requesting__r.id,Applicant_1_A1__r.PersonContactId,Applicant_2_A2__r.PersonContactId,Person_Requesting__c,Request_Status__c,Opportunity__r.FinServ__ReferredByContact__c,
                                          Opportunity__r.FinServ__ReferredByContact__r.Email from Funding_Request__c where Opportunity__c != null];
        DateTime myDateTime = DateTime.now();
        String dayOfWeek = myDateTime.format('EEEE');
        List<Funding_Request__c> frListToUpdate = new List<Funding_Request__c>();
        for(Funding_Request__c fundReq : frList){
            Integer days = (fundReq.Date_Last_Request_Status_Changes__c.Date()).daysBetween(system.today());
            Datetime dt = fundReq.Date_Last_Request_Status_Changes__c;
            fundReq.BusinessDays__c = 0;
            system.debug('DaysBetween '+days);
            system.debug('last date '+dt);
            for(integer i=1; i<=days; i++){
                Datetime diff = dt + i;
                if(diff.format('EEEE') != 'Saturday' && diff.format('EEEE') != 'Sunday'){
                    fundReq.BusinessDays__c += 1;
                }
            }
            frListToUpdate.add(fundReq);
        }
        if(!frListToUpdate.isEmpty()){
            update frListToUpdate; 
        }
        // Kunal Sir Code End.
    }
    public static void sendMessage(String reqBy, String phone, String fName, String personReq, String RefCompany, String purpose){
        List<smagicinteract__smsMagic__c> smsObjectList = new List<smagicinteract__smsMagic__c> ();
        String templateText = '';
        if(reqBy == 'Supplier'){
            templateText = 'Hi '+fName+', Action required! '+personReq+ ' at '+RefCompany+ 
                ' has requested payment and we require your approval. Please refer to your email to review and approve. The Parker Lane team :)';
        }
        else if(reqBy == 'Customer'){
            templateText = 'Hi '+fName+', Action required! '+personReq+ 
                '  has requested that your ' +purpose+ ' loan is funded and we require your approval. Please refer to your email to review and approve. The Parker Lane team :)';
        }
        smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
        smsObject.smagicinteract__SenderId__c = 'parkerlane';
        smsObject.smagicinteract__PhoneNumber__c = phone;//contact.MobilePhone;
        smsObject.smagicinteract__Name__c = 'test';//contact.Name; // recordsname
        smsObject.smagicinteract__ObjectType__c = 'Funding Request'; // record type
        smsObject.smagicinteract__disableSMSOnTrigger__c = 0; // this field either be 0 or 1, if you specify the value as 1 then sms will not get send but entry of sms will get create under SMS History object
        smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
        smsObject.smagicinteract__SMSText__c = templateText;
        //smsObject.smagicinteract__Funding_Request__c = fundingId;
        smsObjectList.add(smsObject);
        system.debug('smsObjectList'+smsObjectList);
        Database.SaveResult[] results = Database.insert(smsObjectList, false);
        for(Database.SaveResult result : results) {
            if(result.isSuccess()) {
                //  System.debug('Successfully inserted Accounts : ' + result.getId());
            } else {
                for(Database.Error error : result.getErrors()) {
                    System.debug('Error Status : ' + error.getMessage() + ' : ' + 'Error Fields : ' + error.getFields());
                }
            }
        }
    }
    
    public static void sendMessageForVariation(String phone, String templateText){
        List<smagicinteract__smsMagic__c> smsObjectList = new List<smagicinteract__smsMagic__c> ();
        smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
        smsObject.smagicinteract__SenderId__c = 'parkerlane';
        smsObject.smagicinteract__PhoneNumber__c = phone;//contact.MobilePhone;
        smsObject.smagicinteract__Name__c = 'test';//contact.Name; // recordsname
        smsObject.smagicinteract__ObjectType__c = 'Funding Request'; // record type
        smsObject.smagicinteract__disableSMSOnTrigger__c = 0; // this field either be 0 or 1, if you specify the value as 1 then sms will not get send but entry of sms will get create under SMS History object
        smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
        smsObject.smagicinteract__SMSText__c = templateText;
        //smsObject.smagicinteract__Funding_Request__c = fundingId;
        smsObjectList.add(smsObject);
        Database.SaveResult[] results = Database.insert(smsObjectList, false);
        for(Database.SaveResult result : results) {
            if(result.isSuccess()) {
                //  System.debug('Successfully inserted Accounts : ' + result.getId());
            } else {
                for(Database.Error error : result.getErrors()) {
                    System.debug('Error Status : ' + error.getMessage() + ' : ' + 'Error Fields : ' + error.getFields());
                }
            }
        }
    }
    
    public static void mailOnCompletion(list<Funding_Request__c> FrDetail){
        OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address =:UtilityClass.adminEmail];
        List<Messaging.Email> emailList = new List<Messaging.Email>();
        list<String> conEmailList = new list<String>();
        set<id> companyList = new set<id>();
        list<contact> conList = new list<contact>();
        for(Funding_Request__c Fr : FrDetail){
            companyList.add(Fr.Opportunity__r.Referred_by_Company__c);
        }
        if(companyList != null){
            conList = [Select id, Email from contact where AccountId IN: companyList AND Admin__c = true];
        }            
        for(contact cont : conList){
            if(cont.Email != null){
                conEmailList.add(cont.Email);
            }
        }
        for(Funding_Request__c getFr : FrDetail){
            if((getFr.Customer_Authorisation_Status__c == 'Pending Applicant 1' || getFr.Customer_Authorisation_Status__c == 'Pending Applicant 2') && getFr.BusinessDays__c == 6){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                EmailTemplate et=[Select id, Subject, Body from EmailTemplate where Name = 'FundingNotAuthorised(EmailToApplicant)']; 
                mail.setTemplateId(et.id);
                mail.setTargetObjectId(getFr.Opportunity__r.Contact_1__c);
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setUseSignature(false);
                String appName = '';
                if(getFr.Customer_Authorisation_Status__c != null && getFr.Customer_Authorisation_Status__c == 'Pending Applicant 1'){
                    appName = getFr.Applicant_1_A1__r.Name;
                }
                else if(getFr.Customer_Authorisation_Status__c != null && getFr.Customer_Authorisation_Status__c == 'Pending Applicant 2'){
                    appName = getFr.Applicant_2_A2__r.Name;
                }
                mail = Messaging.renderStoredEmailTemplate(et.id, getFr.Opportunity__r.Contact_1__c, getFr.Id);
                String sub = 'Funding delayed! We’ve been unable to reach '+ appName + ' to authorise payment.';
                mail.setSubject(sub);
                mail.Setwhatid(getFr.Id);
                
                if(owea.size() > 0){
                    mail.setorgWideEmailAddressId(Owea.get(0).Id);
                }
                
                List<string> sendTo = new List<string>();
                if(getFr.Customer_Authorisation_Status__c != null && getFr.Customer_Authorisation_Status__c == 'Pending Applicant 1'){
                    sendTo.add(getFr.Applicant_2_A2__r.PersonEmail);
                }
                else if(getFr.Customer_Authorisation_Status__c != null && getFr.Customer_Authorisation_Status__c == 'Pending Applicant 2'){
                    sendTo.add(getFr.Applicant_1_A1__r.PersonEmail);
                }
                mail.setToAddresses(sendTo);                   
                emailList.add(mail);  
            }
            
            //Funding not authorised at the completion of reminder emails - email to referrer
            if((getFr.Request_Status__c == 'Payment requested by customer' || getFr.Request_Status__c == 'Payment requested by customer (pending contract)')
               || (getFr.Request_Status__c == 'Payment requested by supplier' || getFr.Request_Status__c == 'Payment requested by supplier (pending contract)') 
               && getFr.Opportunity__r.Referred_by_Company__c != null && getFr.BusinessDays__c == 6){
                   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                   EmailTemplate et=[Select id, Subject, Body from EmailTemplate where Name = 'FundingNotAuthorised']; 
                   mail.setTemplateId(et.id);
                   mail.setTargetObjectId(getFr.Opportunity__r.Contact_1__c);
                   String[] oppName = getFr.Opportunity__r.Name.split(',');
                   mail = Messaging.renderStoredEmailTemplate(et.Id, getFr.Opportunity__r.Contact_1__c, getFr.Id);
                   String sub = 'Funding delayed! We’ve been unable to reach '+ oppName + ' to authorise payment.';
                   mail.setSubject(sub);
                   mail.setTreatTargetObjectAsRecipient(false);
                   mail.setUseSignature(false);
                   mail.Setwhatid(getFr.Id);
                   
                   if(owea.size() > 0){
                       mail.setorgWideEmailAddressId(Owea.get(0).Id);
                   }
                   
                   List<string> sendTo = new List<string>();
                   sendTo.add(getFr.opportunity__r.FinServ__ReferredByContact__r.Email);
                   sendTo.addall(conEmailList);
                   mail.setToAddresses(sendTo);                    
                   emailList.add(mail);                    
               }
        }
        if(!emailList.isEmpty()){
            Messaging.sendEmail(emailList);
        }
    }    
}