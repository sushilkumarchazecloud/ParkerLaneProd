({  
      
    fetchRecords : function(component, event, helper) {  
          
        var temObjName = component.get( "v.sobjectName" );  
		var tempTitle = component.get( "v.title" );  
        var action = component.get( "c.fetchRecs" );  
        component.set( "v.title", tempTitle );
        console.log('>>>>>>'+tempTitle);
        console.log('>>>>>>'+component.get( "v.recordId" ));
        console.log('>>>>>>'+component.get( "v.parentFieldName" ));
        console.log('>>>>>>'+component.get( "v.fieldSetName" ));
        console.log('>>>>>>'+component.get( "v.childRelName" ));
        action.setParams({  
            recId: component.get( "v.recordId" ),  
            sObjName: temObjName,  
            parentFldNam: component.get( "v.parentFieldName" ),  
            fieldSetName: component.get( "v.fieldSetName" ),
            childRelName: component.get( "v.childRelName" )
        });  
        action.setCallback(this, function(response) {  
            var state = response.getState();  
            console.log(state);
            if ( state === "SUCCESS" ) {  
                var res = response.getReturnValue();
                component.set( "v.listRecords", res.listsObject );
                component.set( "v.parentRecId", res.parentRecId );
                component.set( "v.title", tempTitle + res.strTitle );  
                component.set( "v.fieldsList",  JSON.parse(res.fieldSetList) );
                component.set( "v.fieldsAPIList",  JSON.parse(res.fieldAPIList) );
            }  
        });  
        $A.enqueueAction(action);  
          
    },  
      
    viewRelatedList: function (component, event, helper) {  
          
        var navEvt = $A.get("e.force:navigateToRelatedList");  
        navEvt.setParams({  
            "relatedListId": component.get( "v.childRelName" ),  
            "parentRecordId": component.get( "v.parentRecId" )  
        });  
        navEvt.fire();  
    },  
      
    viewRecord: function (component, event, helper) {  
          
        var navEvt = $A.get("e.force:navigateToSObject");  
        var recId = event.getSource().get( "v.value" )  
        navEvt.setParams({  
            "recordId": recId  
        });  
        navEvt.fire();  
          
    }  
      
})