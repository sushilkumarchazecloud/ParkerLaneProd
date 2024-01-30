({
      getContactData : function(component, event){
        var action = component.get("c.getMyAccount");
        action.setParams({ 
            conId : component.get("v.accountId")
        }); 
        
        action.setCallback(this,function(response) 
                           {
                               var  ret = response.getReturnValue();
                               if(ret){
                               component.set("v.con",ret);
                                   if(ret.Declaration__c == true && ret.Declaration_Signed_DateTime__c !=null ){
                                       component.set("v.DeclarationSigned",true);
                                       var datetime = new Date(ret.Declaration_Signed_DateTime__c);
                                       var newdatetime = new Date(datetime.toLocaleString(undefined, {timeZone: 'Australia/Canberra'}));
                                       
                                       var date = $A.localizationService.formatDate(newdatetime.toLocaleDateString(),"DD/MM/YYYY");
                                       var hours = newdatetime.getHours();
                                       var minutes = newdatetime.getMinutes();
                                       var ampm = hours >= 12 ? 'PM' : 'AM';
                                       hours = hours % 12;
                                       hours = hours ? hours : 12; // the hour '0' should be '12'
                                       minutes = minutes < 10 ? '0'+minutes : minutes;
                                       var time = hours + ':' + minutes + ' ' + ampm;
                                       
                                       component.set("v.SignedDate",date);
                                       component.set("v.SignedTime",time);
                                       component.set("v.opt1",true);
                                       component.set("v.opt2",true);
                                       component.set("v.opt3",true);
                                       component.set("v.isDeclarationBtnDisabled",true);
                                       component.set("v.decCheckBoxdisabled",true);
                                   }   
                               }
                           });
        $A.enqueueAction(action);
    },
    
    
 /*   submitDec : function(component, event){
     var action = component.get("c.updatedeclarationOnMyAccount");
        action.setParams({ conId : component.get("v.accountId"), dec : true});
        action.setCallback(this, function(response) {
            var  ret = response.getReturnValue(); 
            var state = response.getState(); 
            if (state === "SUCCESS") {  
                alert('Declaration Signed Successfully');
                component.set("v.DeclarationSigned",true);
                var datetime = new Date(ret);
                var newdatetime = new Date(datetime.toLocaleString(undefined, {timeZone: 'Australia/Canberra'}));
                
                var date = $A.localizationService.formatDate(newdatetime.toLocaleDateString(),"DD/MM/YYYY");
                var hours = newdatetime.getHours();  
                var minutes = newdatetime.getMinutes();
                var ampm = hours >= 12 ? 'PM' : 'AM'; 
                hours = hours % 12;
                hours = hours ? hours : 12; // the hour '0' should be '12'
                minutes = minutes < 10 ? '0'+minutes : minutes;
                var time = hours + ':' + minutes + ' ' + ampm;
                
                component.set("v.SignedDate",date);
                component.set("v.SignedTime",time);
                component.set("v.opt1",true);
                component.set("v.opt2",true);
                component.set("v.opt3",true);
                component.set("v.isDeclarationBtnDisabled",true);
                component.set("v.decCheckBoxdisabled",true); 
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } 
            } 
        });
        $A.enqueueAction(action); 
    }, */
})