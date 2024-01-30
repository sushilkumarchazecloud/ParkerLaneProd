({
	setOccupation: function(component, event) {
        var occupation = component.get("v.occupation");
        var incomfromOpt1 =  [{'label': 'Full time permanent', 'value': 'Full time permanent'},{'label': 'Part time permanent', 'value': 'Part time permanent'},{'label': 'Self Employed / Contractor', 'value': 'Self Employed / Contractor'},{'label': 'Casual / Temporary', 'value': 'Casual / Temporary'}];
        var incomfromOpt2 =  [{'label': 'Self Employed / Contractor', 'value': 'Self Employed / Contractor'}];
        var incomfromOpt3 =  [{'label': 'New Start Allowance', 'value': 'New Start Allowance'},{'label': 'Pension', 'value': 'Pension'},{'label': 'Dividends or Annuity', 'value': 'Dividends or Annuity'},{'label': 'Family Tax Benefits', 'value': 'Family Tax Benefits'},{'label': 'Disability Pension', 'value': 'Disability Pension'},{'label': 'Carer’s Pension', 'value': 'Carer’s Pension'},{'label': 'Child Support', 'value': 'Child Support'},{'label': 'Other', 'value': 'Other'}];
        if(occupation =='Administration' ||
           occupation =='Professional' ||
           occupation =='Sales' ||
           occupation =='Technical' ||
           occupation =='Trade' ||
           occupation =='Workcover / Workers Compensation' ){
            
            component.set("v.incomeFromOptions", incomfromOpt1);
        }else if(occupation =='Self Employed'){
            component.set("v.incomeFromOptions", incomfromOpt2);
        }else if(occupation =='Student' ||
                occupation =='Government Benefits' ||
                occupation =='Carer' ||
                occupation =='Self Funded Retired' ||
                occupation =='Retired' ||
                occupation =='Home Duties' ||
                occupation =='Unemployed'){
            component.set("v.incomeFromOptions", incomfromOpt3);
        }
		
    },

})