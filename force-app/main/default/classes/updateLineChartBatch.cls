global class updateLineChartBatch implements Database.Batchable<sObject>,Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext bc) {
       
        
        return Database.getQueryLocator('Select Id, Name,Line_Chart_JSON__c from Opportunity');
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        for(Opportunity opp : scope){
            Linechartcont.fillActivity(opp.Id);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
       
    }
}