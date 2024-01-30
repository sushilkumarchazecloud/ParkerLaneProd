import { LightningElement, track, api, wire } from 'lwc';
import LwcStyle from '@salesforce/resourceUrl/LwcStyle';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import IMAGES from "@salesforce/resourceUrl/SolarLoan";
import headersLogo from '@salesforce/resourceUrl/headersLogo';
import sendAnotherDevByLwc from'@salesforce/apex/newVOIController.sendAnotherDevByLwc';
import updateVOIst from '@salesforce/apex/newVOIController.updateVOIst';
export default class NewDlSections extends LightningElement {
    @api opprec;
    @api quotrec;
    @api conrec;
    @api voist;      
    @api empone;      
    @api emptwo;
    @api voidetail;

    @track oppRecord;
    @track quoteRecord;
    @track conRecord;
    @track voiStatus;      
    @track emp1;      
    @track emp2;   
    @track voidt;   
    @api authtoken; 
    @track filesUploaded = []; 
    @track isPassport = false;
    @track idType = 'Driver\'s License';
    @track idName = 'Driver\'s License';
    @track isDeisable = true;
    @track passport;
    @track photoId;
    @track isErrorForGlitch = false;    
    formatedMobile = '';
    formatedEmail = '';
    showDailog = false;
    showSpin = false;  
    showMainSpin = true;  
    tick = IMAGES + '/img/tick.png';
    identityImg = IMAGES + '/img/IdentityDocument.png';
    anotherDev = IMAGES + '/img/ContinueAnotherDevice.png';
    dlHead = headersLogo + '/headersLogo/UploadID.png';
    docType = 'Driver\'s License';
    showForSMS = false;
    showForEmail = false;
    hidedivicediv = 'slds-size_1-of-1 slds-medium-size_3-of-12 slds-large-size_3-of-12';
        
   
    get options() {
        return [
            { label: 'Driver\'s License', value: 'Driver\'s License' },
            { label: 'Passport', value: 'Passport' }
            //{ label: 'Photo ID Card', value: 'Photo ID Card' }
        ];
    }

    get frontId(){
        return 'Front of your ' + this.idType;
    }

    get backId(){
        return 'Back of your ' + this.idType;
    }

    get passport(){
        return 'other Doc';
    }    
    

    connectedCallback() {  
        
        loadStyle(this, LwcStyle + '/lwcCss.css' )
        .then(() => {
            console.log('Custom CSS loaded successfully----');
        })
        .catch((error) => {
            console.error('Error loading custom CSS: ', error);
        });
        loadStyle(this, LwcStyle + '/esign.css' )
        .then(() => {
            console.log('Custom CSS loaded successfully----');
        })
        .catch((error) => {
            console.error('Error loading custom CSS: ', error);
        });
               
        this.oppRecord = this.opprec;
        this.conRecord = this.conrec;
        this.voiStatus = this.voist;
        this.voidt = this.voidetail;
        console.log('-=-==-=',this.voist.Current_VOI_section__c);
        if(this.voist.Current_VOI_section__c == 'Video' || this.voist.Current_VOI_section__c == 'CQP' || this.voist.Current_VOI_section__c == 'TMCU'){
            this.showMainSpin = true;
            this.dispatchEvent(new CustomEvent('callparentforvideo'));
        }        
        this.quoteRecord = this.quotrec;
        this.emp1 = this.empone; 
        if(this.opprec.Applicant_2__c != null){
            this.emp2 = this.emptwo;  
        }    
        this.formatedMobile = 'Send SMS to mobile ending in '+ this.conrec.Phone.slice(-3);   

        var email = this.conrec.Email;
        var eml = email.split('@');

        console.log('--' + eml);

        var a = eml[0].substr(0, 3) + '...';
        var b = eml[1];
        var output = a + '@' + b;
        this.formatedEmail = 'Send an email to '+output;
        console.log(output);
        this.showMainSpin = false;        
        console.log('--=-',this.authtoken);                    
        
    }
    

    isMobileDevice() {
        const userAgent = navigator.userAgent.toLowerCase();
        const mobileKeywords = ["mobile", "android", "iphone", "ipod", "blackberry", "windows phone"];
      
        for (const keyword of mobileKeywords) {
          if (userAgent.indexOf(keyword) !== -1) {
            return true; 
          }
        }
      
        return false; 
      }

