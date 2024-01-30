public without sharing class DocuSignRESTUtility {

    //Get Rest Configuration Setings from Custom Metadata provided as a part of the installation source 
    private static Map<String, DocuSignRESTSettings__mdt> settingsMap { 
        //Getter Method
        get {
            //populate only if settingsMap is null
            if (settingsMap == null) {
                settingsMap = new Map<String, DocuSignRESTSettings__mdt>();
                //Query the Custom Metadata and add it to the Map
                //Query against Custom Metadata does not count against the SOQL query Limit
                for (DocuSignRESTSettings__mdt setting : [Select DeveloperName,MasterLabel, Value__c from DocuSignRESTSettings__mdt]) {
                    settingsMap.put(setting.MasterLabel, setting);
                }
            }
            return settingsMap;
        }
        //Blank Setter Method
        set {
        }
    }

    //This method will call the DocuSignJWT class to obtain an access token from DocuSign
    public static String getAccessToken() {
        String access_token = null;
        
        //Instantiate a request object
        HttpRequest req = new HttpRequest();
        //set the request METHOD
        req.setMethod('POST');
        
        //set the request endpoint
        String authendpoint = settingsMap.get('RequestAuthEndpoint').Value__c;
        System.Debug(LoggingLevel.INFO, '**RequestAuthEndpoint' + authendpoint);
        req.setEndPoint(authendpoint);

        //set the request headers
        //1. Content -type
        String authRequestContentType = settingsMap.get('RequestAuthContentType').Value__c;
        System.Debug(LoggingLevel.INFO, '**authRequestContentType ' + authRequestContentType);
        req.setHeader('Content-type', authRequestContentType);

        //2. Host
        String authRequestDomain = settingsMap.get('RequestAuthDomain').Value__c;
        System.Debug(LoggingLevel.INFO, '**authRequestDomain ' + authRequestDomain);
        req.setHeader('Host', authRequestDomain);

        //Body of the request
        String alg = 'RS256';
        String iss = settingsMap.get('RequestIntegratorKey').Value__c;
        String pkey = settingsMap.get('RequestPrivateKey').Value__c;
        String scope = settingsMap.get('RequestScope').Value__c;
        DocusignJWT jwtObject = new DocusignJWT(alg, settingsMap.get('DSUserName').Value__c, iss, pkey, scope, authRequestDomain);
        
        //Set the request body  
        String requestBody = settingsMap.get('RequestAuthBody').Value__c + jwtObject .issue();
        System.Debug(LoggingLevel.INFO, '**RequestAuthBody' + requestBody);
        req.setBody(requestBody);

        //call the service
        Http http = new Http();
        HTTPResponse res;
        
        //Obtain the access token from the Response
        if(!Test.isRunningTest()){
            res = http.send(req);
            //System.Debug(LoggingLevel.INFO, '**ResponseAuthBody' + res.getbody());
            //System.Debug(LoggingLevel.INFO, '**ResponseAuth' + res);
            if (res.getStatusCode() == 200) {
                System.JSONParser parser = System.JSON.createParser(res.getBody());
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                        parser.nextToken();
                        access_token = parser.getText();
                        break;
                    }
                }
            }
        }else{
            String jsonBody = '{"access_token":"eyJ0eXAiOiJNVCIsImFsZyI6IlJTMjU2Iiwia2lkIjoiNjgxODVmZjEtNGU1MS00Y2U5LWFmMWMtNjg5ODEyMjAzMzE3In0.AQkAAAABAAUABwCA7tlMqivXSAgAgFaerrIr10gCAI70STvrcK1FgGthGl8yUawVAAEAAAAYAAEAAAAFAAAADQAkAAAAYzE5NTE3MTgtZDhjOC00ZjIyLTkyOTEtMGVmMTcyODE4NDQ0IwAkAAAAYzE5NTE3MTgtZDhjOC00ZjIyLTkyOTEtMGVmMTcyODE4NDQ0EgABAAAABgAAAGp3dF9icg.ACUvBWRXv3o28ghDXv9WiTFaxfUXV644rjXRNZtbrFEvMCYXJODdP7WHrDE-fF1kgURbntmGxJaEX8tkjnMPSqztkg0xLZDkRMOlgkgWrYRj27LqBITDbhyxT8yqJyhZ45zGBKASYI8xBrGJ1YYqAT87rM21FUxeo6LyZlREfjjGg9aHXOM9jX0NtQN7eorcj90QtmYikOZQLZDy2IsHHr-VR3xBbzfgJfqJQy-xBNRYTLmrw1Nf2Ak1pHMYbxZ6YfqwFHtXz7iMBzToRb-kuOHlvThE_CG1lFDZl-BFRmW_iY16Kx5pdPV1n9Xk-ISDGlTCJ6sWeeRG-kDy3Zw14A","token_type":"Bearer","expires_in":3600}';
            System.JSONParser parser = System.JSON.createParser(jsonBody);
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                    parser.nextToken();
                    access_token = parser.getText();
                    break;
                }
            }
        }
        
        return access_token;

    }
    
    @AuraEnabled
    public static String makeCallout(String oppId){
        createEnvelope(oppId);
        return 'Success';
    }
    
    //This method will invoke the outbound REST call to the Docusign API for creating the envelope
    public static void createEnvelope(String recordId) {
        
        Opportunity opp = [SELECT Applicant_1__r.Name, Applicant_1__r.LastName, Applicant_2__r.LastName, Applicant_1__r.PersonEmail, Applicant_2__r.Name, Applicant_2__r.PersonEmail,
                            (Select Customer_Amount__c,Product__r.Name,Purpose__c,Brokerage_Amount__c
                            From Quotes where Application__c = true)
                   FROM Opportunity WHERE Id =: recordId limit 1][0];
        //Get the access token
        String accessToken = getAccessToken();
        System.Debug(LoggingLevel.INFO, '***accessToken ' + accessToken);

        //Call envelope Creation service if a non-empty access token is returned
        if (!String.isEmpty(accessToken)) {
            //instantiate an Http instance  
            Http httpProtocol = new Http();

            //instantiate an HttpRequest instance  
            HttpRequest request = new HttpRequest();

            //Set the request parameters 
            // Request endpoint for createEnvelope call
            String endpoint = settingsMap.get('RequestEnvelopeEndpoint').Value__c + settingsMap.get('DSAccountID').Value__c + '/envelopes';
            System.Debug(LoggingLevel.INFO, '***endpoint ' + endpoint);
            request.setEndPoint(endpoint);

            //set the POST method
            request.setMethod('POST');

            //set Authentication Header
            request.setHeader('grant_type', 'Bearer');
            request.setHeader('Authorization', 'Bearer ' + accessToken);

            //set Accept Header
            request.setHeader('Accept', 'application/json');

            //set Content Type Header
            request.setHeader('Content-type', 'application/json');
            
            //create the request Body
            PageReference pdf = Page.SaveAndOpenApplicaton;
            pdf.getParameters().put('id',recordId);
            pdf.setRedirect(true);
            String bPDF;
            if(Test.isRunningTest()){
                bPDF = EncodingUtil.base64Encode(Blob.valueOf('Unit Test Body'));
            }else{
                bPDF = EncodingUtil.base64Encode(pdf.getContentaspdf());
            }
            
            String pdfName = 'Credit Proposal '+opp.Applicant_1__r.LastName;
            if(opp.Applicant_2__r.LastName != '')
                pdfName = pdfName+' & '+opp.Applicant_2__r.LastName;
            
            pdfName = pdfName+' '+opp.Quotes[0].Product__r.Name+', '+opp.Quotes[0].Customer_Amount__c+', '+String.valueof(Datetime.now())+'.pdf';
            
            String subject = opp.Quotes[0].Purpose__c+' Loan Documents For Your e-Signature';
            
            String newBody = '{'
                                  +'"status": "sent",'
                                  +'"emailSubject": "'+subject+'",'
                                  +'"customFields": {'
                                        +'"textCustomFields": ['
                                            +'{'
                                                +'"name": "##SFOpportunity",'
                                                +'"value": "'+recordId+'",'
                                                +'"show": "false"'
                                            +'}'
                                        +']'
                                    +'},'
                                  +'"documents": [{'
                                    +'"documentId": "1",'
                                    +'"name": "'+pdfName+'",'
                                    +'"documentBase64": "'+bPDF+'",'
                                  +'}],'
                                  +'"recipients": {'
                                    +'"signers": [{'
                                      +'"name": "'+opp.Applicant_1__r.Name+'",'
                                      +'"email": "'+opp.Applicant_1__r.PersonEmail+'",'
                                      +'"recipientId": "1",'
                                      +'"routingOrder": "1",'
                                      +'"tabs": {'
                                        +'"signHereTabs": [{'
                                          +'"xPosition": "150",'
                                          +'"yPosition": "100",'
                                          +'"documentId": "1",'
                                          +'"pageNumber": "5"'
                                        +'}';
                                        if(opp.Quotes[0].Brokerage_Amount__c > 0){
                                            newbody = newbody +',{'
                                              +'"xPosition": "150",'
                                              +'"yPosition": "440",'
                                              +'"documentId": "1",'
                                              +'"pageNumber": "6"'
                                            +'}';
                                        }
                                        newbody = newbody +']'
                                      +'}'
                                    +'}';
                                    if(opp.Applicant_2__r.Name != null){
                                        newbody = newbody +',{'
                                          +'"name": "'+opp.Applicant_2__r.Name+'",'
                                          +'"email": "'+opp.Applicant_2__r.PersonEmail+'",'
                                          +'"recipientId": "2",'
                                          +'"routingOrder": "1",'
                                          +'"tabs": {'
                                            +'"signHereTabs": [{'
                                              +'"xPosition": "410",'
                                              +'"yPosition": "100",'
                                              +'"documentId": "1",'
                                              +'"pageNumber": "5"'
                                            +'}';
                                            if(opp.Quotes[0].Brokerage_Amount__c > 0){
                                                newbody = newbody +',{'
                                                  +'"xPosition": "410",'
                                                  +'"yPosition": "440",'
                                                  +'"documentId": "1",'
                                                  +'"pageNumber": "6"'
                                                +'}';
                                            }
                                            newbody = newbody +']'
                                        +'}'
                                        +'}';
                                    }
                                  newbody = newbody +']'
                                                  +'},'
                                                  +'"notification": {'
                                                        +'"useAccountDefaults": "false",'
                                                        +'"reminders": {'
                                                            +'"reminderEnabled": "true",'
                                                            +'"reminderDelay": "1",'
                                                            +'"reminderFrequency": "1"'
                                                        +'},'
                                                        +'"expirations": {'
                                                            +'"expireEnabled": "true",'
                                                            +'"expireAfter": "250",'
                                                            +'"expireWarn": "5"'
                                                        +'}'
                                                    +'}'
                                                +'}';
            //create instance of the EnvelopeCreationRequest class
            DocuSignRESTUtility.EnvelopeCreationRequest requestObject = new DocuSignRESTUtility.EnvelopeCreationRequest();
            requestObject.status = settingsMap.get('RequestEnvelopeStatus').Value__c;
            requestObject.emailSubject = settingsMap.get('RequestEnvelopeSubject').Value__c;
            //requestObject.templateId = settingsMap.get('RequestEnvelopeTemplateID').Value__c;

            System.Debug(LoggingLevel.INFO, '***requestObject() ' + requestObject);
            String jsonBody = json.serialize(requestObject);
            System.Debug(LoggingLevel.INFO, '***jsonBody() ' + jsonBody);
            System.Debug(LoggingLevel.INFO, '***newBody() ' + newBody);
            //request.setBody(jsonBody);
            request.setBody(newBody);
            //Make the request and capture the response
            HttpResponse response;
            if(!Test.isRunningTest()){
                response = httpProtocol.send(request);
            }
            //System.Debug(LoggingLevel.INFO, '***response.getBody() ' + response.getBody());
            //System.debug(LoggingLevel.INFO, '***response.getStatus() ' + response.getStatus());
            
            //Parse the response
            /*String responseStatus = response.getStatus();
            if (responseStatus.equals('Created')) {
                DocuSignRESTUtility.EnvelopeCreationResponse responseObject = new DocuSignRESTUtility.EnvelopeCreationResponse();
                responseObject = (DocuSignRESTUtility.EnvelopeCreationResponse)System.JSON.deserialize(response.getBody(), DocuSignRESTUtility.EnvelopeCreationResponse.class);
                System.Debug(LoggingLevel.INFO, '***responseObject ' + responseObject);
            }*/
        }
    }
    
    //This method will invoke the outbound REST call to the Docusign API for creating the envelope
    public static void createEnvelopeForAccount(String recordId) {
        
        Account acc = [SELECT Id, Name, Company_Legal_Name__c,
                            (Select Id, Name, FirstName, LastName, Email, Is_Authorised_Signatory__c
                            From Contacts where Is_Authorised_Signatory__c = true)
                   FROM Account WHERE Id =: recordId limit 1][0];
        //Get the access token
        String accessToken = getAccessToken();
        System.Debug(LoggingLevel.INFO, '***accessToken ' + accessToken);

        //Call envelope Creation service if a non-empty access token is returned
        if (!String.isEmpty(accessToken)) {
            //instantiate an Http instance  
            Http httpProtocol = new Http();

            //instantiate an HttpRequest instance  
            HttpRequest request = new HttpRequest();

            //Set the request parameters 
            // Request endpoint for createEnvelope call
            String endpoint = settingsMap.get('RequestEnvelopeEndpoint').Value__c + settingsMap.get('DSAccountID').Value__c + '/envelopes';
            System.Debug(LoggingLevel.INFO, '***endpoint ' + endpoint);
            request.setEndPoint(endpoint);

            //set the POST method
            request.setMethod('POST');

            //set Authentication Header
            request.setHeader('grant_type', 'Bearer');
            request.setHeader('Authorization', 'Bearer ' + accessToken);

            //set Accept Header
            request.setHeader('Accept', 'application/json');

            //set Content Type Header
            request.setHeader('Content-type', 'application/json');
            
            //create the request Body
            PageReference pdf = Page.ReferrerOnboardingFormPDF;
            pdf.getParameters().put('id',recordId);
            pdf.setRedirect(true);
            String bPDF;
            if(Test.isRunningTest()){
                bPDF = EncodingUtil.base64Encode(Blob.valueOf('Unit Test Body'));
            }else{
                bPDF = EncodingUtil.base64Encode(pdf.getContentaspdf());
            }
            
            String pdfName = 'Referral Agreement '+acc.Company_Legal_Name__c+'.pdf';
            
            String subject = 'Short Form Referral Agreement for your e-Signature';
            
            String plainBody = 'Welcome!\n\n'
                               +'We are thrilled that you have decided to help your customers with low-rate payment options for your products and services.\n\n'
                               +'The advent of the National Consumer Credit Protection Act 2009 has required that we have a formal agreement in place to detail our obligations in respect of referring customers for finance.\n\n'
                               +'This non-exclusive agreement simply explains how to refer customers and the things you should avoid discussing.\n\n'
                               +'Thank you and we look forward to a prosperous partnership.\n\n'
                               +'Yours faithfully,\n\n'
                               +'The Parker Lane Team';
            
            String newBody = '{'
                                  +'"status": "sent",'
                                  +'"emailSubject": "'+subject+'",'
                                  +'"customFields": {'
                                        +'"textCustomFields": ['
                                            +'{'
                                                +'"name": "##SFAccount",'
                                                +'"value": "'+recordId+'",'
                                                +'"show": "false"'
                                            +'}'
                                        +']'
                                    +'},'
                                  +'"documents": [{'
                                    +'"documentId": "1",'
                                    +'"name": "'+pdfName+'",'
                                    +'"documentBase64": "'+bPDF+'",'
                                  +'}],'
                                  +'"recipients": {'
                                    +'"signers": [{'
                                      +'"name": "'+acc.Contacts[0].Name+'",'
                                      +'"email": "'+acc.Contacts[0].Email+'",'
                                      +'"recipientId": "1",'
                                      +'"routingOrder": "1",'
                                      +'"emailNotification": {'
                                       +'"emailSubject": "Short Form Referral Agreement for your e-Signature",'
                                       +'"emailBody": "'+plainBody+'"'
                                      +'},'
                                      +'"tabs": {'
                                        +'"signHereTabs": [{'
                                          +'"xPosition": "380",'
                                          +'"yPosition": "548",'
                                          +'"documentId": "1",'
                                          +'"pageNumber": "1"'
                                        +'}]'
                                      +'}'
                                    +'}]'
                                  +'},'
                                  +'"notification": {'
                                        +'"useAccountDefaults": "false",'
                                        +'"reminders": {'
                                            +'"reminderEnabled": "true",'
                                            +'"reminderDelay": "1",'
                                            +'"reminderFrequency": "1"'
                                        +'},'
                                        +'"expirations": {'
                                            +'"expireEnabled": "true",'
                                            +'"expireAfter": "250",'
                                            +'"expireWarn": "5"'
                                        +'}'
                                    +'}'
                                +'}';
            //create instance of the EnvelopeCreationRequest class
            DocuSignRESTUtility.EnvelopeCreationRequest requestObject = new DocuSignRESTUtility.EnvelopeCreationRequest();
            requestObject.status = settingsMap.get('RequestEnvelopeStatus').Value__c;
            requestObject.emailSubject = settingsMap.get('RequestEnvelopeSubject').Value__c;
            //requestObject.templateId = settingsMap.get('RequestEnvelopeTemplateID').Value__c;

            //System.Debug(LoggingLevel.INFO, '***requestObject() ' + requestObject);
            String jsonBody = json.serialize(requestObject);
            System.Debug(LoggingLevel.INFO, '***jsonBody() ' + jsonBody);
            System.Debug(LoggingLevel.INFO, '***newBody() ' + newBody);
            //request.setBody(jsonBody);
            request.setBody(newBody);
            //Make the request and capture the response
            HttpResponse response;
            if(!Test.isRunningTest()){
                response = httpProtocol.send(request);
            }
            //System.Debug(LoggingLevel.INFO, '***response.getBody() ' + response.getBody());
            //System.debug(LoggingLevel.INFO, '***response.getStatus() ' + response.getStatus());
            
            //Parse the response
            /*String responseStatus = response.getStatus();
            if (responseStatus.equals('Created')) {
                DocuSignRESTUtility.EnvelopeCreationResponse responseObject = new DocuSignRESTUtility.EnvelopeCreationResponse();
                responseObject = (DocuSignRESTUtility.EnvelopeCreationResponse)System.JSON.deserialize(response.getBody(), DocuSignRESTUtility.EnvelopeCreationResponse.class);
                System.Debug(LoggingLevel.INFO, '***responseObject ' + responseObject);
            }*/
        }
    }
    
    //This method will invoke the outbound REST call to the Docusign API to void the envelope
    @future(callout=true)
    public static void voidEnvelope(String recordId) {
        
        List<dsfs__DocuSign_Status__c> dsList = [Select dsfs__Opportunity__c,dsfs__Envelope_Status__c,dsfs__DocuSign_Envelope_ID__c
                            From dsfs__DocuSign_Status__c where dsfs__Opportunity__c =: recordId AND dsfs__Envelope_Status__c != 'Completed'];
        //Get the access token
        String accessToken = getAccessToken();
        System.Debug(LoggingLevel.INFO, '***accessToken ' + accessToken);

        //Call envelope Creation service if a non-empty access token is returned
        if (!String.isEmpty(accessToken)) {
            if(dsList.size() > 0){
                for(dsfs__DocuSign_Status__c ds : dsList){
                    //instantiate an Http instance  
                    Http httpProtocol = new Http();
        
                    //instantiate an HttpRequest instance  
                    HttpRequest request = new HttpRequest();
        
                    //Set the request parameters 
                    // Request endpoint for createEnvelope call
                    String endpoint = settingsMap.get('RequestEnvelopeEndpoint').Value__c + settingsMap.get('DSAccountID').Value__c + '/envelopes/'+ds.dsfs__DocuSign_Envelope_ID__c;
                    System.Debug(LoggingLevel.INFO, '***endpoint ' + endpoint);
                    request.setEndPoint(endpoint);
        
                    //set the POST method
                    request.setMethod('PUT');
        
                    //set Authentication Header
                    request.setHeader('grant_type', 'Bearer');
                    request.setHeader('Authorization', 'Bearer ' + accessToken);
        
                    //set Accept Header
                    request.setHeader('Accept', 'application/json');
        
                    //set Content Type Header
                    request.setHeader('Content-type', 'application/json');
                    
                    String newBody = '{'
                                          +'"status": "voided",'
                                          +'"voidedReason": "Opportunity is closed lost"'
                                        +'}';
                    //create instance of the EnvelopeCreationRequest class
                    DocuSignRESTUtility.EnvelopeCreationRequest requestObject = new DocuSignRESTUtility.EnvelopeCreationRequest();
                    requestObject.status = settingsMap.get('RequestEnvelopeStatus').Value__c;
                    requestObject.emailSubject = settingsMap.get('RequestEnvelopeSubject').Value__c;
                    //requestObject.templateId = settingsMap.get('RequestEnvelopeTemplateID').Value__c;
        
                    //System.Debug(LoggingLevel.INFO, '***requestObject() ' + requestObject);
                    String jsonBody = json.serialize(requestObject);
                    System.Debug(LoggingLevel.INFO, '***jsonBody() ' + jsonBody);
                    System.Debug(LoggingLevel.INFO, '***newBody() ' + newBody);
                    //request.setBody(jsonBody);
                    request.setBody(newBody);
                    //Make the request and capture the response
                    HttpResponse response;
                    if(!Test.isRunningTest()){
                        response = httpProtocol.send(request);
                    }
                    //System.Debug(LoggingLevel.INFO, '***response.getBody() ' + response.getBody());
                    //System.debug(LoggingLevel.INFO, '***response.getStatus() ' + response.getStatus());
                }
            }
        }
    }
    
    //wrapper class for Envelope Creation Request
    //This class can be further re-vamped to create complex Envelopes to be passed to the createEnvelope Service
    //For more information refer https://developers.docusign.com/esign-rest-api/reference/Envelopes/Envelopes/create
    public class EnvelopeCreationRequest {
        public String emailSubject { get; set; }
        public String status { get; set; }
        public List<DocumentCreation> documents{get;set;}
        //public String templateId { get; set; }
    }
    
    //Wrapper class for Document creation
    public class DocumentCreation{
        public String documentId { get; set; }
        public String name { get; set; }
        public String documentBase64 { get; set; }
    }
    
    //wrapper class for Envelope Creation Response
    public class EnvelopeCreationResponse {
        public String envelopeId { get; set; }
        public String uri { get; set; }
        public String status { get; set; }
        public String statusDateTime { get; set; }
    }

}