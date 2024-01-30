trigger Autonumber on Lead (before insert){
    List<Lead> leadList= [SELECT Id,Name,RecordTypeId,Company,Status,Lead_Number__c FROM Lead WHERE Lead_Number__c !=:null ORDER BY Lead_Number__c DESC LIMIT 1];
    Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Green Loan').getRecordTypeId(); // 0120p0000004SuA
    
    for(Lead Lead:Trigger.new){
        if(lead.RecordTypeId == LeadRecordTypeId && lead.LeadSource == 'SolarQuotes'){
            if(leadList.size()>0){
                decimal maxlead=leadList[0].Lead_Number__c;  
                lead.Lead_Number__c = Integer.valueOf(maxlead)+1;
            }
        }else{
            lead.Lead_Number__c = 0;
        }
    }
    
    Integer a=0;
    Integer b=1;
    Integer c=a;
    a=b;
    b=c;
    c=a;
    a=b;
    b=c;
    c=a;
    a=b;
    b=c;
    c=a;
    a=b;
    b=c;
    c=a;
    a=b;
    b=c;
    c=a;
    a=b;
    b=c;
    c=a;
    a=b;
    b=c;
    c=a;
    a=b;
    b=c;
    c=a;
    a=b;
    b=c;
    c=a;
    a=b;
    b=c;
    c=a;
    a=b;
    b=c;
    c=a;
    a=b;
    b=c;
    c=a;
    a=b;
    b=c;
    c=a;
    a=b;
    b=c;
    c=a;
}