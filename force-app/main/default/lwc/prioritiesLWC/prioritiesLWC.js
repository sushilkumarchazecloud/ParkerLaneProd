import { LightningElement, track } from 'lwc';
import getProducts from '@salesforce/apex/ApplicationFormController.getFeaturedProducts';
import getProductTypes from '@salesforce/apex/ApplicationFormController.getAllProductTypes';
import createLeadAndQuotes from '@salesforce/apex/ApplicationFormController.createLeadAndQuotes';

export default class PrioritiesLWC extends LightningElement {
    @track applicationSection;
    @track appSectionPath = [];
    @track featuredProducts = [];
    @track showQuote = false;
    @track myPriority;
    @track repayOverTerm;
    @track homeOwner;
    @track customerAmount;
    @track applicantFName;
    @track applicantLName;
    @track applicantEmail;
    @track purpose;
    @track loanTitle = 'Featured';
    @track isShowGetQuote = false;
    @track recordId;
    @track masterQuote;
    @track showErrorParent = false;
    @track errorMsg;

    @track productTypeList = [];
    @track selectedProductTypeId = '';
    @track showSpinner = false;

    connectedCallback() {
        this.doInit();
    }

    doInit() {
        this.showSpinner = true;
        getProducts()
            .then(result => {
                this.featuredProducts = result;
                return getProductTypes();
            })
            .then(productTypes => {
                this.productTypeList = productTypes;
            })
            .catch(error => {
                this.showErrorParent = true;
                this.errorMsg = 'Error fetching data: ' + error.message;
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    handleSelectedProductType(event) {
        this.selectedProductTypeId = event.target.value;
        this.purpose = event.target.name;
        this.showQuote = true;
    }

    handleSaveNext() {
        const solarLoanGetQuote = this.template.querySelector('c-solar-loan-get-quote');
        const isValidate = solarLoanGetQuote.checkApplicantDetails();

        if (isValidate) {
            this.showSpinner = true;
            createLeadAndQuotes({
                productType: this.purpose,
                cFName: this.applicantFName,
                cLName: this.applicantLName,
                cEmail: this.applicantEmail,
                cAmount: this.customerAmount,
                myPriority: this.myPriority,
                repayOverTerm: this.repayOverTerm,
                homeOwner: this.homeOwner,
                ProductTypeId: this.selectedProductTypeId
            })
                .then(result => {
                    // Handle success
                })
                .catch(error => {
                    this.showErrorParent = true;
                    this.errorMsg = 'Error creating lead and quotes: ' + error.message;
                })
                .finally(() => {
                    this.showSpinner = false;
                });
        }

        // Scroll to the top
        window.scrollTo({
            top: 0,
            left: 0,
            behavior: 'smooth'
        });
    }
}