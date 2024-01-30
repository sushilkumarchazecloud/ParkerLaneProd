import { LightningElement, api, track } from 'lwc';
export default class Collapsible extends LightningElement {
   
    @api quoterecord;
    @api opprecord;
    @track accAmounnt;
    @track isAmount;
    @track formattedNumber;
    @track Recipt;
    connectedCallback() {
        if(this.quoterecord.Monthly_Account_Keeping_Fees__c != null && this.quoterecord.Monthly_Account_Keeping_Fees__c > 0){
            var amnt = this.quoterecord.Monthly_Account_Keeping_Fees__c * this.quoterecord.Loan_Term__c;
            console.log('--',amnt);
            var x = Math.floor(amnt * 100) / 100;
            this.accAmounnt = '$' + x.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });
          //  this.accAmount = '$'+ x.toFixed(2); Commented by pawan 1249.
             //= (amnt.format().contains('.')?amnt.format():(amnt.format()+'.00'));
        }
        else{
            this.accAmounnt = '$0.00';
        }

        if(this.opprecord.Referral_Fee_Recipient__c != null){
            this.Recipt = this.opprecord.Referral_Fee_Recipient__r.Name;
        }
        else{
            this.Recipt = '';   
        }
        
        if(this.opprecord.Referral_Fee_inc_GST__c != null && this.opprecord.Referral_Fee_inc_GST__c > 0){
            this.isAmount = true;            
            this.formattedNumber = (Math.ceil(this.opprecord.Referral_Fee_inc_GST__c)).toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
                minimumFractionDigits: 0,
                maximumFractionDigits: 0
            });
        }

    }
    
}