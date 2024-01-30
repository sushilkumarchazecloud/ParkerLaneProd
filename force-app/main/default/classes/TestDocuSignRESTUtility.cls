@isTest
public class TestDocuSignRESTUtility{
    @isTest
    private static void testSendEnvelope(){
        Account ac = new Account(Name='Test Ac');
        insert ac;
        List<String> typeList = productSearch.getProductType();
        Product2 pd = new Product2();
        pd.Interest_Rate__c = 5.6;
        pd.Interest_Rate_Override__c = true;
        pd.Interest_Rate_Type__c = 'Fixed';
        pd.Name = 'Test product';
        insert pd;
        Opportunity opp = new Opportunity( Applicant_1__c = ac.Id,Applicant_2__c = ac.Id, Name='Test', StageName='open', CloseDate= Date.today());
        Insert opp;
        List<Product2> temp = productSearch.getProduct(typeList[0], 0);
        String pro = '[{"chk":true,"Lender":"Transport Mutual Credit Union",';
        pro +='"IntRate":4.99,"MaxTerm":84,"MinTerm":12,"LoanAmounts":"$5000 to $100000","ProductName":"Go Green (1-7yrs)","LoanAmount":"5000","LoanTerm":"12","InterestRateFrom":true,"isInterestRate":false,';
        pro +='"InterestRate":4.99,"InterestRateType":"Variable","ComparisonRate":5.26,"Description":"No monthly account keeping fees ; Extra repayments and pay out early without penalty. Clear out your high interest credit cards faster and be debt free sooner. Borrow from $1,000 to $30,000.","Features":"One low fixed up front fee;Extra repayments at no penalty;No account keeping or early termination fees","fees":[{"Product__c":"","Id":"","Fee_Type__c":"Application","Frequency__c":"Setup","Name":"LF-0078","Override_allowed__c":false,"Amount__c":199},{"Product__c":"","Id":"","Fee_Type__c":"Application","Frequency__c":"Setup","Name":"LF-0004","Override_allowed__c":false,"Amount__c":199},{"Product__c":"","Id":"","Fee_Type__c":"Application","Frequency__c":"Setup","Name":"LF-0082","Override_allowed__c":false,"Amount__c":199},{"Product__c":"","Id":"","Fee_Type__c":"Application","Frequency__c":"Setup","Name":"LF-0100","Override_allowed__c":false,"Amount__c":199},{"Product__c":"","Id":"","Fee_Type__c":"Application","Frequency__c":"Setup","Name":"LF-0122","Override_allowed__c":false,"Amount__c":199},{"Product__c":"","Id":"","Fee_Type__c":"Application","Frequency__c":"Setup","Name":"LF-0118","Override_allowed__c":false,"Amount__c":199}],"feesMap":{},"feesList":[{"Product__c":"","Id":"","Fee_Type__c":"Application","Frequency__c":"Setup","Name":"LF-0078","Override_allowed__c":false,"Amount__c":199}]}]';
         productSearch.insertQuote(pro, typeList[0], 'groupName', opp.Id);
         Id loanAccountRTId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName().get('Loan Account').getRecordTypeId();
        Quote quote = [Select Id,Name,Application__c,Loan_Term__c,Purpose__c,Customer_Amount__c,Interest_Rate__c,Product__c from quote where OpportunityId =: opp.Id][0];
        quote.Application__c = true;
        update quote;
        FinServ__FinancialAccount__c finAccount = New FinServ__FinancialAccount__c();
        finAccount.RecordTypeId = loanAccountRTId;
        
        finAccount.FinServ__LoanTermMonths__c = quote.Loan_Term__c;
        finAccount.FinServ__LoanAmount__c = quote.Customer_Amount__c;
        finAccount.FinServ__InterestRate__c = quote.Interest_Rate__c;
        finAccount.FinServ__ProductName__c = quote.Product__c;
        finAccount.Name = quote.Name;
        finAccount.Quote__c = quote.Id;
        finAccount.FinServ__PrimaryOwner__c = ac.Id;
        insert finAccount;
        opp.FinServ__FinancialAccount__c = finAccount.Id;
        
        update opp;
         
        DocuSignRESTUtility.makeCallout(opp.Id);
        DocuSignRESTUtility.voidEnvelope(opp.Id);  
    }
    
    @isTest
    static void sendReferralPDF(){
        Id accRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Referrer (Business)').getRecordTypeId();
        Id conRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Referrer').getRecordTypeId();
        Account acc = new Account(Name='test acc', On_Board_Referral__c = true, RecordTypeId = accRT);
        insert acc;
        Contact con = New Contact(Email = 'test@test.com', LastName ='test', AccountId = acc.Id,RecordTypeId = conRT, Is_Authorised_Signatory__c=true);
        insert con;
        
        DocuSignRESTUtility.createEnvelopeForAccount(acc.Id);
    }
}