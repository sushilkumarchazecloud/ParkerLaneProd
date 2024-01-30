public with sharing class LeadTriggerHandler {
  List<Lead> trigger_new_list = new List<Lead>();
  List<Lead> trigger_old_list = new List<Lead>();

  public LeadTriggerHandler(List<Lead> new_list,List<Lead> old_list){
    trigger_new_list = new_list;
    trigger_old_list = old_list;
  }
  
  public void on_before_insert_Leads(){
      setOwnerIds(trigger_new_list);
  }

  public void on_before_update_Leads(){
      setOwnerIds(trigger_new_list);
  }
  
  public void setOwnerIds(List<Lead> leadList){
      Set<Id> OwnerIDs = new Set<Id>();
      for(Lead l : leadList){
          OwnerIDs.add(l.OwnerId);
      }
      updateBrokerQuote(OwnerIDs);
  }
  
  public void updateBrokerQuote(Set<Id> idSet){
      List<User> LeadOwner = [SELECT Id, Broker_Quote__c FROM USER WHERE Id IN: idSet];
      Map<Id,User> mapUser = new Map<Id, User>();
      
      for(User u : leadOwner){
          if(!mapUser.containsKey(u.Id)){
              mapUser.put(u.id, u);
          }
      }
      
      for(Lead l : trigger_new_list){
          if(mapUser.containsKey(l.ownerId)){
              l.Broker_Marketing_Quote__c = mapUser.get(l.ownerId).Broker_Quote__c;
          }
      }
  }
}