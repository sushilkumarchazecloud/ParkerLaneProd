({
	setMonthsYearsTerms : function(component, event) {
        var months = [];
        var years = [];
        var remainingTerms = [];
        
        for (var i = 0; i <=11; i++) {
            var month = {
                "label": i.toString(),
                "value": i.toString(),
            };
            months.push(month);
        }
        component.set("v.monthsOptions", months);
        
        for (var i = 0; i <=10; i++) {
            var year = {
                "label": i.toString(),
                "value": i.toString(),
            };
            years.push(year);
        }
        component.set("v.yearsOptions", years);
        
        var remainingTerm = {
            "label": 'n/a',
            "value": 'n/a'
        };
        remainingTerms.push(remainingTerm);
        for (var i = 0; i <= 30; i++) {
            var remainingTerm = {
                "label": i.toString(),
                "value": i.toString(),
            };
            remainingTerms.push(remainingTerm);
        }
        component.set("v.remainingTermsOptions", remainingTerms);
    },
})