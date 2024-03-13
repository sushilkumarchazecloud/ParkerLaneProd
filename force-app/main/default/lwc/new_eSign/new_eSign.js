import { LightningElement, wire, track, api  } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import headersLogo from '@salesforce/resourceUrl/headersLogo';
import IMAGES from "@salesforce/resourceUrl/SolarLoan";
import dataWrapmethod from'@salesforce/apex/newVOIController.dataWrapmethod';
import updateVOIst from '@salesforce/apex/newVOIController.updateVOIst';
import getTerms from '@salesforce/apex/newVOIController.getTerms';

export default class New_eSign extends LightningElement {
    @api oppId;
    @api conId;
    @api code;
    @track oppRecord;
    @track quoteRecord;
    @track conRecord;      
    @track emp1;      
    @track emp2;      
    @track voiStatus; 
    @track error;
    @api callAfter;
    @api callonClose;
    @api check;
    @api checkToglefun;
    @api checkForValidation;
    @track isTMCU = false;
    @track isBHCCU = false;
    @track isTMCUorbhcu =false;
    @track terms;  
    isTMCU;
    updateforTMCU;
    checkTogle;
    showSpinEsign = true;
    isAgree;    
    tick = IMAGES + '/img/tick.png';
    signIcn =  IMAGES + '/img/eSign.png';
    signHead = headersLogo + '/headersLogo/eSign.png';
       
    @wire(getTerms)
    wiredterms({ error, data }) {
        if (data) {
            console.log('data--==>>'+JSON.stringify(data));
            this.terms = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
    }


    connectedCallback() {
        this.isAgree = false;
            console.log('00--'+this.oppId);
            dataWrapmethod({oppId : this.oppId, conId : this.conId})
                .then(result => {
                    console.log('data==',result);
                    this.oppRecord = result.opp;
                    this.conRecord = result.con;
                    this.voiStatus = result.voiSt;

                    if(result.opp.Lender__c == 'Transport Mutual Credit Union'){
                        this.isTMCU = true;
                         this.isTMCUorbhcu = true;
                    }
                    else if(result.opp.Lender__c == 'Broken Hill Community Credit Union'){
                        this.isBHCCU = true;
                         this.isTMCUorbhcu = true;
                    }
                    if(result.voiSt.Current_VOI_section__c == 'TMCU' && result.opp.Lender__c == 'Broken Hill Community Credit Union'){
                        this.updateforTMCU = true;
                         this.isTMCUorbhcu = true;
                        this.isBHCCU = true;
                    }   
                    else if(result.voiSt.Current_VOI_section__c == 'TMCU' && result.opp.Lender__c == 'Transport Mutual Credit Union'){
                        this.updateforTMCU = true;
                         this.isTMCUorbhcu = true;
                        this.isTMCU = true;
                    }                     
                    this.quoteRecord = result.Qt;
                    this.emp1 = result.emp1;
                    console.log('--=',result.opp.Applicant_2__c);
                    if(result.opp.Applicant_2__c != null){
                        this.emp2 = result.emp2;  
                    }
                    if(result.opp.Lender__c == 'Transport Mutual Credit Union'){
                        this.isTMCU = true;                
                    }else{
                        this.isTMCU = false;
                    }       
                    this.showSpinEsign = false;                      
                })
                .catch(error => {
                    this.error = error;
                    this.showSpinEsign = false;
                });

    }

    updateAgree(event){
        if(event.target.checked){
            this.isAgree = true;
        }else{
            this.isAgree = false;
        }
        this.checkToglefun(this.isAgree);
    }

    updateForSign(event){
        if(event.target.checked){
            console.log('ppppp-=-=',this.isAgree);
            this.callAfter(this.isAgree);
        }
        else{   
            this.callonClose();
        }        
    }
    
    @api
    updateFields(){
        if(this.isTMCU){
            const childComponent = this.template.querySelector('c-signed-t-m-c-u');
            childComponent.updateContact();
        }
        if(this.isBHCCU){
            const childComponent = this.template.querySelector('c-signed-b-h-c-c-u');
            childComponent.updateContact();
        }        
    }

    @api
    checkValidate(){
        const childComponent = this.template.querySelector('c-signed-t-m-c-u');
        if(childComponent){
            childComponent.checkFieldsValidation(); 
            console.log('opopo------',childComponent.retrnval);            
            var returnOfValidtion = childComponent.retrnval;
            this.checkForValidation(returnOfValidtion);

        }
    }

    @api
    checkValidateBHCC(){
        const childComponent = this.template.querySelector('c-signed-b-h-c-c-u');
        if(childComponent){
            childComponent.checkFieldsValidationBHCCU(); 
            console.log('opopo---cvx---',childComponent.retrnval);            
            var returnOfValidtion = childComponent.retrnval;
            this.checkForValidation(returnOfValidtion);

        }
    }

    @api
    updateForOtherSign(){
        this.showSpinEsign = true;        
        const updatedVOIStatus = { ...this.voiStatus };
        updatedVOIStatus.Current_VOI_section__c = 'TMCU';
            updateVOIst({ vs :updatedVOIStatus })
            .then(reslt => {
                alert('---reslt---',reslt);
                this.showSpinEsign = false;
                if(this.oppRecord.Lender__c == 'Broken Hill Community Credit Union'){
                    this.isBHCCU = true;                    
                }
                if(this.oppRecord.Lender__c == 'Transport Mutual Credit Union'){
                    this.isTMCU = true;                                                    
                }
                this.updateforTMCU = true;
                this.checkTogle = false;    
            })
            .catch(err => {
                console.log('error---',err);
                this.showSpinEsign = false;
                this.updateforTMCU = true;
                this.checkTogle = false;    
            });                           
                
    }   

}