({
    getOppId : function(component) {
        var action = component.get('c.getOpportunityId');
        console.log(component.get('v.mgRef'));
        var pageUrl = window.location.href;
        action.setParams({
            apId : component.get('v.mgRef'),
            pgUrl : pageUrl
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS"){
            	console.log('result'+result.getReturnValue());
                component.set('v.recordId',result.getReturnValue());
                this.getContact(component);
            }
            
        });
        $A.enqueueAction(action);
	},
	getContact: function(component) {
        
		var action = component.get('c.getContacts');
        var pageUrl = window.location.href;
        action.setParams({
            oppId : component.get("v.recordId"),
            pgUrl : pageUrl
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                console.log(result);
                var arrayMapKeys = [];
                var  i = 1;
                for(var contId in result){
                    var categry =  result[contId];
                    var sldUploadList = [];
                    for(var categ in categry){
                        var docList = categry[categ];
                        
                        for(var doc in docList){
                            //console.log(doc.split("@")[1]);
                            var docwrap = docList[doc];
                            sldUploadList.push({
                                Document: doc.split("@")[0],
                                Discription : docwrap.Discription,
                                Details : docwrap.Details,
                                reason: docwrap.reason,
                                Id : doc.split("@")[1],
                                Attachments : docwrap.AttachId,
                                isAlready_provided: docwrap.isAlready_provided,
                                isComplete : docwrap.isComplete,
                                isBankStatement : docwrap.isBankStatement,
                                isNotApplicable : false,
                                isOpen : false,
                                isComment : false,
                                isStart : false,
                                count : 0,
                                value:null
                            });
                        }
                    }
                    arrayMapKeys.push({
                        label: contId,
                        value: sldUploadList
                    });
                    console.log(contId.length);
                }
               // component.set("v.options", arrayMapKeys);
               
                if(arrayMapKeys.length == 0){
                    window.open('/?Id='+component.get("v.recordId"),'_top');
                } 
                component.set("v.OrignalRecord", arrayMapKeys);
                console.log('docs'+JSON.stringify(arrayMapKeys));
            }
            this.toggleSpinner(component, event);
        });
        
        $A.enqueueAction(action);
        
    },
    getUserId : function(component){
        var action = component.get('c.getUserId');
        action.setCallback(this, function(result){
            var state = result.getState();
            if(state === "SUCCESS"){
                //alert(result.getReturnValue());
                console.log(result.getReturnValue());
                component.set('v.UserId',result.getReturnValue());
            }   
        });
        $A.enqueueAction(action);
        
    },
    getSelectedContact : function(component, contId) {
        var result = component.get("v.OrignalRecord");
        var categry =  result[contId];
        var sldUploadList = [];
        for(var categ in categry){
            var docList = categry[categ];
            
            for(var doc in docList){
                //console.log(doc.split("@")[1]);
                var docwrap = docList[doc];
                sldUploadList.push({
                    Document: doc.split("@")[0],
                    Description : docwrap.Discription,
                    Id : doc.split("@")[1],
                    Attachments : docwrap.AttachId,
                    isAlready_provided: docwrap.isAlready_provided,
                    isComplete : docwrap.isComplete,
                    isBankStatement : docwrap.isBankStatement,
                    value:null
                });
            }
        }
        component.set("v.sldUploadList", sldUploadList);
    },
    handleComplete : function(cmp, event, index){
        var sldUploadList = cmp.get("v.sldUploadList");
        var sldRecord = sldUploadList[index];
        var action = cmp.get('c.UpdateDocument');
        action.setParams({
            docReId : sldRecord.Id,
            isAlready_provided : sldRecord.isAlready_provided,
            Description : sldRecord.Description
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                sldUploadList[index].isComplete = true;
                sldUploadList[index].Attachments = [];
                cmp.set("v.sldUploadList",sldUploadList);
            }
        });
        
        $A.enqueueAction(action);
        
    },
    
    toggleSpinner: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        console.log('in spinner');
    },
    
    scrollTop: function (component, event, top){
        var scrollOptions = {
            left: 0,
            top: top,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
        console.log('in scroll');
    },
    
    DocumentStatusUpdate: function (component, event){
        var status = component.get("v.status");
        if(status != '' && status != 'COMPLETE'){
            var action = component.get("c.generateerrorTypeDoc");
            action.setParams({
                recId : component.get("v.recordId")                
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS"){
                	//alert('success');
                }
            });
            
            $A.enqueueAction(action); 
        }
    }
})