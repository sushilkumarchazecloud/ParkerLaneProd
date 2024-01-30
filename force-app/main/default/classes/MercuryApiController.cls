public class MercuryApiController{
    
    public static Boolean isApplicant2{get;set;}
    
    public static Contact livingExpensesDetails{get;set;}
    public static Map<String, Contact> employmentDetails{get;set;}
    public static EmploymentStatus applicant1EmpStatus{get;set;}
    public static EmploymentStatus applicant2EmpStatus{get;set;}
    public static List<FinServ__AssetsAndLiabilities__c> assets{get;set;}
    public static List<FinServ__AssetsAndLiabilities__c> liabilities{get;set;}
    public static Map<String, List<FinServ__AssetsAndLiabilities__c>> assetsAndLiabilities{get;set;}
    public static OpportunityContacts oppContacts{get;set;}
    public static Quote selectedQuote{get;set;}
    public static Boolean isResident;
    public static String advisor;
    
    
    @AuraEnabled
    public static String makeCallout(String oppId){
        isApplicant2 = false;
        //advisor = [SELECT Username__c, Userid__c FROM MercuryUsers__c where userid__c =: System.Userinfo.getUserId()][0].Username__c;
        advisor = MercuryUsers__c.getValues(System.Userinfo.getUserId()).Username__c;
        System.debug(advisor);
        String token = '41b5d141-d090-4636-bbb1-eb1efa93ad2e';
        
        String app1personId;
        String app2personId;
        try{
            String body = fetchDetails(oppId);
            body = getPersonInfo(oppContacts.contact1,applicant1EmpStatus,true);
            System.debug('body '+body);
            app1personId = mercuryCallout('https://apis.connective.com.au/mercury/v1/' + token + '/contacts', body);
            
            if(app1personId.contains('Error'))
                return 'Error : Please review Applicant 1 information';
                
            if(isApplicant2){
                body = getPersonInfo(oppContacts.contact2,applicant2EmpStatus,false);
                app2personId = mercuryCallout('https://apis.connective.com.au/mercury/v1/' + token + '/contacts', body);
            
                if(app2personId.contains('Error'))
                    return 'Error : Please review Applicant 2 information';
            }
            
            body = getOpportunityDetail(app1personId,app2personId);
            System.debug('====> oppBody '+body);
            String oppStatus = mercuryCallout('https://apis.connective.com.au/mercury/v1/' + token + '/opportunities', body);
            if(oppStatus.contains('Error'))
                    return 'Error : Please review Opportunity information';
            
            return 'Success';
        }catch(Exception e){
            return 'Error : '+e.getMessage();
        }
    }
    
    public static String mercuryCallout(String endpoint, String body){
        
        HttpRequest req = new HttpRequest();        
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setBody(body);
        req.setHeader('x-api-key','m3nhcHhR7U3ynmmDhdK9Z4c1mvSWjy91aLtZrAtJ');
        req.setHeader('content-type','application/json');
        
        Http http = new Http();
        HTTPResponse res;
        
        if(Test.isRunningTest()){
            res = new HTTPResponse();
            res.setStatusCode(200);
            res.setBody('{"Token":123,"loanPeople":[{"uniqueId": "unique123", "personID":"person123","loanID":"loan123","firstName":"testf","lastName":"testl","gender":"male","email":"test@email.com"},{"personID":"person124","loanID":"loan124","uniqueId": "unique124","firstName":"testf1","lastName":"testl1","gender":"male","email":"test1@email.com"}]}');
            return '{"Token":123,"loanPeople":[{"uniqueId": "unique123", "personID":"person123","loanID":"loan123","firstName":"testf","lastName":"testl","gender":"male","email":"test@email.com"},{"personID":"person124","loanID":"loan124","uniqueId": "unique124","firstName":"testf1","lastName":"testl1","gender":"male","email":"test1@email.com"}]}';
        }else{
            res = http.send(req);
            system.debug('@@ '+res.getBody());
            
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            if((String)result.get('uniqueId') != null){
                return (String)result.get('uniqueId');
            }else{
                return 'Error';
            }
        }
        
    }
    
    public static String fetchDetails(String oppId){
        assets = new List<FinServ__AssetsAndLiabilities__c>();
        liabilities = new List<FinServ__AssetsAndLiabilities__c>(); 
        
        isResident = false;
        employmentDetails = new Map<String, Contact>();
        
        applicant1EmpStatus = new EmploymentStatus();
        applicant2EmpStatus = new EmploymentStatus();
        
        
        livingExpensesDetails = fetchLivingExpensesDetails(oppId);
        employmentDetails = fetchEmploymentDetails(oppId);
        
        applicant1EmpStatus.con = employmentDetails.get('applicant1');
        
        System.debug('+ ==> '+employmentDetails.get('applicant1').FinServ__Employment__r);
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
        
        return null;
    }
    
    public static String getOpportunityDetail(String app1personId,String app2personId){
        String relatedParties =  '"personID": "'+app1personId+'",'
                                 +'"relationship": "Primary Applicant"';
        
        if(isApplicant2)
            relatedParties = relatedParties+'},{'
                                +'"personID": "'+app2personId+'",'
                                +'"relationship": "Applicant"';
            
        String body = '{'
                        +'"uniqueId": "'+oppContacts.opp.Id+'",'
                        +'"company": "P201322",'
                        +'"isDeleted": false,'
                        +'"deletedByDisplay": "",'
                        +'"createdOn": "' + nowTimeStr() +'",'
                        +'"amount": '+Integer.valueOf(oppContacts.opp.Loan_Amount__c)+','
                        +'"lender": "",'
                        +'"lenderNameShort": "",'
                        +'"lenderDisplayName": "",'
                        +'"status": "Lead",'
                        +'"agent": "'+advisor+'",'
                        +'"personActing": "'+advisor+'",'
                        +'"personResponsible": "",'
                        +'"lenderReference": "",'
                        +'"confirmedSettlementDateDisplay": "",'
                        +'"leadSourceId": "",'
                        +'"discount": 0,'
                        +'"existingAmount": 0,'
                        +'"lmi": 0,'
                        +'"settlementDateConfirmed": false,'
                        +'"transactionType": "'+opportunityType().get(oppContacts.opp.RecordType.Name)+'",'
                        +'"notePadText": "",'
                        +'"partnerReference": "'+oppContacts.opp.FinServ__ReferredByUser__c+'",'
                        +'"nextGenId": "",'
                        +'"workspaceUsers": "",'
                        +'"tranxType": "",'
                        +'"connectiveLodgeId": 0,'
                        +'"peResidualAmount": 0,'
                        +'"peRepaymentAmount": 0,'
                        +'"peEffectiveRate": 0,'
                        +'"peInterestRate": 0,'
                        +'"peBrokerage": 0,'
                        +'"assetDescription": "",'
                        +'"loanTerm": 0,'
                        +'"metaData": "",'
                        +'"agentName": "'+UserInfo.getName()+'",'
                        +'"personActingName": "",'
                        +'"personResponsibleName": "",'
                        +'"partnerName": "Upside Downside Pty Ltd",'
                        +'"lenderComments": "",'
                        +'"sitRep": "",'
                        +'"campaignId": "",'
                        +'"securityValue": 0,'
                        +'"salePrice": 0,'
                        +'"aliApplicationId": "",'
                        +'"metlifeApplicationId": "",'
                        +'"lastUpdated": null,'
                        +'"originationFee": 0,'
                        +'"docFee": 0,'
                        +'"invoiceId": "",'
                        +'"invoicePaymentReceived": false,'
                        +'"invoicePersonName": "",'
                        +'"invoicePersonAddress": "",'
                        +'"invoiceBrokerReference": "",'
                        +'"invoiceCafStatus": "",'
                        +'"applicationPlatform": "",'
                        +'"assets": ['+getAssets()+'],'
                        +'"liabilities": ['+getLiabilities()+'],'
                        +'"opportunityName": "'+oppContacts.opp.Name+'",'
                        +'"relatedParties": [{'+relatedParties+'}]'
                      + '}';    
                       
        
        return body;    
    }
    
    public static Map<String,String> opportunityType(){
    
        Map<String,String> oppType = new Map<String,String>();
        oppType.put('First Home Purchase','Loan');
        oppType.put('Home Loan Construction','Loan');
        oppType.put('Home Loan Purchase','Loan');
        oppType.put('Home Loan Refinance','Loan');
        oppType.put('Investment Property Purchase','Loan');
        oppType.put('Next Home Purchase','Loan');
        oppType.put('Green Loan','PersonalLoans');
        oppType.put('Personal Loan','PersonalLoans');
        oppType.put('Debt Consolidation','PersonalLoans');
        oppType.put('Asset Finance','PlantAndEquipment');
        oppType.put('Commercial Asset Finance','PlantAndEquipment');
        oppType.put('Vehicle Purchase','PlantAndEquipment');
        oppType.put('Commercial Solar Purchase','PlantAndEquipment');
        oppType.put('Commercial Mortgage','CommercialLoans');
        oppType.put('Commercial Property Purchase','CommercialLoans');
        
        return oppType;
    }
    
    public static String getPersonInfo(Contact contact, EmploymentStatus empStatus, Boolean isExpense){
        Integer d = 0;
        Integer mo = 0;
        Integer yr = 0;
        DateTime dt;
        
        Long dob;
        if(contact.Birthdate != null){
            d = contact.Birthdate.day();
            mo = contact.Birthdate.month();
            yr = contact.Birthdate.year();
            dt = DateTime.newInstance(yr, mo, d, 00, 00, 00 );
            dob = dt.getTime();
        }
        
        Decimal months = 0;
        date newDate;
        String empCommenced = '';
        if(empStatus.emp != null){
            months = empStatus.emp.Years__c * 12 + empStatus.emp.Months__c;
            newDate = System.today().addMonths(-(Integer)months);
            d = newDate.day();
            mo = newDate.month();
            yr = newDate.year();
            empCommenced = yr + '-' + mo + '-' + d;
        }
        
        months = Integer.valueOf(contact.Year__c) * 12 + Integer.valueOf(contact.Months__c);
        
        newDate = System.today().addMonths(-(Integer)months);
        d = newDate.day();
        mo = newDate.month();
        yr = newDate.year();
        dt = DateTime.newInstance(yr, mo, d, 00, 00, 00 );
        Long fromDate = dt.getTime();
        
        newDate = System.today();
        d = newDate.day();
        mo = newDate.month();
        yr = newDate.year();
        dt = DateTime.newInstance(yr, mo, d, 00, 00, 00 );
        Long toDate = dt.getTime();
        
        Long fromDatePre = 0;
        if(Integer.valueOf(contact.Year__c) < 3){
            months = Integer.valueOf(contact.Year__c) * 12 + Integer.valueOf(contact.Months__c);
            months += Integer.valueOf(contact.Year_1__c) * 12 + Integer.valueOf(contact.Months_1__c);
            newDate = System.today().addMonths(-(Integer)months);
            d = newDate.day();
            mo = newDate.month();
            yr = newDate.year();
            dt = DateTime.newInstance(yr, mo, d, 00, 00, 00 );
            fromDatePre = dt.getTime();
        }
        
        Long toDatePre = 0;
        if(Integer.valueOf(contact.Year__c) < 3){
            months = Integer.valueOf(contact.Year__c) * 12 + Integer.valueOf(contact.Months__c);
            newDate = System.today().addMonths(-(Integer)months);
            d = newDate.day();
            mo = newDate.month();
            yr = newDate.year();
            dt = DateTime.newInstance(yr, mo, d, 00, 00, 00 );
            toDatePre = dt.getTime();
        }
        
        
        
        String gender = contact.FinServ__Gender__c == 'Male'? 'M' : 'F';
        
        String mstatus = contact.FinServ__MaritalStatus__c.contains('Married') ? 'Married' : contact.FinServ__MaritalStatus__c;
        String body = '{'
                            +'"uniqueId": "'+contact.Id+'",'
                            +'"company": "P201322",'
                            +'"createdBy": "'+advisor+'",'
                            +'"relationship": "Primary Applicant",'
                            +'"firstName": "'+contact.FirstName+'",'
                            +'"lastName": "'+contact.LastName+'",'
                            +'"middleName": "'+contact.MiddleName+'",'
                            +'"title": "'+contact.Title+'",'
                            +'"occupation": "'+empStatus.con.FinServ__Occupation__c+'",'
                            +'"employer": "'+empStatus.emp.Name+'",'
                            +'"jobTitle": "'+empStatus.emp.Job_Title__c+'",'
                            +'"maritalStatus": "'+mstatus+'",'
                            +'"driversLicenceNumber": "'+contact.Govt_Id_Number__c+'",'
                            +'"driversLicenceExpiry": "",'
                            +'"driversLicenceState": "'+stateTypeMap().get(contact.Driver_s_licence_state_Territory__c)+'",'
                            +'"gender": "'+gender+'",'
                            +'"dateOfBirth": '+dob+','
                            +'"employmentStatus": "'+empStatusMap(empStatus)+'",'
                            +'"employmentCommenced": "'+empCommenced+'",'
                            +'"phoneDisplayType1": "Home",'
                            +'"phoneDisplayType2": "Mobile",'
                            +'"phoneDisplayType3": "Business",'
                            +'"phoneDisplayType4": "Business Fax",'
                            +'"addressDisplay": "",'
                            +'"homePhone": "",'
                            +'"businessPhone": "",'
                            +'"mobile": "'+contact.Phone+'",'
                            +'"email": "'+contact.Email+'",'
                            +'"personDataType": "Full",'
                            +'"notes": "",'
                            +'"relationshipManager": "",'
                            +'"annualSalary": '+empStatus.emp.Total_Income_from_Employment__c+','
                            +'"abn": "",'
                            +'"numberOfDependents": '+oppContacts.app1Children.size()+','
                            +'"partnerName": "Upside Downside Pty Ltd",'
                            +'"contactMethods": ['
                                +'{'
                                    +'"contactMethod": "Mobile",'
                                    +'"content": "'+contact.Phone+'",'
                                    +'"modified": true'
                                +'},'
                                +'{'
                                    +'"contactMethod": "Email 1",'
                                    +'"content": "'+contact.Email+'",'
                                    +'"modified": true'
                                +'}'
                            +'],';
                            if(isExpense){
                                body += '"expenses": ['
                                        +'{'
                                            +'"company": "P201322",'
                                            +'"amount": '+livingExpensesDetails.Rental_or_Board_paid__c+','
                                            +'"type": "Rent Paid",'
                                            +'"frequency": "Monthly",'
                                            +'"balance": 0,'
                                            +'"creditLimit": 0,'
                                            +'"comment": ""'
                                        +'},'
                                        +'{'
                                            +'"company": "P201322",'
                                            +'"amount": '+livingExpensesDetails.Education_ChildCare_SchoolFees_Uniform__c+','
                                            +'"type": "Education",'
                                            +'"frequency": "Monthly",'
                                            +'"balance": 0,'
                                            +'"creditLimit": 0,'
                                            +'"comment": ""'
                                        +'},'
                                        +'{'
                                            +'"company": "P201322",'
                                            +'"amount": '+livingExpensesDetails.Insurance_Medical_Health__c+','
                                            +'"type": "Insurance",'
                                            +'"frequency": "Monthly",'
                                            +'"balance": 0,'
                                            +'"creditLimit": 0,'
                                            +'"comment": ""'
                                        +'},'
                                        +'{'
                                            +'"company": "P201322",'
                                            +'"amount": '+livingExpensesDetails.CFCU_Other__c+','
                                            +'"type": "Other",'
                                            +'"frequency": "Monthly",'
                                            +'"balance": 0,'
                                            +'"creditLimit": 0,'
                                            +'"comment": ""'
                                        +'},'
                                        +'{'
                                            +'"company": "P201322",'
                                            +'"amount": '+livingExpensesDetails.Food_Groceries_Meat_Fruit_Vegetabl__c+','
                                            +'"type": "Living Expenses",'
                                            +'"frequency": "Monthly",'
                                            +'"balance": 0,'
                                            +'"creditLimit": 0,'
                                            +'"comment": "Groceries"'
                                        +'},'
                                        +'{'
                                            +'"company": "P201322",'
                                            +'"amount": '+livingExpensesDetails.Clothing_Recreational_Entertainment__c+','
                                            +'"type": "Living Expenses",'
                                            +'"frequency": "Monthly",'
                                            +'"balance": 0,'
                                            +'"creditLimit": 0,'
                                            +'"comment": "Clothing"'
                                        +'},'
                                        +'{'
                                            +'"company": "P201322",'
                                            +'"amount": '+livingExpensesDetails.Property_including_Rates_Utilities_Manag__c+','
                                            +'"type": "Living Expenses",'
                                            +'"frequency": "Monthly",'
                                            +'"balance": 0,'
                                            +'"creditLimit": 0,'
                                            +'"comment": "Property"'
                                        +'},'
                                        +'{'
                                            +'"company": "P201322",'
                                            +'"amount": '+livingExpensesDetails.Transport_Public_Petrol_Registration__c+','
                                            +'"type": "Living Expenses",'
                                            +'"frequency": "Monthly",'
                                            +'"balance": 0,'
                                            +'"creditLimit": 0,'
                                            +'"comment": "Transport"'
                                        +'}'
                                    +'],';
                            }
                            body += '"addresses": ['
                                +'{'
                                    +'"company": "P201322",'
                                    +'"type": "Home",'
                                    +'"streetName": "'+contact.Street__c+'",'
                                    +'"streetNumber": "'+contact.Street_Number__c+'",'
                                    +'"streetType": "",'
                                    +'"city": "'+contact.Suburb__c+'",'
                                    +'"state": "'+stateTypeMap().get(contact.State__c)+'",'
                                    +'"postcode": "'+contact.Postal_Code__c+'",'
                                    +'"country": "Australia",'
                                    +'"unitNumber": "",'
                                    +'"buildingName": "",'
                                    +'"floorNumber": "",'
                                    +'"fromDate": '+fromDate+','
                                    +'"toDate": '+toDate+','
                                    +'"addressBlock": "'+contact.Residential_Address__c+'",'
                                    +'"format": "standard",'
                                    +'"housingSituation": "'+livingSituation().get(contact.Living_Situation__c)+'"'
                                +'},'
                                +'{'
                                    +'"company": "P201322",'
                                    +'"type": "Employer",'
                                    +'"streetName": "'+empStatus.emp.Street__c+'",'
                                    +'"streetNumber": "'+empStatus.emp.Street_Number__c+'",'
                                    +'"streetType": "",'
                                    +'"city": "'+empStatus.emp.Suburb__c+'",'
                                    +'"state": "'+stateTypeMap().get(empStatus.emp.State__c)+'",'
                                    +'"postcode": "'+empStatus.emp.Postal_Code__c+'",'
                                    +'"country": "Australia",'
                                    +'"unitNumber": "",'
                                    +'"buildingName": "",'
                                    +'"floorNumber": "",'
                                    +'"fromDate": null,'
                                    +'"addressBlock": "'+empStatus.emp.FinServ__EmployerAddress__c+'",'
                                    +'"format": "standard"'
                                +'}';
                                if(Integer.valueOf(contact.Year__c) < 3){
                                    body += ',{'
                                            +'"company": "P201322",'
                                            +'"type": "Previous",'
                                            +'"streetName": "'+contact.Street_1__c+'",'
                                            +'"streetNumber": "'+contact.Street_Number_1__c+'",'
                                            +'"streetType": "",'
                                            +'"city": "'+contact.Suburb_1__c+'",'
                                            +'"state": "'+stateTypeMap().get(contact.State_1__c)+'",'
                                            +'"postcode": "'+contact.Postal_Code_1__c+'",'
                                            +'"country": "Australia",'
                                            +'"unitNumber": "",'
                                            +'"buildingName": "",'
                                            +'"floorNumber": "",'
                                            +'"fromDate": '+fromDatePre+','
                                            +'"toDate": '+toDatePre+','
                                            +'"addressBlock": "'+contact.Residential_Address_1__c+'",'
                                            +'"format": "standard",'
                                            +'"housingSituation": "'+livingSituation().get(contact.Living_Situation__c)+'"'
                                        +'}';
                                }
                                if(Integer.valueOf(empStatus.emp.Years__c) < 3){
                                    body += ',{'
                                            +'"company": "P201322",'
                                            +'"type": "Previous Employer",'
                                            +'"streetName": "'+empStatus.emp.Street_1__c+'",'
                                            +'"streetNumber": "'+empStatus.emp.Street_Number_1__c+'",'
                                            +'"streetType": "",'
                                            +'"city": "'+empStatus.emp.Suburb_1__c+'",'
                                            +'"state": "'+stateTypeMap().get(empStatus.emp.State_1__c)+'",'
                                            +'"postcode": "'+empStatus.emp.Postal_Code_1__c+'",'
                                            +'"country": "Australia",'
                                            +'"unitNumber": "",'
                                            +'"buildingName": "",'
                                            +'"floorNumber": "",'
                                            +'"fromDate": null,'
                                            +'"addressBlock": "'+empStatus.emp.Address_1_Previous__c+'",'
                                            +'"format": "standard"'
                                        +'}';
                                }
                            body += '],'
                            +'"categories": [],'
                            +'"countryOfResidency": "AU",'
                            +'"residencyStatus": "'+residencyStatus(contact)+'",'
                            +'"isPermanentResident": '+isResident+','
                            +'"companyType": "",'
                            +'"companyRegisteredIn": "",'
                            +'"fullName": "'+contact.Name+'",'
                            +'"salutationOrFirstName": "'+contact.FirstName+'"'
                        +'}';
                        
        return body;
    }
    
    public static string getAssets(){
        String body = '';
        if(assets != null){
            if(assets.size() > 0){
                for(Integer i=0;i<assets.size();i++){
                    body += '{'
                                +'"uniqueId": "'+assets[i].Id+'",'
                                +'"company": "P201322",'
                                +'"name": "'+assetsMap().get(assets[i].FinServ__AssetsAndLiabilitiesType__c)+'",'
                                +'"type": "'+assetsType().get(assetsMap().get(assets[i].FinServ__AssetsAndLiabilitiesType__c))+'",'
                                +'"value": '+assets[i].Value__c+','
                                +'"valueBasis": "Applicant Estimate",'
                                +'"details": "'+assets[i].FinServ__Description__c+'",'
                                +'"institution": "'+assets[i].Institution__c+'"';
                                if(assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Home'){
                                    body += ',"realEstatePurpose": "Owner Occupied",'
                                    +'"realEstateZoning": "Residential",'
                                    +'"realEstateRentalIncome": 0,'
                                    +'"realEstateRentalIncomeFrequency": "monthly"';
                                }
                                if(assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Investment Property'){
                                    body += ',"realEstatePurpose": "Investment",'
                                    +'"realEstateZoning": "Residential",'
                                    +'"realEstateRentalIncome": 0,'
                                    +'"realEstateRentalIncomeFrequency": "monthly"';
                                }
                                if(assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Commercial Property'){
                                    body += ',"realEstatePurpose": "Investment",'
                                    +'"realEstateZoning": "Commercial",'
                                    +'"realEstateRentalIncome": 0,'
                                    +'"realEstateRentalIncomeFrequency": "monthly"';
                                }
                                if(assetsMap().get(assets[i].FinServ__AssetsAndLiabilitiesType__c) == 'Motor Vehicle'){
                                    body += ',"motorVehiceYear": "",'
                                    +'"motorVehicleMake": "CBUS"';
                                }
                                /*if(isApplicant2){
                                    body += '"valueObjectOwnershipList": ['
                                            +'{'
                                                +'"ownership": '+assets[i].Ownership_Share__c+','
                                                +'"name": "'+oppContacts.contact1.Name+'",'
                                                +'"relationship": "Primary Applicant"'
                                            +'},'
                                            +'{'
                                                +'"ownership": '+assets[i].Other_Ownership_Share__c+','
                                                +'"name": "'+oppContacts.contact2.Name+'",'
                                                +'"relationship": "Applicant"'
                                            +'}'
                                        +'],';
                                }*/
                                if(assetsType().get(assetsMap().get(assets[i].FinServ__AssetsAndLiabilitiesType__c)) == 'realEstate'){
                                    body += ',"address": {'
                                        +'"company": "P201322",'
                                        +'"parentID": "'+assets[i].Id+'",'
                                        +'"parentType": "asset",'
                                        +'"type": "",'
                                        +'"streetName": "'+assets[i].Street__c+'",'
                                        +'"streetNumber": "'+assets[i].Street_Number__c+'",'
                                        +'"streetType": "'+assets[i].Street_Type__c+'",'
                                        +'"city": "'+assets[i].Suburb__c+'",'
                                        +'"state": "'+stateTypeMap().get(assets[i].State__c)+'",'
                                        +'"postcode": "'+assets[i].Postal_Code__c+'",'
                                        +'"country": "Australia",'
                                        +'"unitNumber": "",'
                                        +'"buildingName": "",'
                                        +'"floorNumber": "",'
                                        +'"isCorrespondenceAddress": false,'
                                        +'"addressBlock": "'+assets[i].Address__c+'",'
                                        +'"format": "standard",'
                                        +'"housingSituation": "",'
                                        +'"requiresConfirmation": false'
                                    +'}';
                                }
                            body += '}';
                    if(i != assets.size()-1)
                        body += ',';
                            
                }
            }else{
                return '';
            }
        }
        return body;
    }
    
    public static String getLiabilities(){
        
        String body = '';
        if(liabilities != null){
            if(liabilities.size() > 0){
                for(Integer i=0;i<liabilities.size();i++){
                    String repayment = '';
                    if(liabilities[i].Repayment_Frequency__c != null)
                        repayment = liabilities[i].Repayment_Frequency__c.tolowercase();
                        
                    Decimal l = liabilities[i].Limit__c != null ? liabilities[i].Limit__c : 0;
                    Decimal mr = liabilities[i].Monthly_Repayment__c != null ? liabilities[i].Monthly_Repayment__c : 0;
                    body += '{'
                        +'"uniqueId": "'+liabilities[i].Id+'",'
                        +'"company": "P201322",'
                        +'"name": "'+liabilitiesMap().get(liabilities[i].FinServ__AssetsAndLiabilitiesType__c)+'",'
                        +'"type": "'+liabilitiesType().get(liabilitiesMap().get(liabilities[i].FinServ__AssetsAndLiabilitiesType__c))+'",'
                        +'"value": '+liabilities[i].Value__c+','
                        +'"details": "'+liabilities[i].FinServ__Description__c+'",'
                        +'"limit": '+l+','
                        +'"institution": "'+liabilities[i].Institution__c+'",';
                        
                        if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Car Loan')
                            body += '"accountName": "Car Loan",';
                            
                        body += '"accountRepayment": '+mr+','
                        +'"accountRepaymentFrequency": "'+repayment+'"'
                    +'}';
                    
                    if(i != liabilities.size()-1)
                        body += ',';
                }
            }else{
                return '';
            }
        }
        return body;
    }
    
    public static Map<String,String> liabilitiesMap(){
        Map<String,String> assetMap = new Map<String,String>();
        assetMap.put('HECS/HELP','HECS');
        assetMap.put('Credit Card / Store Card','Credit Card');
        assetMap.put('Car Loan','Personal Loan');
        assetMap.put('Child support','Maintenance');
        assetMap.put('Car Lease','Lease');
        assetMap.put('Tax liability','Outstanding Taxation');
        assetMap.put('Merchant Credit (zip pay / afterpay / certigy)','Personal Loan');
        assetMap.put('Margin Loan','Other Loan');
        assetMap.put('Overdraft','Overdraft');
        assetMap.put('Payday Loan','Personal Loan');
        assetMap.put('Personal Loan','Personal Loan');
        assetMap.put('Home Loan/Mortgage','Mortgage Loan');
        assetMap.put('Investment Home Loan','Mortgage Loan');
        assetMap.put('Commercial Mortgage','Mortgage Loan');
        
        return assetMap;
    }
    
    public static Map<String,String> liabilitiesType(){
        Map<String,String> assetMap = new Map<String,String>();
        assetMap.put('Mortgage Loan','account');
        assetMap.put('Credit Card','account');
        assetMap.put('HECS','standard');
        assetMap.put('Lease','standard');
        assetMap.put('Outstanding Taxation','standard');
        assetMap.put('Other Loan','account');
        assetMap.put('Overdraft','account');
        assetMap.put('Personal Loan','account');
        
        return assetMap;
    }
    
    public static Map<String,String> assetsMap(){
        Map<String,String> assetMap = new Map<String,String>();
        assetMap.put('Investment Property','Real Estate');
        assetMap.put('Motor Vehicle','Motor Vehicle');
        assetMap.put('Bank Account','Savings Account');
        assetMap.put('Superannuation','Superannuation');
        assetMap.put('Commercial Property','Real Estate');
        assetMap.put('Home','Real Estate');
        assetMap.put('Home Contents','Home Contents');
        assetMap.put('Shares Portfolio','Shares');
        assetMap.put('Collectibles','Other');
        assetMap.put('Leisure','Other');
        assetMap.put('Other','Other');
        assetMap.put('Gift Funds','Gifts');
        assetMap.put('Deposit Paid','Term Deposit');
        
        return assetMap;
    }
    
    public static Map<String,String> assetsType(){
        Map<String,String> assetMap = new Map<String,String>();
        assetMap.put('Real Estate','realEstate');
        assetMap.put('Motor Vehicle','vehicle');
        assetMap.put('Savings Account','account');
        assetMap.put('Superannuation','standard');
        assetMap.put('Home Contents,','standard');
        assetMap.put('Shares','standard');
        assetMap.put('Other','standard');
        assetMap.put('Gifts','standard');
        assetMap.put('Term Deposit','account');
        
        return assetMap;
    }
    
    public static Map<String,String> livingSituation(){
        Map<String,String> livingSit = new Map<String,String>();
        livingSit.put('Own home outright','Own Home');
        livingSit.put('Own home with mortgage','Own Home - Mortgage');
        livingSit.put('Renting','NSW');
        livingSit.put('Boarding with parents','With Parents');
        livingSit.put('Boarding with other','Boarding');
        livingSit.put('Supplied by employer','Other');
        return livingSit;
    }
    
    public static String residencyStatus(Contact con){
        String status = '';
        if(con.Citizenship_Status__c == 'Australian Citizen'){
            isResident = true;
            status = 'Citizen';
        }
        if(con.Citizenship_Status__c == 'Permanent Resident'){
            isResident = true;
            status = 'Resident';
        }
        if(con.Citizenship_Status__c == 'NZ Citizen'){
            isResident = false;
            status = 'Non-Resident';
        }
        if(con.Citizenship_Status__c == 'Other'){
            isResident = false;    
            status = 'Non-Resident';
        }
        return status;
    }
    
    public static String empStatusMap(EmploymentStatus empStatus){
        String status = '';
        if(empStatus.con.FinServ__Occupation__c == 'Home Duties'){
            status = 'Home Duties';
        }
        if(empStatus.con.FinServ__Occupation__c == 'Self Employed'){
            status = 'Self-Employed';
        }
        if(empStatus.con.FinServ__Occupation__c == 'Retired' || empStatus.con.FinServ__Occupation__c == 'Self Funded Retired'){
            status = 'Retired';
        }
        
        if(empStatus.con.FinServ__Occupation__c == 'Carer' || 
        empStatus.con.FinServ__Occupation__c == 'Unemployed' ||
        empStatus.con.FinServ__Occupation__c == 'Government Benefits' ||
        empStatus.con.FinServ__Occupation__c == 'Student'){
            status = 'Unemployed';
        }
        if(status == ''){
            Map<String,String> empType = new Map<String,String>();
            empType.put('Full time permanent','Full Time');
            empType.put('Self Employed / Contractor','Self-Employed');
            empType.put('Casual / Temporary','Casual');
            empType.put('Part time permanent','Part Time');
            
            if(empStatus.emp != null)
                status = empType.get(empStatus.emp.FinServ__EmploymentStatus__c.trim());
        }
        return status;
    }
    
    public static Map<String,String> stateTypeMap(){
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
    
    public static string nowTimeStr(){
        DateTime nowTime = System.now();
        String str = nowTime.format('yyyy-MM-dd') + 'T' +  nowTime.format('hh:mm:ss') + '+10:30';
        return str;
    }
    
    public static Quote fetchSelectedQuote(Id recordId){
        try{
            Quote qt = [SELECT Id, Customer_Amount__c, Loan_Term__c, Monthly_Repayment__c, Purpose__c,  Interest_Rate__c,
                        Lead__c, Lead__r.FirstName, Lead__r.LastName, Lead__r.Email, Shared_Message__c, 
                        Opportunity.Applicant_1__r.PersonContactId, Product__c, Product__r.Name
                        FROM Quote WHERE OpportunityId =: recordId AND Application__c = true LIMIT 1];
            
            return qt;
        }catch(exception e){
            return null;
        }
    }
    
    public static Contact fetchLivingExpensesDetails(Id recordId){
        Opportunity opp = [SELECT Applicant_1__r.PersonContactId FROM Opportunity WHERE Id =: recordId];
        List<Contact> conList = 
            [SELECT FinServ__CurrentEmployer__c, FinServ__Occupation__c, Home_Loan_repayment__c, Investment_Property_Loan_repayment__c,
             Credit_Card_payment_3_of_total_limit__c, Other_loans_and_or_debt_commitments__c, Rental_or_Board_paid__c, Utilities__c,
             Connections_Phone_Mobile_Internet_C__c, Education_ChildCare_SchoolFees_Uniform__c, Food_Groceries_Meat_Fruit_Vegetabl__c,
             Transport_Public_Petrol_Registration__c, Medical_Private_Health_Insurance_Ong__c, Insurances_Home_Personal_Voluntary__c,
             Household_Purchases_and_Maintenance__c, Entertainment_Dining_Out_Movies_Gift__c, Sports_Hobbies_and_Memberships__c,
             Gambling_Betting_and_Lottery__c, Other_Regular_Expenditure__c, Total_Living_Expenses__c, Email,Clothing_Recreational_Entertainment__c,
             Insurance_Medical_Health__c,Property_including_Rates_Utilities_Manag__c,CFCU_Other__c
             FROM Contact 
             WHERE Id =: opp.Applicant_1__r.PersonContactId];
        return conList[0];
    }
    
    public static Map<String, Contact> fetchEmploymentDetails(Id recordId){
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
    
    public static Map<String, List<FinServ__AssetsAndLiabilities__c>> fetchAssetsAndLiabilities(Id recordId){
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
    
    public static OpportunityContacts fetchOppContacts(Id recordId){
        if (String.isBlank(recordId)) return null;
        List<Contact> app1Children = new List<Contact>();
        List<Contact> app2Children = new List<Contact>();
        
        OpportunityContacts oppCons = new OpportunityContacts();
        Opportunity opp = new Opportunity();
        try{
            opp = [SELECT Id, Name,Amount,Number_of_applicants__c, Application_Sections__c, Current_Application_Sections__c,FinServ__ReferredByUser__c,
                   Applicant_1__c, Applicant_1__r.PersonContactId, Applicant_2__c, Applicant_2__r.PersonContactId,Lead_Source__c,Loan_Amount__c,
                   AccountId, Account.RecordType.Name, FinServ__Household__c, Relationship_to_Applicant_2__c,RecordType.Name
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
            
            Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Name,FirstName, LastName, MiddleName, Email, Phone, Title, Birthdate, 
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