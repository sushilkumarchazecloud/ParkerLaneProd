({
    doInIt : function(component, event, helper) {
        
        var req_Status = component.get("v.item.Request_Status__c");
        if(req_Status != null){
        component.set("v.RequestStatus",req_Status.toUpperCase());
        }
        
        var funding_req = component.get("v.item");
        if(funding_req != null){
            var datetime = new Date(funding_req.Request_Date__c);
            var newdatetime = new Date(datetime.toLocaleString(undefined, {timeZone: 'Australia/Canberra'}));
            
            var date = $A.localizationService.formatDate(newdatetime.toLocaleDateString(),"DD MMM YYYY");
            var hours = newdatetime.getHours();
            var minutes = newdatetime.getMinutes();
            var ampm = hours >= 12 ? 'PM' : 'AM';
            hours = hours % 12;
            hours = hours ? hours : 12; 
            minutes = minutes < 10 ? '0'+minutes : minutes;
            var time = hours + ':' + minutes + ampm;
            
            component.set("v.PreviousrequestDate",date);
            component.set("v.PreviousrequestTime",time); 
            
            var Date_last_Status = funding_req.Date_Last_Request_Status_Changes__c; 
            if(Date_last_Status != null){
            var Date_Last_Request_Status_Changes__c = new Date(Date_last_Status);
            var datetimeLast = new Date(Date_Last_Request_Status_Changes__c.toLocaleString(undefined, {timeZone: 'Australia/Canberra'}));
            
            var lastDateOnly = $A.localizationService.formatDate(datetimeLast.toLocaleDateString(),"DD MMM YYYY");
            component.set("v.DateLastStatus",lastDateOnly);
                
            }
        }
    },
})