import { LightningElement, api, track} from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { deleteRecord } from 'lightning/uiRecordApi';

import getAllObject from '@salesforce/apex/Arc.getAllObject';

//this is static resource import
import staticStyleArcRecordTemplate from "@salesforce/resourceUrl/staticStyleArcRecordTemplate";
import { loadStyle } from 'lightning/platformResourceLoader';

export default class ArcRecordTemplate extends NavigationMixin(LightningElement) {

    @api objectid;
    @api objectname;

    @track objectData = [];

    particularObjectRecord;
    isCase;
    isContracts;
    isOrders;

    particularRecordId;
    particularAccountId;

    @track isLoading = false;

    //this is for static resource UI design css
    connectedCallback(){

        this.allRecordMethod();

        console.log('Record Object Id : ' + this.objectid);
        console.log('Record Object Name : ' + this.objectname);

        loadStyle(this, staticStyleArcRecordTemplate )
        .then(() => {
            console.log('Custom CSS loaded successfully----');
        })
        .catch((error) => {
            console.error('Error loading custom CSS: ', error);
        })
    }

    allRecordMethod() {
        this.isLoading = true;
        getAllObject({ objectId: this.objectid })
            .then(result => {
                this.objectData = Object.keys(result).map(objectName => ({
                    objectName: objectName,
                    records: result[objectName],
                    allRecordId: result[objectName].map(record => record.Id),
                }));
    
                this.objectData.forEach(obj => {
                    if (this.objectname === obj.objectName) {
                        console.log('Matching Object Name : ' + JSON.stringify(obj.objectName));
                        this.particularObjectRecord = obj.records;
                        console.log('Matching Object Records : ' + JSON.stringify(this.particularObjectRecord));

                        if(obj.objectName === 'Cases'){
                            this.isCase = obj.records;
                        }
                        else if(obj.objectName === 'Contracts'){
                            this.isContracts = obj.records;
                        }
                        else if(obj.objectName === 'Orders'){
                            this.isOrders = obj.records;
                        }
                        else if(obj.objectName != 'Cases' && obj.objectName != 'Contracts' && obj.objectName != 'Orders'){
                            this.particularObjectRecord.forEach(record => {
                                if(record.Name.length > 20){
                                    let truncatedCategory = record.Name.substr(0, 20) + '...';
                                    record.Name = truncatedCategory;
                                }
                            });
                        }
                    }
                });
                this.isLoading = false;
            })
            .catch(error => {
                console.log("All Object Error : " + JSON.stringify(error));
                this.isLoading = false;
            });
    }

    handleLink(event){
        const recordId = event.currentTarget.dataset.recordId;

        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: recordId,
                actionName: 'view',
            },
        });
    }

    handleOnselect(event){
        let onSelect = event.detail.value;

        const recordId = event.currentTarget.dataset.recordId;
        console.log('>>>>>>>>>>>>' + JSON.stringify(recordId));

        window.addEventListener('popstate', this.handleUrlChange);
        this.currentUrl = window.location.href;
        console.log('this.currentUrl : ' + JSON.stringify(this.currentUrl));

        if(onSelect === 'edit'){
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: recordId,
                    actionName: 'edit',
                }
            })
        }
        else if(onSelect === 'delete'){
            deleteRecord(recordId)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Record deleted",
                        variant: "success",
                    }),
                );
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error deleting record",
                        message: error.body.message,
                        variant: "error",
                    }),
                );
            });
        }
    }

    handleHierarchy(event) {
        const recordId = event.currentTarget.dataset.recordId;
        console.log('>>>>>>>>>>>>' + JSON.stringify(recordId));

        const objectIds = this.particularObjectRecord.map(record => record.Id);

        // This only to get AccountId for arcHierachyObjectTemplate component for navigation in New record
        this.particularObjectRecord.forEach(rec =>{
            if(recordId === rec.Id){
                console.log('One Account Id : ' + rec.AccountId);
                this.particularAccountId = rec.AccountId;
            }
        });

        if (recordId) {
            this.particularRecordId = recordId;

            if(recordId.startsWith('800')){
                this.isContracts = this.isContracts.map(record => ({
                    ...record, 
                    isOpen: record.Id === recordId ? !record.isOpen : false,
                    isHorizontalLine: record.Id === recordId ? !record.isHorizontalLine : false,
                }));
            }
            else {
                this.particularObjectRecord = this.particularObjectRecord.map(record => ({
                    ...record,
                    isOpen: record.Id === recordId ? !record.isOpen : false,
                    isHorizontalLine: record.Id === recordId ? !record.isHorizontalLine : false,
                }));
            }

            let changeCss = this.template.querySelectorAll(`[data-record-id="${recordId}"]`);

            changeCss.forEach(element => {
                if (element.classList.contains('mainDiv')) {
                    element.classList.remove('mainDiv');
                    element.classList.add('mainDivHierarchy');
                } 
                else if (element.classList.contains('mainDivHierarchy')) {
                    element.classList.remove('mainDivHierarchy');
                    element.classList.add('mainDiv');
                }
            });

            // remain Css from all other records
            objectIds.forEach(id => {
                if (id !== recordId) {
                    let remainCss = this.template.querySelectorAll(`.mainDivHierarchy[data-record-id="${id}"]`);
                    remainCss.forEach(element => {
                        element.classList.remove('mainDivHierarchy');
                        element.classList.add('mainDiv');
                    });
                }
            });
        }
    }

}