public class ImportLeadScheduler implements Schedulable{
    //Start method for scheduler
    public void execute(SchedulableContext sc){              
        SendHttpRequest.UpsertLeads();        
    }
}