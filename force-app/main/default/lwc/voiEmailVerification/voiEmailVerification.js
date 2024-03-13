import { LightningElement,  wire, track, api } from 'lwc';
import emailForOtp from'@salesforce/apex/newVOIController.emailForOtp';
import updateForEmailVerify from'@salesforce/apex/newVOIController.updateForEmailVerify';
import SolarLoan from '@salesforce/resourceUrl/SolarLoan';
import headersLogo from '@salesforce/resourceUrl/headersLogo';
import dataWrapmethod from '@salesforce/apex/newVOIController.dataWrapmethod';
import sendEmailAndSMSForCode from '@salesforce/apex/newVOIController.sendEmailAndSMSForCode';
import LwcStyle from '@salesforce/resourceUrl/LwcStyle';
import updateVOIst from '@salesforce/apex/newVOIController.updateVOIst';
import sendCustomEmail from '@salesforce/apex/newVOIController.sendCustomEmail';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class VoiEmailVerification extends LightningElement {
    @api oppId;
    @api conId;
    @api code;
    @track oppRecord;
    @track quoteRecord;
    @track conRecord;      
    @track emp1;      
    @track emp2;
    @track VOIdetail;
    @track voiStatus;
    @track isCheck;
    @api authToken;
    @api callvfPageforVideo;
    @track mailSent;
    @track flag;
    @track isEmailVerified = false;
    @track showErrormsg = false;
    @track codeSentSpinner = false;
    @track showSpinMain = true;
    @track emailSentOn = false;
    @track emailSentsuccess = false;
    @track incorrectOtp = 'slds-size_1-of-1 slds-medium-size_6-of-12 slds-large-size_6-of-12 slds-hide';
    greenTick = SolarLoan + '/img/tick.png';
    emailImg = SolarLoan + '/img/Verifyemail.png';
    emailHead = headersLogo + '/headersLogo/VerifyEmail.png';
    correctOtp = '';
    otpOne;
    otpTwo;
    otpThree;
    otpFour;
    applicantEmail = '';
    

    connectedCallback() {
        loadStyle(this, LwcStyle + '/emailVerificationCSS.css' )
        .then(() => {
            console.log('Custom CSS loaded successfully----');
        })
        .catch((error) => {
            console.error('Error loading custom CSS: ', error);
        });

    console.log('--' +this.oppId);
    console.log('--' +this.conId);

    dataWrapmethod({oppId : this.oppId, conId : this.conId})
        .then(result => {
            console.log('data=inin=',result);
            this.oppRecord = result.opp;
            this.conRecord = result.con;
            this.voiStatus = result.voiSt;
            this.VOIdetail = result.voiDt;            
            this.quoteRecord = result.Qt;
            this.emp1 = result.emp1; 
            if(result.opp.Applicant_2__c != null){
                this.emp2 = result.emp2;  
            }
            if(result.con.is_Email_verified_for_VOI__c){
                this.isEmailVerified = true;
            }
            this.correctOtp = result.con.voi_Email_Verification_Code__c;
           // alert(result.con.voi_Email_Verification_Code__c);            
            this.applicantEmail = result.con.Email;  
            this.showSpinMain = false;   
            sendEmailAndSMSForCode({con : result.con})
            .then(result => {
                if(result != null){
                    this.correctOtp = result.voi_Email_Verification_Code__c;
                    alert(result.voi_Email_Verification_Code__c);
                }                
            })
            .catch(error => {
                this.error = error;
                this.showSpinMain = false;
            });                    
        })
        .catch(error => {
            console.log('--0-error-->'+JSON.stringify(error));
            this.error = error;
            this.showSpinMain = false;
        });
    }

    
    moveNext(event){
    var name = event.target.value;    
    if(name != null || name != ''){
        this.otpOne = name;
        var temp = this.template.querySelector('[data-id="two"]');
        temp.focus();
    }
    if(name == null || name == ''){
        var temp = this.template.querySelector('[data-id="one"]');
        temp.focus();
    }
    this.incorrectOtp = 'slds-size_1-of-1 slds-medium-size_6-of-12 slds-large-size_6-of-12 slds-hide';
    }
    moveNext2(event){
    var name = event.target.value;
    if(name != null || name != ''){
        this.otpTwo = name;
        var temp = this.template.querySelector('[data-id="three"]');
        temp.focus();
    }
    if(name == null || name == ''){
        var temp = this.template.querySelector('[data-id="one"]');
        temp.focus();
    }
    this.incorrectOtp = 'slds-size_1-of-1 slds-medium-size_6-of-12 slds-large-size_6-of-12 slds-hide';
    }
    moveNext3(event){
    var name = event.target.value;
    if(name != null || name != ''){
        this.otpThree = name;
        var temp = this.template.querySelector('[data-id="four"]');
        temp.focus();
    }
    if(name == null || name == ''){
        var temp = this.template.querySelector('[data-id="two"]');
        temp.focus();
    }
    this.incorrectOtp = 'slds-size_1-of-1 slds-medium-size_6-of-12 slds-large-size_6-of-12 slds-hide';
    }
    moveNext4(event){
    var name = event.target.value;
    if(name != null || name != ''){
        this.otpFour = name;
        var temp = this.template.querySelector('[data-id="one"]');
        //temp.focus();        
        if((this.otpOne != null || this.otpOne != '') && (this.otpTwo != null || this.otpTwo != '') && 
        (this.otpThree != null || this.otpThree != '') && (this.otpFour != null || this.otpFour != '')
        ){      
            this.showSpinMain = true;      
            var otp = this.otpOne + this.otpTwo + this.otpThree + this.otpFour;
            console.log('---',otp);

            if(otp == this.correctOtp){                
                // alert('correct Otp');
                updateForEmailVerify({conId : this.conId})
                .then(result => {
                    console.log('data==',result);
                    if(result == 'success'){
                        this.isEmailVerified = true;   
                        const updatedVOIStatus = { ...this.voiStatus };  
                            if(updatedVOIStatus.VOI_Type_For__c == 'FULL' || updatedVOIStatus.VOI_Type_For__c == 'VOI'){
                                updatedVOIStatus.Current_VOI_section__c = 'Id Upload';
                            }else{
                                updatedVOIStatus.Current_VOI_section__c = 'CQP';
                            }                                               

                            updateVOIst({ vs :updatedVOIStatus })
                            .then(reslt => {
                                console.log('---reslt---',reslt);
                                this.showSpinMain = false; 
                            })
                            .catch(err => {
                                console.log('error---',err);
                                this.showSpinMain = false; 
                            });    
                    }                  
                })
                .catch(error => {
                    console.log('error---',error);
                    this.showSpinMain = false;
                });                
            }else{
                console.log('incorrect OTP'); 
                this.showSpinMain = false;
                this.incorrectOtp = 'slds-size_1-of-1 slds-medium-size_6-of-12 slds-large-size_6-of-12';
            }


        }else{
            console.log('incorrect OTP');
            this.showSpinMain = false;
        }

    }
    if(name == null || name == ''){
        var temp = this.template.querySelector('[data-id="three"]');
        temp.focus();
        this.incorrectOtp = 'slds-size_1-of-1 slds-medium-size_6-of-12 slds-large-size_6-of-12 slds-hide';
    }
    }
    sendVerification(){
    this.codeSentSpinner = true;
    this.mailSent = false;
    emailForOtp({conId : this.conId})
        .then(result => {
            if(result != null){
                this.codeSentSpinner = false;
                this.correctOtp = result.voi_Email_Verification_Code__c;
                this.mailSent = true;                
                alert('OTP-'+result.voi_Email_Verification_Code__c);
            }            
            else{
                this.showErrormsg = true;
                this.codeSentSpinner = false;
            }
        })
        .catch(error => {
            console.log('error---',error);
            this.showErrormsg = true;
            this.codeSentSpinner = false;
        });
    }


    alternateEmail(){
        this.isCheck = true;
    }

    handleEmailChange() {
        const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        let email = this.template.querySelector('[data-id="txtEmailAddress"]');
        let emailVal = email.value;
        if (emailVal.match(emailRegex)) {
            email.setCustomValidity("");
            this.flag = true;
            
        } else {
            this.flag = false;
            email.setCustomValidity("Please enter valid email");
        }
        email.reportValidity();
    }


    callforvideo(event){
        this.callvfPageforVideo();  
        
        const childComponent = this.template.querySelector('c-new-dl-sections');
        if(childComponent){
            childComponent.stopSpintFromVideo();
        }    
    }

    sendcodeonEmail(){    
        this.emailSentsuccess = false;            
        this.emailSentOn = true;
        let email = this.template.querySelector('[data-id="txtEmailAddress"]');
        let emailVal = email.value;       
        sendCustomEmail({email : emailVal, conId: this.conId})
        .then(result => {
            if(result != null){
                this.emailSentOn = false;
                this.emailSentsuccess = true;
                this.conRecord = result;                
                this.correctOtp = result.voi_Email_Verification_Code__c;           
                alert('otp is: '+this.correctOtp);
            }
            else{
                alert('please enter correct email.');
                this.emailSentOn = false;
            }

        })
        .catch(error => {
            this.emailSentOn = false;
        });
    }

    checkForEnter(event){
        if(event.which == 13 ){
            if(this.flag)
                this.sendcodeonEmail();
            else
                this.handleEmailChange();
        }
    }
}