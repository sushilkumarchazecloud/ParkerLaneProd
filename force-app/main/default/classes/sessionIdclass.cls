public without sharing class sessionIdclass {
    private final String clientId = System.Label.ClientId;
    private final String clientSecret = System.Label.ClientSecret;
    private final String username = System.Label.Username;
    private final String password = System.Label.PasswordSupportingDoc;
    private final String endPointUrl = System.Label.EndpointURL;
    String partitionInput = 'local.CacheForOTP';
    Cache.SessionPartition sessionPartition;
    public String accessToken { get; set;}
    public String contactId = ApexPages.currentPage().getParameters().get('id');
    public boolean SMS {get; set;}
    public static boolean sessionCheck {get; set;}
    public contact setCon {get; set;}
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
        //sessionCheck = con.flag__c;
        update con;
    }
    
    public sessionIdclass(){
        if(contactId != null){
            Contact con = [Select flag__c from contact where id =: contactId];
            sessionCheck = con.flag__c;
            setCon = con;
        }
        //getSessionPartOnLoad();
        System.debug('UserInfo.getSessionId()--'+UserInfo.getSessionId());
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
    }
}