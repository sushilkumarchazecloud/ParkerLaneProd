public class EzeeAPIWithDoc {
    
    public static  List<ContentVersion> cvList{get; set;}
    
    @AuraEnabled
    public static string makeCallout(string OppId){
        try{
        	string ress = EzeeAPIController.makeCallout(OppId, 'full');
            if(ress == 'success'){
            	return 'success';
            }
            else{
                return 'Error : Please review information';
            }
            
        }catch(Exception ex){
            Exception__c eror = new Exception__c();
            eror.Class_Name__c = 'ZEAL CALLOUT';
            eror.Method_Name__c = 'Make Callout';
            eror.Error_Message__c = ex.getMessage() + '' + ex.getLineNumber();
            eror.opportunity__c = OppId;
            insert eror;
            return eror.Name;
        }
    }
    
    @AuraEnabled
    public static string uploadDocu(string OppId){
        try{ 
           string msg = SendDocs(OppId);
            System.debug('msgmsg+++'+msg);
            return msg;
        }Catch(Exception ex){
            Exception__c eror = new Exception__c();
            eror.Class_Name__c = 'ZEAL DOC CALLOUT';
            eror.Method_Name__c = 'Make Callout';
            eror.Error_Message__c = ex.getMessage() + '' + ex.getLineNumber();
            eror.opportunity__c = OppId;
            insert eror;
            return 'Error';
        }
    }
    
    public static string SendDocs(string oppId){
        opportunity opp = [Select Id, name,Lender_Application_ID__c from opportunity WHERE id =: oppId LIMIT 1];
        
        List<ContentDocumentLink> cdl = [SELECT ContentDocument.LatestPublishedVersionId, LinkedEntityId, ContentDocumentId
                                       FROM ContentDocumentLink WHERE LinkedEntityId =: opp.id];
        List<ID> vId = new List<ID>();
        for(ContentDocumentLink a: cdl){            
            vId.add(a.ContentDocument.LatestPublishedVersionId);
        }
        
        cvList = [Select Id,Category__c,VersionData,title,FileExtension from ContentVersion WHERE id IN: vId AND Send_to_Lender__c = true];
        string body = '{'+
            '"source": "TMCU",'+
            '"data": {'+
            '"main": {'+
            '"documents":[';
        
        for(integer i=0; i<cvList.size(); i++){
            string filename = cvList[i].Title +'.'+cvList[i].FileExtension; 
            if(cvList[i].Category__c == 'Identification'){
                body += '{'+
                    '"fileContent": "'+EncodingUtil.base64Encode(cvList[i].VersionData)+'",'+
                    '"fileName": "'+filename+'",'+
                    '"category":"Document Upload",'+
                    '"subCategory":"Photo ID"'+
                    '}';
                if(i != cvList.size()-1)
                    body += ',';
            }
            else if(cvList[i].Category__c == 'Credit Report'){
                body += '{'+
                    '"fileContent": "'+EncodingUtil.base64Encode(cvList[i].VersionData)+'",'+
                    '"fileName": "'+filename+'",'+
                    '"category":"Document Upload",'+
                    '"subCategory":"Others"'+
                    '}';
                if(i != cvList.size()-1)
                    body += ',';
            }
            else{
                body += '{'+
                    '"fileContent": "'+EncodingUtil.base64Encode(cvList[i].VersionData)+'",'+
                    '"fileName": "'+filename+'",'+
                    '"category":"Document Upload",'+
                    '"subCategory":"3 months bank statements"'+
                    '}';
                if(i != cvList.size()-1)
                    body += ',';
            }
        }
        body += ']'+
            '}'+
            '}'+
            '}';
        
        System.debug('body++'+body);
        
        string res = makCallout(body, opp.Lender_Application_ID__c);
        System.debug('resres++'+res);
        if(res.contains('Error')){
            return 'Error : Document Not Uploaded!';
        }
        else{
            return 'success';    
        }
    }
    
    
    
    public static string makCallout(string body, string appId){
        System.debug('body+++'+body);
        System.debug('appId+++'+appId);
        String endpoint =  'https://marketplace.ezee.ai/ezeeapi/tmcu/lending/submission/1.0.0/GNL_1f3l7f558/submissions/' + appId;
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(body);
        req.setHeader('accept', '*/*');
        req.setHeader('clientId','dca5ee1d6cfc412');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
        req.setHeader('Authorization', 'Basic dG1jdTpUbUN1I3dzbzIjMjAyMQ==');
        System.debug('req--==-=-'+req);
        Http http = new Http();
        HTTPResponse res;
        
        res = http.send(req);
        System.debug('response+++++ '+res.getBody()); 
        
        if(res.getStatusCode() !=200)
        {	
            return 'Error';
        }
        System.debug(string.valueOf(res).contains('Error'));
        if(string.valueOf(res).contains('Error')){
            return 'Error';
        }
        System.debug('res.getBody()'+res.getBody());
        
        return 'success';
    }
    
}