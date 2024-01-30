public class FundingRequestTriggerhandler {
    public void LastRequestStatusUpdate(List<Funding_Request__c> newRequest,Map<ID, Funding_Request__c> oldReqMap){
        for(Funding_Request__c fr : newRequest){
            if(oldReqMap == Null){
                if(fr.Request_Status__c != Null){
                    fr.Date_Last_Request_Status_Changes__c = system.now();
                    fr.BusinessDays__c = 0;
                }
            }
            else if(oldReqMap != null){
                if(fr.Request_Status__c != Null && fr.Request_Status__c != oldReqMap.get(fr.Id).Request_Status__c){
                    fr.Date_Last_Request_Status_Changes__c = system.now();
                    fr.BusinessDays__c = 0;
                }
            }
        }  
    }
    public void AfterInsertOrUpdate(List<Funding_Request__c> newRequest,Map<ID, Funding_Request__c> oldReqMap){
        List<Funding_Request__c> reqListtoUpdate = new List<Funding_Request__c>();
        List<Task> tklist = new List<Task>();
        for(Funding_Request__c fr : newRequest){
            if(oldReqMap == Null){
                SendMailOnInsert(newRequest);
            }else if(oldReqMap != null){
                if(!fr.Funding_On_Hold__c && oldReqMap.get(fr.Id).Funding_On_Hold__c && fr.Funding_Hold_Expiry_Date__c == Date.today() && fr.Opportunity__c != null){
                    Task tk = new Task();
                    tk.Subject = 'funding hold expires today. Reminders commence tomorrow. Confirm it is OK to commence reminders otherwise update on hold expiry date.';
                    tk.WhatId = fr.Opportunity__c;
                    if(fr.Opportunity__r.Customer_Support_Person__c != null){
                        tk.OwnerId = fr.Opportunity__r.Customer_Support_Person__c;  
                    }
                    tklist.add(tk); 
                }
                SendMailOnUpdate(newRequest,oldReqMap);
            }
        } 
        if(!tklist.isEmpty()){
            insert tklist;
        }
    }
    
    public void SendMailOnInsert(List<Funding_Request__c> newRequest){
        set<id> frIds = new set<id>();
        for(Funding_Request__c fr : newRequest){
            frIds.add(fr.Id);
        }
        List<String> emailTemplateNames = New List<String>{'RequestedByApplicant(EmailToReferrer)','RequestedByApplicant(EmailToApplicant)','RequestedByApplicantORReferrer','RequestedByApplicantORReferrer(App2)','VariationRequested(EmailToReferrer)'};
            Map<String, Id> emailTempIdMap = New Map<String, Id>();
        for(EmailTemplate emailTemp: [SELECT id, Name  FROM EmailTemplate WHERE Name IN: emailTemplateNames]){
            emailTempIdMap.put(emailTemp.Name, emailTemp.Id);
        }       
        
        OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address =: UtilityClass.adminEmail];
        List<Messaging.Email> emailList = new List<Messaging.Email>();
        list<String> conEmailList = new list<String>();
        list<contact> conList = new list<contact>();
        if(!frIds.isEmpty()){
            list<Funding_Request__c> frRec = [select id,Opportunity__r.Applicant_1__c,Opportunity__r.SyncedQuote.Product__r.Funding_Authorisation_Type__c, Requested_by__c,
                                              Opportunity__r.Referred_by_Company__c,Applicant_2_A2__c,Applicant_2_A2__r.PersonEmail,Applicant_1_A1__c,Applicant_1_A1__r.PersonEmail,Opportunity__r.Name,Opportunity__r.Referred_by_Company__r.Name,Applicant_1_A1__r.Phone,Applicant_2_A2__r.Phone,
                                              Customer_Authorisation_Type__c,Date_Last_Request_Status_Changes__c,Customer_Authorisation_Status__c,Applicant_1_A1__r.PersonContactId,Applicant_2_A2__r.PersonContactId,Person_Requesting__r.Name,Opportunity__r.Purpose__c,Applicant_1_A1__r.Name,Applicant_2_A2__r.Name,
                                              Funding_On_Hold__c,Person_Requesting__c,Person_Requesting__r.id,Opportunity__r.Contact_1__c,Opportunity__r.Contact_2__c,Request_Status__c,Opportunity__r.FinServ__ReferredByContact__c,Opportunity__r.FinServ__ReferredByContact__r.Email from Funding_Request__c where id IN: frIds];
            
            List<ContentDocumentLink> cntList = new List<ContentDocumentLink>();
            if(frRec != null && frRec[0].Opportunity__c != null){
                cntList = [SELECT ContentDocument.LatestPublishedVersionId, LinkedEntityId, ContentDocumentId
                           FROM ContentDocumentLink WHERE LinkedEntityId =: frRec[0].Opportunity__c];
            }
            Set<Id> cntVersionIds = new Set<Id>();
            List<ContentVersion> cvList = new List<ContentVersion>();
            if(!cntList.isEmpty()){
                for(ContentDocumentLink cnt: cntList){            
                    cntVersionIds.add(cnt.ContentDocument.LatestPublishedVersionId );
                }
                if(!cntVersionIds.isEmpty()){
                    cvList  = [SELECT Id,related__c,VersionData, Category__c,FileType,Current_in_use__c, Title, FileExtension, Description, ContentModifiedDate, CreatedDate, ContentSize, ContentDocumentId 
                               FROM ContentVersion WHERE Id IN :cntVersionIds AND Category__c = 'Purchase Invoice' AND Current_in_use__c = true];
                }
            }
            List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
            for(ContentVersion cv : cvList){
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(cv.Title+'.'+cv.FileType);
                efa.setContentType('Application/'+cv.FileType);
                efa.setBody(cv.VersionData);
                efaList.add(efa);
            }
            
            if(frRec[0].Opportunity__r.Referred_by_Company__c != null){
                conList = [Select id, Email from contact where AccountId =: frRec[0].Opportunity__r.Referred_by_Company__c AND Admin__c = true];
            }            
            for(contact cont : conList){
                if(cont.Email != null){
                    conEmailList.add(cont.Email);
                }
            }
            for(Funding_Request__c getFr : frRec){
                //Requested by Applicant - Email to referrer
                if(getFr.Requested_by__c == 'Customer' && getFr.Opportunity__r.Referred_by_Company__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateId(emailTempIdMap.get('RequestedByApplicant(EmailToReferrer)'));
                    mail.setTargetObjectId(getFr.Opportunity__r.Contact_1__c);
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.setUseSignature(false);
                    mail.Setwhatid(getFr.Id);
                    if(efaList != Null){
                        mail.setFileAttachments(efaList);
                    }
                    
                    if(owea.size() > 0){
                        mail.setorgWideEmailAddressId(Owea.get(0).Id);
                    }
                    
                    List<string> sendTo = new List<string>();
                    sendTo.add(getFr.Opportunity__r.FinServ__ReferredByContact__r.Email);
                    sendTo.addall(conEmailList);
                    mail.setToAddresses(sendTo);                   
                    emailList.add(mail);
                }
                //Requested by Applicant - Email to other Applicant (either to sign)
                if((getFr.Request_Status__c == 'Payment requested by customer' || getFr.Request_Status__c == 'Payment requested by customer (pending contract)') 
                   && getFr.Customer_Authorisation_Type__c == 'Either to sign' && getFr.Applicant_2_A2__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateId(emailTempIdMap.get('RequestedByApplicant(EmailToApplicant)'));
                    mail.setTargetObjectId(getFr.Opportunity__r.Contact_1__c);
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.setUseSignature(false);
                    mail.Setwhatid(getFr.Id);
                    if(efaList != Null){
                        mail.setFileAttachments(efaList);
                    }
                    
                    if(owea.size() > 0){
                        mail.setorgWideEmailAddressId(Owea.get(0).Id);
                    }                    
                    List<string> sendTo = new List<string>();
                    if(getFr.Person_Requesting__c == getFr.Applicant_1_A1__r.PersonContactId){
                       sendTo.add(getFr.Applicant_2_A2__r.PersonEmail);
                    }
                    else if(getFr.Person_Requesting__c == getFr.Applicant_2_A2__r.PersonContactId){
                       sendTo.add(getFr.Applicant_1_A1__r.PersonEmail);
                    }
                    mail.setToAddresses(sendTo);                
                    emailList.add(mail);
                }
                
                //Variation Requested - email to Referrer
                if(getFr.Request_Status__c == 'Variation requested by customer' && getFr.Opportunity__r.Referred_by_Company__c != null){
                       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                       mail.setTemplateId(emailTempIdMap.get('VariationRequested(EmailToReferrer)'));
                       mail.setTargetObjectId(getFr.Opportunity__r.Contact_1__c);
                       mail.setTreatTargetObjectAsRecipient(false);    
                       String[] oppName = getFr.Opportunity__r.Name.split(',');
                       mail = Messaging.renderStoredEmailTemplate(emailTempIdMap.get('VariationRequested(EmailToReferrer)'), getFr.Opportunity__r.Contact_1__c, getFr.Id);
                       String sub = 'Important! Variation to approved limit requested by '+ oppName[0];
                       mail.setSubject(sub); 
                       mail.setUseSignature(false);
                       mail.Setwhatid(getFr.Id);
                       
                       if(owea.size() > 0){
                           mail.setorgWideEmailAddressId(Owea.get(0).Id);
                       }
                       
                       List<string> sendTo = new List<string>();
                       sendTo.add(getFr.opportunity__r.FinServ__ReferredByContact__r.Email);
                       sendTo.addall(conEmailList);
                       if(sendTo.size() > 0){
                           mail.setToAddresses(sendTo);                  
                           emailList.add(mail);
                       }
                   }
                
                //Requested by Applicant OR Referrer (or after variation request is approved or after hold is expired) - Email & SMS to Applicant(s) 
                if((getFr.Request_Status__c == 'Payment requested by supplier' || getFr.Request_Status__c == 'Payment requested by supplier (pending contract)')
                   || (getFr.Request_Status__c == 'Payment requested by customer' || getFr.Request_Status__c == 'Payment requested by customer (pending contract)') &&
                   (getFr.Requested_by__c == 'Customer' || getFr.Requested_by__c == 'Supplier')){
                       list<String> sendList = new list<string>();
                       if(getFr.Applicant_2_A2__c != null){
                           if(getFr.Customer_Authorisation_Type__c == 'Either to sign' || getFr.Customer_Authorisation_Type__c == null){
                               sendList.add(getFr.Applicant_1_A1__r.PersonEmail);
                           }
                           else if(getFr.Customer_Authorisation_Type__c == 'Both to sign'){
                               sendList.add(getFr.Applicant_1_A1__r.PersonEmail);
                               sendList.add(getFr.Applicant_2_A2__r.PersonEmail);
                           }
                       }
                       else if(getFr.Applicant_2_A2__c == null){
                           sendList.add(getFr.Applicant_1_A1__r.PersonEmail);
                       }
                       if(!sendList.isEmpty()){
                           for(String frval : sendList){
                               Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                               if(frval == getFr.Applicant_1_A1__r.PersonEmail){
                                   mail = Messaging.renderStoredEmailTemplate(emailTempIdMap.get('RequestedByApplicantORReferrer'), getFr.Opportunity__r.Contact_1__c, getFr.Id);
                               }
                               if(frval == getFr.Applicant_2_A2__r.PersonEmail){
                                   mail = Messaging.renderStoredEmailTemplate(emailTempIdMap.get('RequestedByApplicantORReferrer(App2)'), getFr.Opportunity__r.Contact_2__c, getFr.Id); 
                               }
                               String dynamicSubject = '';
                               if(getFr.Requested_by__c == 'Customer'){
                                   dynamicSubject = 'Action required! '+ getFr.Person_Requesting__r.Name +' has requested payment authorisation.';
                               }
                               if(getFr.Requested_by__c == 'Supplier'){
                                   dynamicSubject = 'Action required! '+ getFr.Opportunity__r.Referred_by_Company__r.Name +' has requested payment authorisation.';
                               }
                               mail.setSubject(dynamicSubject);
                               mail.setTreatTargetObjectAsRecipient(false);
                               mail.setUseSignature(false);
                               List<string> sendTo = new List<string>();
                               sendTo.add(frval);
                               mail.setToAddresses(sendTo);
                               if(owea.size() > 0){
                                   mail.setorgWideEmailAddressId(Owea.get(0).Id);
                               }  
                               if(!sendTo.isEmpty()){
                               emailList.add(mail);
                               }
                           } 
                       }
                       if(getFr.Requested_by__c == 'Supplier'){
                           if(getFr.Applicant_2_A2__c != null){
                               if(getFr.Customer_Authorisation_Type__c == 'Either to sign' || getFr.Customer_Authorisation_Type__c == null){
                                   sendMessage(getFr.Requested_by__c, getFr.Applicant_1_A1__r.Phone, getFr.Applicant_1_A1__r.Name, getFr.Person_Requesting__r.Name, getFr.Opportunity__r.Referred_by_Company__r.Name, getFr.Opportunity__r.Purpose__c);
                               }
                               else if(getFr.Customer_Authorisation_Type__c == 'Both to sign'){
                                   sendMessage(getFr.Requested_by__c, getFr.Applicant_1_A1__r.Phone, getFr.Applicant_1_A1__r.Name, getFr.Person_Requesting__r.Name, getFr.Opportunity__r.Referred_by_Company__r.Name, getFr.Opportunity__r.Purpose__c);
                                   sendMessage(getFr.Requested_by__c, getFr.Applicant_2_A2__r.Phone, getFr.Applicant_2_A2__r.Name, getFr.Person_Requesting__r.Name, getFr.Opportunity__r.Referred_by_Company__r.Name, getFr.Opportunity__r.Purpose__c);
                               }
                           }
                           else if(getFr.Applicant_2_A2__c == null){
                               sendMessage(getFr.Requested_by__c, getFr.Applicant_1_A1__r.Phone, getFr.Applicant_1_A1__r.Name, getFr.Person_Requesting__r.Name, getFr.Opportunity__r.Referred_by_Company__r.Name, getFr.Opportunity__r.Purpose__c);
                           }
                       }                       
                       if(getFr.Requested_by__c == 'Customer'){
                           if(getFr.Applicant_2_A2__c != null){
                               if(getFr.Person_Requesting__c != null){
                                   if(getFr.Customer_Authorisation_Type__c == 'Both to sign' && getFr.Person_Requesting__r.id == getFr.Applicant_1_A1__r.PersonContactId){
                                       sendMessage(getFr.Requested_by__c, getFr.Applicant_2_A2__r.Phone, getFr.Applicant_2_A2__r.Name, getFr.Person_Requesting__r.Name, getFr.Opportunity__r.Referred_by_Company__r.Name, getFr.Opportunity__r.Purpose__c);
                                   }
                                   else if(getFr.Customer_Authorisation_Type__c == 'Both to sign' && getFr.Person_Requesting__r.id == getFr.Applicant_2_A2__r.PersonContactId){
                                       sendMessage(getFr.Requested_by__c, getFr.Applicant_1_A1__r.Phone, getFr.Applicant_1_A1__r.Name, getFr.Person_Requesting__r.Name, getFr.Opportunity__r.Referred_by_Company__r.Name, getFr.Opportunity__r.Purpose__c);
                                   }
                               }
                           }
                       }                
                   }
            }
            if(!emailList.isEmpty()){
                if(!Test.isRunningTest()){
                    Messaging.sendEmail(emailList);
                } 
            } 
        }        
    }
    
    public void SendMailOnUpdate(List<Funding_Request__c> newRequest,Map<ID, Funding_Request__c> oldReqMap){
        set<id> frIds = new set<id>();        
        for(Funding_Request__c fr : newRequest){
            frIds.add(fr.Id);
        }
        List<String> emailTemplateNames = New List<String>{'FundingNotAuthorised','FundingOnHold',
            'VariationRequested','VariationRequested(EmailToReferrer)','FundingAuthorised(EmailToReferrer)','Funded(EmailToReferrer)'
            ,'Funded(EmailToCustomers)','RequestedByApplicantORReferrer','RequestedByApplicantORReferrer(App2)'};
                Map<String, Id> emailTempIdMap = New Map<String, Id>();
        for(EmailTemplate emailTemp: [SELECT id, Name  FROM EmailTemplate WHERE Name IN: emailTemplateNames]){
            emailTempIdMap.put(emailTemp.Name, emailTemp.Id);
        }
        OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address =: UtilityClass.adminEmail];
        List<Messaging.Email> emailList = new List<Messaging.Email>();
        list<String> conEmailList = new list<String>();
        list<contact> conList = new list<contact>();
        if(!frIds.isEmpty()){
            list<Funding_Request__c> frRec = [select id,Opportunity__r.Applicant_1__c,Opportunity__r.SyncedQuote.Product__r.Funding_Authorisation_Type__c, Requested_by__c,Request_Type__c,
                                              Opportunity__r.Referred_by_Company__c,Applicant_2_A2__c,Applicant_2_A2__r.PersonEmail,Applicant_1_A1__c,Applicant_1_A1__r.PersonEmail,Opportunity__r.Name,Opportunity__r.Referred_by_Company__r.Name,Applicant_1_A1__r.Phone,Applicant_2_A2__r.Phone,
                                              Customer_Authorisation_Type__c,Date_Last_Request_Status_Changes__c,Customer_Authorisation_Status__c,Applicant_1_A1__r.PersonContactId,Applicant_2_A2__r.PersonContactId,Person_Requesting__r.Name,Opportunity__r.Purpose__c,Applicant_1_A1__r.Name,Applicant_2_A2__r.Name,
                                              Funding_On_Hold__c,Person_Requesting__c,Person_Requesting__r.id,Opportunity__r.Contact_1__c,Opportunity__r.Contact_2__c,Request_Status__c,Opportunity__r.FinServ__ReferredByContact__c,Opportunity__r.FinServ__ReferredByContact__r.Email from Funding_Request__c where id IN: frIds];
            Datetime newDate,oldDate;
            Date tDay;
            if(frRec[0].Date_Last_Request_Status_Changes__c != null){
                newDate = frRec[0].Date_Last_Request_Status_Changes__c;
                tDay = (frRec[0].Date_Last_Request_Status_Changes__c).date();
            }
            if(oldReqMap.get(frRec[0].Id).Date_Last_Request_Status_Changes__c != null){
                oldDate = oldReqMap.get(frRec[0].Id).Date_Last_Request_Status_Changes__c;
            }
            if(frRec[0].Opportunity__r.Referred_by_Company__c != null){
                conList = [Select id, Email from contact where AccountId =: frRec[0].Opportunity__r.Referred_by_Company__c AND Admin__c = true];
            }            
            for(contact cont : conList){
                if(cont.Email != null){
                    conEmailList.add(cont.Email);
                }
            }
            for(Funding_Request__c getFr : frRec){
                //Funding placed on hold - email to referrer
                system.debug('reqtYPE'+getFr.Request_Type__c);
                system.debug('hold'+getFr.Funding_On_Hold__c);
                if(getFr.Funding_On_Hold__c == true && oldReqMap.get(getFr.Id).Funding_On_Hold__c == false && getFr.Opportunity__r.Referred_by_Company__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateId(emailTempIdMap.get('FundingOnHold'));
                    mail.setTargetObjectId(getFr.Opportunity__r.Contact_1__c);
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.setUseSignature(false);
                    mail.Setwhatid(getFr.Id);
                    
                    if(owea.size() > 0){
                        mail.setorgWideEmailAddressId(Owea.get(0).Id);
                    }
                    
                    List<string> sendTo = new List<string>();
                    sendTo.add(getFr.opportunity__r.FinServ__ReferredByContact__r.Email);
                    sendTo.addall(conEmailList);
                    if(sendTo.size() > 0){
                        mail.setToAddresses(sendTo);                  
                        emailList.add(mail);
                    }
                }
                //Variation Requested - email to Referrer
                if(newDate != null && oldDate != null && tDay == date.today() && oldDate != newDate &&
                   getFr.Request_Status__c == 'Variation requested by customer'
                   && getFr.Opportunity__r.Referred_by_Company__c != null){
                       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                       mail.setTemplateId(emailTempIdMap.get('VariationRequested(EmailToReferrer)'));
                       mail.setTargetObjectId(getFr.Opportunity__r.Contact_1__c);
                       mail.setTreatTargetObjectAsRecipient(false);    
                       String[] oppName = getFr.Opportunity__r.Name.split(',');
                       mail = Messaging.renderStoredEmailTemplate(emailTempIdMap.get('VariationRequested(EmailToReferrer)'), getFr.Opportunity__r.Contact_1__c, getFr.Id);
                       String sub = 'Important! Variation to approved limit requested by '+ oppName[0];
                       mail.setSubject(sub); 
                       mail.setUseSignature(false);
                       mail.Setwhatid(getFr.Id);
                       
                       if(owea.size() > 0){
                           mail.setorgWideEmailAddressId(Owea.get(0).Id);
                       }
                       
                       List<string> sendTo = new List<string>();
                       sendTo.add(getFr.opportunity__r.FinServ__ReferredByContact__r.Email);
                       sendTo.addall(conEmailList);
                       if(sendTo.size() > 0){
                           mail.setToAddresses(sendTo);                  
                           emailList.add(mail);
                       }
                   }
                //Funding Authorised - email to Referrer
                if(newDate != null && oldDate != null && tDay == date.today() && oldDate != newDate &&
                   (getFr.Request_Status__c == 'Payment authorised by customer' || getFr.Request_Status__c == 'Funding handover call completed') 
                   && getFr.Opportunity__r.Referred_by_Company__c != null){
                       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                       mail.setTemplateId(emailTempIdMap.get('FundingAuthorised(EmailToReferrer)'));
                       mail.setTargetObjectId(getFr.Opportunity__r.Contact_1__c);
                       mail.setTreatTargetObjectAsRecipient(false);
                       mail.setUseSignature(false);
                       mail.Setwhatid(getFr.Id);
                       
                       if(owea.size() > 0){
                           mail.setorgWideEmailAddressId(Owea.get(0).Id);
                       }
                       
                       List<string> sendTo = new List<string>();
                       sendTo.add(getFr.opportunity__r.FinServ__ReferredByContact__r.Email);
                       sendTo.addall(conEmailList);
                       if(sendTo.size() > 0){
                           mail.setToAddresses(sendTo);                  
                           emailList.add(mail);
                       }
                   }
                //Funded - email to Referrer
                if(newDate != null && oldDate != null && tDay == date.today() && oldDate != newDate &&
                   getFr.Request_Status__c == 'Payment funded' && getFr.Opportunity__r.Referred_by_Company__c != null){
                       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                       mail.setTemplateId(emailTempIdMap.get('Funded(EmailToReferrer)'));
                       mail.setTargetObjectId(getFr.Opportunity__r.Contact_1__c);
                       mail.setTreatTargetObjectAsRecipient(false);
                       mail.setUseSignature(false);
                       mail.Setwhatid(getFr.Id);
                       
                       if(owea.size() > 0){
                           mail.setorgWideEmailAddressId(Owea.get(0).Id);
                       }
                       
                       List<string> sendTo = new List<string>();
                       sendTo.add(getFr.opportunity__r.FinServ__ReferredByContact__r.Email);
                       sendTo.addall(conEmailList);
                       if(sendTo.size() > 0){
                           mail.setToAddresses(sendTo);                  
                           emailList.add(mail);
                       }
                   }
                //Funded - email to Customer(s)
                if(newDate != null && oldDate != null && tDay == date.today() && oldDate != newDate &&
                   getFr.Request_Status__c == 'Payment funded'){
                       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                       mail.setTemplateId(emailTempIdMap.get('Funded(EmailToCustomers)'));
                       mail.setTargetObjectId(getFr.Opportunity__r.Contact_1__c);
                       mail.setTreatTargetObjectAsRecipient(false);
                       mail.setUseSignature(false);
                       mail.Setwhatid(getFr.Id);
                       
                       if(owea.size() > 0){
                           mail.setorgWideEmailAddressId(Owea.get(0).Id);
                       }
                       
                       List<string> sendTo = new List<string>();
                       sendTo.add(getFr.Applicant_1_A1__r.PersonEmail);
                       if(getFr.Applicant_2_A2__c != null){
                           sendTo.add(getFr.Applicant_2_A2__r.PersonEmail);
                       }
                       if(sendTo.size() > 0){
                           mail.setToAddresses(sendTo);                  
                           emailList.add(mail);
                       }
                   }
                //Requested by Applicant OR Referrer (or after variation request is approved or after hold is expired) - Email & SMS to Applicant(s) 
                List<String> sendList = new List<string>();                
                /*system.debug('getFr.Request_Status__c'+getFr.Request_Status__c);
                system.debug('oldReqMap.get(getFr.Id).Request_Status__c'+oldReqMap.get(getFr.Id).Request_Status__c);
                system.debug('getFr.Requested_by__c'+getFr.Requested_by__c);*/
                if(newDate != null && oldDate != null && tDay == date.today() && oldDate != newDate &&
                   (((getFr.Request_Status__c == 'Payment requested by supplier' || getFr.Request_Status__c == 'Payment requested by supplier (pending contract)') && oldReqMap.get(getFr.Id).Request_Status__c == 'Variation requested by customer')
                    || ((getFr.Request_Status__c == 'Payment requested by customer' || getFr.Request_Status__c == 'Payment requested by customer (pending contract)') && oldReqMap.get(getFr.Id).Request_Status__c == 'Variation requested by customer') 
                    || (getFr.Funding_On_Hold__c == false && oldReqMap.get(getFr.Id).Funding_On_Hold__c == true))
                   && (getFr.Requested_by__c == 'Customer' || getFr.Requested_by__c == 'Supplier')){
                       system.debug('>>>>>>>>>>>>>Enter');
                       if(getFr.Applicant_2_A2__c != null){
                           if(getFr.Customer_Authorisation_Type__c == 'Either to sign' || getFr.Customer_Authorisation_Type__c == null){
                               sendList.add(getFr.Applicant_1_A1__r.PersonEmail);
                           }
                           else if(getFr.Customer_Authorisation_Type__c == 'Both to sign'){
                               sendList.add(getFr.Applicant_1_A1__r.PersonEmail);
                               sendList.add(getFr.Applicant_2_A2__r.PersonEmail);
                           }
                       }
                       else if(getFr.Applicant_2_A2__c == null){
                           sendList.add(getFr.Applicant_1_A1__r.PersonEmail);
                       }
                       if(!sendList.isEmpty()){
                           for(String frval : sendList){
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                               if(frval == getFr.Applicant_1_A1__r.PersonEmail){
                                   mail = Messaging.renderStoredEmailTemplate(emailTempIdMap.get('RequestedByApplicantORReferrer'), getFr.Opportunity__r.Contact_1__c, getFr.Id);
                               }
                               if(frval == getFr.Applicant_2_A2__r.PersonEmail){
                                   mail = Messaging.renderStoredEmailTemplate(emailTempIdMap.get('RequestedByApplicantORReferrer(App2)'), getFr.Opportunity__r.Contact_2__c, getFr.Id); 
                               }
                               String dynamicSubject = '';
                               if(getFr.Requested_by__c == 'Customer'){
                                   dynamicSubject = 'Action required! '+ getFr.Person_Requesting__r.Name +' has requested payment authorisation.';
                               }
                               if(getFr.Requested_by__c == 'Supplier'){
                                   dynamicSubject = 'Action required! '+ getFr.Opportunity__r.Referred_by_Company__r.Name +' has requested payment authorisation.';
                               }
                               mail.setSubject(dynamicSubject);
                               mail.setTreatTargetObjectAsRecipient(false);
                               mail.setUseSignature(false);
                               List<string> sendTo = new List<string>();
                               sendTo.add(frval);
                               mail.setToAddresses(sendTo);
                               if(owea.size() > 0){
                                   mail.setorgWideEmailAddressId(Owea.get(0).Id);
                               }  
                               if(!sendTo.isEmpty()){
                               emailList.add(mail);
                               }
                           }
                       }   
                       if(getFr.Requested_by__c == 'Supplier'){
                           if(getFr.Applicant_2_A2__c != null){
                               if(getFr.Customer_Authorisation_Type__c == 'Either to sign' || getFr.Customer_Authorisation_Type__c == null){
                                   sendMessage(getFr.Requested_by__c, getFr.Applicant_1_A1__r.Phone, getFr.Applicant_1_A1__r.Name, getFr.Person_Requesting__r.Name, getFr.Opportunity__r.Referred_by_Company__r.Name, getFr.Opportunity__r.Purpose__c);
                               }
                               else if(getFr.Customer_Authorisation_Type__c == 'Both to sign'){
                                   sendMessage(getFr.Requested_by__c, getFr.Applicant_1_A1__r.Phone, getFr.Applicant_1_A1__r.Name, getFr.Person_Requesting__r.Name, getFr.Opportunity__r.Referred_by_Company__r.Name, getFr.Opportunity__r.Purpose__c);
                                   sendMessage(getFr.Requested_by__c, getFr.Applicant_2_A2__r.Phone, getFr.Applicant_2_A2__r.Name, getFr.Person_Requesting__r.Name, getFr.Opportunity__r.Referred_by_Company__r.Name, getFr.Opportunity__r.Purpose__c);
                               }
                           }
                           else if(getFr.Applicant_2_A2__c == null){
                               sendMessage(getFr.Requested_by__c, getFr.Applicant_1_A1__r.Phone, getFr.Applicant_1_A1__r.Name, getFr.Person_Requesting__r.Name, getFr.Opportunity__r.Referred_by_Company__r.Name, getFr.Opportunity__r.Purpose__c);
                           }
                       }                       
                       if(getFr.Requested_by__c == 'Customer'){
                           if(getFr.Applicant_2_A2__c != null){
                               if(getFr.Person_Requesting__c != null){
                                   if(getFr.Customer_Authorisation_Type__c == 'Both to sign' && getFr.Person_Requesting__r.id == getFr.Applicant_1_A1__r.PersonContactId){
                                       sendMessage(getFr.Requested_by__c, getFr.Applicant_2_A2__r.Phone, getFr.Applicant_2_A2__r.Name, getFr.Person_Requesting__r.Name, getFr.Opportunity__r.Referred_by_Company__r.Name, getFr.Opportunity__r.Purpose__c);
                                   }
                                   else if(getFr.Customer_Authorisation_Type__c == 'Both to sign' && getFr.Person_Requesting__r.id == getFr.Applicant_2_A2__r.PersonContactId){
                                       sendMessage(getFr.Requested_by__c, getFr.Applicant_1_A1__r.Phone, getFr.Applicant_1_A1__r.Name, getFr.Person_Requesting__r.Name, getFr.Opportunity__r.Referred_by_Company__r.Name, getFr.Opportunity__r.Purpose__c);
                                   }
                               }
                           }
                       }                
                   }                
                if(!emailList.isEmpty()){
                    if(!Test.isRunningTest()){
                        Messaging.sendEmail(emailList);
                    }
                }            
            }
        }
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
    
    public void UpdateFundingAfterVariation(List<Funding_Request__c> newRequest,Map<Id,Funding_Request__c> oldReqMap){
        Map<id, Decimal>  quoteMap = new Map<id, Decimal>();
        if(oldReqMap == null){
            for(Funding_Request__c fr : newRequest){
                if(fr.Request_Type__c == 'Variation' && fr.Request_Status__c == 'Variation requested by customer'){
                    quoteMap.put(fr.Opportunity__c, fr.Invoice_Amount__c);              
                }
            }
        }
        else if(oldReqMap != null){
            for(Funding_Request__c fr : newRequest){
                if(fr.Request_Type__c == 'Variation' && oldReqMap.get(fr.id).Request_Type__c != 'Variation' && fr.Request_Status__c == 'Variation requested by customer' && oldReqMap.get(fr.id).Request_Status__c != 'Variation requested by customer'){
                    quoteMap.put(fr.Opportunity__c, fr.Invoice_Amount__c);              
                }
            }  
        }
        if(!quoteMap.isEmpty() && quoteMap != null){
        UpdateFundingAfterVariationFuture(quoteMap);
        }
    }

    public static void UpdateFundingAfterVariationFuture(map<Id,Decimal> quoteMap){
        Map<Id,Decimal> oppIdCustomeramtmap = new Map<Id,Decimal>();
        set<id> oppIds = new set<id>();
        if(!quoteMap.isEmpty() && quoteMap != null){
            
            list<Quote> qtlist = [select id,customer_amount__c,Gruop_Name__c,OpportunityId,Opportunity.SyncedQuote.Gruop_Name__c from quote where OpportunityId IN : quoteMap.keySet()];
            List<Quote> qtListToUpdate = new List<Quote>();
            if(!qtlist.isEmpty()){
                for(Quote qt : qtlist){
                    if(qt.Gruop_Name__c == qt.Opportunity.SyncedQuote.Gruop_Name__c){
                        oppIdCustomeramtmap.put(qt.OpportunityId, qt.customer_amount__c);
                        qt.customer_amount__c =  quoteMap.get(qt.OpportunityId);
                        qtListToUpdate.add(qt);
                    }
                }
                if(!qtListToUpdate.isEmpty()){
                    update qtListToUpdate; 
                } 
            } 
            
            Set<Id> contentDocId = new Set<Id>();
            List<ContentDocumentLink> linkList = [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :quoteMap.keySet()];  
            if(!linkList.isEmpty()){
                for(ContentDocumentLink cnt : linkList){
                    contentDocId.add(cnt.ContentDocumentId); 
                }
            }
            Set<Id> DocsIdsToStore = new Set<Id>();
            if(!contentDocId.isEmpty()){
                List<ContentVersion> cvList = [SELECT Id, Title,Category__c,Current_in_use__c, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: contentDocId];
                List<ContentVersion> cvListupdate = new List<ContentVersion>();
                if(!cvList.isEmpty()){
                    for(ContentVersion cvv : cvList){
                        if(cvv.Category__c == 'Lender Credit Contract' && cvv.Current_in_use__c == true){
                            DocsIdsToStore.add(cvv.id);
                            cvv.Current_in_use__c = false;
                            cvListupdate.add(cvv);
                        }
                    }
                    if(!cvListupdate.isEmpty()){
                        update cvListupdate;
                    }
                }
            }
            
            List<Opportunity> oppList = [SELECT Id,Stagename,Funding_Variation_Request__c,
                                         Previous_Loan_Amount_After_Variation__c,Lender_Documents_after_Variation__c
                                         FROM Opportunity WHERE Id IN: quoteMap.keySet()];
            Id SynceQuoteId; 
            if(!oppList.isEmpty()){
                for(Opportunity opp : oppList){
                    opp.Previous_Loan_Amount_After_Variation__c = oppIdCustomeramtmap.get(opp.Id);
                    opp.StageName = 'Packs Out';
                    opp.Funding_Variation_Request__c = true; 
                    if(!DocsIdsToStore.isEmpty()){
                        String idString = String.join(new List<Id>(DocsIdsToStore), ',');
                        opp.Lender_Documents_after_Variation__c = idString;    
                    }
                }
                Update oppList;
            }
        }
    }
    
    public void UpdatefundedToDate(List<Funding_Request__c> newRequests){
        Set<Id> fundingRequestIds = new Set<Id>();
        Set<Id> oppids = new Set<Id>();
        for(Funding_Request__c request : newRequests) {
            if(request.Opportunity__c != null){
                fundingRequestIds.add(request.Id);
                oppids.add(request.Opportunity__c);
            }
            system.debug('conttt'+request.Applicant_1_A1__r.personcontactID);
        }
        if(!fundingRequestIds.isEmpty()){
            List<Funding_Request__c> priorFundedRequests = [SELECT Id,Request_Amount__c,Funded_To_Date__c,Opportunity__c FROM Funding_Request__c
                                                            WHERE Request_Status__c = 'Payment funded' AND ID NOT IN:fundingRequestIds AND Opportunity__c IN:oppids];
            Decimal fundedToDate = 0;
            Map<Id,Decimal> fundingMap = new Map<Id,Decimal>();
            if(!priorFundedRequests.isEmpty()){
                for (Funding_Request__c request : priorFundedRequests) {
                    if(!fundingMap.containskey(request.Opportunity__c)){
                        fundingMap.put(request.Opportunity__c,request.Request_Amount__c);
                    }
                    else{
                        fundingMap.put(request.Opportunity__c,fundingMap.get(request.Opportunity__c) + request.Request_Amount__c);
                    } 
                }
            }
            
            for (Funding_Request__c request : newRequests) {
                if(oppids.contains(request.Opportunity__c)){
                    if(request.Request_Status__c != 'Payment funded'){ 
                        request.Funded_To_Date__c = fundingMap.get(request.Opportunity__c) != null ? fundingMap.get(request.Opportunity__c) : null;
                    }
                }
            }
        }    
    }
    public void HoldStatus(List<Funding_Request__c> newRequest,Map<ID, Funding_Request__c> oldReqMap){
        for(Funding_Request__c fr : newRequest){
            if (fr.Funding_On_Hold__c && (fr.Funding_Hold_Expiry_Date__c == Date.today()  || (fr.Customer_Authorisation_Status__c != 'Request sent to customer(s)' &&  fr.Customer_Authorisation_Status__c != null))) {
                fr.Funding_On_Hold__c = false;
                fr.Funding_On_Hold_Reason__c = '';
                fr.Date_Last_Request_Status_Changes__c = system.now();
            }
            
            // Funding On Hold checkbox: Can not uncheck manually - show warning
            if (oldReqMap != null && !fr.Funding_On_Hold__c && oldReqMap.get(fr.Id).Funding_On_Hold__c) {
                if((fr.Customer_Authorisation_Status__c == 'Request sent to customer(s)' ||  fr.Customer_Authorisation_Status__c == null) && (fr.Funding_Hold_Expiry_Date__c != Date.today())){
                    fr.addError('You cannot uncheck this field. Instead, update the Funding Hold Expiry Date to today’s date to recommence customer authorization flow immediately.');
                }
            } 
            
            // Fields Mandatory Error.
            if(fr.Funding_On_Hold__c == true){
                if(fr.Funding_Hold_Expiry_Date__c == null || fr.Funding_On_Hold_Reason__c == null){
                    fr.addError('Funding Hold Expiry Date and Funding On Hold Reason fields are mandatory before updating funding on Hold.');
                }
                else if(fr.Funding_Hold_Expiry_Date__c != null && fr.Funding_Hold_Expiry_Date__c < Date.today()){
                    fr.addError('Funding Hold Expiry Date will not set a past date (only today or future).');
                }
            }
        }
        UpdateRequestStatusForVariation(newRequest, oldReqMap);
    } 
    
    public void UpdateRequestStatusForVariation(List<Funding_Request__c> newRequest,Map<ID, Funding_Request__c> oldReqMap){
        for(Funding_Request__c fr : newRequest){
            if(oldReqMap == Null && fr.Request_Type__c == 'Variation'){
                fr.Previous_Req_Type__c = 'Payment in full after installation';
            }  
            else if(oldReqMap != Null && fr.Request_Type__c == 'Variation' && oldReqMap.get(fr.Id).Request_Type__c != 'Variation'){
                fr.Previous_Req_Type__c = oldReqMap.get(fr.Id).Request_Type__c;
            }
        }
    }
    
    public void updateRequestStatus(List<Funding_Request__c> newRequest,Map<ID, Funding_Request__c> oldReqMap){
        Map<id,string> productMap = new Map<id,string>();
        set<id> oppIds = new set<id>();
        for(Funding_Request__c fd : newRequest){
            if(fd.Opportunity__c != null){
                oppIds.add(fd.Opportunity__c);
            }
        }
        for(Opportunity opp : [select id,SyncedQuote.Product__r.Funding_Authorisation_Type__c from Opportunity where ID IN:oppIds]){
            productMap.put(opp.id,opp.SyncedQuote.Product__r.Funding_Authorisation_Type__c);
        }
        system.debug('mapp'+productMap);
        for(Funding_Request__c fr : newRequest){
            if((fr.A1_Funding_Call_Handover__c != null && oldReqMap.get(fr.id).A1_Funding_Call_Handover__c == null ) || (fr.A2_Funding_Call_Handover__c != null && oldReqMap.get(fr.id).A2_Funding_Call_Handover__c == null )){
                if((fr.Applicant_2_A2__c != null || fr.Applicant_2_A2__c == null) && fr.Customer_Authorisation_Type__c == 'Either to sign'){
                    if(fr.Request_Status__c != 'Funding handover call completed'){
                        fr.Request_Status_before_handover__c = fr.Request_Status__c;
                        fr.Authorisation_Status_before_handover__c = fr.Customer_Authorisation_Status__c;
                        fr.Request_Status__c = 'Funding handover call completed';
                        fr.Customer_Authorisation_Status__c = 'Authorised';
                    }
                }
                else if(fr.Applicant_2_A2__c != null && fr.Customer_Authorisation_Type__c == 'Both to sign'){
                    if(fr.A1_Funding_Call_Handover__c != null && fr.A2_Funding_Call_Handover__c != null){
                        fr.Request_Status_before_handover__c = fr.Request_Status__c;
                        fr.Request_Status__c = 'Funding handover call completed';
                        //fr.Authorisation_Status_before_handover__c = fr.Customer_Authorisation_Status__c;
                        fr.Customer_Authorisation_Status__c = 'Authorised';
                    }
                    else if(fr.A1_Funding_Call_Handover__c == null){
                        fr.Customer_Authorisation_Status__c = 'Pending Applicant 1';  
                    }
                    else if(fr.A2_Funding_Call_Handover__c == null){
                        fr.Customer_Authorisation_Status__c = 'Pending Applicant 2';
                    }
                }
                else if(fr.Applicant_2_A2__c == null && fr.Customer_Authorisation_Type__c == 'Both to sign'){
                    fr.Request_Status_before_handover__c = fr.Request_Status__c;
                    fr.Request_Status__c = 'Funding handover call completed';
                    fr.Authorisation_Status_before_handover__c = fr.Customer_Authorisation_Status__c;
                    fr.Customer_Authorisation_Status__c = 'Authorised';
                }
            }
            else if((fr.A1_Funding_Call_Handover__c == null && oldReqMap.get(fr.id).A1_Funding_Call_Handover__c != null ) || (fr.A2_Funding_Call_Handover__c == null && oldReqMap.get(fr.id).A2_Funding_Call_Handover__c != null )){
                if(fr.Request_Status__c == 'Funding handover call completed'){
                    if(fr.Applicant_2_A2__c != null && fr.Customer_Authorisation_Type__c == 'Either to sign'){
                        if(fr.A1_Funding_Call_Handover__c == null && fr.A2_Funding_Call_Handover__c == null){
                            fr.Request_Status__c = fr.Request_Status_before_handover__c;
                            fr.Customer_Authorisation_Status__c = 'Request sent to customer(s)';
                        }
                    }
                    else if(fr.Applicant_2_A2__c != null && fr.Customer_Authorisation_Type__c == 'Both to sign'){
                        if(fr.A1_Funding_Call_Handover__c == null && fr.A2_Funding_Call_Handover__c == null){
                            fr.Request_Status__c = fr.Request_Status_before_handover__c;
                            fr.Customer_Authorisation_Status__c = 'Request sent to customer(s)';
                        }
                        else if(fr.A1_Funding_Call_Handover__c == null || fr.A2_Funding_Call_Handover__c == null){
                            fr.Request_Status__c = fr.Request_Status_before_handover__c;
                            if(fr.A1_Funding_Call_Handover__c == null){
                                fr.Customer_Authorisation_Status__c = 'Pending Applicant 1'; 
                            }
                            else if(fr.A2_Funding_Call_Handover__c == null){
                                fr.Customer_Authorisation_Status__c = 'Pending Applicant 2'; 
                            }
                        }    
                    }
                    else if(fr.Applicant_2_A2__c == null){
                        fr.Request_Status__c = fr.Request_Status_before_handover__c;
                        fr.Customer_Authorisation_Status__c = 'Request sent to customer(s)';
                    }
                }
            }
        }
    }
    
    public void variationDelete(List<Funding_Request__c> newRequest){
        Set<Id> oppIds = new Set<Id>();
        for(Funding_Request__c fr : newRequest){
            if(fr.Request_Type__c == 'Variation' && fr.Opportunity__c != null){
               oppIds.add(fr.Opportunity__c);
            }
        }
        List<Opportunity> OppListToUpdate = new List<Opportunity>();
        if(!oppIds.isEmpty()){
            List<Opportunity> oppList = [SELECT Id,Funding_Variation_Request__c FROM Opportunity WHERE Id IN: oppIds AND Funding_Variation_Request__c = true];
            if(!oppList.isEmpty() && oppList != null){
                for(Opportunity opp : oppList){
                    system.debug('reType'+opp.Funding_Variation_Request__c);
                    opp.Funding_Variation_Request__c = false;
                    OppListToUpdate.add(opp);
                }
                Update OppListToUpdate;
            }
        }
    }
}