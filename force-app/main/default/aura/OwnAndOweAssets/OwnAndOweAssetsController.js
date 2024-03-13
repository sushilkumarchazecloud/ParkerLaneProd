({
	doInit : function(component, event, helper) {
        var applicant = component.get("v.applicant");
        var makeModel = [];
        for (var i = 2021; i >= 1950; i--) {
            var make = {
                "label": i.toString(),
                "value": i.toString(),
            };
            makeModel.push(make);
        }
        component.set("v.makeModelOptions", makeModel);
        
        var consumerAssets = component.get("v.consumerAssets");
        if(consumerAssets.Ownership__c == 'Joint'){
            component.set("v.app1Ownership", "Applicant 1 Ownership Share (%)");
            component.set("v.app2Ownership", "Applicant 2 Ownership Share (%)");
        }else if(consumerAssets.Ownership__c == 'Joint (non-applicant)'){
            component.set("v.app1Ownership", "Applicant Ownership Share (%)");
            component.set("v.app2Ownership", "Non-Applicant Ownership Share (%)");
        }else if(consumerAssets.Ownership__c == 'Joint with Spouse'){
            component.set("v.app1Ownership", "Applicant Ownership Share (%)");
            component.set("v.app2Ownership", "Spouse Ownership Share (%)");
        }
        if(!$A.util.isUndefinedOrNull(consumerAssets) && !$A.util.isUndefinedOrNull(consumerAssets.Year__c)){
            consumerAssets.Year__c = ''+ consumerAssets.Year__c;
        }
        
        component.set("v.consumerAssets",consumerAssets);
    },

    handleOwnership : function(component, event, helper) {
        
        var consumerAssets = component.get("v.consumerAssets");
        if(!$A.util.isUndefinedOrNull(consumerAssets) && !$A.util.isUndefinedOrNull(consumerAssets.Ownership__c)){
			var isJoint = false;
            if(consumerAssets.Ownership__c == 'Joint'){
                component.set("v.app1Ownership", "Applicant 1 Ownership Share (%)");
                component.set("v.app2Ownership", "Applicant 2 Ownership Share (%)");
                isJoint = true;
            }else if(consumerAssets.Ownership__c == 'Joint (non-applicant)'){
                component.set("v.app1Ownership", "Applicant Ownership Share (%)");
                component.set("v.app2Ownership", "Non-Applicant Ownership Share (%)");
                isJoint = true;
            }else if(consumerAssets.Ownership__c == 'Joint with Spouse'){
                component.set("v.app1Ownership", "Applicant Ownership Share (%)");
                component.set("v.app2Ownership", "Spouse Ownership Share (%)");
                isJoint = true;
            }
            if(isJoint){
                consumerAssets.Other_Ownership_Share__c = 50;
                consumerAssets.Ownership_Share__c = 50;
            }else{
                consumerAssets.Other_Ownership_Share__c = 0;
                consumerAssets.Ownership_Share__c = 0;
            }
            component.set("v.consumerAssets", consumerAssets);
        }
    },
    
    validateAsset : function(component, event, helper) {

        var fieldcheck = component.find('fieldcheck');
        var inputField = component.find('fieldcheckType');
        var value = inputField.get('v.value');
        var isvalidate =false;
        var ownShareEle = component.find('ownShare');
        $A.util.removeClass(ownShareEle, 'errMoreThan50');
        if(value != 'foo') {
            inputField.set('v.validity', {valid:false, badInput :true});
            inputField.showHelpMessageIfInvalid();
            isvalidate =false;
        }
        
        if(!$A.util.isUndefinedOrNull(fieldcheck) && !$A.util.isUndefinedOrNull(fieldcheck.length)){
             isvalidate = fieldcheck.reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && !inputCmp.get('v.validity').valueMissing;
            }, true);
        
        }

        component.set("v.showError",!isvalidate);
        component.set("v.errorMsg", "Please update the form entries highlighted in red and try again");
        var consumerAssets = component.get("v.consumerAssets");
        if(!$A.util.isUndefinedOrNull(consumerAssets) && 
           !$A.util.isUndefinedOrNull(consumerAssets.Ownership__c) &&
           !$A.util.isUndefinedOrNull(consumerAssets.Ownership_Share__c) &&
           !$A.util.isUndefinedOrNull(consumerAssets.Other_Ownership_Share__c)){
            var app1Share = parseInt(consumerAssets.Ownership_Share__c);
            var app2Share = parseInt(consumerAssets.Other_Ownership_Share__c);
            var totalSharing = app1Share + app2Share;
            if(isvalidate && ((totalSharing > 100) || (app1Share < 0) || (app2Share < 0))){
                component.set("v.showError", true);
                component.set("v.errorMsg", "Ownership cannot total more than 100%");
                var ownShareEle = component.find('ownShare');
                $A.util.addClass(ownShareEle, 'errMoreThan50');
                isvalidate = false;
            }
        }
        
        var addressTool = component.find("addressTool");
        var isAddvalidate = true;
        if(!$A.util.isUndefinedOrNull(addressTool)){
            isAddvalidate = addressTool.checkAddress();
        }
        
        if(consumerAssets.Is_Find_Address__c && isAddvalidate){
            var searchString = '';
            var unitNumber = consumerAssets.Unit_Number__c;
            var streetNumber = consumerAssets.Street_Number__c;
            var street = consumerAssets.Street__c;
            var streetType = consumerAssets.Street_Type__c;
            var suburb = consumerAssets.Suburb__c;
            var state = consumerAssets.State__c;
            var postalCode = consumerAssets.Postal_Code__c;
            var country = consumerAssets.Country__c;
            if(!$A.util.isUndefinedOrNull(unitNumber)){
                searchString = unitNumber + ' ';
            }
            searchString += streetNumber + ' ' + street + ' ' + streetType + ' ' + suburb + ' ' +
                state + ' ' + country + ' ' + postalCode;
            consumerAssets.Address__c = searchString;
            component.set("v.consumerAssets", consumerAssets);
        }
        
        return isvalidate && isAddvalidate;
    },
    
    deleteAsset : function(component, event, helper) {
		var deleyeEvent = component.getEvent("SolarDeleteRowEvent");
        deleyeEvent.setParams({"indexVar" : component.get("v.index"),
                               "rowType" : "Asset"});
        deleyeEvent.fire();
    }, 
  	
    changePercentageBlur : function(component, event, helper) {
		var consumerAssets = component.get("v.consumerAssets");
        consumerAssets.Ownership_Share__c = consumerAssets.Ownership_Share__c/100;
        component.set("v.consumerAssets", consumerAssets);
    },
    
    changePercentageFocus : function(component, event, helper) {
        var consumerAssets = component.get("v.consumerAssets");
        consumerAssets.Ownership_Share__c = consumerAssets.Ownership_Share__c*100;
        component.set("v.consumerAssets", consumerAssets);
    },
})