({
	getOppContacts : function(component, event, recordId) {
		var action = component.get("c.getOppContacts");
        var self = this;
     	action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var ret = response.getReturnValue();
                console.log('who is applying ----'+JSON.stringify(ret));
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                }else{
                    if(ret.opp.RecordType.DeveloperName == 'Home_Improvement' || ret.opp.RecordType.DeveloperName == 'Green_Loan'){
                        //if(ret.opp.Loan_Amount__c > 25000 || ret.opp.Lender__c == 'Community First Credit Union'){
                            component.set("v.isCFCU",true);
                       //}
                    }
                    component.set('v.opportunity', ret.opp);
                    if(ret.opp.Applicant_1__c != null || ret.opp.Applicant_2__c != null){
                        component.set('v.applicant1', ret.contact1);
                        component.set('v.applicant2', ret.contact2);
                        component.set('v.app1Children', ret.app1Children);
                        component.set('v.app2Children', ret.app2Children);
                        if(ret.opp.Number_of_applicants__c == 1 || !$A.util.isUndefinedOrNull(ret.contact1)){
                            component.set('v.selectedPerson', "single");
                            if(ret.contact1.FirstName !='' && ret.contact1.LastName !='' && ret.contact1.Email !='' && 
                               ret.contact1.Phone !='' && !$A.util.isUndefinedOrNull(ret.contact1.FirstName) && 
                               !$A.util.isUndefinedOrNull(ret.contact1.LastName) && !$A.util.isUndefinedOrNull(ret.contact1.Email) && 
                               !$A.util.isUndefinedOrNull(ret.contact1.Phone)){
                            }
                            
                        }
                        if(ret.opp.Number_of_applicants__c == 2 || !$A.util.isUndefinedOrNull(ret.contact2)){
                            component.set('v.selectedPerson', "joint");
                        }
                    }
                }
            }
            self.toggleSpinner(component, event);
            self.scrollTop(component, event, 70);
        });
        $A.enqueueAction(action);
	},
    
    upsertOppCons: function (component, event, isOppUpdate, isShare) {
        var action = component.get("c.upsertOppContacts");
        var self = this;
        var opp = component.get('v.opportunity');

        var applicant1= component.get('v.applicant1');
        var applicant2= component.get('v.applicant2');
        var selectPerson = component.get('v.selectedPerson');
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
            // console.log('@@@@state----------' + state);
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                console.log('-->>>>'+JSON.stringify(ret));
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                    self.toggleSpinner(component, event);
                }else{
                    self.upsertOppAssetsAndLiabilities(component, event, isShare, JSON.parse(ret).CurrentSection, JSON.parse(ret).path);
                }
            }else{self.toggleSpinner(component, event);}
        });
        $A.enqueueAction(action);
    },
    upsertOppAssetsAndLiabilities: function (component, event, isShare, currentSection, path) {
  		var self = this;
        var action = component.get("c.upsertOppAssetsAndLiabilitiesPL");
        var oppId = component.get('v.recordId');
        var applicant1 = component.get('v.applicant1');
        var creditCardscheck = '';
        var personalAndAutoLoanscheck ='';
        var OtherCommitmentscheck = '';                                                 
        /*if(!$A.util.isUndefinedOrNull(applicant1.CreditCardsCommitments__c)){
            creditCardscheck = applicant1.CreditCardsCommitments__c;
        }
        if(!$A.util.isUndefinedOrNull(applicant1.PersonalAndAuto__c)){
            personalAndAutoLoanscheck = applicant1.PersonalAndAuto__c;
        }
        if(!$A.util.isUndefinedOrNull(applicant1.OtherCommitments__c)){
            OtherCommitmentscheck = applicant1.OtherCommitments__c;
        }*/
        
        var assetListdata = component.get("v.allAssetsList");
		console.log('00-assetListdata-->>>'+JSON.stringify(assetListdata));
        console.log('00--oppId->>>'+oppId);
        
        action.setParams({
            assetsList:  assetListdata,
            liabilitiesList: [],
            oppId : oppId,
            isOppUpdate : false,
            isShare : isShare,
            creditCardscheck :creditCardscheck,
            personalAndAutoLoanscheck: personalAndAutoLoanscheck,
            OtherCommitmentscheck: OtherCommitmentscheck,
            skipSave: true
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('@@@@state----------' + state);
            console.log('@@@ error-------' + JSON.stringify(response.getError()));
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                }else{
                    component.set('v.applicationSection', currentSection);
                    component.set('v.appSectionPath', path);
                }
            }
            self.toggleSpinner(component, event);
        });
        $A.enqueueAction(action);
    },
    
    checkExistingCustomer : function(component, event, emailIds) {
		var action = component.get("c.checkExistingCustomer");
        var self = this;
        var con1 = component.get('v.applicant1');
        var con2 = component.get('v.applicant2');
        var opp = component.get('v.opportunity');
        var selectedPerson = component.get('v.selectedPerson');
        var Number_of_applicants = 0;
        if(selectedPerson == 'single'){
           Number_of_applicants = '1';
        } else if(selectedPerson == 'joint'){
            Number_of_applicants = '2';
        }
     	action.setParams({
            con1 : con1,
            con2 : con2,
            opp : opp,
            Number_of_applicants : Number_of_applicants
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var ret = response.getReturnValue();
                if(ret=='[]' || $A.util.isUndefinedOrNull(ret)){
                    component.set("v.showError", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message"));
                }else{
                    if(JSON.parse(ret).status == 'Success'){
                        component.set('v.showError', false);
                        component.set("v.selectedTab", "AboutFormTab");
                        component.set("v.isDisableNext", false);
                        if(!$A.util.isUndefinedOrNull(con2) && $A.util.isUndefinedOrNull(con2.Id) && !$A.util.isUndefinedOrNull(JSON.parse(ret).con2Id)){
                            con2.Id = JSON.parse(ret).con2Id;
                            component.set("v.applicant2", con2);
                        }

                    }else if(JSON.parse(ret).status == 'Error'){                    
                        component.set('v.errorMsg', JSON.parse(ret).message);
                        component.set('v.showError', true);
                    }
                }
            }
            self.toggleSpinner(component, event);
            self.scrollTop(component, event, 70);
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
})