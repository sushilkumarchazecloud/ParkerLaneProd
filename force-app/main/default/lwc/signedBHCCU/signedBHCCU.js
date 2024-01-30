import { LightningElement,api,track } from 'lwc';
import LwcStyle from '@salesforce/resourceUrl/LwcStyle';
import { loadStyle } from 'lightning/platformResourceLoader';
import baseUrlLabel from '@salesforce/label/c.baseUrl';
import updateContactForBhccu from'@salesforce/apex/newVOIController.updateContactForBhccu';
import insertPDFAndSendEmail from'@salesforce/apex/newVOIController.insertPDFAndSendEmail';

export default class SignedBHCCU extends LightningElement {

    @api quoterecord;
    @api opprecord;
    @track error;
    @api condata;      
    @api emp1;      
    @api emp2; 
    @track isApp2 = false;   
    country;
    numberOfPerson;
    @api retrnval = [];
    @track showSpin = false;
    @track allValuesofCitizen = [];
    @track allValuesofTax = [];
    @track addressapp1 = '';
    @track addressapp2 = '';
    get options(){
        return [
            {label: 'Australia', value: 'Australia'},
            {label: 'New Zealand', value: 'New Zealand'},
            {label: 'United Kingdom', value: 'United Kingdom'},
            {label: 'United States of America', value: 'United States of America'},
            {label: '--------------------------', value: '--------------------------'},
            {label: 'Afghanistan', value: 'Afghanistan'},
            {label: 'Albania', value: 'Albania'},
            {label: 'Algeria', value: 'Algeria'},
            {label: 'Andorra', value: 'Andorra'},
            {label: 'Angola', value: 'Angola'},
            {label: 'Antigua and Barbuda', value: 'Antigua and Barbuda'},
            {label: 'Argentina', value: 'Argentina'},
            {label: 'Armenia', value: 'Armenia'},
            {label: 'Austria', value: 'Austria'},
            {label: 'Azerbaijan', value: 'Azerbaijan'},
            {label: 'Bahamas', value: 'Bahamas'},
            {label: 'Bahrain', value: 'Bahrain'},
            {label: 'Bangladesh', value: 'Bangladesh'},
            {label: 'Barbados', value: 'Barbados'},
            {label: 'Belarus', value: 'Belarus'},
            {label: 'Belgium', value: 'Belgium'},
            {label: 'Belize', value: 'Belize'},
            {label: 'Benin', value: 'Benin'},
            {label: 'Bhutan', value: 'Bhutan'},
            {label: 'Bolivia', value: 'Bolivia'},
            {label: 'Bosnia and Herzegovina', value: 'Bosnia and Herzegovina'},
            {label: 'Botswana', value: 'Botswana'},
            {label: 'Brazil', value: 'Brazil'},
            {label: 'Brunei', value: 'Brunei'},
            {label: 'Bulgaria', value: 'Bulgaria'},
            {label: 'Burkina Faso', value: 'Burkina Faso'},
            {label: 'Burundi', value: 'Burundi'},
            {label: "Côte d'Ivoire", value: "Côte d'Ivoire"},
            {label: 'Cabo Verde', value: 'Cabo Verde'},
            {label: 'Cambodia', value: 'Cambodia'},
            {label: 'Cameroon', value: 'Cameroon'},
            {label: 'Canada', value: 'Canada'},
            {label: 'Central African Republic', value: 'Central African Republic'},
            {label: 'Chad', value: 'Chad'},
            {label: 'Chile', value: 'Chile'},
            {label: 'China', value: 'China'},
            {label: 'Colombia', value: 'Colombia'},
            {label: 'Comoros', value: 'Comoros'},
            {label: 'Congo (Congo-Brazzaville)', value: 'Congo (Congo-Brazzaville)'},
            {label: 'Costa Rica', value: 'Costa Rica'},
            {label: 'Croatia', value: 'Croatia'},
            {label: 'Cuba', value: 'Cuba'},
            {label: 'Cyprus', value: 'Cyprus'},
            {label: 'Czechia (Czech Republic)', value: 'Czechia (Czech Republic)'},
            {label: 'Democratic Republic of the Congo', value: 'Democratic Republic of the Congo'},
            {label: 'Denmark', value: 'Denmark'},
            {label: 'Djibouti', value: 'Djibouti'},
            {label: 'Dominica', value: 'Dominica'},
            {label: 'Dominican Republic', value: 'Dominican Republic'},
            {label: 'Ecuador', value: 'Ecuador'},
            {label: 'Egypt', value: 'Egypt'},
            {label: 'El Salvador', value: 'El Salvador'},
            {label: 'Equatorial Guinea', value: 'Equatorial Guinea'},
            {label: 'Eritrea', value: 'Eritrea'},
            {label: 'Estonia', value: 'Estonia'},
            {label: 'Eswatini (fmr. Swaziland)', value: 'Eswatini (fmr. Swaziland)'},
            {label: 'Ethiopia', value: 'Ethiopia'},
            {label: 'Fiji', value: 'Fiji'},
            {label: 'Finland', value: 'Finland'},
            {label: 'France', value: 'France'},
            {label: 'Gabon', value: 'Gabon'},
            {label: 'Gambia', value: 'Gambia'},
            {label: 'Georgia', value: 'Georgia'},
            {label: 'Germany', value: 'Germany'},
            {label: 'Ghana', value: 'Ghana'},
            {label: 'Greece', value: 'Greece'},
            {label: 'Grenada', value: 'Grenada'},
            {label: 'Guatemala', value: 'Guatemala'},
            {label: 'Guinea', value: 'Guinea'},
            {label: 'Guinea-Bissau', value: 'Guinea-Bissau'},
            {label: 'Guyana', value: 'Guyana'},
            {label: 'Haiti', value: 'Haiti'},
            {label: 'Holy See', value: 'Holy See'},
            {label: 'Honduras', value: 'Honduras'},
            {label: 'Hungary', value: 'Hungary'},
            {label: 'Iceland', value: 'Iceland'},
            {label: 'India', value: 'India'},
            {label: 'Indonesia', value: 'Indonesia'},
            {label: 'Iran', value: 'Iran'},
            {label: 'Iraq', value: 'Iraq'},
            {label: 'Ireland', value: 'Ireland'},
            {label: 'Israel', value: 'Israel'},
            {label: 'Italy', value: 'Italy'},
            {label: 'Jamaica', value: 'Jamaica'},
            {label: 'Japan', value: 'Japan'},
            {label: 'Jordan', value: 'Jordan'},
            {label: 'Kazakhstan', value: 'Kazakhstan'},
            {label: 'Kenya', value: 'Kenya'},
            {label: 'Kiribati', value: 'Kiribati'},
            {label: 'Kuwait', value: 'Kuwait'},
            {label: 'Kyrgyzstan', value: 'Kyrgyzstan'},
            {label: 'Laos', value: 'Laos'},
            {label: 'Latvia', value: 'Latvia'},
            {label: 'Lebanon', value: 'Lebanon'},
            {label: 'Lesotho', value: 'Lesotho'},
            {label: 'Liberia', value: 'Liberia'},
            {label: 'Libya', value: 'Libya'},
            {label: 'Liechtenstein', value: 'Liechtenstein'},
            {label: 'Lithuania', value: 'Lithuania'},
            {label: 'Luxembourg', value: 'Luxembourg'},
            {label: 'Madagascar', value: 'Madagascar'},
            {label: 'Malawi', value: 'Malawi'},
            {label: 'Malaysia', value: 'Malaysia'},
            {label: 'Maldives', value: 'Maldives'},
            {label: 'Mali', value: 'Mali'},
            {label: 'Malta', value: 'Malta'},
            {label: 'Marshall Islands', value: 'Marshall Islands'},
            {label: 'Mauritania', value: 'Mauritania'},
            {label: 'Mauritius', value: 'Mauritius'},
            {label: 'Mexico', value: 'Mexico'},
            {label: 'Micronesia', value: 'Micronesia'},
            {label: 'Moldova', value: 'Moldova'},
            {label: 'Monaco', value: 'Monaco'},
            {label: 'Mongolia', value: 'Mongolia'},
            {label: 'Montenegro', value: 'Montenegro'},
            {label: 'Morocco', value: 'Morocco'},
            {label: 'Mozambique', value: 'Mozambique'},
            {label: 'Myanmar (formerly Burma)', value: 'Myanmar (formerly Burma)'},
            {label: 'Namibia', value: 'Namibia'},
            {label: 'Nauru', value: 'Nauru'},
            {label: 'Nepal', value: 'Nepal'},
            {label: 'Netherlands', value: 'Netherlands'},
            {label: 'Nicaragua', value: 'Nicaragua'},
            {label: 'Niger', value: 'Niger'},
            {label: 'Nigeria', value: 'Nigeria'},
            {label: 'North Korea', value: 'North Korea'},
            {label: 'North Macedonia', value: 'North Macedonia'},
            {label: 'Norway', value: 'Norway'},
            {label: 'Oman', value: 'Oman'},
            {label: 'Pakistan', value: 'Pakistan'},
            {label: 'Palau', value: 'Palau'},
            {label: 'Palestine State', value: 'Palestine State'},
            {label: 'Panama', value: 'Panama'},
            {label: 'Papua New Guinea', value: 'Papua New Guinea'},
            {label: 'Paraguay', value: 'Paraguay'},
            {label: 'Peru', value: 'Peru'},
            {label: 'Philippines', value: 'Philippines'},
            {label: 'Poland', value: 'Poland'},
            {label: 'Portugal', value: 'Portugal'},
            {label: 'Qatar', value: 'Qatar'},
            {label: 'Romania', value: 'Romania'},
            {label: 'Russia', value: 'Russia'},
            {label: 'Rwanda', value: 'Rwanda'},
            {label: 'Saint Kitts and Nevis', value: 'Saint Kitts and Nevis'},
            {label: 'Saint Lucia', value: 'Saint Lucia'},
            {label: 'Saint Vincent and the Grenadines', value: 'Saint Vincent and the Grenadines'},
            {label: 'Samoa', value: 'Samoa'},
            {label: 'San Marino', value: 'San Marino'},
            {label: 'Sao Tome and Principe', value: 'Sao Tome and Principe'},
            {label: 'Saudi Arabia', value: 'Saudi Arabia'},
            {label: 'Senegal', value: 'Senegal'},
            {label: 'Serbia', value: 'Serbia'},
            {label: 'Seychelles', value: 'Seychelles'},
            {label: 'Sierra Leone', value: 'Sierra Leone'},
            {label: 'Singapore', value: 'Singapore'},
            {label: 'Slovakia', value: 'Slovakia'},
            {label: 'Slovenia', value: 'Slovenia'},
            {label: 'Solomon Islands', value: 'Solomon Islands'},
            {label: 'Somalia', value: 'Somalia'},
            {label: 'South Africa', value: 'South Africa'},
            {label: 'South Korea', value: 'South Korea'},
            {label: 'South Sudan', value: 'South Sudan'},
            {label: 'Spain', value: 'Spain'},
            {label: 'Sri Lanka', value: 'Sri Lanka'},
            {label: 'Sudan', value: 'Sudan'},
            {label: 'Suriname', value: 'Suriname'},
            {label: 'Sweden', value: 'Sweden'},
            {label: 'Switzerland', value: 'Switzerland'},
            {label: 'Syria', value: 'Syria'},
            {label: 'Tajikistan', value: 'Tajikistan'},
            {label: 'Tanzania', value: 'Tanzania'},
            {label: 'Thailand', value: 'Thailand'},
            {label: 'Timor-Leste', value: 'Timor-Leste'},
            {label: 'Togo', value: 'Togo'},
            {label: 'Tonga', value: 'Tonga'},
            {label: 'Trinidad and Tobago', value: 'Trinidad and Tobago'},
            {label: 'Tunisia', value: 'Tunisia'},
            {label: 'Turkey', value: 'Turkey'},
            {label: 'Turkmenistan', value: 'Turkmenistan'},
            {label: 'Tuvalu', value: 'Tuvalu'},
            {label: 'Uganda', value: 'Uganda'},
            {label: 'Ukraine', value: 'Ukraine'},
            {label: 'United Arab Emirates', value: 'United Arab Emirates'},
            {label: 'Uruguay', value: 'Uruguay'},
            {label: 'Uzbekistan', value: 'Uzbekistan'},
            {label: 'Vanuatu', value: 'Vanuatu'},
            {label: 'Venezuela', value: 'Venezuela'},
            {label: 'Vietnam', value: 'Vietnam'},
            {label: 'Yemen', value: 'Yemen'},
            {label: 'Zambia', value: 'Zambia'},
            {label: 'Zimbabwe', value: 'Zimbabwe'}            
        ]
    }

    

  
    connectedCallback() {
        console.log(',,.,,.,',this.showOhterText);
        if(this.opprecord.Applicant_2__c != null){
            this.addressapp2 = this.opprecord.Applicant_2__r.Residential_Address__pc + ' ' + this.opprecord.Applicant_2__r.Postal_Code__pc;
            if(this.condata.Id == this.opprecord.Applicant_2__r.PersonContactId){
                this.isApp2 = true;
            }
        }else{
            this.isinglePersonapp = true;            
        }

        this.addressapp1 = this.opprecord.Applicant_1__r.Residential_Address__pc + ' ' + this.opprecord.Applicant_1__r.Postal_Code__pc;
        

      /*  loadStyle(this,  LwcStyle + '/esign.css')
            .then(() => {
                console.log('Custom CSS loaded successfully');
            })
            .catch((error) => {
                console.error('Error loading custom CSS: ', error);
            });*/
    } 
    
    

