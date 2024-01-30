global without sharing class roundRobinFunct implements Queueable { 
    
    public List<opportunity> opList;
    public roundRobinFunct(List<opportunity> NewOPP){
        this.opList = NewOPP;
    }
    global void execute(QueueableContext context) {
        System.debug('-==--roundRobin='+opList);
        String CreditAna = System.Label.Credit_analyst;
        User caUser = [select id, name from user where username =: CreditAna];
        Group gc = [select id, name from group where name = 'Customer Support Group'];
        system.debug('gc__'+gc);
        set<id> grupMem = new Set<id>();
        for(GroupMember gcM : [select id, UserOrGroupid from GroupMember where GroupId =: gc.id]){
            grupMem.add(gcM.UserOrGroupid);
        }
        List<User> userList =  new List<User>();
        List<User> userListforUpdate =  new List<User>();
        List<opportunity> oppListforUpdate =  new List<opportunity>();
        system.debug('grupMem__'+grupMem);
        if(grupMem != null && grupMem.size() > 0){
            for(user us : [select id, name from user where Id IN: grupMem]){
                userList.add(us);
            }
            
            System.debug('users:====='+userList);
            
            if(userList != null && userList.size() > 0){
                Integer randomNumber = Integer.valueof((Math.random() * userList.size()));
                
                User usr = userList[randomNumber];
                
                for(opportunity op : opList){
                    opportunity opp = new opportunity();
                    opp.Id = op.Id;
                    opp.Customer_Support_Person__c = usr.Id;
                    opp.Credit_Analyst__c = caUser.id;
                    oppListforUpdate.add(opp);
                }
                update oppListforUpdate;
            }
            
        }            
    }
}