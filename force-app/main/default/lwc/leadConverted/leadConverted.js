import { LightningElement , api , wire , track} from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import { CloseActionScreenEvent } from 'lightning/actions';

import getLead from '@salesforce/apex/ConvertLead.getLead';
import convertLead from '@salesforce/apex/ConvertLead.convertLead';
import findAccRelatedOpp from '@salesforce/apex/ConvertLead.findAccRelatedOpp';

//this is static resource import
import staticStyleLeadConverted from "@salesforce/resourceUrl/staticStyleLeadConverted";
import { loadStyle } from 'lightning/platformResourceLoader';

export default class LeadConverted extends NavigationMixin(LightningElement) {    

    //Current ID
    @api recordId;

    @track actionAccordionSection = 'A';

    //Radio Value
    radioAccountValue = 'option1';
    radioContactValue = 'option3';
    radioOpportunityValue = 'option5';

    // ----------- Account section -----------------

    // Lead Field Value
    leadOwnerId;

    //Account Field Value
    accountNewValue; 
    accountExistingRecordValue;
    @track accountError = false;

    // ----------- Contact section -----------------

    //Contact Field Value
    contactNewSalutationValue;
    contactNewFirstNameValue;
    contactNewLastNameValue;
    contactExistingRecordValue;
    contactExistingCheckBoxValue = false;
    @track contactError = false;
    disableContactCheckbox = true;
    checkboxFalse;

    // ----------- Opportunity section -----------------

    //Opportunity Field Value
    oppUi1 = true;
    oppUi2 = false;
    oppUi3 = false;
    oppUi4 = false;
    countOpp = '';
    opportunityNewValue;
    opportunityExistingRecordValue;
    copyOpportunityExistingRecordValue;
    opportunityNewCheckBoxValue = false;
    disabledNewOpportunity = false;
    disabledExistingTopOpportunity = true;
    disabledExistingBottomOpportunity = true;
    @track opportunityError = false;


    //Opportunity Dynamic Field Value
    allOppData;

    //Error showing help text on convert button click
    helptextAndIcon = false;

    //-------------- Lightning card section ------------------- 

    //by default vlaue of record picker
    @track userRecordPickerValue;

    //apply combobox default value in the lighting card
    @track comboboxValue = 'closeConverted';

    //this is for static resource design
    connectedCallback(){
        loadStyle(this, staticStyleLeadConverted )
        .then(() => {
            console.log('Custom CSS loaded successfully----');
        })
        .catch((error) => {
            console.error('Error loading custom CSS: ', error);
        });
    }

    //use wire to get by default data for all section -------------------------------------------------------------
    @wire(getLead, { Id: "$recordId" })
    result({error, data}) {
        if('option1' != null && 'option3' != null && 'option5' != null){
            if(data) {
                console.log('Result : ' + JSON.stringify(data));
                this.userRecordPickerValue = data[0].OwnerId;

                this.leadOwnerId = data[0].OwnerId;

                this.accountNewValue = data[0].Company;

                this.contactNewSalutationValue = data[0].Salutation;
                this.contactNewFirstNameValue = data[0].FirstName;
                this.contactNewLastNameValue = data[0].LastName;

                this.opportunityNewValue = data[0].Company;
                this.copyOpportunityExistingRecordValue = data[0].Company;
            }
            else if(error){
                console.log("Find Error : " + JSON.stringify(error));
            }
        }
    }

    //Section Account start from here *****************************************************************************

    //this is for Radio oprtion1 ----------------------------------------------------------------------------------
    get options1() {
        return [
            { label: 'Create New', value: 'option1' },
        ];
    }

    //this is for Radio oprtion2 ----------------------------------------------------------------------------------
    get options2() {
        return [
            { label: 'Choose Existing', value: 'option2' },
        ];
    }

