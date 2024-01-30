global class batchForLineChart implements Database.Batchable<sObject>,Database.Stateful {
    
    public List<opportunity> oppList;
    public batchForLineChart(List<opportunity> opp){
        oppList = new List<opportunity>();
        oppList = opp;
        System.debug('-=OPPOPOP++++'+oppList);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('select id, LineChart_Flag__c from opportunity where id IN : oppList');
    }
    
    global void execute(Database.BatchableContext bc, List<opportunity> scope) {
        System.debug('-=OPPOPOP++++'+oppList);
        System.debug('-=Scope++++'+scope.size());
        try{
            List<opportunity> oppl = new List<opportunity>();
            for(opportunity op : scope){
                Linechartcont.fillActivity(op.id);
                op.LineChart_Flag__c = true;
                oppl.add(op);
            }
            OpportunityTriggerHandler.isByPassTrigger = true;
            update oppl;
            OpportunityTriggerHandler.isByPassTrigger = false;
        }catch(Exception ex){
            insert new Exception__c(Class_Name__c = 'linechart batch', Method_Name__c = 'ALL', Error_Message__c = ex.getMessage() + '' + ex.getLineNumber());            
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations - send emails, notify clients,
        // give a call to another batch class
        // Can give to another batch class
        // Can give callout request
        system.debug('batch job id = '+bc.getJobId());
    }
    
}