public without sharing class HLHCOpportunityController {
    
    @auraEnabled
    public static String Save(String recordId, String recordTypeName, String rating, String OwnerId){
        Opportunity opp = [SELECT id,accountid,recordtypeid,name,stagename,closedate,type,ownerid,contractid,hasopenactivity,hasoverduetask,
                           budget_confirmed__c,discovery_completed__c,roi_analysis_completed__c,finserv__financialaccount__c,loss_reason__c,finserv__household__c,
                           finserv__referredbyuser__c,any_lenders_you_don_t_wish_to_deal_with__c,applicant_1__c,applicant_2__c,application_sections__c,
                           current_application_sections__c,expect_to_remain_in_the_credit_contract__c,have_adequate_debt_protection_insurance__c,have_adequate_income_protection__c,
                           have_adequate_life_insurance__c,have_adequate_insurance__c,consent_and_identification__c,preferred_repayment_frequency__c,
                           primary_reason_for_installing_solar__c,product_type__c,relationship_to_applicant_2__c,type_of_interest_rate__c,
                           would_you_like_us_to_arrange_a_meeting__c,prefered_primary_contact_method__c,purpose__c,
                           applicant_1_voii_attached__c,applicant_1_voii_notes__c,applicant_1_voii_type__c,applicant_2_voii_notes__c,applicant_2_voi_attached__c,
                           applicant_2_voi_type__c,application_pending_notes__c,application_pending_status__c,application_status__c,
                           broker_confirmation_the_loan_is_not_unsu__c,confirmed_email_was_correct__c,credit_guide_privacy_consent_provided__c,
                           credit_guide_privacy_sent_date__c,customer_response_sq_commision__c,customer_response__c,do_not_contact__c,email_opt_opt__c,
                           interest_rate__c,loan_term_months__c,monthly_repayments__c,needs_analysis_completed__c,disclosure_statement_read_to_client__c,
                           disclosure_statement_read_to_client_date__c,product_comparison_attached__c,product_name__c,sms_opt_opt__c,
                           sq_commission_script_read_date__c,sq_commission_script_read__c,servicability_attached__c,signed_cpd_attached__c,signed_credit_quote_attached__c,
                           total_loan_amount__c,annual_rent__c,applicant_1_income_before_tax__c,applicant_1_taxable_income__c,applicant_1_share__c,
                           applicant_2_income_before_tax__c,applicant_2_share__c,assesment_rate__c,child_support__c,contact_1__c,contact_2__c,credit_card_limits__c,
                           gross_income__c,hecs__c,hem_living_expenses__c,home_loan_repayments__c,household__c,lender_calculator__c,max_borrowing_capacity__c,
                           net_monthly_income_after_tax__c,net_monthly_surplus__c,other__c,personal_loan_repayments__c,proposed_loan_amount__c,proposed_loan_payment__c,
                           proposed_term__c,rent__c,secured_loc_balance__c,tax_free_income__c,total_monthly_commitments__c,x1_applicant_1_income_tax__c,
                           x1_applicant_2_taxable_income__c,x1_applicant_2_income_tax__c,application_fee__c,borrower_contribution__c,brokerage__c,closed_reason__c,
                           deposit_paid__c,government_charges__c,legal_fees__c,opportunity_temperature__c,purchase_price_funds_needed__c,purpose_type__c,risk_fee__c,
                           settled_reason__c,stamp_duty__c,total_funds_available__c,total_funds_required__c,valuation_fee__c,remaining__c,net_surplus__c,
                           applicant_1_firstname__c,broker_declaration__c,conduct__c,credit_default_explanation__c,credit_enquiries_explanation__c,credit_file__c,credit_score__c,
                           debt_to_income_ratio__c,equifax_url__c,income_employment__c,lvr__c,recommendation__c,number_of_applicants__c,
                           home_owner__c,secured__c,security_identifier__c,security_value__c,securiy_description__c,stability__c,supplier__c,
                           oppid__c,loan_purpose__c,i_certify_the_applicants_id_and_intent__c,why_did_you_chose_parker_lane__c,prefer_to_repay_over_a_term__c,
                           priority_is__c,utilities__c,connections__c,disclosure_statement__c,education_living_expenses__c,food_groceries_meat_fruit_vegetables__c,
                           transport_public_petrol_regs_servc__c,medical_private_health_ins_med_bills__c,insurances_home_personal_voluntary__c,household_purchases_and_maintenance__c,
                           entertainment_dining_out_movies_gift__c,sports_hobbies_and_memberships__c,gambling_betting_and_lottery__c,other_regular_expenditure__c,
                           total_living_expenses__c,hem_link__c,how_much_do_you_need__c,how_would_you_like_us_to_support_you__c,send_the_quote_to__c,credit_check__c,
                           electronic_communication__c,privacy_and_credit_guide__c,product_disclosure__c,referral_fees__c,ways_to_save_optional__c,
                           consent_and_identification_description__c,credit_check_description__c,electronic_communication_description__c,privacy_and_credit_guide_description__c,
                           product_disclosure_description__c,referral_fees_description__c,ways_to_save_optional_description__c, direction__c,features__c,
                           how_detailed_would_you_like_your_quotes__c,leadid__c,system_price_type__c,timeframe__c,what_type_of_system_are_you_after__c,availableforconversation__c,
                           importantnotes__c,installationaddresslineone__c,installationaddresslinetwo__c,installationcountry__c,installationpostcode__c,installationstate__c,
                           installationsuburb__c,leadaddress__c,leadtype__c,minimumtensquaremetersnorthfacing__c,owntheroofspace__c,quarterlybill__c,size__c,submitteddate__c,
                           typeofroof__c,ownername__c,secondary_contact__c,last_stage_change_date__c,
                           opportunity_support__c,original_opportunity_type__c,status_of_original_opportunity__c,time_at_current_stage__c,confirm_settlement_date__c,
                           hlhc_amount__c,hlhc_interest_rate__c,hlhc_important_notes__c,hlhc_offered__c,
                           hlhc_offer_outcome__c,date_hlhc_created__c, Date_HLHC_Offered__c,opportunity_stage_when_hlhc_created__c,opportunity_owner_when_hlhc_created__c,hlhc_created_by__c,
                           loan_amount_you_want_to_apply_for__c,what_is_the_intended_use_of_the_funds__c,term_you_wish_to_apply_for_in_years__c,
                           preference_for_the_type_of_lender__c,do_you_have_a_fixed_term_in_mind__c,locking_rate_at_the_time_of_application__c,interested_in_fixed_rate__c,
                           interested_in_variable_rate__c,interested_in_part_fixed_and_variable__c,interest_only_repayments__c,interest_in_advance__c,interested_in_offset_account__c,
                           interested_in_redraw__c,interested_in_access_to_a_branch_network__c,other_features_you_are_interested_in__c,any_product_types_you_are_interested_in__c,
                           application_supporting_notes__c,mortgage_repayments_halved__c,servicing_net_surplus__c,sf_rate_inc_gst__c,income_description__c,character_description__c,
                           servicing_notes__c,applicant_1_veda_score__c,applicant_2_veda_score__c,sf_date_due_paid__c,sf_paid_confirmed__c,service_fee_inc_gst__c,sf_adviser_split__c,
                           sf_payment_due__c,commitment_fee_inc_gst__c,cf_type__c,cf_rate_inc_gst__c,cf_date_due_paid__c,cf_paid_confirmed__c,ufc_type__c,ufc_rate_inc_gst__c,
                           ufc_date_due_paid__c,ufc_paid_confirmed__c,up_front_commission_inc_gst__c,tc_commences__c,tc_date_due_paid__c,tc_paid_confirmed__c,bsf_type__c,
                           bsf_rate_inc_gst__c,bsf_date_due_paid__c,bsf_paid_confirmed__c,mtc_rate_annual_inc_gst__c,ufc_adviser_split__c,
                           monthly_trail_commission_inc_gst__c,brokerage_service_fee_inc_gst__c,bsf_adviser_split__c,x3_year_gross_income_inc_gst__c,x3_year_net_income_inc_gst__c,
                           x5_year_gross_income_inc_gst__c,x5_year_net_income_inc_gst__c,fixed_term_preference__c,
                           rapport_notes__c,link_to_disc_guide__c,hlhc_interest_rate_type__c,hlhc_monthly_repayment__c,hlhc_approx_term_left_yrs__c,
                           hlhc_property_valuation__c,hlhc_lender__c,credit_quote_status__c,credit_quote_fees__c,commitment_fee__c,service_fee__c,valuation__c,discharge__c,
                           certificate_of_currency__c,mortgage_documents__c,closed_lost_reason__c,mercuryid__c, contact_1__r.FirstName, contact_1__r.LastName, contact_2__r.FirstName,
                           contact_2__r.LastName, contact_1__r.Name 
                           FROM Opportunity WHERE Id =: recordId limit 1];
        
        List<Account> accListToUpdate = New List<Account>();
        Opportunity newHLHCOpp = opp.clone();
        newHLHCOpp.date_hlhc_created__c = Date.today();
        newHLHCOpp.opportunity_stage_when_hlhc_created__c = opp.StageName;
        newHLHCOpp.opportunity_owner_when_hlhc_created__c = opp.OwnerId;
        newHLHCOpp.hlhc_created_by__c = UserInfo.getUserId();
        newHLHCOpp.closedate = Date.today().addDays(70);
        newHLHCOpp.FinServ__ReferredByUser__c = UserInfo.getUserId();
        if(newHLHCOpp.hlhc_offered__c){
            newHLHCOpp.Date_HLHC_Offered__c = Date.today();            
        }
        
        if(String.isNotBlank(recordTypeName)){
            newHLHCOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        }
        if(String.isNotBlank(OwnerId)){
            newHLHCOpp.OwnerId = OwnerId;
            if(String.isNotBlank(opp.applicant_1__c)){
                accListToUpdate.add(New Account(Id = opp.applicant_1__c, OwnerId = OwnerId) );
            }
            if(String.isNotBlank(opp.applicant_2__c)){
                accListToUpdate.add(New Account(Id = opp.applicant_2__c, OwnerId = OwnerId) );
            }
            if(String.isNotBlank(opp.finserv__household__c)){
                accListToUpdate.add(New Account(Id = opp.finserv__household__c, OwnerId = OwnerId) );
            }
            if(String.isBlank(opp.finserv__household__c) && String.isNotBlank(opp.AccountId) && (!opp.AccountId.equals(opp.applicant_1__c))){
                accListToUpdate.add(New Account(Id = opp.AccountId, OwnerId = OwnerId) );
            }
        } 
        if(String.isNotBlank(OwnerId)){
            newHLHCOpp.Rating__c = rating;
        } 
        newHLHCOpp.Current_Application_Sections__c = 'Who is applying';
        newHLHCOpp.Application_Sections__c = 'Who is applying';
        newHLHCOpp.StageName ='HLHC Appointment 1';
        newHLHCOpp.Loan_Amount__c = opp.hlhc_amount__c;
        newHLHCOpp.ufc_type__c= 'Percentage';
        newHLHCOpp.ufc_rate_inc_gst__c = 0.0066;
        String householdName = String.isNotBlank(opp.contact_1__c) ? opp.contact_1__r.Name : '';
        
        if(String.isNotBlank(opp.contact_2__c)){
            if(opp.contact_1__r.LastName.equalsIgnoreCase(opp.contact_2__r.LastName)){
                householdName = opp.contact_1__r.FirstName + ' and ' + opp.contact_2__r.FirstName + ' ' + opp.contact_1__r.LastName;
            }else{
                householdName = opp.contact_1__r.FirstName + ' ' + opp.contact_1__r.LastName + ' and ' + opp.contact_2__r.FirstName + ' ' + opp.contact_2__r.LastName;
            }
        }
        newHLHCOpp.Name = householdName + ', ' + recordTypeName;
        
        insert newHLHCOpp;
        if(!accListToUpdate.isEmpty()){
            update accListToUpdate;
        }
        return newHLHCOpp.Id;
        
    }
}