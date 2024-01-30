public class EzeeAPIController {
    
    public static Boolean isApplicant2{get;set;}
    public static OpportunityContacts oppContacts{get;set;}
    public static Contact livingExpensesDetails{get;set;}
    public static Map<String, Contact> employmentDetails{get;set;}
    public static EmploymentStatus applicant1EmpStatus{get;set;}
    public static EmploymentStatus applicant2EmpStatus{get;set;}
    public static Map<String, List<FinServ__AssetsAndLiabilities__c>> assetsAndLiabilities{get;set;}
    public static List<FinServ__AssetsAndLiabilities__c> assets{get;set;}
    public static List<FinServ__AssetsAndLiabilities__c> liabilities{get;set;}
    
    public static Quote selectedQuote{get;set;}
    // for multiple employeement in one contact...
    public static EmploymentStatus applicant1Emp{get;set;}
    public static EmploymentStatus applicant2Emp{get;set;}
    public static Map<String, Contact> employmentData{get;set;}
    
    
    /*************for income*/
    
    public static EmploymentStatus applicant1Income{get;set;}
    public static EmploymentStatus applicant2Income{get;set;}
    public static Map<String, Contact> employmentIncome{get;set;}
    
    @AuraEnabled
    public static String makeCallout(String OppId, string SubType){
        System.debug('-======================================='+SUbType);
        opportunity opt = [select id, Lender_Application_ID__c	From opportunity WHERE ID = : oppId Limit 1];
        isApplicant2 = false;
        String app1personId;
        String app2personId;
        try{
            string body =  fetchDetails(OppId);
            
            
            body = getPersonInfo(oppContacts.contact1,applicant1EmpStatus,applicant1Emp,true,oppContacts.contact2,applicant2EmpStatus,applicant2Emp,isApplicant2,applicant1Income,applicant2Income,SubType);
            System.debug('body for app1======='+body);
            app1personId = getApplicationCode(body);
            
            System.debug('App1PersonId +++'+app1personId);
            
            if(app1personId.contains('Error')){
                return 'Error : Please review information';
            }
            else{
                opt.Lender_Application_ID__c = app1personId;
                update opt;
            	return 'success';    
            }
            
            
        }catch(Exception ex){
            
            Exception__c eror = new Exception__c();
            eror.Class_Name__c = 'ZEAL CALLOUT';
            eror.Method_Name__c = 'Make Callout';
            eror.Error_Message__c = ex.getMessage() + '' + ex.getLineNumber();
            eror.opportunity__c = OppId;
            insert eror;
            return 'Error';
        }
        
        
    }
    
    public static string getApplicationCode(string body){
        String username = 'tmcu';
        String password = 'TmCu#wso2#2021';
        String endpoint =  'https://marketplace.ezee.ai/ezeeapi/tmcu/lending/submission/1.0.0/GNL_1f3l7f558/submissions';//'https://marketplace.ezee.ai/ezeeapi/tmcu/lending/submission/1.0.0/GNL_1f3l7f558/submissions';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        System.debug('authheaer-->>'+authorizationHeader);
        
        req.setHeader('Authorization', authorizationHeader);
        req.setMethod('POST');
        req.setBody(body);
        req.setHeader('accept', '*/*');
        req.setHeader('clientId','dca5ee1d6cfc412');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
        //req.setHeader('Authorization', 'Basic dG1jdTpUbUN1I3dzbzIjMjAyMQ==');
        System.debug('req--==-=-'+req);
        Http http = new Http();
        HTTPResponse res;
        
        res = http.send(req);
        System.debug('response+++++ '+res.getBody()); 
        
        if(res.getStatusCode() !=200)
        {	
           return 'Error';
        }
        
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        String id = JSON.serialize(result.get('main'));
        
        String[] apId = id.Split(':');
        String temp  = apId[1].replaceAll('"}','');
        temp = temp.replaceAll('"','');
        
        System.debug('temo==='+temp);
        if(temp != null){
            return temp;
        }else{
            return 'Error';
        }
        
    }
    
    
    
    
    public static String fetchDetails(String oppId){
        assets = new List<FinServ__AssetsAndLiabilities__c>();
        liabilities = new List<FinServ__AssetsAndLiabilities__c>();
        employmentDetails = new Map<String, Contact>();
        
        applicant1EmpStatus = new EmploymentStatus();
        applicant2EmpStatus = new EmploymentStatus();
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
        secEmploye(oppId);
        oppContacts = fetchOppContacts(oppId);
        selectedQuote = fetchSelectedQuote(oppId);
        
        assetsAndLiabilities = fetchAssetsAndLiabilities(oppId);
        assets = assetsAndLiabilities.get('Asset');
        liabilities = assetsAndLiabilities.get('Liability');
        
        return null;
    }
    public static  void secEmploye(String oppId)
    {
        employmentData = new Map<String, Contact>();
        
        applicant1Emp = new EmploymentStatus();
        applicant2Emp = new EmploymentStatus();
        
        employmentData = fetchEmployees(oppId);
        
        
        if(employmentData.get('applicant1') != null)
            applicant1Emp.con = employmentData.get('applicant1');
        if(employmentData.get('applicant2') != null)
            applicant2Emp.con = employmentData.get('applicant2');
        
        
        if(employmentData.get('applicant1').FinServ__Employment__r !=null && employmentData.get('applicant1').FinServ__Employment__r.size() >0){
            applicant1Emp.emp = employmentData.get('applicant1').FinServ__Employment__r[0];
            System.debug('applican 1 emp ++'+applicant1Emp.emp);
        }
        
        if(employmentData.containskey('applicant2'))
        {
            if(employmentData.get('applicant2').FinServ__Employment__r.size() >0){
                applicant2Emp.emp = employmentData.get('applicant2').FinServ__Employment__r[0];
                System.debug('applican 2 emp ++'+applicant2Emp.emp);
            }
        }
        
        
        
        
        employmentIncome = new Map<String, Contact>();
        
        applicant1Income = new EmploymentStatus();
        applicant2Income = new EmploymentStatus();
        
        employmentIncome = incomeForZEAL(oppId);
        
        
        if(employmentIncome.get('applicant1') != null)
            applicant1Income.con = employmentIncome.get('applicant1');
        if(employmentIncome.get('applicant2') != null)
            applicant2Income.con = employmentIncome.get('applicant2');
        
        
        if(employmentIncome.get('applicant1').FinServ__Employment__r !=null && employmentIncome.get('applicant1').FinServ__Employment__r.size() >0){
            applicant1Income.emplist = employmentIncome.get('applicant1').FinServ__Employment__r;
        }
        if(employmentIncome.containskey('applicant2') )
        {
            if(employmentIncome.get('applicant2').FinServ__Employment__r.size() >0){
                applicant2Income.emplist = employmentIncome.get('applicant2').FinServ__Employment__r;
            }
        }
    }
    
    
    public static String getPersonInfo(Contact contact, EmploymentStatus empStatus,EmploymentStatus empSecStatus, Boolean isExpense, Contact contact2, EmploymentStatus empStatus2,EmploymentStatus empSecStatus2, boolean isApplicant,EmploymentStatus applicant1Income,EmploymentStatus applicant2Income, string subType){
        String Monthly = 'Monthly';
        Integer Zero = 0;
        String NA = 'N/A';
        Decimal totalAmount = 0.0;
        String d = '';
        String mo = '';
        Integer yr = 0;
        string dt;
        
        if(contact.Birthdate != null){
            d = (contact.Birthdate.day() < 10) ? '0' + String.valueOf(contact.Birthdate.day()) : String.valueOf(contact.Birthdate.day());
            mo = (contact.Birthdate.month() < 10) ? '0' + String.valueOf(contact.Birthdate.month()) : String.valueOf(contact.Birthdate.month()) ;
            yr = contact.Birthdate.year();
            dt = d + '/' + mo + '/' + yr;
        }
        else{
            dt = '12' + '/' + '02' + '/' + '2000';
        }
        
        Decimal months = 0;
        date newDate;
        String empCommenced = '';
        if(empStatus.emp != null){
            months = (empStatus.emp.Years__c != null ? empStatus.emp.Years__c * 12 : 0) + (empStatus.emp.Months__c!= null ? empStatus.emp.Months__c : 0);
            newDate = System.today().addMonths(-(Integer)months);
            String dat = (newDate.day() < 10) ? '0' + String.valueOf(newDate.day()) : String.valueOf(newDate.day());
            String mon = (newDate.month() < 10) ? '0' + String.valueOf(newDate.month()) : String.valueOf(newDate.month());
            yr = newDate.year();
            empCommenced =  + dat + '/'+ mon + '/' + yr;
            System.debug('date commeneced+++'+empCommenced);
        }
        
        
        String endDate;
        Date endDt;
        if(empStatus.emp.years__c < 3){
            endDt  = newDate.addDays(-1);
            String dat = (endDt.day() < 10) ? '0' + String.valueOf(endDt.day()) : String.valueOf(endDt.day());
            String mon = (endDt.month() < 10) ? '0' + String.valueOf(endDt.month()) : String.valueOf(endDt.month());
            yr = endDt.year();
            endDate = dat + '/' + mon + '/' + yr;
            System.debug('endDateendDate'+endDate);
        }
        else{
            endDate = '12' + '/' + '02' + '/' + '2000';
        }
        
        Date preDt;
        String empPreCommenced;
        if(empStatus.emp.years__c < 3){
            months = (empStatus.emp.Years_1_Previous__c != null ? empStatus.emp.Years_1_Previous__c * 12 : 0)  + (empStatus.emp.Months_1_Previous__c != null ? empStatus.emp.Months_1_Previous__c : 0);
            preDt  = endDt.addMonths(-(Integer)months);
            System.debug('PreDate+_+'+preDt);
            String dat = (preDt.day() < 10) ? '0' + String.valueOf(preDt.day()) : String.valueOf(preDt.day());
            String mon = (preDt.month() < 10) ? '0' + String.valueOf(preDt.month()) : String.valueOf(preDt.month());
            yr = preDt.year();
            empPreCommenced =  + dat + '/'+ mon + '/' + yr;
            System.debug('empPreCommenced++++'+empPreCommenced);
        }
        else{
            empPreCommenced = '12' + '/' + '02' + '/' + '2000';
        }
        
        String gender = contact.FinServ__Gender__c == 'Male'? 'M' : 'F';
        
        Decimal loanYear = selectedQuote.Loan_Term__c/12;
        
        String body = '{'+
            '	"source": "TMCU",'+
            '	"sourceReference": "TMCU",'+
            '	"submissionType": "'+subType+'",'+
            '	"data": {'+
            '		"main": {'+
            '			"tmcuCheck": true,'+
            '			"bankruptDeclared": "No",'+
            '			"nonPaymentDebtCourtOrder": "No",'+
            '			"reliefBankruptcyAct": "No",';
        
        if(oppContacts.opp.Number_of_applicants__c != 0){
            if(Integer.valueOf(oppContacts.opp.Number_of_applicants__c) == 1){
                body +='"coappCount": "Single Applicant",';
            }else{
                body +='"coappCount": "1",';//Joint Applicant
            }
        }
        
        if(contact.title != null){
            body += '"title": "'+contact.title+'.",';
        }else{
            body += '"title": "Mr.",';
        }
        body+= 
            '			"firstName": "'+(contact.FirstName != null ? contact.FirstName : '')+'",'+
            '			"middleName": "'+(contact.MiddleName != null ? contact.MiddleName : '')+'",'+
            '			"lastName": "'+(contact.LastName != null ? contact.LastName : '')+'",'+
            '			"gender": "'+gender+'",'+
            '			"dob": "'+dt+'",'+
            '			"emailone": "'+contact.Email+'",';
        if(contact.Phone != null){
            String Phone = contact.Phone;
            if(Phone.startswith('+61')){
                Phone = Phone.replace('+61', '0');
            }
            Phone = Phone.deleteWhitespace();
            body+='"mobile": "'+Phone+'",';
        }
        else{
            body+='"mobile": "'+NA+'",';
        }
        body += '			"radio_609konWRi": "No",'+
            '"securityQuestion": "What is the name of the street you grew up on?",'+
            '			"securityAnswer": "not answered by customer",';
        
        if(contact.FinServ__MaritalStatus__c != null){
            if(contact.FinServ__MaritalStatus__c == 'Married / defacto' || contact.FinServ__MaritalStatus__c == 'Married / Defacto (to applicant 2)' || contact.FinServ__MaritalStatus__c == 'Married / Defacto (to applicant 1)' || contact.FinServ__MaritalStatus__c == 'Married / defacto (non-applicant)'){
                body += '"maritalStatus": "Married",';
            }else{
                body += 
                    '"maritalStatus": "'+contact.FinServ__MaritalStatus__c+'",';
            }
        }
        else{
            body += 
                '"maritalStatus": "Single",';
        }
        
        boolean isChildren = false;
        
        if(applicant1Income.emplist != null){
            if(applicant1Income.emplist.size() > 0){
                for(Integer i=0; i<applicant1Income.emplist.size(); i++){
                    if(applicant1Income.emplist[i].FinServ__EmploymentStatus__c == 'Family Tax Benefits' ){
                        isChildren = true;
                        break;
                    }
                    else{
                      isChildren = false;  
                    }
                }
            }
        }
        System.debug('isChildren--'+isChildren);
        if(isChildren == true){
            if(contact.FinServ__NumberOfChildren__c > 0){
                if(oppContacts.app1Children !=  null){
                    if(oppContacts.app1Children.size() > 0){
                        body+=
                            '"numberOfDependents": "'+oppContacts.app1Children.size()+'",';
                        for(Integer i=0; i<oppContacts.app1Children.size(); i++){
                            string age = '';
                            if(oppContacts.app1Children[i].Child_Age__c == '0 Year' || oppContacts.app1Children[i].Child_Age__c == '1 Year'){
                                age = oppContacts.app1Children[i].Child_Age__c.remove('Year');
                            }
                            else{
                                age = oppContacts.app1Children[i].Child_Age__c.remove('Years');    
                            }
                            age = age.normalizeSpace();
                            body +='"dependentsAge'+string.valueOf(i+1)+'": "'+age+'",';
                            System.debug('age number'+oppContacts.app1Children.size());
                        }       
                    }
                }    
            }
            else{
                body+=
                    '"numberOfDependents": "'+Zero+'",';
            }
        }
        else{
            body+=
                '"numberOfDependents": "'+(oppContacts.app1Children != null ? oppContacts.app1Children.size() : 0)+'",';
            for(Integer i=0; i<oppContacts.app1Children.size(); i++){
                body +='"dependentsAge'+string.valueOf(i+1)+'": "'+Zero+'",';
                System.debug('age number'+oppContacts.app1Children.size()); 
            }
            
        }
      
        body += 
            '"declarationOne": "true",'+
            '"declarationTwo": "true",'+
            '"declarationThree": "true",';
        
        System.debug('emploueement status+'+empStatus.emp.FinServ__EmploymentStatus__c);
        if(empStatus.emp.FinServ__EmploymentStatus__c == 'Full time permanent' || empStatus.emp.FinServ__EmploymentStatus__c == 'Casual / Temporary' || empStatus.emp.FinServ__EmploymentStatus__c == 'Part time permanent'){
            String occ = (contact.FinServ__Occupation__c != null ? contact.FinServ__Occupation__c : '') + ' at ' + (contact.Account.Industry != null ? contact.Account.Industry : '') +' : '+ (contact.Primary_Employer_Job_Title__c != null ? contact.Primary_Employer_Job_Title__c : ''); 
            System.debug('occupatiopn'+occ);
            body += 
                '"currentPayg": "Yes",'
                +'"occupation": "'+occ+'",'
                +'"employmentStatus": "'+empSecStatusMap(empStatus.emp)+'",'
                +'"employerName": "'+empStatus.emp.Name+'",'
                +'"employerAddress": "'+empStatus.emp.FinServ__EmployerAddress__c+'",'
                +'"dateCommencedCurrent": "'+empCommenced+'",';
        }
        else{
            body += 
                '"currentPayg": "No",'
                +'"occupation": "'+NA+'",'
                +'"employmentStatus": "'+NA+'",'
                +'"employerName": "'+NA+'",'
                +'"employerAddress": "'+NA+'",'
                +'"dateCommencedCurrent": "'+NA+'",';
        }
        if(empStatus.emp.Years__c <3){
            body+= '"previousEmploymentQuestion" : "Yes",'+
                '"previousEmployer" : "'+empStatus.emp.Employer_Name_1_Previous__c+'",'+
                '"dateCommenced" : "'+empPreCommenced+'",'+
                '"dateFinished": "'+endDate+'",';
        }else{
            body+= '"previousEmploymentQuestion" : "No",'+
                '"previousEmployer" : "",'+
                '"dateCommenced" : "",'+
                '"dateFinished": "",';
        }
        if(contact.Does_your_spouse_earn_an_income__c == 'Yes'){
            body+= '"partnerStatus" : "Yes",'+
                '"partnersIncome" : "'+contact.spouse_s_approximate_annual_income__c+'",';
        }
        else{
            body+= '"partnerStatus" : "No",'+
                '"partnersIncome" : "",';
        }
        
        if(!string.isBlank(oppContacts.opp.Application_Supporting_Notes__c)){
            List<string> listyy = new List<string>();
            string text = oppContacts.opp.Application_Supporting_Notes__c;
            listyy = text.Split('\\r?\\n|\\r');
            System.debug('listyy'+listyy);
            String temp = '';
            
            for(string s : listyy){
                if(s == '' || s == null){
                    continue;
                }
                else{
                    temp += s+'\\'+'\\n';
                    if(temp.contains('\"')){
                    	temp = temp.replace('\"', '\'');  
                    }
                }
            }
            temp = temp.removeEnd('\\');
            temp = temp.removeEnd('\\');
            
            System.debug('temp ++ '+temp);
            
            body+= '"radioAnythingElse" : "Yes",' +
                '"textAnythingElse" : "'+temp+'",';
        }
        else{
            body+= '"radioAnythingElse" : "No",' +
                '"textAnythingElse" : "",';
        }
        
        if(empSecStatus.emp != null && (empStatus.emp.FinServ__EmploymentStatus__c == 'Full time permanent' || empStatus.emp.FinServ__EmploymentStatus__c == 'Casual / Temporary' || empStatus.emp.FinServ__EmploymentStatus__c == 'Part time permanent')){
            body +=
                '"secondJobCheck": "Yes",'+
                '			"secOccupation": "'+empSecStatus.emp.FinServ__Occupation__c+'",'+
                '           "secEmpStatus": "'+empSecStatusMap(empSecStatus.emp)+'",'+
                '			"secEmpName": "'+empSecStatus.emp.Name+'",'+
                '			"secEmpAddress": "'+empSecStatus.emp.FinServ__EmployerAddress__c+'",';     
        }
           else{
               body +=
                   '"secondJobCheck": "No",'+
                   '			"secOccupation": "",'+
                   '			"secEmpStatus": "",'+
                   '			"secEmpName": "",'+
                   '			"secEmpAddress": "",';
           }
         
        Boolean selfjob = false;
        if(employmentData.get('applicant1').FinServ__Employment__r != null && employmentData.get('applicant1').FinServ__Employment__r.size() > 0){
            for(FinServ__Employment__c emp : employmentData.get('applicant1').FinServ__Employment__r){
                if(emp.FinServ__EmploymentStatus__c == 'Self Employed / Contractor'){
                    body += 
                        '"selfJobCheck": "Yes",'
                        +'"selfNatureBusiness": "'+emp.Self_Employed_Type__c+'",'
                        +'"selfEmpName": "'+emp.Job_Title__c+'",'
                        +'"selfEmpAddress": "'+emp.FinServ__EmployerAddress__c+'",';
                    selfjob = true;
                }
                
            }
        }
       if(empStatus.emp.FinServ__EmploymentStatus__c == 'Self Employed / Contractor'){
            body += 
                '"selfJobCheck": "Yes",'
                +'"selfNatureBusiness": "'+empStatus.emp.Self_Employed_Type__c+'",'
                +'"selfEmpName": "'+empStatus.emp.Job_Title__c+'",'
                +'"selfEmpAddress": "'+empStatus.emp.FinServ__EmployerAddress__c+'",';
           selfjob = true;
        }
        if(!selfjob){
            body += 
                '"selfJobCheck": "No",'
                +'"selfNatureBusiness": "",'
                +'"selfEmpName": "",'
                +'"selfEmpAddress": "",';
        }
        String Street = (contact.Street__c != null ? contact.Street__c : '');
        String suburb = (contact.Suburb__c != null ? contact.Suburb__c : '');
        String state = (contact.State__c != null ? contact.State__c : '');
        String unitNo = (contact.Unit_Number__c != null ? contact.Unit_Number__c : '');
        String streetNo = (contact.Street_Number__c != null ? contact.Street_Number__c : '');
        String postCode = (contact.Postal_Code__c != null ? contact.Postal_Code__c : '');
        body+=
            '			"residencyStatus": "'+citizeShip(contact)+'",'+
            '			"typeOfResidency": "'+livingSituation(contact)+'",'+
            '			"currentAddress": "'+contact.Residential_Address__c+'",'+
            
            '			"streetName": "'+Street+'",'+
            '			"suburb": "'+suburb+'",'+	
            '			"state": "'+state+'",'+
            '			"postCode": "'+postCode+'",'+	
        	'			"unitNoResi": "'+unitNo+'",'+ 
            '			"streetNoResi": "'+streetNo+'",';
            
            
        if(contact.Dont_have_drivers_licence__c != true){
            body +='"idForm": "Driver\'s Licence",'+
                '"idCheck": "Yes",'+
                '"stateDL": "'+DriverState(contact)+'",'+
                '"drivingFname": "'+contact.FirstName+'",'+
                '"drivingMiddleName": "'+contact.MiddleName+'",'+
                '"drivingLastName": "'+contact.LastName+'",'+
                '"drivingDob": "'+contact.Birthdate+'",'+
                '"driverLicence": "'+contact.Govt_Id_Number__c+'",'+
                '"agreeDL": "true",';
        }
        else{
            body +='"idForm": "",'+
                '"idCheck": "No",'+
                '"stateDL": "",'+
                '"drivingFname": "",'+
                '"drivingMiddleName": "",'+
                '"drivingLastName": "",'+
                '"drivingDob": "",'+
                '"driverLicence": "",'+
                '"agreeDL": "",';
        }
        
        body += '"drivingCardNumber" : "'+(contact.ID_Card_Number__c != null ? contact.ID_Card_Number__c : '')+'",';
       
        
        
        if(contact.Year__c != null){
            if(Integer.valueOf(contact.Year__c) >= 3){
                body += 
                    '"longLived": "More than three years",'
                    +'"priorResiAddress": "'+contact.Residential_Address__c+'",';
            }
            else if(Integer.valueOf(contact.Year__c) < 3){
                body += 
                    '"longLived": "Less than three years",'
                    +'"priorResiAddress": "'+contact.Residential_Address_1__c+'",';
            }
        }else{
            body += 
                '"longLived": "'+NA+'",'
                +'"priorResiAddress": "'+NA+'",';
        }
        if(contact.isFindPostalAdd__c == false){
            body += 
                '"postalSame": true,'
                +'"postalAddress": "'+contact.Residential_Address__c+'",';    
        }
        if(contact.isFindPostalAdd__c == true){
            body += 
                '"postalSame": false,'
                +'"postalAddress": "'+contact.Postal_Address__c+'",';
        }
        body+= 
            '"loanAmount": "'+math.ceil(selectedQuote.Total_loan_amount__c)+'",';
        
        if(selectedQuote.Interest_Rate__c == 1.99){
            body+= 
            '"loanPurpose": "Solar via Parker Lane under 10K",';
        }
        if(selectedQuote.Interest_Rate__c == 2.99){
            body+= 
            '"loanPurpose": "Solar via Parker Lane over 10K",';
        }
        
        if(selectedQuote.Loan_Term__c != 0.00){
            body += '"loanTenureInYears": "'+loanYear+'",'; 
        }else{
            body += '"loanTenureInYears": "'+NA+'",';
        }
        
        if(oppContacts.opp.Preferred_repayment_frequency__c != null){
            body += 
                '"repaymentFrequency": "'+oppContacts.opp.Preferred_repayment_frequency__c+'",';  
        }else{
            body += 
                '"repaymentFrequency": "'+Monthly+'",'; 
        }
        if(!string.isBlank(oppContacts.opp.Preferred_repayment_frequency__c)){
            if(oppContacts.opp.Preferred_repayment_frequency__c == 'Monthly'){
                if(selectedQuote.Monthly_Repayments__c != null){
                    body += '"repaymentAmount": "'+selectedQuote.Monthly_Repayments__c+'",'; 
                }
                else{
                    body += '"repaymentAmount": "'+NA+'",';
                }
            }
            if(oppContacts.opp.Preferred_repayment_frequency__c == 'Weekly'){
                if(selectedQuote.Monthly_Repayments__c != null){
                    body += '"repaymentAmount": "'+selectedQuote.Weekly_Repayments__c+'",'; 
                }
                else{
                    body += '"repaymentAmount": "'+NA+'",';
                }
            }
            if(oppContacts.opp.Preferred_repayment_frequency__c == 'Fortnightly'){
                if(selectedQuote.Monthly_Repayments__c != null){
                    body += '"repaymentAmount": "'+selectedQuote.Fortnightly_Repayments__c+'",'; 
                }
                else{
                    body += '"repaymentAmount": "'+NA+'",';
                }
            }
        }
        else{
            body += '"repaymentAmount": "'+selectedQuote.Monthly_Repayments__c+'",';
        }
        
        if(livingExpensesDetails.Food_Groceries_Meat_Fruit_Vegetabl__c > 0){
            body += '"groceries": "'+livingExpensesDetails.Food_Groceries_Meat_Fruit_Vegetabl__c+'",'+
                '"groceryFrequency": "'+Monthly+'",';
        }
        else{
            body += '"groceries": "0.00",'+
                '"groceryFrequency": "'+Monthly+'",';
        }
        
        decimal edu = (livingExpensesDetails.Education_public_and_private__c > 0 ? livingExpensesDetails.Education_public_and_private__c : 0) + (livingExpensesDetails.Education_ChildCare_SchoolFees_Uniform__c > 0 ? livingExpensesDetails.Education_ChildCare_SchoolFees_Uniform__c : 0);
        decimal spending = (livingExpensesDetails.Gambling_Betting_and_Lottery__c > 0 ? livingExpensesDetails.Gambling_Betting_and_Lottery__c : 0) + (livingExpensesDetails.Clothing_Recreational_Entertainment__c > 0 ? livingExpensesDetails.Clothing_Recreational_Entertainment__c : 0) + (livingExpensesDetails.Clothing_and_personal_care__c > 0 ? livingExpensesDetails.Clothing_and_personal_care__c : 0);
        
        System.debug('education :::'+edu);
        System.debug('Spending :::'+spending);
        body += 
            '"education": "'+edu+'",'+
            '"educationFrequency": "'+Monthly+'",'+
            '"spending": "'+spending+'",'+
            '"spendingFrequency": "'+Monthly+'",'+
            '"otherGeneralExpense": "'+(contact.Other_Regular_Expenditure__c != null ? contact.Other_Regular_Expenditure__c : 0)+'",'+
            '"otherFrequency": "'+Monthly+'",';
        
        if(livingExpensesDetails.Transport_Public_Petrol_Registration__c > 0){
            body +=
                '"VehicleExpenseQuestion": true,'+
                '"vehicle": "'+Zero+'",'+
                '"vehicleFrequency": "'+Monthly+'",'+
                '"petrol": "'+Zero+'",'+
                '"petrolFrequency": "'+Monthly+'",'+
                '"registration": "'+Zero+'",'+
                '"registrationFrequency": "'+Monthly+'",'+
                '"otherVehicle": "'+livingExpensesDetails.Transport_Public_Petrol_Registration__c+'",'+
                '"otherVehicleFrequency": "'+Monthly+'",';	
        }
        else{
            body +=
                '"VehicleExpenseQuestion": false,'+
                '"vehicle": "'+Zero+'",'+
                '"vehicleFrequency": "'+Monthly+'",'+
                '"petrol": "'+Zero+'",'+
                '"petrolFrequency": "'+Monthly+'",'+
                '"registration": "'+Zero+'",'+
                '"registrationFrequency": "'+Monthly+'",'+
                '"otherVehicle": "'+Zero+'",'+
                '"otherVehicleFrequency": "'+Monthly+'",';	
        }
        
        decimal health = (livingExpensesDetails.Medical_Private_Health_Insurance_Ong__c > 0 ? livingExpensesDetails.Medical_Private_Health_Insurance_Ong__c : 0);
        decimal personal = (livingExpensesDetails.Personal_Insurances_life_and_income_pro__c > 0 ? livingExpensesDetails.Personal_Insurances_life_and_income_pro__c : 0);
        decimal other = (livingExpensesDetails.Insurances_Home_Personal_Voluntary__c > 0 ? livingExpensesDetails.Insurances_Home_Personal_Voluntary__c : 0);
        if(health > 0 || personal > 0 || other > 0){
            body +='"insuranceExpenseQuestion": true,'+
                '"insurance": "'+Zero+'",'+
                '"insuranceFrequency": "'+Monthly+'",'+
                '"carInsurance": "'+Zero+'",'+
                '"carInsuranceFrequency": "'+Monthly+'",'+
                '"houseInsurance": "'+Zero+'",'+
                '"houseInsuranceFrequency": "'+Monthly+'",'+
                '"lifeInsurance": "'+personal+'",'+
                '"lifeInsuranceFrequency": "'+Monthly+'",'+
                '"insuranceHealth": "'+health+'",'+
                '"healthInsuranceFrequency": "'+Monthly+'",'+
                '"otherInsuranecExpenses": "'+other+'",'+
                '"otherInsuranceFrequency": "'+Monthly+'",';
        }
        else{
            body +='"insuranceExpenseQuestion": false,'+
                '"insurance": "'+Zero+'",'+
                '"insuranceFrequency": "'+Monthly+'",'+
                '"carInsurance": "'+Zero+'",'+
                '"carInsuranceFrequency": "'+Monthly+'",'+
                '"houseInsurance": "'+Zero+'",'+
                '"houseInsuranceFrequency": "'+Monthly+'",'+
                '"lifeInsurance": "'+Zero+'",'+
                '"lifeInsuranceFrequency": "'+Monthly+'",'+
                '"insuranceHealth": "'+Zero+'",'+
                '"healthInsuranceFrequency": "'+Monthly+'",'+
                '"otherInsuranecExpenses": "'+Zero+'",'+
                '"otherInsuranceFrequency": "'+Monthly+'",';
        }
        
        decimal rates = (livingExpensesDetails.Utilities__c > 0 ? livingExpensesDetails.Utilities__c : 0) + (livingExpensesDetails.Investment_property_utilities__c > 0 ? livingExpensesDetails.Investment_property_utilities__c : 0);
        decimal conn = (livingExpensesDetails.Connections_Phone_Mobile_Internet_C__c > 0 ? livingExpensesDetails.Connections_Phone_Mobile_Internet_C__c : 0);
        if(rates > 0 || conn > 0){
            body +='"ratesAndUtilitiesExpenses": true,'+
                '"gas": "'+Zero+'",'+
                '"gasFrequency": "'+Monthly+'",'+
                '"phone": "'+Zero+'",'+
                '"phoneFrequency": "'+Monthly+'",'+
                '"power": "'+Zero+'",'+
                '"powerFrequency": "'+Monthly+'",'+
                '"internet": "'+Zero+'",'+
                '"internetFrequency": "'+Monthly+'",'+
                '"rates": "'+rates+'",'+
                '"ratesFrequency": "'+Monthly+'",'+
                '"water": "'+Zero+'",'+
                '"waterFrequency": "'+Monthly+'",'+
                '"otherRatesAndUtilities": "'+conn+'",'+
                '"otherRateUtilitiesFrequency": "'+Monthly+'",'; 
        } 
        else{
            body +='"ratesAndUtilitiesExpenses": false,'+
                '"gas": "'+Zero+'",'+
                '"gasFrequency": "'+Monthly+'",'+
                '"phone": "'+Zero+'",'+
                '"phoneFrequency": "'+Monthly+'",'+
                '"power": "'+Zero+'",'+
                '"powerFrequency": "'+Monthly+'",'+
                '"internet": "'+Zero+'",'+
                '"internetFrequency": "'+Monthly+'",'+
                '"rates": "'+Zero+'",'+
                '"ratesFrequency": "'+Monthly+'",'+
                '"water": "'+Zero+'",'+
                '"waterFrequency": "'+Monthly+'",'+
                '"otherRatesAndUtilities": "'+Zero+'",'+
                '"otherRateUtilitiesFrequency": "'+Monthly+'",'; 
        }
        if(contact.Monthly_Rental_Payments__c != null || contact.Education_ChildCare_SchoolFees_Uniform__c != null || contact.Maintenance_If_pay_child_maintenance__c != null || contact.Other_loans_and_or_debt_commitments__c != null){
            body +=
                '"rentAndOtherLoanRepayments": "true",';
            if(contact.Living_Situation__c == 'Renting' || contact.Living_Situation__c == 'Boarding with other' || contact.Living_Situation__c == 'Boarding with parents'){
                body +=
                    '"rent": "'+contact.Monthly_Rental_Payments__c+'",'
                    +'"rentCommitFreq": "'+Monthly+'",';
            } 
            else{
                body +=
                    '"rent": "'+Zero+'",'
                    +'"rentCommitFreq": "'+Monthly+'",';
            }
            body+=
                '"board": "'+Zero+'",'
                +'"boardCommitFreq": "'+Monthly+'",';
            
            Decimal amount = 0.0;
            if(liabilities != null){
                if(liabilities.size() > 0){
                    for(Integer i=0;i<liabilities.size();i++){
                        if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Child Maintenance'){
                            if(liabilities[i].Monthly_Repayment__c > 0){
                                amount += liabilities[i].Monthly_Repayment__c;
                            }
                        }
                    }
                }
            }    
            System.debug('child maintain amount'+amount);
            body+=
                '"childMaintain": "'+amount+'",'
                +'"childCommitFreq": "'+Monthly+'",'+ 
                '"childSpouseMaintain": "'+Zero+'",'+
                '"childSpouseCommitFreq": "'+Monthly+'",'+
                '"otherCommitments": "'+Zero+'",'
                +'"otherCommitFreq": "'+Monthly+'",';
            
        }
        else{
            body +=
                '"rentAndOtherLoanRepayments": "false",'
                +'"rent": "'+Zero+'",'
                +'"rentCommitFreq": "'+Monthly+'",'
                +'"board": "'+Zero+'",'
                +'"boardCommitFreq": "'+Monthly+'",'
                +'"childSpouseMaintain": "'+Zero+'",'
                +'"childSpouseCommitFreq": "'+Monthly+'",'
                +'"otherCommitments": "'+Zero+'",'
                +'"otherCommitFreq": "'+Monthly+'",';
        }
        body += 
            '"totalOtherCommitments": 0,';
        if(contact.Total_Living_Expenses__c != null){
                Decimal amount = (contact.Total_Living_Expenses__c != null ? contact.Total_Living_Expenses__c : 0) + (contact.Monthly_Rental_Payments__c != null ? contact.Monthly_Rental_Payments__c : 0);
                System.debug('amount'+amount);
                body +='"monthlyExpenses": "'+amount+'",';
        }
        if(assets != null){
            if(assets.size() > 0){
                body +=  '"checkboxAssets":  false,';
            }
            else{
                body +=  '"checkboxAssets":  true,';
            }
        }
        if(liabilities != null){
            if(liabilities.size() > 0){
                body +='"checkbox_M-B1GyKiL": false,';      
            }
            else{
                body +='"checkbox_M-B1GyKiL": true,';
            }
        }
        body +=
            '			"finalConsent": true,'+
            '			"interestType": "Variable",';
        
        if(applicant1Income.emplist != null){
            if(applicant1Income.emplist.size() > 0){
                for(Integer i=0; i<applicant1Income.emplist.size(); i++){
                    if(applicant1Income.emplist[i].Source_Document__c == 'Mogo' || applicant1Income.emplist[i].Source_Document__c == 'Bank Statements'){
            			body +='			"basiqForExpense": "Yes",';
                        break;
                    }
                    else{
                        body +='			"basiqForExpense": "No",';
                    }
                }
            }
        }
        body += 
            '			"incomeDetails": ['+incomeForApplicantOne(applicant1Income, contact)+'],'+
            
            '			"accordion_ir2jdL3Q2": ['+bank(Contact)+'],'+
            
            '			"accordionAssetOwnershipDetails": [],';
            
            //'				"accordionAssetOwnershipDetails": ['+getAssets(contact)+'],';
        
        body +='			"accordionSuperannuation": ['+superannution(contact)+'],';
        
        body +='			"accordionRealEstate": ['+accordionRealEstate(contact)+'],'+
            '				"accordionOtherAssets": ['+otherAssets(contact)+'],'+
            
            
            '				"liabilityDetails": ['+getLiabilities(contact)+']'+
            '		}';
        if(isApplicant2 == true){
            body += ','+ 
                coApplicant(contact, contact2, empStatus2, empSecStatus2, applicant2Income); 
        }
        body +=	'}'+
            '}';
        return body;
        
    }
    
    
    public static String incomeForApplicantOne(EmploymentStatus applicant, contact con){
        string body = '';
        if(applicant.emplist != null){
            if(applicant.emplist.size() > 0){
                for(Integer i=0; i<applicant.emplist.size(); i++){
                    if((applicant.emplist[i].FinServ__EmploymentStatus__c == 'Full time permanent' || applicant.emplist[i].FinServ__EmploymentStatus__c == 'Part time permanent' || applicant.emplist[i].FinServ__EmploymentStatus__c == 'Casual / Temporary') && (applicant.emplist[i].Source_Document__c == 'Mogo' || applicant.emplist[i].Source_Document__c == 'Bank Statements') && applicant.emplist[i].Verified_Income_Amount__c > 0){
                        body += '{'+
                            '				"borrowerName": "'+con.FirstName+'",'+
                            '				"basiqSource": "regular",'+
                            '				"basiqShading": "1",'+
                            '				"amount": "'+applicant.emplist[i].Verified_Income_Amount__c+'",'+
                            '				"frequency": "'+(applicant.emplist[i].Verified_Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Verified_Income_Frequency__c)+'",'+
                            '				"monthlyIncome": "'+applicant.emplist[i].Monthly_Verified_Income_Calculation__c+'"'+
                            '}';
                        if(i != applicant.emplist.size()-1)
                        {
                            body += ',';
                        }
                        else
                        {
                            body += ',';
                        }
                    }
                    else{
                        if(applicant.emplist[i].FinServ__EmploymentStatus__c == 'Full time permanent' || applicant.emplist[i].FinServ__EmploymentStatus__c == 'Part time permanent' || applicant.emplist[i].FinServ__EmploymentStatus__c == 'Casual / Temporary'){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Salary",'+
                                '				"amount": "'+applicant.emplist[i].Income_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Income_Frequency__c)+'",'+
                                '				"monthlyIncome": "'+applicant.emplist[i].monthly_Income__c+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1)
                            {
                                body += ',';
                            }
                            else
                            {
                                body += ',';
                            }
                        }
                        
                        if(applicant.emplist[i].FinServ__EmploymentStatus__c == 'New Start Allowance'){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Unemployment Benefits",'+
                                '				"amount": "'+applicant.emplist[i].Income_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Income_Frequency__c)+'",'+
                                '				"monthlyIncome": "'+applicant.emplist[i].monthly_Income__c+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1)
                            {
                                body += ',';
                            }
                            else
                            {
                                body += ',';
                            }
                        }
                        
                        if(applicant.emplist[i].FinServ__EmploymentStatus__c == 'Pension'){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Government Benefits Age Pension",'+
                                '				"amount": "'+applicant.emplist[i].Income_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Income_Frequency__c)+'",'+
                                '				"monthlyIncome": "'+applicant.emplist[i].monthly_Income__c+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1)
                            {
                                body += ',';
                            }
                            else
                            {
                                body += ',';
                            }
						}
                        
                        if(applicant.emplist[i].FinServ__EmploymentStatus__c == 'Rental Income'){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Rental Income - Residential",'+
                                '				"amount": "'+applicant.emplist[i].Income_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Income_Frequency__c)+'",'+
                                '				"monthlyIncome": "'+applicant.emplist[i].monthly_Income__c+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1)
                            {
                                body += ',';
                            }
                            else
                            {
                                body += ',';
                            }
						}
                        
                        if(applicant.emplist[i].FinServ__EmploymentStatus__c == 'Dividends or Annuity'){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Dividend Income",'+
                                '				"amount": "'+applicant.emplist[i].Income_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Income_Frequency__c)+'",'+
                                '				"monthlyIncome": "'+applicant.emplist[i].monthly_Income__c+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1)
                            {
                                body += ',';
                            }
                            else
                            {
                                body += ',';
                            }
						}
                        
                        if(applicant.emplist[i].FinServ__EmploymentStatus__c == 'Family Tax Benefits'){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Government Benefits Family Allowance",'+
                                '				"amount": "'+applicant.emplist[i].Income_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Income_Frequency__c)+'",'+
                                '				"monthlyIncome": "'+applicant.emplist[i].monthly_Income__c+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1)
                            {
                                body += ',';
                            }
                            else
                            {
                                body += ',';
                            }
}
                        
                        if(applicant.emplist[i].FinServ__EmploymentStatus__c == 'Disability Pension'){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Government Benefits Disability Support Pension",'+
                                '				"amount": "'+applicant.emplist[i].Income_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Income_Frequency__c)+'",'+
                                '				"monthlyIncome": "'+applicant.emplist[i].monthly_Income__c+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1)
                            {
                                body += ',';
                            }
                            else
                            {
                                body += ',';
                            }
}
                        
                        if(applicant.emplist[i].FinServ__EmploymentStatus__c == 'Carer’s Pension'){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Government Benefits Carer Payment",'+
                                '				"amount": "'+applicant.emplist[i].Income_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Income_Frequency__c)+'",'+
                                '				"monthlyIncome": "'+applicant.emplist[i].monthly_Income__c+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1)
                            {
                                body += ',';
                            }
                            else
                            {
                                body += ',';
                            }
}
                        
                        if(applicant.emplist[i].FinServ__EmploymentStatus__c == 'Workcover Workers / Compensation'){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Workers Compensation",'+
                                '				"amount": "'+applicant.emplist[i].Income_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Income_Frequency__c)+'",'+
                                '				"monthlyIncome": "'+applicant.emplist[i].monthly_Income__c+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1)
                            {
                                body += ',';
                            }
                            else
                            {
                                body += ',';
                            }
}
                        
                        if(applicant.emplist[i].FinServ__EmploymentStatus__c == 'Other'){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Other Income",'+
                                '				"amount": "'+applicant.emplist[i].Income_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Income_Frequency__c)+'",'+
                                '				"monthlyIncome": "'+applicant.emplist[i].monthly_Income__c+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1)
                            {
                                body += ',';
                            }
                            else
                            {
                                body += ',';
                            }
}
                        
                        if(applicant.emplist[i].FinServ__EmploymentStatus__c == 'Child Support'){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Child Maintenance",'+
                                '				"amount": "'+applicant.emplist[i].Income_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Income_Frequency__c)+'",'+
                                '				"monthlyIncome": "'+applicant.emplist[i].monthly_Income__c+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1)
                                body += ',';
                            else
                                body += ',';
}
                        
                        
                        /*-------------------*/
                        
                        if(applicant.emplist[i].Work_Overtime_amount__c > 0){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Gross Regular Overtime",'+
                                '				"amount": "'+applicant.emplist[i].Work_Overtime_amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Work_Overtime_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Work_Overtime_Frequency__c)+'",';
                            if(applicant.emplist[i].Work_Overtime_Frequency__c == 'Annually'){
                                Decimal amt = applicant.emplist[i].Work_Overtime_amount__c/12;
                                body += '"monthlyIncome": "'+amt+'"';                  
                            }
                            else{
                                body += '"monthlyIncome": "'+applicant.emplist[i].Work_Overtime_amount__c+'"';
                            }
                            body +=
                                '			}';
                            
                            if(i != applicant.emplist.size()-1)
                            {
                                body += ',';
                            }
                            else
                            {
                                body += ',';
                            }
                            
}
                        
                        if(applicant.emplist[i].Commission_or_Bonus_amount__c > 0){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Commission",'+
                                '				"amount": "'+applicant.emplist[i].Commission_or_Bonus_amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Commission_or_Bonus_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Commission_or_Bonus_Frequency__c)+'",';
                            if(applicant.emplist[i].Commission_or_Bonus_Frequency__c == 'Annually'){
                                Decimal amt = applicant.emplist[i].Commission_or_Bonus_amount__c/12;
                                body += '"monthlyIncome": "'+amt+'"';                  
                            }
                            else{
                                body += '"monthlyIncome": "'+applicant.emplist[i].Commission_or_Bonus_amount__c+'"';
                            }
                            body +=
                                '			}';
                            
                            if(i != applicant.emplist.size()-1)
                            {
                                body += ',';
                            }
                            else
                            {
                                body += ',';
                            }
                            
}
                        
                        if(applicant.emplist[i].Allowance_Amount__c > 0){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Permanent Allowance",'+
                                '				"amount": "'+applicant.emplist[i].Allowance_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Allowance_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Allowance_Frequency__c)+'",';
                            if(applicant.emplist[i].Allowance_Frequency__c == 'Annually'){
                                Decimal amt = applicant.emplist[i].Allowance_Amount__c/12;
                                body +='"monthlyIncome": "'+amt+'"';
                            }
                            else{
                                body +='"monthlyIncome": "'+applicant.emplist[i].Allowance_Amount__c+'"';
                            }
                            
                            body +='}';
                            if(i != applicant.emplist.size()-1)
                            {
                                body += ',';
                            }	
                            else{
                                body += ',';
                            }
                            
}
                        
                        if(applicant.emplist[i].Last_year_net_profit__c > 0){
                            Decimal amt = applicant.emplist[i].Last_year_net_profit__c /12;
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Self Employed Income",'+
                                '				"amount": "'+applicant.emplist[i].Last_year_net_profit__c+'",'+
                                '				"frequency": "Yearly",'+	
                                '				"monthlyIncome": "'+amt+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1){
                                body += ',';
                            }
                            else{
                                body += ',';   
                            }
}
                    }
                }
            }
        }
        if(assets != null){
            if(assets.size() > 0){
                for(Integer i=0;i<assets.size();i++){
                    if(assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Investment Property' || assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Commercial Property'){
                        if(assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Investment Property'){
                            if(assets[i].FinServ__Ownership__c == 'Applicant 1' || assets[i].FinServ__Ownership__c == 'Applicant 2'){
                                body += '{'
                                    +'			"basiqSource": "Rental Income - Residential",'+
                                    '			"borrowerName": "'+assets[i].FinServ__PrimaryOwner__r.FirstName+'",'+
                                    '				"amount": "'+assets[i].Rental_Amount__c+'",'+
                                    '				"frequency": "'+(assets[i].Rental_Frequency__c == 'Annually' ? 'Yearly' : assets[i].Rental_Frequency__c)+'",'+
                                    '			"monthlyIncome": "'+assets[i].Monthly_Rental_Income_Calculation__c+'"';
                                body += '}';
                                if(i != assets.size()-1)
                                    body += ',';
                                else
                                    body += ',';
                            }
                            
                            
                            if(assets[i].FinServ__Ownership__c == 'Joint (non-applicant)'){
                                body += '{'
                                    +'			"basiqSource": "Rental Income - Residential",'+
                                    '			"borrowerName": "'+assets[i].FinServ__PrimaryOwner__r.FirstName+'",'+
                                    '				"amount": "'+assets[i].Rental_Amount__c+'",'+
                                    '				"frequency": "'+(assets[i].Rental_Frequency__c == 'Annually' ? 'Yearly' : assets[i].Rental_Frequency__c)+'",'+
                                    ' 				"monthlyIncome": "'+assets[i].Monthly_Rental_Income_Calculation__c+'"';
                                body += '}';
                                if(i != assets.size()-1)
                                    body += ',';
                                else
                                    body += ',';
                            }
                            if(assets[i].FinServ__Ownership__c == 'Joint' || assets[i].FinServ__Ownership__c == 'Joint with Spouse'){
                                body += '{'
                                    +'			"basiqSource": "Rental Income - Residential",'+
                                    '			"borrowerName": "'+assets[i].FinServ__PrimaryOwner__r.FirstName+'",'+
                                    '				"amount": "'+assets[i].Rental_Amount__c+'",'+
                                    '				"frequency": "'+(assets[i].Rental_Frequency__c == 'Annually' ? 'Yearly' : assets[i].Rental_Frequency__c)+'",'+
                                    '				"monthlyIncome": "'+assets[i].Monthly_Rental_Income_Calculation__c+'"';
                                body += '}';
                                if(i != assets.size()-1)
                                    body += ',';
                                else
                                    body += ',';
                            }
                            
                            
                            
                        }
                        
                        
                        
                        if(assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Commercial Property'){
                            if(assets[i].FinServ__Ownership__c == 'Applicant 1' || assets[i].FinServ__Ownership__c == 'Applicant 2'){
                                body += '{'
                                    +'			"basiqSource": "Rental Income - Commercial",'+
                                    '			"borrowerName": "'+assets[i].FinServ__PrimaryOwner__r.FirstName+'",'+
                                    '				"amount": "'+assets[i].Rental_Amount__c+'",'+
                                    '				"frequency": "'+(assets[i].Rental_Frequency__c == 'Annually' ? 'Yearly' : assets[i].Rental_Frequency__c)+'",'+
                                    '				"monthlyIncome": "'+assets[i].Monthly_Rental_Income_Calculation__c+'"';
                                body += '}';
                                if(i != assets.size()-1)
                                    body += ',';
                                else
                                    body += ',';
                            }
                            
                            
                            if(assets[i].FinServ__Ownership__c == 'Joint (non-applicant)'){
                                body += '{'
                                    +'			"basiqSource": "Rental Income - Commercial",'+
                                    '			"borrowerName": "'+assets[i].FinServ__PrimaryOwner__r.FirstName+'",'+
                                    '				"amount": "'+assets[i].Rental_Amount__c+'",'+
                                    '				"frequency": "'+(assets[i].Rental_Frequency__c == 'Annually' ? 'Yearly' : assets[i].Rental_Frequency__c)+'",'+
                                    '			"monthlyIncome": "'+assets[i].Monthly_Rental_Income_Calculation__c+'"';
                                body += '}';
                                if(i != assets.size()-1)
                                    body += ',';
                                else
                                    body += ',';
                            }
                            if(assets[i].FinServ__Ownership__c == 'Joint' || assets[i].FinServ__Ownership__c == 'Joint with Spouse'){
                                body += '{'
                                    +'			"basiqSource": "Rental Income - Commercial",'+
                                    '			"borrowerName": "'+assets[i].FinServ__PrimaryOwner__r.FirstName+'",'+
                                    '				"amount": "'+assets[i].Rental_Amount__c+'",'+
                                    '				"frequency": "'+(assets[i].Rental_Frequency__c == 'Annually' ? 'Yearly' : assets[i].Rental_Frequency__c)+'",'+
                                    '			"monthlyIncome": "'+assets[i].Monthly_Rental_Income_Calculation__c+'"';
                                body += '}';
                                if(i != assets.size()-1)
                                    body += ',';
                                else
                                    body += ',';
                            }
                            
                        }
                    }  
                }
            }
        }
        body = body.removeEnd(',');
        return body;
    }
    
    
    
    public static string superannution(contact con){
        String body = '';
        if(assets != null){
            if(assets.size() > 0){
                for(Integer i=0;i<assets.size();i++){
                    if(isApplicant2 != true){
                        if(assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Superannuation'){
                            body += '{'+
                                '"superAnnIns": "'+assets[i].Institution__c+'",'+
                                '"memNum": "",'+
                                '"estValueSup": "'+assets[i].Value__c+'",'+
                                '"ownerSuperAnn": [';
                            
                            if(assets[i].FinServ__Ownership__c == 'Joint with Spouse'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '},'+
                                    '{'+
                                    '"owner": "Applicants Spouse",'+
                                    '"ownershipPercentDebt": "'+assets[i].Other_Ownership_Share__c+'"'+
                                    '}';
                                
                            }
                            if(assets[i].FinServ__Ownership__c == 'Applicant 1'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '}';
                            }
                            if(assets[i].FinServ__Ownership__c == 'Joint (non-applicant)'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '},'+
                                    '{'+
                                    '"owner": "Other Non Spouse",'+
                                    '"ownershipPercentDebt": "'+assets[i].Other_Ownership_Share__c+'"'+
                                    '}';
                                
                            }
                            
                            
                            body += ']'+
                                '}';
                            
                            if(i != assets.size()-1){
                                body += ',';
                            }
                        }
                    }
                    else{
                        if(assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Superannuation'){
                            body += '{'+
                                '"superAnnIns": "'+assets[i].Institution__c+'",'+
                                '"memNum": "",'+
                                '"estValueSup": "'+assets[i].Value__c+'",'+
                                '"ownerSuperAnn": [';
                            
                            if(assets[i].FinServ__Ownership__c == 'Joint' || assets[i].FinServ__Ownership__c == 'Joint with Spouse'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName+'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '},'+
                                    '{'+
                                    '"owner": "'+assets[i].FinServ__JointOwner__r.FirstName + ' ' + assets[i].FinServ__JointOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Other_Ownership_Share__c+'"'+
                                    '}';
                                
                            }
                            if(assets[i].FinServ__Ownership__c == 'Applicant 1' || assets[i].FinServ__Ownership__c == 'Applicant 2'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '}';
                            }
                            if(assets[i].FinServ__Ownership__c == 'Joint (non-applicant)'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '},'+
                                    '{'+
                                    '"owner": "Other Non Spouse",'+
                                    '"ownershipPercentDebt": "'+assets[i].Other_Ownership_Share__c+'"'+
                                    '}';
                                
                            }
                            
                            
                            body += ']'+
                                '}';
                            
                            if(i != assets.size()-1){
                                body += ',';
                            }
                        }
                    }   
                }
            }else{
                return '';
            }
        }
        body = body.removeEnd(',');
        return body;
    }
    
    public static string bank(Contact con){
        String body = '';
        if(assets != null){
            if(assets.size() > 0){
                for(Integer i=0;i<assets.size();i++){
                    if(isApplicant2 != true){
                        if(assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Bank Account'){
                            body += '{'+
                                '"fiName": "'+assets[i].Institution__c+'",'+
                                '				"acntNumber": "0000000000000000",'+
                                '				"estValue": "'+assets[i].Value__c+'",'+
                                '				"ownershipSaving": [';
                            if(assets[i].FinServ__Ownership__c == 'Applicant 1'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '}';
                            }
							if(assets[i].FinServ__Ownership__c == 'Joint with Spouse'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '},'+
                                    '{'+
                                    '"owner": "Others",'+
									'"ownerNameOther": "Applicants Spouse",'+
                                    '"ownershipPercentDebt": "'+assets[i].Other_Ownership_Share__c+'"'+
                                    '}';
                                
                            }
                            
                            if(assets[i].FinServ__Ownership__c == 'Joint (non-applicant)'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '},'+
                                    '{'+
									'"owner": "Others",'+
                                    '"ownerNameOther": "Other Non Spouse",'+
                                    '"ownershipPercentDebt": "'+assets[i].Other_Ownership_Share__c+'"'+
                                    '}';
                                
                            }
                            
                            
                            
                            body += ']'+
                                '}';
                            
                            if(i != assets.size()-1){
                                body += ',';
                            }
                        } 
                    }
                    else{
                        if(assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Bank Account'){
                            body += '{'+
                                '"fiName": "'+assets[i].Institution__c+'",'+
                                '				"acntNumber": "0000000000000000",'+
                                '				"estValue": "'+assets[i].Value__c+'",'+
                                '				"ownershipSaving": [';
                            if(assets[i].FinServ__Ownership__c == 'Applicant 1' || assets[i].FinServ__Ownership__c == 'Applicant 2'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '}';
                            }
							if(assets[i].FinServ__Ownership__c == 'Joint' || assets[i].FinServ__Ownership__c == 'Joint with Spouse'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName+'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '},'+
                                    '{'+
                                    '"owner": "'+assets[i].FinServ__JointOwner__r.FirstName + ' ' + assets[i].FinServ__JointOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Other_Ownership_Share__c+'"'+
                                    '}';
                                
                            }
                            
                            if(assets[i].FinServ__Ownership__c == 'Joint (non-applicant)'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '},'+
                                    '{'+
									'"owner": "Others",'+
                                    '"ownerNameOther": "Other Non Spouse",'+
                                    '"ownershipPercentDebt": "'+assets[i].Other_Ownership_Share__c+'"'+
                                    '}';
                                
                            }
                            
                            body += ']'+
                                '}';
                            
                            if(i != assets.size()-1){
                                body += ',';
                            }
                        } 
                    }
                }
                
            }
            else{
                return '';
            }
        }
        body = body.removeEnd(',');
        return body;
        
    }
    
    /*public static string getAssets(contact con){
        String body = '';
        if(assets != null){
            if(assets.size() > 0){
                for(Integer i=0;i<assets.size();i++){
                    if(isApplicant2 != true){
							if(assets[i].FinServ__Ownership__c == 'Applicant 1'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '}';
                            }
							if(assets[i].FinServ__Ownership__c == 'Joint with Spouse'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '},'+
                                    '{'+
                                    '"owner": "Others",'+
									'"ownerNameOther": "Applicants Spouse",'+
                                    '"ownershipPercentDebt": "'+assets[i].Other_Ownership_Share__c+'"'+
                                    '}';
                                
                            }
                            
                            if(assets[i].FinServ__Ownership__c == 'Joint (non-applicant)'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '},'+
                                    '{'+
                                    '"owner": "Others",'+
                                    '"ownerNameOther": "Other Non Spouse",'+
                                    '"ownershipPercentDebt": "'+assets[i].Other_Ownership_Share__c+'"'+
                                    '}';
                                
                            }
                        if(i != assets.size()-1)
                            body += ',';    
                        
                    }
                    else{
                        if(assets[i].FinServ__Ownership__c == 'Applicant 1' || assets[i].FinServ__Ownership__c == 'Applicant 2'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '}';
                            }
							if(assets[i].FinServ__Ownership__c == 'Joint' || assets[i].FinServ__Ownership__c == 'Joint with Spouse'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName+'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '},'+
                                    '{'+
                                    '"owner": "'+assets[i].FinServ__JointOwner__r.FirstName + ' ' + assets[i].FinServ__JointOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Other_Ownership_Share__c+'"'+
                                    '}';
                                
                            }
                            
                            if(assets[i].FinServ__Ownership__c == 'Joint (non-applicant)'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '},'+
                                    '{'+
									'"owner": "Others",'+
                                    '"ownerNameOther": "Other Non Spouse",'+
                                    '"ownershipPercentDebt": "'+assets[i].Other_Ownership_Share__c+'"'+
                                    '}';
                                
                            }
                        if(i != assets.size()-1)
                            body += ',';    
                        
                    }
                }
            }else{
                return '';
            }
        }
        body = body.removeEnd(',');
        return body;
    }*/
    
    
    public static string accordionRealEstate(contact con){
        String body = '';
        if(assets != null){
            if(assets.size() > 0){
                for(Integer i=0;i<assets.size();i++){
                    if(isApplicant2 != true){
                        if(assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Investment Property' || assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Home' || assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Commercial Property'){
                            body += '{'+
                                '"rentalAddress": "'+assets[i].Address__c+'",'+
                                '"soldCheck": "No",'+
                                '"propValueAsset": "'+assets[i].Value__c+'",'+
                                '"ownershipP": [';
                            if(assets[i].FinServ__Ownership__c == 'Applicant 1'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '}';
                            }
							if(assets[i].FinServ__Ownership__c == 'Joint with Spouse'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '},'+
                                    '{'+
                                    '"owner": "Others",'+
									'"ownerNameOther": "Applicants Spouse",'+
                                    '"ownershipPercentDebt": "'+assets[i].Other_Ownership_Share__c+'"'+
                                    '}';
                                
                            }
                            
                            if(assets[i].FinServ__Ownership__c == 'Joint (non-applicant)'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '},'+
                                    '{'+
                                    '"owner": "Others",'+
                                    '"ownerNameOther": "Other Non Spouse",'+
                                    '"ownershipPercentDebt": "'+assets[i].Other_Ownership_Share__c+'"'+
                                    '}';
                                
                            }
                            
                            
                            body += ']'+
                                '}';
                            
                            if(i != assets.size()-1){
                                body += ',';
                            }
                        }  
                    }
                    else{
                        if(assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Investment Property' || assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Home' || assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Commercial Property'){
                            body += '{'+
                                '"rentalAddress": "'+assets[i].Address__c+'",'+
                                '"soldCheck": "No",'+
                                '"propValueAsset": "'+assets[i].Value__c+'",'+
                                '"ownershipP": [';
                            if(assets[i].FinServ__Ownership__c == 'Applicant 1' || assets[i].FinServ__Ownership__c == 'Applicant 2'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '}';
                            }
							if(assets[i].FinServ__Ownership__c == 'Joint' || assets[i].FinServ__Ownership__c == 'Joint with Spouse'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName+'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '},'+
                                    '{'+
                                    '"owner": "'+assets[i].FinServ__JointOwner__r.FirstName + ' ' + assets[i].FinServ__JointOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Other_Ownership_Share__c+'"'+
                                    '}';
                                
                            }
                            
                            if(assets[i].FinServ__Ownership__c == 'Joint (non-applicant)'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '},'+
                                    '{'+
									'"owner": "Others",'+
                                    '"ownerNameOther": "Other Non Spouse",'+
                                    '"ownershipPercentDebt": "'+assets[i].Other_Ownership_Share__c+'"'+
                                    '}';
                                
                            }        
                            
                            body += ']'+
                                '}';
                            
                            if(i != assets.size()-1){
                                body += ',';
                            }
                        }  
                    }
                }
                
            }else{
                return '';
            }
        }
        body = body.removeEnd(',');
        return body;
        
    }
    
    public static string otherAssets(contact con){
        String body = '';
        if(assets != null){
            if(assets.size() > 0){
                for(Integer i=0;i<assets.size();i++){
                    if(isApplicant2 != true){
                        if(assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Other' || assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Home Contents' || assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Shares Portfolio' || assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Motor Vehicle' ||assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Collectibles' || assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Leisure' ){
                            body += '{'+
                                '"otherAsset": "'+assets[i].FinServ__AssetsAndLiabilitiesType__c+'",'+
                                '"valueOtherAsse": "'+assets[i].Value__c+'",'+
                                '"ownerOtherAsset": [';
                            if(assets[i].FinServ__Ownership__c == 'Applicant 1'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '}';
                            }
							if(assets[i].FinServ__Ownership__c == 'Joint with Spouse'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '},'+
                                    '{'+
                                    '"owner": "Others",'+
									'"ownerNameOther": "Applicants Spouse",'+
                                    '"ownershipPercentDebt": "'+assets[i].Other_Ownership_Share__c+'"'+
                                    '}';
                                
                            }
                            
                            if(assets[i].FinServ__Ownership__c == 'Joint (non-applicant)'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '},'+
                                    '{'+
                                    '"owner": "Others",'+
                                    '"ownerNameOther": "Other Non Spouse",'+
                                    '"ownershipPercentDebt": "'+assets[i].Other_Ownership_Share__c+'"'+
                                    '}';
                                
                            }
                            
                            body += ']'+
                                '}';
                            
                            if(i != assets.size()-1){
                                body += ',';
                            }
                        }
                    }
                    else{
                        if(assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Other' || assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Home Contents' || assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Shares Portfolio' || assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Motor Vehicle' ||assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Collectibles' || assets[i].FinServ__AssetsAndLiabilitiesType__c == 'Leisure' ){
                            body += '{'+
                                '"otherAsset": "'+assets[i].FinServ__AssetsAndLiabilitiesType__c+'",'+
                                '"valueOtherAsse": "'+assets[i].Value__c+'",'+
                                '"ownerOtherAsset": [';
                            if(assets[i].FinServ__Ownership__c == 'Applicant 1' || assets[i].FinServ__Ownership__c == 'Applicant 2'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '}';
                            }
							if(assets[i].FinServ__Ownership__c == 'Joint' || assets[i].FinServ__Ownership__c == 'Joint with Spouse'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName+'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '},'+
                                    '{'+
                                    '"owner": "'+assets[i].FinServ__JointOwner__r.FirstName + ' ' + assets[i].FinServ__JointOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Other_Ownership_Share__c+'"'+
                                    '}';
                                
                            }
                            
                            if(assets[i].FinServ__Ownership__c == 'Joint (non-applicant)'){
                                body += '{'+
                                    '"owner": "'+assets[i].FinServ__PrimaryOwner__r.FirstName + ' ' + assets[i].FinServ__PrimaryOwner__r.LastName +'",'+
                                    '"ownershipPercentDebt": "'+assets[i].Ownership_Share__c+'"'+
                                    '},'+
                                    '{'+
									'"owner": "Others",'+
                                    '"ownerNameOther": "Other Non Spouse",'+
                                    '"ownershipPercentDebt": "'+assets[i].Other_Ownership_Share__c+'"'+
                                    '}';
                                
                            }                
                            
                            body += ']'+
                                '}';
                            
                            if(i != assets.size()-1){
                                body += ',';
                            }
                        }
                    }
                }
            }else{
                return '';
            }
        }
        body = body.removeEnd(',');
        return body;
    }
    
    public static String getLiabilities(contact con){
        String NA = 'N/A';
        Datetime randomNumber = system.now();
        String body = '';
        if(liabilities != null){
            if(liabilities.size() > 0){
                for(Integer i=0;i<liabilities.size();i++){
                    if(isApplicant2 != true){
                        Decimal ownershipShare = 0.0;
                        if(liabilities[i].Ownership_Share__c > 0 && liabilities[i].Other_Ownership_Share__c > 0){
                            ownershipShare =  liabilities[i].Ownership_Share__c + liabilities[i].Other_Ownership_Share__c;     
                        }else{
                            ownershipShare = 0.0;
                        }
                        if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Car Loan' || liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Auto Loan' || liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Personal Loan' || liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Margin Loan' || liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Overdraft' ||liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Payday Loan' ){
                            body += '{';
                            if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Car Loan' || liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Auto Loan'){
                                body += '"typeOfLoan" : "Car loan",';
                            }
                            if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Personal Loan'){
                                body += '"typeOfLoan" : "Personal Loan",';
                            } 
                            if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Margin Loan'){
                                body += '"typeOfLoan" : "Margin Loan",';
                            }
                            if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Overdraft'){
                                body += '"typeOfLoan" : "Overdraft",';
                            }
                            if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Payday Loan'){
                                body += '"typeOfLoan" : "Other Loan",';
                            }
                            
                            decimal amount = (liabilities[i].Value__c > 0 ? liabilities[i].Value__c : 0) - (liabilities[i].Limit__c > 0 ? liabilities[i].Limit__c : 0);
                            decimal interestRate = (liabilities[i].Interest_Rate__c == null ? 0.05 : (liabilities[i].Interest_Rate__c > 0 ? liabilities[i].Interest_Rate__c / 100 : 0.00));
                            body +=   
                                '"financialInstitution" : "'+liabilities[i].Institution__c+'",'+
                                '"acntNo" : "'+NA+'",'+
                                '"ownership" : 100,';
                           if((liabilities[i].FinServ__Ownership__c == 'Joint with Spouse' || liabilities[i].FinServ__Ownership__c == 'Joint') && con.Does_your_spouse_earn_an_income__c == 'Yes' && con.spouse_s_approximate_annual_income__c > 10000){
                                body +='"ownershipPercentExistingDebt" : 0.5,';
                           }else{
                               body +='"ownershipPercentExistingDebt" : 1.0,';
                           }
                               body+= '"outstandingBalanceRemaingTerm" : "'+liabilities[i].Value__c+'",'+ 
                                '"availableForRedrawAmountRemaingTerm" : "0",'+  
                                '"durationRemaingTerm" : "60",'+
                                '"interestRateLiability" : "'+(liabilities[i].Interest_Rate__c != null ? liabilities[i].Interest_Rate__c : 5.00)+'",'+
                                '"annualInterestRateRemaingTerm" : '+interestRate+','+
                                '"repaymentFrequencyContRepmt" : "'+(liabilities[i].Repayment_Frequency__c == null ? 'Monthly' : (liabilities[i].Repayment_Frequency__c == 'Annually' ? 'Yearly' : liabilities[i].Repayment_Frequency__c))+'",'+
                                '"actualRepaymentAmountExistingDebt" : "'+(liabilities[i].Monthly_Repayment__c != null ? liabilities[i].Monthly_Repayment__c : 0.00)+'",';
                            if(liabilities[i].Repayment_Type__c == 'Interest only'){
                                body +='"payType_PL" : "Interest Only",';
                            }
                            else{
                                body +='"payType_PL" : "Principal+Interest",';
                            }
                            body += 
                                '"loanForRepayLoan" : "No",';
                            if(liabilities[i].FinServ__Ownership__c == 'Joint'){
                                body += '"ownerSumPL" : "'+ownershipShare+'",';
                            }else{
                                body += '"ownerSumPL" : "'+liabilities[i].Ownership_Share__c+'",';    
                            }
                            body +=
                                '"ownerCheck" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' +liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
                                '"debtOwner_Acc_PL" : [';
                           
                            
                            if(liabilities[i].FinServ__Ownership__c == 'Joint with Spouse' && con.Does_your_spouse_earn_an_income__c == 'Yes' && con.spouse_s_approximate_annual_income__c > 10000){
                                if(liabilities[i].FinServ__Ownership__c == 'Joint with Spouse'){
                                    body +=
                                        '{'+
                                        '"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' +liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
                                        '"ownerNameOther" : "",'+
                                        '"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'",'+
                                        '"ownershipAppAndCoApp" : "'+liabilities[i].Ownership_Share__c+'",'+
                                        '"oth" : "Others",'+
                                        '"countAppPur" : "1"'+
                                        '},'+
                                        '{'+
                                        '"owner" : "Others",'+
                                        '"ownerNameOther" : "Applicants Spouse",'+
                                        '"ownershipPercentDebt" : "'+liabilities[i].Other_Ownership_Share__c+'",'+
                                        '"ownershipAppAndCoApp" : "'+liabilities[i].Other_Ownership_Share__c+'",'+
                                        '"oth" : "Others",'+
                                        '"countAppPur" : "1"'+
                                        '}';
                                }
                                if(liabilities[i].FinServ__Ownership__c == 'Joint (non-applicant)'){
                                    body +=
                                        '{'+
                                        '"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' +liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
                                        '"ownerNameOther" : "",'+
                                        '"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'",'+
                                        '"ownershipAppAndCoApp" : "'+liabilities[i].Ownership_Share__c+'",'+
                                        '"oth" : "Others",'+
                                        '"countAppPur" : "1"'+
                                        '},'+
                                        '{'+
                                        '"owner" : "Others",'+
                                        '"ownerNameOther" : "Other Non Spouse",'+
                                        '"ownershipPercentDebt" : "'+liabilities[i].Other_Ownership_Share__c+'",'+
                                        '"ownershipAppAndCoApp" : "'+liabilities[i].Other_Ownership_Share__c+'",'+
                                        '"oth" : "Others",'+
                                        '"countAppPur" : "1"'+
                                        '}';
                                }
                            }
                            else{
                                if(liabilities[i].FinServ__Ownership__c == 'Applicant 1'){
                                    body+=    '{'+
                                        '"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' + liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
                                        '"ownerNameOther" : "",'+
                                        '"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'",'+
                                        '"ownershipAppAndCoApp" : "'+liabilities[i].Ownership_Share__c+'",'+
                                        '"oth" : "Others",'+
                                        '"countAppPur" : "1"'+
                                        '}';
                                }
                            }
                            
                            body +=  '],'+
                                '"creditLimitRemaingTerm" : '+liabilities[i].Limit__c+','+
                                '"_entryId" : "'+randomNumber+'",'+
                                '"_type" : "Personal Loans/Bank Facilities/Overdrafts"'+
                                '}';
                            if(i != liabilities.size()-1)
                                body += ',';
                        }
                        
                        if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c  == 'Home Loan/Mortgage' || liabilities[i].FinServ__AssetsAndLiabilitiesType__c  == 'Investment Home Loan' ||liabilities[i].FinServ__AssetsAndLiabilitiesType__c  == 'Commercial Mortgage'){
                            decimal amount = (liabilities[i].Value__c > 0 ? liabilities[i].Value__c : 0) - (liabilities[i].Limit__c > 0 ? liabilities[i].Limit__c : 0);
                           	decimal interestRate = (liabilities[i].Interest_Rate__c == null ? 0.05 : (liabilities[i].Interest_Rate__c > 0 ? liabilities[i].Interest_Rate__c / 100 : 0.00));
                            body +=
                                '{'+
                                '"typeOfLoan" : "Mortgage Loan",'+
                                '"financialInstitution" : "'+liabilities[i].Institution__c+'",'+
                                '"acntNo" : "'+NA+'",'+
                               	'"Owenrship" : 100,';
                                if((liabilities[i].FinServ__Ownership__c == 'Joint with Spouse' || liabilities[i].FinServ__Ownership__c == 'Joint') && con.Does_your_spouse_earn_an_income__c == 'Yes' && con.spouse_s_approximate_annual_income__c > 10000){
                                    body +='"ownershipPercentExistingDebt" : 0.5,';
                                }else{
                                    body +='"ownershipPercentExistingDebt" : 1.0,';
                                }
                                body+=
                                '"outstandingBalanceRemaingTerm" : "'+liabilities[i].Value__c+'",'+
                                '"availableForRedrawAmountRemaingTerm" : "0",'+
                                '"durationRemaingTerm" : "360",'+
                                '"interestRateLiability" : "'+(liabilities[i].Interest_Rate__c != null ? liabilities[i].Interest_Rate__c : 5.00)+'",'+
                                '"annualInterestRateRemaingTerm" : '+interestRate+','+
                                '"repaymentFrequencyContRepmt" : "'+(liabilities[i].Repayment_Frequency__c == null ? 'Monthly' : (liabilities[i].Repayment_Frequency__c == 'Annually' ? 'Yearly' : liabilities[i].Repayment_Frequency__c))+'",'+
                                '"actualRepaymentAmountExistingDebt" : "'+(liabilities[i].Monthly_Repayment__c != null ? liabilities[i].Monthly_Repayment__c : 0.00)+'",';
                            if(liabilities[i].Repayment_Type__c == 'Interest only'){
                                body +='"paymentType" : "Interest Only",';
                            }
                            else{
                                body +='"paymentType" : "Principal+Interest",';
                            }
                            
                            if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c  == 'Investment Home Loan' ||liabilities[i].FinServ__AssetsAndLiabilitiesType__c  == 'Commercial Mortgage'){
                                body += 
                                    '"taxDeductible" : "Yes",';
                            }else{
                                body += 
                                    '"taxDeductible" : "No",';
                            }
                            body +=
                                '"amountAsDebt" : "'+liabilities[i].Value__c+'",'+
                                '"loanForRepayLoan" : "No",'+
                                '"ownershipMortgage" : '+ownershipShare+','+
                                '"checkJoint" : 1,'+
                                '"checkOwner" : "a",'+
                                '"OwnershipMor" : [';
                            if(liabilities[i].FinServ__Ownership__c == 'Joint with Spouse' && con.Does_your_spouse_earn_an_income__c == 'Yes' && con.spouse_s_approximate_annual_income__c > 10000){
                                if(liabilities[i].FinServ__Ownership__c == 'Joint with Spouse'){
                                    body +=
                                        '{'+
                                        '"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' +liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
                                        '"ownerNameOther" : "",'+
                                        '"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'",'+
                                        '"ownershipAppAndCoApp" : "'+liabilities[i].Ownership_Share__c+'",'+
                                        '"oth" : "Others",'+
                                        '"countAppPur" : "1"'+
                                        '},'+
                                        '{'+
                                        '"owner" : "Others",'+
                                        '"ownerNameOther" : "Applicants Spouse",'+
                                        '"ownershipPercentDebt" : "'+liabilities[i].Other_Ownership_Share__c+'",'+
                                        '"ownershipAppAndCoApp" : "'+liabilities[i].Other_Ownership_Share__c+'",'+
                                        '"oth" : "Others",'+
                                        '"countAppPur" : "1"'+
                                        '}';
                                }
                                if(liabilities[i].FinServ__Ownership__c == 'Joint (non-applicant)'){
                                    body +=
                                        '{'+
                                        '"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' +liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
                                        '"ownerNameOther" : "",'+
                                        '"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'",'+
                                        '"ownershipAppAndCoApp" : "'+liabilities[i].Ownership_Share__c+'",'+
                                        '"oth" : "Others",'+
                                        '"countAppPur" : "1"'+
                                        '},'+
                                        '{'+
                                        '"owner" : "Others",'+
                                        '"ownerNameOther" : "Other Non Spouse",'+
                                        '"ownershipPercentDebt" : "'+liabilities[i].Other_Ownership_Share__c+'",'+
                                        '"ownershipAppAndCoApp" : "'+liabilities[i].Other_Ownership_Share__c+'",'+
                                        '"oth" : "Others",'+
                                        '"countAppPur" : "1"'+
                                        '}';
                                }
                            }
                            else{
                                if(liabilities[i].FinServ__Ownership__c == 'Applicant 1'){
                                    body+=    '{'+
                                        '"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' + liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
                                        '"ownerNameOther" : "",'+
                                        '"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'",'+
                                        '"ownershipAppAndCoApp" : "'+liabilities[i].Ownership_Share__c+'",'+
                                        '"oth" : "Others",'+
                                        '"countAppPur" : "1"'+
                                        '}';
                                }
                            }
                            body += '],'+
                                '"creditLimitRemaingTerm" : '+liabilities[i].Limit__c+','+
                                '"_entryId" : "'+randomNumber+'",'+
                                '"_type" : "Mortgages"'+
                                '}';
                            if(i != liabilities.size()-1)
                                body += ',';
                        }
                        
                        
                        if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'HECS/HELP' || liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Car Lease' || liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Tax liability'){
                            decimal interestRate = (liabilities[i].Interest_Rate__c == null ? 0.05 : (liabilities[i].Interest_Rate__c > 0 ? liabilities[i].Interest_Rate__c / 100 : 0.00));
                            body += '{';
                            if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'HECS/HELP'){
                                body +='"typeOfLoan" : "HECS - HELP",';     
                            }
                            if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Car Lease'){
                                body +='"typeOfLoan" : "Hire Purchase",';     
                            }
                            if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Tax liability'){
                                body +='"typeOfLoan" : "Outstanding Taxation",';     
                            }
                            body +=
                                '"financialInstitution"	 : "'+liabilities[i].Institution__c+'",'+
                                '"acntNo" : "'+NA+'",'+
                                '"ownership" : 100,';
                                if((liabilities[i].FinServ__Ownership__c == 'Joint with Spouse' || liabilities[i].FinServ__Ownership__c == 'Joint') && con.Does_your_spouse_earn_an_income__c == 'Yes' && con.spouse_s_approximate_annual_income__c > 10000){
                                    body +='"ownershipPercentExistingDebt" : 0.5,';
                                }else{
                                    body +='"ownershipPercentExistingDebt" : 1.0,';
                                }
                                body+=
                                '"outstandingBalanceRemaingTerm" : "'+liabilities[i].Value__c+'",'+
                                '"availableForRedrawAmountRemaingTerm" : "0",'+
                                '"durationRemaingTerm" : "60",'+
                                '"interestRateLiability" : "'+(liabilities[i].Interest_Rate__c != null ? liabilities[i].Interest_Rate__c : 5.00)+'",'+
                                '"annualInterestRateRemaingTerm" : '+interestRate+','+
                                '"repaymentFrequencyContRepmt" : "'+(liabilities[i].Repayment_Frequency__c == null ? 'Monthly' : (liabilities[i].Repayment_Frequency__c == 'Annually' ? 'Yearly' : liabilities[i].Repayment_Frequency__c))+'",'+
                                '"actualRepaymentAmountExistingDebt" : "'+(liabilities[i].Monthly_Repayment__c != null ? liabilities[i].Monthly_Repayment__c : 0.00)+'",';
                            if(liabilities[i].Repayment_Type__c == 'Interest only'){
                                body +='"paymentType" : "Interest Only",';
                            }
                            else{
                                body +='"paymentType" : "Principal+Interest",';
                            }
                            body +=  
                                '"loanForRepayLoan" : "No",';
                            if(liabilities[i].FinServ__Ownership__c == 'Joint'){
                                body += '"ownerHirePur" : "'+ownershipShare+'",';
                            }else{
                                body += '"ownerHirePur" : "'+liabilities[i].Ownership_Share__c+'",';    
                            }
                            body +=
                                '"ownerCheck" : "'+contact.Name+'",'+
                                '"ownerShipPer_HP" : [';
                            if(liabilities[i].FinServ__Ownership__c == 'Joint with Spouse' && con.Does_your_spouse_earn_an_income__c == 'Yes' && con.spouse_s_approximate_annual_income__c > 10000){
                                if(liabilities[i].FinServ__Ownership__c == 'Joint with Spouse'){
                                    body +=
                                        '{'+
                                        '"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' +liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
                                        '"ownerNameOther" : "",'+
                                        '"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'",'+
                                        '"ownershipAppAndCoApp" : "'+liabilities[i].Ownership_Share__c+'",'+
                                        '"oth" : "Others",'+
                                        '"countAppPur" : "1"'+
                                        '},'+
                                        '{'+
                                        '"owner" : "Others",'+
                                        '"ownerNameOther" : "Applicants Spouse",'+
                                        '"ownershipPercentDebt" : "'+liabilities[i].Other_Ownership_Share__c+'",'+
                                        '"ownershipAppAndCoApp" : "'+liabilities[i].Other_Ownership_Share__c+'",'+
                                        '"oth" : "Others",'+
                                        '"countAppPur" : "1"'+
                                        '}';
                                }
                                if(liabilities[i].FinServ__Ownership__c == 'Joint (non-applicant)'){
                                    body +=
                                        '{'+
                                        '"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' +liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
                                        '"ownerNameOther" : "",'+
                                        '"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'",'+
                                        '"ownershipAppAndCoApp" : "'+liabilities[i].Ownership_Share__c+'",'+
                                        '"oth" : "Others",'+
                                        '"countAppPur" : "1"'+
                                        '},'+
                                        '{'+
                                        '"owner" : "Others",'+
                                        '"ownerNameOther" : "Other Non Spouse",'+
                                        '"ownershipPercentDebt" : "'+liabilities[i].Other_Ownership_Share__c+'",'+
                                        '"ownershipAppAndCoApp" : "'+liabilities[i].Other_Ownership_Share__c+'",'+
                                        '"oth" : "Others",'+
                                        '"countAppPur" : "1"'+
                                        '}';
                                }
                            }
                            else{
                                if(liabilities[i].FinServ__Ownership__c == 'Applicant 1'){
                                    body+=    '{'+
                                        '"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' + liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
                                        '"ownerNameOther" : "",'+
                                        '"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'",'+
                                        '"ownershipAppAndCoApp" : "'+liabilities[i].Ownership_Share__c+'",'+
                                        '"oth" : "Others",'+
                                        '"countAppPur" : "1"'+
                                        '}';
                                }
                            }
                            body += '],'+
                                '"creditLimitRemaingTerm" : '+liabilities[i].Limit__c+','+
                                '"_entryId" : "'+randomNumber+'",'+
                                '"_type" : "Hire Purchase/Lease/Personal Debts"'+
                                '}';
                            if(i != liabilities.size()-1)
                                body += ',';
                        } 
                        
                        if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Credit Card / Store Card' || liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Merchant Credit (zip pay / afterpay / certigy)'){
                            decimal interestRate = (liabilities[i].Interest_Rate__c == null ? 0.05 : (liabilities[i].Interest_Rate__c > 0 ? liabilities[i].Interest_Rate__c / 100 : 0.00));
                            body +=
                                '{';
                            if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Credit Card / Store Card'){
                                body += '"typeOfLoan" : "Credit Cards",';
                            }
                            if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Merchant Credit (zip pay / afterpay / certigy)'){
                                body += '"typeOfLoan" : "Buy Now Pay Later",';
                            }
                                
                                body +='"financialInstitution" : "'+liabilities[i].Institution__c+'",'+
                                '"acntNo" : "0000000000000000",'+
                                '"ownership" : "100",';
                            	if((liabilities[i].FinServ__Ownership__c == 'Joint with Spouse' || liabilities[i].FinServ__Ownership__c == 'Joint') && con.Does_your_spouse_earn_an_income__c == 'Yes' && con.spouse_s_approximate_annual_income__c > 10000){
                                    body +='"ownershipPercentExistingDebt" : 0.5,';
                                }else{
                                    body +='"ownershipPercentExistingDebt" : 1.0,';
                                }
                                body+=
                                '"outstandingBalanceRemaingTerm" : "'+liabilities[i].Value__c+'",'+
                                '"limit" : "'+liabilities[i].Limit__c+'",'+
                                '"availableForRedrawAmountRemaingTerm" : "0",'+
                                '"interestRateLiability" : "'+(liabilities[i].Interest_Rate__c != null ? liabilities[i].Interest_Rate__c : 5.00)+'",'+
                                '"annualInterestRateRemaingTerm" : '+interestRate+','+
                                '"actualRepaymentAmountExistingDebt" : "'+(liabilities[i].Monthly_Repayment__c != null ? liabilities[i].Monthly_Repayment__c : 0.00)+'",'+
                                '"loanForRepayLoan" : "No",';
                            
                            if(liabilities[i].FinServ__Ownership__c == 'Joint'){
                                body += '"ownerSumCreditCard" : "'+ownershipShare+'",';
                            }else{
                                body += '"ownerSumCreditCard" : "'+liabilities[i].Ownership_Share__c+'",';    
                            }
                            body +='"ownershipDet_CC" : [';
                            if(liabilities[i].FinServ__Ownership__c == 'Joint with Spouse' && con.Does_your_spouse_earn_an_income__c == 'Yes' && con.spouse_s_approximate_annual_income__c > 10000){
                                if(liabilities[i].FinServ__Ownership__c == 'Joint with Spouse'){
                                    body +=
                                        '{'+
                                        '"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' +liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
                                        '"ownerNameOther" : "",'+
                                        '"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'"'+
                                        '},'+
                                        '{'+
                                        '"owner" : "Others",'+
                                        '"ownerNameOther" : "Applicants Spouse",'+
                                        '"ownershipPercentDebt" : "'+liabilities[i].Other_Ownership_Share__c+'"'+
                                        '}';
                                }
                                if(liabilities[i].FinServ__Ownership__c == 'Joint (non-applicant)'){
                                    body +=
                                        '{'+
                                        '"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' +liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
                                        '"ownerNameOther" : "",'+
                                        '"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'"'+
                                        '},'+
                                        '{'+
                                        '"owner" : "Others",'+
                                        '"ownerNameOther" : "Other Non Spouse",'+
                                        '"ownershipPercentDebt" : "'+liabilities[i].Other_Ownership_Share__c+'"'+
                                        '}';
                                }
                            }
                            else{
                                if(liabilities[i].FinServ__Ownership__c == 'Applicant 1'){
                                    body+=    '{'+
                                        '"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' + liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
                                        '"ownerNameOther" : "",'+
                                        '"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'"'+
                                        '}';
                                }
                            }
                            
                            
                            body += '],'+
                                
                                '"ownerCheckCredit" : "1",'+
                                '"creditLimitRemaingTerm" : '+liabilities[i].Limit__c+','+
                                '"_entryId" : "'+randomNumber+'",'+
                                '"_type" : "Credit Cards/Store Cards/BNPL"'+
                                '}';
                            
                                
                            if(i != liabilities.size()-1)
                                body += ',';
                        }
                        
                    }
                    else{
                        Decimal ownershipShare = 0.0;
                        if(liabilities[i].Ownership_Share__c > 0 && liabilities[i].Other_Ownership_Share__c > 0){
                            ownershipShare =  liabilities[i].Ownership_Share__c + liabilities[i].Other_Ownership_Share__c;     
                        }else{
                            ownershipShare = 0.0;
                        }
                        if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Car Loan' || liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Auto Loan' || liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Personal Loan' || liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Margin Loan' || liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Overdraft' ||liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Payday Loan' ){
                            body += '{';
                            if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Car Loan' || liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Auto Loan'){
                                body += '"typeOfLoan" : "Car loan",';
                            }
                            if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Personal Loan'){
                                body += '"typeOfLoan" : "Personal Loan",';
                            } 
                            if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Margin Loan'){
                                body += '"typeOfLoan" : "Margin Loan",';
                            }
                            if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Overdraft'){
                                body += '"typeOfLoan" : "Overdraft",';
                            }
                            if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Payday Loan'){
                                body += '"typeOfLoan" : "Other Loan",';
                            }
                            
                            decimal amount = (liabilities[i].Value__c > 0 ? liabilities[i].Value__c : 0) - (liabilities[i].Limit__c > 0 ? liabilities[i].Limit__c : 0);
                            decimal interestRate = (liabilities[i].Interest_Rate__c == null ? 0.05 : (liabilities[i].Interest_Rate__c > 0 ? liabilities[i].Interest_Rate__c / 100 : 0.00));
                            body +=   
                                '"financialInstitution" : "'+liabilities[i].Institution__c+'",'+
                                '"acntNo" : "'+NA+'",'+
                                '"ownership" : 100,'+
                            	'"ownershipPercentExistingDebt" : 1.0,'+
                                '"outstandingBalanceRemaingTerm" : "'+liabilities[i].Value__c+'",'+ 
                                '"availableForRedrawAmountRemaingTerm" : "0",'+  
                                '"durationRemaingTerm" : "60",'+
                                '"interestRateLiability" : "'+(liabilities[i].Interest_Rate__c != null ? liabilities[i].Interest_Rate__c : 5.00)+'",'+
                                '"annualInterestRateRemaingTerm" : '+interestRate+','+
                                '"repaymentFrequencyContRepmt" : "'+(liabilities[i].Repayment_Frequency__c == null ? 'Monthly' : (liabilities[i].Repayment_Frequency__c == 'Annually' ? 'Yearly' : liabilities[i].Repayment_Frequency__c))+'",'+
                                '"actualRepaymentAmountExistingDebt" : "'+(liabilities[i].Monthly_Repayment__c != null ? liabilities[i].Monthly_Repayment__c : 0.00)+'",';
                            if(liabilities[i].Repayment_Type__c == 'Interest only'){
                                body +='"payType_PL" : "Interest Only",';
                            }
                            else{
                                body +='"payType_PL" : "Principal+Interest",';
                            }
                            body += 
                                '"loanForRepayLoan" : "No",';
                            if(liabilities[i].FinServ__Ownership__c == 'Joint'){
                                body += '"ownerSumPL" : "'+ownershipShare+'",';
                            }else{
                                body += '"ownerSumPL" : "'+liabilities[i].Ownership_Share__c+'",';    
                            }
                            body +=
                                '"ownerCheck" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' +liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
                                '"debtOwner_Acc_PL" : [';
									
							if(liabilities[i].FinServ__Ownership__c == 'Applicant 1' || liabilities[i].FinServ__Ownership__c == 'Applicant 2'){
								body += 
										'{'+
									'"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' +liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
									'"ownerNameOther" : "",'+
									'"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'",'+
									'"ownershipAppAndCoApp" : "'+liabilities[i].Ownership_Share__c+'",'+
									'"oth" : "Others",'+
									'"countAppPur" : "1"'+
									'}';
							} 
                            if(liabilities[i].FinServ__Ownership__c == 'Joint'){
                                body += 
										'{'+
									'"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' +liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
									'"ownerNameOther" : "",'+
									'"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'",'+
									'"ownershipAppAndCoApp" : "'+liabilities[i].Ownership_Share__c+'",'+
									'"oth" : "Others",'+
									'"countAppPur" : "1"'+
									'},'+
                                    '{'+
                                    '"owner" : "'+liabilities[i].FinServ__JointOwner__r.FirstName + ' ' +liabilities[i].FinServ__JointOwner__r.LastName+'",'+
                                    '"ownerNameOther" : "",'+
                                    '"ownershipPercentDebt" : "'+liabilities[i].Other_Ownership_Share__c+'",'+
                                    '"ownershipAppAndCoApp" : "'+liabilities[i].Other_Ownership_Share__c+'",'+
                                    '"oth" : "Others",'+
                                    '"countAppPur" : "1"'+
                                    '}';
                            }
                            if(liabilities[i].FinServ__Ownership__c == 'Joint (non-applicant)'){
                               body += 
										'{'+
									'"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' +liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
									'"ownerNameOther" : "",'+
									'"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'",'+
									'"ownershipAppAndCoApp" : "'+liabilities[i].Ownership_Share__c+'",'+
									'"oth" : "Others",'+
									'"countAppPur" : "1"'+
									'},'+
                                    '{'+
                                    '"owner" : "Others",'+
                                    '"ownerNameOther" : "Other Non Spouse",'+
                                    '"ownershipPercentDebt" : "'+Integer.valueOf(liabilities[i].Other_Ownership_Share__c)+'",'+
                                    '"ownershipAppAndCoApp" : "'+Integer.valueOf(liabilities[i].Other_Ownership_Share__c)+'",'+
                                    '"oth" : "Others",'+
                                    '"countAppPur" : "1"'+
                                    '}';
                            }
                            body +=  '],'+
                                '"creditLimitRemaingTerm" : '+liabilities[i].Limit__c+','+
                                '"_entryId" : "'+randomNumber+'",'+
                                '"_type" : "Personal Loans/Bank Facilities/Overdrafts"'+
                                '}';
                            if(i != liabilities.size()-1)
                                body += ',';
                        }
                        
                        if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c  == 'Home Loan/Mortgage' || liabilities[i].FinServ__AssetsAndLiabilitiesType__c  == 'Investment Home Loan' ||liabilities[i].FinServ__AssetsAndLiabilitiesType__c  == 'Commercial Mortgage'){
                            decimal amount = (liabilities[i].Value__c > 0 ? liabilities[i].Value__c : 0) - (liabilities[i].Limit__c > 0 ? liabilities[i].Limit__c : 0);
                            decimal interestRate = (liabilities[i].Interest_Rate__c == null ? 0.05 : (liabilities[i].Interest_Rate__c > 0 ? liabilities[i].Interest_Rate__c / 100 : 0.00));
                            body +=
                                '{'+
                                '"typeOfLoan" : "Mortgage Loan",'+
                                '"financialInstitution" : "'+liabilities[i].Institution__c+'",'+
                                '"acntNo" : "'+NA+'",'+
                                '"Owenrship" : 100,'+
                                '"ownershipPercentExistingDebt" : 1.0,'+
                                '"outstandingBalanceRemaingTerm" : "'+liabilities[i].Value__c+'",'+
                                '"availableForRedrawAmountRemaingTerm" : "0",'+
                                '"durationRemaingTerm" : "360",'+
                                '"interestRateLiability" : "'+(liabilities[i].Interest_Rate__c != null ? liabilities[i].Interest_Rate__c : 5.00)+'",'+
                                '"annualInterestRateRemaingTerm" : '+interestRate+','+
                                '"repaymentFrequencyContRepmt" : "'+(liabilities[i].Repayment_Frequency__c == null ? 'Monthly' : (liabilities[i].Repayment_Frequency__c == 'Annually' ? 'Yearly' : liabilities[i].Repayment_Frequency__c))+'",'+
                                '"actualRepaymentAmountExistingDebt" : "'+(liabilities[i].Monthly_Repayment__c != null ? liabilities[i].Monthly_Repayment__c : 0.00)+'",';
                            if(liabilities[i].Repayment_Type__c == 'Interest only'){
                                body +='"paymentType" : "Interest Only",';
                            }
                            else{
                                body +='"paymentType" : "Principal+Interest",';
                            }
                            
                            if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c  == 'Investment Home Loan' ||liabilities[i].FinServ__AssetsAndLiabilitiesType__c  == 'Commercial Mortgage'){
                                body += 
                                    '"taxDeductible" : "Yes",';
                            }else{
                                body += 
                                    '"taxDeductible" : "No",';
                            }
                            body +=
                                '"amountAsDebt" : "'+liabilities[i].Value__c+'",'+
                                '"loanForRepayLoan" : "No",'+
                                '"ownershipMortgage" : '+ownershipShare+','+
                                '"checkJoint" : 1,'+
                                '"checkOwner" : "a",'+
                                '"OwnershipMor" : [';
                                if(liabilities[i].FinServ__Ownership__c == 'Applicant 1' || liabilities[i].FinServ__Ownership__c == 'Applicant 2'){
								body += 
										'{'+
									'"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' +liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
									'"ownerNameOther" : "",'+
									'"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'",'+
									'"ownershipAppAndCoApp" : "'+liabilities[i].Ownership_Share__c+'",'+
									'"oth" : "Others",'+
									'"countAppPur" : "1"'+
									'}';
							} 
                            if(liabilities[i].FinServ__Ownership__c == 'Joint'){
                                body += 
										'{'+
									'"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' +liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
									'"ownerNameOther" : "",'+
									'"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'",'+
									'"ownershipAppAndCoApp" : "'+liabilities[i].Ownership_Share__c+'",'+
									'"oth" : "Others",'+
									'"countAppPur" : "1"'+
									'},'+
                                    '{'+
                                    '"owner" : "'+liabilities[i].FinServ__JointOwner__r.FirstName + ' ' +liabilities[i].FinServ__JointOwner__r.LastName+'",'+
                                    '"ownerNameOther" : "",'+
                                    '"ownershipPercentDebt" : "'+liabilities[i].Other_Ownership_Share__c+'",'+
                                    '"ownershipAppAndCoApp" : "'+liabilities[i].Other_Ownership_Share__c+'",'+
                                    '"oth" : "Others",'+
                                    '"countAppPur" : "1"'+
                                    '}';
                            }
                            if(liabilities[i].FinServ__Ownership__c == 'Joint (non-applicant)'){
                               body += 
										'{'+
									'"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' +liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
									'"ownerNameOther" : "",'+
									'"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'",'+
									'"ownershipAppAndCoApp" : "'+liabilities[i].Ownership_Share__c+'",'+
									'"oth" : "Others",'+
									'"countAppPur" : "1"'+
									'},'+
                                    '{'+
                                    '"owner" : "Others",'+
                                    '"ownerNameOther" : "Other Non Spouse",'+
                                    '"ownershipPercentDebt" : "'+Integer.valueOf(liabilities[i].Other_Ownership_Share__c)+'",'+
                                    '"ownershipAppAndCoApp" : "'+Integer.valueOf(liabilities[i].Other_Ownership_Share__c)+'",'+
                                    '"oth" : "Others",'+
                                    '"countAppPur" : "1"'+
                                    '}';
                            }
                            body += '],'+
                                '"creditLimitRemaingTerm" : '+liabilities[i].Limit__c+','+
                                '"_entryId" : "'+randomNumber+'",'+
                                '"_type" : "Mortgages"'+
                                '}';
                            if(i != liabilities.size()-1)
                                body += ',';
                        }
                        
                        
                        if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'HECS/HELP' || liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Car Lease' || liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Tax liability'){
                            body += '{';
                            if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'HECS/HELP'){
                                body +='"typeOfLoan" : "HECS - HELP",';     
                            }
                            if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Car Lease'){
                                body +='"typeOfLoan" : "Hire Purchase",';     
                            }
                            if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Tax liability'){
                                body +='"typeOfLoan" : "Outstanding Taxation",';     
                            }
                            decimal interestRate = (liabilities[i].Interest_Rate__c == null ? 0.05 : (liabilities[i].Interest_Rate__c > 0 ? liabilities[i].Interest_Rate__c / 100 : 0.00));	
                            body +=
                                '"financialInstitution"	 : "'+liabilities[i].Institution__c+'",'+
                                '"acntNo" : "'+NA+'",'+
                                '"ownership" : 100,'+
                                '"ownershipPercentExistingDebt" : 1.0,'+
                                '"outstandingBalanceRemaingTerm" : "'+liabilities[i].Value__c+'",'+
                                '"availableForRedrawAmountRemaingTerm" : "0",'+
                                '"durationRemaingTerm" : "60",'+
                                '"interestRateLiability" : "'+(liabilities[i].Interest_Rate__c != null ? liabilities[i].Interest_Rate__c : 5.00)+'",'+
                                '"annualInterestRateRemaingTerm" : '+interestRate+','+
                                '"repaymentFrequencyContRepmt" : "'+(liabilities[i].Repayment_Frequency__c == null ? 'Monthly' : (liabilities[i].Repayment_Frequency__c == 'Annually' ? 'Yearly' : liabilities[i].Repayment_Frequency__c))+'",'+
                                '"actualRepaymentAmountExistingDebt" : "'+(liabilities[i].Monthly_Repayment__c != null ? liabilities[i].Monthly_Repayment__c : 0.00)+'",';
                            if(liabilities[i].Repayment_Type__c == 'Interest only'){
                                body +='"paymentType" : "Interest Only",';
                            }
                            else{
                                body +='"paymentType" : "Principal+Interest",';
                            }
                            body +=  
                                '"loanForRepayLoan" : "No",';
                            if(liabilities[i].FinServ__Ownership__c == 'Joint'){
                                body += '"ownerHirePur" : "'+ownershipShare+'",';
                            }else{
                                body += '"ownerHirePur" : "'+liabilities[i].Ownership_Share__c+'",';    
                            }
                            body +=
                                '"ownerCheck" : "'+contact.Name+'",'+
                                '"ownerShipPer_HP" : [';
                               if(liabilities[i].FinServ__Ownership__c == 'Applicant 1' || liabilities[i].FinServ__Ownership__c == 'Applicant 2'){
								body += 
										'{'+
									'"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' +liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
									'"ownerNameOther" : "",'+
									'"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'",'+
									'"ownershipAppAndCoApp" : "'+liabilities[i].Ownership_Share__c+'",'+
									'"oth" : "Others",'+
									'"countAppPur" : "1"'+
									'}';
							} 
                            if(liabilities[i].FinServ__Ownership__c == 'Joint'){
                                body += 
										'{'+
									'"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' +liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
									'"ownerNameOther" : "",'+
									'"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'",'+
									'"ownershipAppAndCoApp" : "'+liabilities[i].Ownership_Share__c+'",'+
									'"oth" : "Others",'+
									'"countAppPur" : "1"'+
									'},'+
                                    '{'+
                                    '"owner" : "'+liabilities[i].FinServ__JointOwner__r.FirstName + ' ' +liabilities[i].FinServ__JointOwner__r.LastName+'",'+
                                    '"ownerNameOther" : "",'+
                                    '"ownershipPercentDebt" : "'+liabilities[i].Other_Ownership_Share__c+'",'+
                                    '"ownershipAppAndCoApp" : "'+liabilities[i].Other_Ownership_Share__c+'",'+
                                    '"oth" : "Others",'+
                                    '"countAppPur" : "1"'+
                                    '}';
                            }
                            if(liabilities[i].FinServ__Ownership__c == 'Joint (non-applicant)'){
                               body += 
										'{'+
									'"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' +liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
									'"ownerNameOther" : "",'+
									'"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'",'+
									'"ownershipAppAndCoApp" : "'+liabilities[i].Ownership_Share__c+'",'+
									'"oth" : "Others",'+
									'"countAppPur" : "1"'+
									'},'+
                                    '{'+
                                    '"owner" : "Others",'+
                                    '"ownerNameOther" : "Other Non Spouse",'+
                                    '"ownershipPercentDebt" : "'+Integer.valueOf(liabilities[i].Other_Ownership_Share__c)+'",'+
                                    '"ownershipAppAndCoApp" : "'+Integer.valueOf(liabilities[i].Other_Ownership_Share__c)+'",'+
                                    '"oth" : "Others",'+
                                    '"countAppPur" : "1"'+
                                    '}';
                            }
                            body += '],'+
                                '"creditLimitRemaingTerm" : '+liabilities[i].Limit__c+','+
                                '"_entryId" : "'+randomNumber+'",'+
                                '"_type" : "Hire Purchase/Lease/Personal Debts"'+
                                '}';
                            if(i != liabilities.size()-1)
                                body += ',';
                        } 
                        
                         if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Credit Card / Store Card' || liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Merchant Credit (zip pay / afterpay / certigy)'){
                            decimal interestRate = (liabilities[i].Interest_Rate__c == null ? 0.05 : (liabilities[i].Interest_Rate__c > 0 ? liabilities[i].Interest_Rate__c / 100 : 0.00));
                            body +=
                                '{';
                            if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Credit Card / Store Card'){
                                body += '"typeOfLoan" : "Credit Cards",';
                            }
                            if(liabilities[i].FinServ__AssetsAndLiabilitiesType__c == 'Merchant Credit (zip pay / afterpay / certigy)'){
                                body += '"typeOfLoan" : "Buy Now Pay Later",';
                            }
                                
                                body +='"financialInstitution" : "'+liabilities[i].Institution__c+'",'+
                                '"acntNo" : "0000000000000000",'+
                                '"ownership" : "100",'+
                                '"ownershipPercentExistingDebt" : 1.0,'+
                                '"outstandingBalanceRemaingTerm" : "'+liabilities[i].Value__c+'",'+
                                '"limit" : "'+liabilities[i].Limit__c+'",'+
                                '"availableForRedrawAmountRemaingTerm" : "0",'+
                                '"interestRateLiability" : "'+(liabilities[i].Interest_Rate__c != null ? liabilities[i].Interest_Rate__c : 5.00)+'",'+
                                '"annualInterestRateRemaingTerm" : '+interestRate+','+
                                '"actualRepaymentAmountExistingDebt" : "'+(liabilities[i].Monthly_Repayment__c != null ? liabilities[i].Monthly_Repayment__c : 0.00)+'",'+
                                '"loanForRepayLoan" : "No",';
                            
                            if(liabilities[i].FinServ__Ownership__c == 'Joint'){
                                body += '"ownerSumCreditCard" : "'+ownershipShare+'",';
                            }else{
                                body += '"ownerSumCreditCard" : "'+liabilities[i].Ownership_Share__c+'",';    
                            }
                             body +='"ownershipDet_CC" : [';
									
                             if(liabilities[i].FinServ__Ownership__c == 'Applicant 1' || liabilities[i].FinServ__Ownership__c == 'Applicant 2'){
                                 body += 
                                     '{'+
                                     '"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' +liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
                                     '"ownerNameOther" : "",'+
                                     '"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'"'+
                                     '}';
                             } 
                             if(liabilities[i].FinServ__Ownership__c == 'Joint'){
                                 body += 
                                     '{'+
                                     '"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' +liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
                                     '"ownerNameOther" : "",'+
                                     '"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'"'+
                                     '},'+
                                     '{'+
                                     '"owner" : "'+liabilities[i].FinServ__JointOwner__r.FirstName + ' ' +liabilities[i].FinServ__JointOwner__r.LastName+'",'+
                                     '"ownerNameOther" : "",'+
                                     '"ownershipPercentDebt" : "'+liabilities[i].Other_Ownership_Share__c+'"'+
                                     '}';
                             }
                             if(liabilities[i].FinServ__Ownership__c == 'Joint (non-applicant)'){
                                 body += 
                                     '{'+
                                     '"owner" : "'+liabilities[i].FinServ__PrimaryOwner__r.FirstName + ' ' +liabilities[i].FinServ__PrimaryOwner__r.LastName+'",'+
                                     '"ownerNameOther" : "",'+
                                     '"ownershipPercentDebt" : "'+liabilities[i].Ownership_Share__c+'"'+
                                     '},'+
                                     '{'+
                                     '"owner" : "Others",'+
                                     '"ownerNameOther" : "Other Non Spouse",'+
                                     '"ownershipPercentDebt" : "'+Integer.valueOf(liabilities[i].Other_Ownership_Share__c)+'"'+
                                     '}';
                             }
                             body +=  '],'+
                             
                            	'"ownerCheckCredit" : "1",'+
                                '"creditLimitRemaingTerm" : '+liabilities[i].Limit__c+','+
                                '"_entryId" : "'+randomNumber+'",'+
                                '"_type" : "Credit Cards/Store Cards/BNPL"'+
                                '}';
                            if(i != liabilities.size()-1)
                                body += ',';
                        }
                    }
                    System.debug('body +++++'+body);
                }
            }
            else{
                return '';
            }
        }
        body = body.removeEnd(',');
        return body;
    }
    
    
    public static String coApplicant(contact con1, Contact contact, EmploymentStatus empStatus,EmploymentStatus empSecStatus, EmploymentStatus applicant2Income){
        Integer Zero = 0;
        String NA = 'N/A';
        String Monthly = 'Monthly';
        String d = '';
        String mo = '';
        Integer yr = 0;
        string dt;
        
        if(contact.Birthdate != null){
            system.debug('birthdate+++++++'+contact.Birthdate);
            d = (contact.Birthdate.day() < 10) ? '0' + String.valueOf(contact.Birthdate.day()) : String.valueOf(contact.Birthdate.day());
            System.debug('dd--'+d);
            mo = (contact.Birthdate.month() < 10) ? '0' + String.valueOf(contact.Birthdate.month()) : String.valueOf(contact.Birthdate.month()) ;
            System.debug('mo--'+mo);
            yr = contact.Birthdate.year();
            System.debug('yr--'+yr);
            dt = d + '/' + mo + '/' + yr;
            System.debug('dt--'+dt);
        }
        else{
            dt = '12' + '/' + '02' + '/' + '2000';
        }
        
        Decimal months = 0;
        date newDate;
        String empCommenced = '';
        if(empStatus.emp != null){
            months = (empStatus.emp.Years__c != null ? empStatus.emp.Years__c * 12 : 0) + (empStatus.emp.Months__c!= null ? empStatus.emp.Months__c : 0);
            newDate = System.today().addMonths(-(Integer)months);
            String dat = (newDate.day() < 10) ? '0' + String.valueOf(newDate.day()) : String.valueOf(newDate.day());
            String mon = (newDate.month() < 10) ? '0' + String.valueOf(newDate.month()) : String.valueOf(newDate.month());
            yr = newDate.year();
            empCommenced =  + dat + '/'+ mon + '/' + yr;
            System.debug('date commeneced+++'+empCommenced);
        }
        
        
        String endDate;
        Date endDt;
        if(empStatus.emp.years__c < 3){
            endDt  = newDate.addDays(-1);
            String dat = (endDt.day() < 10) ? '0' + String.valueOf(endDt.day()) : String.valueOf(endDt.day());
            String mon = (endDt.month() < 10) ? '0' + String.valueOf(endDt.month()) : String.valueOf(endDt.month());
            yr = endDt.year();
            endDate = dat + '/' + mon + '/' + yr;
            System.debug('endDateendDate'+endDate);
        }
        else{
            endDate = '12' + '/' + '02' + '/' + '2000';
        }
        
        Date preDt;
        String empPreCommenced;
        if(empStatus.emp.years__c < 3){
            months = (empStatus.emp.Years_1_Previous__c != null ? empStatus.emp.Years_1_Previous__c * 12 : 0)  + (empStatus.emp.Months_1_Previous__c != null ? empStatus.emp.Months_1_Previous__c : 0);
            preDt  = endDt.addMonths(-(Integer)months);
            System.debug('PreDate+_+'+preDt);
            String dat = (preDt.day() < 10) ? '0' + String.valueOf(preDt.day()) : String.valueOf(preDt.day());
            String mon = (preDt.month() < 10) ? '0' + String.valueOf(preDt.month()) : String.valueOf(preDt.month());
            yr = preDt.year();
            empPreCommenced =  + dat + '/'+ mon + '/' + yr;
            System.debug('empPreCommenced++++'+empPreCommenced);
        }
        else{
            empPreCommenced = '12' + '/' + '02' + '/' + '2000';
        }
        
        
        String gender = contact.FinServ__Gender__c == 'Male'? 'M' : 'F';
        Decimal loanYear = selectedQuote.Loan_Term__c/12;
        
        string body = 
            '		"coApplicant": [{'+
            '"tmcuCheck": true,'+
            '			"bankruptDeclared": "No",'+
            '			"nonPaymentDebtCourtOrder": "No",'+
            '			"reliefBankruptcyAct": "No",';
        
        if(oppContacts.opp.Number_of_applicants__c != 0){
            if(Integer.valueOf(oppContacts.opp.Number_of_applicants__c) == 1){
                body +='"coappCount": "Single Applicant",';
            }else{
                body +='"coappCount": "1",';//Joint Applicant
            }
        }
        if(contact.title != null){
            body += '"title": "'+contact.title+'.",';
        }else{
            body += '"title": "Mr.",';
        }
        body+= 
            '			"firstName": "'+(contact.FirstName != null ? contact.FirstName : '')+'",'+
            '			"middleName": "'+(contact.MiddleName != null ? contact.MiddleName : '')+'",'+
            '			"lastName": "'+(contact.LastName != null ? contact.LastName : '')+'",'+
            '			"gender": "'+gender+'",'+
            '			"dob": "'+dt+'",'+
            '			"emailone": "'+contact.Email+'",';
        if(contact.Phone != null){
            String Phone = contact.Phone;
            if(Phone.startswith('+61')){
                Phone = Phone.replace('+61', '0');
            }
            Phone = Phone.deleteWhitespace();
            body+='"mobile": "'+Phone+'",';
        }
        else{
            body+='"mobile": "'+NA+'",';
        } 
        body += '			"radio_609konWRi": "No",'+
            '"securityQuestion": "What is the name of the street you grew up on?",'+
            '"securityAnswer": "not answered by customer",';
       
        if(contact.FinServ__MaritalStatus__c != null){
            if(contact.FinServ__MaritalStatus__c == 'Married / defacto' || contact.FinServ__MaritalStatus__c == 'Married / Defacto (to applicant 2)' || contact.FinServ__MaritalStatus__c == 'Married / Defacto (to applicant 1)' || contact.FinServ__MaritalStatus__c == 'Married / defacto (non-applicant)'){
                body += '"maritalStatus": "Married",';
            }else{
                body += 
                    '"maritalStatus": "'+contact.FinServ__MaritalStatus__c+'",';
            }
        }
        else{
            body += 
                '"maritalStatus": "Single",';
        }
        
        
        body+=
            '"numberOfDependents": "'+Zero+'",'+
            '"declarationOne": "true",'+
            '"declarationTwo": "true",'+
            '"declarationThree": "true",';
        
        if(empStatus.emp.FinServ__EmploymentStatus__c == 'Full time permanent' || empStatus.emp.FinServ__EmploymentStatus__c == 'Casual / Temporary' || empStatus.emp.FinServ__EmploymentStatus__c == 'Part time permanent'){
            String occ = (contact.FinServ__Occupation__c != null ? contact.FinServ__Occupation__c : '') + ' at ' + (contact.Account.Industry != null ? contact.Account.Industry : '') +' : '+ (contact.Primary_Employer_Job_Title__c != null ? contact.Primary_Employer_Job_Title__c : ''); 
            body += 
                '"currentPayg": "Yes",'
                +'"occupation": "'+occ+'",'
                +'"employmentStatus": "'+empSecStatusMap(empStatus.emp)+'",'
                +'"employerName": "'+empStatus.emp.Name+'",'
                +'"employerAddress": "'+empStatus.emp.FinServ__EmployerAddress__c+'",'
                +'"dateCommencedCurrent": "'+empCommenced+'",';
        }
        else{
            body += 
                '"currentPayg": "No",'
                +'"occupation": "'+NA+'",'
                +'"employmentStatus": "'+NA+'",'
                +'"employerName": "'+NA+'",'
                +'"employerAddress": "'+NA+'",'
                +'"dateCommencedCurrent": "'+NA+'",';
        }
        if(empStatus.emp.Years__c <3){
            body+= '"previousEmploymentQuestion" : "Yes",'+
                '"previousEmployer" : "'+empStatus.emp.Employer_Name_1_Previous__c+'",'+
                '"dateCommenced" : "'+empPreCommenced+'",'+
                '"dateFinished": "'+endDate+'",';
        }else{
            body+= '"previousEmploymentQuestion" : "No",'+
                '"previousEmployer" : "",'+
                '"dateCommenced" : "",'+
                '"dateFinished": "",';
        }
        
        
        
        if(empSecStatus.emp != null && (empStatus.emp.FinServ__EmploymentStatus__c == 'Full time permanent' || empStatus.emp.FinServ__EmploymentStatus__c == 'Casual / Temporary' || empStatus.emp.FinServ__EmploymentStatus__c == 'Part time permanent')){
            body +=
                '"secondJobCheck": "Yes",'+
                '			"secOccupation": "'+empSecStatus.emp.FinServ__Occupation__c+'",'+
                '          "secEmpStatus": "'+empSecStatusMap(empSecStatus.emp)+'",'+
                '			"secEmpName": "'+empSecStatus.emp.Name+'",'+//
                '			"secEmpAddress": "'+empSecStatus.emp.FinServ__EmployerAddress__c+'",';     
        }else{
            body +=
                '			"secondJobCheck": "No",'+
                '			"secOccupation": "",'+
                '			"secEmpStatus": "",'+
                '			"secEmpName": "",'+
                '			"secEmpAddress": "",';
        }
        
        Boolean selfjob = false;
        if(employmentData.get('applicant2').FinServ__Employment__r != null && employmentData.get('applicant2').FinServ__Employment__r.size() > 0){
            for(FinServ__Employment__c emp : employmentData.get('applicant2').FinServ__Employment__r){
                if(emp.FinServ__EmploymentStatus__c == 'Self Employed / Contractor'){
                    body += 
                        '"selfJobCheck": "Yes",'
                        +'"selfNatureBusiness": "'+emp.Self_Employed_Type__c+'",'
                        +'"selfEmpName": "'+emp.Job_Title__c+'",'
                        +'"selfEmpAddress": "'+emp.FinServ__EmployerAddress__c+'",';
                    selfjob = true;
                }
                
            }
        }
       if(empStatus.emp.FinServ__EmploymentStatus__c == 'Self Employed / Contractor'){
            body += 
                '"selfJobCheck": "Yes",'
                +'"selfNatureBusiness": "'+empStatus.emp.Self_Employed_Type__c+'",'
                +'"selfEmpName": "'+empStatus.emp.Job_Title__c+'",'
                +'"selfEmpAddress": "'+empStatus.emp.FinServ__EmployerAddress__c+'",';
           selfjob = true;
        }
        if(!selfjob){
            body += 
                '"selfJobCheck": "No",'
                +'"selfNatureBusiness": "",'
                +'"selfEmpName": "",'
                +'"selfEmpAddress": "",';
        }
        String Street = (contact.Street__c != null ? contact.Street__c : '');
        String suburb = (contact.Suburb__c != null ? contact.Suburb__c : '');
        String state = (contact.State__c != null ? contact.State__c : '');
        String unitNo = (contact.Unit_Number__c != null ? contact.Unit_Number__c : '');
        String streetNo = (contact.Street_Number__c != null ? contact.Street_Number__c : '');
        String postCode = (contact.Postal_Code__c != null ? contact.Postal_Code__c : '');
        body+=
            '			"residencyStatus": "'+citizeShip(contact)+'",'+
            '			"typeOfResidency": "'+livingSituation(contact)+'",'+
            '			"currentAddress": "'+contact.Residential_Address__c+'",'+
            
            '			"streetName": "'+Street+'",'+
            '			"suburb": "'+suburb+'",'+	
            '			"state": "'+state+'",'+
            '			"postCode": "'+postCode+'",'+	
            '			"unitNoResi": "'+unitNo+'",'+ 
            '			"streetNoResi": "'+streetNo+'",';
        
        if(contact.Dont_have_drivers_licence__c != true){
            body +='"idForm": "Driver\'s Licence",'+
                '"idCheck": "Yes",'+
                '"stateDL": "'+DriverState(contact)+'",'+
                '"drivingFname": "'+contact.FirstName+'",'+
                '"drivingMiddleName": "'+contact.MiddleName+'",'+
                '"drivingLastName": "'+contact.LastName+'",'+
                '"drivingDob": "'+contact.Birthdate+'",'+
                '"driverLicence": "'+contact.Govt_Id_Number__c+'",'+
                '"agreeDL": "true",';
        }
        else{
            body +='"idForm": "",'+
                '"idCheck": "No",'+
                '"stateDL": "",'+
                '"drivingFname": "",'+
                '"drivingMiddleName": "",'+
                '"drivingLastName": "",'+
                '"drivingDob": "",'+
                '"driverLicence": "",'+
                '"agreeDL": "",';
        }
        
        body += '"drivingCardNumber" : "'+(contact.ID_Card_Number__c != null ? contact.ID_Card_Number__c : '')+'",';
        
        if(contact.Year__c != null){
            if(Integer.valueOf(contact.Year__c) >= 3){
                body += 
                    '"longLived": "More than three years",'
                    +'"priorResiAddress": "'+contact.Residential_Address__c+'",';
            }
            else if(Integer.valueOf(contact.Year__c) < 3){
                body += 
                    '"longLived": "Less than three years",'
                    +'"priorResiAddress": "'+contact.Residential_Address_1__c+'",';
            }
        }else{
            body += 
                '"longLived": "",'
                +'"priorResiAddress": "",';
        }
        boolean t = true;
        boolean f = false;
        if(contact.isFindPostalAdd__c == false){
            body += 
                '"postalSame": true,'
                +'"postalAddress": "'+contact.Residential_Address__c+'",';    
        }
        if(contact.isFindPostalAdd__c == true){
            body += 
                '"postalSame": false,'
                +'"postalAddress": "'+contact.Postal_Address__c+'",';
        }	
        body+= 
            '"loanAmount": "'+math.ceil(selectedQuote.Total_loan_amount__c)+'",';
        
		/*Loan Purpose*/
        if(selectedQuote.Interest_Rate__c == 1.99){
            body+= 
            '"loanPurpose": "Solar via Parker Lane under 10K",';
        }
        if(selectedQuote.Interest_Rate__c == 2.99){
            body+= 
            '"loanPurpose": "Solar via Parker Lane over 10K",';
        }
        /*Loan Purpose*/
        
        if(selectedQuote.Loan_Term__c != 0.00){
            body += '"loanTenureInYears": "'+loanYear+'",';            
        }else{
            body += '"loanTenureInYears": "'+NA+'",';
        }
        if(oppContacts.opp.Preferred_repayment_frequency__c != null){
            body += 
                '"repaymentFrequency": "'+oppContacts.opp.Preferred_repayment_frequency__c+'",';  
        }else{
            body += 
                '"repaymentFrequency": "'+Monthly+'",'; 
        }
        if(!string.isBlank(oppContacts.opp.Preferred_repayment_frequency__c)){
            if(oppContacts.opp.Preferred_repayment_frequency__c == 'Monthly'){
                if(selectedQuote.Monthly_Repayments__c != null){
                    body += '"repaymentAmount": "'+selectedQuote.Monthly_Repayments__c+'",'; 
                }
                else{
                    body += '"repaymentAmount": "'+NA+'",';
                }
            }
            if(oppContacts.opp.Preferred_repayment_frequency__c == 'Weekly'){
                if(selectedQuote.Monthly_Repayments__c != null){
                    body += '"repaymentAmount": "'+selectedQuote.Weekly_Repayments__c+'",'; 
                }
                else{
                    body += '"repaymentAmount": "'+NA+'",';
                }
            }
            if(oppContacts.opp.Preferred_repayment_frequency__c == 'Fortnightly'){
                if(selectedQuote.Monthly_Repayments__c != null){
                    body += '"repaymentAmount": "'+selectedQuote.Fortnightly_Repayments__c+'",'; 
                }
                else{
                    body += '"repaymentAmount": "'+NA+'",';
                }
            }
        }
        else{
            body += '"repaymentAmount": "'+selectedQuote.Monthly_Repayments__c+'",';
        }
          
       
        
        body += 
            '"groceries": "'+zero+'",'+
            '"groceryFrequency": "'+Monthly+'",'+
            '"education": "'+zero+'",'+
            '"educationFrequency": "'+Monthly+'",'+
            '"spending": "'+zero+'",'+
            '"spendingFrequency": "'+Monthly+'",'+
            '"otherGeneralExpense": "'+zero+'",'+
            '"otherFrequency": "'+Monthly+'",';
        
            body +=
                '"VehicleExpenseQuestion": false,'+
                '"vehicle": "",'+
                '"vehicleFrequency": "",'+
                '"petrol": "",'+
                '"petrolFrequency": "",'+
                '"registration": "",'+
                '"registrationFrequency": "",'+
                '"otherVehicle": "",'+
                '"otherVehicleFrequency": "",'+	
            	'"insuranceExpenseQuestion": false,'+
                '"insurance": "",'+
                '"insuranceFrequency": "",'+
                '"carInsurance": "",'+
                '"carInsuranceFrequency": "",'+
                '"houseInsurance": "",'+
                '"houseInsuranceFrequency": "",'+
                '"lifeInsurance": "",'+
                '"lifeInsuranceFrequency": "'+Monthly+'",'+
                '"insuranceHealth": "",'+
                '"healthInsuranceFrequency": "",'+
                '"otherInsuranecExpenses": "",'+
                '"otherInsuranceFrequency": "",'+
        
        
        		'"ratesAndUtilitiesExpenses": false,'+
                '"gas": "",'+
                '"gasFrequency": "",'+
                '"phone": "",'+
                '"phoneFrequency": "",'+
                '"power": "",'+
                '"powerFrequency": "",'+
                '"internet": "",'+
                '"internetFrequency": "",'+
                '"rates": "",'+
                '"ratesFrequency": "",'+
                '"water": "",'+
                '"waterFrequency": "",'+
                '"otherRatesAndUtilities": "",'+
                '"otherRateUtilitiesFrequency": "",'+ 
               	'"childMaintain": "",'
                +'"childCommitFreq": "",'+ 
                '"childSpouseMaintain": "",'+
                '"childSpouseCommitFreq": "",'+
                '"otherCommitments": "",'
                +'"otherCommitFreq": "",'+
            
                '"rentAndOtherLoanRepayments": "false",'
                +'"rent": "",'
                +'"rentCommitFreq": "",'
                +'"board": "",'
                +'"boardCommitFreq": "",'
                +'"totalOtherCommitments": 0,'
            	+'"monthlyExpenses": "",';
        
        if(assets.size() > 0){
            body +=  '"checkboxAssets":  false,';
        }
        else{
            body +=  '"checkboxAssets":  true,';
        }
        if(liabilities.size() > 0){
            body +='"checkbox_M-B1GyKiL": false,';      
        }
        else{
            body +='"checkbox_M-B1GyKiL": true,';
        }
        body +=
            '			"finalConsent": true,'+
            '			"interestType": "Variable",';
        
        if(applicant2Income.emplist != null){
            if(applicant2Income.emplist.size() > 0){
                for(Integer i=0; i<applicant2Income.emplist.size(); i++){
                    if(applicant2Income.emplist[i].Source_Document__c == 'Mogo' || applicant2Income.emplist[i].Source_Document__c == 'Bank Statements'){
                        body +='			"basiqForExpense": "Yes",';
                        break;
                    }
                    else{
                        body +='			"basiqForExpense": "No",';
                    }
                }
            }
        }
        body += 
            '			"incomeDetails": ['+incomeForApplicantTwo(applicant2Income, contact)+'],'+
            
            '			"accordion_ir2jdL3Q2": [{'+
            '				"fiName": "'+NA+'",'+
            '				"acntNumber": "'+NA+'",'+
            '				"estValue": "'+NA+'",'+
            '				"ownershipSaving": [{'+
            '					"owner": "'+NA+'",'+
            '					"ownershipPercentDebt": "'+NA+'"'+
            '				}]'+
            '			}],'+
            '			"accordionAssetOwnershipDetails": [],'+
            '			"accordionSuperannuation": [{'+
            '				"superAnnIns": "'+NA+'",'+
            '				"memNum": "'+NA+'",'+
            '				"estValueSup": "'+NA+'",'+
            '				"ownerSuperAnn": [{'+
            '					"owner": "'+NA+'",'+
            '					"ownershipPercentDebt": "'+NA+'"'+
            '				}]'+
            '			}],'+
            '			"accordionRealEstate": [{'+
            '				"rentalAddress": "'+NA+'",'+
            '				"soldCheck": "'+NA+'",'+
            '				"propValueAsset": "'+NA+'",'+
            '				"ownershipP": [{'+
            '					"owner": "'+NA+'",'+
            '					"ownershipPercentDebt": "'+NA+'"'+
            '				}]'+
            '			}],'+
            '			"accordionOtherAssets": [{'+
            '				"otherAsset": "'+NA+'",'+
            '				"valueOtherAsse": "'+NA+'",'+
            '				"ownerOtherAsset": [{'+
            '					"owner": "'+NA+'",'+
            '					"ownershipPercentDebt": "'+NA+'"'+
            '				}]'+
            '			}],'+
            '			"liabilityDetails": [{'+
            '				"financialInstitution": "tmcu",'+
            '				"outstandingBalanceRemaingTerm": "'+NA+'",'+
            '				"availableForRedrawAmountRemaingTerm": "'+NA+'",'+
            '				"durationRemaingTerm": "'+NA+'",'+
            '				"interestRateLiability": "'+NA+'",'+
            '				"repaymentFrequencyContRepmt": "'+Monthly+'",'+
            '				"actualRepaymentAmountExistingDebt": "'+NA+'",'+
            '				"paymentType": "Principal+Interest",'+
            '				"taxDeductible": "No",'+
            '				"loanForRepayLoan": "No",'+
            '				"OwnershipMor": [{'+
            '						"owner": "'+NA+'",'+
            '						"ownershipPercentDebt": "'+NA+'"'+
            '					},'+
            '					{'+
            '						"owner": "'+NA+'",'+
            '						"ownershipPercentDebt": "'+NA+'"'+
            '					}'+
            '				]'+
            '			}]'+
            '		}]';
        
        return body;
    } 
    
    public static String incomeForApplicantTwo(EmploymentStatus applicant, contact con){
        string body = '';
        if(applicant.emplist != null){
            if(applicant.emplist.size() > 0){
                for(Integer i=0; i<applicant.emplist.size(); i++){
                    if((applicant.emplist[i].FinServ__EmploymentStatus__c == 'Full time permanent' || applicant.emplist[i].FinServ__EmploymentStatus__c == 'Part time permanent' || applicant.emplist[i].FinServ__EmploymentStatus__c == 'Casual / Temporary') && (applicant.emplist[i].Source_Document__c == 'Mogo' || applicant.emplist[i].Source_Document__c == 'Bank Statements') && applicant.emplist[i].Verified_Income_Amount__c > 0 ){
                        body += '{'+
                            '				"borrowerName": "'+con.FirstName+'",'+
                            '				"basiqSource": "regular",'+
                            '				"basiqShading": "1",'+
                            '				"amount": "'+applicant.emplist[i].Verified_Income_Amount__c+'",'+
                            '				"frequency": "'+(applicant.emplist[i].Verified_Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Verified_Income_Frequency__c)+'",'+
                            '				"monthlyIncome": "'+applicant.emplist[i].Monthly_Verified_Income_Calculation__c+'"'+
                            '			}';
                        if(i != applicant.emplist.size()-1)
                        {
                            body += ',';
                        }
                        else
                        {
                            body += ',';
                        }
                    }
                    else{
                        if(applicant.emplist[i].FinServ__EmploymentStatus__c == 'Full time permanent' || applicant.emplist[i].FinServ__EmploymentStatus__c == 'Part time permanent' || applicant.emplist[i].FinServ__EmploymentStatus__c == 'Casual / Temporary'){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Salary",'+
                                '				"amount": "'+applicant.emplist[i].Income_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Income_Frequency__c)+'",'+
                                '				"monthlyIncome": "'+applicant.emplist[i].monthly_Income__c+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1)
                            {
                                body += ',';
                            }
                            else
                            {
                                body += ',';
                            }
                        }
                        
                        if(applicant.emplist[i].FinServ__EmploymentStatus__c == 'New Start Allowance'){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Unemployment Benefits",'+
                                '				"amount": "'+applicant.emplist[i].Income_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Income_Frequency__c)+'",'+
                                '				"monthlyIncome": "'+applicant.emplist[i].monthly_Income__c+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1)
                                body += ',';
}
                        
                        if(applicant.emplist[i].FinServ__EmploymentStatus__c == 'Pension'){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Government Benefits Age Pension",'+
                                '				"amount": "'+applicant.emplist[i].Income_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Income_Frequency__c)+'",'+
                                '				"monthlyIncome": "'+applicant.emplist[i].monthly_Income__c+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1)
                                body += ',';
}
                        
                        if(applicant.emplist[i].FinServ__EmploymentStatus__c == 'Rental Income'){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Rental Income - Residential",'+
                                '				"amount": "'+applicant.emplist[i].Income_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Income_Frequency__c)+'",'+
                                '				"monthlyIncome": "'+applicant.emplist[i].monthly_Income__c+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1)
                                body += ',';
}
                        
                        if(applicant.emplist[i].FinServ__EmploymentStatus__c == 'Dividends or Annuity'){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Dividend Income",'+
                                '				"amount": "'+applicant.emplist[i].Income_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Income_Frequency__c)+'",'+
                                '				"monthlyIncome": "'+applicant.emplist[i].monthly_Income__c+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1)
                                body += ',';
}
                        
                        if(applicant.emplist[i].FinServ__EmploymentStatus__c == 'Family Tax Benefits'){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Government Benefits Family Allowance",'+
                                '				"amount": "'+applicant.emplist[i].Income_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Income_Frequency__c)+'",'+
                                '				"monthlyIncome": "'+applicant.emplist[i].monthly_Income__c+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1)
                                body += ',';
}
                        
                        if(applicant.emplist[i].FinServ__EmploymentStatus__c == 'Disability Pension'){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Government Benefits Disability Support Pension",'+
                                '				"amount": "'+applicant.emplist[i].Income_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Income_Frequency__c)+'",'+
                                '				"monthlyIncome": "'+applicant.emplist[i].monthly_Income__c+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1)
                                body += ',';
}
                        
                        if(applicant.emplist[i].FinServ__EmploymentStatus__c == 'Carer’s Pension'){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Government Benefits Carer Payment",'+
                                '				"amount": "'+applicant.emplist[i].Income_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Income_Frequency__c)+'",'+
                                '				"monthlyIncome": "'+applicant.emplist[i].monthly_Income__c+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1)
                                body += ',';
}
                        
                        if(applicant.emplist[i].FinServ__EmploymentStatus__c == 'Workcover Workers / Compensation'){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Workers Compensation",'+
                                '				"amount": "'+applicant.emplist[i].Income_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Income_Frequency__c)+'",'+
                                '				"monthlyIncome": "'+applicant.emplist[i].monthly_Income__c+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1)
                                body += ',';
}
                        
                        if(applicant.emplist[i].FinServ__EmploymentStatus__c == 'Other'){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Other Income",'+
                                '				"amount": "'+applicant.emplist[i].Income_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Income_Frequency__c)+'",'+
                                '				"monthlyIncome": "'+applicant.emplist[i].monthly_Income__c+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1)
                                body += ',';
}
                        
                        if(applicant.emplist[i].FinServ__EmploymentStatus__c == 'Child Support'){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Child Maintenance",'+
                                '				"amount": "'+applicant.emplist[i].Income_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Income_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Income_Frequency__c)+'",'+
                                '				"monthlyIncome": "'+applicant.emplist[i].monthly_Income__c+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1)
                                body += ',';
}
                        
                        
                        /*-------------------*/
                        
                        if(applicant.emplist[i].Work_Overtime_amount__c > 0){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Gross Regular Overtime",'+
                                '				"amount": "'+applicant.emplist[i].Work_Overtime_amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Work_Overtime_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Work_Overtime_Frequency__c)+'",';
                            if(applicant.emplist[i].Work_Overtime_Frequency__c == 'Annually'){
                                Decimal amt = applicant.emplist[i].Work_Overtime_amount__c/12;
                                body += '"monthlyIncome": "'+amt+'"';                  
                            }
                            else{
                                body += '"monthlyIncome": "'+applicant.emplist[i].Work_Overtime_amount__c+'"';
                            }
                            body +=
                                '			}';
                            
                            if(i != applicant.emplist.size()-1)
                            {
                                body += ',';
                            }
                            else
                            {
                                body += ',';
                            }
                            
}
                        
                        if(applicant.emplist[i].Commission_or_Bonus_amount__c > 0){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Commission",'+
                                '				"amount": "'+applicant.emplist[i].Commission_or_Bonus_amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Commission_or_Bonus_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Commission_or_Bonus_Frequency__c)+'",';
                            if(applicant.emplist[i].Commission_or_Bonus_Frequency__c == 'Annually'){
                                Decimal amt = applicant.emplist[i].Commission_or_Bonus_amount__c/12;
                                body += '"monthlyIncome": "'+amt+'"';                  
                            }
                            else{
                                body += '"monthlyIncome": "'+applicant.emplist[i].Commission_or_Bonus_amount__c+'"';
                            }
                            body +=
                                '			}';
                            
                            if(i != applicant.emplist.size()-1)
                            {
                                body += ',';
                            }
                            else
                            {
                                body += ',';
                            }
                            
}
                        
                        if(applicant.emplist[i].Allowance_Amount__c > 0){
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Permanent Allowance",'+
                                '				"amount": "'+applicant.emplist[i].Allowance_Amount__c+'",'+
                                '				"frequency": "'+(applicant.emplist[i].Allowance_Frequency__c == 'Annually' ? 'Yearly' : applicant.emplist[i].Allowance_Frequency__c)+'",';
                            if(applicant.emplist[i].Allowance_Frequency__c == 'Annually'){
                                Decimal amt = applicant.emplist[i].Allowance_Amount__c/12;
                                body +='"monthlyIncome": "'+amt+'"';
                            }
                            else{
                                body +='"monthlyIncome": "'+applicant.emplist[i].Allowance_Amount__c+'"';
                            }
                            
                            body +='}';
                            if(i != applicant.emplist.size()-1)
                            {
                                body += ',';
                            }	
                            else{
                                body += ',';
                            }
                            
}
                        
                        if(applicant.emplist[i].Last_year_net_profit__c > 0){
                            Decimal amt = applicant.emplist[i].Last_year_net_profit__c /12;
                            body += '{'+
                                '				"borrowerName": "'+con.FirstName+'",'+
                                '				"basiqSource": "Self Employed Income",'+
                                '				"amount": "'+applicant.emplist[i].Last_year_net_profit__c+'",'+
                                '				"frequency": "Yearly",'+	
                                '				"monthlyIncome": "'+amt+'"'+
                                '			}';
                            if(i != applicant.emplist.size()-1){
                                body += ',';
                            }
                            else{
                                body += ',';   
                            }
}
                    }
                }
            }
        }
        
        body = body.removeEnd(',');
        return body;
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
    
    public static string citizeShip(contact cont){
        string value = '';
        if(cont.Citizenship_Status__c == 'Australian Citizen'){
            value = 'Australian Citizen';
        }
        else if(cont.Citizenship_Status__c == 'Permanent Resident'){
            value = 'Permanent Resident';
        }
        else if(cont.Citizenship_Status__c == 'NZ Citizen'){
            value = 'New Zealand Citizen';
        }
        else if(cont.Citizenship_Status__c == 'Other'){
            value = 'Other Visa';
        }
        else{
            value = '';
        }
        
        return value;
    }
    
    public static Map<String, Contact> incomeForZEAL(Id recordId){
        Opportunity opp = [SELECT Applicant_1__c, Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                           FROM Opportunity WHERE Id =: recordId limit 1];
        Set<Id> conIds = new Set<Id>();
        if(opp.Applicant_1__c != null){
            conIds.add(opp.Applicant_1__r.PersonContactId);
        }
        if(opp.Applicant_2__c != null){
            conIds.add(opp.Applicant_2__r.PersonContactId);
        }
        Map<Id, Contact> conEmploymentMap = new Map<Id, Contact>([SELECT Id,Name,
                                                                  (SELECT Id, Name,FinServ__Occupation__c,Annual_Verified_Income_Calculation__c,Monthly_Verified_Income_Calculation__c,Verified_Income_Amount__c,Verified_Income_Frequency__c,Source_Document__c,monthly_Income__c,Income_Frequency__c, FinServ__EmployerAddress__c,Income_Amount__c,FinServ__EmploymentStatus__c,Work_Overtime_amount__c,Commission_or_Bonus_amount__c,Work_Overtime_Frequency__c,Allowance_Amount__c,Allowance_Frequency__c,Commission_or_Bonus_Frequency__c,Last_year_net_profit__c,Is_Primary__c  FROM FinServ__Employment__r)
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
    
    
    
    public static Map<String, Contact> fetchEmployees(Id recordId){
        Opportunity opp = [SELECT Applicant_1__c, Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                           FROM Opportunity WHERE Id =: recordId limit 1];
        Set<Id> conIds = new Set<Id>();
        if(opp.Applicant_1__c != null){
            conIds.add(opp.Applicant_1__r.PersonContactId);
        }
        if(opp.Applicant_2__c != null){
            conIds.add(opp.Applicant_2__r.PersonContactId);
        }
        Map<Id, Contact> conEmploymentMap = new Map<Id, Contact>([SELECT Id,Name,
                                                                  (SELECT Id, Name,FinServ__Occupation__c, FinServ__EmployerAddress__c,Job_Title__c,Self_Employed_Type__c ,FinServ__EmploymentStatus__c,Is_Primary__c  FROM FinServ__Employment__r WHERE Is_Primary__c = false)
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
        Map<Id, Contact> conEmploymentMap =new Map<Id, Contact>([SELECT Name, FinServ__CurrentEmployer__c,FinServ__Occupation__c, FinServ__MaritalStatus__c, Email,
                                                                 (SELECT Id, Name, FinServ__AnnualIncome__c, FinServ__EmployerAddress__c,
                                                                  FinServ__EmployerPhoneNumber__c,Income_Amount__c, FinServ__EmploymentStatus__c, Income_Frequency__c, Months__c,
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
                                                                  Address_2_Previous__c,FinServ__EndDate__c, Regularly_work_Overtime__c, Work_Overtime_amount__c, Work_Overtime_Frequency__c, 
                                                                  Regularly_receive_Commission_or_Bonus__c, Commission_or_Bonus_amount__c, Commission_or_Bonus_Frequency__c,
                                                                  Regularly_Receive_Allowance__c, Allowance_Amount__c, Allowance_Frequency__c, Provide_a_Company_Car__c,Job_Title__c,Annual_Verified_Income_Calculation__c,Monthly_Verified_Income_Calculation__c,Verified_Income_Amount__c,Verified_Income_Frequency__c,Source_Document__c
                                                                  FROM FinServ__Employment__r WHERE Is_Primary__c = true LIMIT 1)
                                                                 FROM Contact WHERE Id in :conIds]);
        
        Map<String, Contact> conMap = new Map<String, Contact>();
        if(opp.Applicant_1__c != null){
            conMap.put('applicant1', conEmploymentMap.get(opp.Applicant_1__r.PersonContactId));
        }
        if(opp.Applicant_2__c != null){
            conMap.put('applicant2', conEmploymentMap.get(opp.Applicant_2__r.PersonContactId));
        }
        //System.debug('---applicant1---'+conMap.get('applicant1').FinServ__Employment__r);
        //System.debug('---applicant2---'+conMap.get('applicant2').FinServ__Employment__r);
        
        return conMap;
    }
    
    public static Map<String, List<FinServ__AssetsAndLiabilities__c>> fetchAssetsAndLiabilities(Id recordId){
        Opportunity oppt = [SELECT Applicant_1__c,Applicant_2__c FROM Opportunity WHERE Id =: recordId LIMIT 1];
        List<FinServ__AssetsAndLiabilities__c> assetsAndLiabilitiesList = 
            [SELECT FinServ__Amount__c,Monthly_Calculation__c,Name, FinServ__Description__c, RecordType.Name, Limit__c, Monthly_Repayment__c,
             FinServ__Ownership__c, FinServ__AssetsAndLiabilitiesType__c, Address__c, Interest_Rate__c,
             Approximate_Remaining_Term_Years__c, Bank_Type__c, Country__c,FinServ__JointOwner__r.FirstName, FinServ__PrimaryOwner__r.FirstName, FinServ__JointOwner__r.LastName, FinServ__PrimaryOwner__r.LastName,FinServ__PrimaryOwner__r.Name, FinServ__JointOwner__r.Name, Institution__c, Repayment_Type__c,
             Is_Address_Same__c, Is_Find_Address__c, Make_Model__c, Payment_Frequency__c, Postal_Code__c,
             Property_Managed_By__c, Rate_Expires_in_Months__c, Rate_Expires_in_Years__c, Rate_Type__c, Rental_Amount__c,
             Rental_Frequency__c, Repayment_Frequency__c, State__c, Street__c, Street_Number__c, Street_Type__c, Suburb__c,
             Type_of_Fund__c, Type_of_Tenancy__c, Unit_Number__c, Year__c, Post_Payment_Frequency__c, Post_tax_lease_Payment__c,Monthly_Rental_Income_Calculation__c,
             Pre_Payment_Frequency__c,FinServ__PrimaryOwner__c, Pre_tax_lease_Payment__c, Ownership_Share__c, Other_Ownership_Share__c, Value__c, Monthly_Repayment_Calculation__c
             FROM FinServ__AssetsAndLiabilities__c
             WHERE FinServ__PrimaryOwner__c =: oppt.Applicant_1__c OR FinServ__PrimaryOwner__c =: oppt.Applicant_2__c];
        
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
                   Applicant_1__c, Applicant_1__r.PersonContactId,Loan_Term_months__c, Applicant_2__c, Applicant_2__r.PersonContactId,Lead_Source__c,Loan_Amount__c,
                   AccountId, Account.RecordType.Name, FinServ__Household__c, Application_Supporting_Notes__c, Preferred_repayment_frequency__c, Relationship_to_Applicant_2__c,RecordType.Name
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
            
            Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Name,ID_Card_Number__c, Medicare_Reference__c, FirstName, LastName, MiddleName,Does_your_spouse_earn_an_income__c,spouse_s_approximate_annual_income__c, Email, Phone, Title, Birthdate,FinServ__Occupation__c,Account.Industry,Primary_Employer_Job_Title__c, 
                                                                 OtherPhone, FinServ__Gender__c,Rental_or_Board_paid__c, FinServ__MaritalStatus__c, Government_ID__c,
                                                                 Govt_Id_Number__c, Total_Living_Expenses__c,Food_Groceries_Meat_Fruit_Vegetabl__c, Living_Situation__c, FinServ__NumberOfChildren__c,
                                                                 Security_Answer__c, Security_Question__c, Driver_s_licence_state_Territory__c,
                                                                 Dont_have_drivers_licence__c,Education_ChildCare_SchoolFees_Uniform__c, FinServ__PrimaryAddressIsOther__c, isFindPostalAdd__c,
                                                                 Postal_address_is_PO_or_GPO_box__c, Months__c, Months_1__c, Months_2__c, Year__c, 
                                                                 Year_1__c, Year_2__c, Unit_Number__c, Unit_Number_1__c,Maintenance_If_pay_child_maintenance__c, Unit_Number_2__c,
                                                                 Suburb__c, Suburb_1__c, Suburb_2__c, Street_Type__c, Street_Type_1__c, Street_Type_2__c,
                                                                 Street_Number__c, Street_Number_1__c, Street_Number_2__c, Street__c,Other_loans_and_or_debt_commitments__c, Street_1__c, 
                                                                 Street_2__c, State__c, State_1__c, State_2__c, Residential_Address__c, Residential_Address_1__c,
                                                                 Residential_Address_2__c, Postal_Suburb__c, Postal_State__c, Postal_Postal_Code__c, 
                                                                 Postal_PO_Box__c, Postal_Number__c, Postal_Country__c, Postal_Code__c, Postal_Code_1__c, 
                                                                 Postal_Code_2__c, Postal_Box_Type__c, Postal_Address__c,FinServ__AnnualIncome__c, Is_Find_Address__c, Is_Find_Address_1__c, 
                                                                 Is_Find_Address_2__c, Is_Address_Same__c, FinServ__CountryOfResidence__c, Country_1__c, Country_2__c,
                                                                 Rental_Amount__c, Rental_Frequency__c, Rental_Managed_via__c, Citizenship_Status__c, Visa_Details__c,
                                                                 First_Name_Child_1__c, First_Name_Child_2__c, First_Name_Child_3__c, First_Name_Child_4__c, First_Name_Child_5__c,
                                                                 Age_Child_1__c, Age_Child_2__c, Age_Child_3__c, Age_Child_4__c, Age_Child_5__c,Medicare_Card_Colour__c,
                                                                 Medicare_Expiry_Date__c,Medicare_Number__c,Monthly_Rental_Payments__c,Other_Regular_Expenditure__c
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
                System.debug('contact'+con);
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
    
    public static string livingSituation(contact con){
        String living = '';
        if(con.Living_Situation__c == 'Own home outright'){
            living = 'Home owner (no mortgage)';
        }
        if(con.Living_Situation__c == 'Own home with mortgage'){
            living = 'Home owner (with mortgage)';
        }
        if(con.Living_Situation__c == 'Renting'){
            living = 'Renting';
        }
        if(con.Living_Situation__c == 'Boarding with parents'){
            living = 'Living with parent';
        }
        if(con.Living_Situation__c == 'Boarding with other'){
            living = 'Boarding';
        }
        if(con.Living_Situation__c == 'Supplied by employer'){
            living = 'Employer Supplied';
        }
        
        return living;
    }
    
    public static Contact fetchLivingExpensesDetails(Id recordId){
        Opportunity opp = [SELECT Applicant_1__r.PersonContactId FROM Opportunity WHERE Id =: recordId];
        List<Contact> conList = 
            [SELECT FinServ__CurrentEmployer__c,Education_public_and_private__c, FinServ__Occupation__c, Home_Loan_repayment__c, Investment_Property_Loan_repayment__c,
             Credit_Card_payment_3_of_total_limit__c, Other_loans_and_or_debt_commitments__c, Rental_or_Board_paid__c, Utilities__c,
             Connections_Phone_Mobile_Internet_C__c, Education_ChildCare_SchoolFees_Uniform__c, Food_Groceries_Meat_Fruit_Vegetabl__c,
             Transport_Public_Petrol_Registration__c, Medical_Private_Health_Insurance_Ong__c, Insurances_Home_Personal_Voluntary__c,
             Household_Purchases_and_Maintenance__c, Entertainment_Dining_Out_Movies_Gift__c, Sports_Hobbies_and_Memberships__c,
             Gambling_Betting_and_Lottery__c, Other_Regular_Expenditure__c, Total_Living_Expenses__c, Email,Clothing_Recreational_Entertainment__c,
             Insurance_Medical_Health__c,Property_including_Rates_Utilities_Manag__c,CFCU_Other__c,Investment_property_utilities__c,Clothing_and_personal_care__c,Personal_Insurances_life_and_income_pro__c
             FROM Contact 
             WHERE Id =: opp.Applicant_1__r.PersonContactId];
        return conList[0];
    }
    
    public static String empSecStatusMap(FinServ__Employment__c emp){
        String status = '';
        if(emp.FinServ__EmploymentStatus__c == 'Full time permanent'){
            status = 'Permanent Full Time';
        }	
        else if(emp.FinServ__EmploymentStatus__c == 'Part time permanent'){
            status = 'Permanent Part Time';
        }
        else if(emp.FinServ__EmploymentStatus__c == 'Self Employed / Contractor'){
            status = 'Contract';
        }
        else if(emp.FinServ__EmploymentStatus__c == 'Casual / Temporary'){
            status = 'Casual';
        }
        else{
            status = 'Not working';
        }
        
        
        return status;
    }
    
    public static Quote fetchSelectedQuote(Id recordId){
        try{
            Quote qt = [SELECT Id, Customer_Amount__c, Total_loan_amount__c, Monthly_Repayments__c, Loan_Term__c, Monthly_Repayment__c, Purpose__c,Repayment_Frequency_Options__c,  Interest_Rate__c,
                        Lead__c, Lead__r.FirstName, Lead__r.LastName, Lead__r.Email, Shared_Message__c, Weekly_Repayments__c,Fortnightly_Repayments__c,
                        Opportunity.Applicant_1__r.PersonContactId, Product__c, Product__r.Name
                        FROM Quote WHERE OpportunityId =: recordId AND Application__c = true LIMIT 1];
            
            return qt;
        }catch(exception e){
            throw new AuraHandledException(e.getMessage());
            // return null;
        }
    }
    
    public class employmentStatus{
        public Contact con{get;set;}
        public FinServ__Employment__c emp{get;set;}
        public List<FinServ__Employment__c >empList {get;set;}
    }
    
    public class OpportunityContacts{
        public Opportunity opp = new  Opportunity();
        public Contact contact1 = new contact();
        public Contact contact2 = new contact();
        public Integer app1NoChild{get;set;}
        public Integer app2NoChild{get;set;}
        public List<Contact> app1Children = new List<contact>();
        public List<Contact> app2Children = new List<contact>();
        
    }
    
    public static string DriverState(contact con){
        string state = '';
        if(con.Driver_s_licence_state_Territory__c == 'Queensland'){
            state = 'QLD';
        }
        if(con.Driver_s_licence_state_Territory__c == 'New South Wales'){
            state = 'NSW';
        }
        if(con.Driver_s_licence_state_Territory__c == 'Australian Capital Territory'){
            state = 'ACT';
        }
        if(con.Driver_s_licence_state_Territory__c == 'Victoria'){
			state = 'VIC';            
        }
        if(con.Driver_s_licence_state_Territory__c == 'South Australia'){
			state = 'SA';            
        }
        if(con.Driver_s_licence_state_Territory__c == 'Western Australia'){
			state = 'WA';            
        }
        if(con.Driver_s_licence_state_Territory__c == 'Tasmania'){
			state = 'TAS';            
        }
        if(con.Driver_s_licence_state_Territory__c == 'Northern Territory'){
			state = 'NT';            
        }
        return state;
    }
    
    
}