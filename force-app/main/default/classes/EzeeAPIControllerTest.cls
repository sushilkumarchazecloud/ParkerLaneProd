@isTest
public class EzeeAPIControllerTest {
    
    @testsetup
    static void setdata(){
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String recordHTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Household').getRecordTypeId();
        List<Account> accList= new List<Account>();
        Account acc= new Account(
            RecordTypeID=recordHTypeId ,
            Name='Test Name'
        );
        accList.add(acc);
        
        System.debug('acc id +++'+acc.Id);
        Account accPerson= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test Person',
            LastName='Test LName',
            PersonEmail='test@yahoo.com',
            PersonBirthdate = system.today(),
            Is_Sync_with_Household__c=false,
            Does_your_spouse_earn_an_income__pc = 'Yes',
            spouse_s_approximate_annual_income__pc = 2000,
            FinServ__MaritalStatus__pc = 'Married / Defacto (to applicant 2)',
            Year__pc = '1',            
            Months__pc = '1',
            Year_1__pc = '1',
            Months_1__pc = '1',
            Relationship_with_Applicant_1__c='Client',
            PersonTitle = 'Mr.',
            Phone = '0400000000',
            Security_Question__pc = 'Mothers maiden name',
            Security_Answer__pc = 'qwerty',
            Rental_Amount__pc = 500,
            Rental_or_Board_paid__pc =  50,
            Education_ChildCare_SchoolFees_Uniform__pc = 12,
            Maintenance_If_pay_child_maintenance__pc =  25,
            Other_loans_and_or_debt_commitments__pc = 24,
            Education_public_and_private__pc  = 10,
            Food_Groceries_Meat_Fruit_Vegetabl__pc = 100,
            Living_Situation__pc = 'Renting',
            Citizenship_Status__pc = 'Australian Citizen',
            FinServ__Gender__pc = 'Male',
            Transport_Public_Petrol_Registration__pc = 100,
            Medical_Private_Health_Insurance_Ong__pc = 100,
            Personal_Insurances_life_and_income_pro__pc = 100,
            Insurances_Home_Personal_Voluntary__pc = 100,
            Utilities__pc = 100,
            Driver_s_licence_state_Territory__pc = 'Queensland',
            Connections_Phone_Mobile_Internet_C__pc = 200,
            FinServ__NumberOfChildren__pc = 3
        );
        