    handleRadio(evt){
        console.log('radoi----',evt.target.value);
        this.idName = evt.target.value;
        if(evt.target.value == 'Passport'){
            const front = this.template.querySelector('[data-id="front-dl-Sec"]');
            const back = this.template.querySelector('[data-id="back-dl-sec"]');
            const pass = this.template.querySelector('[data-id="passport"]');
            //const phid = this.template.querySelector('[data-id="photo-id"]');
            front.style.display = 'none';
            back.style.display = 'none';
           // phid.style.display = 'none';
            pass.style.display = 'block';
            this.passport = 'Passport';
            this.isPassport = true;
            this.idType = '';
            this.hidedivicediv = 'slds-size_1-of-1 slds-medium-size_3-of-12 slds-large-size_3-of-12 slds-hide';            
        }
        /*if(evt.target.value == 'Photo ID Card'){
            const front = this.template.querySelector('[data-id="front-dl-Sec"]');
            const back = this.template.querySelector('[data-id="back-dl-sec"]');
            const pass = this.template.querySelector('[data-id="passport"]');
            const phid = this.template.querySelector('[data-id="photo-id"]');
            front.style.display = 'none';
            back.style.display = 'none';
            phid.style.display = 'block';
            pass.style.display = 'none';
            this.photoId = 'Photo ID Card';
            this.isPassport = true;
            this.idType = '';
            this.hidedivicediv = 'slds-size_1-of-1 slds-medium-size_3-of-12 slds-large-size_3-of-12 slds-hide';
        }*/
        if(evt.target.value == 'Driver\'s License'){
            const front = this.template.querySelector('[data-id="front-dl-Sec"]');
            const back = this.template.querySelector('[data-id="back-dl-sec"]');
            const pass = this.template.querySelector('[data-id="passport"]');
           // const phid = this.template.querySelector('[data-id="photo-id"]');
            front.style.display = 'block';
            back.style.display = 'block';
            //phid.style.display = 'none';
            pass.style.display = 'none';
            this.isPassport = false;
            this.idType = evt.target.value;
            this.hidedivicediv = 'slds-size_1-of-1 slds-medium-size_3-of-12 slds-large-size_3-of-12';
        }
        //this.filesUploaded = []; 
        //this.isDeisable = true;      
    }
    
    showBox(event){  
        const buttonElement = this.template.querySelector('.buttonOfAnother button');
        if(this.showDailog == true){           
            this.showDailog = false;
            buttonElement.style.border = '1px solid #afc2e3';
        }else{
            this.showDailog = true;
            buttonElement.style.border = '1px solid #0176d3';
        }
    }

    hidelistbx(event){
        const buttonElement = this.template.querySelector('.buttonOfAnother button');
        if(this.showDailog == true){           
            this.showDailog = false;
            buttonElement.style.border = '1px solid #afc2e3';
        }
        
    }
    handleListItemClick(event) {        
        this.checkValforselect(event);
    }   

    checkValforselect(event){ 
        this.showDailog = false;
        const buttonElement = this.template.querySelector('.buttonOfAnother button');
        buttonElement.style.border = '1px solid #afc2e3';              
        this.showSpin = true;
        this.showForEmail = false;
        this.showForSMS = false;                    
        const element = event.currentTarget.dataset.value;               
        console.log('--=-',element);
        this.sendDataToApex(element);
    }

    sendDataToApex(type){
        console.log('type--',type);
        sendAnotherDevByLwc({ deviceType: type, conId :  this.conRecord.Id})
            .then(result => {                
                this.showSpin = false;
                console.log(result);
                if(type == 'sms'){
                    this.showForSMS = true;                    
                }else{
                    this.showForEmail = true;                    
                }                
            })
            .catch(error => {
                // Handle any errors that occur during the Apex call
                console.error(error);
                this.showSpin = false;
            });
    } 

    completeDlSec(){
        this.showMainSpin = true;
        const updatedVOIStatus = { ...this.voiStatus };
        console.log('in button'+updatedVOIStatus.Current_VOI_section__c);
        updatedVOIStatus.Current_VOI_section__c = 'Video';
            updateVOIst({ vs :updatedVOIStatus })
            .then(reslt => {
                console.log('---reslt---',reslt);
                this.dispatchEvent(new CustomEvent('callparentforvideo'));
            })
            .catch(err => {
                console.log('error---',err);
                this.dispatchEvent(new CustomEvent('callparentforvideo'));
            });        
    }

    @api
    stopSpintFromVideo(){
        console.log('loaded');
        this.showMainSpin = false;
    }

    checkfileuploaded(event){ 
        console.log('event detail'+event.detail.type);
        var filetyp = event.detail.type;
        this.filesUploaded.push(filetyp);
        var remIndx = event.detail.removetyp;
        console.log('---remIndx--'+remIndx);
        
        var filesName = this.filesUploaded;
        if(remIndx != ''){
            for(var i=0; i<=filesName.length; i++){                
                if(filesName.includes(remIndx)){
                    var indx = this.filesUploaded.indexOf(remIndx);
                    console.log('indx--'+indx);
                    filesName.splice(indx, 1);
                }                
            }
        }
        console.log('op---'+filesName);
        this.filesUploaded = filesName;
        console.log('--'+this.filesUploaded);
        var filedt = this.filesUploaded;
        let flag = false;
        if(filedt.includes('Passport')){ // || filedt.includes('Photo ID Card')
            console.log('if');
            this.isDeisable = false;
            const buttonElement = this.template.querySelector('[data-id="submtBtn"]');
            buttonElement.style.background = '#45c65a';
            buttonElement.style.border = 'none';
            flag = true;
        }else{
            console.log('else');
            this.isDeisable = true;
        }

        if(filedt.includes('Front of your Driver\'s License') && filedt.includes('Back of your Driver\'s License')){
            console.log('else if');
            this.isDeisable = false;
            console.log('condition true');
            const buttonElement = this.template.querySelector('[data-id="submtBtn"]');
            buttonElement.style.background = '#45c65a';
            buttonElement.style.border = 'none';
        }
        else{
            if(flag == false){ 
                console.log('else');
                this.isDeisable = true;
            }
        }                              
    }

    callforError(event){
        if(event.detail.istr == true){
            this.isErrorForGlitch = true;
        }
        else{
            this.isErrorForGlitch = false;
        }
        
    }


}