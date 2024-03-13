import { LightningElement } from 'lwc';
import SolarLoan from '@salesforce/resourceUrl/SolarLoan';
import ChazeCloud from '@salesforce/resourceUrl/ChazeCloud';

export default class GenericHeader extends LightningElement {
    plImg = ChazeCloud;
    headerlogo = SolarLoan + '/img/uploadicon.png';
}