({
	getApplicantsOne : function(component) {
		var action = component.get('c.getApplicantOne');
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                var arrayMapKeys = [];
                for(var key in result){
                    arrayMapKeys.push({key: key, value: result[key]});
                }
                component.set("v.applicantOne", arrayMapKeys);
            }
        });
        
        $A.enqueueAction(action);
        
	},
    getApplicantsTwo : function(component) {
		var action = component.get('c.getApplicantTwo');
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                var arrayMapKeys = [];
                for(var key in result){
                    arrayMapKeys.push({key: key, value: result[key]});
                }
                component.set("v.applicantTwo", arrayMapKeys);
            }
        });
        
        $A.enqueueAction(action);
	},
    getJointApplications : function(component) {
		var action = component.get('c.getJointApplication');
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                var arrayMapKeys = [];
                for(var key in result){
                    arrayMapKeys.push({key: key, value: result[key]});
                }
                component.set("v.jointApplication", arrayMapKeys);
                this.callDom(component);
            }
        });
        
        $A.enqueueAction(action);
	},
    createDocumentRequest : function (component, documentRequestList, isAppTwo,isSendEmail){
        var action = component.get('c.createDocumentRequest');
        action.setParams({ 
            documentList : JSON.stringify(documentRequestList),
            isAppTwo : isAppTwo,
            oppId : component.get('v.recordId'),
            isSendEmail : isSendEmail
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.isSuccess", true);
                $A.createComponent(
                    "ui:message",
                    {
                        "title": "Successfully Created Document Request!",
                        "severity": "confirm"
                    },
                    function(newButton, status, errorMessage){
                        //Add the new button to the body array
                        if (status === "SUCCESS") {
                            var body = component.get("v.body");
                            body.push(newButton);
                            component.set("v.body", body);
                        }
                        else if (status === "INCOMPLETE") {
                            console.log("No response from server or client is offline.")
                            // Show offline error
                        }
                            else if (status === "ERROR") {
                                console.log("Error: " + errorMessage);
                                // Show error message
                            }
                    }
                );
                
            }
        });
        
        $A.enqueueAction(action);
    },
    postionset: function( i, key){
        var ele = document.getElementById(key+''+i);
        var chil = document.getElementById(key+''+i+2);
        console.log(ele);
        console.log(chil);
        if(ele && chil){
            var parent = ele.offsetTop + ele.offsetHeight;
            var chl = chil.offsetTop;
            if(chl-parent > 15){
                chil.style.position = "absolute";
                chil.style.width = "inherit";
                chil.style.top =  parent + 12 +"px";
        }
        }
    },
    callDom: function(cmp){
        if(!cmp.get("v.isApplicantTwo")){
            var applicantOnelist = cmp.get("v.applicantOne");
            if(applicantOnelist){
                console.log('test');
                var applicantOne = applicantOnelist.length -1;
                for(var i = 0 ; i < applicantOne; i++ )
                    this.postionset(i, 'Applicant1');
            }
            var applicantOneList = cmp.get("v.jointApplication");
            if(applicantOneList){
                applicantOne = applicantOneList.length - 1;
                for(var i = 0 ; i < applicantOne; i++ )
                    this.postionset( i, 'General');
            }
        }
    }
})