    //Radio On Account --------------------------------------------------------------------------------------------
    handleRadioGroupAccount(event) {
        this.radioAccountValue = event.target.value;
        console.log("Radio : " + this.radioAccountValue);
        console.log("Lead Id : " + this.recordId);

        if (this.radioAccountValue === 'option1') {
            this.accountError = false;
            this.disabledExistingTopOpportunity = true;
            this.disabledExistingBottomOpportunity = true;
            this.helptextAndIcon = false;

            const accountPicker = this.template.querySelector('.account-picker')
            accountPicker.clearSelection();

            this.oppUi1 = true;
            this.oppUi2 = false;
            this.oppUi3 = false;
            this.oppUi4 = false;

            getLead({
                Id: this.recordId
            })
                .then(result => {
                    const data = result;
                    this.accountNewValue = data[0].Company;

                    console.log("Showing Data : " + JSON.stringify(data));
                    console.log("Showing Name : " + JSON.stringify(data[0].Company));
                })
                .catch(error => {
                    console.log("Find Error : " + JSON.stringify(error));
                })
        }
        else if (this.radioAccountValue === 'option2') {
            this.accountNewValue = null;
            this.helptextAndIcon = false;
            console.log("Account Existing Record : " + JSON.stringify(this.accountExistingRecordValue));
        }
    }

    //Account New OnChange ----------------------------------------------------------------------------------------
    handleAccountNewChange(event) {
        this.accountNewValue = event.target.value;
    }

    //Account Exiting OnChange ------------------------------------------------------------------------------------
    handleAccountExistingChange(event) {
        this.accountExistingRecordValue = event.detail.recordId;
        console.log("Account Exiting Value : " + JSON.stringify(this.accountExistingRecordValue));

        //This is for opportunity existing matches record find and count opp record--------------------------------
        if(this.accountExistingRecordValue != null){
            if(this.radioAccountValue === 'option2'){
                this.accountError = false;
                this.disabledExistingTopOpportunity = false;
                this.disabledExistingBottomOpportunity = false;
                this.helptextAndIcon = false;
            }

            findAccRelatedOpp({
                accId: this.accountExistingRecordValue
            })
                .then(result => {
                    console.log('Result : ' + JSON.stringify(result));
                    console.log('Result length : ' + result.length);
                    this.countOpp = result.length;                    
                    this.allOppData = result;
                    
                    // this is for Opportunity dynamic Ui ---------------------------------------------------------
                    if(result.length == 0){
                        this.oppUi1 = false;
                        this.oppUi2 = true;
                        this.oppUi3 = false;
                        this.oppUi4 = false;
                    }
                    else if(result.length < 2){
                        this.oppUi1 = false;
                        this.oppUi2 = false;
                        this.oppUi3 = true;
                        this.oppUi4 = false;
                    }
                    else if(result.length >= 2){
                        this.oppUi1 = false;
                        this.oppUi2 = false;
                        this.oppUi3 = false;
                        this.oppUi4 = true;
                    }
                })
                .catch(error => {
                    console.log('Error : ' + JSON.stringify(error));
                })
        }
        else if(this.accountExistingRecordValue == null || this.accountExistingRecordValue == ''){
            this.oppUi1 = true;
            this.oppUi2 = false;
            this.oppUi3 = false;
            this.oppUi4 = false;

            if(this.radioAccountValue === 'option2'){
                this.accountError = true;
                this.disabledExistingTopOpportunity = true;
                this.disabledExistingBottomOpportunity = true;
            }
        }
    }

    //Section Contact start from here *****************************************************************************

    //this is for Radio oprtion3 ----------------------------------------------------------------------------------
    get options3() {
        return [
            { label: 'Create New', value: 'option3' },
        ];
    }

    //this is for Radio oprtion4 ----------------------------------------------------------------------------------
    get options4() {
        return [
            { label: 'Choose Existing', value: 'option4' },
        ];
    }

    //Radio On Contact --------------------------------------------------------------------------------------------
    handleRadioGroupContact(event) {
        this.radioContactValue = event.target.value;
        console.log("Radio : " + this.radioContactValue);

        // this is for custom validation error for account
        if(this.radioAccountValue === 'option2'){
            if(this.accountExistingRecordValue == null || this.accountExistingRecordValue == ''){
                this.accountError = true;
            }
            else if(this.accountExistingRecordValue != null){
                this.accountError = false;
            } 
        }

        if (this.radioContactValue === 'option3') {
            this.contactError = false;
            this.disableContactCheckbox = true;
            this.helptextAndIcon = false;

            const contactPicker = this.template.querySelector('.contact-picker')
            contactPicker.clearSelection();

            getLead({
                Id: this.recordId
            })
                .then(result => {
                    const data = result;
                    console.log("Showing Data : " + JSON.stringify(data));
                    this.contactNewSalutationValue = data[0].Salutation;
                    this.contactNewFirstNameValue = data[0].FirstName;
                    this.contactNewLastNameValue = data[0].LastName;
                })
                .catch(error => {
                    console.log("Find Error : " + JSON.stringify(error));
                })
        }
        else if (this.radioContactValue === 'option4') {
            console.log("Option 4 is working");
            this.contactNewSalutationValue = null;
            this.contactNewFirstNameValue = null;
            this.contactNewLastNameValue = null;
            this.helptextAndIcon = false;
        }
    }

