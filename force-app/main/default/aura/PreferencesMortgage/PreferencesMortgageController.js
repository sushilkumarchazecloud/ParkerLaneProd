({
    doInit: function(component, event, helper){
        var years = [];
        var fYears = [];
        for (var i = 1; i <= 30; i++) {
            var yearStr=' Years';
            if(i==1){
                yearStr=' Year';
            }
            var year = {
                "label": i + yearStr,
                "value": i + yearStr
            };
            if(i<=5)fYears.push(year);
            years.push(year);
        }
        fYears.push({"label": "Don’t know", "value": "Don’t know"});
        component.set("v.fixedTermYearOptions", fYears);
        component.set("v.yearsOptions", years);
        
        let recordId = component.get("v.recordId");
        helper.toggleSpinner(component, event);
        helper.getPreferences(component, event, recordId);
        helper.scrollTop(component, event);
        
        
    },
    prevSave: function(component, event, helper) {
        var recordId =component.get("v.recordId");
        helper.toggleSpinner(component, event);
        helper.SavePrev(component, event, recordId);

    },
    
    saveNext: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var isValidated = helper.validateDetails(component, event);
        if(isValidated){
            helper.toggleSpinner(component, event);
            helper.upsertPreferences(component, event, true, false);
        }
        helper.scrollTop(component, event);
    },
    
    saveApplication: function(component, event, helper) {
        var args = event.getParam("arguments");
        var isShare = args.isShare;
        var isNext = args.isNext;
        
        var recordId =component.get("v.recordId");
        helper.toggleSpinner(component, event);
        helper.upsertPreferences(component, event, isNext, isShare);
        
    },
    
    addNewLoanPurpose: function(component, event) {
        var opp = component.get('v.opportunity');
        var loanPurpose = {
            'sobjectType': 'Loan_Purpose__c',
            'Opportunity__c': opp.Id
        };
        component.set("v.selectedLoanPurpose",loanPurpose);
        component.set("v.isOpenModal", true);
    },
    
    openLoanPurposeModel: function(component, event, helper) {
		var loanPurposesList = component.get("v.loanPurposesList");
        var indexNo = event.currentTarget.id;
        component.set("v.selectedLoanPurpose",loanPurposesList[indexNo]);
        component.set("v.isOpenModal", true);
        component.set("v.isEdit", true);
    },
    
    AddCloseLoanPurpose: function(component, event, helper) {
        var preferenceLoanPurpose = component.find("preferenceLoanPurpose");
        var isvalidate = preferenceLoanPurpose.validateLoanPurpose();
        if(isvalidate){
            var typesList = component.get("v.loanPurposesList");
            var typeSelected = component.get("v.selectedLoanPurpose");
            var isEdit = component.get("v.isEdit");
            if($A.util.isUndefinedOrNull(typeSelected.Id) && !isEdit){
                typesList.push(typeSelected);
            }
            component.set("v.loanPurposesList", typesList);
            helper.calculatePurposeAmount(component);
            component.set("v.isOpenModal", false);
            component.set("v.isEdit", false);
            component.set("v.showError", false);
        }
    },
    
    deleteAlertModel: function(component, event, helper) {
        var index = event.currentTarget.id;
        component.set("v.isOpenAlertModal", true);
        component.set("v.selectedType","asset");
        component.set("v.deleteIndex",index);
    },
    
    deleteLoanPurpose: function(component, event, helper) {
        var index = component.get("v.deleteIndex");
        var deleteList = component.get("v.loanPurposesList");
        var ids = [];
        //helper.deleteLoanPurposes(component, event, component.get("v.deleteIndex"), listType);
        if(!$A.util.isUndefinedOrNull(deleteList[index].Id)){
            ids.push(deleteList[index].Id);
            helper.toggleSpinner(component, event);
            helper.deleteRecords(component, event, ids);
        }
        deleteList.splice(index,1);
        helper.calculatePurposeAmount(component);
        component.set("v.loanPurposesList", deleteList);
        component.set("v.isOpenAlertModal", false);
    },   
    
    closeAlertModel: function(component, event, helper) {
        component.set("v.isOpenAlertModal", false);
    },
    
    closeModel: function(component, event, helper) {
        component.set("v.isOpenModal", false);
    },
    handleProductTypes: function(component, event, helper) {
        var opportunity = component.get('v.opportunity');
        var anyProductTypes = component.get('v.anyProductTypes');;

        if(!$A.util.isUndefinedOrNull(anyProductTypes) && anyProductTypes.length > 0){
            anyProductTypes = anyProductTypes.join(";") +';';
        }
        opportunity.Any_product_types_you_are_interested_in__c = anyProductTypes;
        component.set('v.opportunity', opportunity);
    },
})