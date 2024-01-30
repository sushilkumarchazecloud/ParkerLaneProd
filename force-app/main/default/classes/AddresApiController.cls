public class AddresApiController {

    @AuraEnabled
    public static string getAddressAutoComplete(String input) {
        String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input='
            + EncodingUtil.urlEncode(input, 'UTF-8')
            + '&key=' + AddresApiController.getGoogleMapsAPIKey()
            + '&libraries=places&components=country:AU';
        return AddresApiController.getHttp(url);
    }
    @AuraEnabled
    public static string getAddressDetails (String placeid) {
        String url = 'https://maps.googleapis.com/maps/api/place/details/json?placeid='
            + placeid          
            + '&key=' + AddresApiController.getGoogleMapsAPIKey();
        return AddresApiController.getHttp(url);
    }     
    @AuraEnabled
    public static String getHttp(String url) {
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        req.setMethod('GET');
        req.setEndpoint(url);
        HTTPResponse res = New HttpResponse();
        if(Test.isRunningTest()){
            res.setBody('Unit Test');
        }else{
            res = http.send(req);
        }
        
        return res.getBody();
    }  
    @AuraEnabled
    public static String getGoogleMapsAPIKey() {
        return 'AIzaSyAFH1T9kCi5oGjrmvK9m6gVDgX1O89AUjU';
    }
}