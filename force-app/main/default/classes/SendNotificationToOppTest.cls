@isTest
public class SendNotificationToOppTest{
    @isTest
    private static void testSendNotiToOpp(){
        Account ac = new Account(Name='Test Ac');
        insert ac;
        
        List<String> typeList = productSearch.getProductType(); 
        Product2 pd = new Product2();
        pd.Interest_Rate__c = 5.6;
        pd.Interest_Rate_Override__c = true;
        pd.Interest_Rate_Type__c = 'Fixed';
        pd.Name = 'Test product';
        insert pd;
        
        Opportunity opp = new Opportunity( Applicant_1__c = ac.Id,Applicant_2__c = ac.Id,Documents_Outstanding__c='No more documents outstanding',App_1_VOI_eSign_Complete__c=true,App_2_VOI_eSign_Complete__c=true, Name='Test', StageName='open', CloseDate= Date.today());
        Insert opp;
        
        List<Product2> temp = productSearch.getProduct(typeList[0], 0);
        String pro = '[{"chk":true,"Lender":"Transport Mutual Credit Union",';
        pro +='"IntRate":4.99,"MaxTerm":84,"MinTerm":12,"LoanAmounts":"$5000 to $100000","ProductName":"Go Green (1-7yrs)","LoanAmount":"5000","LoanTerm":"12","InterestRateFrom":true,"isInterestRate":false,';
        pro +='"InterestRate":4.99,"InterestRateType":"Variable","ComparisonRate":5.26,"Description":"No monthly account keeping fees ; Extra repayments and pay out early without penalty. Clear out your high interest credit cards faster and be debt free sooner. Borrow from $1,000 to $30,000.","Features":"One low fixed up front fee;Extra repayments at no penalty;No account keeping or early termination fees","fees":[{"Product__c":"","Id":"","Fee_Type__c":"Application","Frequency__c":"Setup","Name":"LF-0078","Override_allowed__c":false,"Amount__c":199},{"Product__c":"","Id":"","Fee_Type__c":"Application","Frequency__c":"Setup","Name":"LF-0004","Override_allowed__c":false,"Amount__c":199},{"Product__c":"","Id":"","Fee_Type__c":"Application","Frequency__c":"Setup","Name":"LF-0082","Override_allowed__c":false,"Amount__c":199},{"Product__c":"","Id":"","Fee_Type__c":"Application","Frequency__c":"Setup","Name":"LF-0100","Override_allowed__c":false,"Amount__c":199},{"Product__c":"","Id":"","Fee_Type__c":"Application","Frequency__c":"Setup","Name":"LF-0122","Override_allowed__c":false,"Amount__c":199},{"Product__c":"","Id":"","Fee_Type__c":"Application","Frequency__c":"Setup","Name":"LF-0118","Override_allowed__c":false,"Amount__c":199}],"feesMap":{},"feesList":[{"Product__c":"","Id":"","Fee_Type__c":"Application","Frequency__c":"Setup","Name":"LF-0078","Override_allowed__c":false,"Amount__c":199}]}]';
        productSearch.insertQuote(pro, typeList[0], 'groupName', opp.Id);
        
        Quote quote = [Select Id,Name,Application__c,Loan_Term__c,Purpose__c,Customer_Amount__c,Interest_Rate__c,Product__c from quote where OpportunityId =: opp.Id][0];
        quote.Application__c = true;
        update quote;
        
        dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c();
        ds.dsfs__Opportunity__c = opp.Id;
        ds.dsfs__Envelope_Status__c = 'Sent';
        ds.dsfs__Subject__c = 'Home Improvement Loan Documents For Your e-Signature';
        insert ds;
        
        ds.dsfs__Envelope_Status__c = 'Completed';
        update ds;
       
    }
}