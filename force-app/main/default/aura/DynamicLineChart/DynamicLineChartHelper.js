({
    getStages : function(component, event){
        var action = component.get("c.getStages"); 
        console.log('@@@@@get stage');
        action.setCallback(this, function(response) { 
            var state = response.getState();
            console.log('@@@@@state' + state);
            if (state === "SUCCESS") { 
                var ret= response.getReturnValue();
                var dataObj = JSON.parse(ret);
                component.set("v.StageOptions",dataObj);
            }
        });
        $A.enqueueAction(action);
    },
    
    doInit : function(component, event, helper){
        var action = component.get("c.getChartData"); 
        action.setParams({
            lender: component.get('v.lender'),
            adviser: component.get('v.adviser'),
            loanType: component.get('v.loanType'),
            stagesList: component.get('v.selectedStageName'),
            stageStartDate: component.get('v.startDate'),
            stageEndDate: component.get('v.endDate')
        });
        action.setCallback(this, function(response) { 
            var state = response.getState();
            console.log('@@@@@state' + state);
            if (state === "SUCCESS") { 
                var ret= response.getReturnValue();
                console.log('@@@@@ret' + ret);
                if(ret == ''){
                    alert('Data is too large, please use filter for result');
                }else{
                    var dataObj = JSON.parse(ret);
                    /*if(component.get("v.isStagesChange")){
                        component.set("v.StageOptions",dataObj.stages);
                    }*/
                    
                    component.set("v.data",JSON.stringify(dataObj.data));
                    component.set("v.xAxisCategories",JSON.stringify(dataObj.dates));
                    helper.Linechart(component,event,helper);
                }
            }else{
                alert('Data is too large, please use filter for result');
            } 
            this.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
    },

    Linechart : function(component,event,helper) {
        var jsonData = component.get("v.data");
        var dataObj = JSON.parse(jsonData);
        
        new Highcharts.Chart({
            chart: {
                plotBackgroundColor: null,
                plotBorderWidth: null,
                plotShadow: false,
                renderTo: component.find("linechart").getElement(),
                type: 'line'
            },
            title: {
                text: 'Line Chart'
            },
            subtitle: {
                text: component.get("v.chartSubTitle")
            },
            legend: {
                layout: 'vertical',
                align: 'right',
                verticalAlign: 'middle'
            },
            xAxis: {
                categories: JSON.parse(component.get("v.xAxisCategories")),
                crosshair: true
            },
            yAxis: {
                min: 0,
                title: 
                {
                    text: component.get("v.yAxisParameter")
                }
            },
            tooltip: {
                pointFormat: '{series.name}: <b>{point.y}</b>'
            },
            plotOptions: {
                line: {
                    dataLabels: {
                        enabled: true
                    },
                    enableMouseTracking: false,
                }
            },
            series: dataObj
        });
    },
    
    toggleSpinner: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
})