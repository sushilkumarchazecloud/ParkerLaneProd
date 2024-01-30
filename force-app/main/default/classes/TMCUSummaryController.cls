public class TMCUSummaryController{
    
    public Boolean isApplicant2{get;set;}  
    
    public FinServ__FinancialGoal__c goals{get;set;}    
    public OpportunityContacts preferences{get;set;}
    public Contact livingExpensesDetails{get;set;}
    public Map<String, Contact> employmentDetails{get;set;}
    public EmploymentStatus applicant1EmpStatus{get;set;}
    public EmploymentStatus applicant2EmpStatus{get;set;}
    public EmploymentStatus applicant1Income2{get;set;}
    public EmploymentStatus applicant2Income2{get;set;}
    public EmploymentStatus applicant1Income3{get;set;}
    public EmploymentStatus applicant2Income3{get;set;}
    public List<FinServ__AssetsAndLiabilities__c> assets{get;set;}
    public List<FinServ__AssetsAndLiabilities__c> liabilities{get;set;}
    public Map<String, List<FinServ__AssetsAndLiabilities__c>> assetsAndLiabilities{get;set;}
    public OpportunityContacts oppContacts{get;set;}
    public Quote selectedQuote{get;set;}
    public Boolean isIncome2{get;set;}
    public Boolean isIncome3{get;set;}
    public static string dateCreated{get; set;}
    
    public TMCUSummaryController(){
        Datetime myDatetime = Datetime.now();
        dateCreated = myDatetime.format('E MMM dd yyyy hh:mm:ss a');
                
        isApplicant2 = false;
        isIncome2 = false;
        isIncome3 = false;
        
        Id oppId = ApexPages.CurrentPage().getParameters().get('id');
        
        employmentDetails = new Map<String, Contact>();
        
        applicant1EmpStatus = new EmploymentStatus();
        applicant2EmpStatus = new EmploymentStatus();
        applicant1Income2 = new EmploymentStatus();
        applicant2Income2 = new EmploymentStatus();
        applicant1Income3 = new EmploymentStatus();
        applicant2Income3 = new EmploymentStatus();
        
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
        
        employmentDetails = fetchSecondaryEmploymentDetails(oppId);
        
        applicant1Income2.con = employmentDetails.get('applicant1');
        applicant1Income3.con = employmentDetails.get('applicant1');
        
        if(employmentDetails.get('applicant1').FinServ__Employment__r.size() > 0){
            isIncome2 = true;
            applicant1Income2.emp = employmentDetails.get('applicant1').FinServ__Employment__r[0];
            if(employmentDetails.get('applicant1').FinServ__Employment__r.size() == 2){
                isIncome3 = true;
                applicant1Income3.emp = employmentDetails.get('applicant1').FinServ__Employment__r[1];
            }
        }
            
        if(employmentDetails.get('applicant2') != null){
            applicant2Income2.con = employmentDetails.get('applicant2');
            applicant2Income3.con = employmentDetails.get('applicant2');
            if(employmentDetails.get('applicant2').FinServ__Employment__r.size() > 0){
                isIncome2 = true;
                applicant2Income2.emp = employmentDetails.get('applicant2').FinServ__Employment__r[0];
                if(employmentDetails.get('applicant2').FinServ__Employment__r.size() == 2){
                    isIncome3 = true;
                    applicant2Income3.emp = employmentDetails.get('applicant2').FinServ__Employment__r[1];
                }
            }
        }
        
        assetsAndLiabilities = fetchAssetsAndLiabilities(oppId);
        assets = assetsAndLiabilities.get('Asset');
        liabilities = assetsAndLiabilities.get('Liability');
        oppContacts = fetchOppContacts(oppId);
        selectedQuote = fetchSelectedQuote(oppId);
        
        String oppName = oppContacts.opp.Name;
        Datetime dt = Datetime.now();
        List<string> data = string.valueOf(dt).split(' ');
        dateTime tim =  dt;
        string timeCorrect = data[0]+ ' '+ tim.format('h:mm a');
        String encodedOppName = EncodingUtil.urlEncode(oppName, 'UTF-8').replace('+', '%20');
        string title = 'Parker Lane Customer Application - '+encodedOppName + '(' + timeCorrect + ')';
        String FName = title+'.pdf';
        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+FName);      
    }
    
    public static Boolean checkApplicant2{get;set;}
    
    
    public Quote fetchSelectedQuote(Id recordId){
        try{
            Quote qt = [SELECT Id, Customer_Amount__c, Loan_Term__c, Monthly_Repayment__c, Purpose__c,  Interest_Rate__c,Total_Loan_Cost__c,Total_Fees__c,Brokerage_Amount__c,
                        Lead__c, Lead__r.FirstName, Lead__r.LastName, Lead__r.Email, Shared_Message__c, Monthly_Repayments__c,Product__r.Interest_Rate_Type__c,Credit_Available_after_Setup_Costs__c,
                        Opportunity.Applicant_1__r.PersonContactId, Product__c, Product__r.Name,Total_loan_amount__c,Total_Setup_Fees__c,Product__r.Ongoing_Fees__c,Commission_Amount__c,Lender__c 
                        FROM Quote WHERE OpportunityId =: recordId AND Application__c = true LIMIT 1];
            
            if(qt.Product__r.Name != null){
                if(qt.Product__r.Name.contains('1-5')){
                    String productName = qt.Product__r.Name.remove(qt.Product__r.Name.substringAfter('('));
                    productName = productName.remove('(');
                    qt.Product__r.Name = 'Green Loan (via Parker Lane)';
                    
                }
                if(qt.Product__r.Name.contains('6-10')){
                    String productName = qt.Product__r.Name.remove(qt.Product__r.Name.substringAfter('('));
                    productName = productName.remove('(');
                    qt.Product__r.Name = 'Green Loan (via Parker Lane, over 5 years)';
                    
                }
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
            [SELECT Id, Control_of_your_finances__c,Description_struggle_to_meet_houshold__c,Description_exp_in_the_next_6_12_month__c, Find_ways_to_save_money__c, Plan_to_achieve_your_financial_goals__c,Do_you_have_an_adequate_plan__c,
             Plan_to_repay_debt_quickly__c, household_expense_in_the_next_6_12_month__c,Rates_of_interest_you_currently_pay__c, Do_you_struggle_to_meet_your_household__c,Take_action_to_save_money__c, Track_and_manage_your_finances__c,
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
            opp = [SELECT Id, Number_of_applicants__c,Purpose__c, Application_Sections__c, Current_Application_Sections__c, AccountId,
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
            [SELECT FinServ__CurrentEmployer__c,Insurance_and_medical__c, FinServ__Occupation__c, Home_Loan_repayment__c, Investment_Property_Loan_repayment__c,Clothing_and_entertainment__c,Education_and_childcare__c,Groceries_transport__c,
             Credit_Card_payment_3_of_total_limit__c, Other_loans_and_or_debt_commitments__c, Rental_or_Board_paid__c, Utilities__c,
             Connections_Phone_Mobile_Internet_C__c, Education_ChildCare_SchoolFees_Uniform__c, Food_Groceries_Meat_Fruit_Vegetabl__c,
             Transport_Public_Petrol_Registration__c, Medical_Private_Health_Insurance_Ong__c, Insurances_Home_Personal_Voluntary__c,Personal_Insurances_life_and_income_pro__c,
             Household_Purchases_and_Maintenance__c, Entertainment_Dining_Out_Movies_Gift__c, Sports_Hobbies_and_Memberships__c,Clothing_and_personal_care__c,
             Gambling_Betting_and_Lottery__c, Other_Regular_Expenditure__c, Total_Living_Expenses__c, Email,Clothing_Recreational_Entertainment__c,
             Insurance_Medical_Health__c,Property_including_Rates_Utilities_Manag__c,CFCU_Other__c,Investment_property_utilities__c,Education_public_and_private__c 
             FROM Contact 
             WHERE Id =: opp.Applicant_1__r.PersonContactId];
        return conList[0];
    }
    
    public Map<String, Contact> fetchSecondaryEmploymentDetails(Id recordId){
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
             (SELECT Id, Name, FinServ__Occupation__c, FinServ__AnnualIncome__c, FinServ__EmployerAddress__c,Minimum_hours_per_week__c,
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
              FROM FinServ__Employment__r WHERE Is_Primary__c = false LIMIT 2)
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
             (SELECT Id, Name, FinServ__Occupation__c, FinServ__AnnualIncome__c, FinServ__EmployerAddress__c,Minimum_hours_per_week__c,
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
             Pre_Payment_Frequency__c, Pre_tax_lease_Payment__c, Ownership_Share__c, Other_Ownership_Share__c, Value__c,Monthly_Calculation__c
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
            opp = [SELECT Id,Name,Number_of_applicants__c,Purpose__c, Application_Sections__c, Current_Application_Sections__c,
                   Applicant_1__c, Applicant_1__r.PersonContactId, Applicant_2__c, Applicant_2__r.PersonContactId,Living_Expense_Group_Type__c,
                   AccountId, Account.RecordType.Name, FinServ__Household__c, Relationship_to_Applicant_2__c,Owner.Name
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
            
            Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Name,spouse_s_approximate_annual_income__c,What_is_spouse_s_primary_income_source__c,FirstName, LastName, MiddleName, Email, Phone, Title, Birthdate, 
                                                                 OtherPhone, FinServ__Gender__c, FinServ__MaritalStatus__c, Government_ID__c,Medicare_Expiry_Month__c,
                                                                 Govt_Id_Number__c, Living_Situation__c, FinServ__NumberOfChildren__c,Medicare_Reference__c,
                                                                 Security_Answer__c, Security_Question__c, Driver_s_licence_state_Territory__c,Medicare_Expiry_Year__c,
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