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
                        if($A.util.isUndefinedOrNull(emp[0].Employment_Status_1_Previous__c)){
                            emp[0].Employment_Status_1_Previous__c = '';
                        }
                        
                        emp[0].Months_1_Previous__c = ''+emp[0].Months_1_Previous__c;
                        emp[0].Years_1_Previous__c = ''+emp[0].Years_1_Previous__c;
                        
                        //added for previous emploment  
                        if(!$A.util.isUndefinedOrNull(emp[0].Employment_Status_1_Previous__c)){
                            component.set("v.incomeFromPreviousEmployee1",emp[0].Employment_Status_1_Previous__c);
                        }
                        //added for previous emploment  
                        if(emp[0].Months_1_Previous__c != '0' || emp[0].Years_1_Previous__c != '0'){
                            self.addPreEmp(component, event, 1);
                        }
                        
                        if($A.util.isUndefinedOrNull(emp[0].Months_2_Previous__c)){
                            emp[0].Months_2_Previous__c = '0';
                        }
                        
                        if($A.util.isUndefinedOrNull(emp[0].Years_2_Previous__c)){
                            emp[0].Years_2_Previous__c = '0';
                        }
                        if($A.util.isUndefinedOrNull(emp[0].Employment_Status_2_Previous__c)){
                            emp[0].Employment_Status_2_Previous__c = '';
                        }
                    
                        emp[0].Months_2_Previous__c = ''+emp[0].Months_2_Previous__c;
                        emp[0].Years_2_Previous__c = ''+emp[0].Years_2_Previous__c;
                      //added for previous emploment  
                         if(!$A.util.isUndefinedOrNull(emp[0].Employment_Status_2_Previous__c)){
                            component.set("v.incomeFromPreviousEmployee1",emp[0].Employment_Status_2_Previous__c);
                        }
                       //added for previous emploment  
                        if(emp[0].Months_2_Previous__c != '0' || emp[0].Years_2_Previous__c != '0'){
                            self.addPreEmp(component, event, 1);
                        }
                        this.totalPersonalIncome(component);
                        self.checkMonthYear(component, event, emp[0], 1);
                    }
                    
                    if(!$A.util.isUndefinedOrNull(ret.applicant2)){
                        
                        component.set('v.selectedPerson', 'joint');
                        var ops = [];
                        ops.push({ label: ret.applicant1.FirstName, value: "applicant1"});
                        ops.push({ label: ret.applicant2.FirstName, value: "applicant2"});
                        
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
                            
                            //added for previous emploment status 
                            if(!$A.util.isUndefinedOrNull(emp[0].Employment_Status_1_Previous__c)){
                                component.set("v.incomeFromPreviousEmployee2",emp[0].Employment_Status_1_Previous__c);
                            }
                        	//end for previous emploment  
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
                            
                            //added for previous emploment status  
                            if(!$A.util.isUndefinedOrNull(emp[0].Employment_Status_2_Previous__c)){
                                component.set("v.incomeFromPreviousEmployee2",emp[0].Employment_Status_2_Previous__c);
                            }
                        	//end  
                            if(emp[0].Months_2_Previous__c != '0' || emp[0].Years_2_Previous__c != '0'){
                                self.addPreEmp(component, event, 2);
                            }
                            this.totalPersonalIncome(component);
                            self.checkMonthYear(component, event, emp[0], 2);
                        }
                    }
                }
             self.getOppContacts(component);}
            self.toggleSpinner(component, event);
            self.scrollTop(component, event, 70);
        });
        $A.enqueueAction(action);
    },
    
    upsertEmploymentsDetail: function (component, event, isNext, isShare) {
        
        var action = component.get("c.upsertEmploymentDetails");
        var self = this;
        var oppId = component.get('v.recordId');
           
        var employmentsList1 = component.get('v.employmentsList1');
        var employmentsList2 = component.get('v.employmentsList2');
        
        self.upsertOppCons(component, event, false, isShare);
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
            console.log('@@@@state----------' + state);
            
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
            self.scrollTop(component, event, 70);
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
        var incomeFrom =  component.get("v.incomeFrom"+appNo);
        var isprimary = false;
        if(employmentsList.length == 0){
            isprimary = true;
        }
        employmentsList.push({
            'sobjectType': 'FinServ__Employment__c',
            'FinServ__Contact__c': applicant.Id,
            'FinServ__EmploymentStatus__c': incomeFrom,
            "Years__c":" ",
            "Months__c":"0",
            "Is_Primary__c": isprimary
        });
        component.set("v.employmentsList"+ appNo, employmentsList);
        component.set("v.incomeFrom"+appNo,"");
        
    },
    
    addPreEmp : function(component, event, appNo) {
        var preEmpList = component.get("v.preEmpList" + appNo);
        var incomeFromPreviousEmployee = component.get("v.incomeFromPreviousEmployee"+appNo);
       console.log('----------------------'+incomeFromPreviousEmployee);
        preEmpList.push({
            'incomeFrom': incomeFromPreviousEmployee,
            'occupation': '',
            'empName': '',
            'annualIncome': '',
            'years':'0',
            'months':'0'
        });

        component.set("v.preEmpList" + appNo, preEmpList); 
        component.set("v.incomeFromPreviousEmployee"+appNo,"");
        var employmentsList = component.get("v.employmentsList"+ appNo);
        if(preEmpList.length==1){
            
            /*employmentsList[0].Employment_Status_2_Previous__c = incomeFromPreviousEmployee;*/
            employmentsList[0].Employment_Status_1_Previous__c = incomeFromPreviousEmployee;	
            component.set("v.showPreviousEmpHistory" + appNo, false); 
        }
        component.set("v.employmentsList" + appNo, employmentsList);
    }, 
    
    checkMonthYear : function(component, event, emp, appNo) {
        var totalMonths = 0;
        console.log('------');
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
            if(emp.Years__c == 6){
                totalMonths += parseInt(emp.Years__c);
            }
            else{
                totalMonths += (parseInt(emp.Years__c) * 12);
            }
            
        }
        if(!$A.util.isUndefinedOrNull(emp.Years_1_Previous__c)){
            if(emp.Years_1_Previous__c == 6){
                totalMonths += parseInt(emp.Years_1_Previous__c);
            }
            else{
                totalMonths += (parseInt(emp.Years_1_Previous__c) * 12);
            }
            //totalMonths += (parseInt(emp.Years_1_Previous__c) * 12);
        }
        if(!$A.util.isUndefinedOrNull(emp.Years_2_Previous__c)){
            if(emp.Years_2_Previous__c == 6){
                totalMonths += parseInt(emp.Years_2_Previous__c);
            }
            else{
                totalMonths += (parseInt(emp.Years_2_Previous__c) * 12);
            }
            //totalMonths += (parseInt(emp.Years_2_Previous__c) * 12);
        }
        console.log('totalMonths'+totalMonths);
        var preEmpList = component.get("v.preEmpList"  + appNo);
        if(totalMonths<36 && preEmpList.length==0){
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
            console.log('@@@@@@' +state);
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
        var isMoile = false;
        if(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)){
            isMoile = true;
            top += 100;
        }else{
            isMoile = false;
        }
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
    totalPersonalIncome:function(component) {
        
        var employment1 = component.get("v.employmentsList1");
        var employment2 = component.get("v.employmentsList2");
        var totalAmt = 0;
        var totalhouseholdAmt = 0;
        
       
        employment1.forEach(function(item){
            if(item.FinServ__AnnualIncome__c){
                if(!$A.util.isUndefinedOrNull(item.Income_Frequency__c)){
                    if(item.Income_Frequency__c == 'Weekly'){
                        totalAmt += parseFloat(item.FinServ__AnnualIncome__c)*52/12;
                    }
                    else if(item.Income_Frequency__c == 'Fortnightly'){
                        totalAmt += parseFloat(item.FinServ__AnnualIncome__c)*26/12;
                    }
                    else if(item.Income_Frequency__c == 'Monthly'){
                         totalAmt += parseFloat(item.FinServ__AnnualIncome__c);
                    }
                    else if(item.Income_Frequency__c == 'Annually'){
                         totalAmt += parseFloat(item.FinServ__AnnualIncome__c)/12;
                     }
                }
                
                //totalAmt += parseFloat(item.FinServ__AnnualIncome__c)*12;
            } 
        });
        employment2.forEach(function(item){
            if(item.FinServ__AnnualIncome__c){
                totalhouseholdAmt += parseFloat(item.FinServ__AnnualIncome__c) + totalAmt;
            }
        });
        component.set("v.totalAmount",totalAmt*12);
        component.set("v.totalHousholdAmount",totalhouseholdAmt);
    },
    deleteRecords:function(component,event,ids){

        var action = component.get("c.deleteRecordsByIds");
        var self = this;
        action.setParams({
            recordIdsList: ids
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('@@@@state----------' + state);
            if (state === "ERROR") {
                component.set("v.showError", true);
                component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
            }
            
        });
        $A.enqueueAction(action);
    },
    deleteEmploymentDetails:function(component, event, index, deleteListType){
         var ids = [];
        var self = this;
        
        var deleteList = component.get("v." + deleteListType);
       
        if(!$A.util.isUndefinedOrNull(deleteList[index].Id)){
            ids.push(deleteList[index].Id);
            self.deleteRecords(component, event, ids);
        }
    },
    deleteEmploymentPrevioudAddress:function(component,event,index,employmentsList){
        var employmentsList = component.get("v." + employmentsList);
        if(!$A.util.isUndefinedOrNull(employmentsList[0])){
            employmentsList[0].Employment_Status_1_Previous__c = "";
            employmentsList[0].Employer_Name_1_Previous__c= "";
            employmentsList[0].Years_1_Previous__c = "0";
            employmentsList[0].Months_1_Previous__c = "0";
            employmentsList[0].Annual_Income_1_Previous__c = "";
            employmentsList[0].Occupation_1_Previous__c = "";
            employmentsList[0].Address_1_Previous__c = "";
            employmentsList[0].Is_Find_Address_1__c = "";
            employmentsList[0].Unit_Number_1__c = "";
            employmentsList[0].Street_Number_1__c = "";
            employmentsList[0].Street_Type_1__c = "";
            employmentsList[0].Street_1__c = "";
            employmentsList[0].Suburb_1__c= "";
            employmentsList[0].State_1__c= "";
            employmentsList[0].Postal_Code_1__c= "";
            employmentsList[0].Country_1__c= "";
            employmentsList[0].Income_Frequency_1__c="";
            component.set("v."+employmentsList, employmentsList);
        }
       /* if(!$A.util.isUndefinedOrNull(employmentsList[0].Employment_Status_2_Previous__c)){
			employmentsList[0].Employment_Status_2_Previous__c = '';
            employmentsList[0].Employer_Name_2_Previous__c= '';
            employmentsList[0].Years_2_Previous__c = '';
            employmentsList[0].Months_2_Previous__c = '';
            employmentsList[0].Annual_Income_2_Previous__c = '';
            employmentsList[0].Occupation_2_Previous__c = '';
            employmentsList[0].Income_Frequency__c = '';
            employmentsList[0].Address_2_Previous__c = '';
            employmentsList[0].Is_Find_Address_2__c = '';
            employmentsList[0].Unit_Number_2__c = '';
            employmentsList[0].Street_Number_2__c = '';
            employmentsList[0].Street_Type_2__c = '';
            employmentsList[0].Street_2__c = '';
            employmentsList[0].Suburb_2__c= '';
            employmentsList[0].State_2__c= '';
            employmentsList[0].Postal_Code_2__c= '';
            employmentsList[0].Country_2__c= '';
            component.set("v."+employmentsList, employmentsList);            
        }   */      

    },
    getOppContacts : function(component) {
		var action = component.get("c.getOppContacts");
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
                    component.set('v.opportunity', ret.opp);
                    if(ret.opp.Applicant_1__c != null || ret.opp.Applicant_2__c != null){
                        console.log('>>wqe>>>' + JSON.stringify(ret.app1Children));
                        console.log('>>>wqe22>>' + JSON.stringify(ret.app2Children));
                        component.set('v.app1Children', ret.app1Children);
                        component.set('v.app2Children', ret.app2Children);
                    }
                }
            }
        });
        $A.enqueueAction(action);
	},
    upsertOppCons: function (component, event, isOppUpdate, isShare) {
        var action = component.get("c.upsertOppContacts");
        var self = this;
        var opp = component.get('v.opportunity');      
     	action.setParams({
            con1 : component.get('v.applicant1'),
            con2 : component.get('v.applicant2'), 
            app1Children : component.get('v.app1Children'),
            app2Children : component.get('v.app2Children'),
            opp : opp,
            isOppUpdate : isOppUpdate,
            isShare : isShare
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('@@@@state----------' + state);
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                }
            }
            self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
    },
    
    
    
})