    //this is making a array list for salutations -----------------------------------------------------------------
    get optionList() {
        return [
            { label: '--None--', value: '' },
            { label: 'Mr.', value: 'Mr.' },
            { label: 'Ms.', value: 'Ms.' },
            { label: 'Mrs.', value: 'Mrs.' },
            { label: 'Dr.', value: 'Dr.' },
            { label: 'Prof.', value: 'Prof.' },
            { label: 'Mx.', value: 'Mx.' },
            { label: 'Mr', value: 'Mr' },
        ];
    }

    //Contact New Salutation OnChange -----------------------------------------------------------------------------
    handleContactNewSalutationChange(event) {
        this.contactNewSalutationValue = event.target.value;
        console.log("Salutation Value : " + this.contactNewSalutationValue);
    }

    //Contact New First Name OnChange -----------------------------------------------------------------------------
    handleContactNewFirstNameChange(event) {
        this.contactNewFirstNameValue = event.target.value;
    }

    //Contact New Last Name OnChange ------------------------------------------------------------------------------
    handleContactNewLastNameChange(event) {
        this.contactNewLastNameValue = event.target.value;
    }

    //Contact Existing Record OnChange ----------------------------------------------------------------------------
    handleContactExistingChange(event) {
        this.contactExistingRecordValue = event.detail.recordId;
        console.log("Contact existing Record : " + JSON.stringify(this.contactExistingRecordValue));

        // this is for custom validation error and disable checkbox for contact
        if(this.radioContactValue === 'option4'){
            if(this.contactExistingRecordValue == null || this.contactExistingRecordValue == ''){
                this.contactError = true;
                this.disableContactCheckbox = true;
            }
            else if(this.contactExistingRecordValue != null){
                this.contactError = false;
                this.disableContactCheckbox = false;
                this.helptextAndIcon = false;
            }
        }
    }

    //Contact Existing CheckBox OnChange
    handleConExistingCheckBoxChange(event) {
        this.contactExistingCheckBoxValue = event.target.checked;
        console.log("CheckBox : " + JSON.stringify(this.contactExistingCheckBoxValue));
    }

    //Section Opportunity start from here *************************************************************************

    //this is for Radio oprtion5 ----------------------------------------------------------------------------------
    get options5() {
        return [
            { label: 'Create New', value: 'option5' },
        ];
    }

    //this is for Radio oprtion4 ----------------------------------------------------------------------------------
    get options6() {
        return [
            { label: 'Choose Existing', value: 'option6' },
        ];
    }

    //Radio On Opportunity ----------------------------------------------------------------------------------------
    handleRadioGroupOpportunity(event) {
        this.radioOpportunityValue = event.target.value;
        console.log("Radio : " + this.radioOpportunityValue);

        // this is for custom validation error for Contact
        if(this.radioContactValue === 'option4'){
            if(this.contactExistingRecordValue == null || this.contactExistingRecordValue == ''){
                this.contactError = true;
            }
            else if(this.contactExistingRecordValue != null){
                this.contactError = false;
            }
        }

        if (this.radioOpportunityValue === 'option5') {
            this.opportunityError = false;
            this.disabledExistingBottomOpportunity = true;
            this.helptextAndIcon = false;

            if(this.radioContactValue === 'option4' && this.contactExistingRecordValue == null){
                this.contactError = true;
            }

            getLead({
                Id: this.recordId
            })
                .then(result => {
                    const data = result;
                    console.log("Showing Data : " + JSON.stringify(data));
                    this.opportunityNewValue = data[0].Company;
                })
                .catch(error => {
                    console.log("Find Error : " + JSON.stringify(error));
                })
        }
        else if (this.radioOpportunityValue === 'option6') {
            console.log("Option 6 is working");
            this.opportunityNewValue = null;
            this.disabledExistingBottomOpportunity = false;
            this.helptextAndIcon = false;

            if(this.opportunityExistingRecordValue != null){
                this.opportunityError = false;
            }
            else if(this.radioContactValue === 'option4' && this.contactExistingRecordValue == null){
                this.contactError = true;
            }
        }
    }

