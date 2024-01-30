public class ServiceAnnouncementController {
    public String nameOfService{get;set;}
    public Configuration__c config{get;set;}
    public Boolean isShowMessage{
        get{
            return showMessage();
        }
    } 
    
    public Boolean showMessage(){
        if(String.isBlank(nameOfService)) return false;
        config = getServiceMessage(nameOfService);
        if(config == NULL || !config.isShowMessage__c ){
            return false;
        }
        return true;
    }
    
	@auraEnabled
    public static Configuration__c getServiceMessage(String serviceName){
        Configuration__c  config = Configuration__c.getInstance(serviceName);
        System.debug('@@@@config' + config);
        return config;
    }
    
}