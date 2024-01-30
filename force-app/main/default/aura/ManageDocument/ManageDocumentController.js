({
	doInit: function(component, event, helper) {
        var action = component.get('c.checkApplicantTwo');
        var recordId = component.get('v.recordId');
        recordId = recordId.trim();
        console.log('recordId'+recordId);
        action.setParams({ oppId : recordId });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.isApplicantTwo", response.getReturnValue());
                console.log('===> '+response.getReturnValue());        
        		console.log('===> '+component.get("v.isApplicantTwo"));        
                helper.getApplicantsOne(component);
                helper.getApplicantsTwo(component);
                helper.getJointApplications(component);
            }
        });
        
        $A.enqueueAction(action);
        
    },
    makeRequest :function(component, event, helper) {
        var documentRequestList = [];
        var applicantOne = component.get("v.applicantOne");
        var selectedItemAppOne =[];
        var selectedItemApptwo =[];
        var selectedItemJoint =[];
        for(index in applicantOne){
            var item = applicantOne[index];
            var value = item.value;
            var selectedItem =[];
            for(ind in value){
                if(value[ind].isSelected){
                    selectedItem.push({
                        label: value[ind].label,
                        value: value[ind].value,
                        Discription : value[ind].Discription,
                        isBankStatment : value[ind].isBankStatment
                    });
                }
            }
            if(selectedItem.length > 0){
                selectedItemAppOne.push({
                    categry : item.key,
                    selectedItem : selectedItem
                });
            }
        }
        if(selectedItemAppOne.length > 0){
            documentRequestList.push({
                label : 'ApplicantOne',
                value: selectedItemAppOne
            });
        }
        if(component.get("v.isApplicantTwo")){
            var applicantTwo = component.get("v.applicantTwo"); 
            for(var index in applicantTwo){
                var item = applicantTwo[index];
                var value = item.value;
                var selectedItem =[];
                for(var ind in value){
                    if(value[ind].isSelected){
                        selectedItem.push({
                            label: value[ind].label,
                            value: value[ind].value,
                            Discription : value[ind].Discription,
                            isBankStatment : value[ind].isBankStatment
                        });
                    }
                }
                if(selectedItem.length > 0){
                    selectedItemApptwo.push({
                        categry : item.key,
                        selectedItem : selectedItem
                    });
                }
            }
            if(selectedItemApptwo.length > 0){
                documentRequestList.push({
                    label : 'ApplicantTwo',
                    value: selectedItemApptwo
                });
            }
        }
        var jointApplication = component.get("v.jointApplication");
        for(var index in jointApplication){
            var item = jointApplication[index];
            var value = item.value;
            var selectedItem =[];
            for(var ind in value){
                if(value[ind].isSelected){
                    selectedItem.push({
                        label: value[ind].label,
                        value: value[ind].value,
                        Discription : value[ind].Discription,
                        isBankStatment : value[ind].isBankStatment
                    });
                }
            }
            if(selectedItem.length > 0){
                selectedItemJoint.push({
                    categry : item.key,
                    selectedItem : selectedItem
                });
            }
        }
        if(selectedItemJoint.length > 0){
            documentRequestList.push({
                label : 'JointApp',
                value: selectedItemJoint
            });
        }
        helper.createDocumentRequest(component, documentRequestList, component.get("v.isApplicantTwo"),true);
    },
    sendRequest :function(component, event, helper) {
        var documentRequestList = [];
        var applicantOne = component.get("v.applicantOne");
        var selectedItemAppOne =[];
        var selectedItemApptwo =[];
        var selectedItemJoint =[];
        for(index in applicantOne){
            var item = applicantOne[index];
            var value = item.value;
            var selectedItem =[];
            for(ind in value){
                if(value[ind].isSelected){
                    selectedItem.push({
                        label: value[ind].label,
                        value: value[ind].value,
                        Discription : value[ind].Discription,
                        isBankStatment : value[ind].isBankStatment
                    });
                }
            }
            if(selectedItem.length > 0){
                selectedItemAppOne.push({
                    categry : item.key,
                    selectedItem : selectedItem
                });
            }
        }
        if(selectedItemAppOne.length > 0){
            documentRequestList.push({
                label : 'ApplicantOne',
                value: selectedItemAppOne
            });
        }
        if(component.get("v.isApplicantTwo")){
            var applicantTwo = component.get("v.applicantTwo"); 
            for(var index in applicantTwo){
                var item = applicantTwo[index];
                var value = item.value;
                var selectedItem =[];
                for(var ind in value){
                    if(value[ind].isSelected){
                        selectedItem.push({
                            label: value[ind].label,
                            value: value[ind].value,
                            Discription : value[ind].Discription,
                            isBankStatment : value[ind].isBankStatment
                        });
                    }
                }
                if(selectedItem.length > 0){
                    selectedItemApptwo.push({
                        categry : item.key,
                        selectedItem : selectedItem
                    });
                }
            }
            if(selectedItemApptwo.length > 0){
                documentRequestList.push({
                    label : 'ApplicantTwo',
                    value: selectedItemApptwo
                });
            }
        }
        var jointApplication = component.get("v.jointApplication");
        for(var index in jointApplication){
            var item = jointApplication[index];
            var value = item.value;
            var selectedItem =[];
            for(var ind in value){
                if(value[ind].isSelected){
                    selectedItem.push({
                        label: value[ind].label,
                        value: value[ind].value,
                        Discription : value[ind].Discription,
                        isBankStatment : value[ind].isBankStatment
                    });
                }
            }
            if(selectedItem.length > 0){
                selectedItemJoint.push({
                    categry : item.key,
                    selectedItem : selectedItem
                });
            }
        }
        if(selectedItemJoint.length > 0){
            documentRequestList.push({
                label : 'JointApp',
                value: selectedItemJoint
            });
        }
        helper.createDocumentRequest(component, documentRequestList, component.get("v.isApplicantTwo"),false);
    },
    selectCategory: function(component, event, helper) {
		var appType = event.target.id;
        
        var action = component.get('c.getSelectedCategory');
        action.setParams({ applicationType : appType });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                var applicantOne = component.get("v.applicantOne");
                for(var key in applicantOne){
                    if(result.hasOwnProperty(applicantOne[key].key)){
                        var value = applicantOne[key].value;
                        var serverResult = result[applicantOne[key].key];
                        for(var index in value){
                            if(serverResult.includes(value[index].value)){
                                value[index].isSelected = true;
                            }
                        }
                        applicantOne[key].value = value;
                    }	
                    
                }
                component.set("v.applicantOne", applicantOne);
                
                var applicantTwo = component.get("v.applicantTwo");
                for(var key in applicantTwo){
                    if(result.hasOwnProperty(applicantTwo[key].key)){
                        var value = applicantTwo[key].value;
                        var serverResult = result[applicantTwo[key].key];
                        for(var index in value){
                            if(serverResult.includes(value[index].value)){
                                value[index].isSelected = true;
                            }
                        }
                        applicantTwo[key].value = value;
                    }	
                    
                }
                component.set("v.applicantTwo", applicantTwo);
                
                var jointApplication = component.get("v.jointApplication");
                for(var key in jointApplication){
                    if(result.hasOwnProperty(jointApplication[key].key)){
                         var value = jointApplication[key].value;
                        var serverResult = result[jointApplication[key].key];
                        for(var index in value){
                            if(serverResult.includes(value[index].value)){
                                value[index].isSelected = true;
                            }
                        }
                        jointApplication[key].value = value;
                    }	
                    
                }
                component.set("v.jointApplication", jointApplication);
            }
        });
        
        $A.enqueueAction(action);
      
    },
    
    showSpinner: function(component, event, helper) {
       
        component.set("v.isWating", true); 
   },
    
 
    hideSpinner : function(component,event,helper){
     
       component.set("v.isWating", false);
    },
    done : function (cmp, event, helper){
       
    }
})