/**
 * @description      : This Utility class used to perform DML operations
 * @author           : Sethu Singh Rawat 
 * @created on       : 23-02-2024
**/
public with sharing class DMLUtility {
    //this enum type contains types of DML operations
    private enum Operation {OP_INSERT, OP_UPDATE, OP_DELETE, OP_UPSERT}
    
    /**
     * @description Custom DML Exception Class
     * @author Sethu Singh Rawat
    */
    public virtual class DMLManagerException extends Exception {
        /**
     * @description Custom DML Exception Class
     * @author Sethu Singh Rawat
    **/
        public SObjectType objectType {get; private set;}
        /**
     * @description Custom DML Exception Class
     * @author Sethu Singh Rawat
    **/
        public Operation operationType {get; private set;}
    }
    
    /**
     * @description This class constructor form the DML exception object
     * @author Sethu Singh Rawat
    */
    public class DMLException extends DMLManagerException {
         /**
     * @description This class constructor form the DML exception object
     * @author Sethu Singh Rawat
     * @param objectType - Salesforce object type
     * @param operationType -enum type, to check the user can perform the specific DML operation or not
    */
        public DMLException(SObjectType objectType, Operation operationType) {
            this(String.format(Label.DML_AccessErrorMessage, new List<object> {operationType, objectType}));
            this.objectType = objectType;
            this.operationType = operationType;
        }
    }
    
    /**
     * @description This method is Check CRUD permissions for the current user on the object
     * @author Sethu Singh Rawat
     * @param  objectType
     * @param  dmlOperation
    */
    private static void checkDMLPermission(SObjectType objectType, Operation dmlOperation) {
        DescribeSObjectResult describeObject = objectType.getDescribe();        
        //check the operation and user DML access on the object if no access through exception 
        if( (dmlOperation == Operation.OP_INSERT && !describeObject.isCreateable()) ||
            (dmlOperation == Operation.OP_UPDATE && !describeObject.isUpdateable()) ||
            (dmlOperation == Operation.OP_DELETE && !describeObject.isDeletable()) ) {
                throw new DMLException(objectType, dmlOperation);
        }
    }
    
    /**
     * @description This method is used to commit the new list of SObject records
     * @author Sethu Singh Rawat
     * @param newRecords - new list of SObject records
     * @param allOrNone
     * @return Database.SaveResult[]
    */
    public static Database.SaveResult[] commitInsert(List<SObject> newRecords, Boolean allOrNone) {
        Database.SaveResult[] saveResults; 
        try {
            if(newRecords.size() > 0) {
                checkDMLPermission(newRecords[0].getSObjectType(), Operation.OP_INSERT);
                saveResults = Database.insert(newRecords, allOrNone);
            }
        }
        catch(Exception e){
            throw e;
        }        
        return saveResults;
    }
    
    /**
     * @description This method is used to update the list of records
     * @author Sethu Singh Rawat
     * @param updateRecords - list of SObject records
     * @param allOrNone
     * @return Database.SaveResult[]
    */
    public static Database.SaveResult[] commitUpdate(List<SObject> updateRecords, Boolean allOrNone) {
        Database.SaveResult[] saveResults;        
        try {
            if(updateRecords.size() > 0) {
                checkDMLPermission(updateRecords[0].getSObjectType(), Operation.OP_UPDATE);
                saveResults = Database.update(updateRecords, allOrNone);
            }
        }
        catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, 'error'+e.getMessage());
            throw e;
        }        
        return saveResults;
    }
    
    /**
     * @description This method is used to perform insert and update
     * @author Sethu Singh Rawat
     * @param upsertRecords - list of SObject records
     * @param externalIDField
     * @param allOrNone
     * @return Database.UpsertResult[]
    */
    public static Database.UpsertResult[] commitUpsert(List<SObject> upsertRecords, Schema.SObjectField externalIDField, Boolean allOrNone) {
        Database.UpsertResult[] upsertResults;        
        try {
            if(upsertRecords.size() > 0) {            
            checkDMLPermission(upsertRecords[0].getSObjectType(), Operation.OP_UPSERT);                
                if(externalIDField != null) {
                    upsertResults=Database.upsert(upsertRecords, externalIDField, allOrNone);
                }else {
                    upsertResults = Database.upsert(upsertRecords, allOrNone);
                }
            }
        }
        catch(Exception e) {
            throw e;
        }        
        return upsertResults;
    }
    
    /**
     * @description This method is used to delete list of SObject records
     * @author Sethu Singh Rawat
     * @param deleteRecords - list of SObject records
     * @param allOrNone
     * @return Database.DeleteResult[]
    */ 
    public static Database.DeleteResult[] deleteRecords(List<SObject> deleteRecords, Boolean allOrNone) {
        Database.DeleteResult[] deleteResults;        
        try{
            if(deleteRecords.size() > 0) {
                checkDMLPermission(deleteRecords[0].getSObjectType(), Operation.OP_DELETE);
                deleteResults = Database.delete(deleteRecords, allOrNone);
            }
        }
        catch(Exception e) {
            throw e;
        }        
        return deleteResults;
    }
}