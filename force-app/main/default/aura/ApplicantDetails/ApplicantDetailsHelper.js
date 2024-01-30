({
    addPreAdd : function(component, event) {
        
        var addressList = component.get("v.addressList");
        addressList.push({
            'years':0,
            'months':0
        });
        component.set("v.addressList", addressList);
        if(addressList.length>1){
            component.set("v.showPreviousAdd" , false);
        }
    },
    
    checkMonthYear : function(component, event) {
        var totalMonths = 0;      
        var addressList = component.get("v.addressList");
        var applicant = component.get("v.applicant");
        
        if(!$A.util.isUndefinedOrNull(applicant.Months__c)){
            totalMonths += parseInt(applicant.Months__c);
        }
        if(!$A.util.isUndefinedOrNull(applicant.Months_1__c)){
            totalMonths += parseInt(applicant.Months_1__c);
        }
        if(!$A.util.isUndefinedOrNull(applicant.Months_2__c)){
            totalMonths += parseInt(applicant.Months_2__c);
        }
        if(!$A.util.isUndefinedOrNull(applicant.Year__c)){
            totalMonths += (parseInt(applicant.Year__c) * 12);
        }
        if(!$A.util.isUndefinedOrNull(applicant.Year_1__c)){
            totalMonths += (parseInt(applicant.Year_1__c) * 12);
        }
        if(!$A.util.isUndefinedOrNull(applicant.Year_2__c)){
            totalMonths += (parseInt(applicant.Year_2__c) * 12);
        }
        if(totalMonths<36 && addressList.length<2){
            component.set("v.showPreviousAdd", true);
        }else{
            component.set("v.showPreviousAdd", false);
        }
    },
})