    //Opportunity New OnChange ------------------------------------------------------------------------------------
    handleOpportunityNewChange(event) {
        this.opportunityNewValue = event.target.value;
    }

    //Opportunituy CheckBox For Dont Create OnChange --------------------------------------------------------------
    handleOppNewCheckBoxChange(event) {
        this.opportunityNewCheckBoxValue = event.target.checked;
        console.log("CheckBox : " + JSON.stringify(this.opportunityNewCheckBoxValue));

        //Disable the all input on checkbox is true
        if (this.opportunityNewCheckBoxValue === true) {
            this.disabledNewOpportunity = true;
            this.disabledExistingTopOpportunity = true;
            this.disabledExistingBottomOpportunity = true;
            this.radioOpportunityValue = false;
        }
        else if (this.opportunityNewCheckBoxValue === false) {
            this.disabledNewOpportunity = false;

            this.radioOpportunityValue = 'option5';
            this.opportunityNewValue = this.copyOpportunityExistingRecordValue;

            if(this.accountExistingRecordValue != null){
                this.disabledExistingTopOpportunity = false;
                this.disabledExistingBottomOpportunity = false;
            }
            else{
                this.disabledExistingTopOpportunity = true;
                this.disabledExistingBottomOpportunity = true;
            }
        }
    }

    // this is for dynamic Div ---------------------------------------------------------------------------------- 
    get divData(){ 
        return this.allOppData;
    }

    // this is for dynamic radio onchange -------------------------------------------------------------------------
    handleRadioGroupOppChoice(event){

        this.opportunityExistingRecordValue = event.target.value;
        console.log('Dynamic Radio Value = = = ' + this.opportunityExistingRecordValue);

        if(this.opportunityExistingRecordValue != null){
            this.opportunityError = false;
            this.helptextAndIcon = false;
        }
    }

    // Lightning card Section -------------------------------------------------------------------------------------
    get options() {
        return [
            { label: 'Closed - Convered', value: 'closeConverted' },
        ];
    }

