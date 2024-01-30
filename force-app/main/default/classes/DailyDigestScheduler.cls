global class DailyDigestScheduler implements Schedulable {
    global void execute(SchedulableContext sc){
        DailyDigestBatchable opp=new DailyDigestBatchable();
        Database.executeBatch(opp,10);
    }
}