        Account acc2Person= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test Person',
            LastName='Test LName',
            PersonEmail='test@yahoo.com',
            PersonBirthdate = system.today(),
            Is_Sync_with_Household__c=false,
            Does_your_spouse_earn_an_income__pc = 'Yes',
            spouse_s_approximate_annual_income__pc = 2000,
            FinServ__MaritalStatus__pc = 'Married / Defacto (to applicant 2)',
            Year__pc = '1',            
            Months__pc = '1',
            Year_1__pc = '1',
            Months_1__pc = '1',
            Relationship_with_Applicant_1__c='Client',
            PersonTitle = 'Mr.',
            Phone = '0400000000',
            Security_Question__pc = 'Mothers maiden name',
            Security_Answer__pc = 'qwerty',
            Rental_Amount__pc = 500,
            Rental_or_Board_paid__pc =  50,
            Education_ChildCare_SchoolFees_Uniform__pc = 12,
            Maintenance_If_pay_child_maintenance__pc =  25,
            Other_loans_and_or_debt_commitments__pc = 24,
            Education_public_and_private__pc  = 10,
            Food_Groceries_Meat_Fruit_Vegetabl__pc = 100,
            Living_Situation__pc = 'Renting',
            Citizenship_Status__pc = 'Australian Citizen',
            FinServ__Gender__pc = 'Male',
            Transport_Public_Petrol_Registration__pc = 100,
            Medical_Private_Health_Insurance_Ong__pc = 100,
            Personal_Insurances_life_and_income_pro__pc = 100,
            Insurances_Home_Personal_Voluntary__pc = 100,
            Utilities__pc = 100,
            Driver_s_licence_state_Territory__pc = 'Queensland',
            Connections_Phone_Mobile_Internet_C__pc = 200,
            FinServ__NumberOfChildren__pc = 3
        );
        
        accList.add(accPerson);
        accList.add(acc2Person);
        insert accList;
        
        Account accChild1= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test Child',
            LastName='Test LName',
            PersonEmail='test@yahoo.com',
            Is_Sync_with_Household__c=false,
            Child_Age__pc = '1 Year',
            Relationship_with_Applicant_1__c='Dependent',
            Dependent_Parent__c = accPerson.Id
        );
        
        insert accChild1;
        
        List<FinServ__AssetsAndLiabilities__c> assetsList = new List<FinServ__AssetsAndLiabilities__c>();
        List<FinServ__AssetsAndLiabilities__c> liabilitiesList = new List<FinServ__AssetsAndLiabilities__c>();
        
        
        FinServ__AssetsAndLiabilities__c one = new FinServ__AssetsAndLiabilities__c();
        one.Name = 'Asset';
        one.FinServ__AssetsAndLiabilitiesType__c = 'Superannuation';
        one.FinServ__Ownership__c = 'joint';
        one.FinServ__PrimaryOwner__c = accPerson.Id;
        
        FinServ__AssetsAndLiabilities__c oneO = new FinServ__AssetsAndLiabilities__c();
        oneO.Name = 'Asset';
        oneO.Institution__c = 'tmcu';
        oneO.Value__c = 123;
        oneO.FinServ__AssetsAndLiabilitiesType__c = 'Superannuation';
        oneO.FinServ__Ownership__c = 'Applicant 1';
        oneO.FinServ__PrimaryOwner__c = accPerson.Id;
        
        FinServ__AssetsAndLiabilities__c oneO1 = new FinServ__AssetsAndLiabilities__c();
        oneO1.Name = 'Asset';
        oneO1.Institution__c = 'tmcu';
        oneO1.Value__c = 123;
        oneO1.FinServ__AssetsAndLiabilitiesType__c = 'Superannuation';
        oneO1.FinServ__Ownership__c = 'Joint (non-applicant)';
        oneO1.FinServ__PrimaryOwner__c = accPerson.Id;
        
        
        
        FinServ__AssetsAndLiabilities__c Two = new FinServ__AssetsAndLiabilities__c();
        Two.Name = 'Asset';
        Two.FinServ__AssetsAndLiabilitiesType__c = 'Investment Property';
        Two.FinServ__Ownership__c = 'Applicant 2';
        Two.FinServ__PrimaryOwner__c = accPerson.Id;
        
        FinServ__AssetsAndLiabilities__c Three = new FinServ__AssetsAndLiabilities__c();
        Three.Name = 'Asset';
        Three.FinServ__AssetsAndLiabilitiesType__c = 'Investment Property';
        Three.FinServ__Ownership__c = 'Joint (non-applicant)';
        Three.FinServ__PrimaryOwner__c = accPerson.Id;
        
        FinServ__AssetsAndLiabilities__c Four = new FinServ__AssetsAndLiabilities__c();
        Four.Name = 'Asset';
        Four.FinServ__AssetsAndLiabilitiesType__c = 'Commercial Property';
        Four.FinServ__Ownership__c = 'Joint (non-applicant)';
        Four.FinServ__PrimaryOwner__c = accPerson.Id;
        
        FinServ__AssetsAndLiabilities__c five = new FinServ__AssetsAndLiabilities__c();
        five.Name = 'Asset';
        five.FinServ__AssetsAndLiabilitiesType__c = 'Commercial Property';
        five.FinServ__Ownership__c = 'Applicant 2';
        five.Rental_Frequency__c = 'Monthly';
        five.Rental_Amount__c = 200;
        five.Ownership_Share__c = 50;
        five.Other_Ownership_Share__c = 50;
        five.FinServ__PrimaryOwner__c = accPerson.Id;
        
        FinServ__AssetsAndLiabilities__c six = new FinServ__AssetsAndLiabilities__c();
        six.Name = 'Asset';
        six.FinServ__AssetsAndLiabilitiesType__c = 'Commercial Property';
        six.FinServ__Ownership__c = 'Joint';
        six.Rental_Frequency__c = 'Monthly';
        six.Rental_Amount__c = 200;
        six.Ownership_Share__c = 50;
        six.Other_Ownership_Share__c = 50;
        six.FinServ__PrimaryOwner__c = accPerson.Id;
        
        FinServ__AssetsAndLiabilities__c seven = new FinServ__AssetsAndLiabilities__c();
        seven.Name = 'Asset';
        seven.FinServ__AssetsAndLiabilitiesType__c = 'Other';
        seven.Value__c = 1000;
        seven.Rental_Frequency__c = 'Monthly';
        seven.FinServ__Ownership__c = 'Joint';
        seven.Rental_Amount__c = 200;
        seven.Ownership_Share__c = 50;
        seven.FinServ__PrimaryOwner__c = accPerson.Id;
        
        
        FinServ__AssetsAndLiabilities__c eight = new FinServ__AssetsAndLiabilities__c();
        eight.Name = 'Asset';
        eight.FinServ__AssetsAndLiabilitiesType__c = 'Bank Account';
        eight.Value__c = 1000;
        eight.FinServ__Ownership__c ='joint';
        eight.Rental_Frequency__c = 'Monthly';
        eight.Rental_Amount__c = 200;
        eight.Ownership_Share__c = 50;
        eight.FinServ__PrimaryOwner__c = accPerson.Id;
        
        FinServ__AssetsAndLiabilities__c eight1 = new FinServ__AssetsAndLiabilities__c();
        eight1.Name = 'Asset';
        eight1.FinServ__AssetsAndLiabilitiesType__c = 'Bank Account';
        eight1.Value__c = 1000;
        eight1.FinServ__Ownership__c ='Joint (non-applicant)';
        eight1.Rental_Frequency__c = 'Monthly';
        eight1.Rental_Amount__c = 200;
        eight1.Ownership_Share__c = 50;
        eight1.FinServ__PrimaryOwner__c = accPerson.Id;
        
        FinServ__AssetsAndLiabilities__c eight2 = new FinServ__AssetsAndLiabilities__c();
        eight2.Name = 'Asset';
        eight2.FinServ__AssetsAndLiabilitiesType__c = 'Bank Account';
        eight2.Value__c = 1000;
        eight2.FinServ__Ownership__c ='Applicant 1';
        eight2.Rental_Frequency__c = 'Monthly';
        eight2.Rental_Amount__c = 200;
        eight2.Ownership_Share__c = 50;
        eight2.FinServ__PrimaryOwner__c = accPerson.Id;
        
        FinServ__AssetsAndLiabilities__c nine = new FinServ__AssetsAndLiabilities__c();
        nine.Name = 'Asset';
        nine.FinServ__AssetsAndLiabilitiesType__c = 'Investment Property';
        nine.FinServ__Ownership__c = 'Applicant 1';
        nine.Rental_Frequency__c = 'Monthly';
        nine.Rental_Amount__c = 200;
        nine.Ownership_Share__c = 50;
        nine.FinServ__PrimaryOwner__c = accPerson.Id;
        
        
        FinServ__AssetsAndLiabilities__c ten = new FinServ__AssetsAndLiabilities__c();
        ten.Name = 'Asset';
        ten.FinServ__AssetsAndLiabilitiesType__c = 'Investment Property';
        ten.FinServ__Ownership__c = 'Joint';
        ten.Rental_Frequency__c = 'Monthly';
        ten.Rental_Amount__c = 200;
        ten.Ownership_Share__c = 50;
        ten.FinServ__PrimaryOwner__c = accPerson.Id;
        
        FinServ__AssetsAndLiabilities__c ten1 = new FinServ__AssetsAndLiabilities__c();
        ten1.Name = 'Asset';
        ten1.FinServ__AssetsAndLiabilitiesType__c = 'Commercial Property';
        ten1.FinServ__Ownership__c = 'Applicant 1';
        ten1.Rental_Frequency__c = 'Monthly';
        ten1.Rental_Amount__c = 200;
        ten1.Ownership_Share__c = 50;
        ten1.FinServ__PrimaryOwner__c = accPerson.Id;
        
        
        
        assetsList.add(one);
        assetsList.add(oneO);
        assetsList.add(oneO1);
        assetsList.add(two);
        assetsList.add(Three);
        assetsList.add(Four);
        assetsList.add(five);
        assetsList.add(six);
        assetsList.add(seven);
        assetsList.add(eight);
        assetsList.add(eight1);
        assetsList.add(eight2);
        assetsList.add(nine);
        assetsList.add(ten);
        assetsList.add(ten1);
        
        insert assetsList;
        
        
        FinServ__AssetsAndLiabilities__c one1 = new FinServ__AssetsAndLiabilities__c();
        one1.Name = 'Liability';
        one1.FinServ__AssetsAndLiabilitiesType__c = 'Car Loan';
        one1.FinServ__PrimaryOwner__c = accPerson.Id;
        
        FinServ__AssetsAndLiabilities__c Two1 = new FinServ__AssetsAndLiabilities__c();
        Two1.Name = 'Liability';
        Two1.FinServ__AssetsAndLiabilitiesType__c = 'Home Loan/Mortgage';
        Two1.FinServ__PrimaryOwner__c = accPerson.Id;
        
        FinServ__AssetsAndLiabilities__c three1 = new FinServ__AssetsAndLiabilities__c();
        three1.Name = 'Liability';
        three1.FinServ__AssetsAndLiabilitiesType__c = 'Bank Account';
        three1.FinServ__PrimaryOwner__c = accPerson.Id;
        
        FinServ__AssetsAndLiabilities__c three2 = new FinServ__AssetsAndLiabilities__c();
        three2.Name = 'Liability';
        three2.FinServ__AssetsAndLiabilitiesType__c = 'Car Lease';
        three2.Institution__c = 'tmcu';
        three2.Value__c = 1000;
        three2.Interest_Rate__c = 14;
        three2.Repayment_Frequency__c = 'Monthly';
        three2.Repayment_Type__c = 'Interest only';
        three2.FinServ__Ownership__c = 'Joint';
        three2.Ownership_Share__c = 50;
        three2.Other_Ownership_Share__c = 50;
        three2.FinServ__PrimaryOwner__c = accPerson.Id;
        
        
        FinServ__AssetsAndLiabilities__c three3 = new FinServ__AssetsAndLiabilities__c();
        three3.Name = 'Liability';
        three3.FinServ__AssetsAndLiabilitiesType__c = 'Credit Card / Store Card';
        three3.Institution__c = 'tmcu';
        three3.Value__c = 1000;
        three3.Limit__c = 10000;
        three3.Interest_Rate__c = 14;
        three3.Rental_Amount__c = 1000;
        three3.Repayment_Frequency__c = 'Monthly';
        three3.Repayment_Type__c = 'Interest only';
        three3.Rental_Frequency__c = 'Fortnightly';
        three3.FinServ__Ownership__c = 'Joint';
        three3.Ownership_Share__c = 50;
        three3.Other_Ownership_Share__c = 50;
        three3.FinServ__PrimaryOwner__c = accPerson.Id;
        
        
        
        liabilitiesList.add(one1);
        liabilitiesList.add(Two1);
        liabilitiesList.add(three1);
        liabilitiesList.add(three2);
        liabilitiesList.add(three3);
        
        //insert liabilitiesList;
        
        
        Account Ac = [Select Id,PersonContactId from Account Where Id =: accPerson.Id];
        
        System.debug('acid'+Ac.PersonContactId);
        opportunity op1 = new Opportunity()	;
        op1.Name = 'testing';
        op1.AccountId = acc.Id;
        op1.Applicant_1__c = accPerson.Id;
        op1.Applicant_2__c = acc2Person.Id;
        op1.Preferred_repayment_frequency__c = 'Monthly';  
        op1.Loan_Amount__c = 560;
        op1.StageName = 'Working';
        op1.Application_Supporting_Notes__c = 'hello';
        op1.CloseDate = System.today();
        insert op1;
        
        
        opportunity opanother = new Opportunity()	;
        opanother.Name = 'testing another';
        opanother.AccountId = acc.Id;
        opanother.Applicant_1__c = accPerson.Id;
        opanother.Preferred_repayment_frequency__c = 'Monthly';  
        opanother.Loan_Amount__c = 560;
        opanother.StageName = 'Working';
        opanother.Application_Supporting_Notes__c = 'hello';
        opanother.CloseDate = System.today();
        insert opanother;
        
        
        Opportunity oppUpdate = [SELECT Applicant_1__c, Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                           FROM Opportunity WHERE Id = : op1.id limit 1];
       
        ParkerLaneLoanController.upsertOppAssetsAndLiabilities(assetsList, liabilitiesList, op1.Id, true, true);
       
        
        FinServ__Employment__c emp1 =New FinServ__Employment__c();
        emp1.Name = 'test';
        emp1.FinServ__EmploymentStatus__c = 'Full time permanent';
        emp1.FinServ__Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        emp1.Years__c = 2;
        emp1.Work_Overtime_amount__c = 250;
        emp1.Commission_or_Bonus_amount__c = 520;
        emp1.Allowance_Amount__c = 250;
        emp1.Last_year_net_profit__c = 250;
        emp1.Months__c= 2;
        emp1.Source_Document__c = 'Mogo';
        emp1.Verified_Income_Amount__c = 1210;
        emp1.Verified_Income_Frequency__c = 'Monthly';
        emp1.Years_1_Previous__c = 2;
        emp1.Months_1_Previous__c = 2;
        emp1.FinServ__EndDate__c = system.today();
        emp1.Is_Primary__c = true;
        insert emp1;
        
        System.debug('empoyeent one ++++++'+emp1);
        System.debug('empoyeent one ++++++'+emp1.Verified_Income_Amount__c);
        System.debug('empoyeent one ++++++'+emp1.Source_Document__c);
        
        FinServ__Employment__c empQ =New FinServ__Employment__c();
        empQ.Name = 'test';
        empQ.FinServ__EmploymentStatus__c = 'Self Employed / Contractor';
        empQ.FinServ__Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        empQ.Years__c = 2;
        empQ.Work_Overtime_amount__c = 250;
        empQ.Commission_or_Bonus_amount__c = 520;
        empQ.Allowance_Amount__c = 250;
        empQ.Last_year_net_profit__c = 250;
        empQ.Months__c= 2;
        empQ.Source_Document__c = 'Pay Slip';
        empQ.Verified_Income_Amount__c = 0;
        empQ.Verified_Income_Frequency__c = 'Monthly';
        empQ.Years_1_Previous__c = 2;
        empQ.Months_1_Previous__c = 2;
        empQ.FinServ__EndDate__c = system.today();
        empQ.Is_Primary__c = true;
        insert empQ;
        
        
        FinServ__Employment__c emp2 =New FinServ__Employment__c();
        emp2.Name = 'test1';
        emp2.FinServ__EmploymentStatus__c = 'New Start Allowance';
        emp2.FinServ__Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        emp2.work_Overtime_amount__c = 250;
        emp2.Commission_or_Bonus_amount__c = 520;
        emp2.Source_Document__c = 'Pay Slip';
        emp2.Verified_Income_Amount__c = 0;
        emp2.Verified_Income_Frequency__c = 'Monthly';
        emp2.Allowance_Amount__c = 250;
        emp2.Last_year_net_profit__c = 250;
        emp2.Years__c = 3;
        emp2.Months__c= 2;
        emp2.Years_1_Previous__c = 3;
        emp2.Months_1_Previous__c = 2;
        emp2.Is_Primary__c = false;
        insert emp2;
        
        FinServ__Employment__c emp3 =New FinServ__Employment__c();
        emp3.Name = 'test1';
        emp3.FinServ__EmploymentStatus__c = 'Pension';
        emp3.FinServ__Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        emp3.work_Overtime_amount__c = 250;
        emp3.Commission_or_Bonus_amount__c = 520;
        emp3.Source_Document__c = 'Pay Slip';
        emp3.Verified_Income_Amount__c = 0;
        emp3.Verified_Income_Frequency__c = 'Monthly';
        emp3.Allowance_Amount__c = 250;
        emp3.Last_year_net_profit__c = 250;
        emp3.Years__c = 3;
        emp3.Months__c= 2;
        emp3.Years_1_Previous__c = 3;
        emp3.Months_1_Previous__c = 2;
        emp3.Is_Primary__c = false;
        insert emp3;
        
        FinServ__Employment__c emp4 =New FinServ__Employment__c();
        emp4.Name = 'test1';
        emp4.FinServ__EmploymentStatus__c = 'Rental Income';
        emp4.FinServ__Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        emp4.work_Overtime_amount__c = 250;
        emp4.Commission_or_Bonus_amount__c = 520;
        emp4.Allowance_Amount__c = 250;
        emp4.Source_Document__c = 'Pay Slip';
        emp4.Verified_Income_Amount__c = 0;
        emp4.Verified_Income_Frequency__c = 'Monthly';
        emp4.Last_year_net_profit__c = 250;
        emp4.Years__c = 3;
        emp4.Months__c= 2;
        emp4.Years_1_Previous__c = 3;
        emp4.Months_1_Previous__c = 2;
        emp4.Is_Primary__c = false;
        insert emp4;
        
        FinServ__Employment__c emp5 =New FinServ__Employment__c();
        emp5.Name = 'test1';
        emp5.FinServ__EmploymentStatus__c = 'Dividends or Annuity';
        emp5.FinServ__Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        emp5.work_Overtime_amount__c = 250;
        emp5.Commission_or_Bonus_amount__c = 520;
        emp5.Allowance_Amount__c = 250;
        emp5.Source_Document__c = 'Pay Slip';
        emp5.Verified_Income_Amount__c = 0;
        emp5.Verified_Income_Frequency__c = 'Monthly';
        emp5.Last_year_net_profit__c = 250;
        emp5.Years__c = 3;
        emp5.Months__c= 2;
        emp5.Years_1_Previous__c = 3;
        emp5.Months_1_Previous__c = 2;
        emp5.Is_Primary__c = false;
        insert emp5;
        
        FinServ__Employment__c emp6 =New FinServ__Employment__c();
        emp6.Name = 'test1';
        emp6.FinServ__EmploymentStatus__c = 'Family Tax Benefits';
        emp6.FinServ__Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        emp6.work_Overtime_amount__c = 250;
        emp6.Commission_or_Bonus_amount__c = 520;
        emp6.Allowance_Amount__c = 250;
        emp6.Last_year_net_profit__c = 250;
        emp6.Source_Document__c = 'Pay Slip';
        emp6.Verified_Income_Amount__c = 0;
        emp6.Verified_Income_Frequency__c = 'Monthly';
        emp6.Years__c = 3;
        emp6.Months__c= 2;
        emp6.Is_Primary__c = false;
        insert emp6;
        
        FinServ__Employment__c emp7 =New FinServ__Employment__c();
        emp7.Name = 'test1';
        emp7.FinServ__EmploymentStatus__c = 'Disability Pension';
        emp7.FinServ__Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        emp7.work_Overtime_amount__c = 250;
        emp7.Source_Document__c = 'Pay Slip';
        emp7.Verified_Income_Amount__c = 0;
        emp7.Verified_Income_Frequency__c = 'Monthly';
        emp7.Commission_or_Bonus_amount__c = 520;
        emp7.Allowance_Amount__c = 250;
        emp7.Last_year_net_profit__c = 250;
        emp7.Years__c = 3;
        emp7.Months__c= 2;
        emp7.Years_1_Previous__c = 3;
        emp7.Months_1_Previous__c = 2;
        emp7.Is_Primary__c = false;
        insert emp7;
        
        FinServ__Employment__c emp8 =New FinServ__Employment__c();
        emp8.Name = 'test1';
        emp8.FinServ__EmploymentStatus__c = 'Carer’s Pension';
        emp8.FinServ__Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        emp8.work_Overtime_amount__c = 250;
        emp8.Commission_or_Bonus_amount__c = 520;
        emp8.Source_Document__c = 'Pay Slip';
        emp8.Verified_Income_Amount__c = 0;
        emp8.Verified_Income_Frequency__c = 'Monthly';
        emp8.Allowance_Amount__c = 250;
        emp8.Last_year_net_profit__c = 250;
        emp8.Years__c = 3;
        emp8.Months__c= 2;
        emp8.Years_1_Previous__c = 3;
        emp8.Months_1_Previous__c = 2;
        emp8.Is_Primary__c = false;
        insert emp8;
        
        FinServ__Employment__c emp9 =New FinServ__Employment__c();
        emp9.Name = 'test1';
        emp9.FinServ__EmploymentStatus__c = 'Workcover Workers / Compensation';
        emp9.FinServ__Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        emp9.work_Overtime_amount__c = 250;
        emp9.Commission_or_Bonus_amount__c = 520;
		emp9.Source_Document__c = 'Pay Slip';
        emp9.Verified_Income_Amount__c = 0;
        emp9.Verified_Income_Frequency__c = 'Monthly';        
        emp9.Allowance_Amount__c = 250;
        emp9.Last_year_net_profit__c = 250;
        emp9.Years__c = 3;
        emp9.Months__c= 2;
        emp9.Years_1_Previous__c = 3;
        emp9.Months_1_Previous__c = 2;
        emp9.Is_Primary__c = false;
        insert emp9;
        
        FinServ__Employment__c emp10 =New FinServ__Employment__c();
        emp10.Name = 'test1';
        emp10.FinServ__EmploymentStatus__c = 'Other';
        emp10.FinServ__Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        emp10.work_Overtime_amount__c = 250;
        emp10.Commission_or_Bonus_amount__c = 520;
        emp10.Allowance_Amount__c = 250;
        emp10.Source_Document__c = 'Pay Slip';
        emp10.Verified_Income_Amount__c = 0;
        emp10.Verified_Income_Frequency__c = 'Monthly';
        emp10.Last_year_net_profit__c = 250;
        emp10.Years__c = 3;
        emp10.Months__c= 2;
        emp10.Years_1_Previous__c = 3;
        emp10.Months_1_Previous__c = 2;
        emp10.Is_Primary__c = false;
        insert emp10;
        
        FinServ__Employment__c emp11 =New FinServ__Employment__c();
        emp11.Name = 'test1';
        emp11.FinServ__EmploymentStatus__c = 'Child Support';
        emp11.FinServ__Contact__c = oppUpdate.Applicant_1__r.PersonContactId;
        emp11.Source_Document__c = 'Pay Slip';
        emp11.Verified_Income_Amount__c = 0;
        emp11.Verified_Income_Frequency__c = 'Monthly';
        emp11.work_Overtime_amount__c = 250;
        emp11.Commission_or_Bonus_amount__c = 520;
        emp11.Allowance_Amount__c = 250;
        emp11.Last_year_net_profit__c = 250;
        emp11.Years__c = 3;
        emp11.Months__c= 2;
        emp11.Years_1_Previous__c = 3;
        emp11.Months_1_Previous__c = 2;
        emp11.Is_Primary__c = false;
        insert emp11;
        
        FinServ__Employment__c forEmployment2_1 =New FinServ__Employment__c();
        forEmployment2_1.Name = 'test';
        forEmployment2_1.FinServ__EmploymentStatus__c = 'Full time permanent';
        forEmployment2_1.FinServ__Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        forEmployment2_1.Years__c = 2;
        forEmployment2_1.Work_Overtime_amount__c = 250;
        forEmployment2_1.Source_Document__c = 'Mogo';
        forEmployment2_1.Verified_Income_Amount__c = 1210;
        forEmployment2_1.Verified_Income_Frequency__c = 'Monthly';
        forEmployment2_1.Commission_or_Bonus_amount__c = 520;
        forEmployment2_1.Allowance_Amount__c = 250;
        forEmployment2_1.Last_year_net_profit__c = 250;
        forEmployment2_1.Months__c= 2;
        forEmployment2_1.Years_1_Previous__c = 2;
        forEmployment2_1.Months_1_Previous__c = 2;
        forEmployment2_1.FinServ__EndDate__c = system.today();
        forEmployment2_1.Is_Primary__c = true;
        insert forEmployment2_1;
        
        FinServ__Employment__c forEmployment2_2 =New FinServ__Employment__c();
        forEmployment2_2.Name = 'test';
        forEmployment2_2.FinServ__EmploymentStatus__c = 'Self Employed / Contractor';
        forEmployment2_2.FinServ__Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        forEmployment2_2.Years__c = 2;
        forEmployment2_2.Work_Overtime_amount__c = 250;
        forEmployment2_2.Commission_or_Bonus_amount__c = 520;
        forEmployment2_2.Allowance_Amount__c = 250;
        forEmployment2_2.Last_year_net_profit__c = 250;
        forEmployment2_2.Months__c= 2;
        forEmployment2_2.Years_1_Previous__c = 2;
        forEmployment2_2.Months_1_Previous__c = 2;
        forEmployment2_2.FinServ__EndDate__c = system.today();
        forEmployment2_2.Is_Primary__c = true;
        insert forEmployment2_2;
        
        
        FinServ__Employment__c forEmployment2_3 =New FinServ__Employment__c();
        forEmployment2_3.Name = 'test1';
        forEmployment2_3.FinServ__EmploymentStatus__c = 'New Start Allowance';
        forEmployment2_3.FinServ__Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        forEmployment2_3.work_Overtime_amount__c = 250;
        forEmployment2_3.Commission_or_Bonus_amount__c = 520;
        forEmployment2_3.Allowance_Amount__c = 250;
        forEmployment2_3.Last_year_net_profit__c = 250;
        forEmployment2_3.Years__c = 3;
        forEmployment2_3.Months__c= 2;
        forEmployment2_3.Years_1_Previous__c = 3;
        forEmployment2_3.Months_1_Previous__c = 2;
        forEmployment2_3.Is_Primary__c = false;
        insert forEmployment2_3;
        
        FinServ__Employment__c forEmployment2_4 =New FinServ__Employment__c();
        forEmployment2_4.Name = 'test1';
        forEmployment2_4.FinServ__EmploymentStatus__c = 'Pension';
        forEmployment2_4.FinServ__Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        forEmployment2_4.work_Overtime_amount__c = 250;
        forEmployment2_4.Commission_or_Bonus_amount__c = 520;
        forEmployment2_4.Allowance_Amount__c = 250;
        forEmployment2_4.Last_year_net_profit__c = 250;
        forEmployment2_4.Years__c = 3;
        forEmployment2_4.Months__c= 2;
        forEmployment2_4.Years_1_Previous__c = 3;
        forEmployment2_4.Months_1_Previous__c = 2;
        forEmployment2_4.Is_Primary__c = false;
        insert forEmployment2_4;
        
        FinServ__Employment__c forEmployment2_5 =New FinServ__Employment__c();
        forEmployment2_5.Name = 'test1';
        forEmployment2_5.FinServ__EmploymentStatus__c = 'Rental Income';
        forEmployment2_5.FinServ__Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        forEmployment2_5.work_Overtime_amount__c = 250;
        forEmployment2_5.Commission_or_Bonus_amount__c = 520;
        forEmployment2_5.Allowance_Amount__c = 250;
        forEmployment2_5.Last_year_net_profit__c = 250;
        forEmployment2_5.Years__c = 3;
        forEmployment2_5.Months__c= 2;
        forEmployment2_5.Years_1_Previous__c = 3;
        forEmployment2_5.Months_1_Previous__c = 2;
        forEmployment2_5.Is_Primary__c = false;
        insert forEmployment2_5;
        
        FinServ__Employment__c forEmployment2_6 =New FinServ__Employment__c();
        forEmployment2_6.Name = 'test1';
        forEmployment2_6.FinServ__EmploymentStatus__c = 'Dividends or Annuity';
        forEmployment2_6.FinServ__Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        forEmployment2_6.work_Overtime_amount__c = 250;
        forEmployment2_6.Commission_or_Bonus_amount__c = 520;
        forEmployment2_6.Allowance_Amount__c = 250;
        forEmployment2_6.Last_year_net_profit__c = 250;
        forEmployment2_6.Years__c = 3;
        forEmployment2_6.Months__c= 2;
        forEmployment2_6.Years_1_Previous__c = 3;
        forEmployment2_6.Months_1_Previous__c = 2;
        forEmployment2_6.Is_Primary__c = false;
        insert forEmployment2_6;
        
        
        
        FinServ__Employment__c forEmployment2_8 =New FinServ__Employment__c();
        forEmployment2_8.Name = 'test1';
        forEmployment2_8.FinServ__EmploymentStatus__c = 'Disability Pension';
        forEmployment2_8.FinServ__Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        forEmployment2_8.work_Overtime_amount__c = 250;
        forEmployment2_8.Commission_or_Bonus_amount__c = 520;
        forEmployment2_8.Allowance_Amount__c = 250;
        forEmployment2_8.Last_year_net_profit__c = 250;
        forEmployment2_8.Years__c = 3;
        forEmployment2_8.Months__c= 2;
        forEmployment2_8.Years_1_Previous__c = 3;
        forEmployment2_8.Months_1_Previous__c = 2;
        forEmployment2_8.Is_Primary__c = false;
        insert forEmployment2_8;
        
        FinServ__Employment__c forEmployment2_9 =New FinServ__Employment__c();
        forEmployment2_9.Name = 'test1';
        forEmployment2_9.FinServ__EmploymentStatus__c = 'Carer’s Pension';
        forEmployment2_9.FinServ__Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        forEmployment2_9.work_Overtime_amount__c = 250;
        forEmployment2_9.Commission_or_Bonus_amount__c = 520;
        forEmployment2_9.Allowance_Amount__c = 250;
        forEmployment2_9.Last_year_net_profit__c = 250;
        forEmployment2_9.Years__c = 3;
        forEmployment2_9.Months__c= 2;
        forEmployment2_9.Years_1_Previous__c = 3;
        forEmployment2_9.Months_1_Previous__c = 2;
        forEmployment2_9.Is_Primary__c = false;
        insert forEmployment2_9;
        
        FinServ__Employment__c forEmployment2_10 =New FinServ__Employment__c();
        forEmployment2_10.Name = 'test1';
        forEmployment2_10.FinServ__EmploymentStatus__c = 'Workcover Workers / Compensation';
        forEmployment2_10.FinServ__Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        forEmployment2_10.work_Overtime_amount__c = 250;
        forEmployment2_10.Commission_or_Bonus_amount__c = 520;
        forEmployment2_10.Allowance_Amount__c = 250;
        forEmployment2_10.Last_year_net_profit__c = 250;
        forEmployment2_10.Years__c = 3;
        forEmployment2_10.Months__c= 2;
        forEmployment2_10.Years_1_Previous__c = 3;
        forEmployment2_10.Months_1_Previous__c = 2;
        forEmployment2_10.Is_Primary__c = false;
        insert forEmployment2_10;
        
        FinServ__Employment__c forEmployment2_11 =New FinServ__Employment__c();
        forEmployment2_11.Name = 'test1';
        forEmployment2_11.FinServ__EmploymentStatus__c = 'Other';
        forEmployment2_11.FinServ__Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        forEmployment2_11.work_Overtime_amount__c = 250;
        forEmployment2_11.Commission_or_Bonus_amount__c = 520;
        forEmployment2_11.Allowance_Amount__c = 250;
        forEmployment2_11.Last_year_net_profit__c = 250;
        forEmployment2_11.Years__c = 3;
        forEmployment2_11.Months__c= 2;
        forEmployment2_11.Years_1_Previous__c = 3;
        forEmployment2_11.Months_1_Previous__c = 2;
        forEmployment2_11.Is_Primary__c = false;
        insert forEmployment2_11;
        
        FinServ__Employment__c forEmployment2_12 =New FinServ__Employment__c();
        forEmployment2_12.Name = 'test1';
        forEmployment2_12.FinServ__EmploymentStatus__c = 'Child Support';
        forEmployment2_12.FinServ__Contact__c = oppUpdate.Applicant_2__r.PersonContactId;
        forEmployment2_12.work_Overtime_amount__c = 250;
        forEmployment2_12.Commission_or_Bonus_amount__c = 520;
        forEmployment2_12.Allowance_Amount__c = 250;
        forEmployment2_12.Last_year_net_profit__c = 250;
        forEmployment2_12.Years__c = 3;
        forEmployment2_12.Months__c= 2;
        forEmployment2_12.Years_1_Previous__c = 3;
        forEmployment2_12.Months_1_Previous__c = 2;
        forEmployment2_12.Is_Primary__c = false;
        insert forEmployment2_12;
        
        
        
        Quote Q1 = new Quote();
        Q1.Name = 'Zeal';
        Q1.Application__c = true;
        Q1.OpportunityId = op1.Id;
        Q1.Loan_Term__c = 60;
        Q1.Repayment_Frequency_Options__c  = 'Monthly';
        Q1.Application__c = true;
        insert Q1;
        
       
        Quote Q2 = new Quote();
        Q2.Name = 'Zeal';
        Q2.Application__c = true;
        Q2.OpportunityId = opanother.Id;
        Q2.Loan_Term__c = 60;
        Q2.Repayment_Frequency_Options__c  = 'Monthly';
        Q2.Application__c = true;
        insert Q2;
        
        
        contact con11 =  new Contact();
        con11.Title = 'Mr.';
        con11.FirstName = 'Test';
        con11.MiddleName = 'testinng';
        con11.LastName = 'tesLast';
        con11.Email = 'test@yahoo.com';
        con11.Phone = '0400000000';
        con11.FinServ__NumberOfChildren__c = 2;
        con11.Security_Question__c = 'Mothers maiden name';
        con11.Security_Answer__c = 'qwer';
        con11.Rental_Amount__c = 50;
        con11.Rental_or_Board_paid__c =  50;
        con11.Education_public_and_private__c  = 10;
        con11.Food_Groceries_Meat_Fruit_Vegetabl__c = 100;
        con11.Living_Situation__c = 'Renting';
        con11.Citizenship_Status__c = 'Australian Citizen';
        con11.FinServ__Gender__c = 'Male';
       // insert con11;
        System.debug('con1111='+con11.Id);
        
        contact con12 =  new Contact();
        con12.Title = 'Mr.';
        con12.FirstName = 'Test1';
        con12.MiddleName = 'testinng1';
        con12.LastName = 'tesLast1';
        con12.Email = 'test1@yahoo.com';
        con12.Phone = '0400000000';
        con12.Rental_Amount__c = 50.0;
        con12.Rental_or_Board_paid__c = 50.0;
        con12.FinServ__NumberOfChildren__c = 5;
        con12.Age_Child_1__c = 10;
        con12.Age_Child_2__c = 12;
        con12.Age_Child_3__c = 13;
        con12.Age_Child_4__c = 16;
        con12.Age_Child_5__c = 17;
        con12.Education_ChildCare_SchoolFees_Uniform__c = 12;
        con12.Maintenance_If_pay_child_maintenance__c =  25;
        con12.Other_loans_and_or_debt_commitments__c = 24;
        con12.Education_public_and_private__c  = 10;
        con12.Food_Groceries_Meat_Fruit_Vegetabl__c = 100;
        con12.Living_Situation__c = 'Renting';
        con12.Citizenship_Status__c = 'Australian Citizen';
        con12.FinServ__Gender__c = 'Male';
        con12.Transport_Public_Petrol_Registration__c = 0;
        
        //insert con12;
    }
    
    @isTest
    public static void testZeal(){
        
        Opportunity oppUpdate = [SELECT Applicant_1__c, Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                           FROM Opportunity WHERE Name = 'testing' limit 1];
        
                
        Map<String, Contact> empMap = new Map<String, Contact>();
        
        test.startTest();
        EzeeAPIController.fetchAssetsAndLiabilities(oppUpdate.Id);
        EzeeAPIController.fetchDetails(oppUpdate.Id);
        empMap = EzeeAPIController.fetchEmploymentDetails(oppUpdate.id);
        EzeeAPIController.makeCallout(oppUpdate.Id, 'prtial');
        EzeeAPIController.assetsMap();
        EzeeAPIController.assetsType();
        test.stopTest();
        
    }
    
    @isTest
    public static void testZealSec(){
        Opportunity oppUpdate = [SELECT Applicant_1__c,  Applicant_1__r.PersonContactId
                                 FROM Opportunity WHERE Name = 'testing another' limit 1];
        
        Map<String, Contact> empMap = new Map<String, Contact>();
        
        test.startTest();
        EzeeAPIController.fetchAssetsAndLiabilities(oppUpdate.Id);
        EzeeAPIController.fetchDetails(oppUpdate.Id);
        empMap = EzeeAPIController.fetchEmploymentDetails(oppUpdate.id);
        EzeeAPIController.makeCallout(oppUpdate.Id, 'prtial');
        EzeeAPIController.assetsMap();
        EzeeAPIController.assetsType();
        test.stopTest();
        
    }
    
}