import { LightningElement } from 'lwc';
import SolarLoan from '@salesforce/resourceUrl/SolarLoan';

export default class GenericHeader extends LightningElement {
    plImg = SolarLoan + '/img/logowhite.png';
    headerlogo = SolarLoan + '/img/uploadicon.png';
}