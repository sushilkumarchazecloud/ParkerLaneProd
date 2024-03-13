import { LightningElement ,api } from 'lwc';
import getAllObject from '@salesforce/apex/Arc.getAllObject';

// //this is static resource import
import staticStyleArcRelations from "@salesforce/resourceUrl/staticStyleArcRelations";
import { loadStyle } from 'lightning/platformResourceLoader';

export default class ArcRelations extends LightningElement {

    // Current page Id
    @api recordId;
    recordName;

    // Parent to child Id
    idValue;

    //this is for static resource UI design css
    connectedCallback(){

        this.idValue = this.recordId;

        //Custom method calling from this
        this.allObjectMethod();
        
        // Load the Static style Css
        loadStyle(this, staticStyleArcRelations )
        .then(() => {
            console.log('Custom CSS loaded successfully----');
        })
        .catch((error) => {
            console.error('Error loading custom CSS: ', error);
        })
    }

    allObjectMethod() {

        getAllObject({ objectId: this.recordId })
            .then(result => {
                // Extract ParentRecord separately
                const parentRecordData = result['ParentRecord'];
                this.parentRecord = {
                    objectName: 'ParentRecord',
                    records: parentRecordData,
                };
                console.log("Parent Record Data : " + JSON.stringify(this.parentRecord));
                
                const parentRecordName = parentRecordData.map(record => record.Name);
                this.recordName = parentRecordName;
                console.log('Parent Rcord Name : ' + JSON.stringify(parentRecordName));

                // const objectLength = Object.keys(result).length - 1
                // console.log('Total object length : ' + objectLength);
            })
            .catch(error => {
                console.log("All Object Error : " + JSON.stringify(error));
            });
    }
    
    handleLink(){
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.recordId,
                actionName: 'view',
            },
        });
    }

    handleRefresh(){    
        this.template.querySelector('c-arc-object-template').refreshObjectTemplateMethod();
    }
}