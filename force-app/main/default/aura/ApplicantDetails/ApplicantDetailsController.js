({
	doInit : function(component, event, helper) {
        var today = new Date();
        var currentYear = today.getFullYear();
        var applicant = component.get("v.applicant");
        var selectedPerson = component.get("v.selectedPerson");
        var applicantNo = component.get("v.applicantNo");
        var maritalStatusOptions = [];
        var days = [];
        var years = [];
        var mediExpYears =[];
        applicant.FinServ__NumberOfChildren__c = ''+ applicant.FinServ__NumberOfChildren__c;
        applicant.FinServ__Gender__c = ''+ applicant.FinServ__Gender__c;
        component.set("v.applicant", applicant);
        for (var i = 1; i <= 31; i++) {
            var dayStr='';
            if(i>0 && i<10){
                dayStr = '0';
            }
            var day = {
                "label": dayStr+i,
                "value": dayStr+i,
            };
            days.push(day);
        }
        component.set("v.birthDayOptions", days);
        
        const dToday = new Date();


        for (var i = dToday.getFullYear() - 100; i <= dToday.getFullYear() - 18; i++) {
            var year = {
                "label": i.toString(),
                "value": i.toString(),
            };
            years.push(year);
        }
        component.set("v.birthYearOptions", years);
        
        for (var i = currentYear; i <= currentYear+20; i++) {
            var year = {
                "label": i.toString(),
                "value": i.toString(),
            };
            mediExpYears.push(year);
        }
        component.set("v.MediExpYearOptions", mediExpYears);
       
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
        
        if(!$A.util.isUndefinedOrNull(applicant.Birthdate)){
            var birthday = (applicant.Birthdate).split("-");
            component.set("v.birthYear", birthday[0]);
            component.set("v.birthMonth", birthday[1]);
            component.set("v.birthDay", birthday[2]);
        }
        if((!$A.util.isUndefinedOrNull(applicant.Months_1__c) && applicant.Months_1__c > 0) || 
           !$A.util.isUndefinedOrNull(applicant.Year_1__c)){
            helper.addPreAdd(component, event);
        }
        
        if((!$A.util.isUndefinedOrNull(applicant.Months_2__c)  && applicant.Months_2__c > 0) || 
           !$A.util.isUndefinedOrNull(applicant.Year_2__c)){
            helper.addPreAdd(component, event);
        }
        
        if($A.util.isUndefinedOrNull(applicant.Months__c)){
            applicant.Months__c = "0";
        }
        if($A.util.isUndefinedOrNull(applicant.Months_1__c)){
            applicant.Months_1__c = "0";
        }
        if($A.util.isUndefinedOrNull(applicant.Months_2__c)){
            applicant.Months_2__c = "0";
        }
        if($A.util.isUndefinedOrNull(applicant.Medicare_Expiry_Month__c)){
            applicant.Medicare_Expiry_Month__c = "0";
        }else{
            applicant.Medicare_Expiry_Month__c = ("" +applicant.Medicare_Expiry_Month__c).length == 1 ? "0" + applicant.Medicare_Expiry_Month__c : "" + applicant.Medicare_Expiry_Month__c; 
        }
        if(!$A.util.isUndefinedOrNull(applicant.Medicare_Reference__c)){
            applicant.Medicare_Reference__c = "" +applicant.Medicare_Reference__c;
        }
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
        component.set("v.relationship", applicantNo + '----' + component.get("v.applicant.FinServ__MaritalStatus__c"));
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
        var applicant = component.get("v.applicant");
        var applicantChildren = component.get("v.applicantChildren");
        var sel= applicant.FinServ__NumberOfChildren__c;
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
    },
    
    deleteRow: function(component, event) {
        var index = event.getParam("indexVar");
        var rowType = event.getParam("rowType");
        if(rowType === 'applicantAddress'){
            var addressList = component.get("v.addressList");
            addressList.splice(index,1);
            component.set("v.addressList", addressList);
       
            if(addressList.length<2){
                component.set("v.showPreviousAdd", true);
            }
        }
    },
    
    setSameAddress : function(component, event, helper) {
        var applicant = component.get("v.applicant");

        if(applicant.Is_Address_Same__c){
            var applicant1 = component.get("v.applicant1");
            applicant.Living_Situation__c = applicant1.Living_Situation__c;
            applicant.Year__c = applicant1.Year__c;
            applicant.Months__c = applicant1.Months__c;
            applicant.Is_Find_Address__c = applicant1.Is_Find_Address__c;
            applicant.Residential_Address__c = applicant1.Residential_Address__c;
            applicant.Unit_Number__c = applicant1.Unit_Number__c;
            applicant.Street_Number__c = applicant1.Street_Number__c;
            applicant.Street__c = applicant1.Street__c;
            applicant.Street_Type__c = applicant1.Street_Type__c;
            applicant.Suburb__c = applicant1.Suburb__c;
            applicant.State__c = applicant1.State__c;
            applicant.Postal_Code__c = applicant1.Postal_Code__c;
            applicant.FinServ__CountryOfResidence__c = applicant1.FinServ__CountryOfResidence__c;
            applicant.FinServ__PrimaryAddressIsOther__c = applicant1.FinServ__PrimaryAddressIsOther__c;
            applicant.Postal_Address__c = applicant1.Postal_Address__c;
            applicant.isFindPostalAdd__c = applicant1.isFindPostalAdd__c;
            applicant.Postal_address_is_PO_or_GPO_box__c = applicant1.Postal_address_is_PO_or_GPO_box__c;
            applicant.Postal_Box_Type__c = applicant1.Postal_Box_Type__c;
            applicant.Postal_Number__c = applicant1.Postal_Number__c;
            applicant.Postal_Suburb__c = applicant1.Postal_Suburb__c;
            applicant.Postal_State__c = applicant1.Postal_State__c;
            applicant.Postal_Postal_Code__c = applicant1.Postal_Postal_Code__c;
            applicant.Postal_Country__c = applicant1.Postal_Country__c;
            applicant.Postal_PO_Box__c = applicant1.Postal_PO_Box__c;
            component.set("v.applicant", applicant);
            
        }else{
            applicant.Living_Situation__c="";
            applicant.Year__c = "";
            applicant.Months__c = "";
            applicant.Is_Find_Address__c = false;
            applicant.Residential_Address__c = "";
            applicant.Unit_Number__c = "";
            applicant.Street_Number__c = "";
            applicant.Street__c = "";
            applicant.Street_Type__c = "";
            applicant.Suburb__c = "";
            applicant.State__c = "";
            applicant.Postal_Code__c = "";
            applicant.FinServ__CountryOfResidence__c = "";
            applicant.FinServ__PrimaryAddressIsOther__c=false;
            applicant.Postal_Address__c="";
            applicant.isFindPostalAdd__c=false;
            applicant.Postal_address_is_PO_or_GPO_box__c = false;
            applicant.Postal_Box_Type__c = "";
            applicant.Postal_Number__c ="";
            applicant.Postal_Suburb__c="";
            applicant.Postal_State__c = "";
            applicant.Postal_Postal_Code__c = "";
            applicant.Postal_Country__c ="";
            applicant.Postal_PO_Box__c = "";
            component.set("v.applicant", applicant);
        }
        helper.checkMonthYear(component, event);
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
})