    @api 
    checkFieldsValidationBHCCU(){
        this.retrnval = [];
        let cntry = this.template.querySelector(".countrycitizen"); 
        let cntryTax  = this.template.querySelector(".countrytax");       

        var ids = [];

        if(this.allValuesofCitizen.length <= 0 ){
            cntry.setCustomValidity("Complete this field.");
            this.retrnval.push(false);
            ids.push('countrycitizen');
        }
        else{
            cntry.setCustomValidity("");
            this.retrnval.push(true);
            ids.push('');
        }
        cntry.reportValidity();

        if(this.allValuesofTax.length <= 0 ){
            cntryTax.setCustomValidity("Complete this field.");
            this.retrnval.push(false);
            ids.push('countrytax');
        }
        else{
            cntryTax.setCustomValidity("");
            this.retrnval.push(true);
            ids.push('');
        }
        cntryTax.reportValidity();
        

        for(var i=0; i<ids.length; i++){
            if(ids[i] != ''){
                const mandatoryFieldElement = this.template.querySelector('.'+ids[i]);
                mandatoryFieldElement.scrollIntoView({ behavior: 'smooth' });
                break;
            }
        }
    }

    @api
   updateContact(){
        this.showSpin = true;        
        var citizen =  this.allValuesofCitizen.toString();
        var taxCont =  this.allValuesofTax.toString();
        console.log('citizen-'+citizen);
        console.log('taxCont-'+taxCont);
        var updatedCitizen = '';
        var updatedTax = '';
        if(citizen.includes(',')){
            updatedCitizen = citizen.replace(',',';');
        }else{
            updatedCitizen = citizen;
        }

       if(taxCont.includes(',')){
            updatedTax = taxCont.replace(',',';');
        }else{
            updatedTax = taxCont;
        }
        console.log('updatedCitizen-'+updatedCitizen);
        console.log('updatedTax-'+updatedTax);
        
        updateContactForBhccu({conId :  this.condata.Id, TaxResi : updatedTax, citizenCountry : updatedCitizen})
        .then(result => {
            console.log('data  bhcccuupdate==',result);
            if(result == 'success'){  
                insertPDFAndSendEmail({conId : this.condata.Id, oppId : this.opprecord.Id})   
                .then(result => {
                    var masterQuote = this.quoterecord.Gruop_Name__c;
                    var label = baseUrlLabel;                     
                    var app2 = (this.opprecord.Applicant_2__c != null ?  this.opprecord.Applicant_2__r.PersonContactId : '');
                    if(this.condata.Id == app2){
                        var istr = true;
                        window.location.href = label+'?id='+this.opprecord.Id+ '&AppTwo=' + istr +'&master='+masterQuote.replace('&', '%26'), '_blank';
                    }
                    else{
                        window.location.href = label+'?id='+this.opprecord.Id+'&master='+masterQuote.replace('&', '%26'), '_blank';
                    }                                         
                })
                .catch(error => {
                    console.log('error--',error);
                    this.error = error;
                    
                });                      
            }
        })
        .catch(error => {
            console.log('error--',error);
            this.error = error;
        });
    }


    handleCitizenCountry(event){
        if(!this.allValuesofCitizen.includes(event.target.value)){
            if(event.target.value != '--------------------------'){
                this.allValuesofCitizen.push(event.target.value);
            }            
        }
        if(event.target.value != '--------------------------'){
            let cntry = this.template.querySelector(".countrycitizen");       
            cntry.setCustomValidity("");
        }
    }

    handleRemove(event){
        const indexToRemove = event.detail.name;
        this.allValuesofCitizen.splice(indexToRemove, 1);
    }

    handleCitizenTax(event){
       if(!this.allValuesofTax.includes(event.target.value)){
           if(event.target.value != '--------------------------'){
                this.allValuesofTax.push(event.target.value);                
            }            
        }
        if(event.target.value != '--------------------------'){
            let cntry = this.template.querySelector(".countrytax");       
            cntry.setCustomValidity(""); 
        }
    }

    handleRemovetax(event){
        const indexToRemove = event.detail.name;
        this.allValuesofTax.splice(indexToRemove, 1);
    }
}