public class UpdateSupportingNotesController {
    
    @auraEnabled
    public static void refreshNotes(String recordId){
        Opportunity opp=[SELECT Id, Applicant_1__r.Name, Applicant_2__r.Name, Application_Amount__c, RecordType.Name,
                         Loan_Term_months__c,Interest_Rate__c,Owner.Name, FinServ__ReferredByContact__r.Name, SyncedQuote.Commission_Amount__c,
                         Applicant_1__r.FinServ__MaritalStatus__pc, Applicant_1__r.FinServ__NumberOfChildren__pc, Applicant_2__r.FinServ__MaritalStatus__pc, 
                         Applicant_2__r.FinServ__NumberOfChildren__pc, Applicant_1__c, Applicant_2__c, Character_Description__c, SyncedQuote.Brokerage_Amount__c,
                         Applicant_1_Veda_Score__c, Applicant_2_Veda_Score__c, Income_Description__c, Mortgage_repayments_halved__c, Servicing_Net_Surplus__c,
                         Servicing_Notes__c, Application_Supporting_Notes__c
                         FROM Opportunity WHERE Id =: recordId limit 1];
        
        Map<String, Contact> employmentDetailsMap = ParkerLaneLoanController.getEmploymentDetails(recordId);
        ParkerLaneLoanController.ContactWithOpp conWrap = ParkerLaneLoanController.getLivingExpensesDetails(recordId);
        Contact expDetails = conWrap.con;
        Contact app1 = employmentDetailsMap.get('applicant1');
        Contact app2 = employmentDetailsMap.get('applicant2');
        Map<String, List<FinServ__AssetsAndLiabilities__c>> assetsAndLiabilitiesMap = ParkerLaneLoanController.getAssetsAndLiabilities(recordId);
        
        String summary='';
        summary += 'A discussion has been had with the member(s) around their needs, we have discussed their options and I confirm that the loan purpose and product is not unsuitable.\n\n';
        
        summary += 'Member Name(s): ';
        if(opp.Applicant_1__c != NULL){
            summary +=  opp.Applicant_1__r.Name;
        }
        if(opp.Applicant_2__c != NULL){
            summary += ' and ' + opp.Applicant_2__r.Name;
        }
        summary +='\n';
        
        summary += 'Loan Amount (Inclusive of Fees): $' + getFormatedValue(opp.Application_Amount__c) + '\n';
        summary += 'Product / Term: ' + opp.RecordType.Name + ' (';
        if(opp.Loan_Term_months__c!= Null){
            summary += ((opp.Loan_Term_months__c/12).setScale(0)) + ' years';
        }
        summary +=')\n';
        summary += 'Rate & Interest Class: ' + opp.Interest_Rate__c + '% P&I\n';
        summary += 'Total Exposure: $' + getFormatedValue(opp.Application_Amount__c) + '\n';
        summary += 'ARA (i.e. Actual Amt with Buffer Rate): $' + getFormatedValue( opp.Servicing_Net_Surplus__c) + '\n';
        summary += 'Applicant 1 Veda Score: ' + opp.Applicant_1_Veda_Score__c + '\n';
        summary += 'Applicant 2 Veda Score: ' + opp.Applicant_2_Veda_Score__c + '\n';
        summary += 'Store / Originator: ' + opp.Owner.Name + ', Parker Lane\n';
        summary += 'Referrer/Commission Payable to: Upside Downside Pty Ltd T/A Parker Lane: $' +getFormatedValue( opp.SyncedQuote.Commission_Amount__c)  + '\n';
        summary += 'Brokerage Payable to: Upside Downside Pty Ltd T/A Parker Lane $' + getFormatedValue( opp.SyncedQuote.Brokerage_Amount__c) + '\n';
        
        summary += 'Purpose of loan: $' + getFormatedValue( opp.Application_Amount__c ) + ' for '; 
        summary += (('Green Loan').equalsIgnoreCase(opp.RecordType.Name)? 'Solar Panels': opp.RecordType.Name)+'\n\n';
        
        summary += 'Summary of Applicant:\n'; 
        if(opp.Applicant_1__c != NULL){
            summary += 'Applicant 1: New member to CFCU who is ' + opp.Applicant_1__r.FinServ__MaritalStatus__pc + ' with ' + opp.Applicant_1__r.FinServ__NumberOfChildren__pc + '  dependent children \n';
        }
        if(opp.Applicant_2__c != NULL){
            summary += 'Applicant 2: New member to CFCU who is  ' + opp.Applicant_2__r.FinServ__MaritalStatus__pc + ' \n\n'; 
        }
        if(app1!= Null){
            summary += 'Applicant 1 Income: \n';
            summary += 'Applicant 1 primary occupation is ' + app1.FinServ__Occupation__c + '. \n';
            if(!app1.FinServ__Employment__r.isEmpty()){
                summary += 'Primary source of income is from ' + app1.FinServ__Employment__r[0].FinServ__EmploymentStatus__c;
                if(app1.FinServ__Employment__r[0].FinServ__EmploymentStatus__c !=NULL && app1.FinServ__Employment__r[0].FinServ__EmploymentStatus__c.contains('Part time')){
                    summary += 'with minimum hours of ' + app1.FinServ__Employment__r[0].Minimum_hours_per_week__c + ' per week';
                }
                summary += '\nTenure: ' + app1.FinServ__Employment__r[0].Years__c + ' years and ' + app1.FinServ__Employment__r[0].Months__c + ' months. \n';
                summary += 'Industry: ' + app1.FinServ__Employment__r[0].FinServ__Occupation__c + '\n';
                summary += 'Job Title: ' + app1.FinServ__Employment__r[0].Job_Title__c + '\n';
                summary += 'Employer Name: ' + app1.FinServ__Employment__r[0].Name + '\n';
                summary += 'Employer Contact Number: ' + app1.FinServ__Employment__r[0].FinServ__EmployerPhoneNumber__c + '\n';
                summary += 'Gross Base Income: $' + getFormatedValue( app1.FinServ__Employment__r[0].FinServ__AnnualIncome__c ) + ' ' + app1.FinServ__Employment__r[0].Income_Frequency__c+'\n';
                if(('Yes').equalsIgnoreCase(app1.FinServ__Employment__r[0].Regularly_work_Overtime__c)){
                    summary += 'Receives regular Overtime: $' + getFormatedValue( app1.FinServ__Employment__r[0].Work_Overtime_amount__c ) + ' ' + app1.FinServ__Employment__r[0].Work_Overtime_Frequency__c + '\n';
                }
                if(('Yes').equalsIgnoreCase(app1.FinServ__Employment__r[0].Regularly_receive_Commission_or_Bonus__c)){
                    summary += 'Receives regular Bonus & Commission: $' + getFormatedValue( app1.FinServ__Employment__r[0].Commission_or_Bonus_amount__c ) + ' ' + app1.FinServ__Employment__r[0].Commission_or_Bonus_Frequency__c + '\n';
                }
                if(('Yes').equalsIgnoreCase(app1.FinServ__Employment__r[0].Regularly_Receive_Allowance__c)){
                    summary += 'Receives regular Allowances: ' + getFormatedValue( app1.FinServ__Employment__r[0].Allowance_Amount__c ) + ' ' + app1.FinServ__Employment__r[0].Allowance_Frequency__c + '\n';
                }
                if(('Yes').equalsIgnoreCase(app1.FinServ__Employment__r[0].Provide_a_Company_Car__c)){
                    summary += 'Employer provides fully funded company car\n';
                }
            }
        }
        if(app2 != Null){
            summary += '\nApplicant 2 Income: \n';
            summary += 'Applicant 2 primary occupation is ' + app2.FinServ__Occupation__c + '. \n';
            if(!app2.FinServ__Employment__r.isEmpty()){
                summary += 'Primary source of income is from ' + app2.FinServ__Employment__r[0].FinServ__EmploymentStatus__c;
                if(app2.FinServ__Employment__r[0].FinServ__EmploymentStatus__c !=NULL && app2.FinServ__Employment__r[0].FinServ__EmploymentStatus__c.contains('Part time')){
                    summary += 'with minimum hours of ' + app2.FinServ__Employment__r[0].Minimum_hours_per_week__c + ' per week';
                }
                summary += '\nTenure: ' + app2.FinServ__Employment__r[0].Years__c + ' years and ' + app2.FinServ__Employment__r[0].Months__c + ' months. \n';
                summary += 'Industry: ' + app2.FinServ__Employment__r[0].FinServ__Occupation__c + '\n';
                summary += 'Job Title: ' + app2.FinServ__Employment__r[0].Job_Title__c + '\n';
                summary += 'Employer Name: ' + app2.FinServ__Employment__r[0].Name + '\n';
                summary += 'Employer Contact Number: ' + app2.FinServ__Employment__r[0].FinServ__EmployerPhoneNumber__c + '\n';
                summary += 'Gross Base Income: ' + getFormatedValue( app2.FinServ__Employment__r[0].FinServ__AnnualIncome__c )  + ' ' + app2.FinServ__Employment__r[0].Income_Frequency__c+'\n';
                
                if(('Yes').equalsIgnoreCase(app2.FinServ__Employment__r[0].Regularly_work_Overtime__c)){
                    summary += 'Receives regular Overtime: ' + getFormatedValue( app2.FinServ__Employment__r[0].Work_Overtime_amount__c ) + ' ' + app2.FinServ__Employment__r[0].Work_Overtime_Frequency__c + '\n';
                }
                if(('Yes').equalsIgnoreCase(app2.FinServ__Employment__r[0].Regularly_receive_Commission_or_Bonus__c)){
                    summary += 'Receives regular Bonus & Commission: ' + getFormatedValue( app2.FinServ__Employment__r[0].Commission_or_Bonus_amount__c ) + ' ' + app2.FinServ__Employment__r[0].Commission_or_Bonus_Frequency__c + '\n';
                }
                if(('Yes').equalsIgnoreCase(app2.FinServ__Employment__r[0].Regularly_Receive_Allowance__c)){
                    summary += 'Receives regular Allowances: ' + getFormatedValue( app2.FinServ__Employment__r[0].Allowance_Amount__c ) + ' ' + app2.FinServ__Employment__r[0].Allowance_Frequency__c + '\n';
                }
                if(('Yes').equalsIgnoreCase(app2.FinServ__Employment__r[0].Provide_a_Company_Car__c)){
                    summary += 'Employer provides fully funded company car\n';
                }
            }
        }
        
        summary += '\nCapacity Calculator\n';
        if(('Yes').EqualsIgnoreCase(opp.Mortgage_repayments_halved__c)){
            summary += 'Mortgage payments halved: The applicant has disclosed that their partner is gainfully employed and contributes to the repayment of their owner occupied mortgage for which they are also a listed borrower. \n\n';
        }
        if(opp.Servicing_Notes__c !=Null){
            summary += opp.Servicing_Notes__c + '\n';
        }
        summary += '\n';
        summary += 'Living Expenses: Enquiries have been made to determine the household living expenses to get the monthly numbers for below.\n';
        
        if(expDetails !=Null){
            summary += 'General Monthly Living Expenses\n';
            summary += 'Owner occupied property utilities, rates and relates costs including taxes, levies, body corporate and Strata fees, repairs, maintenance and other household items and utilities: $' + getFormatedValue( expDetails.Utilities__c ) + '\n';
            summary += 'Investment property utilities, rates and relates costs including taxes, levies, body corporate and Strata fees, repairs, maintenance and other household items and utilities: $' + getFormatedValue( expDetails.Investment_property_utilities__c ) + '\n';
            summary += 'Connections: Phone, mobile, internet, cable TV, streaming services such as Netflix, music and any other similar subscriptions: $' + getFormatedValue( expDetails.Connections_Phone_Mobile_Internet_C__c ) + '\n';
            summary += 'Childcare: All childcare expenses. Including nannies: $' + getFormatedValue( expDetails.Education_ChildCare_SchoolFees_Uniform__c ) + '\n';
            summary += 'Education: public and private education fees and associated costs (preschool, primary, secondary, tertiary) including books, uniforms etc.: $' + getFormatedValue( expDetails.Education_public_and_private__c ) + '\n';
            summary += 'Maintenance: If you pay child maintenance (child support), the amount per month: $' + getFormatedValue( expDetails.Maintenance_If_pay_child_maintenance__c ) + '\n';
            summary += 'HECS / HELP debt: $' + getFormatedValue( expDetails.HECS_HELP_debt__c ) + '\n';
            summary += 'Groceries: supermarket, meat, fruit and vegetables : $' + getFormatedValue( expDetails.Food_Groceries_Meat_Fruit_Vegetabl__c ) + '\n';
            summary += 'Clothing and personal care: Clothing, footwear, cosmetics and personal care: $' + getFormatedValue( expDetails.Clothing_and_personal_care__c ) + '\n';
            summary += 'Transport: public transport fees, car expenses including petrol, registration, insurance, servicing, tolls: $' + getFormatedValue( expDetails.Transport_Public_Petrol_Registration__c ) + '\n';
            summary += 'Medical and Health: Including doctor and dentist, optical and pharmaceutical (excluding health insurance): $' + getFormatedValue( expDetails.Medical_Private_Health_Insurance_Ong__c )  + '\n';
            summary += 'General Insurances: All insurance including health, home and contents, motor vehicle: $' + getFormatedValue( expDetails.Insurances_Home_Personal_Voluntary__c ) + '\n';
            summary += 'Personal Insurances: life and income protection, illness and accident, pet insurance, voluntary superannuation: $' + getFormatedValue( expDetails.Personal_Insurances_life_and_income_pro__c ) + '\n';
            summary += 'Recreation and Entertainment: dining out, movies, gifts, membership fees, sporting, pet care, holidays and other items: $' + getFormatedValue( expDetails.Entertainment_Dining_Out_Movies_Gift__c ) + '\n';
            summary += 'Gambling, Betting &amp; lottery: $' + getFormatedValue( expDetails.Gambling_Betting_and_Lottery__c ) + '\n';
            summary += 'Other unique items not covered in the above categories (must be explained to your broker): $' + getFormatedValue( expDetails.Other_Regular_Expenditure__c )+ '\n';
            summary += 'Total General Monthly Living Expenses $' + getFormatedValue( expDetails.Total_Living_Expenses__c)  + '\n\n';
        }
        summary += 'Existing non refinanced debts:\n';
        if(! assetsAndLiabilitiesMap.isEmpty()){
            Decimal assetTotal = 0;
            Decimal liabilityTotal = 0;
            if(assetsAndLiabilitiesMap.containsKey('Asset')){
                for(FinServ__AssetsAndLiabilities__c ass: assetsAndLiabilitiesMap.get('Asset')){
                    if(ass.Value__c != NULL)
                        assetTotal += ass.Value__c;
                }
            }
            if(assetsAndLiabilitiesMap.containsKey('Liability')){
                for(FinServ__AssetsAndLiabilities__c lia: assetsAndLiabilitiesMap.get('Liability')){
                    summary += lia.FinServ__AssetsAndLiabilitiesType__c +' ';
                    if(lia.Institution__c != NULL){
                        summary +=lia.Institution__c;
                    }
                    if(lia.Value__c != NULL){
                        liabilityTotal += lia.Value__c;
                    }
                    if(lia.Monthly_Repayment__c != NULL){
                        summary +=': Monthly Repayments $' + getFormatedValue(lia.Monthly_Calculation__c) ;
                    }
                    if(('Car Lease').equalsIgnoreCase(lia.FinServ__AssetsAndLiabilitiesType__c)){
                        Decimal preTax = 0;
                        Decimal postTax = 0;
                        if(lia.Post_tax_lease_Payment__c != NULL){
                            postTax = ('Weekly').equalsIgnoreCase(lia.Post_Payment_Frequency__c) ? (lia.Post_tax_lease_Payment__c *52/12) :
                            (('Fortnightly').equalsIgnoreCase(lia.Post_Payment_Frequency__c) ? (lia.Post_tax_lease_Payment__c *26/12) :
                             (('Monthly').equalsIgnoreCase(lia.Post_Payment_Frequency__c) ? (lia.Post_tax_lease_Payment__c) :
                              (('Annually').equalsIgnoreCase(lia.Post_Payment_Frequency__c) ? (lia.Post_tax_lease_Payment__c/12) :0)));
                                  }
                        
                        if(lia.Pre_tax_lease_Payment__c != NULL){
                            preTax = ('Weekly').equalsIgnoreCase(lia.Pre_Payment_Frequency__c) ? (lia.Pre_tax_lease_Payment__c *52/12) :
                            (('Fortnightly').equalsIgnoreCase(lia.Pre_Payment_Frequency__c) ? (lia.Pre_tax_lease_Payment__c *26/12) :
                             (('Monthly').equalsIgnoreCase(lia.Pre_Payment_Frequency__c) ? (lia.Pre_tax_lease_Payment__c) :
                              (('Annually').equalsIgnoreCase(lia.Pre_Payment_Frequency__c) ? (lia.Pre_tax_lease_Payment__c/12) :0)));
                                  }
                        summary +=': Monthly Repayments $' + getFormatedValue(preTax) + ' pre tax; $';
                        summary += getFormatedValue( postTax) + ' post tax';
                    }
                    summary +='\n';
                }
            }
            
            summary += '\nCapital\n';
            summary += 'Total Assets: $' + getFormatedValue( assetTotal) +' Total Liabilities: $' +getFormatedValue( liabilityTotal) +' Net Assets: $' + getFormatedValue( assetTotal - liabilityTotal) +'\n\n';
        }
        summary += 'Character: The applicants demonstrate good character\n';
        summary += opp.Character_Description__c +'\n\n';
        summary += '*ALL OTHER INQUIRES LISTED ON CREDIT REPORT ARE NOT LISTED AS CURRENT BY THE APPLICANT IN THEIR FACT FIND*\n';
        summary += 'Collateral : N/A\n';
        summary += 'Recommendation: Please approve\n';
        opp.Application_Supporting_Notes__c = summary;
        update opp;
        //return summary;
    }
    private static String getFormatedValue(Decimal val){
        List<String> noFormat = new String[]{'0','number','###,###,##0'};
        Decimal tmpVal = val != NULL? val:0;
        return String.format((tmpVal.setScale(0)).format(), noFormat);
    }
}