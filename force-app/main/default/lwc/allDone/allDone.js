import { LightningElement, wire, track, api } from 'lwc';
import SolarLoan from '@salesforce/resourceUrl/SolarLoan';
import headersLogo from '@salesforce/resourceUrl/headersLogo';
import ReferralPortal from '@salesforce/resourceUrl/ReferralPortal';
import getOppDetails from '@salesforce/apex/ApplicationFormController.getOppDetails';
import LwcStyle from '@salesforce/resourceUrl/LwcStyle';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class AllDone extends LightningElement {
    @track signHead = headersLogo + '/headersLogo/Alldone.png';
    @track stars = ReferralPortal + '/ReferralPortal/4.9Stars.png';
    @track warning = SolarLoan + '/img/ReferrerTODO.png';
    @track checkgreen = ReferralPortal + '/ReferralPortal/newTick.png';
    @track greenAlert = ReferralPortal + '/ReferralPortal/newAlert.png';
    @api recordId;
    @track oppRec;
    @track csName;
    @track purpose;
    @track review;
    @track userPic;
    @track dynamicText;
    @track pending = false;
    @track applicantName;

    connectedCallback(){
        loadStyle(this, LwcStyle + '/allDone.css' )
        .then(() => {
            console.log('Custom CSS loaded successfully----');
        })
        .catch((error) => {
            console.error('Error loading custom CSS: ', error);
        });


        getOppDetails({recordId : this.recordId})
        .then(result =>{
            this.oppRec = result.opp;
            this.csName = result.opp.Customer_Support_Person_Name__c;
            this.purpose = result.opp.Purpose__c;
            this.review = result.opp.Customer_Support_Person__r.Best_Customer_Review__c;
            this.userPic = result.opp.Customer_Support_Person__r.MediumPhotoUrl;
            console.log('>>>>>>>>>>>>>>>>'+result.opp.Customer_Support_Person__r.MediumPhotoUrl);
            
            if(result.opp.Applicant_2__c != null){
                if(result.app1Voi.VOI_Status__c == 'Sent' || result.app1Voi.VOI_Status__c == 'Delivered'){                    
                    if(result.app1Voi.VOI_Type_For__c == 'FULL' || result.app1Voi.VOI_Type_For__c == 'VOI'){
                        this.pending = true;
                        this.dynamicText = 'verify their details';
                        this.applicantName = result.opp.Applicant_1__r.FirstName;
                    }
                    else if(result.app1Voi.VOI_Type_For__c == 'E-SIGN'){
                        this.pending = true;
                        this.dynamicText = 'eSign their docs';
                        this.applicantName = result.opp.Applicant_1__r.FirstName;
                    }
                }
                if(result.app2Voi.VOI_Status__c == 'Sent' || result.app2Voi.VOI_Status__c == 'Delivered'){                    
                    if(result.app2Voi.VOI_Type_For__c == 'FULL' || result.app2Voi.VOI_Type_For__c == 'VOI'){
                        this.pending = true;
                        this.dynamicText = 'verify their details';
                        this.applicantName = result.opp.Applicant_2__r.FirstName;
                    }
                    else if(result.app2Voi.VOI_Type_For__c == 'E-SIGN'){
                        this.pending = true;
                        this.dynamicText = 'eSign their docs';
                        this.applicantName = result.opp.Applicant_2__r.FirstName;
                    }
                }
            }
        })
        .catch(eror =>{

        })        
    }

    closePage(event){
        window.location.href = 'https://chazecloud.com/';
    }

}