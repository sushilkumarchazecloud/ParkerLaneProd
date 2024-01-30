public class CFCUController{

    public String username{get;set;}
    public String password{get;set;}
    public Boolean isApplicant2{get;set;}
    
    public FinServ__FinancialGoal__c goals{get;set;}    
    public OpportunityContacts preferences{get;set;}
    public Contact livingExpensesDetails{get;set;}
    public Map<String, Contact> employmentDetails{get;set;}
    public EmploymentStatus applicant1EmpStatus{get;set;}
    public EmploymentStatus applicant2EmpStatus{get;set;}
    public List<FinServ__AssetsAndLiabilities__c> assets{get;set;}
    public List<FinServ__AssetsAndLiabilities__c> liabilities{get;set;}
    public Map<String, List<FinServ__AssetsAndLiabilities__c>> assetsAndLiabilities{get;set;}
    public OpportunityContacts oppContacts{get;set;}
    public Quote selectedQuote{get;set;}
    public String productCode{get;set;}
    public String loanpurpose{get;set;}
    
    
    public CFCUController(){
        productCode = '';
        loanpurpose = '';
        isApplicant2 = false;
        
        System.debug('===> '+System.Userinfo.getUserId());
        System.debug('===> '+InteflowUsers__c.getInstance());
        //InteflowUsers__c cfcuUser = [SELECT Password__c, Username__c, Userid__c FROM InteflowUsers__c where setupownerid =: System.Userinfo.getUserId()][0];
        username = InteflowUsers__c.getValues(System.Userinfo.getUserId()).Username__c;
        password = InteflowUsers__c.getValues(System.Userinfo.getUserId()).Password__c;
        System.debug('==>'+username+'===='+password);
        Id oppId = ApexPages.CurrentPage().getParameters().get('id');
        
        employmentDetails = new Map<String, Contact>();
        
        applicant1EmpStatus = new EmploymentStatus();
        applicant2EmpStatus = new EmploymentStatus();
        setEmploymentStatus(applicant2EmpStatus);
        
        goals = fetchGoals(oppId);
        preferences = fetchPreferences(oppId);
        livingExpensesDetails = fetchLivingExpensesDetails(oppId);
        employmentDetails = fetchEmploymentDetails(oppId);
        
        applicant1EmpStatus.con = employmentDetails.get('applicant1');
        
        if(employmentDetails.get('applicant1').FinServ__Employment__r.size() > 0)
            applicant1EmpStatus.emp = employmentDetails.get('applicant1').FinServ__Employment__r[0];
            
        if(employmentDetails.get('applicant2') != null){
            applicant2EmpStatus.con = employmentDetails.get('applicant2');
            if(employmentDetails.get('applicant2').FinServ__Employment__r.size() > 0)
                applicant2EmpStatus.emp = employmentDetails.get('applicant2').FinServ__Employment__r[0];
        }
        
        assetsAndLiabilities = fetchAssetsAndLiabilities(oppId);
        assets = assetsAndLiabilities.get('Asset');
        liabilities = assetsAndLiabilities.get('Liability');
        oppContacts = fetchOppContacts(oppId);
        selectedQuote = fetchSelectedQuote(oppId);
        setApplicantsInfo();
        
        applicant1EmpStatus = setEmployment(applicant1EmpStatus);
        applicant2EmpStatus = setEmployment(applicant2EmpStatus);
        
        if(assets != null)
            assets = setAssetValues(assets);
            
        if(liabilities != null)
            liabilities = setLiabilitiesValues(liabilities);
        
    }
    
    public static String sendApplication(String oppId){
        String cfcuXml = '';
        Opportunity opp = [SELECT Id, Number_of_applicants__c,StageName FROM Opportunity WHERE Id =: oppId limit 1];
        
        if(opp.Number_of_applicants__c == 2){
            PageReference aPage = Page.CFCUXmlData;
            aPage.getParameters().put('id',oppId);
            aPage.setRedirect(true);
            if(Test.isRunningTest()) {
                cfcuXml = '<?xml version="1.0" encoding="utf-8"?> <GetMethod xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"> <Extend /> <Successful>true</Successful> <CustAllowed> <CustomerAllow> <SampleData /> <CurrentDate>10/14/2015</CurrentDate> <DocID>296</DocID> <DType>BP</DType> <Allows> <ALLOW> <BID /> <sampleDesc>exist1</sampleDesc> <sampleID>123456</sampleID> <DocID>111</DocID> <State /> </ALLOW> <ALLOW> <BID /> <sampleDesc>exist1</sampleDesc> <sampleID>123456</sampleID> <DocID>222</DocID> <State /> </ALLOW> <ALLOW> <BID /> <sampleDesc>exist1</sampleDesc> <sampleID>123454</sampleID> <DocID>333</DocID> <State /> </ALLOW> </Allows> </CustomerAllow> </CustAllowed> </GetMethod>';
            }else{
                cfcuXml = aPage.getContent().toString();
            }
        }
        if(opp.Number_of_applicants__c == 1){
            PageReference aPage = Page.CFCUXmlDataAppOne;
            aPage.getParameters().put('id',oppId);
            aPage.setRedirect(true);
            if(Test.isRunningTest()) {
                cfcuXml = '<?xml version="1.0" encoding="utf-8"?> <GetMethod xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"> <Extend /> <Successful>true</Successful> <CustAllowed> <CustomerAllow> <SampleData /> <CurrentDate>10/14/2015</CurrentDate> <DocID>296</DocID> <DType>BP</DType> <Allows> <ALLOW> <BID /> <sampleDesc>exist1</sampleDesc> <sampleID>123456</sampleID> <DocID>111</DocID> <State /> </ALLOW> <ALLOW> <BID /> <sampleDesc>exist1</sampleDesc> <sampleID>123456</sampleID> <DocID>222</DocID> <State /> </ALLOW> <ALLOW> <BID /> <sampleDesc>exist1</sampleDesc> <sampleID>123454</sampleID> <DocID>333</DocID> <State /> </ALLOW> </Allows> </CustomerAllow> </CustAllowed> </GetMethod>';
            }else{
                cfcuXml = aPage.getContent().toString();
            }
        }
        
        Dom.Document doc = new Dom.Document();
        doc.load(cfcuXml);
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        
        req.setEndpoint('https://www.inteflow.com.au/Inteport/DecisionGateway.asmx');
        req.setMethod('POST');
        req.setBody(cfcuXml);
        req.setHeader('Host', 'www.inteflow.com.au');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        req.setHeader('Content-Length', '100000');
        req.setHeader('SOAPAction', 'http://decisionintellect.com/inteport/SubmitXMLRequest');
        //req.setCompressed(true); // otherwise we hit a limit of 32000

        try {
            if(!Test.isRunningTest()){
                res = http.send(req);
                System.debug(LoggingLevel.Info,'====> '+res.getBody());
                System.debug(res.toString());
                String xmlString = res.getBody();
                if(xmlString.contains('Error')){
                    return 'Error';
                }else{
                    opp.StageName = 'Application';
                    update opp;
                    return 'Success';
                }
            }    
        } catch(System.CalloutException e) {
            System.debug(res.getBody());
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        }
        
        return null;
    }
    
    public void setApplicantsInfo(){
        if(oppContacts.contact1.Driver_s_licence_state_Territory__c != null){
            if(stateTypeMap().get(oppContacts.contact1.Driver_s_licence_state_Territory__c.trim()) != null){
                oppContacts.contact1.Driver_s_licence_state_Territory__c = stateTypeMap().get(oppContacts.contact1.Driver_s_licence_state_Territory__c.trim());
            }
        }
        
        if(oppContacts.contact1.Street_Type__c != null){
            if(streetTypeMap().get(oppContacts.contact1.Street_Type__c.trim()) != null){
                oppContacts.contact1.Street_Type__c = streetTypeMap().get(oppContacts.contact1.Street_Type__c.trim());
            }
        }else{
            oppContacts.contact1.Street_Type__c = 'St';
        }
        
        if(oppContacts.contact1.State__c != null){
            if(stateTypeMap().get(oppContacts.contact1.State__c.trim()) != null){
                oppContacts.contact1.State__c = stateTypeMap().get(oppContacts.contact1.State__c.trim());
            }
        }
        
        if(oppContacts.contact1.Street_Type_1__c != null){
            if(streetTypeMap().get(oppContacts.contact1.Street_Type_1__c.trim()) != null){
                oppContacts.contact1.Street_Type_1__c = streetTypeMap().get(oppContacts.contact1.Street_Type_1__c.trim());
            }
        }else{
            oppContacts.contact1.Street_Type_1__c = 'St';
        }
        
        if(oppContacts.contact1.State_1__c != null){
            if(stateTypeMap().get(oppContacts.contact1.State_1__c.trim()) != null){
                oppContacts.contact1.State_1__c = stateTypeMap().get(oppContacts.contact1.State_1__c.trim());
            }
        }
        
        if(oppContacts.contact1.Living_Situation__c == 'Own home outright'){
            oppContacts.contact1.Living_Situation__c = 'Owner';
        }
        if(oppContacts.contact1.Living_Situation__c == 'Own home with mortgage'){
            oppContacts.contact1.Living_Situation__c = 'Buyer';
        }
        if(oppContacts.contact1.Living_Situation__c == 'Renting'){
            oppContacts.contact1.Living_Situation__c = 'Renter';
        }
        if(oppContacts.contact1.Living_Situation__c == 'Boarding with parents'){
            oppContacts.contact1.Living_Situation__c = 'Living with Parents';
        }
        if(oppContacts.contact1.Living_Situation__c == 'Boarding with other'){
            oppContacts.contact1.Living_Situation__c = 'Boarder';
        }
        if(oppContacts.contact1.Living_Situation__c == 'Supplied by employer'){
            oppContacts.contact1.Living_Situation__c = 'Employer';
        }
        
        if(oppContacts.contact1.Medicare_Card_Colour__c == 'Green'){
            oppContacts.contact1.Medicare_Card_Colour__c = 'G';
        }
        if(oppContacts.contact1.Medicare_Card_Colour__c == 'Blue'){
            oppContacts.contact1.Medicare_Card_Colour__c = 'B';
        }
        if(oppContacts.contact1.Medicare_Card_Colour__c == 'Yellow'){
            oppContacts.contact1.Medicare_Card_Colour__c = 'Y';
        }
        
        if(oppContacts.contact1.Citizenship_Status__c == 'Australian Citizen'){
            oppContacts.contact1.Citizenship_Status__c = 'Citizen';
        }
        if(oppContacts.contact1.Citizenship_Status__c == 'Permanent Resident'){
            oppContacts.contact1.Citizenship_Status__c = 'PR';
        }
        if(oppContacts.contact1.Citizenship_Status__c == 'NZ Citizen'){
            oppContacts.contact1.Citizenship_Status__c = 'Other';
        }
        
        if(isApplicant2){
            if(oppContacts.contact2.Citizenship_Status__c == 'Australian Citizen'){
                oppContacts.contact2.Citizenship_Status__c = 'Citizen';
            }
            if(oppContacts.contact2.Citizenship_Status__c == 'Permanent Resident'){
                oppContacts.contact2.Citizenship_Status__c = 'PR';
            }
            if(oppContacts.contact2.Citizenship_Status__c == 'NZ Citizen'){
                oppContacts.contact2.Citizenship_Status__c = 'Other';
            }
            
            if(oppContacts.contact2.Medicare_Card_Colour__c == 'Green'){
                oppContacts.contact2.Medicare_Card_Colour__c = 'G';
            }
            if(oppContacts.contact2.Medicare_Card_Colour__c == 'Blue'){
                oppContacts.contact2.Medicare_Card_Colour__c = 'B';
            }
            if(oppContacts.contact2.Medicare_Card_Colour__c == 'Yellow'){
                oppContacts.contact2.Medicare_Card_Colour__c = 'Y';
            }
            
            if(oppContacts.contact2.Driver_s_licence_state_Territory__c != null){
                if(stateTypeMap().get(oppContacts.contact2.Driver_s_licence_state_Territory__c.trim()) != null){
                    oppContacts.contact2.Driver_s_licence_state_Territory__c = stateTypeMap().get(oppContacts.contact2.Driver_s_licence_state_Territory__c.trim());
                }
            }
                
            if(oppContacts.contact2.Street_Type__c != null){
                if(streetTypeMap().get(oppContacts.contact2.Street_Type__c.trim()) != null){
                    oppContacts.contact2.Street_Type__c = streetTypeMap().get(oppContacts.contact2.Street_Type__c.trim());
                }
            }else{
                oppContacts.contact2.Street_Type__c = '';
            }
            
            if(oppContacts.contact2.State__c != null){
                if(stateTypeMap().get(oppContacts.contact2.State__c.trim()) != null){
                    oppContacts.contact2.State__c = stateTypeMap().get(oppContacts.contact2.State__c.trim());
                }
            }
            
            if(oppContacts.contact2.Street_Type_1__c != null){
                if(streetTypeMap().get(oppContacts.contact2.Street_Type_1__c.trim()) != null){
                    oppContacts.contact2.Street_Type_1__c = streetTypeMap().get(oppContacts.contact2.Street_Type_1__c.trim());
                }
            }else{
                oppContacts.contact2.Street_Type_1__c = 'St';
            }
            
            if(oppContacts.contact2.State_1__c != null){
                if(stateTypeMap().get(oppContacts.contact2.State_1__c.trim()) != null){
                    oppContacts.contact2.State_1__c = stateTypeMap().get(oppContacts.contact2.State_1__c.trim());
                }
            }
            
            if(oppContacts.contact2.Living_Situation__c == 'Own home outright'){
                oppContacts.contact2.Living_Situation__c = 'Owner';
            }
            if(oppContacts.contact2.Living_Situation__c == 'Own home with mortgage'){
                oppContacts.contact2.Living_Situation__c = 'Buyer';
            }
            if(oppContacts.contact2.Living_Situation__c == 'Renting'){
                oppContacts.contact2.Living_Situation__c = 'Renter';
            }
            if(oppContacts.contact2.Living_Situation__c == 'Boarding with parents'){
                oppContacts.contact2.Living_Situation__c = 'Living with Parents';
            }
            if(oppContacts.contact2.Living_Situation__c == 'Boarding with other'){
                oppContacts.contact2.Living_Situation__c = 'Boarder';
            }
            if(oppContacts.contact2.Living_Situation__c == 'Supplied by employer'){
                oppContacts.contact2.Living_Situation__c = 'Employer';
            }
        }
    }
    
    public EmploymentStatus setEmployment(EmploymentStatus applicant1EmpStatus){
        
        if(applicant1EmpStatus.con.FinServ__Occupation__c != null){
                
            if(empStatusSet().contains(applicant1EmpStatus.con.FinServ__Occupation__c)){
                applicant1EmpStatus.emp.FinServ__EmploymentStatus__c = 'Part-time';
            }else{
                applicant1EmpStatus = setEmploymentStatus(applicant1EmpStatus);
            }
            
            if(empOccMap().get(applicant1EmpStatus.con.FinServ__Occupation__c) != null)
                applicant1EmpStatus.con.FinServ__Occupation__c = empOccMap().get(applicant1EmpStatus.con.FinServ__Occupation__c);
            
        }
        
        if(applicant1EmpStatus.emp.Occupation_1_Previous__c != null){
                
            if(empStatusSet().contains(applicant1EmpStatus.emp.Occupation_1_Previous__c)){
                applicant1EmpStatus.emp.Employment_Status_1_Previous__c = 'Part-time';
            }else{
                applicant1EmpStatus = setEmploymentStatus(applicant1EmpStatus);
            }
            if(empOccMap().get(applicant1EmpStatus.emp.Occupation_1_Previous__c) != null)
                applicant1EmpStatus.emp.Occupation_1_Previous__c = empOccMap().get(applicant1EmpStatus.emp.Occupation_1_Previous__c);
                
        }
        
        if(isApplicant2){
            if(applicant2EmpStatus.con.FinServ__Occupation__c != null){
                    
                if(empStatusSet().contains(applicant2EmpStatus.con.FinServ__Occupation__c)){
                    applicant2EmpStatus.emp.FinServ__EmploymentStatus__c = 'Part-time';
                }else{
                    applicant2EmpStatus = setEmploymentStatus(applicant2EmpStatus);
                }
                
                if(empOccMap().get(applicant2EmpStatus.con.FinServ__Occupation__c) != null)
                    applicant2EmpStatus.con.FinServ__Occupation__c = empOccMap().get(applicant2EmpStatus.con.FinServ__Occupation__c);
                    
            }
            
            if(applicant2EmpStatus.emp.Occupation_1_Previous__c != null){
                    
                if(empStatusSet().contains(applicant2EmpStatus.emp.Occupation_1_Previous__c)){
                    applicant2EmpStatus.emp.Employment_Status_1_Previous__c = 'Part-time';
                }else{
                    applicant2EmpStatus = setEmploymentStatus(applicant2EmpStatus);
                }
                
                if(empOccMap().get(applicant2EmpStatus.emp.Occupation_1_Previous__c) != null)
                    applicant2EmpStatus.emp.Occupation_1_Previous__c = empOccMap().get(applicant2EmpStatus.emp.Occupation_1_Previous__c);
                
            }
        }
        
        return applicant1EmpStatus;
    }
    
    public EmploymentStatus setEmploymentStatus(EmploymentStatus applicant1EmpStatus){
        
        if(applicant1EmpStatus.emp.FinServ__EmploymentStatus__c != null){
            if(empStatusMap().get(applicant1EmpStatus.emp.FinServ__EmploymentStatus__c) != null)        
                applicant1EmpStatus.emp.FinServ__EmploymentStatus__c = empStatusMap().get(applicant1EmpStatus.emp.FinServ__EmploymentStatus__c);
            
        }
        if(applicant1EmpStatus.emp.Employment_Status_1_Previous__c != null){
            if(empStatusMap().get(applicant1EmpStatus.emp.Employment_Status_1_Previous__c) != null)
                applicant1EmpStatus.emp.Employment_Status_1_Previous__c = empStatusMap().get(applicant1EmpStatus.emp.Employment_Status_1_Previous__c);
        }
        
        if(isApplicant2){
            if(applicant2EmpStatus.emp.FinServ__EmploymentStatus__c != null){
                if(empStatusMap().get(applicant2EmpStatus.emp.FinServ__EmploymentStatus__c) != null)        
                    applicant2EmpStatus.emp.FinServ__EmploymentStatus__c = empStatusMap().get(applicant2EmpStatus.emp.FinServ__EmploymentStatus__c);
                
            }
            if(applicant2EmpStatus.emp.Employment_Status_1_Previous__c != null){
                if(empStatusMap().get(applicant2EmpStatus.emp.Employment_Status_1_Previous__c) != null)
                    applicant2EmpStatus.emp.Employment_Status_1_Previous__c = empStatusMap().get(applicant2EmpStatus.emp.Employment_Status_1_Previous__c);
            }
        }
        
        return applicant1EmpStatus;
    }
    
    public List<FinServ__AssetsAndLiabilities__c> setAssetValues(List<FinServ__AssetsAndLiabilities__c> assets){
        
        for(FinServ__AssetsAndLiabilities__c asst : assets){
            if(asst.FinServ__AssetsAndLiabilitiesType__c != null){
                if(assetsMap().get(asst.FinServ__AssetsAndLiabilitiesType__c) != null)
                    asst.FinServ__AssetsAndLiabilitiesType__c = assetsMap().get(asst.FinServ__AssetsAndLiabilitiesType__c);
            }
        }
        
        return assets;
    }
    
    public List<FinServ__AssetsAndLiabilities__c> setLiabilitiesValues(List<FinServ__AssetsAndLiabilities__c> liabilities){
        
        for(FinServ__AssetsAndLiabilities__c lia : liabilities){
            if(lia.FinServ__AssetsAndLiabilitiesType__c != null){
                if(liabilitiesMap().get(lia.FinServ__AssetsAndLiabilitiesType__c) != null)
                    lia.FinServ__AssetsAndLiabilitiesType__c = liabilitiesMap().get(lia.FinServ__AssetsAndLiabilitiesType__c);
            }
            if(lia.Repayment_Frequency__c == 'Weekly'){
                if(lia.Monthly_Repayment__c != null)
                    lia.Monthly_Repayment__c = lia.Monthly_Repayment__c*52/12;
                else
                    lia.Monthly_Repayment__c = 0.0;
            }
            if(lia.Repayment_Frequency__c == 'Fortnightly'){
                if(lia.Monthly_Repayment__c != null)
                    lia.Monthly_Repayment__c = lia.Monthly_Repayment__c*26/12;
                else
                    lia.Monthly_Repayment__c = 0.0;
            }
            if(lia.Repayment_Frequency__c == 'Annually'){
                if(lia.Monthly_Repayment__c != null)
                    lia.Monthly_Repayment__c = lia.Monthly_Repayment__c*1/12;
                else
                    lia.Monthly_Repayment__c = 0.0;
            }
            if(lia.FinServ__AssetsAndLiabilitiesType__c == 'CreditCard'){
                if(lia.Monthly_Repayment__c != null){
                    if(lia.Limit__c != null)
                        lia.Monthly_Repayment__c = lia.Limit__c*3.8/100;
                }else
                    lia.Monthly_Repayment__c = 0.0;
            }
            
        }
        
        return liabilities;
    }
    
    public Quote fetchSelectedQuote(Id recordId){
        try{
            Quote qt = [SELECT Id, Customer_Amount__c, Loan_Term__c, Monthly_Repayment__c, Purpose__c,  Interest_Rate__c,
                        Lead__c, Lead__r.FirstName, Lead__r.LastName, Lead__r.Email, Shared_Message__c, 
                        Opportunity.Applicant_1__r.PersonContactId, Product__c, Product__r.Name
                        FROM Quote WHERE OpportunityId =: recordId AND Application__c = true LIMIT 1];
            
            //productCode = 'PRKLN';           
            if(qt.Product__r.Name.contains('1-10')){
                String productName = qt.Product__r.Name.remove(qt.Product__r.Name.substringAfter('('));
                productName = productName.remove('(');
                qt.Product__r.Name = 'Green Loan 3.99% (via Partner)';
                productCode = 'GLPRT3.99';
            }
            /*if(qt.Product__r.Name.contains('6-10')){
                String productName = qt.Product__r.Name.remove(qt.Product__r.Name.substringAfter('('));
                productName = productName.remove('(');
                qt.Product__r.Name = 'Green Loan (via Parker Lane, over 5 years)';
                productCode = 'PRKLNGRLN10Y';
            }*/
            
            
            if(qt.Purpose__c == 'Solar'){
                loanpurpose = 'Solar Products';
            }
            if(qt.Purpose__c == 'Home Improvement'){
                loanpurpose = 'Home Improvements';
            }
            if(qt.Purpose__c == 'Debt Consolidation'){
                loanpurpose = 'Debt Consolidation';
            }
            
            if(qt.Purpose__c == 'Solar'){
                qt.Purpose__c = 'SolarProducts';
            }
            if(qt.Purpose__c == 'Home Improvement'){
                qt.Purpose__c = 'HomeImprovements';
            }
            if(qt.Purpose__c == 'Debt Consolidation'){
                qt.Purpose__c = 'DebtConsolidation';
            }
            
            qt.Loan_Term__c  = qt.Loan_Term__c/12;
            return qt;
        }catch(exception e){
            return null;
        }
    }
    
    public FinServ__FinancialGoal__c fetchGoals(Id oppId){
        List<FinServ__FinancialGoal__c> goalList = 
            [SELECT Id, Control_of_your_finances__c, Find_ways_to_save_money__c, Plan_to_achieve_your_financial_goals__c,
             Plan_to_repay_debt_quickly__c, Rates_of_interest_you_currently_pay__c, Take_action_to_save_money__c, Track_and_manage_your_finances__c,
             What_is_your_stage_in_life__c, Which_financial_priorities_relevant_you__c, Which_life_events_are_relevant_to_you__c,
             Why_did_you_chose_Parker_Lane__c, Is_Not_Applicable_For_Life_Event__c, Is_Not_Applicable_For_financial_priority__c
             FROM FinServ__FinancialGoal__c 
             WHERE FinServ__PrimaryOwner__c in (SELECT Applicant_1__c FROM Opportunity WHERE Id =: oppId)];

        if(goalList.isEmpty()){
            return new FinServ__FinancialGoal__c();
        }
        return goalList[0];
    }
    
    public OpportunityContacts fetchPreferences(Id recordId){

        if (String.isBlank(recordId)) return null;
        
        OpportunityContacts oppCons = new OpportunityContacts();
        
        Opportunity opp = new Opportunity();
        try{
            opp = [SELECT Id, Number_of_applicants__c, Application_Sections__c, Current_Application_Sections__c, AccountId,
                   Applicant_1__c, Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId,
                   Primary_reason_for_installing_solar__c, Type_of_interest_rate__c, Preferred_repayment_frequency__c, 
                   Expect_to_remain_in_the_credit_contract__c, Any_lenders_you_don_t_wish_to_deal_with__c, 
                   Have_adequate_Life_Insurance__c, Have_adequate_Debt_Protection_Insurance__c, Have_adequate_Income_Protection__c,
                   Have_adequate_insurance__c, Would_you_like_us_to_arrange_a_meeting__c
                   FROM Opportunity WHERE Id =: recordId limit 1];
            oppCons.opp = opp;
            set<Id> conIds = new Set<Id>();
            if(String.isNotBlank(opp.Applicant_1__c)){
                conIds.add(opp.Applicant_1__r.PersonContactId);
            }
            if(String.isNotBlank(opp.Applicant_2__c)){
                conIds.add(opp.Applicant_2__r.PersonContactId);
            }
            Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Rate_current_Job_Security__c, Judgements_or_legal_proceedings_recorded__c, 
                                                                 Description_Judgement_legal_proceeding__c, Credit_commitments_up_to_date__c, 
                                                                 Description_Credit_commitment_up_to_date__c, Your_income_in_the_next_6_12_months__c, 
                                                                 Decription_income_in_next_6_12_months__c, Materially_in_the_next_6_12_months__c, 
                                                                 Description_materially_next_6_12_months__c, Income_expenses_in_the_next_6_12_months__c, 
                                                                 Description_Income_expenses_6_12_months__c, Email
                                                                 FROM Contact WHERE Id in: conIds]);
            
            oppCons.contact1 = contactsMap.get(opp.Applicant_1__r.PersonContactId);
            oppCons.contact2 = contactsMap.get(opp.Applicant_2__r.PersonContactId);
            
            return oppCons;
        }catch(exception e){
            return null;
        }
    }
    
    public Contact fetchLivingExpensesDetails(Id recordId){
        Opportunity opp = [SELECT Applicant_1__r.PersonContactId FROM Opportunity WHERE Id =: recordId];
        List<Contact> conList = 
            [SELECT FinServ__CurrentEmployer__c, FinServ__Occupation__c, Home_Loan_repayment__c, Investment_Property_Loan_repayment__c,
             Credit_Card_payment_3_of_total_limit__c, Other_loans_and_or_debt_commitments__c, Rental_or_Board_paid__c, Utilities__c,
             Connections_Phone_Mobile_Internet_C__c, Education_ChildCare_SchoolFees_Uniform__c, Food_Groceries_Meat_Fruit_Vegetabl__c,Clothing_and_personal_care__c,
             Transport_Public_Petrol_Registration__c, Medical_Private_Health_Insurance_Ong__c, Insurances_Home_Personal_Voluntary__c,Investment_property_utilities__c,
             Household_Purchases_and_Maintenance__c, Entertainment_Dining_Out_Movies_Gift__c, Sports_Hobbies_and_Memberships__c,Education_public_and_private__c,
             Gambling_Betting_and_Lottery__c, Other_Regular_Expenditure__c, Total_Living_Expenses__c, Email,Clothing_Recreational_Entertainment__c,
             Insurance_Medical_Health__c,Property_including_Rates_Utilities_Manag__c,CFCU_Other__c,Personal_Insurances_life_and_income_pro__c 
             FROM Contact 
             WHERE Id =: opp.Applicant_1__r.PersonContactId];
        return conList[0];
    }
    
    public Map<String, Contact> fetchEmploymentDetails(Id recordId){
        Opportunity opp = [SELECT Applicant_1__c, Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                           FROM Opportunity WHERE Id =: recordId limit 1];
        Set<Id> conIds = new Set<Id>();
        if(opp.Applicant_1__c != null){
            conIds.add(opp.Applicant_1__r.PersonContactId);
        }
        if(opp.Applicant_2__c != null){
            conIds.add(opp.Applicant_2__r.PersonContactId);
        }
        Map<Id, Contact> conEmploymentMap =new Map<Id, Contact>([SELECT Name, FinServ__CurrentEmployer__c, 
              FinServ__Occupation__c, FinServ__MaritalStatus__c, Email,
             (SELECT Id, Name, FinServ__Occupation__c, FinServ__AnnualIncome__c, FinServ__EmployerAddress__c, 
              FinServ__EmployerPhoneNumber__c, FinServ__EmploymentStatus__c, Income_Frequency__c, Months__c,
              Years__c, Self_Employed_Type__c, Employment_Status_1_Previous__c, Employer_Name_1_Previous__c,
              Years_1_Previous__c, Months_1_Previous__c, Annual_Income_1_Previous__c, Occupation_1_Previous__c, 
              Employment_Status_2_Previous__c, Employer_Name_2_Previous__c,Years_2_Previous__c, Months_2_Previous__c, 
              Annual_Income_2_Previous__c, Occupation_2_Previous__c,Is_Find_Address__c, Is_Find_Address_1__c, Is_Find_Address_2__c, 
              Unit_Number__c, Unit_Number_1__c, Unit_Number_2__c, Street_Number__c, Street_Number_1__c, Street_Number_2__c, 
              Street__c, Street_1__c, Street_2__c, Street_Type__c, Street_Type_1__c, Street_Type_2__c, Total_Income_from_Employment__c,
              Suburb__c, Suburb_1__c, Suburb_2__c, State__c, State_1__c, State_2__c, Postal_Code__c, Postal_Code_1__c, Postal_Code_2__c, 
              Country__c, Country_1__c, Country_2__c, Ownership_Share__c, ABN__c, Date_ABN_registered__c, Are_you_registered_for_GST__c, 
              Last_year_net_profit__c, Previous_year_net_profit__c, Pay_yourself_salary__c, Annual_salary_before_tax__c, 
              Does_your_spouse_earn_an_income__c, spouse_approximate_annual_income__c, Description__c, Address_1_Previous__c,
              Address_2_Previous__c, Regularly_work_Overtime__c, Work_Overtime_amount__c, Work_Overtime_Frequency__c, 
              Regularly_receive_Commission_or_Bonus__c, Commission_or_Bonus_amount__c, Commission_or_Bonus_Frequency__c,
              Regularly_Receive_Allowance__c, Allowance_Amount__c, Allowance_Frequency__c, Provide_a_Company_Car__c,Job_Title__c 
              FROM FinServ__Employment__r WHERE Is_Primary__c = true LIMIT 1)
              FROM Contact WHERE Id in :conIds]);
        Map<String, Contact> conMap = new Map<String, Contact>();
        if(opp.Applicant_1__c != null){
            conMap.put('applicant1', conEmploymentMap.get(opp.Applicant_1__r.PersonContactId));
        }
        if(opp.Applicant_2__c != null){
            conMap.put('applicant2', conEmploymentMap.get(opp.Applicant_2__r.PersonContactId));
        }

        return conMap;
    }
    
    public Map<String, List<FinServ__AssetsAndLiabilities__c>> fetchAssetsAndLiabilities(Id recordId){
        List<FinServ__AssetsAndLiabilities__c> assetsAndLiabilitiesList = 
            [SELECT FinServ__Amount__c, FinServ__Description__c, RecordType.Name, Limit__c, Monthly_Repayment__c,
             FinServ__Ownership__c, FinServ__AssetsAndLiabilitiesType__c, Address__c, Interest_Rate__c,
             Approximate_Remaining_Term_Years__c, Bank_Type__c, Country__c, Institution__c, Repayment_Type__c,
             Is_Address_Same__c, Is_Find_Address__c, Make_Model__c, Payment_Frequency__c, Postal_Code__c,
             Property_Managed_By__c, Rate_Expires_in_Months__c, Rate_Expires_in_Years__c, Rate_Type__c, Rental_Amount__c,
             Rental_Frequency__c, Repayment_Frequency__c, State__c, Street__c, Street_Number__c, Street_Type__c, Suburb__c,
             Type_of_Fund__c, Type_of_Tenancy__c, Unit_Number__c, Year__c, Post_Payment_Frequency__c, Post_tax_lease_Payment__c,
             Pre_Payment_Frequency__c, Pre_tax_lease_Payment__c, Ownership_Share__c, Other_Ownership_Share__c, Value__c
             FROM FinServ__AssetsAndLiabilities__c 
             WHERE FinServ__PrimaryOwner__c in (SELECT Applicant_1__c FROM Opportunity WHERE Id =: recordId)];
        Map<String, List<FinServ__AssetsAndLiabilities__c>> assetsAndLiabilitiesMap = new Map<String, List<FinServ__AssetsAndLiabilities__c>>();
        for(FinServ__AssetsAndLiabilities__c assLiab : assetsAndLiabilitiesList){
            List<FinServ__AssetsAndLiabilities__c>assLiabList = assetsAndLiabilitiesMap.get(assLiab.RecordType.Name);
            if(assLiabList == Null){
                assLiabList = new List<FinServ__AssetsAndLiabilities__c>();
            }
            assLiabList.add(assLiab);
            assetsAndLiabilitiesMap.put(assLiab.RecordType.Name, assLiabList);
        }
        return assetsAndLiabilitiesMap;
    }
    
    public OpportunityContacts fetchOppContacts(Id recordId){
        if (String.isBlank(recordId)) return null;
        List<Contact> app1Children = new List<Contact>();
        List<Contact> app2Children = new List<Contact>();
        
        OpportunityContacts oppCons = new OpportunityContacts();
        Opportunity opp = new Opportunity();
        try{
            opp = [SELECT Id, Number_of_applicants__c, Application_Sections__c, Current_Application_Sections__c,
                   Applicant_1__c, Applicant_1__r.PersonContactId, Applicant_2__c, Applicant_2__r.PersonContactId,
                   AccountId, Account.RecordType.Name, FinServ__Household__c, Relationship_to_Applicant_2__c
                   FROM Opportunity WHERE Id =: recordId limit 1];
            oppCons.opp = opp;
            set<Id> conIds = new Set<Id>();
            if(String.isNotBlank(opp.Applicant_1__c)){
                conIds.add(opp.Applicant_1__r.PersonContactId);
            }
            if(String.isNotBlank(opp.Applicant_2__c)){
                conIds.add(opp.Applicant_2__r.PersonContactId);
                isApplicant2 = true;
            }
            
            Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT FirstName, LastName, MiddleName, Email, Phone, Title, Birthdate, 
                                                                 OtherPhone, FinServ__Gender__c, FinServ__MaritalStatus__c, Government_ID__c,
                                                                 Govt_Id_Number__c, Living_Situation__c, FinServ__NumberOfChildren__c,
                                                                 Security_Answer__c, Security_Question__c, Driver_s_licence_state_Territory__c,
                                                                 Dont_have_drivers_licence__c, FinServ__PrimaryAddressIsOther__c, isFindPostalAdd__c,
                                                                 Postal_address_is_PO_or_GPO_box__c, Months__c, Months_1__c, Months_2__c, Year__c, 
                                                                 Year_1__c, Year_2__c, Unit_Number__c, Unit_Number_1__c, Unit_Number_2__c,
                                                                 Suburb__c, Suburb_1__c, Suburb_2__c, Street_Type__c, Street_Type_1__c, Street_Type_2__c,
                                                                 Street_Number__c, Street_Number_1__c, Street_Number_2__c, Street__c, Street_1__c, 
                                                                 Street_2__c, State__c, State_1__c, State_2__c, Residential_Address__c, Residential_Address_1__c,
                                                                 Residential_Address_2__c, Postal_Suburb__c, Postal_State__c, Postal_Postal_Code__c, 
                                                                 Postal_PO_Box__c, Postal_Number__c, Postal_Country__c, Postal_Code__c, Postal_Code_1__c, 
                                                                 Postal_Code_2__c, Postal_Box_Type__c, Postal_Address__c, Is_Find_Address__c, Is_Find_Address_1__c, 
                                                                 Is_Find_Address_2__c, Is_Address_Same__c, FinServ__CountryOfResidence__c, Country_1__c, Country_2__c,
                                                                 Rental_Amount__c, Rental_Frequency__c, Rental_Managed_via__c, Citizenship_Status__c, Visa_Details__c,
                                                                 First_Name_Child_1__c, First_Name_Child_2__c, First_Name_Child_3__c, First_Name_Child_4__c, First_Name_Child_5__c,
                                                                 Age_Child_1__c, Age_Child_2__c, Age_Child_3__c, Age_Child_4__c, Age_Child_5__c,Medicare_Card_Colour__c,
                                                                 Medicare_Expiry_Date__c,Medicare_Number__c
                                                                 FROM Contact WHERE Id in: conIds]);
            
            oppCons.contact1 = contactsMap.get(opp.Applicant_1__r.PersonContactId);
            oppCons.contact2 = contactsMap.get(opp.Applicant_2__r.PersonContactId);
            
            for(Contact con : [SELECT Id, LastName, Account.Dependent_parent__c,Child_Age__c FROM Contact WHERE  Account.Dependent_parent__r.personContactId in: conIds]){
                if(String.isNotBlank(con.Account.Dependent_parent__c)){
                    if(String.isNotBlank(opp.Applicant_1__c) && opp.Applicant_1__c.equals(con.Account.Dependent_parent__c)){
                        app1Children.add(con);
                    }
                    if(String.isNotBlank(opp.Applicant_2__c) && opp.Applicant_2__c.equals(con.Account.Dependent_parent__c)){
                        app2Children.add(con);
                    }
                }
            }
            oppCons.app1Children = app1Children;
            oppCons.app2Children = app2Children;
            
            oppCons.app1NoChild = app1Children.size();
            oppCons.app2NoChild = app2Children.size();
            
            return oppCons;
        }catch(exception e){
            return null;
        }
    }
    
    public Set<String> empStatusSet(){
        
        Set<String> empStatus = new Set<String>();
        empStatus.add('Unemployed');
        empStatus.add('Student');
        empStatus.add('Government Benefits');
        empStatus.add('Carer');
        empStatus.add('Self Funded Retired');
        empStatus.add('Retired');
        empStatus.add('Home Duties');
        
        return empStatus;
    }
    
    public Map<String,String> empOccMap(){
        Map<String,String> empOccType = new Map<String,String>();
        empOccType.put('Government Benefits','Benefit');
        empOccType.put('Carer','Benefit');
        empOccType.put('Self Employed','Other');
        empOccType.put('Self Funded Retired','Retired');
        empOccType.put('Home Duties','Home');
        empOccType.put('Workcover / Workers Compensation','Other');
        empOccType.put('Technical','Professional');
        empOccType.put('Advertising','Administration');
        empOccType.put('Agri/Horticulture','Other');
        empOccType.put('Armed Services','Other');
        empOccType.put('Banking/Finance','Other');
        empOccType.put('Civil Services','Other');
        empOccType.put('Cleaning/Laundry','Other');
        empOccType.put('Construction','Other');
        empOccType.put('Education','Other');
        empOccType.put('Emergency Services','Other');
        empOccType.put('Hospital','Other');
        empOccType.put('Hotel','Other');
        empOccType.put('Industry Services','Other');
        empOccType.put('Insurance','Other');
        empOccType.put('IT','Professional');
        empOccType.put('Leisure/Enttainmnt','Other');
        empOccType.put('Menufaturing','Other');
        empOccType.put('Media','Other');
        empOccType.put('Mining','Other');
        empOccType.put('Other Category','Other');
        empOccType.put('Property/Business','Other');
        empOccType.put('Restaurant','Other');
        empOccType.put('Retail/Wholesale','Other');
        empOccType.put('Sciences','Other');
        empOccType.put('Transport','Other');
        
        return empOccType;
    }
    
    public Map<String,String> empStatusMap(){
        Map<String,String> empType = new Map<String,String>();
        empType.put('Full time permanent','Full-time');
        empType.put('Self Employed / Contractor','Self-Employed');
        empType.put('Casual / Temporary','Casual');
        empType.put('Part time permanent','Part-time');
        return empType;
    }
    
    public Map<String,String> stateTypeMap(){
        Map<String,String> stateType = new Map<String,String>();
        stateType.put('New South Wales','NSW');
        stateType.put('Victoria','VIC');
        stateType.put('Tasmania','TAS');
        stateType.put('Western Australia','WA');
        stateType.put('South Australia','SA');
        stateType.put('Australian Capital Territory','ACT');
        stateType.put('Northern Territory','NT');
        stateType.put('Queensland','QLD');
        return stateType;
    }
    
    public Map<String,String> streetTypeMap(){
        Map<String,String> streetType = new Map<String,String>();
        streetType.put('Alley','Al');
        streetType.put('Ambl','Amb');
        streetType.put('Arcade','Arc');
        streetType.put('Avenue','Ave');
        streetType.put('Bend','Bnd');
        streetType.put('Boulevard','Blv');
        streetType.put('Brace','Br');
        streetType.put('Centre','Ctr');
        streetType.put('Chase','Ch');
        streetType.put('Circle','Cir');
        streetType.put('Circuit','Cct');
        streetType.put('Circus','Crc');
        streetType.put('Close','Cl');
        streetType.put('Concourse','Cnc');
        streetType.put('Corner','Cnr');
        streetType.put('Corso','Cso');
        streetType.put('Court','Ct');
        streetType.put('Crescent','Crs');
        streetType.put('Crossing','Csg');
        streetType.put('Drive','Dr');
        streetType.put('Entrance','Ent');
        streetType.put('Esplanade','Esp');
        streetType.put('Freeway','Fwy');
        streetType.put('Frontage','Fr');
        streetType.put('Gate','Gte');
        streetType.put('Glade','Gl');
        streetType.put('Glen','Gln');
        streetType.put('Grange','Gra');
        streetType.put('Green','Grn');
        streetType.put('Ground','Grd');
        streetType.put('Grove','Gve');
        streetType.put('Heights','Hts');
        streetType.put('Highway','Hwy');
        streetType.put('Junction','Jn');
        streetType.put('Lane','La');
        streetType.put('Link','Lk');
        streetType.put('Loop','Lp');
        streetType.put('Mews','Mws');
        streetType.put('Mount','Mt');
        streetType.put('Nook','Nk');
        streetType.put('Outlook','Out');
        streetType.put('Parade','Pde');
        streetType.put('Parkway','Pwy');
        streetType.put('Pass','Pss');
        streetType.put('Place','Pl');
        streetType.put('Plaza','Plz');
        streetType.put('Point','Pnt');
        streetType.put('Port','Pt');
        streetType.put('Promenade','Prm');
        streetType.put('Quadrangle','Qdg');
        streetType.put('Quadrant','Qd');
        streetType.put('Quay','Qy');
        streetType.put('Reserve','Res');
        streetType.put('Rest','Rst');
        streetType.put('Retreat','Rt');
        streetType.put('Ridge','Rdg');
        streetType.put('Right of Way','Rtw');
        streetType.put('Rise','Ri');
        streetType.put('Road','Rd');
        streetType.put('Roadway','Rdy');
        streetType.put('Round','Rnd');
        streetType.put('Row','Row');
        streetType.put('Siding','Sdg');
        streetType.put('Square','Sq');
        streetType.put('Street','St');
        streetType.put('Terrace','Tce');
        streetType.put('Tollway','');
        streetType.put('Track','Twy');
        streetType.put('View','Vw');
        streetType.put('Walk','Wk');
        streetType.put('Walkway','Wky');
        streetType.put('Way','Way');
        streetType.put('Wynd','Wnd');
        
        return streetType;
    }
    
    
    public Map<String,String> assetsMap(){
        Map<String,String> assetMap = new Map<String,String>();
        assetMap.put('Investment Property','Property');
        assetMap.put('Motor Vehicle','MV');
        assetMap.put('Bank Account','Savings');
        assetMap.put('Superannuation','Super');
        assetMap.put('Commercial Property','Property');
        assetMap.put('Home','Property');
        assetMap.put('Home Contents,','Home Contents');
        assetMap.put('Shares Portfolio','Shares');
        assetMap.put('Collectibles','Collections');
        assetMap.put('Leisure','Boat');
        assetMap.put('Other','Collections');
        assetMap.put('Gift Funds','Gift Funds');
        assetMap.put('Deposit Paid','Deposit Paid');
        
        return assetMap;
    }
    
    public Map<String,String> liabilitiesMap(){
        Map<String,String> liaMap = new Map<String,String>();
        liaMap.put('Commercial Mortgage','Investment Loan');
        liaMap.put('Payday Loan','Personal');
        liaMap.put('Overdraft','Line of Credit');
        liaMap.put('Margin Loan','Line of Credit');
        liaMap.put('Merchant Credit (zip pay / afterpay / certigy)','Personal');
        liaMap.put('Tax liability','Other');
        liaMap.put('Personal Loan','Personal');
        liaMap.put('Car Lease','Hire Purchase');
        liaMap.put('Car Loan','Motor Vehicle Loan');
        liaMap.put('Child support','Other');
        liaMap.put('Credit Card / Store Card','CreditCard');
        liaMap.put('HECS/HELP','HECSHELP');
        liaMap.put('Mortgage','Line of Credit');
        liaMap.put('Home Loan/Mortgage','Home Loan');
        liaMap.put('Investment Home Loan','Investment Loan');
        return liaMap;
    }
    
    public class employmentStatus{
        public Contact con{get;set;}
        public FinServ__Employment__c emp{get;set;}
    }
    
    public class OpportunityContacts{
        public Opportunity opp{get;set;}
        public Contact contact1{get;set;}
        public Contact contact2{get;set;}
        public Integer app1NoChild{get;set;}
        public Integer app2NoChild{get;set;}
        public List<Contact> app1Children{get;set;}
        public List<Contact> app2Children{get;set;}
    }
    
}