public without sharing class ManageDocumentController{
    
    @AuraEnabled
    public static Boolean checkApplicantTwo(String oppId){
        List<Opportunity> oppConts = [select Id from Opportunity 
                where Id =: oppId and Applicant_2__c != null];
        if(oppConts.size()>0){
            return true;
        }else{
            return false;
        }
    }
    
    @AuraEnabled
    public static Map<String,List<selectOptionWrap>> getApplicantOne(){
    
        Map<String,List<selectOptionWrap>> applicants = new Map<String,List<selectOptionWrap>>();
        
        List<Manage_Document__c> dmList = [SELECT Application_Type__c, Category__c, Description__c, Document__c, IsJoint__c, isBankStatment__c
                                            FROM Manage_Document__c];
                                            
        if(dmList.size() > 0){
            for(Manage_Document__c dm : dmList){
                if(!dm.isJoint__c){
                    String documentName = '';
                    String Descr = '';
                    if(dm.Description__c != null){
                        documentName = dm.Document__c+' : '+dm.Description__c;
                    }
                    else{
                        documentName = dm.Document__c;
                    }
                    if(applicants.get(dm.Category__c) != null){
                        
                        List<selectOptionWrap> sList = applicants.get(dm.Category__c);
                        sList.add(new selectOptionWrap(dm.Document__c,documentName,dm.Description__c,dm.isBankStatment__c ));
                        applicants.put(dm.Category__c,sList);
                    }else{
                        applicants.put(dm.Category__c,new List<selectOptionWrap>{new selectOptionWrap(dm.Document__c,documentName,dm.Description__c, dm.isBankStatment__c)});
                    }
                }
            }
        }
        
        return applicants;
    }
    
    @AuraEnabled
    public static Map<String,List<selectOptionWrap>> getApplicantTwo(){
    
        Map<String,List<selectOptionWrap>> applicants = new Map<String,List<selectOptionWrap>>();
        
        List<Manage_Document__c> dmList = [SELECT Application_Type__c, Category__c, Description__c, Document__c, IsJoint__c, isBankStatment__c
                                            FROM Manage_Document__c];
                                            
        if(dmList.size() > 0){
            for(Manage_Document__c dm : dmList){
                if(!dm.isJoint__c){
                    String documentName = '';
                    if(dm.Description__c != null)
                        documentName = dm.Document__c+' : '+dm.Description__c;
                    else
                        documentName = dm.Document__c;
                        
                    if(applicants.get(dm.Category__c) != null){
                        
                        List<selectOptionWrap> sList = applicants.get(dm.Category__c);
                        sList.add(new selectOptionWrap(dm.Document__c,documentName,dm.Description__c, dm.isBankStatment__c));
                        applicants.put(dm.Category__c,sList);
                    }else{
                        applicants.put(dm.Category__c,new List<selectOptionWrap>{new selectOptionWrap(dm.Document__c,documentName,dm.Description__c, dm.isBankStatment__c)});
                    }
                }
            }
        }
        
        return applicants;
    }
    
    @AuraEnabled
    public static Map<String,List<selectOptionWrap>> getJointApplication(){
        
        List<selectOptionWrap> otherCategory = new List<selectOptionWrap>();
        for(Integer i=0; i<5; i++)
            otherCategory.add(new selectOptionWrap('','','',false));
            
        Map<String,List<selectOptionWrap>> applicants = new Map<String,List<selectOptionWrap>>();
        
        List<Manage_Document__c> dmList = [SELECT Application_Type__c, Category__c, Description__c, Document__c, IsJoint__c, isBankStatment__c
                                            FROM Manage_Document__c];
                                            
        if(dmList.size() > 0){
            for(Manage_Document__c dm : dmList){
                if(dm.isJoint__c){
                    String documentName = '';
                    if(dm.Description__c != null)
                        documentName = dm.Document__c+' : '+dm.Description__c;
                    else
                        documentName = dm.Document__c;
                        
                    if(applicants.get(dm.Category__c) != null){
                        
                        List<selectOptionWrap> sList = applicants.get(dm.Category__c);
                        sList.add(new selectOptionWrap(dm.Document__c,documentName,dm.Description__c, dm.isBankStatment__c));
                        applicants.put(dm.Category__c,sList);
                    }else{
                        applicants.put(dm.Category__c,new List<selectOptionWrap>{new selectOptionWrap(dm.Document__c,documentName,dm.Description__c, dm.isBankStatment__c)});
                    }
                }
            }
        }
        
        applicants.put('Others',otherCategory);
        
        return applicants;
    }
    
    @AuraEnabled
    public static Map<String,List<String>> getSelectedCategory(String applicationType){
        Map<String,List<String>> selectedCategories = new Map<String,List<String>>();
        
        List<String> includesList = new List<String>{'\''+applicationType+'\''};
        String queryString = 'SELECT Application_Type__c, Category__c, Description__c, Document__c, IsJoint__c FROM Manage_Document__c Where Application_Type__c INCLUDES(';
        for(String includeValue :includesList)
            queryString += includeValue + ',';
        queryString = queryString.removeEnd(',') +')';
        List<Manage_Document__c> dmList = (List<Manage_Document__c>)Database.query(queryString);
        
        if(dmList.size() > 0){
            for(Manage_Document__c dm : dmList){
                
                if(selectedCategories.get(dm.Category__c) != null){
                    selectedCategories.get(dm.Category__c).add(dm.Document__c);
                }else{
                    selectedCategories.put(dm.Category__c,new List<String>{dm.Document__c});
                }
                
            }
        }
        
        return selectedCategories;
    }
    @AuraEnabled
    public static void createDocumentRequest(String documentList, Boolean isAppTwo, String oppId, Boolean isSendEmail){
        Map<String, Id> PrimaryContact = new Map<String, Id>();
        Opportunity op = new Opportunity();
        
        String temp = oppId.trim();
        oppId = temp;
        
        List<Opportunity> opList = [Select Name,Owner.Email, Applicant_1__c ,Owner.Id, Applicant_2__c, Applicant_1__r.PersonEmail ,Applicant_2__r.PersonEmail, Applicant_1__r.Firstname, Applicant_1__r.PersonContactId,Credit_Analyst__c,Credit_Analyst__r.Email,RecordType.Name,RecordTypeId 
                          FROM Opportunity
                          WHERE ID =:temp ];
        
        if(opList.size()>0)
            op = opList[0];
        else
            throw new AuraHandledException('error! Please contact to Administrator');
            
        PrimaryContact.put('ApplicantOne', op.Applicant_1__c);
        
        if(String.isNotBlank(op.Applicant_2__c))
            PrimaryContact.put('ApplicantTwo', op.Applicant_2__c);
        
        //Check if documents are already exists
        Set<String> app1docs = new Set<String>();
        Set<String> app2docs = new Set<String>();
        Set<String> gendocs = new Set<String>();
        
        Opportunity opp = [SELECT Applicant_1__c,Applicant_2__c
                           FROM Opportunity WHERE Id =: oppId][0];
        
        for(Document_Requested__c doc : [SELECT Document__c,Person_Account__c FROM Document_Requested__c WHERE Person_Account__c =: opp.Applicant_1__c AND Opportunity__c =: oppId]){
            app1docs.add(doc.Document__c);
        }
        
        if(opp.Applicant_2__c != null){
            for(Document_Requested__c doc : [SELECT Document__c,Person_Account__c FROM Document_Requested__c WHERE Person_Account__c =: opp.Applicant_2__c AND Opportunity__c =: oppId]){
                app2docs.add(doc.Document__c);
            }   
        }
        
        for(Document_Requested__c doc : [SELECT Document__c,Person_Account__c FROM Document_Requested__c WHERE Person_Account__c = null AND Opportunity__c =: oppId]){
            gendocs.add(doc.Document__c);
        }
        
        Map<String,Map<String,List<selectOptionWrap>>> mapOfApplication = new Map<String,Map<String,List<selectOptionWrap>>>();
        List<Document_Requested__c> docList = new List<Document_Requested__c>();
        List<documentRequestWrap> documentRequestList = (List<documentRequestWrap>) JSON.deserialize(documentList, List<documentRequestWrap>.class);
        String message = ' Required Document List are: <br/> ';
        for(documentRequestWrap var : documentRequestList){
            if(var.label == 'ApplicantOne'){
        
                for(documentCategaryWrap cat : (List<documentCategaryWrap>)var.value){
                    message += '<h4> * '+cat.categry+'</h4> <br/> ';
                    
                    integer i = 0;
                    
                    for(selectOptionWrap item :(List<selectOptionWrap>)cat.selectedItem){
                        List<String> label = item.label.split(':');
                        message += ++i+'. <b>'+item.value+'</b> : '+item.Discription+'.<br/>';
                        System.debug('====> app1docs '+app1docs);
                        System.debug('====> item.value '+item.value.trim());
                        if(!app1docs.contains(item.value.trim())){
                            docList.add(new Document_Requested__c(
                                Document__c = item.value,
                                Description__c = item.Discription,
                                Category__c = cat.categry,
                                Person_Account__c = PrimaryContact.get('ApplicantOne'),
                                Opportunity__c = oppId,
                                //reason__c = item.Discription,
                                isBankStatement__c = item.isBankStatment
                            ));
                            System.debug('====> docList '+docList);
                        }
                    }
                }
            }else if(var.label == 'ApplicantTwo'){
                message += '<h3>For Secondary Person: </h3><br/>';
                for(documentCategaryWrap cat : (List<documentCategaryWrap>)var.value){
                    message += '<h4> * '+cat.categry+'</h4> <br/> ';
                    integer i = 0;
                    for(selectOptionWrap item :(List<selectOptionWrap>)cat.selectedItem){
                        List<String> label = item.label.split(':');
                        System.debug('====> app2docs 2 '+app2docs);
                        System.debug('====> item.value 2 '+item.value.trim());
                        if(!app2docs.contains(item.value.trim())){
                            docList.add(new Document_Requested__c(
                                Document__c = item.value,
                                Description__c = item.Discription,
                                Category__c = cat.categry,
                                Person_Account__c = PrimaryContact.get('ApplicantTwo'),
                                Opportunity__c = oppId,
                                //reason__c = item.Discription,
                                isBankStatement__c = item.isBankStatment
                            ));
                            System.debug('====> docList 2 '+docList);
                        }
                        message += ++i+'. <b>'+item.value+'</b> : '+item.Discription+'.<br/>' ;
                    }
                }
            }else{
                message += '<h3>For Genral Documents:</h3> <br/>';
                for(documentCategaryWrap cat : (List<documentCategaryWrap>)var.value){
                    message += '<h4> * '+cat.categry+'</h4> <br/> ';
                    integer i = 0;
                    for(selectOptionWrap item :(List<selectOptionWrap>)cat.selectedItem){
                        List<String> label = item.label.split(':');
                        if(!gendocs.contains(item.value.trim())){
                            docList.add(new Document_Requested__c(
                                Document__c = item.value,
                                Description__c = item.Discription,
                                Category__c = cat.categry,
                                //Contact__c = PrimaryContact.get('AplicantTwo'),
                                Opportunity__c = oppId,
                               // reason__c = item.Discription,
                                isBankStatement__c = item.isBankStatment
                            ));
                        }
                        message += ++i+'. <b>'+item.value+'</b> Discription: '+item.Discription+'.<br/>' ;
                    }
                }
            }
        }
        
        String url = label.instanceURL+''+label.SiteUrl.replaceFirst('\'\'','')+'/apex/sessionId?oppId='+oppId;
        //url = EncodingUtil.urlEncode(url, 'UTF-8');
        //System.debug(url);
        message += '<p>To upload document please <a href="'+url+'">click here</a></p>';
        System.debug(message);
        //sendMail(op.Applicant_1__r.PersonEmail, op.Applicant_2__r.PersonEmail,message);
        if(isSendEmail)
            UtilityClass.sendEmail(op);
            
        insert docList;
    }
    public static void sendMail(String mailId,String cc, String message){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        string[] to = new string[] {mailId};
            email.setToAddresses(to);
        if(String.isNotBlank(cc))
            email.setCcAddresses(new string[] {cc});
        email.setSubject('Required Document');
        email.setHtmlBody('Please upload below documents for associated applicant <br/> '+message);
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }catch(exception e){
            apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
        }
    }
    public class documentRequestWrap{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public List<documentCategaryWrap> value;
    }
    public class documentCategaryWrap{
        @AuraEnabled
        public String categry;
        @AuraEnabled
        public List<selectOptionWrap> selectedItem;
    }
    public class selectOptionWrap{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String Discription;
        @AuraEnabled
        public Boolean isSelected;
        @AuraEnabled
        public Boolean isBankStatment;
        public selectOptionWrap(String value, String label,string Discription,Boolean isBankStatment ){
            this.label = label;
            this.value = value;
            this.Discription = Discription;
            isSelected = false;
            this.isBankStatment = isBankStatment;
        }
    }
    
}