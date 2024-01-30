({
    doInit: function(component, event, helper) {
        helper.toggleSpinner(component, event);
        helper.scrollTop(component, event, 315);
        helper.getEmploymentDetails(component, event);
    },
    
    addIncome1: function(component, event, helper) {
        helper.addIncome(component, event, 1);
    },
    
    addIncome2: function(component, event, helper) {
        helper.addIncome(component, event, 2);
    },
    
    deleteRow: function(component, event) {
        var index = event.getParam("indexVar");
        var rowType = event.getParam("rowType");

        if(rowType === 'EarningIncome1'){
            var employmentsList = component.get("v.employmentsList1");
            employmentsList.splice(index,1);
            component.set("v.employmentsList1", employmentsList);
        }else if(rowType === 'EarningIncome2'){
            var employmentsList = component.get("v.employmentsList2");
            employmentsList.splice(index,1);
            component.set("v.employmentsList2", employmentsList);
        }else if(rowType === 'preEmpHistory1'){
            var preEmpList = component.get("v.preEmpList1");
            preEmpList.splice(index,1);
            component.set("v.preEmpList1", preEmpList);

            if(preEmpList.length<2){
                component.set("v.showPreviousEmpHistory1", true);
            }
        }else if(rowType === 'preEmpHistory2'){
            var preEmpList = component.get("v.preEmpList2");
            preEmpList.splice(index,1);
            component.set("v.preEmpList2", preEmpList);

            if(preEmpList.length<2){
                component.set("v.showPreviousEmpHistory2", true);
            }
        }
    },
    
    validateFields: function(component, event, helper) {
        helper.doValidation(component, event);
        
    },
    
    save: function(component, event, helper) {
        var applicantGrpValue = component.get("v.applicantGrpValue");
        var selectedPerson = component.get("v.selectedPerson");
        var employmentsList;
        var lstSize = component.get("v.empListSize");
        var result = event.getParam("result");

        var isShowPreEmpHistory = false;
        var isvalidate = true;
        if(applicantGrpValue== 'applicant2' && selectedPerson == 'joint'){
            employmentsList = component.get("v.employmentsList2");
            isShowPreEmpHistory = component.get("v.showPreviousEmpHistory2");
            var previousEmpHistory1 = component.find("previousEmp2History1");
            
            if(!$A.util.isUndefinedOrNull(previousEmpHistory1)){
                var isvalidatedResult = previousEmpHistory1.validatePreEmp();
                
                if(!isvalidatedResult){
                    isvalidate = false;
                }
            }
            var previousEmpHistory2 = component.find("previousEmp2History2");
            if(!$A.util.isUndefinedOrNull(previousEmpHistory2)){
                var isvalidatedResult = previousEmpHistory2.validatePreEmp();
                if(!isvalidatedResult){
                    isvalidate = false;
                }
            }
        }else{
            employmentsList = component.get("v.employmentsList1");
            isShowPreEmpHistory = component.get("v.showPreviousEmpHistory1");
            var previousEmpHistory1 = component.find("previousEmp1History1");
            if(!$A.util.isUndefinedOrNull(previousEmpHistory1)){
                var isvalidatedResult = previousEmpHistory1.validatePreEmp();
                if(!isvalidatedResult){
                    isvalidate = false;
                }
            }
            var previousEmpHistory2 = component.find("previousEmp1History2");
            if(!$A.util.isUndefinedOrNull(previousEmpHistory2)){
                var isvalidatedResult = previousEmpHistory2.validatePreEmp();
                if(!isvalidatedResult){
                    isvalidate = false;
                }
            }
        }

        var fieldcheck = component.find('fieldcheck'); 
        if(!$A.util.isUndefinedOrNull(fieldcheck) && !$A.util.isUndefinedOrNull(fieldcheck.length)){
            isvalidate = fieldcheck.reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                if($A.util.isUndefinedOrNull(inputCmp.get('v.validity'))){
                    return false;
                }else{
                    return validSoFar && !inputCmp.get('v.validity').valueMissing;
                }
                
            }, true);
        }else if(!$A.util.isUndefinedOrNull(fieldcheck)){
            var value = fieldcheck.get('v.value');
            if($A.util.isUndefinedOrNull(value)) {
                fieldcheck.set('v.validity', {valid:false, badInput :true});
                fieldcheck.showHelpMessageIfInvalid();
                isvalidate =false;
            }
        }

        component.set("v.empListSize", lstSize+1);
        component.set("v.showError", false);
        if((lstSize < employmentsList.length && !result) || isShowPreEmpHistory || !isvalidate){
            component.set("v.showError", true);
            component.set("v.errorMsg", "Please update the form entries highlighted in red and try again");
        }else if(lstSize == employmentsList.length-1 && !component.get("v.showError")){
            if(applicantGrpValue== 'applicant1' && selectedPerson == 'joint'){
                component.set("v.applicantGrpValue","applicant2");
            }else{
                helper.toggleSpinner(component, event);
                helper.upsertEmploymentsDetail(component, event, true, false);
            }
        }
        helper.scrollTop(component, event, 315);
    },
    
    saveApplication: function(component, event, helper) {
        var args = event.getParam("arguments");
        var isShare = args.isShare;
        var isNext = args.isNext;
        helper.toggleSpinner(component, event);
        helper.scrollTop(component, event, 315);
        helper.upsertEmploymentsDetail(component, event, isNext, isShare);
    },
    
    changeMonthYear : function(component, event, helper) {
        var appNo = event.getParam("applicantNo");
        if(appNo == 1){
            var empList = component.get("v.employmentsList1");
            helper.checkMonthYear(component, event, empList[0], appNo);
        }else if(appNo == 2){
            var empList = component.get("v.employmentsList2");
            helper.checkMonthYear(component, event, empList[0], appNo);
        }

    }, 
    
    prevSave: function(component, event, helper) {
        var recordId =component.get("v.recordId");
        
        var applicantGrpValue = component.get("v.applicantGrpValue");
        var selectedPerson = component.get("v.selectedPerson");
        if(applicantGrpValue== 'applicant2' && selectedPerson == 'joint'){
            component.set("v.applicantGrpValue","applicant1");
        }else{
            helper.toggleSpinner(component, event);
            helper.SavePrev(component, event, recordId);
        }
        helper.scrollTop(component, event, 315);
    },
     
    addPreEmployment : function(component, event, helper) {
        helper.addPreEmp(component, event, 1);
    },
    addPreEmployment2 : function(component, event, helper) {
        helper.addPreEmp(component, event, 2);
    },
})