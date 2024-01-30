({
    doInIt : function(component, event, helper) {
        var accr = component.get("v.item");
        if(accr != null){
            var datetime = new Date(accr.Action_DateTime__c);
            var newdatetime = new Date(datetime.toLocaleString(undefined, {timeZone: 'Australia/Canberra'}));
            
            var date = $A.localizationService.formatDate(newdatetime.toLocaleDateString(),"DD MMM YYYY");
            var hours = newdatetime.getHours();
            var minutes = newdatetime.getMinutes();
            var ampm = hours >= 12 ? 'PM' : 'AM';
            hours = hours % 12;
            hours = hours ? hours : 12; 
            minutes = minutes < 10 ? '0'+minutes : minutes;
            var time = hours + ':' + minutes + ' ' + ampm;
            
            component.set("v.PreviousrequestDate",date);
            component.set("v.PreviousrequestTime",time); 
            
            var reqbody = (accr.Request_Body__c);
            if(reqbody.length >= 50){
            var str = reqbody.slice(0,50) +'...';
            component.set("v.PreviousrequestNotes",str);
            }
            else {
              component.set("v.PreviousrequestNotes",reqbody);
            }
                
        }
    },
})