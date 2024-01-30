({
	doInit: function(component, event, helper) {
        helper.toggleSpinner(component, event);
        helper.getAssetLiabilities(component, event);
        helper.getSelPerson(component, event);
        helper.scrollTop(component, event, 70);
    },
    
    addAsset: function(component, event, helper) {
        var newAsset = component.get("v.addAssetValue");

        var asset = {
            'sobjectType': 'FinServ__AssetsAndLiabilities__c',
            'FinServ__AssetsAndLiabilitiesType__c': newAsset,
            'Value__c':'0'
        };
        var typesList = component.get("v.assetsList");
        typesList.push(asset);
        component.set("v.assetsList", typesList);
        component.set("v.addAssetValue", "");

    },
    
    addMortgage: function(component, event, helper) {
		helper.addNewLiability(component, event, 'mortgageList','Home Loan/Mortgage');
        helper.scrollTop(component, event, 70);
    },
    addCreditCardRowOnYes: function(component, event, helper) {
		var liabilitylist = component.get("v.creditCardlist");
        if(liabilitylist.length == 0){
            helper.addNewLiability(component, event, 'creditCardlist','Credit Card / Store Card');
        }
    },
    addCreditCardRow: function(component, event, helper) {
		helper.addNewLiability(component, event, 'creditCardlist','Credit Card / Store Card');
    },
    addPersonalRowOnYes: function(component, event, helper) {
		var liabilitylist = component.get("v.personalAndAutoloanlist");
        if(liabilitylist.length == 0){
            helper.addNewLiability(component, event, 'personalAndAutoloanlist','');
        }
    },
    addPersonalRow: function(component, event, helper) {
		helper.addNewLiability(component, event, 'personalAndAutoloanlist','');
    },
    addOtherCommitmentOnYes: function(component, event, helper) {
		var liabilitylist = component.get("v.otherCommitmentlist");
        if(liabilitylist.length == 0){
            helper.addNewLiability(component, event, 'otherCommitmentlist','Other');
        }
    },
    addOtherCommitment: function(component, event, helper) {
		helper.addNewLiability(component, event, 'otherCommitmentlist','Other');
    },
    doCalculation: function(component, event, helper) {
        helper.doCalculation(component);
    },
    deleteRow: function(component, event) {

        var index = event.currentTarget.id;//event.getParam("indexVar");
        var rowType = event.currentTarget.data;//event.getParam("rowType");
        var deleteList;
        if(rowType === "Asset"){
            deleteList = component.get("v.assetsList");
        }else if(rowType === "Liability"){
            deleteList = component.get("v.liabilitiesList");
        }
        deleteList.splice(index,1);
        if(rowType === "Asset"){
            component.set("v.assetsList", deleteList);
        }else if(rowType === "Liability"){
            component.set("v.liabilitiesList", deleteList);
        }
        helper.doCalculation(component);
    },       
    
    saveAndNext: function(component, event, helper) {

        var mortgageList = component.get("v.mortgageList");
        var propertyLoanlist = component.get("v.propertyLoanlist");
        
        var creditCardlist = component.get("v.creditCardlist");
        var CreditCardscheck = component.get("v.CreditCardscheck");
        var personalAndAutoloanlist = component.get("v.personalAndAutoloanlist");
        var personalAndAutoLoanscheck = component.get("v.PersonalAndAutoLoanscheck");
        var anotherCommitmentlist = component.get("v.anotherCommitmentlist");
        var otherCommitmentlist = component.get("v.otherCommitmentlist");
        var OtherCommitmentscheck = component.get("v.OtherCommitmentscheck");
       
        if($A.util.isUndefinedOrNull(propertyLoanlist) && $A.util.isUndefinedOrNull(mortgageList) && $A.util.isUndefinedOrNull(creditCardlist) && $A.util.isUndefinedOrNull(personalAndAutoloanlist) && $A.util.isUndefinedOrNull(anotherCommitmentlist)) {
            component.set("v.delOrEmpty","empty");
            component.set("v.isOpenAlertModal", true);
        
        }else{
			var allValid = component.find('fieldcheck').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && !inputCmp.get('v.validity').valueMissing;
            }, true);
            
            if($A.util.isUndefinedOrNull(CreditCardscheck) || (CreditCardscheck == 'Yes' && creditCardlist.length ==0) ||
              $A.util.isUndefinedOrNull(personalAndAutoLoanscheck) || (personalAndAutoLoanscheck == 'Yes' && personalAndAutoloanlist.length ==0)||
              $A.util.isUndefinedOrNull(OtherCommitmentscheck) || (OtherCommitmentscheck == 'Yes' && otherCommitmentlist.length ==0)){
                allValid = false;
            }

            if(allValid){
                component.set("v.isOpenAlertModal", false);
                component.set("v.showError", false);
                helper.saveAssetLiabilities(component, event);
            }else{
                component.set("v.showError", true);
                component.set("v.errorMsg", 'Please fill all information.');

                helper.scrollTop(component, event, 70);
            }
            
        }
    },
    
    save: function(component, event, helper) {
        component.set("v.isOpenAlertModal", false);
        helper.saveAssetLiabilities(component, event);
        helper.scrollTop(component, event, 70);
    },
    
    saveApplication: function(component, event, helper) {
        var args = event.getParam("arguments");
        var isShare = args.isShare;
        var isNext = args.isNext;
        var isSave = false;
        component.set("v.saveNextClicked", component.get("v.saveNextClicked") + 1);
        helper.toggleSpinner(component, event);
        helper.upsertOppAssetsAndLiabilities(component, event, isNext, isShare);
    },
    
    prevSave: function(component, event, helper) {
        var recordId =component.get("v.recordId");
        helper.toggleSpinner(component, event);
        helper.SavePrev(component, event, recordId);
    },
    
    openAssetModel: function(component, event, helper) {
		var assetsList = component.get("v.assetsList");
        var indexNo = event.currentTarget.id;
        component.set("v.selectedTypeName",assetsList[indexNo].FinServ__AssetsAndLiabilitiesType__c);
        component.set("v.selectedType","Asset");
        component.set("v.assetsSelected",assetsList[indexNo]);
        component.set("v.isOpenModal", true);
        component.set("v.isEdit", true);
        component.set("v.deleteIndex",indexNo);
    },
    
    openLiabilityModel: function(component, event, helper) {
		var liabilitiesList = component.get("v.liabilitiesList");
        var indexNo = event.currentTarget.id;
        component.set("v.selectedType","Liability");
        component.set("v.liabilitiesSelected",liabilitiesList[indexNo]);
        component.set("v.isOpenModal", true);
        component.set("v.isEdit", true);
    },
    
    closeAlertModel: function(component, event, helper) {
        component.set("v.isOpenAlertModal", false);
    },
    
    closeModel: function(component, event, helper) {
        component.set("v.isOpenModal", false);
    },
    
    deleteMortgage:function(component, event, helper){
       
        var indexNo = event.currentTarget.id;
        helper.deleteAssetAndLiability(component, event, indexNo, 'mortgageList');
    },
    deleteCreditCard:function(component, event, helper){
       
        var index = event.currentTarget.id;
        component.set("v.delOrEmpty","delete");
        component.set("v.isOpenAlertModal", true);
        component.set("v.selectedType","creditCardlist");
        component.set("v.deleteIndex",index);
    },
    deletePersonalAndAutoloan:function(component, event, helper){
        var index = event.currentTarget.id;
        component.set("v.delOrEmpty","delete");
        component.set("v.isOpenAlertModal", true);
        component.set("v.selectedType","personalAndAutoloanlist");
        component.set("v.deleteIndex",index);
    },
    deleteAnotherCommitment:function(component, event, helper){
        var index = event.currentTarget.id;
        component.set("v.delOrEmpty","delete");
        component.set("v.isOpenAlertModal", true);
        component.set("v.selectedType","otherCommitmentlist");
        component.set("v.deleteIndex",index);
    },
    deleteAssLiability: function(component, event, helper) {
        var listType = component.get("v.selectedType");
        helper.deleteAssetAndLiability(component, event, component.get("v.deleteIndex"), listType);
        component.set("v.isOpenAlertModal", false);
    }, 
   
})