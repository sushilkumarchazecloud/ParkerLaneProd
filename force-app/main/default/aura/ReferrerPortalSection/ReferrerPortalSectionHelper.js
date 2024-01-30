({
    getdeclarationmodel : function(component, event){
        var action = component.get("c.getMyAccount");
        action.setParams({ 
            conId : component.get("v.accountId")
        }); 
        action.setCallback(this,function(response) {
            var  ret = response.getReturnValue(); 
            if(ret){
                if(ret.Declaration__c == true && ret.Declaration_Signed_DateTime__c !=null ){
                    component.set("v.isDeclarationModalOpen",false);
                }
                else{
                    component.set("v.isDeclarationModalOpen",true);
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    
    getContactData : function(component, event){
        var action = component.get("c.getContact");        
        
        action.setParams({
            contactId : component.get("v.accountId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var retrnVal = response.getReturnValue();
                component.set("v.con",retrnVal);
                //  alert('-11--'+component.get("v.con.Portal_View__c"));
                var temp = retrnVal.Name;
                var myArray = temp.split(" ");
                if(myArray[1] == null){
                    myArray = temp.charAt(0);
                    component.set("v.conName",myArray);
                }
                else{
                    component.set("v.conName", myArray[0][0] + ' ' + myArray[1][0]);
                }
            }else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE RESPONSE");
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });
        $A.enqueueAction(action);
    }
})