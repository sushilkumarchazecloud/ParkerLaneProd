({
    getEmploymentDetails : function(component, event) {
        
        var action = component.get("c.getEmploymentDetails");
        var self = this;
        action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                }else{
                    component.set('v.applicant1', ret.applicant1);
                    
                    if($A.util.isUndefinedOrNull(component.get('v.applicant1').FinServ__Employment__r)){
                        component.set('v.employmentsList1', []);
                        self.addIncome(component, event, 1);
                    }else{
                        component.set('v.employmentsList1', component.get('v.applicant1').FinServ__Employment__r);
                        var emp = component.get("v.employmentsList1");
                        
                        if($A.util.isUndefinedOrNull(emp[0].Months_1_Previous__c)){
                            emp[0].Months_1_Previous__c = '0';
                        }
                        
                        if($A.util.isUndefinedOrNull(emp[0].Years_1_Previous__c)){
                            emp[0].Years_1_Previous__c = '0';
                        }
                        
                        emp[0].Months_1_Previous__c = ''+emp[0].Months_1_Previous__c;
                        emp[0].Years_1_Previous__c = ''+emp[0].Years_1_Previous__c;
                        
                        if(emp[0].Months_1_Previous__c != '0' || emp[0].Years_1_Previous__c != '0'){
                            self.addPreEmp(component, event, 1);
                        }
                        
                        if($A.util.isUndefinedOrNull(emp[0].Months_2_Previous__c)){
                            emp[0].Months_2_Previous__c = '0';
                        }
                        
                        if($A.util.isUndefinedOrNull(emp[0].Years_2_Previous__c)){
                            emp[0].Years_2_Previous__c = '0';
                        }
                        
                        emp[0].Months_2_Previous__c = ''+emp[0].Months_2_Previous__c;
                        emp[0].Years_2_Previous__c = ''+emp[0].Years_2_Previous__c;
                        
                        if(emp[0].Months_2_Previous__c != '0' || emp[0].Years_2_Previous__c != '0'){
                            self.addPreEmp(component, event, 1);
                        }
                    }
                    
                    if(!$A.util.isUndefinedOrNull(ret.applicant2)){
                        
                        component.set('v.selectedPerson', 'joint');
                        var ops = [];
                        ops.push({ label: ret.applicant1.Name, value: "applicant1"});
                        ops.push({ label: ret.applicant2.Name, value: "applicant2"});
                        
                        component.set("v.applicantNameOptions",ops);
                        component.set('v.applicant2', ret.applicant2);
                        
                        if($A.util.isUndefinedOrNull(component.get('v.applicant2').FinServ__Employment__r)){
                            component.set('v.employmentsList2', []);
                            self.addIncome(component, event, 2);
                        }else{
                            component.set('v.employmentsList2', component.get('v.applicant2').FinServ__Employment__r);
                            var emp = component.get("v.employmentsList2");
                            
                            if($A.util.isUndefinedOrNull(emp[0].Months_1_Previous__c)){
                                emp[0].Months_1_Previous__c = '0';
                            }
                            
                            if($A.util.isUndefinedOrNull(emp[0].Years_1_Previous__c)){
                                emp[0].Years_1_Previous__c = '0';
                            }
                            
                            emp[0].Months_1_Previous__c = ''+emp[0].Months_1_Previous__c;
                            emp[0].Years_1_Previous__c = ''+emp[0].Years_1_Previous__c;
                            
                            if(emp[0].Months_1_Previous__c != '0' || emp[0].Years_1_Previous__c != '0'){
                                self.addPreEmp(component, event, 2);
                            }
                            
                            if($A.util.isUndefinedOrNull(emp[0].Months_2_Previous__c)){
                                emp[0].Months_2_Previous__c = '0';
                            }
                            
                            if($A.util.isUndefinedOrNull(emp[0].Years_2_Previous__c)){
                                emp[0].Years_2_Previous__c = '0';
                            }
                            
                            emp[0].Months_2_Previous__c = ''+emp[0].Months_2_Previous__c;
                            emp[0].Years_2_Previous__c = ''+emp[0].Years_2_Previous__c;
                            
                            if(emp[0].Months_2_Previous__c != '0' || emp[0].Years_2_Previous__c != '0'){
                                self.addPreEmp(component, event, 2);
                            }
                        }
                    }
                }
            }
            self.toggleSpinner(component, event);
            self.scrollTop(component, event, 315);
        });
        $A.enqueueAction(action);
    },
    
    upsertEmploymentsDetail: function (component, event, isNext, isShare) {
        
        var action = component.get("c.upsertEmploymentDetails");
        var self = this;
        var oppId = component.get('v.recordId');
        
        action.setParams({
            con1: component.get('v.applicant1'),
            con2: component.get('v.applicant2'),
            employmentDetailsList1: component.get('v.employmentsList1'),
            employmentDetailsList2: component.get('v.employmentsList2'), 
            oppId : oppId,
            isOppUpdate : isNext,
            isShare : isShare
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                }else{
                    component.set('v.applicationSection', JSON.parse(ret).CurrentSection);
                    component.set('v.appSectionPath', JSON.parse(ret).path);
                }
            }
            self.toggleSpinner(component, event);
            self.scrollTop(component, event, 315);
        });
        $A.enqueueAction(action);
    },
    
    doValidation: function(component, event){
        var applicantGrpValue = component.get("v.applicantGrpValue");
        var selectedPerson = component.get("v.selectedPerson");
        var myEvent = $A.get("e.c:validateAppEvent");
        var appNo = 1;
        if(applicantGrpValue== 'applicant2' && selectedPerson == 'joint'){
            appNo = 2;
        }
        myEvent.setParams({"applicantNo" : appNo});
        myEvent.fire();
        component.set("v.empListSize", 0);
    },
    
    addIncome: function(component, event, appNo) {
        
        var employmentsList = component.get("v.employmentsList" + appNo);
        var applicant = component.get("v.applicant" + appNo);
        employmentsList.push({
            'sobjectType': 'FinServ__Employment__c',
            'FinServ__Contact__c': applicant.Id,
            'FinServ__EmploymentStatus__c': '',
            "Years__c":"0","Months__c":"0"
        });
        component.set("v.employmentsList" + appNo, employmentsList);
    },
    
    addPreEmp : function(component, event, appNo) {
        var preEmpList = component.get("v.preEmpList" + appNo);
        preEmpList.push({
            'incomeFrom': '',
            'occupation': '',
            'empName': '',
            'annualIncome': '',
            'years':'0',
            'months':'0'
        });
        
        component.set("v.preEmpList" + appNo, preEmpList);
        if(preEmpList.length>1){
            component.set("v.showPreviousEmpHistory" + appNo, false);
        }
    }, 
    
    checkMonthYear : function(component, event, emp, appNo) {
        var totalMonths = 0;
        if(!$A.util.isUndefinedOrNull(emp.Months__c)){
            totalMonths += parseInt(emp.Months__c);
        }
        if(!$A.util.isUndefinedOrNull(emp.Months_1_Previous__c)){
            totalMonths += parseInt(emp.Months_1_Previous__c);
        }
        if(!$A.util.isUndefinedOrNull(emp.Months_2_Previous__c)){
            totalMonths += parseInt(emp.Months_2_Previous__c);
        }
        if(!$A.util.isUndefinedOrNull(emp.Years__c)){
            totalMonths += (parseInt(emp.Years__c) * 12);
        }
        if(!$A.util.isUndefinedOrNull(emp.Years_1_Previous__c)){
            totalMonths += (parseInt(emp.Years_1_Previous__c) * 12);
        }
        if(!$A.util.isUndefinedOrNull(emp.Years_2_Previous__c)){
            totalMonths += (parseInt(emp.Years_2_Previous__c) * 12);
        }
        
        var preEmpList = component.get("v.preEmpList"  + appNo);
        if(totalMonths<36 && preEmpList.length<2){
            component.set("v.showPreviousEmpHistory" + appNo, true);
        }else{
            component.set("v.showPreviousEmpHistory" + appNo, false);
        }
    },
    
    SavePrev : function(component, event, recordId) {
        var action = component.get("c.previous");
        var self = this;
        
        action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                }else{
                    component.set('v.applicationSection', JSON.parse(ret).CurrentSection);
                    component.set('v.appSectionPath', JSON.parse(ret).path);
                    self.upsertEmploymentsDetail(component, event, false, false);
                }
            }
            self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
    },
    
    scrollTop: function (component, event, top){
        var scrollOptions = {
            left: 0,
            top: top,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    },
    
    toggleSpinner: function (component, event) {            
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
})