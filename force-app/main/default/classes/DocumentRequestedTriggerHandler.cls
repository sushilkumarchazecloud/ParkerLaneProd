/**
 * @description	: Handler class for Document_Requested triggers to encapsulate the trigger logic.
 * @author     	: Sethu Singh Rawat
 * @created on 	: 26-02-2024
 */
public with sharing class DocumentRequestedTriggerHandler implements ITriggerHandlerInf {
    public static boolean triggerDisabled = false;
    
    /**
     * @description: Checks if the trigger is disabled.
     * @author     : Sethu Singh Rawat
     * @created on : 26-02-2024
     * @return     : Boolean - True if the trigger is disabled, false otherwise.
     */
    public Boolean isDisabled() {
        return triggerDisabled;
    }
    
    /**
     * @description: Logic to be executed before account records are inserted.
     * @author     : Sethu Singh Rawat
     * @created on : 26-02-2024
     * @param      : newItems - List of new SObject records being inserted.
     */
    public void beforeInsert(List<SObject> newItems) {
        System.debug('beforeInsert: ' + newItems);
        // Additional logic to be implemented
    }
    
    /**
     * @description: Logic to be executed before account records are updated.
     * @author     : Sethu Singh Rawat
     * @created on : 26-02-2024
     * @param      : newItems - Map of new SObject records being updated, keyed by their Id.
     * @param      : oldItems - Map of old SObject records before the update, keyed by their Id.
     */
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        System.debug('beforeUpdate: ' + newItems + '\noldItems: ' + oldItems);
        // Additional logic to be implemented
    }
    
    /**
     * @description: Logic to be executed before account records are deleted.
     * @author     : Sethu Singh Rawat
     * @created on : 26-02-2024
     * @param      : oldItems - Map of SObject records being deleted, keyed by their Id.
     */
    public void beforeDelete(Map<Id, SObject> oldItems) {
        System.debug('beforeDelete: ' + oldItems);
        // Additional logic to be implemented
    }
    
    /**
     * @description: Logic to be executed after account records are inserted.
     * @author     : Sethu Singh Rawat
     * @created on : 22-02-2024
     * @param      : newItems - Map of new SObject records that were inserted, keyed by their Id.
     */
    public void afterInsert(Map<Id, SObject> newItems) {
        System.debug('afterInsert: ' + newItems);
    }
    
    /**
     * @description: Logic to be executed after account records are updated.
     * @author     : Sethu Singh Rawat
     * @created on : 26-02-2024
     * @param      : newItems - Map of new SObject records after the update, keyed by their Id.
     * @param      : oldItems - Map of old SObject records before the update, keyed by their Id.
     */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        System.debug('afterUpdate: ' + newItems + ' oldItems: ' + oldItems);
    }
    
    /**
     * @description: Logic to be executed after account records are deleted.
     * @author     : Sethu Singh Rawat
     * @created on : 26-02-2024
     * @param      : oldItems - Map of SObject records that were deleted, keyed by their Id.
     */
    public void afterDelete(Map<Id, SObject> oldItems) {
        System.debug('afterDelete: ' + 'oldItems: ' + oldItems);
    }
    
    /**
     * @description: Logic to be executed after account records are undeleted.
     * @author     : Sethu Singh Rawat
     * @created on : 26-02-2024
     * @param      : newItems - Map of SObject records that were undeleted, keyed by their Id.
     */
    public void afterUndelete(Map<Id, SObject> newItems) {
        System.debug('afterUndelete: ' + 'newItems: ' + newItems);
    }
}