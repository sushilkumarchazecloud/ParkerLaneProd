public class ReferrersReportController {
	public static final string ConId = ApexPages.currentPage().getParameters().get('ConId');
    public Map<id, List<Opportunity>> refMap {get;set;}
    public Integer sizelist{get;set;}
    public List<opportunity> opList{get;set;}
    public string now{get;Set;}
    public Account Acc{get; set;}
    public contact con{get; set;}
    public String xlsHeader {
        get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }
    
    public ReferrersReportController(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = opportunity.stageName.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     

        con = [Select Id, AccountId, name From Contact WHERE id =: ConId LIMIT 1];
        for(Account Ac : [Select Id, name from Account WHERE ID =: con.AccountId Limit 1]){
            Acc = Ac;
        }
        opList = new List<opportunity>();
        refMap = new Map<id, List<Opportunity>>();
        for(Opportunity op : [Select Id,Loan_Amount__c,Lender__c,Escalation__c,LastModifiedDate,Application_Pending_Notes__c,Application_Pending_Status__c, Name,Time_at_current_stage__c, StageName,CreatedDate,LastActivityDate,ReferredByContact__c,ReferredByContact__r.name from opportunity WHERE ReferredByContact__c =: con.Id order By stageName,Time_at_current_stage__c  Asc]){
            if(((op.stageName == 'Working' || op.stageName == 'Nurturing') && op.Time_at_current_stage__c <= 7) 
               || (op.StageName == 'Closed Lost' && op.Time_at_current_stage__c <= 7)
               || ((op.StageName != 'Settled (closed won)' && op.stageName != 'Working' && op.stageName != 'Nurturing' && op.StageName != 'Closed Lost') && op.Time_at_current_stage__c <= 120)
               || (op.StageName == 'Settled (closed won)') 
              ){
                  opList.add(op);
                  if(!refMap.containsKey(op.ReferredByContact__c)){
                      refMap.put(op.ReferredByContact__c, new List<Opportunity>{op});  
                      System.debug('infii89i89989f');
                  }
                  else{
                      refMap.get(op.ReferredByContact__c).add(op);
                      System.debug('infif'+refMap.get(op.ReferredByContact__c));
                  }
              }
        }
        
        sizelist = (opList != null && opList.size() > 0 ? opList.size() : 0);
        
        DateTime todayTImm = System.now();
        now = monthCOnvert(todayTImm)[1];
    }
    
    public List<string> monthCOnvert(dateTime dat){
        
        List<string> datetimeconverted = new List<string>();
        List<string> data = string.valueOf(dat).split(' ');
        dateTime tim =  dat;
        string team = tim.format('h:mm a');
        
        datetimeconverted.add(team);
        
        integer nm = dat.month();
        
        string mnth = '';
        if(nm == 1){
            mnth = 'Jan';
        }
        else if(nm == 2){
            mnth = 'Feb';
        }
        else if(nm == 3){
            mnth = 'Mar';
        }
        else if(nm == 4){
            mnth = 'Apr';
        }
        else if(nm == 5){
            mnth = 'May'; 
        }
        else if(nm == 6){
            mnth = 'Jun';
        }
        else if(nm == 7){
            mnth = 'Jul';
        }
        else if(nm == 8){
            mnth = 'Aug';
        }
        else if(nm == 9){
            mnth = 'Sep';
        }
        else if(nm == 10){
            mnth = 'Oct';
        }
        else if(nm == 11){
            mnth = 'Nov';
        }
        else if(nm == 12){
            mnth = 'Dec'; 
        }
        else{
            mnth = '';
        }
        
        string st = dat.day() + ' ' + mnth + ' ' + dat.year();
        
        datetimeconverted.add(st);
        return datetimeconverted;
    }
    
}