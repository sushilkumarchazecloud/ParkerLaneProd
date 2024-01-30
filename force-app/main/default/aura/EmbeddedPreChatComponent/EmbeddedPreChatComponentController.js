({
    onInit: function(cmp, evt, hlp) {
        // Get pre-chat fields defined in setup using the prechatAPI component
        var prechatFields = cmp.find("prechatAPI").getPrechatFields();
        prechatFields.forEach(function(field) {
            var fieldName = field.name; 
            if(fieldName == "FirstName"){
                if(field.value != null){
                cmp.set("v.first_name",field.value);
                cmp.set("v.noPredata",false);
                }
                else{
                    cmp.set("v.noPredata",true);
                }
            }
        }); 
    },
    
    subjectOnchange : function(cmp, evt, hlp) {
        var nopredata = cmp.get("v.noPredata");
        if(nopredata){
            var emailInputCmp = cmp.find("emll").get("v.value");
            var allValid = false;
            if(emailInputCmp){
                var emailPattern = /^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{1,5})$/;
                var isValidEmail = emailPattern.test(emailInputCmp);
                if (isValidEmail) {
                    allValid = true;
                } else {
                    allValid = false;
                }
            }
            var frstName = cmp.find("firstname").get("v.value");
            var lstName = cmp.find("lastname").get("v.value");
            var eml = cmp.find("emll").get("v.value");
            var val = cmp.find("customSubjectField").get("v.value");
            if(frstName != '' && lstName != '' && eml != '' && val != '' && allValid){
                cmp.set("v.btndisabled",false); 
            }
            else{
                cmp.set("v.btndisabled",true); 
            }
        }
        else if(!nopredata){ 
            var val = cmp.find("customSubjectField").get("v.value");
            if(val != ''){
                cmp.set("v.btndisabled",false);
            }
            else{
                cmp.set("v.btndisabled",true);
            }  
        }
    },
    
    handleStartButtonClick: function(cmp, evt, hlp) {
        var prechatAPI = cmp.find("prechatAPI");
        // Get the pre-chat field values
        var prechatFields = prechatAPI.getPrechatFields();
         
        var nopredata = cmp.get("v.noPredata");
        // Set the custom Subject field from your input field with class "inp"
        prechatFields.forEach(function (field) {
            if(nopredata){
                if (field.label === "FirstName") {
                    field.value = cmp.find("firstname").get("v.value");
                } 
                if (field.label === "LastName") {
                    field.value = cmp.find("lastname").get("v.value");
                } 
                if (field.label === "Email") {
                    field.value = cmp.find("emll").get("v.value");
                } 
                if (field.label === "Subject") {
                    field.value = cmp.find("customSubjectField").get("v.value");
                } 
            }
            else{
                if (field.label === "Subject") {
                    field.value = cmp.find("customSubjectField").get("v.value");
                }
            }
        });
         // Start the chat with updated pre-chat fields
        prechatAPI.startChat(prechatFields);
    },
    
    checkEmail : function(component, event, helper) {
        var emailInputCmp = component.get('v.custEmail');
        var email = emailInputCmp.trim();
        component.set("v.custEmail",email);
    },
});