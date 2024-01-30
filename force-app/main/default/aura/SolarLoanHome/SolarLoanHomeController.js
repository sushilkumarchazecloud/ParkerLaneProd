({    
    doInit : function(component, event, helper) {        
        var recordId =component.get("v.recordId");
       	var action = component.get("c.getOpportunityRec");
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                component.set("v.oppData",res);
                var temp = component.get("v.IsApplicantTwo");
                var opp = component.get("v.oppData");
                //alert('temp-->'+temp);
                 //alert('temp-->'+opp.app_Two_completed_Summary__c);
                if(temp == 'true'){
                    if(opp.Lender__c == 'Transport Mutual Credit Union'){                                               
                        component.set("v.isTMCU",true);                        
                    }
                    else{
                     //   alert('cfcu-->'+temp);
                        var label = $A.get("$Label.c.baseUrl");
                        var red = label + "supportingDocument?oppId=" + recordId;
                        console.log('_red->'+red);
                        window.location = red;
                    }                 
                }
                else{
                    //alert('tempopop-->'+opp.app_Two_completed_Summary__c);
                    if(res.app_Two_completed_Summary__c == true){
                       // alert('app2 complete');
                        var label = $A.get("$Label.c.baseUrl");
                        var red = label + "supportingDocument?oppId=" + recordId;
                        console.log('_red->'+red);
                        window.location = red; 
                    }    
                }
                helper.getSectionStatus(component, event, recordId);
            }
        });
        $A.enqueueAction(action);                
    },
})