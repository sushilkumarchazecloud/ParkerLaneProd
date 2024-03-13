({
    getAssetLiabilities : function(component, event) {
        var action = component.get("c.getAssetsAndLiabilities");
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
                    if(!$A.util.isUndefinedOrNull(ret.Asset)){
                        component.set('v.assetsList', ret.Asset);
                    }else{
                        var defaultAssets = ['Home','Home Contents','Motor Vehicle','Superannuation']; 
                        defaultAssets.forEach(function(item){ 
                            self.addNewAsset(component, event, ''+item);
                            self.AddClose(component, event, "assets");
                        });

                    }
                    if(!$A.util.isUndefinedOrNull(ret.Liability)){
                        component.set('v.liabilitiesList', ret.Liability);
                    }else{
                        if(!$A.util.isUndefinedOrNull(ret.livingSituation) &&
                           !$A.util.isUndefinedOrNull(ret.livingSituation[0].Name) && 
                           ret.livingSituation[0].Name =='Own home with mortgage'){
                            var defaultLiability = ['Home Loan/Mortgage']; 
                            defaultLiability.forEach(function(item){ 
                                self.addNewLiability(component, event, ''+item);
                                self.AddClose(component, event, "liabilities");
                            });
                        }
                    }
                    this.doCalculation(component);
                }
            }
            self.scrollTop(component, event, 315);
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
    
    saveAssetLiabilities: function(component, event) {
        var isValidate = true;
        var isSave = false;
        var self = this;
        component.set("v.saveNextClicked", component.get("v.saveNextClicked") + 1);
        var assetsList = component.get("v.assetsList");
        var liabilitiesList = component.get("v.liabilitiesList");
        assetsList.forEach(function(asset){ 
            if($A.util.isUndefinedOrNull(asset.Value__c)){
                isValidate = false;
            }
        });
        liabilitiesList.forEach(function(liability){ 
            if($A.util.isUndefinedOrNull(liability.Value__c) && liability.AssetsAndLiabilitiesType__c != 'Child Maintenance'){
                isValidate = false;
            }
        });
        component.set("v.showError", !isValidate);
        component.set("v.errorMsg", "Please Click Update to complete asset or financial commitment details or delete if the Asset or Financial Commitment not applicable");
        if(isValidate){
            self.toggleSpinner(component, event);
            self.upsertOppAssetsAndLiabilities(component, event, true, false);
        }
        self.scrollTop(component, event, 315);
    },
    
    deleteAssetAndLiability: function(component, event, index, deleteListType) {
        var ids = [];
        var self = this;
        var deleteList = component.get("v." + deleteListType);
        if(!$A.util.isUndefinedOrNull(deleteList[index].Id)){
            ids.push(deleteList[index].Id);
            self.toggleSpinner(component, event);
            self.deleteRecords(component, event, ids);
        }
        deleteList.splice(index,1);
        
        component.set("v." + deleteListType, deleteList);
        this.doCalculation(component);
    },
    
    upsertOppAssetsAndLiabilities: function (component, event, isNext, isShare) {
        
        var action = component.get("c.upsertOppAssetsAndLiabilities");
        var self = this;
        var oppId = component.get('v.recordId');
        action.setParams({
            assetsList: component.get('v.assetsList'),
            liabilitiesList: component.get('v.liabilitiesList'), 
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
        });
        $A.enqueueAction(action);
    },
    
    deleteRecords: function (component, event, ids) {
        
        var action = component.get("c.deleteRecordsByIds");
        var self = this;
        action.setParams({
            recordIdsList: ids
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "ERROR") {
                component.set("v.showError", true);
                component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
            }
            self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
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
                    self.upsertOppAssetsAndLiabilities(component, event, false, false);
                }
            }
            self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
    },
    
    addNewAsset: function(component, event, name) {
        var asset = {
            'sobjectType': 'AssetsAndLiabilities__c',
            'AssetsAndLiabilitiesType__c': name
        };
        component.set("v.assetsSelected",asset);
    },
    
    addNewLiability: function(component, event, name) {
        var liability = {
            'sobjectType': 'AssetsAndLiabilities__c',
            'AssetsAndLiabilitiesType__c': name
        };
        component.set("v.liabilitiesSelected",liability);
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
        component.set("v.isOpenModal", false);
        component.set("v.isEdit", false);
        component.set("v.showError", false);
    },
    
    doCalculation: function(component) {
        var liabilitiesList = component.get("v.liabilitiesList");
        var assetsList = component.get("v.assetsList");
        var totalAssetsAmt = 0;
        var totalLiabilitiesAmt = 0;
        
        assetsList.forEach(function(item) {
            if(item.Value__c){
                totalAssetsAmt += parseFloat(item.Value__c);
            }
        });
        
        liabilitiesList.forEach(function(item) {
            if(item.Value__c){
                totalLiabilitiesAmt += parseFloat(item.Value__c);
            }
        });
        component.set("v.totalAssetsAmount", totalAssetsAmt);
        component.set("v.totalLiabilitiesAmount", totalLiabilitiesAmt);
    },
    
    toggleSpinner: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
    
    scrollTop: function (component, event, top){
        var scrollOptions = {
            left: 0,
            top: top,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    },
})