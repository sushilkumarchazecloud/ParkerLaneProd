({
	doInit: function(component, event, helper) {
        var recordIds = component.get("v.recordId");
        helper.callDoInit(component, recordIds);
        helper.getOppDocs(component, recordIds);
        helper.getCurrentAppName(component, event, helper);
    },
    openUploadDocs: function(component, event, helper) {
        var recordIds = component.get("v.recordId");
        var label = $A.get("$Label.c.baseUrl"); 
        window.open(label+'supportingDocument?oppId='+recordIds,'_blank');
        //window.open('https://lanecorp--uat.sandbox.my.salesforce-sites.com/supportingDocument?oppId='+recordIds,'_blank');
    },
    navigateToRecord : function(component , event, helper){
        var recordId = event.currentTarget.dataset.recordId;
        var currentApp = component.get("v.currentAppName");
        var navService = component.find("navService");
        var pageReference = {    
            "type": "standard__recordPage",
            "attributes": {
                "recordId": recordId,
                "actionName": "view"
            }
        }
        if (currentApp == 'Service Console') {
            // Running in Service Console (not open in new tab).
            navService.navigate(pageReference);
        } 
        else {
        // Running in Financial Service Cloud, open the record in a new tab
        navService.generateUrl(pageReference).then($A.getCallback(function (url) {
            window.open(url, '_blank');
        }),
        $A.getCallback(function (error) {
            console.log('error: ' + error);
        }));
     }
    },
    //Select all contacts
    handleSelectAllContact: function(component, event, helper) {
        var size = 0;
        var getID = component.get("v.cvList");
        var checkvalue = component.find("selectAll").get("v.value");        
        var checkCV = component.find("checkCV"); 
        if(checkvalue == true){
            for(var i=0; i<checkCV.length; i++){
                var id = checkCV[i].get("v.text");
                checkCV[i].set("v.value",true);
                for(var j=0; j<getID.length; j++){
                    if(id==getID[j].Id){
                        size += getID[j].ContentSize;
                    }
                }
            }
        }
        else{ 
            for(var i=0; i<checkCV.length; i++){
                checkCV[i].set("v.value",false);
            }
            component.set("v.selectedSize",0);
        }
        component.set("v.selectedSize",size);
    },
    handleCheckBox: function(component, event, helper) {
        var size = 0;
        var getID = component.get("v.cvList");
        var checkvalue = component.find("checkCV");
        for(var j=0; j<getID.length; j++){
            size += getID[j].ContentSize;
        }
        if(!Array.isArray(checkvalue)){
            if(checkvalue.get("v.value") == false) {
                var id = checkvalue.get("v.text");
                for(var j=0; j<getID.length; j++){
                    if(id == getID[j].Id){
                        size -= getID[j].ContentSize;
                    }
                }
            }
        }
        else{
            for(var i = 0; i < checkvalue.length; i++) {
                if(checkvalue[i].get("v.value") == false) {
                    var id = checkvalue[i].get("v.text");
                    for(var j=0; j<getID.length; j++){
                        if(id==getID[j].Id){
                            size -= getID[j].ContentSize;
                        }
                    }
                }
            }
        }
        component.set("v.selectedSize",size);
    }, 
    //Process the selected contacts
    handleSelectedContacts: function(component, event, helper) {
        
        var selectedCV = [];
        var checkvalue = component.find("checkCV");
         
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                selectedCV.push(checkvalue.get("v.text"));
            }
        }else{
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    selectedCV.push(checkvalue[i].get("v.text"));
                }
            }
        }
        var val = 0;
        val = component.get("v.selectedSize")
        if(val > 20971520){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Download Size greater than 20Mb is not allowed.",
                "type": "error"
            });
            toastEvent.fire();
        }
        else{
            helper.downloadSelected(component,selectedCV);
        }
        
        
    },
    preview: function(component, event, helper) {
        var index = event.getSource().get("v.name");
        var fireEvent = $A.get("e.lightning:openFiles");
        fireEvent.fire({
            recordIds: [index]
        });
    },
    edit: function(component, event, helper) {
        var index = event.getSource().get("v.name");
        component.set("v.isView",false);
        component.set("v.isEdit",true);
        console.log('Edit record ID..'+index);
        component.set("v.viewRecordId",index);
        component.set("v.viewRecordId",index);
    },
    closeModel: function(component, event, helper) {
      component.set("v.isEdit",false);
    },
    save : function(component, event, helper) {
        try {
			component.find("edit").get("e.recordSave").fire();
            component.set("v.isEdit",false);
            //var recordIds = component.get("v.recordId");
        	//helper.callDoInit(component, recordIds);
            //$A.get("e.force:refreshView").fire();
            location.reload();
        }catch (e) {
    		var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "error!",
                "type": "error",
                "message": "Please contact to administrator."
            });
            toastEvent.fire(); 
  		}
    },
    delete: function(component, event, helper) {        
        var index = event.getSource().get("v.name");
    	if(confirm('Are you sure?')){
            var action = component.get("c.deleteContent");
            action.setParams({
                'recordIdStr': index
            });
            action.setCallback(this, function(result){
                var state = result.getState();
                if (component.isValid() && state === "SUCCESS"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Document deleted successfully."
                    });
                    toastEvent.fire(); 
                    $A.get("e.force:refreshView").fire();
                }
            });
            $A.enqueueAction(action);
        }
        
    },
 	download: function(component, event, helper) {        
    	var index = event.getSource().get("v.name");
        var action = component.get("c.downloadContent");
    	action.setParams({
            "recordIdStr": index
        });
    	console.log('test');
        action.setCallback(this, function(result){
            console.log(result.getState());
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": result.getReturnValue()
            });
            urlEvent.fire();
    	});
    	$A.enqueueAction(action);
    },
        
   	openModelCopyTo: function(component,event,helper){
        component.set("v.isCopyTo",true); 
    },
    closeModelCopyTo: function(component,event,helper){
        component.set("v.isCopyTo",false);
    	component.set("v.Applicant1",false);
        component.set("v.Applicant2",false);
        component.set("v.isSelected" , false);
    },
        
    onfocus : function(component,event,helper){
        $A.util.removeClass(component.find("mySpinnerOpp"), 'slds-hide');
        $A.util.addClass(component.find("mySpinnerOpp"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
        var getInputkeyWord = ""; 
        getInputkeyWord = component.get("v.SearchKeyWord");
        if(getInputkeyWord.length > 0 && getInputkeyWord != null){
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{
            $A.util.addClass(component.find("mySpinnerOpp"), 'slds-hide');
            $A.util.removeClass(component.find("mySpinnerOpp"), "slds-show");
            var forOpen = component.find("searchRes");
            $A.util.removeClass(forOpen, 'slds-is-open');
            $A.util.addClass(forOpen, 'slds-is-close');
        }
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchOpp", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    // get the search Input keyword
    keyPressController : function(component, event, helper) {
        $A.util.removeClass(component.find("mySpinnerOpp"), 'slds-hide');
        $A.util.addClass(component.find("mySpinnerOpp"), "slds-show");   
        var getInputkeyWord = component.get("v.SearchKeyWord");   
        console.log('!@@@@>>input' + getInputkeyWord);
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchOpp", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    
    // function for clear the Record Selection 
    clear :function(component,event,heplper){
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        component.set("v.Applicant1",false);
        component.set("v.Applicant2",false);
        component.set("v.isSelected" , false);
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord","");
        component.set("v.listOfSearchOpp", null );
        component.set("v.selectedOpp", {} );   
    },
    
    // This function call when the end User Select any record from the result list.   
    handleOppSelection : function(component, event, helper) {
        // get the selected Account record from the COMPONETN event 	 
        var selectedOpportunityGetFromEvent = event.getParam("oppByEvent");
        component.set("v.selectedOpp" , selectedOpportunityGetFromEvent); 
        component.set("v.isSelected" , true); 
        var sId = component.get("v.selectedOpp.Id");
        helper.matchHelper(component, event, sId);
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');  
        
    },    
    handleSelectedDocuments: function(component, event, helper) {
        $A.util.addClass(component.find("mySpinnerCopy"), 'slds-show');
        $A.util.removeClass(component.find("mySpinnerCopy"), "slds-hide");
        var selectedCV = [];
        var checkvalue = component.find("checkCV");
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                selectedCV.push(checkvalue.get("v.text"));
            }
        }
        else{
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    selectedCV.push(checkvalue[i].get("v.text"));
                }
            }
        }
        helper.copyFiles(component,selectedCV);
        
    },
    sortCreatedDate: function(component, event, helper) {  
        component.set("v.selectedTabsoft", 'CreatedDate');   
        var ids=[];
        var cv = component.get("v.cvList");
        if(cv.length > 0){
            for(var i = 0; i < cv.length; i++){
                ids.push(cv[i].Id);
            }
        }
        console.log(ids)
        helper.sortHelper(component, event, 'CreatedDate', ids);
    },
    sortRelatedTo: function(component, event, helper) {  
        component.set("v.selectedTabsoft", 'RelatedTo');   
        var ids=[];
        var cv = component.get("v.cvList");
        if(cv.length > 0){
            for(var i = 0; i < cv.length; i++){
                ids.push(cv[i].Id);
            }
        }
        helper.sortHelper(component, event, 'Related__c', ids);
    },
    sortCategory: function(component, event, helper) {  
        component.set("v.selectedTabsoft", 'Category');   
        var ids=[];
        var cv = component.get("v.cvList");
        if(cv.length > 0){
            for(var i = 0; i < cv.length; i++){
                ids.push(cv[i].Id);
            }
        }
        helper.sortHelper(component, event, 'Category__c', ids);
    },    
    filterCategory: function(component, event, helper){
        var selectedRelated = [];
        var selectedCategory = [];
        var checkvalue = component.find("checkCategory");
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                if(checkvalue.get("v.text")=="Applicant 1" || checkvalue.get("v.text")=="Applicant 2" 
                || checkvalue.get("v.text")=="GeneralRel"){
                    if(checkvalue.get("v.text") == "GeneralRel"){
                        selectedRelated.push("General");
                    }
                    else{
                        selectedRelated.push(checkvalue.get("v.text"));    
                    }
                    
                }
                else{
                    selectedCategory.push(checkvalue.get("v.text"));
                }
                
            }
        }else{
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    if(checkvalue[i].get("v.text") == "Applicant 1" || checkvalue[i].get("v.text") == "Applicant 2" 
                       || checkvalue[i].get("v.text") == "GeneralRel"){
                        if(checkvalue[i].get("v.text") == "GeneralRel"){
                            selectedRelated.push("General");
                        }
                        else{
                            selectedRelated.push(checkvalue[i].get("v.text"));    
                        }
                    }
                    else{
                        selectedCategory.push(checkvalue[i].get("v.text"));
                    }
                }
            }
        }
        console.log(selectedRelated);
        console.log(selectedCategory);
        helper.filterHelper(component, event, selectedRelated, selectedCategory);
    },
    openModalUpload: function(component, event, helper){
		helper.helperApplicant(component);
        component.set("v.isUpload",true);
        
    },
    closeModalUpload: function(component, event, helper){
		component.set("v.isUpload",false);            
    },
    handleDocUploadFinished: function(component, event, helper){
        var uploadedFiles = event.getParam("files");
        var idContent = [];
        for(var i=0; i<uploadedFiles.length; i++){
            idContent.push(uploadedFiles[i].documentId);
        }
        helper.fetchUploadedFiles(component, idContent);
    },
	closeIsAfter: function(component, event, helper){
		component.set("v.isAfterUpload",false);
        component.set("v.docExistError",false);
    },
    titleChange: function(component, event, helper){
		var cid = event.getSource().get("v.name");	            
        var ctxt =  event.getSource().get("v.value");
        var list = [];
        list = component.get("v.finalUpload")
        for(var i=0; i<list.length; i++){
            if(cid == list[i].Id){
                list[i].Title = ctext;
            }
            console.log(list[i].Title);
        }
        console.log(list);
        component.set("v.finalUpload",list);
    },
    descriptionChange: function(component, event, helper){
		var cid = event.getSource().get("v.name");	            
        var cdes =  event.getSource().get("v.value");
        var list = [];
        list = component.get("v.finalUpload")
        for(var i=0; i<list.length; i++){
            if(cid == list[i].Id){
                list[i].Description = cdes;
            }
        }
        console.log(list);
        component.set("v.finalUpload",list);
    },
    handleCmbRelated: function(component, event, helper){
        var cid = event.getSource().get("v.name");	            
        var selectedOptionValue = event.getParam("value");
        console.log(selectedOptionValue);
        var list = [];
        list = component.get("v.finalUpload")
        for(var i=0; i<list.length; i++){
            if(cid == list[i].ContentDocumentId){
                console.log("yes");
                list[i].Related__c = selectedOptionValue;
            }
        }
        console.log(list);
        component.set("v.finalUpload",list);
    },
    handleCmbCategory: function(component, event, helper){
        var cid = event.getSource().get("v.name");	            
        var selectedOptionValue = event.getParam("value");
        console.log('====> '+selectedOptionValue);
        var list = [];
        list = component.get("v.finalUpload")
        for(var i=0; i<list.length; i++){
            if(cid == list[i].ContentDocumentId){
                console.log("yes");
                list[i].Category__c = selectedOptionValue;
            }
            console.log(list[i].Category__c);
        }
        console.log(list);
        component.set("v.finalUpload",list);
        
        //Added by Pawan PDO-1019--
        var olddocs = component.get("v.oldDocExist");
        var cmbList = component.get("v.finalUpload");
        if(olddocs){
            for(var j=0; j< cmbList.length; j++){
                if(cmbList[j].Category__c == 'Lender Credit Contract'){
                    component.set("v.docExistError",true); 
                    break;
                }
                else{
                    component.set("v.docExistError",false);  
                }
            }
            
        } 
        else{
            component.set("v.docExistError",false);  
        }
        //Pawan Code End.
    },
    handleFinalUploadDoc: function(component, event, helper){
        component.set("v.docExistError",false);
        
		var list = [];
        list = component.get("v.finalUpload")
        for(var i=0; i<list.length; i++){
            if(list[i].Category__c == null){
                list[i].Category__c = '';
            }
        }
        helper.finalUploadDocHelper(component, list);             
    },
    deleteNewContent: function(component, event, helper){
        var index = event.getSource().get("v.name");
    	if(confirm('Are you sure?')){
            $A.util.addClass(component.find("mySpinnerUpload"), 'slds-show');
            $A.util.removeClass(component.find("mySpinnerUpload"), "slds-hide");
            var list = [];
            list = component.get("v.finalUpload")
            for(var i=0; i<list.length; i++){
                if(list[i].ContentDocumentId == index){
                    list.splice(i,1);
                }
            }
            var action = component.get("c.deleteContent");
            action.setParams({
                'recordIdStr': index
            });
            action.setCallback(this, function(result){
                var state = result.getState();
                if(component.isValid() && state === "SUCCESS"){
                    component.set("v.filesUploaded",list);
                    component.set("v.finalUpload",list);
                    console.log("yes deleted");
                }
                if(!list.length>0){
                    component.set("v.isAfterUpload",false);
                }
                $A.util.removeClass(component.find("mySpinnerUpload"), 'slds-show');
                $A.util.addClass(component.find("mySpinnerUpload"), "slds-hide");
            });
            $A.enqueueAction(action);
        }	            
    },
    openDocsPdf: function(component,event,helper){
        var selectedCV = [];
        var checkvalue = component.find("checkCV");
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                selectedCV.push(checkvalue.get("v.text"));
            }
        }else{
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    selectedCV.push(checkvalue[i].get("v.text"));
                }
            }
        }
        helper.mergePdf(component,selectedCV);
    },
        
        
        updateForLender : function(component,event,helper){
           	$A.util.removeClass(component.find("mySpinnerOpp"), "slds-show");
            var lender = event.getSource().get("v.value");
            var action = component.get("c.updateLender");
            var recordIds = component.get("v.recordId");
            var index = event.getSource().get("v.name");
            action.setParams({
                chkbx :  lender,
                CVID : index
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    helper.callDoInit(component, recordIds);
                    $A.util.addClass(component.find("mySpinnerOpp"), 'slds-hide');
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                alert("Error message: " + 
                                      errors[0].message);
                            }
                        } else {
                            alert("Unknown error");
                        }
                    }
            });
            
            $A.enqueueAction(action);
        }
})