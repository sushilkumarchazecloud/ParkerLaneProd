trigger AccountTrigger on Account (After update) {
    List<Account> accList = new List<Account>();
   
    for(Account acc:Trigger.new){
        system.debug(acc.Name);
        if(acc.FirstName!=Trigger.oldmap.get(acc.Id).FirstName || acc.LastName!=Trigger.oldmap.get(acc.Id).LastName){
            accList.add(acc);
        }
    }

    list<opportunity> opplist = new list<opportunity>();
    opplist = [select id,name, Number_of_applicants__c,Applicant_Details_Change__c,Applicant_1__c,Applicant_2__c,Applicant_1__r.FirstName,Applicant_1__r.LastName,Applicant_2__r.FirstName,Applicant_2__r.LastName,RecordType.Name from opportunity where Applicant_1__c =: accList or Applicant_2__c =: accList] ;
    String str = '';

    
    for(Opportunity opp:opplist){
        if(opp.Number_of_applicants__c == 1){
            str = opp.Applicant_1__r.FirstName + ' ' + opp.Applicant_1__r.LastName + ', ' + opp.recordType.Name;
            opp.Name=str;
        }else if(opp.Number_of_applicants__c == 2){
            if(opp.Applicant_1__r.LastName.equalsIgnoreCase(opp.Applicant_2__r.LastName)){
                str = opp.Applicant_1__r.FirstName + ' and ' + opp.Applicant_2__r.FirstName + ' ' + opp.Applicant_1__r.LastName + ', ' + opp.recordType.Name;
            }else{
                str = opp.Applicant_1__r.FirstName + ' ' + opp.Applicant_1__r.LastName + ' and ' + opp.Applicant_2__r.FirstName + ' ' + opp.Applicant_2__r.LastName + ', ' + opp.recordType.Name;
            }
            opp.Name=str;
       		opp.Applicant_Details_Change__c = true;
        }}
     
    update opplist;
}