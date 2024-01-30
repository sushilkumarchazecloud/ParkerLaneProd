public without sharing class SaveAndSavePDFController{
    
    public WrapperClass wpObj{get;set;}
    public QuoteWrap quoteWrap{get;set;}
    
    public SaveAndSavePDFController(ApexPages.StandardController stdController){
        wpObj = new WrapperClass();
        quoteWrap = new QuoteWrap();
        String oppId = ApexPages.currentPage().getParameters().get('id');
        if(String.isBlank(oppId)){
            oppId = stdController.getRecord().id;
        }
        Opportunity opp = new Opportunity();
        
        opp = [SELECT CreatedDate,Applicant_1__c,Applicant_2__c,Owner.Name,Owner.Email,Owner.Phone,Applicant_1__r.Name,
                            Applicant_2__r.Name,Applicant_1__r.Residential_Address__pc,(Select Lender__c, Product__c,Customer_Amount__c,Product__r.Interest_Rate_Type__c,Product__r.Risk_Insurance_Available__c,
                            Interest_Rate__c,Monthly_Repayments__c,Monthly_Repayment__c,Loan_Term__c,Total_Setup_Fees__c,Brokerage_Amount__c,Commission_Amount__c,SQ_Referral_Commission__c,Up_Front_Fees__c,
                            Product__r.Ongoing_Fees__c,Total_loan_amount__c,Total_Loan_Cost__c,Application__c,Product__r.Name,Total_Fees__c,Credit_Available_after_Setup_Costs__c, Monthly_Account_Keeping_Fees__c 
                            From Quotes where Application__c = true)
                            From Opportunity where Id =: oppId][0];
                            
        List<Loan_Fees__c> lflist = [SELECT Amount__c, Fee_Type__c, Frequency__c, Quote__c FROM Loan_Fees__c where Quote__c =: opp.Quotes[0].Id ];
        wpObj.opp = opp;
        
        quoteWrap.RiskInsuranceAvailable = opp.Quotes[0].Product__r.Risk_Insurance_Available__c;
        quoteWrap.Lender = opp.Quotes[0].Lender__c;
        quoteWrap.ProductName = opp.Quotes[0].Product__r.Name;
        quoteWrap.CustomerAmount = opp.Quotes[0].Customer_Amount__c;
        quoteWrap.InterestRateType = opp.Quotes[0].Product__r.Interest_Rate_Type__c;
        quoteWrap.InterestRate = opp.Quotes[0].Interest_Rate__c;
        quoteWrap.MonthlyRepayments = opp.Quotes[0].Monthly_Repayments__c;
        quoteWrap.LoanTerm = opp.Quotes[0].Loan_Term__c;
        quoteWrap.TotalSetupFees = opp.Quotes[0].Total_Setup_Fees__c.setScale(2);
        quoteWrap.BrokerageAmount = opp.Quotes[0].Brokerage_Amount__c != null ? opp.Quotes[0].Brokerage_Amount__c : 0.0;
        quoteWrap.UpFrontFees = opp.Quotes[0].Up_Front_Fees__c != null ? opp.Quotes[0].Up_Front_Fees__c : 0.0;
        quoteWrap.CommissionAmount = opp.Quotes[0].Commission_Amount__c;
        quoteWrap.SQReferralCommission = opp.Quotes[0].SQ_Referral_Commission__c;
        quoteWrap.OngoingFees = opp.Quotes[0].Product__r.Ongoing_Fees__c;
        quoteWrap.TotalLoanAmount = opp.Quotes[0].Total_loan_amount__c;
        quoteWrap.TotalLoanCost = opp.Quotes[0].Total_Loan_Cost__c;
        quoteWrap.TotalFees = opp.Quotes[0].Total_Fees__c.setScale(2);
        quoteWrap.CreditAvailableAfterSetupCosts = opp.Quotes[0].Credit_Available_after_Setup_Costs__c != null ? opp.Quotes[0].Credit_Available_after_Setup_Costs__c : 0.0;
        quoteWrap.AccountKeeping = (opp.Quotes[0].Monthly_Account_Keeping_Fees__c  * opp.Quotes[0].Loan_Term__c).round();
        String accountKeepingFees = '';
        for(Loan_Fees__c lf : lflist){
            if(lf.Fee_Type__c == 'Establishment'){
                wpObj.Establishment = lf.Amount__c.round();
            }
            if(lf.Fee_Type__c == 'Application'){
                wpObj.Application = lf.Amount__c.round();
            }
            if(lf.Fee_Type__c == 'Risk'){
                wpObj.Risk = lf.Amount__c.round();
            }
            if(lf.Fee_Type__c == 'Valuation'){
                wpObj.Valuation = lf.Amount__c.round();
            }
            if(lf.Fee_Type__c == 'Legal'){
                wpObj.Legal = lf.Amount__c.round();
            }
            if(lf.Fee_Type__c == 'Government Charges'){
                wpObj.GovernmentCharges = lf.Amount__c.round();
            }
            if(lf.Fee_Type__c == 'Account Keeping'){
                accountKeepingFees += '$'+lf.Amount__c + ' ' + lf.Frequency__c + ' account keeping fees; ';
            }
        }
        
        if(String.isNotBlank(accountKeepingFees)){
            quoteWrap.accountKeepingFees = accountKeepingFees.removeEnd('; ');
        }
        
    }
    
    public class QuoteWrap{
        public Boolean RiskInsuranceAvailable{get;set;}
        public String Lender{get;set;}
        public String ProductName{get;set;}
        public Decimal CustomerAmount{get;set;}
        public String InterestRateType{get;set;}
        public Decimal InterestRate{get;set;}
        public Decimal MonthlyRepayments{get;set;}
        public Decimal LoanTerm{get;set;}
        public Decimal TotalSetupFees{get;set;}
        public Decimal BrokerageAmount{get;set;}
        public Decimal CommissionAmount{get;set;}
        public Decimal SQReferralCommission{get;set;}
        public Decimal OngoingFees{get;set;}
        public Decimal TotalLoanAmount{get;set;}
        public Decimal TotalLoanCost{get;set;}
        public Decimal TotalFees{get;set;}
        public Decimal CreditAvailableAfterSetupCosts{get;set;}
        public String accountKeepingFees{get;set;}
        public Decimal AccountKeeping{get;set;}
        public Decimal UpFrontFees{get;set;}
    }
    
    public class WrapperClass{
        public Opportunity opp{get;set;}
        public Decimal Establishment{get;set;}
        public Decimal Application{get;set;}
        public Decimal Risk{get;set;}
        public Decimal Valuation{get;set;}
        public Decimal Legal{get;set;}
        public Decimal GovernmentCharges{get;set;}
        
        public WrapperClass(){
            opp = new Opportunity();
            Establishment = 0;
            Application = 0;
            Risk = 0;
            Valuation = 0;
            Legal = 0;
            GovernmentCharges = 0;
        }    
    }
}