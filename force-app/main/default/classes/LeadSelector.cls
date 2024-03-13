/**
 * @description       : This is a Selector Class for Lead
 * @Author            : Sethu Singh Rawat
 * @Created on        : 26/02/2024
 * @Last Modified By  : Sethu Singh Rawat
 * @Last Modified On  : 26/02/2024
**/
public with sharing  class LeadSelector {
    
    public static Lead selectLeadId(String leadId){
        return[SELECT Id,Name,Application_Sections__c, Current_Application_Sections__c FROM Lead WHERE id =: leadId];
    }

}