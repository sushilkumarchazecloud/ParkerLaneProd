public without sharing class LinkBankAccountController{
    //private static final String BASE_URL = 'https://secure.live.mogoplus.com/clovelly/application/createApplication';
    private static final String BASE_URL = 'https://api.aulive.mogoplus.com/clovelly/application/createApplication';
    @future
    public static void myFutureMethod(String aId, String oId)
    {  
        Opportunity opp = [Select Id, Access_Id__c from Opportunity where id=:oId Limit 1];
        opp.Access_Id__c = aId;
        update opp;
    }
    @auraEnabled
    public static String makeMOGORequest(String opId){

        List<Opportunity> opp = [Select Id, Access_Id__c, Name,Applicant_1__r.PersonContactId, Applicant_1__r.FirstName, Applicant_1__r.MiddleName, Applicant_1__r.LastName from Opportunity where id=: opId];

        Contact con = [SELECT Name, FinServ__CurrentEmployer__c, 
              FinServ__Occupation__c, FinServ__MaritalStatus__c, Email,
             (SELECT Id, Name, FinServ__EmploymentStatus__c, Total_Income_from_Employment__c,Is_Primary__c
              FROM FinServ__Employment__r WHERE Is_Primary__c = true LIMIT 1)
              FROM Contact WHERE Id =: opp[0].Applicant_1__r.PersonContactId];
              
        String body = '{'+'"providerId":252,'+'"username":"ParkerLane",'+'"password":"XxmLe2kN",'+'"reference":"'+opp[0].Id+'",'+'"productType":19,'+'"token":"98vc79095332",'+'"userData": {'+'"firstName":"'+opp[0].Applicant_1__r.FirstName+'",'+'"middleName":"'+opp[0].Applicant_1__r.MiddleName+'",'+'"lastName":"'+opp[0].Applicant_1__r.LastName+'",'+'"employerName":"'+con.FinServ__Employment__r[0].Name+'",'+'"employmentType":"F",'+'"income":[{"amount":"'+con.FinServ__Employment__r[0].Total_Income_from_Employment__c+'", "type":"Main", "code":"F"}]'+'}'+'}';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(BASE_URL);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(body);        
        Map<String, Object> result = new Map<String, Object>();
        if(!Test.isRunningTest()){
            HttpResponse response = http.send(request);
            result = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        }else{
            String jsonInput = '{\n'+'"hybridUrl":"102",\n'+'"reference":"Invalid45data"\n'+'}';
            result = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
        }
        System.debug(result);
        String url;

        if((String)result.get('hybridUrl') != null){
            url = (String)result.get('hybridUrl');
        }
        if((String)result.get('reference') != null){
            String apId = (String)result.get('reference');
            myFutureMethod(apId,opp[0].Id);
        }
        return url;
    }
    
    @auraEnabled
    public static void updateSection(String oppId){
        Opportunity opp = [select Id, name, Applicant_1__r.PersonContactId, Application_Sections__c, Current_Application_Sections__c, Applicant_1__r.Phone, Applicant_2__c, 
                           Applicant_2__r.PersonContactId, Applicant_2__r.Phone, Document_Redirect_URL__c 
                           FROM opportunity WHERE Id =: oppId];
        system.debug(opp);
        
        if(opp.Document_Redirect_URL__c.contains('/MogoDocument')){
            opp.Application_Sections__c = 'Mogo Document Upload';
            opp.Current_Application_Sections__c = 'Mogo Document Upload';
        }
        update opp;
    }    
}