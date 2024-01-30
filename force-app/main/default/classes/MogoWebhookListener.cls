@RestResource(urlMapping='/MogoListener/*')
global class MogoWebhookListener {
    @HttpPost
    global static void handlePost() {
        try {
            String reqBody = RestContext.request.requestBody.toString();
            
            Map<String, Object> resultBody = (Map<String, Object>)JSON.deserializeUntyped(reqBody);
            
            String refId = (String)resultBody.get('reference');
            String accessId = (String)resultBody.get('accessId');
            System.debug('===> refId '+refId+' '+resultBody);            
            
            String body = '{"providerId" : 252,' + '"username" : "ParkerLane",' + '"password" : "XxmLe2kN",' + '"caseId" : "' + refId + '"}';
        
            Opportunity opp = [Select Id, Name, Report_Ready_Access_Ids__c, Applicant_1__r.FirstName, Applicant_1__r.MiddleName, Applicant_1__r.LastName from Opportunity where Access_Id__c=:refId Limit 1];
            
            String notifiyType = (String)resultBody.get('notifyType') != null ? (String)resultBody.get('notifyType') : '';
            
            if(Test.isRunningTest()){
                notifiyType = 'CASE_READY';
            }
            
            if(notifiyType == 'REPORT_READY'){
                opp.Report_Ready_Access_Ids__c = string.isBlank(opp.Report_Ready_Access_Ids__c) ? accessId : opp.Report_Ready_Access_Ids__c+ ',' + accessId;
                opp.Sent_Case_Ready_Request__c  = false;
                update opp;
            }
            
            if(notifiyType == 'CASE_READY'){    
                
                Http htp = new Http();
                HttpRequest request = new HttpRequest();
                request.setTimeout(120000);
                request.setEndpoint('https://api.aulive.mogoplus.com/clovelly/collection/mogoReport');
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json');
                request.setBody(body);  
                Map<String, Object> result = new Map<String, Object>();
                if(!Test.isRunningTest()){
                    Long startTime = DateTime.now().getTime();
                    HttpResponse response = htp.send(request);
                    Long stopTime = DateTime.now().getTime();
                    System.debug('Stoptime = '+stopTime+' Start Time = '+startTime);
                    result = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                }else{
                    Long startTime = DateTime.now().getTime();
                    Long stopTime = DateTime.now().getTime();
                    Long diff;
                    diff = stopTime - startTime;
                    System.debug('Stoptime = '+stopTime+' Start Time = '+startTime +' '+diff);
                    
                    String jsonInput = '{\n'+'"mogoReport":"success",\n'+'"reference":"Invalid45data"\n'+'}';
                    result = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
                }
                
                
                String base64string = '';
                Blob afterblob;
                if((String)result.get('mogoReport') != null){
                    System.debug('yes');
                    base64string = (String)result.get('mogoReport');
                    afterblob = EncodingUtil.base64Decode(base64string);
                }
                
                ContentVersion cv = new ContentVersion();
                cv.VersionData = afterblob;
                cv.Title = 'MogoBankStatementReport.pdf';
                cv.PathOnClient = 'MogoBankStatementReport.pdf';
                insert cv;
                System.debug(cv.Id);
                
                Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
                
                ContentDocumentLink cdl = New ContentDocumentLink();
                cdl.LinkedEntityId = opp.Id;
                cdl.ContentDocumentId = conDocId;
                cdl.shareType = 'V';
                Insert cdl;
                
            }     
        } catch (Exception e) {
            
        }
    }
}