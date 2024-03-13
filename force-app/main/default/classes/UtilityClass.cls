public class UtilityClass {
    public static final String adminEmail = 'tazeem.khan@chazecloud.com';
    public static final string sendEMail = 'sethu.rawat@chazecloud.com';
    
    
    public static void createException(String recordId, String className, String methodName, String ErrorMessage, String stackTrace, String lineNo,
                                       String errorType, String errorCause){
                                           Exception__c exe = New Exception__c(Record_Id__c = recordId,
                                                                               Method_Name__c = methodName, 
                                                                               Class_Name__c = className,
                                                                               Error_Message__c = ErrorMessage,
                                                                               Error_Cause__c = errorCause,
                                                                               Line_Number__c = lineNo,
                                                                               Stack_Trace__c = stackTrace,
                                                                               Error_Type__c = errorType);
                                           try{
                                               insert exe;
                                           } catch (Exception e) {
                                               System.debug(e.getMessage());
                                           }
                                       }
    
    
}