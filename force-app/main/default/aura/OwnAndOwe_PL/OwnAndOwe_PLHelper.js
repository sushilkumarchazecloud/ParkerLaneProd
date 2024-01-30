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
                        component.set('v.assetsList',ret.Asset);
                    }
                    if(!$A.util.isUndefinedOrNull(ret.Liability)){
                        component.set('v.liabilitiesList', ret.Liability);
                        var mortgageList = [];
                        var creditCardlist = [];
                        var personalAndAutoloanlist = [];
                        var otherCommitmentlist = [];
                        var propertyLoanlist = [];
                        
                        ret.Liability.forEach(function(item){
                            component.set('v.CreditCardscheck', item.FinServ__PrimaryOwner__r.CreditCardsCommitments__pc);
                            component.set('v.PersonalAndAutoLoanscheck',item.FinServ__PrimaryOwner__r.PersonalAndAuto__pc);
                            component.set('v.OtherCommitmentscheck', item.FinServ__PrimaryOwner__r.OtherCommitments__pc);
                            
                            if(item.FinServ__AssetsAndLiabilitiesType__c == 'Home Loan/Mortgage'){
                                mortgageList.push(item);
                            }else if(item.FinServ__AssetsAndLiabilitiesType__c == 'Investment Home Loan'){
                                propertyLoanlist.push(item);
                            }
                            else if(item.FinServ__AssetsAndLiabilitiesType__c == 'Credit Card / Store Card'){
                                creditCardlist.push(item);
                            }
                            else if(item.FinServ__AssetsAndLiabilitiesType__c == 'Personal Loan' || item.FinServ__AssetsAndLiabilitiesType__c == 'Auto Loan'){
                                personalAndAutoloanlist.push(item);
                            }
                            else {
                                otherCommitmentlist.push(item);
                            }
                        });
                        
                        component.set('v.propertyLoanlist', propertyLoanlist);
                        component.set('v.mortgageList', mortgageList);
                        component.set('v.creditCardlist', creditCardlist);
                        component.set('v.personalAndAutoloanlist', personalAndAutoloanlist);
                        component.set('v.otherCommitmentlist', otherCommitmentlist);
                    }else{
                        if(!$A.util.isUndefinedOrNull(ret.livingSituation) &&
                           !$A.util.isUndefinedOrNull(ret.livingSituation[0].Name) && 
                           ret.livingSituation[0].Name =='Own home with mortgage'){
                            var defaultLiability = ['Home Loan/Mortgage']; 
                            defaultLiability.forEach(function(item){ 
                                //self.addNewLiability(component, event, ''+item);
                                //self.AddClose(component, event, "liabilities");
                            });
                        }
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
    
    saveAssetLiabilities: function(component, event) {
        var isSave = false;
        var self = this;

        component.set("v.saveNextClicked", component.get("v.saveNextClicked") + 1);
        self.toggleSpinner(component, event);
        self.upsertOppAssetsAndLiabilities(component, event, true, false);
        self.scrollTop(component, event, 70);
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
        
        var action = component.get("c.upsertOppAssetsAndLiabilitiesPL");
        var self = this;
        var oppId = component.get('v.recordId');
        
        var mergeListOfliabilities = [];
        var mortgageList= component.get('v.mortgageList');
        var propertyLoanlist= component.get('v.propertyLoanlist');
        
        var creditCardscheck = component.get('v.CreditCardscheck');
        var personalAndAutoLoanscheck = component.get('v.PersonalAndAutoLoanscheck');
        var OtherCommitmentscheck = component.get('v.OtherCommitmentscheck');
        mortgageList.forEach(function(item){
            mergeListOfliabilities.push(item);   
        });
        propertyLoanlist.forEach(function(item){
            mergeListOfliabilities.push(item);   
        });
        var creditCardlist= component.get('v.creditCardlist');
        var personalAndAutoloanlist= component.get('v.personalAndAutoloanlist');
        var otherCommitmentlist= component.get('v.otherCommitmentlist');
        
        if(creditCardscheck =='No'){

            creditCardlist.forEach(function(item){
                if(!$A.util.isUndefinedOrNull(item.Id)){
                    mergeListOfliabilities.push(item);
                }   
            });
        }else{

            creditCardlist.forEach(function(item){
                    mergeListOfliabilities.push(item);
            });
        }
        if(personalAndAutoLoanscheck =='No'){

            personalAndAutoloanlist.forEach(function(item){
                if(!$A.util.isUndefinedOrNull(item.Id)){
                    mergeListOfliabilities.push(item);
                }      
            });
        }else{

            personalAndAutoloanlist.forEach(function(item){
                    mergeListOfliabilities.push(item);
            });
        }
        if(OtherCommitmentscheck == 'No'){

            otherCommitmentlist.forEach(function(item){
               if(!$A.util.isUndefinedOrNull(item.Id)){
                    mergeListOfliabilities.push(item);
                }      
            });
        }else{

            otherCommitmentlist.forEach(function(item){
                    mergeListOfliabilities.push(item);
            });
        }
        
		var listOfliabilities = [];
        mergeListOfliabilities.forEach(function(item){
            if($A.util.isUndefinedOrNull(item.Limit__c) && !$A.util.isUndefinedOrNull(item.Value__c)){
                item.Limit__c = item.Value__c
            }
            listOfliabilities.push(item);
        });        
        
        action.setParams({
            assetsList: component.get('v.assetsList'),
            liabilitiesList: listOfliabilities,//component.get('v.liabilitiesList'), 
            oppId : oppId,
            isOppUpdate : isNext,
            isShare : isShare,
            creditCardscheck : creditCardscheck,
            personalAndAutoLoanscheck: personalAndAutoLoanscheck,
            OtherCommitmentscheck: OtherCommitmentscheck
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
            console.log('@@@@state----------' + state);
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
            console.log('@@@@@@' +state);
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                }else{
                    component.set('v.applicationSection', JSON.parse(ret).CurrentSection);
                    component.set('v.appSectionPath', JSON.parse(ret).path);
                        component.set('v.mortgageList', []);
                        component.set('v.creditCardlist', []);
                        component.set('v.personalAndAutoloanlist', []);
                        component.set('v.otherCommitmentlist', []);
                    self.upsertOppAssetsAndLiabilities(component, event, false, false);
                }
            }
            self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
    },
    
    addNewAsset: function(component, event, name) {
        var asset = {
            'sobjectType': 'FinServ__AssetsAndLiabilities__c',
            'FinServ__AssetsAndLiabilitiesType__c': name,
            'Value__c':'0'
        };
        component.set("v.assetsSelected",asset);
    },
    
    addNewLiability: function(component, event, name, type) {
        var liabilitiesList = component.get("v."+ name);
        var liability = {
            'sobjectType': 'FinServ__AssetsAndLiabilities__c',
            'FinServ__AssetsAndLiabilitiesType__c': type
        };
        liabilitiesList.push(liability);
        component.set("v."+ name, liabilitiesList);
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
        var mortgageList = component.get("v.mortgageList");
        var creditCardlist = component.get("v.creditCardlist");
        var personalAndAutoloanlist = component.get("v.personalAndAutoloanlist");
        var otherCommitmentlist = component.get("v.otherCommitmentlist");
        var totalLiabilitiesAmt = 0;
        var totalAssetsAmt = 0;
        if(!$A.util.isUndefinedOrNull(mortgageList)){
            mortgageList.forEach(function(item) {
                if(!$A.util.isEmpty(item.Value__c)){
                    totalLiabilitiesAmt += parseFloat(item.Value__c);
                }
            });
        }
        
        if(!$A.util.isUndefinedOrNull(creditCardlist)){
            creditCardlist.forEach(function(item) {
                if(!$A.util.isEmpty(item.Value__c)){
                    totalLiabilitiesAmt += parseFloat(item.Value__c);
                }
            });
        }
        
        if(!$A.util.isUndefinedOrNull(personalAndAutoloanlist)){
            personalAndAutoloanlist.forEach(function(item) {
                if(!$A.util.isEmpty(item.Value__c)){
                    totalLiabilitiesAmt += parseFloat(item.Value__c);
                }
            });
        }
        
        if(!$A.util.isUndefinedOrNull(otherCommitmentlist)){
            otherCommitmentlist.forEach(function(item) {
                if(!$A.util.isEmpty(item.Value__c)){
                    totalLiabilitiesAmt += parseFloat(item.Value__c);
                }
            });
        }
        component.set("v.totalLiabilitiesAmount", totalLiabilitiesAmt);
        var assetsList = component.get("v.assetsList");
        if(!$A.util.isUndefinedOrNull(assetsList)){
            assetsList.forEach(function(item) {
                if(!$A.util.isEmpty(item.Value__c)){
                    totalAssetsAmt += parseFloat(item.Value__c);
                }
            });
        }
       
        component.set("v.totalAssetsAmount", totalAssetsAmt);
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
    }
})