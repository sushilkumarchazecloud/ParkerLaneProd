({
    
    getAssetLiabilities : function(component, event) {
        var action = component.get("c.getAssetsAndLiabilities");
        var self = this;
        var propertyList = [];
        var assetList = [];
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
                    if(!$A.util.isUndefinedOrNull(ret.Asset)){
                        var allAssetList = ret.Asset;
                        allAssetList.forEach(function(item){
                            if(item.FinServ__AssetsAndLiabilitiesType__c == 'Investment Property'){
                                propertyList.push(item);
                            }else if(item.FinServ__AssetsAndLiabilitiesType__c == 'Home'){
                                component.set("v.homeAsset",item);
                            }
                             else if(item.FinServ__AssetsAndLiabilitiesType__c == 'Other'){
                                component.set("v.OtherAsset",item)    
                             
                            }else{
                                assetList.push(item);
                            }
                            
                        }); 
                        component.set('v.propertysList', propertyList);
                        component.set('v.assetsList', assetList);
                        
                    }else{
                        if(component.get("v.opportunity.Lender__c") == 'Transport Mutual Credit Union' || component.get("v.opportunity.Lender__c")== 'TMCU'){
                            var asset = {
                                'sobjectType': 'FinServ__AssetsAndLiabilities__c',
                                'FinServ__AssetsAndLiabilitiesType__c': 'Other',
                                'FinServ__Description__c':'Total non-property assets'
                            }; 
                            component.set("v.OtherAsset",asset);   
                        }
                        else{
                            var defaultAssets = ['Bank Account','Motor Vehicle','Superannuation','Home Contents']; 
                            defaultAssets.forEach(function(item){ 
                                self.addNewAsset(component, event, ''+item);
                            });
                        }
                    }
                    if(component.get("v.opportunity.Lender__c") == 'Transport Mutual Credit Union' || component.get("v.opportunity.Lender__c")== 'TMCU')
                    {
                        component.set('v.assetsList', []);
                    }
                    this.doCalculation(component);
                }
            }
            self.scrollTop(component, event, 70);
            self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
    },
    
    getSelPerson : function(component, event) {
        var action = component.get("c.getSelectedPerson");
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
                    component.set('v.selectedPerson', ret);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    addNewAsset: function(component, event, name) {
        var assetList = component.get('v.assetsList');
        var asset = {
            'sobjectType': 'FinServ__AssetsAndLiabilities__c',
            'FinServ__AssetsAndLiabilitiesType__c': name
        };
        assetList.push(asset);
        component.set('v.assetsList', assetList);
    },
    toggleSpinner: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
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
    AddClose: function(component, event, type) {
        var typesList = component.get("v." + type + "List");
        var typeSelected = component.get("v." + type + "Selected");
        var isEdit = component.get("v.isEdit");
        
        if($A.util.isUndefinedOrNull(typeSelected.Id) && !isEdit){
            typesList.push(typeSelected);
        }
        component.set("v." + type + "List", typesList);
        this.doCalculation(component);
    },
    upsertOppAssetsAndLiabilities: function (component, event, isNext, isShare) {
  		var self = this;
        var oppId = component.get('v.recordId');
        var applicant = component.get('v.applicant');
        var homeAsset  = component.get("v.homeAsset");
        var assetListdata = component.get('v.assetsList');     
        var OtherAsset  = component.get("v.OtherAsset");
     
        if(!$A.util.isUndefinedOrNull(assetListdata)){
            assetListdata.forEach(function(item) {
                if(item.FinServ__AssetsAndLiabilitiesType__c == 'Motor Vehicle'){
                    item.Make_Model__c = (item.Value__c!=null ? item.Value__c : '0') + '';
                    item.Year__c = new Date().getFullYear();
                    
                }
            });
        }
        
        if(!$A.util.isUndefinedOrNull(OtherAsset) && !$A.util.isEmpty(OtherAsset.Value__c)){
            assetListdata.push(OtherAsset);
        }
        if(applicant.Do_you_own_any_other_property__c == 'No'){
           self.deleteAllRecordorNO(component,event,"propertysList");
        }
        var homeAssetlist = [];
        homeAssetlist.push(homeAsset);
        component.set("v.homeAssetList",homeAssetlist);
        if(applicant.Living_Situation__c == 'Renting'){
            self.deleteAllRecordorNO(component,event,"homeAssetList");
        }
        else{
            applicant.Rental_Amount__c = '';
            applicant.Rental_Frequency__c = '';
            component.set('v.applicant',applicant);
            homeAsset.FinServ__AssetsAndLiabilitiesType__c = 'Home';
            homeAsset.Is_Find_Address__c = applicant.Is_Find_Address__c;
            homeAsset.Unit_Number__c = applicant.Unit_Number__c;
            homeAsset.Street_Number__c = applicant.Street_Number__c;
            homeAsset.Street__c = applicant.Street__c;
            homeAsset.State__c = applicant.State__c;
            homeAsset.Suburb__c = applicant.Suburb__c;
            homeAsset.Street_Type__c = applicant.Street_Type__c;
            homeAsset.Postal_Code__c = applicant.Postal_Code__c;
            homeAsset.Address__c = applicant.Residential_Address__c;
            homeAsset.Country__c = applicant.FinServ__CountryOfResidence__c;
            if(applicant.Living_Situation__c == 'Own home outright'){
                homeAsset.Property_Situation__c = 'Own outright';
            }else if(applicant.Living_Situation__c == 'Own home with mortgage'){
                homeAsset.Property_Situation__c = 'Own with mortgage';
            }
            assetListdata.push(homeAsset);
        }  
        
        var propertyList = component.get('v.propertysList');
        if(!$A.util.isUndefinedOrNull(propertyList)){
            propertyList.forEach(function(item) {
                assetListdata.push(item);
            });
        }
        component.set("v.allAssetsList", assetListdata);
    },
    deleteRecords: function (component, event, ids) {
        
        var action = component.get("c.deleteAssetAndLibByIds");
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
    deletePropertydata: function(component, event, index, deleteListType) {
        var ids = [];
        var self = this;
        
        var deleteList = component.get("v." + deleteListType);
       
        if(!$A.util.isUndefinedOrNull(deleteList[index].Id)){
            ids.push(deleteList[index].Id);
            self.deleteRecords(component, event, ids);
        }
        deleteList.splice(index,1);
        
        component.set("v." + deleteListType, deleteList);
        
    },
    deletePreviousAddress: function (component, event, applicant) {
        
        var action = component.get("c.deletePrevioudAddress");
        var self = this;
        action.setParams({
            applicant: applicant
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
    addPreAdd : function(component, event) {
        
        var addressList = component.get("v.addressList");
        addressList.push({
            'years':0,
            'months':0
        });
        component.set("v.addressList", addressList);
        if(addressList.length==1){
            component.set("v.showPreviousAdd" , false);
        }
    },
    
    checkMonthYear : function(component, event) {
        var totalMonths = 0;      
        var addressList = component.get("v.addressList");
        var applicant = component.get("v.applicant");
        
        if(!$A.util.isUndefinedOrNull(applicant.Year__c)){
            totalMonths += (parseInt(applicant.Year__c)* 12);
        }
        if(!$A.util.isUndefinedOrNull(applicant.Year_1__c)){
            totalMonths += (parseInt(applicant.Year_1__c) * 12);
        }
        
        if(totalMonths<36 && addressList.length == 0){
            component.set("v.showPreviousAdd", true);
        }else{   
            component.set("v.showPreviousAdd", false);
        }
    },
    
    deleteAllRecordorNO:function(component,event,deleteListType){
         var ids = [];
        var self = this;
        var deleteList = component.get("v." + deleteListType);
        if(!$A.util.isUndefinedOrNull(deleteList)){
            deleteList.forEach(function(item){
                if(!$A.util.isUndefinedOrNull(item.Id)){
                    ids.push(item.Id);
                }
            });
            if(ids.length>0){
                self.deleteRecords(component, event, ids);
            }
            component.set("v." + deleteListType, []);
        }
    },
    addMoreProperty:function(component,event,name,type){
        var propertyList = component.get("v."+ name);
        var property = {
            'sobjectType': 'FinServ__AssetsAndLiabilities__c',
            'FinServ__AssetsAndLiabilitiesType__c': type
        };
        propertyList.push(property);
        component.set("v."+ name, propertyList);
    },
    
    doCalculation: function(component) {
        var totalAssetsAmt = 0; 
        var homeAsset = component.get("v.homeAsset");
        var assetsList = component.get("v.assetsList");
        var propertysList = component.get("v.propertysList");
        
        if( !$A.util.isEmpty(homeAsset.Value__c)){
            totalAssetsAmt += parseFloat(homeAsset.Value__c);
        }
        
        if(component.get("v.opportunity.Lender__c") == 'Transport Mutual Credit Union' || component.get("v.opportunity.Lender__c") == 'TMCU'){
            var Total_non_property = component.get("v.OtherAsset.Value__c");
            if(!$A.util.isEmpty(Total_non_property)){
               totalAssetsAmt += parseFloat(Total_non_property);
            }
        }else if(!$A.util.isUndefinedOrNull(assetsList)){
            assetsList.forEach(function(item) {
                if( !$A.util.isEmpty(item.Value__c)){
                    totalAssetsAmt += parseFloat(item.Value__c);
                }
            });
        }
        if(!$A.util.isUndefinedOrNull(propertysList)){
            propertysList.forEach(function(item) {
                if(!$A.util.isEmpty(item.Value__c)){
                    totalAssetsAmt += parseFloat(item.Value__c);
                }
            });
        }
        component.set("v.totalAssetsAmount", totalAssetsAmt);
    },
    setSameAddressOrDependentChildren : function(component,selectedPerson) {
        var applicant = component.get("v.applicant");
		
        if(selectedPerson == 'joint' && !$A.util.isUndefinedOrNull(component.get("v.applicant1"))){
            var applicant1 = component.get("v.applicant1");
            applicant1.Living_Situation__c = applicant.Living_Situation__c;
            applicant1.Year__c = applicant.Year__c;
            applicant1.Months__c = applicant.Months__c;
            applicant1.Is_Find_Address__c = applicant.Is_Find_Address__c;
            applicant1.Residential_Address__c = applicant.Residential_Address__c;
            applicant1.Unit_Number__c = applicant.Unit_Number__c;
            applicant1.Street_Number__c = applicant.Street_Number__c;
            applicant1.Street__c = applicant.Street__c;
            applicant1.Street_Type__c = applicant.Street_Type__c;
            applicant1.Suburb__c = applicant.Suburb__c;
            applicant1.State__c = applicant.State__c;
            applicant1.Postal_Code__c = applicant.Postal_Code__c;
            applicant1.FinServ__CountryOfResidence__c = applicant.FinServ__CountryOfResidence__c;
            applicant1.FinServ__PrimaryAddressIsOther__c = applicant.FinServ__PrimaryAddressIsOther__c;
            applicant1.Postal_Address__c = applicant.Postal_Address__c;
            applicant1.isFindPostalAdd__c = applicant.isFindPostalAdd__c;
            applicant1.Postal_address_is_PO_or_GPO_box__c = applicant.Postal_address_is_PO_or_GPO_box__c;
            applicant1.Postal_Box_Type__c = applicant.Postal_Box_Type__c;
            applicant1.Postal_Number__c = applicant.Postal_Number__c;
            applicant1.Postal_Suburb__c = applicant.Postal_Suburb__c;
            applicant1.Postal_State__c = applicant.Postal_State__c;
            applicant1.Postal_Postal_Code__c = applicant.Postal_Postal_Code__c;
            applicant1.Postal_Country__c = applicant.Postal_Country__c;
            applicant1.Postal_PO_Box__c = applicant.Postal_PO_Box__c;
            applicant1.Year_1__c = applicant.Year_1__c;
            applicant1.Months_1__c = applicant.Months_1__c;
            applicant1.Is_Find_Address_1__c = applicant.Is_Find_Address_1__c;
            applicant1.Residential_Address_1__c = applicant.Residential_Address_1__c;
            applicant1.Unit_Number_1__c = applicant.Unit_Number_1__c;
            applicant1.Street_Number_1__c = applicant.Street_Number_1__c;
            applicant1.Street_1__c = applicant.Street_1__c;
            applicant1.Street_Type_1__c = applicant.Street_Type_1__c;
            applicant1.Suburb_1__c = applicant.Suburb_1__c;
            applicant1.State_1__c = applicant.State_1__c;
            applicant1.Postal_Code_1__c = applicant.Postal_Code_1__c;
            applicant1.Country_1__c = applicant.Country_1__c;
            
            applicant1.Year_2__c = applicant.Year_2__c;
            applicant1.Months_2__c = applicant.Months__c;
            applicant1.Is_Find_Address_2__c = applicant.Is_Find_Address_2__c;
            applicant1.Residential_Address_2__c = applicant.Residential_Address_2__c;
            applicant1.Unit_Number_2__c = applicant.Unit_Number_2__c;
            applicant1.Street_Number_2__c = applicant.Street_Number_2__c;
            applicant1.Street_2__c = applicant.Street_2__c;
            applicant1.Street_Type_2__c = applicant.Street_Type_2__c;
            applicant1.Suburb_2__c = applicant.Suburb_2__c;
            applicant1.State_2__c = applicant.State_2__c;
            applicant1.Postal_Code_2__c = applicant.Postal_Code_2__c;
            applicant1.Country_2__c = applicant.Country_2__c;
            
            if(!$A.util.isUndefinedOrNull(applicant.FinServ__NumberOfChildren__c )){
                applicant1.FinServ__NumberOfChildren__c = applicant.FinServ__NumberOfChildren__c;
            }
            component.set("v.applicant1", applicant1);
            
        }
        //helper.checkMonthYear(component, event);
    },
    applicant1options:function(component, event, item){
           
            var OwnerShipOption = component.get("v.OwnershipOptions");
        	var applicant = component.get("v.applicant");
            var applicant1ownerShip = {         
                'label': item,
                'value': item
            };
            OwnerShipOption.push(applicant1ownerShip);
            component.set("v.OwnershipOptions",OwnerShipOption);
    }
    
})