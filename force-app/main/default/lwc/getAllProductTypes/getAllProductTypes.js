import { LightningElement,api,wire } from 'lwc';
import getProductTypes from '@salesforce/apex/ApplicationFormController.getAllProductTypes';
export default class GetAllProductTypes extends LightningElement {
productTypeList;

connectedCallback() {
    this.fetchCricketerData();
}
    fetchCricketerData() {
        getProductTypes()
            .then(result => {
                this.productTypeList = result;
                console.log('Data loaded successfully:', this.productTypeList);
            })
            .catch(error => {
                console.error('Error: ', error);
            });
    }

}