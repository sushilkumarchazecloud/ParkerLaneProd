public class CFCUCalloutController{
    
    @AuraEnabled
    public static String makeCallout(String oppId){
        String message = CFCUController.sendApplication(oppId);
        return message;
    }

}