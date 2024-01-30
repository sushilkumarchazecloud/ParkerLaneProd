global class SchedularForRefReportbatch implements Schedulable{
    
    global void execute(SchedulableContext ctx) {
      
        batchForSendingMailToRefererAdmin obj = new batchForSendingMailToRefererAdmin();
        
        Id batchId = Database.executeBatch(obj, 1);
        
        BatchForCustomerTasks cst = new BatchForCustomerTasks();
        
        Database.executeBatch(cst, 5);
        
    }
}