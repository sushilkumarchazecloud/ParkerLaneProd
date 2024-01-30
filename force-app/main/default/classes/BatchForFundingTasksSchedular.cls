global class BatchForFundingTasksSchedular Implements Schedulable{
    global void execute(SchedulableContext sc){
        BatchForFundingTasks be = new BatchForFundingTasks();
        database.executeBatch(be,50);
    } 
}