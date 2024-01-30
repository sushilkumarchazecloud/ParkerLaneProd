global class updateQuotesByProductBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    private string productID;
    public updateQuotesByProductBatch(String proId) {
        productID = proId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<string> stages = new List<string>{'Nurturing','Working','CPA Started','CPA Done','Packs Out','Packs Back','Quote'};
            string Query = 'Select Id, Actual_Comparison_Rate__c, Customer_Amount__c,Product__r.Actual_Comparison_Rate__c, Name, Product__r.Name, Interest_Rate__c, Product__r.Interest_Rate__c,Loan_Term__c, Product__r.Max_Loan_Term__c, Product__r.Default_Loan_Term_Months__c, Commission_Amount__c, Product__r.Commission_Amount__c,Brokerage_Amount__c, Product__r.Brokerage_Amount__c, Lender__c, Product__r.Lender__c,(SELECT ID, Amount__c, Fee_Type__c, Frequency__c, Product_Loan_Fees__r.Amount__c, Product_Loan_Fees__r.Fee_Type__c, Product_Loan_Fees__r.Frequency__c FROM Loan_Fees__r)From Quote WHERE Product__c=:productID  AND Opportunity.StageName IN: stages Limit 10000';
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext bc, List<Quote> scope) {
        List<Loan_Rate__c> objList = new List<Loan_Rate__c>();
        List<Loan_Fees__c> lfees = new List<Loan_Fees__c>();
        List<Quote> quotesList = new List<Quote>();
        try{
            System.debug('SCOPR===='+scope.size());
            
            for(Loan_Rate__c lr : [select id,Interest_rate__c,From_amount__c,Comparison_rate__c,To_amount__c from Loan_Rate__c where Product__c = :productID ]){
                objList.add(lr);
            }
            
            for(Quote quote: scope){
                quote.Actual_Comparison_Rate__c = quote.Product__r.Actual_Comparison_Rate__c;
                quote.Name = quote.Product__r.Name;
                //quote.Interest_Rate__c = quote.Product__r.Interest_Rate__c;
                for(Loan_Rate__c  lr: objList){
                    //console.log('>>>>From_amount  ' + loanRates[i].From_amount__c);
                    if(lr.From_amount__c <= quote.Customer_Amount__c && lr.To_amount__c >= quote.Customer_Amount__c){
                        quote.Actual_Comparison_Rate__c = lr.Comparison_rate__c;
                        quote.Interest_Rate__c = lr.Interest_rate__c;
                        //break;
                    }
                }
                quote.Loan_Term__c = quote.Product__r.Max_Loan_Term__c;
                if(quote.Product__r.Default_Loan_Term_Months__c != NULL && quote.Product__r.Default_Loan_Term_Months__c > 0){   
                    quote.Loan_Term__c = quote.Product__r.Default_Loan_Term_Months__c;    
                }
                quote.Commission_Amount__c = quote.Product__r.Commission_Amount__c;
                quote.Brokerage_Amount__c = quote.Product__r.Brokerage_Amount__c;
                quote.Lender__c = quote.Product__r.Lender__c;
                //quote.Temp_Flag__c = true;
                quotesList.add(quote);
                
                for(Loan_Fees__c lf:quote.Loan_Fees__r){
                    lf.Amount__c = lf.Product_Loan_Fees__r.Amount__c;
                    lf.Fee_Type__c = lf.Product_Loan_Fees__r.Fee_Type__c;
                    lf.Frequency__c = lf.Product_Loan_Fees__r.Frequency__c;
                    lfees.add(lf);
                }
                
            }
        }catch(Exception ex){
            Exception__c eror = new Exception__c();
            eror.Class_Name__c = 'Quote Update Batch';
            eror.Method_Name__c = 'In code error';
            eror.Error_Message__c = ex.getMessage() + '' + ex.getLineNumber() + '' + ex.getCause();
            insert eror;  
        }
        System.debug('>>>>quotesList' + quotesList.size());
        System.debug('>>>>lfees' + lfees.size());
        try{
            database.update(lfees, false);
            Database.update(quotesList, false);
        }catch(Exception ex){
            Exception__c eror = new Exception__c();
            eror.Class_Name__c = 'Quote Update Batch';
            eror.Method_Name__c = 'updating Failed';
            eror.Error_Message__c = ex.getMessage() + '' + ex.getLineNumber() + '' + ex.getCause();
            insert eror;
        }
        
    }
    
    global void finish(Database.BatchableContext bc) {
        system.debug('batch job id = '+bc.getJobId());
        String userName = UserInfo.getUserName();
        User activeUser = [Select name,Email From User where Username = : userName limit 1];
        list<String> userEmail =  new List<string>();
        userEmail.add(activeUser.Email); 
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: activeUser.Email]; //sushil.verma1988@gmail.com
        if(owea != null){
            if ( owea.size() > 0 ) {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }
        }
        string body = 'Hi ' + activeUser.name + '\n\n';
        body += 'Quotes are Updated Successfully';
        email.setToAddresses(userEmail);
        email.setSubject('Quotes are Updated Successfully!!');
        email.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
    
}