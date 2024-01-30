trigger EmploymentTrigger on FinServ__Employment__c (after insert, after update, after undelete, before delete) {
    
    Set<Id> pcIds = new Set<Id>();
    List<FinServ__Employment__c> empList = New List<FinServ__Employment__c>();
    if(Trigger.isDelete){
        empList = Trigger.old;
    }else{
        empList = Trigger.new;
    }
    
    for(FinServ__Employment__c emp: empList){
        if(String.isNotBlank(emp.FinServ__Contact__c) && ('Other').equalsIgnoreCase(emp.FinServ__EmploymentStatus__c) ){
            pcIds.add(emp.FinServ__Contact__c);
        }
    }
    
    
    List<FinServ__Employment__c> empsList = [SELECT Id, FinServ__AnnualIncome__c, FinServ__Contact__c, Income_Frequency__c FROM FinServ__Employment__c
                                            WHERE FinServ__EmploymentStatus__c ='Other' AND FinServ__Contact__c in: pcIds];
          
    Map<Id, Contact> conMap = New Map<Id, Contact>();
    for(FinServ__Employment__c emp: empsList){
        Contact con = conMap.get(emp.FinServ__Contact__c);
        if(con == Null){
            con = New Contact();
            con.Other_income_p_a__c = 0;
        }
        Decimal otherIncome = 0;
        if(emp.Income_Frequency__c == 'Weekly'){
            otherIncome = emp.FinServ__AnnualIncome__c * 52;
        }else if(emp.Income_Frequency__c == 'Fortnightly'){
            otherIncome = emp.FinServ__AnnualIncome__c * 26;
        }else if(emp.Income_Frequency__c == 'Monthly'){
            otherIncome = emp.FinServ__AnnualIncome__c * 12;
        }else if(emp.Income_Frequency__c == 'Annually'){
            otherIncome = emp.FinServ__AnnualIncome__c * 1;
        }
        
        con.Id = emp.FinServ__Contact__c;
        con.Other_income_p_a__c = con.Other_income_p_a__c + otherIncome;
            
        conMap.put(emp.FinServ__Contact__c, con);
    }
    update conMap.values();

}