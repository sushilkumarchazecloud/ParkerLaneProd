public without sharing class QuotationTemplatePDFCtrl {
    public List<QuoteWrapper> quoteWrpList {get;set;}
    public Map<String,List<QuoteWrapper>> quoteWrpMap {get;set;}
    public Map<String,Decimal> custmerAmountMap {get;set;}
    public String loanPurpose {get;set;}
    public String applicantName {get;set;}
    public Decimal custmerAmount {get;set;}
    public Boolean isAfterLoanRecc {get;set;}
    public Opportunity opprtunity {get;set;}
    
    public QuotationTemplatePDFCtrl(){
        isAfterLoanRecc = false;
        applicantName='';
        custmerAmount = 0;
        opprtunity = New Opportunity();
        string OppId = apexpages.currentpage().getparameters().get('id');
        string isSelected =  apexpages.currentpage().getparameters().get('isSelected');
        custmerAmountMap = New Map<String,Decimal> ();
        if(String.isNotBlank(OppId)){
            quoteWrpMap = New Map<String,List<QuoteWrapper>>();
            quoteWrpList = New List<QuoteWrapper>();
            list<Opportunity> oppsQuotesList = new List<Opportunity>();
            if(isSelected=='yes'){
                oppsQuotesList=
                    [SELECT Id, Product_Type__c, Applicant_1__c, Applicant_2__c, Applicant_1__r.Name, Applicant_2__r.Name, Amount,
                     Application_Sections__c, Purpose__c,
                     (SELECT Id, Actual_Comparison_Rate__c, Comparison_Rate_Warning__c, Eligibility__c, Gruop_Name__c,
                      Product__r.Features__c,Product__r.What_document_needs_to_apply__c, Interest_Rate__c, Customer_Amount__c, Loan_Term__c, Name, Product__r.Eligibility_Description__c ,
                      Monthly_Repayment__c, Product__r.Min_Loan_Term__c, Product__r.Max_Loan_Term__c, Purpose__c, Lead__c,
                      Product__r.Lender__c,Product__r.Is_Feature_Product__c, Total_Loan_Cost__c, Weekly_Repayments__c, Product__r.Security__c, Product__r.Interest_Rate_Type__c,
                      Product__r.Description, Product__r.Product_Type__c, Product__r.Interest_Rate_From__c, Total_Setup_Fees__c, Lead__r.Name,isSelected__c
                      FROM Quotes where isSelected__c=true ORDER BY Product__r.Product_Order__c) 
                     FROM Opportunity WHERE Id =: OppId];
                System.debug('@@@@@oppsQuotesList' + oppsQuotesList.size());}
            else{
                oppsQuotesList=
                    [SELECT Id, Product_Type__c, Applicant_1__c, Applicant_2__c, Applicant_1__r.Name, Applicant_2__r.Name, Amount,
                     Application_Sections__c, Purpose__c,
                     (SELECT Id, Actual_Comparison_Rate__c, Comparison_Rate_Warning__c, Eligibility__c, Gruop_Name__c,
                      Product__r.Features__c,Product__r.What_document_needs_to_apply__c, Interest_Rate__c, Customer_Amount__c, Loan_Term__c, Name, Product__r.Eligibility_Description__c ,
                      Monthly_Repayment__c, Product__r.Min_Loan_Term__c, Product__r.Max_Loan_Term__c, Purpose__c, Lead__c,
                      Product__r.Lender__c,Product__r.Is_Feature_Product__c, Total_Loan_Cost__c, Weekly_Repayments__c, Product__r.Security__c, Product__r.Interest_Rate_Type__c,
                      Product__r.Description, Product__r.Product_Type__c, Product__r.Interest_Rate_From__c, Total_Setup_Fees__c, Lead__r.Name
                      FROM Quotes ORDER BY Product__r.Product_Order__c) 
                     FROM Opportunity WHERE Id =: OppId];
            }
            
            List<String> appSectionsList = ApplicationFormController.getApplicationSections();
            
            if(!oppsQuotesList.isEmpty()){
                opprtunity = oppsQuotesList[0];
                
                if(appSectionsList.indexOf(opprtunity.Application_Sections__c) >= 2){
                    isAfterLoanRecc = true;
                }
                
                if(isAfterLoanRecc){
                    if(String.isNotBlank(opprtunity.Applicant_1__c))
                        applicantName += opprtunity.Applicant_1__r.Name;
                    
                    if(String.isNotBlank(opprtunity.Applicant_2__c))
                        applicantName += ' and ' + opprtunity.Applicant_2__r.Name;
                }
                if(!opprtunity.Quotes.isEmpty()){
                    for(Quote qt : opprtunity.Quotes){
                        custmerAmount = qt.Customer_Amount__c;
                        applicantName = qt.Gruop_Name__c;
                        quoteWrpList.add(getQuoteWrapper(qt));
                        List<QuoteWrapper> quoteWrpListTemp = quoteWrpMap.get(qt.Gruop_Name__c);
                        if(quoteWrpListTemp == NULL){
                            quoteWrpListTemp = New List<QuoteWrapper>();
                        }                   
                        quoteWrpListTemp.add(getQuoteWrapper(qt));
                        custmerAmountMap.put(qt.Gruop_Name__c, qt.Customer_Amount__c);
                        quoteWrpMap.put(qt.Gruop_Name__c, quoteWrpListTemp);
                    }
                }
            }
        }  
    }
    
    private QuoteWrapper getQuoteWrapper(Quote qt){
        System.debug('@@@@@opprtunity.Quote' + qt);
        QuoteWrapper quoteWrp = New QuoteWrapper();
        quoteWrp.Loan_Term = qt.Loan_Term__c;
        quoteWrp.Monthly_Repayment = qt.Monthly_Repayment__c;
        quoteWrp.Weekly_Repayments = qt.Weekly_Repayments__c;
        quoteWrp.Security = qt.Product__r.Security__c;
        quoteWrp.Interest_Rate_Type = qt.Product__r.Interest_Rate_Type__c;
        quoteWrp.Interest_Rate = qt.Interest_Rate__c;
        quoteWrp.Actual_Comparison_Rate = qt.Actual_Comparison_Rate__c;
        quoteWrp.Description = qt.Product__r.Description;
        quoteWrp.Lender = qt.Product__r.Lender__c;
        quoteWrp.Total_Setup_Fees = qt.Total_Setup_Fees__c;
        quoteWrp.Total_Loan_Cost = qt.Total_Loan_Cost__c;
        quoteWrp.Eligibility_Description = qt.Product__r.Eligibility_Description__c;
        quoteWrp.fromStr = qt.Product__r.Interest_Rate_From__c ? ' From' : '';
        quoteWrp.Loan_Term_Available = qt.Product__r.Min_Loan_Term__c + '-' + qt.Product__r.Max_Loan_Term__c;
        quoteWrp.Loan_Term_Year = qt.Product__r.Min_Loan_Term__c/12 + '-' + qt.Product__r.Max_Loan_Term__c/12;
        quoteWrp.isFeatured = qt.Product__r.Is_Feature_Product__c;
        if(qt.Product__r.Features__c != Null){
            quoteWrp.features = qt.Product__r.Features__c.split(';');
        }
        if(qt.Product__r.What_document_needs_to_apply__c != Null){
            quoteWrp.whatYouGet = qt.Product__r.What_document_needs_to_apply__c.split(';');
        }        
        return quoteWrp;
    }
    
    public class QuoteWrapper{
        public list<String> features {get;set;}
        public list<String> whatYouGet {get;set;}
        public Decimal Loan_Term {get;set;}
        public Decimal Monthly_Repayment {get;set;}
        public Decimal Weekly_Repayments {get;set;}
        public String Gruop_Name {get;set;}
        public String Security {get;set;}
        public String Interest_Rate_Type {get;set;}
        public Decimal Interest_Rate {get;set;}
        public Decimal Actual_Comparison_Rate {get;set;}
        public String Description {get;set;}
        public String Lender {get;set;}
        public String fromStr {get;set;}
        public Decimal Total_Setup_Fees {get;set;}
        public Decimal Total_Loan_Cost {get;set;}
        public String Eligibility_Description {get;set;}
        public String Loan_Term_Available {get;set;}
        public String Loan_Term_Year {get;set;}
        public Boolean isFeatured {get;set;}
    }
}