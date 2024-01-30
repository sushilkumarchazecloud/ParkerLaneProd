({
    doInit : function(component, event, helper) {
        helper.showSpinnerForThreeSeconds(component, event, helper);
        var approvedDate = component.get("v.oppWrapper.Approved_Date__c");
        var expireDate =  component.get("v.oppWrapper.Approved_Expire_Date__c");
        var options = { year: 'numeric', month: 'long', day: 'numeric' };
        var formattedDateTime = new Date(approvedDate).toLocaleDateString(undefined, options);
        component.set("v.approvedDate",formattedDateTime);
        var currentDate = new Date();
        var expiryDate = new Date(expireDate);
        var timeDifference = expiryDate.getTime() - currentDate.getTime();
        var daysDifference = Math.floor(timeDifference / (1000 * 60 * 60 * 24));
        component.set("v.expireDays", daysDifference);
    }
})