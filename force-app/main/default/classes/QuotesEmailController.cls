public class QuotesEmailController {
    public String opportunityId{get;set;}
    public String opportunityName{get;set;}
    public String leadName{get;set;}
    public String custName{get;set;}
    public String refName{get;set;}
    public String purpose{get;set;}
    public String address{get;set;}
    public String phone{get;set;}
    public String sendQuoteTo{get;set;}
    public String openUrl{get;set;}
    public Boolean var1{get;set;}
    public Boolean var2{get;set;}
    public Boolean noVoi{get;set;}    
    public list<quoteWrp> qtWrapper{get;set;}
    public Quote qtDetails{get;set;}
    
    
    public Boolean init{
        get{
            init();            
            return false;
        }
    } 
    
    public opportunity getOpportunity(){
        var1 = false;
        var2 = false;
        noVoi = false;
        String custLabel = System.Label.baseUrl;        
        Opportunity opp = [select id,name,StageName,SyncedQuoteId,Applicant_1__r.personContactId,Applicant_2__r.personContactId,Applicant_1_FirstName__c,Applicant_2_FirstName__c,purpose__c,Applicant_1_Name__c,Applicant_2_Name__c,Documents_Outstanding__c from opportunity where id=:opportunityId LIMIT 1];
        system.debug('Documents_Outstanding__c'+opp.Documents_Outstanding__c);
        Quote qtDetails = [Select id, Gruop_Name__c from Quote where id =: opp.SyncedQuoteId];
        openUrl = custLabel+'?id='+opportunityId+'&master='+qtDetails.Gruop_Name__c.replace('&', '%26')+ '';
        list<VOI_Status__c> newlst = [select id,Contact__c,VOI_Details__c,VOI_Status__c from VOI_Status__c where Opportunity__c =: opportunityId];
        system.debug('newlst'+newlst);
        if(newlst.isEmpty()){
            noVoi = true;
        }
        for(VOI_Status__c sd : newlst){
            if(sd.Contact__c == opp.Applicant_1__r.personContactId){
                if(sd.VOI_Status__c == 'Sent' || sd.VOI_Status__c == 'Delivered'){
                    var1 = true;
                }
            }
            if(opp.Applicant_2__c != null){
                if(sd.Contact__c == opp.Applicant_2__r.personContactId){
                    if(sd.VOI_Status__c == 'Sent' || sd.VOI_Status__c == 'Delivered'){
                        var2 = true;
                    }
                }   
            }            
        }
        
        system.debug('newlst>>>>>'+newlst);
        return opp;
    }
    
    public void init(){
        
        Opportunity opp = [select id,name,Applicant_1_FirstName__c,Applicant_1_Email__c,FinServ__ReferredByContact__r.Name,purpose__c,leadAddress__c, Applicant_1__r.phone, Send_the_quote_to__c from opportunity where id=:opportunityId LIMIT 1];
        Lead ld = [select id,name,email from lead where email=:opp.Applicant_1_Email__c limit 1];
         opportunityName = opp.Name;
         custName = opp.Applicant_1_FirstName__c;
         leadName = ld.Name;
         refName  = opp.FinServ__ReferredByContact__r.Name;
         purpose  = opp.Purpose__c;
         address  = opp.leadAddress__c;
         phone    = opp.Applicant_1__r.phone;
         sendQuoteTo = opp.Send_the_quote_to__c;
        Map<String,quoteWrp> mapOfquotes = new Map<String,quoteWrp>();
        decimal minInterest=0;
        decimal minRepayment=0;
        list<Quote> qtList =[SELECT id,Name,QuoteNumber,Customer_Amount__c,Master_Quote_For_URL__c,ORG_URL__c,OpportunityId,Interest_Rate__c,Monthly_Repayment__c,Gruop_Name__c,Quote_Group_Label__c,Application__c,Loan_Term__c,Comparison_Rate_Display__c,Actual_Comparison_Rate__c FROM Quote WHERE
                             OpportunityId =: opportunityId AND IsSelected__c=true];
        system.debug('My list--'+qtList);
        for(Quote qt : qtList){
            quoteWrp quoteWrapper = new quoteWrp();
            if(!mapOfquotes.containskey(qt.Gruop_Name__c)){
                quoteWrapper.InterestRate = qt.Interest_Rate__c;
                minInterest = qt.Interest_Rate__c;
                quoteWrapper.Repayment = qt.Monthly_Repayment__c;
                minRepayment = qt.Monthly_Repayment__c;
                quoteWrapper.ComparsionRate= qt.Actual_Comparison_Rate__c;
                quoteWrapper.Loanterm = qt.Loan_Term__c;
                quoteWrapper.Amount=qt.Customer_Amount__c;
                quoteWrapper.GroupName = qt.Gruop_Name__c;
                quoteWrapper.GroupLabel = qt.Quote_Group_Label__c;
                quoteWrapper.isChecked = false;
                quoteWrapper.masterQuoteForURL = qt.Master_Quote_For_URL__c;
                quoteWrapper.compRateDisplay = qt.Comparison_Rate_Display__c;
                quoteWrapper.orgURL = qt.ORG_URL__c;
                quoteWrapper.oppId = qt.OpportunityId;
                mapOfquotes.put(qt.Gruop_Name__c,quoteWrapper);
            }
            else{
                if(qt.Interest_Rate__c < minInterest){
                    quoteWrapper.InterestRate = qt.Interest_Rate__c;
                    quoteWrapper.ComparsionRate= qt.Actual_Comparison_Rate__c;
                    minInterest = qt.Interest_Rate__c;
                }
                else if(qt.Interest_Rate__c == minInterest){
                    if(mapOfquotes.get(qt.Gruop_Name__c).ComparsionRate > qt.Actual_Comparison_Rate__c){
                        quoteWrapper.ComparsionRate= qt.Actual_Comparison_Rate__c;
                    }
                    quoteWrapper.InterestRate = qt.Interest_Rate__c;
                    quoteWrapper.ComparsionRate= qt.Actual_Comparison_Rate__c;
                    minInterest = qt.Interest_Rate__c;
                }
                else{
                    quoteWrapper.InterestRate = mapOfquotes.get(qt.Gruop_Name__c).InterestRate;
                    quoteWrapper.ComparsionRate= mapOfquotes.get(qt.Gruop_Name__c).ComparsionRate;
                }
                if(qt.Monthly_Repayment__c < minRepayment){
                    quoteWrapper.Repayment = qt.Monthly_Repayment__c;
                    quoteWrapper.Loanterm  = qt.Loan_Term__c;
                    minRepayment = qt.Monthly_Repayment__c;
                }
                else{
                    quoteWrapper.Repayment = mapOfquotes.get(qt.Gruop_Name__c).Repayment;
                    quoteWrapper.Loanterm  = mapOfquotes.get(qt.Gruop_Name__c).Loanterm;
                }
                quoteWrapper.Amount = mapOfquotes.get(qt.Gruop_Name__c).Amount;
                quoteWrapper.GroupName = mapOfquotes.get(qt.Gruop_Name__c).GroupName;
                quoteWrapper.GroupLabel = mapOfquotes.get(qt.Gruop_Name__c).GroupLabel;
                quoteWrapper.isChecked = false;
                quoteWrapper.masterQuoteForURL = mapOfquotes.get(qt.Gruop_Name__c).masterQuoteForURL;
                quoteWrapper.compRateDisplay = mapOfquotes.get(qt.Gruop_Name__c).compRateDisplay;
                quoteWrapper.orgURL = mapOfquotes.get(qt.Gruop_Name__c).orgURL;
                quoteWrapper.oppId = mapOfquotes.get(qt.Gruop_Name__c).oppId;
                mapOfquotes.put(qt.Gruop_Name__c,quoteWrapper);
            }
        }
        qtWrapper = new list<quoteWrp>();
        if(mapOfquotes.values()!=null){
        qtWrapper = mapOfquotes.values();
        }
        system.debug('mail quoets--'+qtWrapper.size());
        //system.Assert(false);
        
    }
    
    public class quoteWrp{
        public Decimal InterestRate{get;set;}
        public Decimal ComparsionRate{get;set;}
        public Decimal Repayment{get;set;}
        public Decimal Loanterm{get;set;}
        public Decimal Amount{get;set;}
        public String oppId{get;set;}
        public string masterQuoteForURL{get;set;}
        public string compRateDisplay{get;set;}
        public string orgURL{get;set;}
        public String GroupName{get;set;}
        public String GroupLabel{get;set;}
        public Boolean isChecked{get;set;}
    }
    
    
}