    //This is for Conver the Account, Contact And Opportunity -----------------------------------------------------
    handleConvert() {

        // Lead
        console.log("Lead Id : " + this.recordId);

        if(this.opportunityNewCheckBoxValue == false && ('option1' != null || 'option2' != null) && ('option3' != null || 'option4' != null) && ('option5' != null || 'option6' != null)){

            if(this.accountError == true && this.radioContactValue === 'option4' && this.contactExistingRecordValue == null){
                this.contactError = true;
            }
            else if(this.opportunityNewCheckBoxValue == false && this.accountError == false && this.contactError == true && this.radioOpportunityValue === 'option6' && this.opportunityExistingRecordValue == null){
                this.opportunityError = true;
            }

            if(((this.radioAccountValue === 'option1' && this.accountNewValue == null || this.accountNewValue == '') || (this.radioAccountValue === 'option2' && this.accountExistingRecordValue == null || this.accountExistingRecordValue == '')) ||
            
            ((this.radioContactValue === 'option3' && this.contactNewLastNameValue == null || this.contactNewLastNameValue == '') || (this.radioContactValue === 'option4' && this.contactExistingRecordValue == null || this.contactExistingRecordValue == '')) ||
            
            ((this.radioOpportunityValue === 'option5' && this.opportunityNewValue == null || this.opportunityNewValue == '') || (this.radioOpportunityValue === 'option6' && this.opportunityExistingRecordValue == null || this.opportunityExistingRecordValue == ''))){

                this.helptextAndIcon = true;

                if((this.radioAccountValue === 'option1' && (this.accountNewValue == null || this.accountNewValue == '')) || (this.radioAccountValue === 'option2' && this.helptextAndIcon == true && this.accountExistingRecordValue == null)){

                    if(this.radioAccountValue === 'option2'){
                        this.accountError = true;
                    }

                    const scrollOptions = {
                        left: 0,
                        top: 0,
                        behavior: 'smooth'
                    };
                
                    const recordPicker = this.template.querySelector('.accountScroll');
                    if (recordPicker) {
                        recordPicker.scrollIntoView(scrollOptions);
                    }
                }
                else if((this.radioContactValue === 'option3' && (this.contactNewLastNameValue == null || this.contactNewLastNameValue == '')) || (this.radioContactValue === 'option4' && this.helptextAndIcon == true && this.contactExistingRecordValue == null)){

                    if(this.radioContactValue === 'option4'){
                        this.contactError = true;
                    }

                    const scrollOptions = {
                        left: 0,
                        top: 0,
                        behavior: 'smooth'
                    };
                
                    const recordPicker = this.template.querySelector('.contactScroll');
                    if (recordPicker) {
                        recordPicker.scrollIntoView(scrollOptions);
                    }
                }
                else if((this.radioOpportunityValue === 'option5' && (this.opportunityNewValue == null || this.opportunityNewValue == '')) || (this.radioOpportunityValue === 'option6' && this.helptextAndIcon == true && this.opportunityExistingRecordValue == null)){

                    if(this.radioOpportunityValue === 'option6'){
                        this.opportunityError = true; 
                    }
                    
                    const scrollOptions = {
                        left: 0,
                        top: 0,
                        behavior: 'smooth'
                    };
                
                    const recordPicker = this.template.querySelector('.opportunityScroll');
                    if (recordPicker) {
                        recordPicker.scrollIntoView(scrollOptions);
                    }
                }

            }
            else if(((this.radioAccountValue === 'option1' && this.accountNewValue != null) || (this.radioAccountValue === 'option2' && this.accountExistingRecordValue != null)) ||
            
            ((this.radioContactValue === 'option3' && this.contactNewLastNameValue != null) || (this.radioContactValue === 'option4' && this.contactExistingRecordValue != null)) ||
            
            ((this.radioOpportunityValue === 'option5' && this.opportunityNewValue != null) || (this.radioOpportunityValue === 'option6' && this.opportunityExistingRecordValue != null))){

                //Account
                console.log("Account New Data : " + this.accountNewValue);
                console.log("Account Existing Data : " + JSON.stringify(this.accountExistingRecordValue));
                //Contact
                console.log("Contact New Data Salutation : " + this.contactNewSalutationValue);
                console.log("Contact New Data First Name : " + this.contactNewFirstNameValue);
                console.log("Contact New Data Last Name : " + this.contactNewLastNameValue);
                console.log("Contact Existing Data : " + JSON.stringify(this.contactExistingRecordValue));
                console.log("Contact Existing CheckBox Data : " + JSON.stringify(this.contactExistingCheckBoxValue));
                //Opportunity
                console.log("Opportunity New Data : " + this.opportunityNewValue);
                console.log("Opportunity New Data Check box : " + this.opportunityNewCheckBoxValue);
                console.log('Opportunity Existing Data : ' + this.opportunityExistingRecordValue);

                convertLead({
                    // Lead
                    LeadId: this.recordId,
                    LeadOwnerId: this.leadOwnerId,

                    //Account
                    accNewName: this.accountNewValue,
                    accExistingId: this.accountExistingRecordValue,

                    //Contact
                    conNewSalutation: this.contactNewSalutationValue,
                    conNewFirstName: this.contactNewFirstNameValue,
                    conNewLastName: this.contactNewLastNameValue,
                    conExistingId: this.contactExistingRecordValue,
                    conExistingCheckBox: this.contactExistingCheckBoxValue,

                    //Opportunity
                    oppNewName: this.opportunityNewValue,
                    oppNewCheckBox: this.opportunityNewCheckBoxValue,
                    oppExistingId: this.opportunityExistingRecordValue,
                })
                    .then(result => {
                        console.log("Record is created: " + JSON.stringify(result));

                        const event = new ShowToastEvent({
                            title: 'Successfully Converted',
                            message: "Lead is successfully Converted",
                            variant: 'success',
                        });
                        this.dispatchEvent(event);

                        // this is for Navigate to lead object in All Open Leads
                        this[NavigationMixin.Navigate]({
                            type: "standard__webPage",
                            attributes: {
                                url: "https://chazecloud42-dev-ed.develop.lightning.force.com/lightning/o/Lead/list?filterName=00B5h00000f1NBPEA2",
                            },
                        });
                    })
                    .catch(error => {
                        console.log("Record is not created: " + JSON.stringify(error));

                        const findError = error.body.message;
                        console.log('Record not created message : ' + findError);

                        const event = new ShowToastEvent({
                            title: 'Error In Converting',
                            message: "Lead is not Converted",
                            variant: 'error',
                        });
                        this.dispatchEvent(event);
                    })
            }
        }
        else if(this.opportunityNewCheckBoxValue == true && ('option1' != null || 'option2' != null) && ('option3' != null || 'option4' != null)){

            if(this.accountError == true && this.radioContactValue === 'option4' && this.contactExistingRecordValue == null){
                this.contactError = true;
            }

            if(((this.radioAccountValue === 'option1' && this.accountNewValue == null || this.accountNewValue == '') || (this.radioAccountValue === 'option2' && this.accountExistingRecordValue == null || this.accountExistingRecordValue == '')) ||
            
            ((this.radioContactValue === 'option3' && this.contactNewLastNameValue == null || this.contactNewLastNameValue == '') || (this.radioContactValue === 'option4' && this.contactExistingRecordValue == null || this.contactExistingRecordValue == ''))){

                this.helptextAndIcon = true;

                if((this.radioAccountValue === 'option1' && (this.accountNewValue == null || this.accountNewValue == '')) || (this.radioAccountValue === 'option2' && this.helptextAndIcon == true && this.accountExistingRecordValue == null)){

                    if(this.radioAccountValue === 'option2'){
                        this.accountError = true;
                    }

                    const scrollOptions = {
                        left: 0,
                        top: 0,
                        behavior: 'smooth'
                    };
                
                    const recordPicker = this.template.querySelector('.accountScroll');
                    if (recordPicker) {
                        recordPicker.scrollIntoView(scrollOptions);
                    }
                }
                else if((this.radioContactValue === 'option3' && (this.contactNewLastNameValue == null || this.contactNewLastNameValue == '')) || (this.radioContactValue === 'option4' && this.helptextAndIcon == true && this.contactExistingRecordValue == null)){

                    if(this.radioContactValue === 'option4'){
                        this.contactError = true;
                    }

                    const scrollOptions = {
                        left: 0,
                        top: 0,
                        behavior: 'smooth'
                    };
                
                    const recordPicker = this.template.querySelector('.contactScroll');
                    if (recordPicker) {
                        recordPicker.scrollIntoView(scrollOptions);
                    }
                }
            }
            else if(((this.radioAccountValue === 'option1' && this.accountNewValue != null) || (this.radioAccountValue === 'option2' && this.accountExistingRecordValue != null)) ||
            
            ((this.radioContactValue === 'option3' && this.contactNewLastNameValue != null) || (this.radioContactValue === 'option4' && this.contactExistingRecordValue != null))){

                //Account
                console.log("Account New Data : " + this.accountNewValue);
                console.log("Account Existing Data : " + JSON.stringify(this.accountExistingRecordValue));
                //Contact
                console.log("Contact New Data Salutation : " + this.contactNewSalutationValue);
                console.log("Contact New Data First Name : " + this.contactNewFirstNameValue);
                console.log("Contact New Data Last Name : " + this.contactNewLastNameValue);
                console.log("Contact Existing Data : " + JSON.stringify(this.contactExistingRecordValue));
                console.log("Contact Existing CheckBox Data : " + JSON.stringify(this.contactExistingCheckBoxValue));

                convertLead({
                    // Lead
                    LeadId: this.recordId,
                    LeadOwnerId: this.leadOwnerId,

                    //Account
                    accNewName: this.accountNewValue,
                    accExistingId: this.accountExistingRecordValue,

                    //Contact
                    conNewSalutation: this.contactNewSalutationValue,
                    conNewFirstName: this.contactNewFirstNameValue,
                    conNewLastName: this.contactNewLastNameValue,
                    conExistingId: this.contactExistingRecordValue,
                    conExistingCheckBox: this.contactExistingCheckBoxValue,
                })
                    .then(result => {
                        console.log("Record is created: " + JSON.stringify(result));

                        const event = new ShowToastEvent({
                            title: 'Successfully Converted',
                            message: "Lead is successfully Converted",
                            variant: 'success',
                        });
                        this.dispatchEvent(event);

                        // this is for Navigate to lead object in All Open Leads
                        this[NavigationMixin.Navigate]({
                            type: "standard__webPage",
                            attributes: {
                                url: "https://chazecloud42-dev-ed.develop.lightning.force.com/lightning/o/Lead/list?filterName=00B5h00000f1NBPEA2",
                            },
                        });
                    })
                    .catch(error => {
                        console.log("Record is not created: " + JSON.stringify(error));

                        const event = new ShowToastEvent({
                            title: 'Error In Converting',
                            message: "Lead is not Converted",
                            variant: 'error',
                        });
                        this.dispatchEvent(event);
                    })
            }
        }
    }

    //This is for Cancel Button -----------------------------------------------------------------------------------
    handleCancel() {
        const closeAction = new CloseActionScreenEvent();
        this.dispatchEvent(closeAction);
    }
}