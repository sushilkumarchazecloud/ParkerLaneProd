({
	doInit: function(component, event, helper) {
        helper.toggleSpinner(component, event);
        helper.getAssetLiabilities(component, event);
        helper.getSelPerson(component, event);
        helper.scrollTop(component, event, 315);
    },
    
    addAsset: function(component, event, helper) {
        helper.addNewAsset(component, event,'');
        component.set("v.selectedType","Asset");
        component.set("v.isOpenModal", true);
    },
    
    addLiability: function(component, event, helper) {
		helper.addNewLiability(component, event, '');
        component.set("v.selectedType","Liability");
        component.set("v.isOpenModal", true);
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
    
    deleteLiability: function(component, event, helper) {
        var index = event.currentTarget.id;
        component.set("v.delOrEmpty","delete");
        component.set("v.isOpenAlertModal", true);
        component.set("v.selectedType","liability");
        component.set("v.deleteIndex",index);
    },
    
    deleteAsset: function(component, event, helper) {
        var index = event.currentTarget.id;
        component.set("v.delOrEmpty","delete");
        component.set("v.isOpenAlertModal", true);
        component.set("v.selectedType","asset");
        component.set("v.deleteIndex",index);
    },
    
    deleteAssLiability: function(component, event, helper) {
        var listType ="";
        if(component.get("v.selectedType") == "liability"){
            listType = "liabilitiesList";
        }else if(component.get("v.selectedType") == "asset"){
            listType = "assetsList";
        }
        helper.deleteAssetAndLiability(component, event, component.get("v.deleteIndex"), listType);
        component.set("v.isOpenAlertModal", false);
    },        
    
    saveAndNext: function(component, event, helper) {
        var assetsList = component.get("v.assetsList");
        var liabilitiesList = component.get("v.liabilitiesList");
        if(assetsList.length ==0 || liabilitiesList.length ==0 ){
            component.set("v.delOrEmpty","empty");
            component.set("v.isOpenAlertModal", true);
        }else{
            component.set("v.isOpenAlertModal", false);
            helper.saveAssetLiabilities(component, event);
        }
    },
    
    save: function(component, event, helper) {
        component.set("v.isOpenAlertModal", false);
        helper.saveAssetLiabilities(component, event);
        helper.scrollTop(component, event, 315);
    },
    
    saveApplication: function(component, event, helper) {
        var args = event.getParam("arguments");
        var isShare = args.isShare;
        var isNext = args.isNext;
        var isSave = false;
        component.set("v.saveNextClicked", component.get("v.saveNextClicked") + 1);
        var assetsList = component.get("v.assetsList");
        var liabilitiesList = component.get("v.liabilitiesList");
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
        component.set("v.selectedType","Asset");
        component.set("v.assetsSelected",assetsList[indexNo]);
        component.set("v.isOpenModal", true);
        component.set("v.isEdit", true);
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
    
    AddCloseLiability: function(component, event, helper) {
        var OwnAndOweFinancialCommitments = component.find("OwnAndOweFinancialCommitments");
        var isvalidate = OwnAndOweFinancialCommitments.validateCommitment();
        if(isvalidate){
            helper.AddClose(component, event, "liabilities");
        }

    },
    
    AddCloseAsset: function(component, event, helper) {
        var OwnAndOweAssets = component.find("OwnAndOweAssets");
        var isvalidate = OwnAndOweAssets.validateAsset();
        if(isvalidate){
            helper.AddClose(component, event, "assets");
        }
    },
})