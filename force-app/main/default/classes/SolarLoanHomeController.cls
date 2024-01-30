public without sharing class SolarLoanHomeController {
    public Boolean Active {get;set;}
    public String recId = ApexPages.currentPage().getParameters().get('id');
    public Opportunity opp {get; set;}
    public SolarLoanHomeController(ApexPages.StandardController controller){
        
    }
    
   /* public Boolean init{
        get{    
            return false;
        }
    } */
    
    public SolarLoanHomeController(){
        if(recId != null){
            Opportunity recc = [SELECT Id,Applicant_1__r.FirstName,Applicant_1__r.LastName,Applicant_1__r.PersonEmail FROM Opportunity WHERE Id =: recId];
            opp = recc;
        }
        OmniChannelStatusController();
    }
    
    public void OmniChannelStatusController() {
        // Query Omni-Channel user statuses
        List<UserServicePresence> userPresences = [SELECT Id,ServicePresenceStatusId,IsCurrentState FROM UserServicePresence];
        
        system.debug('userPresences'+userPresences.size());
        // Check user statuses
        Active = false;
        for (UserServicePresence userPresence : userPresences) {
            //  String presenceStatus = userPresence.ServicePresenceStatusId;
            String presenceStatus = userPresence.ServicePresenceStatusId;
            // If any user is not online, set Active to false and break out of the loop
            if(userPresence.IsCurrentState){
             Active = true;
                break;
            }
            else{
                Active = false;
            }
        }
    }
    
    @RemoteAction
    public static Opportunity getOpponPriorties(id recId){ 
        Opportunity opp;
        if(recId != null){
            Opportunity recc = [SELECT Id,Applicant_1__r.FirstName,Applicant_1__r.LastName,Applicant_1__r.PersonEmail FROM Opportunity WHERE Id =: recId];
            opp = recc;
        } 
        return opp;
    }
}