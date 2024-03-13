/*
* @Description       : This is the test class for ConvertLead Apex Class.
* @Author            : Sumit Mahawar
* @Created on        : 05-02-2024
* @Last Modified By  : Sumit Mahawar
* @Last Modified On  : 28-02-2024
*/
public class Arc {
    
    /**
    * @description this for to get the all objects
    * @author Sumit Mahawar
    * @Created on : 05-02-2024
    **/    
    @AuraEnabled
    public static Map<String, List<sObject>> getAllObject(String objectId) {
        Map<String, List<sObject>> recordsMap = new Map<String, List<sObject>>();
        // Convert the String objectId to an SObject
        Id recordId = (Id)objectId;
        SObjectType sObjectType = recordId.getSobjectType(); 	
        System.debug('Object Name : ' + sObjectType);
        if (sObjectType != null) {
            DescribeSObjectResult describe = sObjectType.getDescribe();
            System.debug('describe : ' + describe);
            // Retrieve parent record details
            recordsMap.put('ParentRecord', new List<sObject>());
            String parentObjectName = describe.getName();
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> parentFieldMap = schemaMap.get(parentObjectName).getDescribe().fields.getMap();
            Set<String> parentFieldNames = parentFieldMap.keySet();
            List<String> parentFieldList = new List<String>(parentFieldNames);
            String parentDynamicFields = String.join(parentFieldList, ',');
            String parentQuery = 'SELECT ' + parentDynamicFields + ' FROM ' + parentObjectName + ' WHERE Id = :recordId LIMIT 1';
            List<SObject> parentRecordsList = Database.query(parentQuery);
            System.debug('Parent Data : ' + parentRecordsList);
            recordsMap.get('ParentRecord').addAll(parentRecordsList);
            for (ChildRelationship relation : describe.getChildRelationships()) {
                String relationshipName = relation.getRelationshipName();
                string objectName = '';
                if (relationshipName != null){                    
                    if(relationshipName.equals('Contacts')){
                        objectName = 'Contact';
                    }
                    else if(relationshipName.equals('Opportunities')){
                        objectName = 'Opportunity';
                    }
                    else if(relationshipName.equals('Cases')){
                        objectName = 'Case';
                    }
                    else if(relationshipName.equals('Partners')){
                        objectName = 'Partner';
                    }
                    
                    if(objectName != ''){
                        recordsMap.put(relationshipName, new List<sObject>());
                        Map<String, Schema.SObjectType> childSchemaMap = Schema.getGlobalDescribe();
                        Map<String, Schema.SObjectField> childFieldMap = childSchemaMap.get(objectName).getDescribe().fields.getMap();
                        Set<String> childFieldNames = childFieldMap.keySet();
                        List<String> childFieldList = new List<String>(childFieldNames);
                        String childDynamicFields = String.join(childFieldList, ',');
                        String query = 'SELECT ' + childDynamicFields + ' FROM ' + objectName + ' WHERE ' + relation.getField() + ' = :recordId LIMIT 500';
                        System.debug('query : ' + query);
                        List<SObject> childRecordsList = Database.query(query);
                        System.debug('childRecordsList : ' + childRecordsList);
                        recordsMap.get(relationshipName).addAll(childRecordsList);
                    }
                }
            }           
            System.debug('All Records: ' + recordsMap);
        }
        else {
            System.debug('Invalid object ID: ' + objectId);
        }        
        return recordsMap;
    }
}



	// this is only to find all object name
    /*@AuraEnabled(cacheable=true)
    public static List<String> testing(id objectId){
        System.debug(' object ID: ' + objectId);
        List<String> stList = new List<String>();
        SObjectType sObjectType = objectId.getSobjectType();
        if (sObjectType != null) {
            DescribeSObjectResult describe = sObjectType.getDescribe();          
            for (ChildRelationship relation : describe.getChildRelationships()) {
                String relationshipName = relation.getRelationshipName();
                if (relationshipName != null) {
                    stList.add(relationshipName);
                }
            }            
            System.debug('All Related records : ' + stList);
            for (String relatedRecord : stList) {
                System.debug(' ');
            	System.debug('------------------------ ' + relatedRecord);
        	}
        } 
        else {
            System.debug('Invalid object ID: ' + objectId);
        }        
        return stList;
	}*/