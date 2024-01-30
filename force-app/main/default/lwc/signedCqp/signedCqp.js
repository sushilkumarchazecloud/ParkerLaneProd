import { LightningElement, api,track } from 'lwc';
import LwcStyle from '@salesforce/resourceUrl/LwcStyle';
import { loadStyle } from 'lightning/platformResourceLoader';
export default class SignedCqp extends LightningElement {

    @api quoterecord;
    @api opprecord;
    @api condata;      
    @api emp1;      
    @api emp2; 
    @track appSecName;

    connectedCallback() {
        this.appSecName = (this.opprecord.Applicant_2__c != null ? ' And '+this.opprecord.Applicant_2__r.Name : '');  
        loadStyle(this,  LwcStyle + '/esign.css')
            .then(() => {
                console.log('Custom CSS loaded successfully');
            })
            .catch((error) => {
                console.error('Error loading custom CSS: ', error);
            });          
    }
    
    openPreliminaryPDF() {
        var url = '/apex/PreliminaryAssessmentPDF?id='+this.opprecord.Id;
        window.open(url);
    }
}