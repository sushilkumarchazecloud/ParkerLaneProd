({
	doInit : function(component, event, helper) {
        helper.toggleSpinner(component, event);
        helper.getAssetLiabilities(component, event);
        helper.getSelPerson(component, event);
        helper.scrollTop(component, event, 70);
        var today = new Date();
        var currentYear = today.getFullYear();
        var applicant = component.get("v.applicant");
        var selectedPerson = component.get("v.selectedPerson");
        var applicantNo = component.get("v.applicantNo");
        var maritalStatusOptions = [];
        
        if(!$A.util.isUndefinedOrNull(selectedPerson) && selectedPerson == 'single'){
            component.set("v.OwnershipOptions", []);
            var JointWithSpouse = '';
            if(applicant.MaritalStatus__c == 'Married / defacto' || applicant.MaritalStatus__c == 'Married' || applicant.MaritalStatus__c == 'Divorced'){
                JointWithSpouse = 'Joint with Spouse';
            }
            var applicant1optionslist = ['Applicant 1', JointWithSpouse, 'Joint with other']; 
            applicant1optionslist.forEach(function(item){ 
                if(!$A.util.isEmpty(item)){
                    helper.applicant1options(component, event, ''+item);
                }
                
            });
           
        }
         var highlight = component.find('changeIt');
         $A.util.addClass(highlight, 'highlightOnselect');
        
        if(!$A.util.isUndefinedOrNull(applicant.NumberOfChildren__c )){
            applicant.NumberOfChildren__c = ''+ applicant.NumberOfChildren__c;
            applicant.Gender__c = ''+ applicant.Gender__c;
            component.set("v.applicant", applicant);
            $A.util.removeClass(highlight, 'highlightOnselect');
        }
        
        
       
        maritalStatusOptions.push({"label": "Single", "value": "Single"});
        if(selectedPerson != 'joint'){
            maritalStatusOptions.push({"label": "Married / defacto", "value": "Married / defacto"});
        }else{
            maritalStatusOptions.push({"label": "Married / defacto (non-applicant)", "value": "Married / defacto (non-applicant)"});
            if(applicantNo == '1'){
                maritalStatusOptions.push({"label": "Married / Defacto (to applicant 2)", "value": "Married / Defacto (to applicant 2)"});
            }else if(applicantNo == '2'){
                maritalStatusOptions.push({"label": "Married / Defacto (to applicant 1)", "value": "Married / Defacto (to applicant 1)"});
            }
        }
        maritalStatusOptions.push({"label": "Divorced", "value": "Divorced"});
        maritalStatusOptions.push({"label": "Separated", "value": "Separated"});
        maritalStatusOptions.push({"label": "Widowed", "value": "Widowed"});
    
        component.set("v.maritalStatusOptions", maritalStatusOptions);
        
       
        if((!$A.util.isUndefinedOrNull(applicant.Year_1__c) && applicant.Year_1__c > 0)){
            helper.addPreAdd(component, event);
        }
        
        
        applicant.Months__c = "0";
        applicant.Months_1__c = "0";
        
         
        
        component.set("v.applicant", applicant);
        helper.checkMonthYear(component, event);
        
    },
    
    checkAboutDetails : function(component, event, helper) {
        var applicant = component.get("v.applicant");
        var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        var applicantDetailAdd = component.find("appDetailAddress");
        var applicantDetailAdd1 = component.find("appDetailAddress1");
        var applicantDetailAdd2 = component.find("appDetailAddress2");
        var addressTool = component.find("postalAddressTool");
        var isvalidate = true;
        var isvalidate1 = true;
        var isvalidate2 = true;
        var isvalidateSameAdd = true;
        var isvalidate3 = true;

        if(!$A.util.isUndefinedOrNull(applicantDetailAdd)){
            isvalidate = applicantDetailAdd.checkDetailsAddress();
        }

        if(!$A.util.isUndefinedOrNull(applicantDetailAdd1)){
            isvalidate1 = applicantDetailAdd1.checkDetailsAddress();
        }

        if(!$A.util.isUndefinedOrNull(applicantDetailAdd2)){
            isvalidate2 = applicantDetailAdd2.checkDetailsAddress();
        }
        
        if(!$A.util.isUndefinedOrNull(addressTool)){
            isvalidate3 = addressTool.checkAddress();
        }
        
        helper.checkMonthYear(component, event);

        if(!applicant.Is_Previous_Address_Same__c){
            isvalidateSameAdd = (!component.get("v.showPreviousAdd"));
        }
        if(applicant.isFindPostalAdd__c && isvalidate3){
            var searchString = '';
            var boxType = applicant.Postal_Box_Type__c;
            var number = applicant.Postal_Number__c;
            var suburb = applicant.Postal_Suburb__c;
            var state = applicant.Postal_State__c;
            var postalCode = applicant.Postal_Postal_Code__c;
            var unitNumber = applicant.Postal_Unit_Number__c;
            var streetNumber = applicant.Postal_Street_Number__c;
            var street = applicant.Postal_Street__c;
            var streetType = applicant.Postal_Street_Type__c;
            var isPOBox = applicant.Postal_address_is_PO_or_GPO_box__c;
            var country = applicant.Postal_Country__c;
            if(!$A.util.isUndefinedOrNull(isPOBox) && isPOBox){
                if(!$A.util.isUndefinedOrNull(boxType)){
                    searchString += boxType + ' ';
                }
                if(!$A.util.isUndefinedOrNull(number)){
                    searchString += number + ' ';
                }
                searchString += suburb + ' ' + state + ' ' + postalCode;
            }else{
                if(!$A.util.isUndefinedOrNull(unitNumber)){
                    searchString = unitNumber + ' ';
                }
                searchString += streetNumber + ' ' + street + ' ' + streetType + ' '+ 
                    suburb + ' ' + state + ' ' + country + ' ' + postalCode;
            }
            
            applicant.Postal_Address__c = searchString;
            component.set("v.applicant", applicant);
        }
        
        var propertyValid = true;
        
        var selectedPerson = component.get("v.selectedPerson");
        if(allValid && isvalidate && isvalidate1 && isvalidate2 && isvalidate3 && isvalidateSameAdd /*&& propertyValid*/)
        {
            helper.upsertOppAssetsAndLiabilities(component, event,false,false);
            if(!$A.util.isUndefinedOrNull(selectedPerson)){
                helper.setSameAddressOrDependentChildren(component,selectedPerson); 
            }
            
        }        
        return allValid && isvalidate && isvalidate1 && isvalidate2 && isvalidate3 && isvalidateSameAdd;
    },
    
    changeMonthYear : function(component, event, helper) {
        helper.checkMonthYear(component, event);
    },
    
    addAddress : function(component, event, helper) {
        helper.addPreAdd(component, event);
    },
    changeRelationship : function(component, event, helper) {
        var applicantNo = component.get("v.applicantNo");
        component.set("v.relationship", applicantNo + '----' + component.get("v.applicant.MaritalStatus__c"));
    },
    setBirthday : function(component, event, helper) {
        var applicant = component.get("v.applicant");
        var year = component.get("v.birthYear");
        var month = component.get("v.birthMonth");
        var day = component.get("v.birthDay");
        if(!$A.util.isUndefinedOrNull(year) && !$A.util.isUndefinedOrNull(month) && !$A.util.isUndefinedOrNull(day)){
            var birthday = year + "-" + month + "-" + day;
            applicant.Birthdate = birthday;
            component.set("v.applicant", applicant);
        }
    },
    
    changeDependent: function(component, event) {
    
        var highlight = component.find('changeIt');
        var applicant = component.get("v.applicant");
        var applicantChildren = component.get("v.applicantChildren");
        var sel= applicant.NumberOfChildren__c;
        var len=0;
        if(applicantChildren.length>sel){
            len = applicantChildren.length - sel;
            for(var i= 1; i<=len;i++){
                applicantChildren.pop();
            }
        }else if(applicantChildren.length<sel){
            len = sel -applicantChildren.length;
            for(var i= 1; i<=len;i++){
                applicantChildren.push({
                    'sobjectType': 'Contact'
                });
            }
        }
        component.set("v.applicantChildren", []);
        
        
        component.set("v.applicantChildren", applicantChildren);
        if(applicantChildren.length>=0)
        {
             $A.util.removeClass(highlight, 'highlightOnselect');
        }
       
    },
    
    deleteRow: function(component, event,helper) {
        var index = event.getParam("indexVar");
        var rowType = event.getParam("rowType");
        if(rowType === 'applicantAddress'){
            var addressList = component.get("v.addressList");
            addressList.splice(index,1);            
            component.set("v.addressList", addressList);

            if(addressList.length<1){
                helper.checkMonthYear(component, event);
            }
        }
    },
    setSamePreviosAddress : function(component, event, helper) {
        var applicant = component.get("v.applicant");

        if(applicant.Is_Previous_Address_Same__c){
            var applicant1 = component.get("v.applicant1");
            if(!$A.util.isUndefinedOrNull(applicant1.Months_1__c) || !$A.util.isUndefinedOrNull(applicant1.Year_1__c)){
                helper.addPreAdd(component, event);
            }
            if(!$A.util.isUndefinedOrNull(applicant1.Months_2__c) || !$A.util.isUndefinedOrNull(applicant1.Year_2__c)){
                helper.addPreAdd(component, event);
            }
            
            applicant.Year_1__c = applicant1.Year_1__c;
            applicant.Months_1__c = applicant1.Months_1__c;
            applicant.Is_Find_Address_1__c = applicant1.Is_Find_Address_1__c;
            applicant.Residential_Address_1__c = applicant1.Residential_Address_1__c;
            applicant.Unit_Number_1__c = applicant1.Unit_Number_1__c;
            applicant.Street_Number_1__c = applicant1.Street_Number_1__c;
            applicant.Street_1__c = applicant1.Street_1__c;
            applicant.Street_Type_1__c = applicant1.Street_Type_1__c;
            applicant.Suburb_1__c = applicant1.Suburb_1__c;
            applicant.State_1__c = applicant1.State_1__c;
            applicant.Postal_Code_1__c = applicant1.Postal_Code_1__c;
            applicant.Country_1__c = applicant1.Country_1__c;
            
            applicant.Year_2__c = applicant1.Year_2__c;
            applicant.Months_2__c = applicant1.Months__c;
            applicant.Is_Find_Address_2__c = applicant1.Is_Find_Address_2__c;
            applicant.Residential_Address_2__c = applicant1.Residential_Address_2__c;
            applicant.Unit_Number_2__c = applicant1.Unit_Number_2__c;
            applicant.Street_Number_2__c = applicant1.Street_Number_2__c;
            applicant.Street_2__c = applicant1.Street_2__c;
            applicant.Street_Type_2__c = applicant1.Street_Type_2__c;
            applicant.Suburb_2__c = applicant1.Suburb_2__c;
            applicant.State_2__c = applicant1.State_2__c;
            applicant.Postal_Code_2__c = applicant1.Postal_Code_2__c;
            applicant.Country_2__c = applicant1.Country_2__c;
            
            component.set("v.applicant", applicant);
            component.set("v.showPreviousAdd", false);
        }else{
            applicant.Year_1__c = "";
            applicant.Months_1__c = "";
            applicant.Is_Find_Address_1__c = false;
            applicant.Residential_Address_1__c = "";
            applicant.Unit_Number_1__c = "";
            applicant.Street_Number_1__c = "";
            applicant.Street_1__c = "";
            applicant.Street_Type_1__c = "";
            applicant.Suburb_1__c = "";
            applicant.State_1__c = "";
            applicant.Postal_Code_1__c = "";
            applicant.Country_1__c = "";
            
            applicant.Year_2__c = "";
            applicant.Months_2__c = "";
            applicant.Is_Find_Address_2__c = false;
            applicant.Residential_Address_2__c = "";
            applicant.Unit_Number_2__c = "";
            applicant.Street_Number_2__c = "";
            applicant.Street_2__c = "";
            applicant.Street_Type_2__c = "";
            applicant.Suburb_2__c = "";
            applicant.State_2__c = "";
            applicant.Postal_Code_2__c = "";
            applicant.Country_2__c = "";
            component.set("v.applicant", applicant);
            var addressList = [];
            component.set("v.addressList",addressList);
            component.set("v.showPreviousAdd", true);
        }
    },
    
    deleteProperty:function(component, event, helper){
        component.set("v.isOpenAlertModal", true); 
        component.set("v.deleteIndex" ,event.currentTarget.id);
    },
    doCalculation: function(component, event, helper) {
        helper.doCalculation(component);
    },
    closeAlertModel:function(component, event, helper) {
        component.set("v.isOpenAlertModal", false); 
    },
    deleteAssetLiability:function(component, event, helper) {
        component.set("v.isOpenAlertModal", false); 
        helper.deletePropertydata(component, event, component.get("v.deleteIndex"), 'propertysList');
    },
    addPropertyOnYes:function(component, event, helper){
        var propertyList = component.get("v.propertysList");
        if(propertyList.length == 0){
            helper.addMoreProperty(component, event,"propertysList","Investment Property");
        }
    },
    addMoreProperty:function(component,event,helper){
        helper.addMoreProperty(component, event,"propertysList","Investment Property");
    },
   
    
    
})