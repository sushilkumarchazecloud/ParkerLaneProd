import { LightningElement , api, track} from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";

import getAllObject from '@salesforce/apex/Arc.getAllObject';

//this is static resource import
import staticStyleArcObjectTemplate from "@salesforce/resourceUrl/staticStyleArcObjectTemplate";
import { loadStyle } from 'lightning/platformResourceLoader';

export default class ArcHierarcyObjectTemplate extends NavigationMixin(LightningElement) {

    @api recordidvalue;
    @api recordaccountidvalue;

    @track objectData = [];

    @track isExpanded = false;
    expandTemplate = false;

    recordObjectId;
    recordObjectName;

    @track isLoading = false;

    //this is for static resource UI design css
    connectedCallback(){

        this.recordObjectId = this.recordidvalue;

        //Custom method calling from this
        this.allObjectMethod();
        
        loadStyle(this, staticStyleArcObjectTemplate )
        .then(() => {
            console.log('Custom CSS loaded successfully----');
        })
        .catch((error) => {
            console.error('Error loading custom CSS: ', error);
        })
        
    }

    // this is for all related record data
    allObjectMethod() {

        console.log('From allObjectMethod : ' + this.recordidvalue);
        this.isLoading = true;

        getAllObject({ objectId: this.recordidvalue })
            .then(result => {
                console.log("All Object Data : " + JSON.stringify(result));

                this.objectData = Object.keys(result).map(objectName => ({
                    objectName: objectName,
                    records: result[objectName],
                    icon: this.getObjectIcon(objectName),
                    recordCount: result[objectName].length,
                    hasRecords: result[objectName].length > 0,
                    hasNoRecords: result[objectName].length === 0, 
                    isParent: objectName === 'ParentRecord',
                    dynamicIconName : 'utility:chevronright',
                }));
                this.isLoading = false;
            })
            .catch(error => {
                console.log("All Object Error : " + JSON.stringify(error));
                this.isLoading = false;
            });
    }
    

    getObjectIcon(objectName){
        const iconMappings = {
            'Cases': 'standard:case',
            'Opportunities': 'standard:opportunity',
            'Contacts':'standard:contact',
            'Contracts':'standard:contract',
            'Partners':'standard:partners',
            'Orders': 'standard:orders',
        };
        return iconMappings[objectName] || 'standard:account';    
    }

    handleExpand(event) {
        const clickedObjectName = event.target.dataset.objectName;
        console.log('Object Name : ' + clickedObjectName);
    
        this.recordObjectName = clickedObjectName;
    
        this.objectData.forEach(obj => {
            if (obj.objectName !== clickedObjectName) {
                obj.isExpanded = false;
                obj.dynamicIconName = 'utility:chevronright';
            }
            else if(obj.objectName === clickedObjectName){
                obj.isExpanded = ! obj.isExpanded;

                if (obj.isExpanded) {
                    obj.dynamicIconName = 'utility:chevrondown';
                } 
                else {
                    obj.dynamicIconName = 'utility:chevronright';
                }        
            }
        });
    }

    handleNewClick(event) {
        const clickedObjectName = event.target.dataset.objectName;
        console.log('Object Name : ' + clickedObjectName);
        console.log('Parent Account Id : ' + this.recordaccountidvalue);
    
        const objectApiNameMap = {
            'Contacts': 'Contact',
            'Cases': 'Case',
            'Opportunities': 'Opportunity',
            'Contracts':'Contract',
            'Partners': 'Partner',
            'Orders' : 'Order',
        };
    
        const objectApiName = objectApiNameMap[clickedObjectName];
    
        if (objectApiName) {
            let recordTypeField;
    
            if (this.recordidvalue.startsWith('003')) {
                recordTypeField = 'ContactId';
            } 
            else if (this.recordidvalue.startsWith('006')) {
                recordTypeField = 'OpportunityId';
            } 
            else if (this.recordidvalue.startsWith('500')) {
                recordTypeField = 'CasesId';
            }
            else if (this.recordidvalue.startsWith('800')) {
                recordTypeField = 'ContractId';
            }
    
            const defaultValues = encodeDefaultFieldValues({
                AccountId: this.recordaccountidvalue,
                [recordTypeField]: this.recordidvalue,
            });
    
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: objectApiName,
                    actionName: 'new',
                },
                state: {
                    defaultFieldValues: defaultValues,
                    navigationLocation: 'RELATED_LIST',
                },
            });
        }
    }

}