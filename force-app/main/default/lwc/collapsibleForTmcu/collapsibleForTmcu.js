import { LightningElement, api } from 'lwc';
export default class CollapsibleForTmcu extends LightningElement {

    @api quoterecord;
    @api opprecord;
    @api conRecord;      
    @api emp1;      
    @api emp2;
    
    connectedCallback() {
        console.log('---=-',this.opprecord.Applicant_1__r.PersonContactId);
    }
}