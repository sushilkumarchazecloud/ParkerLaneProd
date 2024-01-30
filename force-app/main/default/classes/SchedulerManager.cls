public class SchedulerManager {
  
     //Method to start scheduler
    public void StartScheduler(){
        String CRON_EXP = '0 0 * * * ?';
        List<CronTrigger> scheduledJobs = new List<CronTrigger>([select Id,CronJobDetail.Name from CronTrigger where CronJobDetail.Name = 'Importing Leads']);
        if(scheduledJobs.isEmpty()){
            ImportLeadScheduler sch = new ImportLeadScheduler();

            System.schedule('Importing Leads 1', '0 00 * * * ?',new ImportLeadScheduler());
            System.schedule('Importing Leads 2', '0 05 * * * ?',new ImportLeadScheduler());
            System.schedule('Importing Leads 3', '0 10 * * * ?',new ImportLeadScheduler());
            System.schedule('Importing Leads 4', '0 15 * * * ?',new ImportLeadScheduler());
            System.schedule('Importing Leads 5', '0 20 * * * ?',new ImportLeadScheduler());
            System.schedule('Importing Leads 6', '0 25 * * * ?',new ImportLeadScheduler());
            System.schedule('Importing Leads 7', '0 30 * * * ?',new ImportLeadScheduler());
            System.schedule('Importing Leads 8', '0 35 * * * ?',new ImportLeadScheduler());
            System.schedule('Importing Leads 9', '0 40 * * * ?',new ImportLeadScheduler());
            System.schedule('Importing Leads 10', '0 45 * * * ?',new ImportLeadScheduler());
            System.schedule('Importing Leads 11', '0 50 * * * ?',new ImportLeadScheduler());
            System.schedule('Importing Leads 12', '0 55 * * * ?',new ImportLeadScheduler());
        }
        
    }
    
    //Method to stop scheduler 
    public void StopScheduler(){
        List<CronTrigger> runningscheduler = new List<CronTrigger>([select Id,CronJobDetail.Name from CronTrigger where CronJobDetail.Name LIKE 'Importing Leads%']);
        if(!runningscheduler.isEmpty()){
             for(CronTrigger ct : runningscheduler){
                 System.abortJob(ct.id);
            }
        }
    }

}