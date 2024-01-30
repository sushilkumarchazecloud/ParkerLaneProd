({
    init : function(component, event, helper) {
        console.log('>>>>>');
        helper.getParentId(component, event);
    },
    
    handleSubmit : function(cmp, event, helper) {
        event.preventDefault();       // stop the form from submitting
        const fields = event.getParam('fields');
        console.log('Called submit record')
        //fields.LastName = 'My Custom Last Name'; // modify a field
        cmp.find('myRecordForm').submit(fields);
    },
    
    handleSuccess: function (cmp, event, helper) {
        /*cmp.find('myRecordForm').showToast({
            "title": "Record updated!",
            "message": "The record has been updated successfully.",
            "variant": "success"
        });*/
    },
    
    handleError: function (cmp, event, helper) {
        cmp.find('myRecordForm').showToast({
            "title": "Something has gone wrong!",
            "message": event.getParam("message"),
            "variant": "error"
        });
    }
})