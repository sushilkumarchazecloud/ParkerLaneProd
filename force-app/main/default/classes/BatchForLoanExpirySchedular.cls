global class BatchForLoanExpirySchedular Implements Schedulable{
    global void execute(SchedulableContext sc){
        BatchForLoanExpiry be = new BatchForLoanExpiry();
        database.executeBatch(be,100);
    }    
}