public class productSearch {
    @AuraEnabled
    public static String getOppStage(String oppId){
        String oppStage = [SELECT Id,StageName FROM Opportunity WHERE Id =: oppId][0].StageName;
        return oppStage;        
    }
    @AuraEnabled
    public static List<String> getProductType(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Product2.Acceptable_Loan_Purpose__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;        
    }
    @AuraEnabled
    public static List<Product2> getProduct(String prdtype, Decimal amount){
        return [SELECT id,  Interest_Rate__c,Interest_Rate_Override__c,Interest_Rate_From__c,Interest_Rate_Type__c,Actual_Comparison_Rate__c,Brokerage_Amount__c,Brokerage_Override_Allowed__c,Commission_Amount__c,Commission_Override_Allowed__c,Description,Features__c,Redraw__c,Extra_Repayments__c,Extra_Repayments_Details__c,Top_Up__c,Eligibility__c,Lender__c,Name, Max_Loan_Term__c ,Min_Loan_Term__c,Loan_Amounts__c , Acceptable_Loan_Purpose__c,Loan_Term__c,
                ( select id,Fee_Type__c,Frequency__c,Name,Override_allowed__c,Amount__c from Loan_Fees__r)
                FROM Product2
                WHERE Maximum_Loan_Amount__c >=: amount AND Minimum_Loan_Amount__c <=: amount AND Acceptable_Loan_Purpose__c INCLUDES(:prdtype)];
        
    }
    @AuraEnabled
    public static void insertQuote(String prodList, string PType, String groupName, String oppId){
        System.debug(oppId);
        if(String.isBlank(groupName)){
            groupName = 'Unknown';
        }
        List<Quote> quoteGruop = [Select Gruop_Name__c from quote where Gruop_Name__c like :groupName+'-%' AND  OpportunityId=: oppId 
                                  ORDER By Gruop_Name__c DESC LIMIT 1];
        if(quoteGruop.isEmpty()){
            groupName += '-1';
        }else{
            groupName +='-';
            groupName += (Integer.valueOf(quoteGruop.get(0).Gruop_Name__c.substringAfterLast(groupName))+1);
        }
        Map<integer, Quote> quoteMap = new Map<integer, Quote>();
        Map<integer, List<Loan_Fees__c>> feesMap = new Map<integer, List<Loan_Fees__c>>();
        List<quoteWrapper> pro = (List<quoteWrapper>)JSON.deserialize(prodList, List<quoteWrapper>.class);
        System.debug(pro);
        List<Quote> insertQute = new List<Quote>();
        integer i =  0 ;
        for(quoteWrapper var : pro){
            System.debug(var);
            //insertQute.add();
            Quote qt = new Quote();
            qt.Lender__c = var.Lender;
            qt.Max_Loan_Term__c = var.MaxTerm;
            qt.Min_Loan_Term__c = var.MinTerm;
            qt.Interest_Rate__c = var.InterestRate;
            qt.Product__c = var.Id;
            qt.OpportunityId = oppId;
            qt.Purpose__c = PType;
            qt.Gruop_Name__c = groupName;
            qt.Name = var.ProductName;
            qt.Description = var.Description;
            qt.Loan_Term__c = var.LoanTerm;
            qt.Brokerage_Amount__c = var.BrokerageAmount;
            qt.Commission_Amount__c = var.CommissionAmount;
            qt.Interest_Rate_From__c = var.InterestRateFrom;
            qt.Customer_Amount__c = var.LoanAmount;
            qt.Actual_Comparison_Rate__c = var.ComparisonRate;
            quoteMap.put(i, qt);
            feesMap.put(i++,var.feesList);
        }
        insert quoteMap.values();
        System.debug(quoteMap.values());
        List<Loan_Fees__c> fessList = new List<Loan_Fees__c>();
        Id loanfeeRT = Schema.SObjectType.Loan_Fees__c.getRecordTypeInfosByName().get('Quote Loan Fees').getRecordTypeId();
        for(integer var : quoteMap.keySet()){
            id opp = quoteMap.get(var).Id;
            System.debug(opp);
            for(Loan_Fees__c fs : feesMap.get(var)){
                if(fs != null){
                    fs.Product_Loan_Fees__c =fs.Id;
                    fs.id = null;
                    fs.Quote__c = opp;
                    fs.Product__c = null;
                    fs.RecordTypeId = loanfeeRT;
                    fessList.add(fs);
                }
                
            }
        }
        insert fessList;
        Opportunity opp = [SELECT Id,StageName FROM Opportunity WHERE Id =: oppId][0];
        opp.StageName = 'Quote';
        opp.Application_Sections__c = 'Loan Recommendation';
        opp.Current_Application_Sections__c = 'Loan Recommendation';
        update opp;
    }
    public class quoteWrapper{
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public boolean chk;
        @AuraEnabled
        public String Lender;
        @AuraEnabled
        public Decimal MaxTerm;
        @AuraEnabled
        public Decimal MinTerm;
        @AuraEnabled
        public Decimal LoanAmount;
        @AuraEnabled
        public Decimal InterestRate;
        @AuraEnabled
        public String ProductName;
        @AuraEnabled
        public Integer LoanTerm;
        @AuraEnabled
        public String InterestRateType;
        @AuraEnabled
        public Decimal ComparisonRate;
        @AuraEnabled
        public String Description;
        @AuraEnabled
        public String Features;
        @AuraEnabled
        public Boolean InterestRateFrom;
        @AuraEnabled
        public Decimal BrokerageAmount;
        @AuraEnabled
        public Boolean BrokerageOverrideAllowed;
        @AuraEnabled
        public Decimal CommissionAmount;
        @AuraEnabled
        public Boolean CommissionOverrideAllowed;
        @AuraEnabled
        public List<Loan_Fees__c> feesList;
    }
    
}