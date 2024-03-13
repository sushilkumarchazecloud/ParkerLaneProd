/**
 * @description: Interface for trigger handler classes to ensure consistency across different triggers.
 * @author     : Sethu Singh Rawat
 * @created on : 22-02-2024
 */
public interface ITriggerHandlerInf {
    
    /**
     * @description   : Handles the 'before insert' trigger event.
     * @author        : Sethu Singh Rawat
     * @created on    : 22-02-2024
     * @param newItems: List of new SObjects being inserted
     */
    void beforeInsert(List<SObject> newItems);
    
    /**
     * @description   : Handles the 'before update' trigger event.
     * @author        : Sethu Singh Rawat
     * @created on    : 22-02-2024
     * @param newItems: Map of new SObjects being updated, keyed by their Ids
     * @param oldItems: Map of old SObjects before the update, keyed by their Ids
     */
    void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);
    
    /**
     * @description   : Handles the 'before delete' trigger event.
     * @author        : Sethu Singh Rawat
     * @created on    : 22-02-2024
     * @param oldItems: Map of SObjects being deleted, keyed by their Ids
     */
    void beforeDelete(Map<Id, SObject> oldItems);
    
    /**
     * @description   : Handles the 'after insert' trigger event.
     * @author        : Sethu Singh Rawat
     * @created on    : 22-02-2024
     * @param newItems: Map of newly inserted SObjects, keyed by their Ids
     */
    void afterInsert(Map<Id, SObject> newItems);
    
    /**
     * @description   : Handles the 'after update' trigger event.
     * @author        : Sethu Singh Rawat
     * @created on    : 22-02-2024
     * @param newItems: Map of updated SObjects, keyed by their Ids
     * @param oldItems: Map of SObjects before the update, keyed by their Ids
     */
    void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);
    
    /**
     * @description   : Handles the 'after delete' trigger event.
     * @author        : Sethu Singh Rawat
     * @created on    : 22-02-2024
     * @param oldItems: Map of deleted SObjects, keyed by their Ids
     */
    void afterDelete(Map<Id, SObject> oldItems);
    
    /**
     * @description   : Handles the 'after undelete' trigger event.
     * @author        : Sethu Singh Rawat
     * @created on    : 22-02-2024
     * @param newItems: Map of undeleted SObjects, keyed by their Ids
     */
    void afterUndelete(Map<Id, SObject> newItems);

    Boolean isDisabled();
}