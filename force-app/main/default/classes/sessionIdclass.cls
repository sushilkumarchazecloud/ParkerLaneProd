public without sharing class sessionIdclass {
    private final String clientId = System.Label.ClientId;
    private final String clientSecret = System.Label.ClientSecret;
    private final String username = System.Label.Username;
    private final String password = System.Label.PasswordSupportingDoc;
    private final String endPointUrl = System.Label.EndpointURL;
    public Boolean Active {get;set;}
    public Opportunity opp {get; set;}
    public String recIdfromSupportDoc = ApexPages.currentPage().getParameters().get('oppId');
    String partitionInput = 'local.CacheForOTP';
    Cache.SessionPartition sessionPartition;
    public String accessToken { get; set;}
    public static String contactId = ApexPages.currentPage().getParameters().get('id');
    public boolean SMS {get; set;}
    public static boolean sessionCheck {get; set;}
    public static contact setCon {get; set;}
    public long interval{get;set;}
    public sessionIdclass(ApexPages.StandardController controller){
        
    }
    
    public Boolean init{
        get{
            //getSessionPartOnLoad();        
            return false;
        }
    }
    
    public void setSes(){
        Contact con = [Select flag__c from contact where id =: contactId];
        con.flag__c = false;
        setCon = con;
        sessionCheck = false;
        update con;
    }
    
    public static void checkFlag(){
        system.debug('contactId'+contactId);
        Contact con = [Select flag__c from contact where id =: contactId];
        sessionCheck = con.flag__c;
        system.debug('conconconcon'+con.flag__c);
        setCon = con;
    }
    
    public sessionIdclass(){
        //system.debug('contactId'+contactId);
        if(contactId != null){
            Contact con = [Select FirstName,LastName,Email,flag__c from contact where id =: contactId];
            sessionCheck = con.flag__c;
            system.debug('conconconcon'+con.flag__c);
            setCon = con;
        }
        //getSessionPartOnLoad();
        System.debug('UserInfo.getSessionId()--'+UserInfo.getSessionId());
        OmniChannelStatusController();
        accessToken = '';
    }
    public class deserializeResponse{
        public String id;
        public String access_token;
    }
    public void ReturnAccessToken(){
        String reqbody = '&client_id='+clientId+'&client_secret='+clientSecret+'&username='+username+'&password='+password;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setBody(reqbody);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setEndpoint(endPointUrl);
        if(!Test.isRunningTest()){
            HttpResponse res = h.send(req);
        system.debug('@@@@access_token@@'+res );
       	system.debug('@@@@access_token@@'+res.getbody());
        deserializeResponse resp1 = (deserializeResponse)JSON.deserialize(res.getbody(),deserializeResponse.class);
        system.debug('@@@@access_token@@'+resp1 );
        accessToken = resp1.access_token;
        }
        if(recIdfromSupportDoc != null){
            Opportunity recc = [SELECT Id,Applicant_1__r.FirstName,Applicant_1__r.LastName,Applicant_1__r.PersonEmail FROM Opportunity WHERE Id =: recIdfromSupportDoc];
            opp = recc;
            OmniChannelStatusController();
        }
    }
    public void OmniChannelStatusController() {
        // Query Omni-Channel user statuses
        List<UserServicePresence> userPresences = [SELECT Id,ServicePresenceStatusId,IsCurrentState FROM UserServicePresence];
        
        system.debug('userPresences'+userPresences.size());
        // Check user statuses
        Active = false;
        for (UserServicePresence userPresence : userPresences) {
            //  String presenceStatus = userPresence.ServicePresenceStatusId;
            String presenceStatus = userPresence.ServicePresenceStatusId;
            // If any user is not online, set Active to false and break out of the loop
            if(userPresence.IsCurrentState){
             Active = true;
                break;
            }
            else{
                Active = false;
            }
        }
    }
}