public without sharing class DownloadFileController{
    
    @AuraEnabled
    public static void updateLender(Boolean chkbx, id CVID){
        System.debug('cvId'+CVID);
        ContentVersion cv = [select Id,related__c, Category__c,Send_to_Lender__c, Title, FileExtension, Description, ContentModifiedDate, CreatedDate, ContentSize, ContentDocumentId from ContentVersion
                                   where Id =: CVID LIMIT 1];
    	cv.Send_to_Lender__c = chkbx;
        update cv;
        
    }
    
    @AuraEnabled
    public static List<ContentVersion> getContentVersion(String recordIdStr){
        Id recordId = (Id)recordIdStr;
        
        List<ContentDocumentLink> c = [SELECT ContentDocument.LatestPublishedVersionId, LinkedEntityId, ContentDocumentId
                                       FROM ContentDocumentLink WHERE LinkedEntityId =: recordId];
        
        List<ID> vId = new List<ID>();
        for(ContentDocumentLink a: c){            
            vId.add(a.ContentDocument.LatestPublishedVersionId );
        }
        List<ContentVersion> cv = [select Id,related__c, Category__c,Current_in_use__c,Send_to_Lender__c, Title, FileExtension, Description, ContentModifiedDate, CreatedDate, ContentSize, ContentDocumentId from ContentVersion
                                   where Id in :vId AND FileExtension != 'snote'];
        
        return cv;
    }
    
    @AuraEnabled
    public static List<Map<String,String>> getZipFile(List<String> recordIdStr){
        
        List<ContentVersion> cv = [select Id, ContentDocumentId, Title, FileExtension, ContentBodyId, ContentSize, VersionData from ContentVersion
                                   where Id in :recordIdStr];
        double size = 0; 
        for(ContentVersion cvs: cv){
            size += cvs.ContentSize;
        }
        List<Map<String,String>> attachments = new List<Map<String,String>>();
        for(ContentVersion cvf:cv){
            Map<String,String> cvMap = new Map<String,String>();
            cvMap.put('title', cvf.Title);
            cvMap.put('data', EncodingUtil.base64Encode(cvf.VersionData));
            cvMap.put('ext', cvf.FileExtension );
            cvMap.put('docId', cvf.ContentDocumentId);
            attachments.add(cvMap);
        }
        return attachments;
    }
    
    
    @AuraEnabled
    public static void deleteContent(String recordIdStr){
        System.debug('====> '+recordIdStr);
        Delete [SELECT Id FROM ContentDocument WHERE Id =: recordIdStr LIMIT 1];
    }
    
    @AuraEnabled
    public static String downloadContent(String recordIdStr){
        List<ContentVersion> cv = [select Id, ContentDocumentId, Title, FileExtension  , ContentBodyId, ContentSize, VersionData from ContentVersion
                                   where Id =:recordIdStr];
        
        String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();
        String URlDownload = fullFileURL+'/sfc/servlet.shepherd/version/download/'+cv.get(0).Id;
        
        return URlDownload;
    }
    
    @AuraEnabled
    public static List<SObject> getAllObjRecords(String objType, String searchFor, String recId){
        searchFor += '%';
        String sQuery = 'Select Id, Name, Applicant_1__c, Applicant_2__c, Applicant_1__r.Name, Applicant_2__r.Name from ' + objType + ' where Name Like:searchFor And Id !=:recId';
        List<SObject> fetchRecords = Database.query(sQuery);
        return fetchRecords;
    }
    @AuraEnabled
    public static List<String> findMatch(String selectId, String oldId){
        Opportunity newOpp = [Select Id, Name, Applicant_1__c, Applicant_2__c from Opportunity where Id=:selectId];
        Opportunity oldOpp = [Select Id, Name, Applicant_1__c, Applicant_2__c from Opportunity where Id=:oldId];
        List<String> app = new List<String>();
        if(newOpp.Applicant_1__c == oldOpp.Applicant_1__c || newOpp.Applicant_1__c == oldOpp.Applicant_2__c){
            app.add('Applicant 1');
        }
        if(newOpp.Applicant_2__c == oldOpp.Applicant_1__c || newOpp.Applicant_2__c == oldOpp.Applicant_2__c){
            app.add('Applicant 2');
        }
        return app;
    } 
    @AuraEnabled 
    public static void copyFilesToNew(String newCaseId, List<String> cvIds, String oldOppId){
        Opportunity oldOpp = [Select Id, Applicant_1__c, Applicant_2__c from Opportunity where Id=:oldOppId];
        Opportunity newOpp = [Select Id, Applicant_1__c, Applicant_2__c from Opportunity where Id=:newCaseId];
        if(cvIds.size() > 10){
            List<String> tempCv = new List<String>();
            Integer j = 1;
            Integer k = 9;
            for(Integer i = 0; i < cvIds.size(); i++){
                tempCv.add(cvIds[i]);
                if(i == (j*k) || i+1 == cvIds.size()){
                    System.debug(tempCv.size() + ' ' + j);
                    DownloadFileController.copyFunction(newCaseId, tempCv, oldOppId, oldOpp, newOpp);	
                    tempCv.clear();
                    j++;
                }
            }
        }
        else{
            DownloadFileController.copyFunction(newCaseId, cvIds, oldOppId, oldOpp, newOpp);
        }
    }
    public static void copyFunction(String newCaseId, List<String> cvIds, String oldOppId, Opportunity oldOpp, Opportunity newOpp){
        List<ContentVersion> cdId = [SELECT ContentUrl, Document_Requested__c, Description, PathOnClient, ContentDocumentId, VersionData, Title, FileType from ContentVersion where Id IN: cvIds];
        List<ContentVersion> newCV = new List<ContentVersion>();
        Set<Id> drId = new Set<Id>();
        for(ContentVersion c: cdId){
            drId.add(c.Document_Requested__c);
        }
        List<Document_Requested__c> oldDr = [Select Id, Category__c, IsJoint__c, isApplicable__c, Opportunity__c, Person_Account__c, 
                                             reason__c, Contact__c, Description__c, Details__c, Document__c, isComplete__c,
                                             isAlready_provided__c,Status__c from Document_Requested__c where Id In :drId];
       
        List<Document_Requested__c> newDr = new List<Document_Requested__c>();
        for(Document_Requested__c dr: oldDr){
            Document_Requested__c ins = new Document_Requested__c();
            ins = dr.clone(false,true);
            ins.Opportunity__c = newOpp.Id;
            if(ins.Person_Account__c != null){
                if(ins.Person_Account__c == newOpp.Applicant_1__c){
                    ins.Person_Account__c = newOpp.Applicant_1__c;
                    ins.isComplete__c = true;
                }
                else if(ins.Person_Account__c == newOpp.Applicant_2__c){
                    ins.Person_Account__c = newOpp.Applicant_2__c;
                    ins.isComplete__c = true;
                }
                else{
                    ins.Person_Account__c = null;
                    ins.IsJoint__c = true;
                    ins.isComplete__c = true;
                }
            }
            else{
                ins.Person_Account__c = null;
                ins.IsJoint__c = true;
                ins.isComplete__c = true;
            }
           	newDr.add(ins);
        }
        insert newDr;
        for(Integer i = 0; i < oldDr.size(); i++){
            for(ContentVersion c: cdId){
                if(c.Document_Requested__c == oldDr[i].id){
                    ContentVersion ncv = new ContentVersion();
                    ncv.VersionData = c.VersionData;
                    ncv.Title = c.Title;
                    ncv.PathOnClient = c.PathOnClient;
                    ncv.ContentUrl = c.ContentUrl;
                    ncv.Description = c.Description;
                    ncv.Document_Requested__c = newDr[i].Id;
                    newcv.add(ncv);
                }
            }
        }
        for(ContentVersion c: cdId){
            if(c.Document_Requested__c == null){
                ContentVersion ncv = new ContentVersion();
                ncv.VersionData = c.VersionData;
                ncv.Title = c.Title;
                ncv.PathOnClient = c.PathOnClient;
                ncv.ContentUrl = c.ContentUrl;
                ncv.Description = c.Description;
                newcv.add(ncv);
            }
        }
        insert newCV;
        Set<Id> newCVid = new Set<Id>();
        for(ContentVersion cc: newCV){
            newCVid.add(cc.Id);
        }
        List<ContentVersion> listToCdl = [Select Id, ContentDocumentId from ContentVersion where id in : newCVid];
        
        List<ContentDocumentLink> newCDL = new List<ContentDocumentLink>();
        for(ContentVersion c: listToCdl){
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = newCaseId;
            cdl.ContentDocumentId = c.ContentDocumentId;
            cdl.shareType = 'V';
            newCDL.add(cdl);
        }
        insert newCDL;
    }
    @AuraEnabled
    public static list <ContentVersion> sortedList(List<String> cvIds, String sortField, boolean isAsc) {
        String sSoql = 'select Id, related__c, Category__c, Title,Current_in_use__c, FileExtension, Description, ContentModifiedDate, CreatedDate, ContentSize, ContentDocumentId from ContentVersion where Id in :cvIds';
        if(sortField != ''){
            sSoql += ' order by ' + sortField;
            if(isAsc){
                sSoql += ' asc';
            }
            else{
                sSoql += ' desc';
            }
        }
        list <ContentVersion> lstResult;
        lstResult = Database.query(sSoql);
        return lstResult;
    }
    
    @AuraEnabled
    public static list<ContentVersion> filterRelated(String recordIdStr, List<String> listRelated, List<String> listCategory){
        Id recordId = (Id)recordIdStr;
        
        List<ContentDocumentLink> c = [SELECT ContentDocument.LatestPublishedVersionId, LinkedEntityId, ContentDocumentId
                                       FROM ContentDocumentLink WHERE LinkedEntityId =: recordId];
        
        List<ID> vId = new List<ID>();
        for(ContentDocumentLink a: c){            
            vId.add(a.ContentDocument.LatestPublishedVersionId );
        }
        List<ContentVersion> cv = new List<ContentVersion>();
        String sql = 'select Id,related__c, Category__c, Title, FileExtension, Description, ContentModifiedDate, CreatedDate, ContentSize, ContentDocumentId from ContentVersion where Id IN :vId';
        if(listRelated.size() > 0){
            if(listRelated.contains('Applicant 1')){
                Opportunity accid = [select Applicant_1__r.FirstName, Applicant_1__r.MiddleName, Applicant_1__r.LastName from Opportunity where id=:recordId];
                listRelated.remove(listRelated.indexOf('Applicant 1'));
                String fullName = accid.Applicant_1__r.FirstName + ' ';
                if(accid.Applicant_1__r.MiddleName != null){
                    fullName += accid.Applicant_1__r.MiddleName;
                }
                fullName += ' ' + accid.Applicant_1__r.LastName;
                listRelated.add(fullName);
            }
            if(listRelated.contains('Applicant 2')){
                Opportunity accid = [select Applicant_2__r.FirstName,Applicant_2__r.MiddleName, Applicant_2__r.LastName from Opportunity where id=:recordId];
                listRelated.remove(listRelated.indexOf('Applicant 2'));
                String fullName = accid.Applicant_2__r.FirstName + ' ';
                if(accid.Applicant_2__r.MiddleName != null){
                    fullName += accid.Applicant_2__r.MiddleName;
                }
                fullName += ' ' + accid.Applicant_2__r.LastName;
                listRelated.add(fullName);
            }
            System.debug(listRelated);
            sql += ' And Related__c IN :listRelated';
        }
        if(listCategory.size() > 0){
            sql += ' And Category__c IN :listCategory';
        }
        cv = Database.query(sql);
        System.debug(sql);
        System.debug(cv);
        return cv;
    }
    
    @AuraEnabled
    public static Opportunity getOppDetail(String recId){
        Id oid = (Id) recId;
        Opportunity opp = [Select Id, Docs_Outstanding__c, Applicant_1__c, Applicant_1__r.Name, Applicant_2__c, Applicant_2__r.Name from Opportunity where Id =:oid];	    
        return opp;
    }
    
    @AuraEnabled
    public static List<ContentVersion> fetchUploaded(List<String> documentIds){
        List<ContentVersion> cv = [select Id,related__c, Category__c, Title, Description, ContentDocumentId from ContentVersion
                                   where ContentDocumentId in :documentIds];
        return cv;
    }
    
    @AuraEnabled
    public static boolean fetchPreviousDocs(Id recordId){
        boolean docExist = false;
        List<ContentDocumentLink> cntList = [SELECT LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId];
        Set<Id> contentDocId = new Set<Id>();
        List<ContentVersion> cvList = new List<ContentVersion>();
        if(!cntList.isEmpty()){
            for(ContentDocumentLink cnt : cntList){
                contentDocId.add(cnt.ContentDocumentId); 
            }
        }
        if(!contentDocId.isEmpty()){
            cvList = [SELECT Id, Title,Category__c, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: contentDocId];
            for(ContentVersion cv : cvList){
                if(cv.Category__c == 'Lender Credit Contract'){
                    docExist = true;
                    break;
                }
            }
        }
        return docExist;
    }
    
    @AuraEnabled
    public static void updateCustomerActivity(string recId){
        Opportunity opp = [select id,Last_Customer_Action__c,isActivityCheck__c,Last_Customer_Activity__c/*,Docs_Last_Uploaded__c*/ from opportunity where id =: recId];
        opp.Last_Customer_Activity__c = system.now(); 
        opp.isActivityCheck__c = false;
        update opp;
        opp.isActivityCheck__c = true;
        opp.Last_Customer_Action__c = 'Documents received';
        opp.Docs_Last_Uploaded__c = System.now();
        update opp;
    }
    
    @AuraEnabled
    public static void uploadDocuments(List<ContentVersion> finalList, String recId){
        System.debug(finalList);
        Set<Id> ids = new Set<Id>();
        for(ContentVersion c: finalList){
            ids.add(c.Id);
        }
        Opportunity newOpp = [Select Id, Applicant_1__c, Applicant_2__c from Opportunity where Id=:recId];
        List<ContentVersion> listToUpdate = new List<ContentVersion>();
        List<ContentVersion> cv = [select Id, Document_Requested__c, Related__c, Category__c, Title, Description from ContentVersion
                                   where Id in :ids];
        List<Document_Requested__c> newDr = new List<Document_Requested__c>();
        try{
            for(ContentVersion fcv: cv){
                for(ContentVersion a: finalList){
                    if(fcv.Id == a.Id){
                        Document_Requested__c ins = new Document_Requested__c();
                        ins.Opportunity__c = newOpp.Id;
                        if(a.Related__c != 'General'){
                            if(a.Related__c == newOpp.Applicant_1__c){
                                ins.Person_Account__c = newOpp.Applicant_1__c;
                                ins.isComplete__c = true;
                                System.debug(a.Category__c);
                                if(a.Category__c != null){
                                    ins.Category__c = a.Category__c;
                                }
                            }
                            else if(a.Related__c == newOpp.Applicant_2__c){
                                ins.Person_Account__c = newOpp.Applicant_2__c;
                                ins.isComplete__c = true;
                                System.debug(a.Category__c);
                                if(a.Category__c != null){
                                    ins.Category__c = a.Category__c;
                                }
                            }
                        }
                        else{
                            ins.Person_Account__c = null;
                            ins.IsJoint__c = true;
                            ins.isComplete__c = true;
                            System.debug(a.Category__c);
                            if(a.Category__c != null){
                                ins.Category__c = a.Category__c;
                            }
                        }
                        newDr.add(ins);
                        if(fcv.Title != a.Title){
                            fcv.Title = a.Title;
                        }
                        fcv.Description = a.Description;
                        listToUpdate.add(fcv);
                    }
                }
            }
            insert newDr;
            
            Set<id> newids = new Set<id>(); //Pawan.
            for(Integer i = 0; i< newDr.size(); i++){
                listToUpdate[i].Document_Requested__c = newDr[i].Id;
                //Added by Pawan - PDO-1019
                if(newDr[i].Category__c == 'Lender Credit Contract'){ 
                 listToUpdate[i].Current_in_use__c = true; 
                 newids.add(listToUpdate[i].id); 
                }
                // Pawan Code End.
            }
            update listToUpdate;
            
            //Added by Pawan PDO-1019.
            List<ContentVersion> cntOldstoUpdate = new List<ContentVersion>();
            Set<Id> contentDocId = new Set<Id>();
            if(!newids.isEmpty()){
                List<ContentDocumentLink> linkList = [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recId]; 
                if(!linkList.isEmpty()){
                    for(ContentDocumentLink cnt : linkList){
                        contentDocId.add(cnt.ContentDocumentId); 
                    }
                }
                
                if(!contentDocId.isEmpty()){
                    List<ContentVersion> cvList = [SELECT Id, Title,Category__c,Current_in_use__c, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: contentDocId AND Id NOT IN : newids];
                    if(!cvList.isEmpty()){
                        for(ContentVersion cvv : cvList){
                            if(cvv.Category__c == 'Lender Credit Contract' && cvv.Current_in_use__c == true){
                                cvv.Current_in_use__c = false;
                                cntOldstoUpdate.add(cvv);
                            }
                        }
                    }
                }
                if(!cntOldstoUpdate.isEmpty()){
                    system.debug('cntOldstoUpdate'+cntOldstoUpdate.size());
                    update cntOldstoUpdate;
                }
            } 
            //Pawan Code End.
            
        }
        catch(Exception e){
            System.debug(e);
        }
    }
    @AuraEnabled
    public static String pdfMerge( Boolean forInsert, String oppId, List<String> ids){
        
        List<ContentDistribution> distributionsToInsert = [Select Id, PdfDownloadUrl, DistributionPublicUrl,ContentVersionId,ContentDownloadURL from ContentDistribution where ContentVersionId in: ids];
        System.debug(forInsert);
        if(forInsert){
            if(distributionsToInsert.size() != ids.size()){
                Set<Id> alreadyIn = new Set<Id>();
                if(distributionsToInsert.size() > 0){
                    for(ContentDistribution d: distributionsToInsert){
                        alreadyIn.add(d.ContentVersionId);
                    }
                }
                List<ContentDistribution> newDis = new List<ContentDistribution>();
                for(Id thisCId : ids){
                    if(!alreadyIn.contains(thisCId)){
                        newDis.add(new ContentDistribution(ContentVersionId  = thisCId, 
                                                           Name='External Link',
                                                           PreferencesNotifyOnVisit = false));
                    }
                }
                insert newDis;
                System.debug(newDis.size());
            }
            return 'done';
        }
        else{
            Opportunity opp = [Select Id, Applicant_1__c, Applicant_2__c, Applicant_1__r.Name, Applicant_2__r.Name, Applicant_1__r.FirstName, Applicant_2__r.FirstName,
                               Applicant_1__r.MiddleName, Applicant_1__r.LastName,Applicant_2__r.MiddleName, Applicant_2__r.LastName  from Opportunity where Id=: oppId ];
            List<ContentVersion> cv = [select Id, Document_Requested__c,ContentUrl,PathOnClient, VersionData, Related__c, Category__c, Title, Description from 
                                       ContentVersion where Id in :ids];
            List<String> category = new List<String>{'Identification','Loan Purpose','Assets','Income','Living Expenses','Liabilities Remaining','Liabilities Being Refinanced','Rental Income','Business Income'}; 
                Map<String, List<ContentVersion>> listDoc = new Map<String, List<ContentVersion>>
            {'ID / VOI'=>[select Id,Related__c, Category__c, Title, FileType from ContentVersion where Id in :ids and Category__c='Identification'],
                'LOAN PURPOSE'=>[select Id, Related__c, Category__c, Title, FileType from ContentVersion where Id in :ids and Category__c='Loan Purpose'],
                'ASSETS'=>[select Id, Related__c, Category__c, Title, FileType from ContentVersion where Id in :ids and Category__c='Assets'],
                'INCOME'=>[select Id, Related__c, Category__c, Title, FileType from ContentVersion where Id in :ids and Category__c in ('Income','Business Income','Rental Income')],
                'LIVING EXPENSES'=>[select Id, Related__c, Category__c, FileType, Title from ContentVersion where Id in :ids and Category__c='Living Expenses'],
                'LIABILITIES'=>[select Id, Related__c, Category__c, Title, FileType from ContentVersion where Id In :ids and Category__c in ('Liabilities Remaining','Liabilities Being Refinanced')],
                'OTHER'=>[select Id, Related__c, Category__c, Title, FileType from ContentVersion where Id in :ids and Category__c Not in : category]};
                    String applicant1,applicant2,fullName;
            String app1Name = opp.Applicant_1__r.FirstName + ' ';
            if(opp.Applicant_1__r.MiddleName != null){
                app1Name += opp.Applicant_1__r.MiddleName;
            }
            app1Name += ' ' + opp.Applicant_1__r.LastName;
            String app2Name;
            if(opp.Applicant_2__c != null){
                app2Name = opp.Applicant_2__r.FirstName + ' ';
                if(opp.Applicant_2__r.MiddleName != null){
                    app2Name += opp.Applicant_2__r.MiddleName;
                }
                app2Name += ' ' + opp.Applicant_2__r.LastName;
            }
            String[] urls = new List<String>();
            String htmlCode = '<html><head><style TYPE="text/css"> @page {margin-left: 0cm; margin-right: 0cm; margin-top: 220px; margin-bottom: 0cm; size:A4 portrait; @top-left {content: element(header); } @bottom-left {content: element(footer); } } .container {position: relative; font-family: Helvetica; z-index:1; } .text-block {position: absolute; top: 30px; left: 60px; font-size: 40px; width:500px; color: white; z-index:2; font-weight: bold; font-family: Calibri; } div.header {position: running(header); width: 100%; margin-right: 1px; } div.footer {width:100%;height:80px;position:absolute;content : "My Footer on right Side";bottom:0;left:0;background:#ee5; display: block; padding: 5px; position: running(footer); } .logo {position: absolute; top: 40px; right: 60px; } .logo img{width: 125px; } body {margin: 0px ; font-family: Calibri; } .font-family{font-family:Arial, Helvetica, sans-serif;; } .only-bottom-border {border-style: solid; border-left: none; border-right: none; border-top: none; } </style></head><body><div class="font-family"><div class="container header"><img src="https://lanecorp--teamindi--c.documentforce.com/servlet/servlet.ImageServer?id=0159D0000006HVb&oid=00D9D0000008cJz&lastMod=1582716767000" style="width: 100%;"><div class="text-block"><b>Application<br>Supporting Documents</b></div><div class="logo"><img src="https://lanecorp--teamindi--c.documentforce.com/servlet/servlet.ImageServer?id=0159D0000006HVg&oid=00D9D0000008cJz&lastMod=1582716973000"></div></div><div class="align_absolute-center" style="margin-top: 1px;width:100%;"><div style="text-align:center;"><div style="text-align:center;padding:25px 40px;font-size:25px"> APPLICANTS: </div><div style="text-align:center;font-size:32px;padding-bottom:5px;">';
            if( opp.Applicant_1__c != null ){
                applicant1 = opp.Applicant_1__r.Name;
                fullName = applicant1;
            }
            if( opp.Applicant_2__c != null ){
                applicant2 = opp.Applicant_2__r.Name;	    
                fullName += ' and ' + applicant2; 
            }
            System.debug( fullName );
            htmlCode += fullName + '</div></div></div></div><div style="margin-top:50px;padding: 5px;padding-left: 50px;"><table style="width:90%;border-collapse: collapse;" ><tr><td style="width:10%; height: 60px; background: #e8f4ff;position: relative;"></td><td  style="width:15%; height: 60px;" class="only-bottom-border"></td><td style="width:40%;height: 60px; text-align:center;" class="only-bottom-border"><div style="font-size: 24px;">';
            if( applicant1 != null && applicant1.length() > 0 ){
                htmlCode += applicant1 ;
                if( applicant2 != null && applicant2.length() > 0 ){
                    htmlCode += '</div></td><td style="width:40%; height: 60px; text-align:center;" class="only-bottom-border"><div style="font-size: 24px;">' + applicant2 + '</div></td></tr>';
                }
                else{
                    htmlCode += '</div></td></tr>';
                }
            }
            Integer indx = 01; 
            List<Id> sequence = new List<Id>();
            Map<String, List<ContentVersion>> finalMap = new Map<String, List<ContentVersion>>();
            for(String cags: listDoc.keySet()){    
                if(listDoc.get(cags).size() > 0){
                    List<ContentVersion> detail = listDoc.get(cags); 
                    List<ContentVersion> seq = new List<ContentVersion>();
                    if( applicant2 != null && applicant2.length() > 0 ){
                        htmlCode += '<tr><td style="width:10%; height: 100px; background: #e8f4ff;position: relative;border: none;"><div style="position: absolute; margin-left: 25px;font-size: 50px; font-weight: 800;margin-top: -27px;">0' + indx + '</div></td><td class="only-bottom-border"  style="width:15%; height: 100px; color: #324458; font-size: 10px; text-align: left;padding-left: 20px; "><div style="font-size: 20px; font-weight: 600;">' + cags + '</div></td><td class="only-bottom-border" style="width:40%; height: 100px; text-align:center;"><div style="font-size:16px;">';
                        for(ContentVersion c: detail){
                            if(c.Related__c == app1Name || c.Related__c == 'General'){
                                htmlCode += c.Title.substringBefore('(') + '<br>';
                                seq.add(c);
                            }
                        }
                        htmlCode += '</div></td><td class="only-bottom-border" style="width:40%; height: 100px; text-align:center;"><div style="font-size:16px;">';
                        for(ContentVersion c: detail){
                            if(c.Related__c == app2Name){
                                htmlCode += c.Title.substringBefore('(') + '<br>';
                                seq.add(c);
                            }
                        }
                        htmlCode += '</div></td></tr>';
                    }
                    else{
                        htmlCode += '<tr><td style="width:10%; height: 100px; background: #e8f4ff;position: relative;border: none;"><div style="position: absolute; margin-left: 25px;font-size: 50px; font-weight: 800;margin-top: -27px;">0' + indx + '</div></td><td class="only-bottom-border"  style="width:15%; height: 100px; color: #324458; font-size: 10px; text-align: left;padding-left: 20px; "><div style="font-size: 20px; font-weight: 600;">' + cags + '</div></td><td class="only-bottom-border" style="width:40%; height: 100px; text-align:center;"><div style="font-size:14px;">';
                        for(ContentVersion c: detail){
                            if(c.Related__c == app1Name || c.Related__c == 'General'){
                                htmlCode += c.Title.substringBefore('(') + '<br>';
                                seq.add(c);
                            }
                        }
                        htmlCode += '</div></td></tr>';
                    }
                    indx++;
                    finalMap.put(cags,seq);
                }
            }
            htmlCode += '</table></div></body></html>';
            Map<String, String> options = new Map<String, String>();
            options.put('marginBottom', '0');
            options.put('marginLeft', '0');
            options.put('marginTop', '0');
            options.put('marginRight', '0');
            Api2PdfClient a2pClient = new Api2PdfClient('258fd109-1401-4ffe-b2ac-78d6b8db8f5b');
            Api2PdfResponse response = a2pClient.wkhtmlToPdfFromHtml(htmlCode, false, 'Gen.pdf',options);
            String fpage = response.getPdf();
            System.debug(fpage);
            urls.add(fpage);
            
            String middlePage = '<html><head><title></title><style type="text/css"> @page {margin-left: 0cm; margin-right: 0cm; margin-top: 220px; margin-bottom: 0cm; size:A4 portrait; @top-left {content: element(header); } @bottom-left {content: element(footer); } } .container {position: relative; font-family: Helvetica; z-index:1; } .text-block {position: absolute; top: 30px; left: 60px; font-size: 40px; width:500px; color: white; z-index:2; font-weight: bold; font-family: Calibri; } div.header {position: running(header); width: 100%; margin-right: 1px; } div.footer {width:100%;height:80px;position:absolute;content : "My Footer on right Side";bottom:0;left:0;background:#ee5; display: block; padding: 5px; position: running(footer); } .logo {position: absolute; top: 40px; right: 60px; } .logo img{width: 200px; } body {margin: 0px ; font-family: Calibri; } .font-family{font-family:Arial, Helvetica, sans-serif;; } .only-bottom-border {border-style: solid; border-left: none; border-right: none; border-top: none; } </style></head><body><div class="font-family"><div class="container header"><div style="text-align:left;margin-top: 50px;margin-left: 46px;"><div style="text-align:left;font-size:20px"> SUPPORTING DOCUMENTS FOR:<br><div style="font-size: 20px; font-weight: 600;margin-top: 10px;">' + fullName + '</div></div></div><div class="logo" style="margin-top: -30px; "><img src="https://lanecorp--teamindi--c.documentforce.com/servlet/servlet.ImageServer?id=0159D0000006HVl&oid=00D9D0000008cJz&lastMod=1582717129000"></div></div></div><hr width="92%" style="border: 2px solid;"><div style="margin-top: 100px;"><div style="text-align:left;font-size:200px;font-weight: 600;color:  #2B3856;font-family: calibri;margin-left: 46px;">';
            Integer findx = 01;
            for(String cags: finalMap.keySet()){
                String cpymidd = middlePage;
                cpymidd += '0' + findx + '<br>' + cags + '</div></div></body></html>';
                findx++;                    
                Api2PdfResponse midresp = a2pClient.wkhtmlToPdfFromHtml(cpymidd, false, 'mid.pdf');
                String mpage = midresp.getPdf();
                System.debug(mpage);
                urls.add(mpage);
                List<ContentVersion> detail = finalMap.get(cags); 
                for(ContentVersion c: detail){
                    for(ContentDistribution cd: distributionsToInsert){
                        if(cd.ContentVersionId == c.Id){
                            if(c.fileType =='pdf' || c.fileType == 'WORD_X' || c.fileType == 'EXCEL_X' || c.fileType == 'EXCEL'){
                                urls.add(cd.PdfDownloadUrl);
                                break;
                            }
                            else{
                                Api2PdfResponse pdfResponse = a2pClient.libreofficeConvert(cd.ContentDownloadUrl, false, + 'pag.pdf');
                                String pdfUrl = pdfResponse.getPdf();
                                System.debug(pdfUrl);
                                urls.add(pdfUrl);
                                break;
                            }
                        }
                    }
                }
            }
            Datetime cDT = System.now();
            Api2PdfResponse pdfResponse = a2pClient.mergePdf(urls, true,'Application Pack_' + fullName + '_' + cDT.format() + '.pdf');
            String pdfUrlf = pdfResponse.getPdf();
            System.debug(pdfUrlf);
            System.debug(pdfResponse.getSuccess());
            System.debug(pdfResponse.getError());
            return pdfUrlf;
        }
    }
    
    
    @AuraEnabled
    public static getDocsWrapper getFundingDocs(String recordIdStr){
        Id recordId = (Id)recordIdStr;
        Opportunity opp;
        Funding_Request__c request = [SELECT Id,Opportunity__c FROM Funding_Request__c WHERE Id=: recordId];
        List<ContentDocumentLink> cntList = new List<ContentDocumentLink>();
        if(request != null && request.Opportunity__c != null){
            opp = [SELECT Id,Name FROM Opportunity WHERE Id =: request.Opportunity__c];
            cntList = [SELECT ContentDocument.LatestPublishedVersionId, LinkedEntityId, ContentDocumentId
                       FROM ContentDocumentLink WHERE LinkedEntityId =: opp.Id];
        }
        Set<Id> cntVersionIds = new Set<Id>();
        List<ContentVersion> cvList = new List<ContentVersion>();
        if(!cntList.isEmpty()){
            for(ContentDocumentLink cnt: cntList){            
                cntVersionIds.add(cnt.ContentDocument.LatestPublishedVersionId );
            }
            if(!cntVersionIds.isEmpty()){
                cvList  = [SELECT Id,related__c, Category__c,Current_in_use__c, Title, FileExtension, Description, ContentModifiedDate, CreatedDate, ContentSize, ContentDocumentId 
                           FROM ContentVersion WHERE Id IN :cntVersionIds AND (Category__c = 'Purchase Invoice' OR Category__c  = 'Lender Credit Contract')];
            }
        }
        getDocsWrapper ret = new getDocsWrapper();
        ret.cvListt = cvList;
        ret.oppp = opp;
        return ret;
    }
    
      public class getDocsWrapper{
        @AuraEnabled public List<ContentVersion> cvListt;
        @AuraEnabled public Opportunity oppp;
    }
}