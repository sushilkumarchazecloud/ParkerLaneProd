/**
 * @description       : This is a Selector Class for Contact
 * @Author            : Sethu Singh Rawat
 * @Created on        : 27/02/2024
 * @Last Modified By  : Sethu Singh Rawat
 * @Last Modified On  : 27/02/2024
**/
public with sharing class ProductTypeSelector {

    /**
     * @description       : This method is used to get the list of Product_Type__c  records that has matched productTypeIds
     * @Author            : Sethu Singh Rawat
     * @Created on        : 27/02/2024
     * @param Set<Id> productTypeIds
     * @return List<Product_Type__c>
    **/
    public static List<Product_Type__c> getAllProductTypes(Set<Id> productTypeIds){
        return [Select id,Name,Icon__c from Product_type__c where id IN : productTypeIds WITH SECURITY_ENFORCED];
    }
}