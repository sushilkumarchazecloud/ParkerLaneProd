public class sessionIdclass {
	
    private final String clientId = System.Label.ClientId;
    private final String clientSecret = System.Label.ClientSecret;
    private final String username = System.Label.Username;
    private final String password = System.Label.PasswordSupportingDoc;
    private final String endPointUrl = System.Label.EndpointURL;
    public contact setCon {get; set;}
    public String accessToken { get; set;}
    public String contactId = ApexPages.currentPage().getParameters().get('id');

    public sessionIdclass(ApexPages.StandardController controller){
        
    }
    
    
    public sessionIdclass(){
        accessToken = '';
    }
    
    public void setSes(){
        Contact con = [Select flag__c from contact where id =: contactId];
        con.flag__c = false;
        setCon = con;
        //sessionCheck = con.flag__c;
        update con;
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
    
    public class deserializeResponse{
        public String id;
        public String access_token;
    }
}