public without sharing class CustomRelatedRecordController{

    @auraEnabled
    public static String getParentId(Id recordId, String parentFieldName, String fieldSetName ){
        Id pId = Null;
        String iconName = '';
        String objName = recordId.getSObjectType().getDescribe().getName(); // Object name you wish to extract lookup fields for
        String fieldLabel = '';
        String pObjName = '';
        if(('self lookup').equalsIgnoreCase(parentFieldName)){
            pId = recordId;
            fieldLabel = objName;
            pObjName = objName;
            iconName = 'standard:' + (('quote').equalsIgnoreCase(pObjName)? 'quotes' : pObjName.toLowerCase());
        }else{
            fieldLabel = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(parentFieldName).getDescribe().getLabel();
            String query = 'SELECT ' + parentFieldName + ' FROM ' + objName + ' WHERE Id =\''+ recordId+'\'';
            System.debug('@@@@query'+query);
            sObject sObj = Database.query(query);
            
            if(sObj.get(parentFieldName) != NULL){
                pId = (Id)sObj.get(parentFieldName);
                pObjName = pId.getSObjectType().getDescribe().getName();
                iconName = 'standard:' + + (('quote').equalsIgnoreCase(pObjName)? 'quotes' : pObjName.toLowerCase());
            }
        }   
        String fieldSetList = '[';
        for(String st: readFieldSet(fieldSetName, pObjName).keySet()){
            
            fieldSetList += '\"' + st + '\",';
        }
        fieldSetList = fieldSetList.removeEnd(',');
        fieldSetList += ']';
        
        return '{\"parentId\":\"' + pId + '\",\"parentObjectName\":\"'+ pObjName +'\",\"fieldLabel\":\"'+ fieldLabel +'\",\"iconName\":\"'+ iconName +'\",\"fieldSetList\":'+  fieldSetList +'}';
    }
    
    public static Map<String,String> readFieldSet(String fieldSetName, String ObjectName){
        System.debug('>>>>>'+ ObjectName);
        System.debug('>>>>>'+ fieldSetName);
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        Map<String,String> fieldSetList = New Map<String,String>();
        if(fieldSetObj.getFields() != Null){
            for(Schema.FieldSetMember fld: fieldSetObj.getFields()){
                fieldSetList.put(fld.getFieldPath(), fld.getLabel());
                
            }
        }
        return fieldSetList; 
    }  
    
    /********************************************************************************/
    
      
    @AuraEnabled  
    public static RelatedListResult fetchRecs( String recId, String sObjName, String parentFldNam, String fieldSetName, String childRelName) {  
        System.debug('>>>>>'+ recId);
        System.debug('>>>>>'+ sObjName);
        System.debug('>>>>>'+ parentFldNam);
        System.debug('>>>>>'+ fieldSetName);
        Id pId = Null;
        String pObjName = '';
        String objName = ((Id)recId).getSObjectType().getDescribe().getName();
        String query = 'SELECT Id, ' + parentFldNam + ' FROM ' + objName + ' WHERE Id =\''+ recId+'\'';
        System.debug('@@@@query'+query);
        sObject sObj = Database.query(query);
        if(sObj.get(parentFldNam) != NULL){
            pId = (Id)sObj.get(parentFldNam);
            pObjName = pId.getSObjectType().getDescribe().getName();
        }
        String strTitle = ' (';           
        List < sObject > listsObjects = new List < sObject >();  
        String fieldList = '';
        String fieldAPIList = '[';
        String fieldSetList = '[';
        Map<String,String> readFieldSet = readFieldSet(fieldSetName, sObjName);
        for(String st: readFieldSet.keySet()){
            fieldAPIList  += '\"' + st + '\",';
            fieldList  += st + ',';
            fieldSetList += '\"' + readFieldSet.get(st) + '\",';
        }
        fieldAPIList = fieldAPIList.removeEnd(',');
        fieldAPIList += ']';
        fieldSetList = fieldSetList.removeEnd(',');
        fieldSetList += ']';
        RelatedListResult obj = new RelatedListResult();  
        
        if(pId != NULL){
            String strSOQL = 'SELECT Id, (SELECT ' + fieldList + 'Id FROM ' + childRelName + ') FROM ' + pObjName + ' WHERE Id = \'' + pId + '\'';  
            strSOQL += ' LIMIT 4';  
            System.debug('strSOQL>>>>>'+ strSOQL);
            
            List < sObject > listsObj = Database.query( strSOQL ); 
            listsObjects = (List < sObject >)listsObj.get(0).getSObjects(childRelName);
            Integer intCount = listsObjects.size();  
            if ( intCount > 3 ) {  
                
                List < sObject > tempListsObjects = new List < sObject >();  
                for ( Integer i = 0; i <3; i++ )  
                    tempListsObjects.add( listsObjects.get( i ) );  
                
                obj.listsObject = tempListsObjects;  
                strTitle += '3+';  
                
            } else {  
                
                obj.listsObject = listsObjects;  
                strTitle += String.valueOf( intCount );  
                
            }  
        }
        strTitle += ')';        
        
        System.debug('>>>>>fieldSetList'+ fieldSetList);
        obj.strTitle = strTitle; 
        obj.parentRecId = pId; 
        obj.fieldSetList = fieldSetList; 
        obj.fieldAPIList = fieldAPIList; 
        System.debug('>>>>>obj'+ obj);
        return obj;  
          
    }  
      
    public class RelatedListResult {  
          
        @AuraEnabled  
        public String strTitle;
        @AuraEnabled  
        public String parentRecId;
        @AuraEnabled  
        public String fieldSetList;
        @AuraEnabled  
        public String fieldAPIList;
        @AuraEnabled  
        public List < sObject > listsObject;  
          
    }  
  
    
    
    
    
    
    
    /*
    @auraEnabled
    public static string getLookupFields(Id recordId ){
        Id opId = '0069D000002O4yDQAS';
        String objName = recordId.getSObjectType().getDescribe().getName(); // Object name you wish to extract lookup fields for
        System.debug('@@@@' +objName);
        
        
        map<string, Map<String, Schema.SObjectField>> objectFieldsMap = new map<string, Map<String, Schema.SObjectField>>(); //Object field schema map
        Map<String, Schema.SObjectField> objectFields
            = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
        for(Schema.SObjectField fld :objectFields.values()){
            schema.describeFieldResult dfield = fld.getDescribe();
            string fldType = string.valueOf(dfield.getType());   
            if (fldType == 'REFERENCE'){ // Lookup field!
                system.debug(string.valueOf(dfield.Name) + ' = ' + dfield.getLabel());
            }
        }
        return '';
    }
    
    
    
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('red', 'RED');
        return defaultValue;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DataRow value1 = new VisualEditor.DataRow('red', 'RED');
        VisualEditor.DataRow value2 = new VisualEditor.DataRow('yellow', 'YELLOW');
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        myValues.addRow(value1);
        myValues.addRow(value2);
        return myValues;
    }*/
}