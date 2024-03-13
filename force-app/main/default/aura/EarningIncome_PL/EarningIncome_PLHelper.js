({
    setMonthsYearsHours : function(component, event) {
        var months = [];
        var years = [];
        var minHours = [];
        
        for (var i = 0; i <=12; i++) {
            var month = {
                "label": i.toString(),
                "value": i.toString(),
            };
            months.push(month);
        }
        component.set("v.monthsOptions", months);
        
        for (var i = 0; i <=25; i++) {
            var year = {
                "label": i.toString(),
                "value": i.toString(),
            };
            years.push(year);
        }
        component.set("v.yearsOptions", years);
        
        
        for (var i = 1; i <=36; i++) {
            var minHour = {
                "label": i.toString(),
                "value": i.toString(),
            };
            minHours.push(minHour);
        }
        component.set("v.minHourOptions", minHours);
    }, 
    
    setOccupation: function(component, event) {
        var applicant = component.get("v.applicant");
        var occupation = component.get("v.occupation");
        var incomfromOpt1 =  [{'label': 'Full time permanent', 'value': 'Full time permanent'},{'label': 'Part time permanent', 'value': 'Part time permanent'},{'label': 'Self Employed / Contractor', 'value': 'Self Employed / Contractor'},{'label': 'Casual / Temporary', 'value': 'Casual / Temporary'}];
        var incomfromOpt2 =  [{'label': 'Self Employed / Contractor', 'value': 'Self Employed / Contractor'}];
        var incomfromOpt3 =  [{'label': 'New Start Allowance', 'value': 'New Start Allowance'},{'label': 'Pension', 'value': 'Pension'},{'label': 'Dividends or Annuity', 'value': 'Dividends or Annuity'},{'label': 'Family Tax Benefits', 'value': 'Family Tax Benefits'},{'label': 'Disability Pension', 'value': 'Disability Pension'},{'label': 'Carer’s Pension', 'value': 'Carer’s Pension'},{'label': 'Child Support', 'value': 'Child Support'},{'label': 'Other', 'value': 'Other'}];
        
    },
	onChangeDependent: function(component, event) {
     
        var applicant = component.get("v.applicant");
        var applicantChildren = component.get("v.applicantChildren");
        
        if(!$A.util.isUndefinedOrNull(applicant.NumberOfChildren__c ) && applicant.NumberOfChildren__c >0){     
            var sel = applicant.NumberOfChildren__c;
            var len=0;
            if(applicantChildren.length>sel){
                len = applicantChildren.length - sel;
                for(var i= 1; i<=len;i++){
                    applicantChildren.pop();
                }
            }else if(applicantChildren.length<sel){
                len = sel - applicantChildren.length;
                for(var i= 1; i<=len;i++){
                    applicantChildren.push({
                        'sobjectType': 'Contact'
                    });
                }
            }
            component.set("v.applicantChildren", []);
            component.set("v.applicantChildren", applicantChildren);
           }
    },
})