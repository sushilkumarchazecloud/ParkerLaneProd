public class CreateDocumentController{
    
    public static List<AssetsAndLiabilities__c> assets{get;set;}
    public static List<AssetsAndLiabilities__c> liabilities{get;set;}
    public static Map<String, List<AssetsAndLiabilities__c>> assetsAndLiabilities{get;set;}
    public static Quote selectedQuote{get;set;}
    
    //Define set of all allowed operators
    //Mostly we don't need to change this, it can be added in setup method 
    public static void defineOperators(){
        Operations opObj = Operations.getInstance(); 
        opObj.registerOperation(OperationFactory.getInstance('&&'));
        opObj.registerOperation(OperationFactory.getInstance('==')); 
        opObj.registerOperation(OperationFactory.getInstance('!=')); 
        opObj.registerOperation(OperationFactory.getInstance('||'));
        opObj.registerOperation(OperationFactory.getInstance('('));
        opObj.registerOperation(OperationFactory.getInstance(')'));
        opObj.registerOperation(OperationFactory.getInstance('<'));
        opObj.registerOperation(OperationFactory.getInstance('<=')); 
        opObj.registerOperation(OperationFactory.getInstance('>'));
        opObj.registerOperation(OperationFactory.getInstance('>='));
    }
    
    public static Boolean checkApplicant2{get;set;}
    
    public static Boolean createDocumentRequest(String oppId){
        boolean isSuccess = false;
        checkApplicant2 = false;
        try{ 
            //Define Operators
            defineOperators();
            //exclude lender list
            List<String> excludeLenderList = New List<String>{'Plenti', 'Community First Credit Union'};
            //Check if documents are already exist
            Set<String> app1docs = new Set<String>();
            Set<String> app2docs = new Set<String>();
            Set<String> gendocs = new Set<String>();
            
            //Check if documents are duplicate in current transaction
            Set<String> app1set = new Set<String>();
            Set<String> app2set = new Set<String>();
            
            List<ContentVersion> cvList = new List<ContentVersion>();
            Set<id> documentId = new Set<id>();
            
            Opportunity opp = [SELECT Applicant_1__c,Applicant_2__c,lender__c
                               FROM Opportunity WHERE Id =: oppId][0];
            
            for(Document_Requested__c doc : [SELECT Document__c,Person_Account__c FROM Document_Requested__c WHERE Person_Account__c =: opp.Applicant_1__c AND Opportunity__c =: oppId]){
                app1docs.add(doc.Document__c);
            }
            
            if(opp.Applicant_2__c != null){
                for(Document_Requested__c doc : [SELECT Document__c,Person_Account__c FROM Document_Requested__c WHERE Person_Account__c =: opp.Applicant_2__c AND Opportunity__c =: oppId]){
                    app2docs.add(doc.Document__c);
                }   
            }
            
            for(Document_Requested__c doc : [SELECT Document__c,Person_Account__c FROM Document_Requested__c WHERE Person_Account__c = null AND Opportunity__c =: oppId]){
                gendocs.add(doc.Document__c);
            }
            
            //added by tazeem on 10-02-23
            for(ContentDocumentLink cdl : [select id, ContentDocumentId  from ContentDocumentLink where LinkedEntityId =: oppId]){
                documentId.add(cdl.ContentDocumentId);
            }
            
            for(ContentVersion cv : [select id,Category__c, title from ContentVersion where ContentDocumentId IN:documentId AND Category__c = 'Purchase Invoice']){
                cvList.add(cv);
            }
            //added by tazeem on 10-02-23
           
            //Document list to be requested
            Map<String,Document_Requested__c> docList = new Map<String,Document_Requested__c>();
            
            //Create documents for employment and income
            Map<String, Contact> empDetail = fetchEmpDetails(oppId);
            
            EmploymentStatus app1Emp = new EmploymentStatus();
            EmploymentStatus app2Emp = new EmploymentStatus();
            
            app1Emp.con = empDetail.get('applicant1');
            if(checkApplicant2){
                app2Emp.con = empDetail.get('applicant2');
            }
            
            selectedQuote = fetchSelectedQuote(oppId);
            
            List<RuleEngine__mdt> ruleList = [SELECT Document__c, Fields__c, Object__c, Description__c, Category__c, Rules__c, isGeneral__c FROM RuleEngine__mdt WHERE Object__c = 'Employment__c'];
            if(ruleList.size() > 0){
                System.debug('===> '+empDetail.get('applicant1').Employment__r.size());
                if(empDetail.get('applicant1').Employment__r.size() > 0){
                    System.debug('===> '+empDetail.get('applicant1').Employment__r.size());
                    List<Employment__c> empList = empDetail.get('applicant1').Employment__r;
                    for(Employment__c emp : empList){
                        for(RuleEngine__mdt re : ruleList){
                            System.debug('re.Document__c '+re.Document__c);
                            System.debug('app1docs '+app1docs.contains(re.Document__c)+' '+app1docs);
                            System.debug('app1set '+app1set.contains(re.Document__c)+' '+app1set);
                            System.debug('gendocs '+gendocs.contains(re.Document__c)+' '+gendocs);
                            if(!app1docs.contains(re.Document__c) && !app1set.contains(re.Document__c) && !gendocs.contains(re.Document__c)){
                                Map<String, String> bindings = new Map<String, String>();                                
                                List<String> fieldList = re.Fields__c.split(',');
                                System.debug('re.Fields__c'+fieldList);
                                if(fieldList.size() > 0){
                                    for(String fieldName : fieldList){
                                        System.debug('===> fieldName '+fieldName);
                                        if(emp.get(fieldName) != null){
                                            String fieldValue = (String)emp.get(fieldName);
                                            System.debug('===> fieldValue '+fieldValue);
                                            fieldValue = fieldValue.replaceAll( '/', '');
                                            fieldValue = fieldValue.replaceAll( '\'', '');
                                            fieldValue = fieldValue.replaceAll( '\\s+', '');
                                            fieldValue = fieldValue.replaceAll( '\u2019', '');                                            
                                            bindings.put(re.Object__c.toLowerCase()+'.'+fieldName.toLowerCase(), fieldValue);   
                                        }else{
                                            bindings = new Map<String, String>();
                                            break;
                                        }
                                    }
                                }
                                if(bindings.size() > 0){
                                    //Initialize Rule Engine
                                    Rule rule = new Rule().setExpression(re.Rules__c);   
                                    system.debug('rule>>>'+rule);
                                    //Evaluate rule with Binding values
                                    Boolean retResult = rule.eval(bindings) ;
                                    system.debug('retResult>>>'+retResult);
                                    if(retResult){
                                        docList.put(re.Document__c+''+opp.Applicant_1__c, createDocumentRequest(opp.Applicant_1__c, re, oppId));
                                        if(re.isGeneral__c){
                                            gendocs.add(re.Document__c);
                                        }else{
                                            app1set.add(re.Document__c);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                if(checkApplicant2){
                    if(empDetail.get('applicant2').Employment__r.size() > 0){
                        System.debug('EmploymentSize '+empDetail.get('applicant2').Employment__r.size());
                        List<Employment__c> empList = empDetail.get('applicant2').Employment__r;
                        for(Employment__c emp : empList){
                            for(RuleEngine__mdt re : ruleList){
                                if(!app2docs.contains(re.Document__c) && !app2set.contains(re.Document__c) && !gendocs.contains(re.Document__c)){
                                    Map<String, String> bindings = new Map<String, String>();
                                    List<String> fieldList = re.Fields__c.split(',');
                                    if(fieldList.size() > 0){
                                        for(String fieldName : fieldList){
                                            System.debug('===> fieldName '+fieldName);
                                            if(emp.get(fieldName) != null){
                                                String fieldValue = (String)emp.get(fieldName);
                                                fieldValue = fieldValue.replaceAll( '/', '');
                                                fieldValue = fieldValue.replaceAll( '\'', '');
                                                fieldValue = fieldValue.replaceAll( '\\s+', '');
                                                fieldValue = fieldValue.replaceAll( '\u2019', '');
                                                bindings.put(re.Object__c.toLowerCase()+'.'+fieldName.toLowerCase(), fieldValue);   
                                            }else{
                                                bindings = new Map<String, String>();
                                                break;
                                            }
                                        }
                                    }
                                    if(bindings.size() > 0){
                                        //Initialize Rule Engine
                                        Rule rule = new Rule().setExpression(re.Rules__c);   
                                        
                                        //Evaluate rule with Binding values
                                        Boolean retResult = rule.eval(bindings) ;
                                        if(retResult){
                                            docList.put(re.Document__c+''+opp.Applicant_2__c,createDocumentRequest(opp.Applicant_2__c, re, oppId));
                                            if(re.isGeneral__c){
                                                gendocs.add(re.Document__c);
                                            }else{
                                                app2set.add(re.Document__c);
                                            }
                                        }
                                    }
                                }        
                            }
                        }
                    }
                }
            }
            
            assetsAndLiabilities = fetchAssetsAndLiabilities(oppId);
            assets = assetsAndLiabilities.get('Asset');
            liabilities = assetsAndLiabilities.get('Liability');
            
            ruleList = [SELECT Document__c, Fields__c, Object__c, Description__c, Category__c, Rules__c, isGeneral__c FROM RuleEngine__mdt WHERE Object__c = 'AssetsAndLiabilities__c'];
            if(ruleList.size() > 0){
                if(assets.size() > 0){
                    for(AssetsAndLiabilities__c assts: assets){
                        for(RuleEngine__mdt re : ruleList){
                            if(!app1docs.contains(re.Document__c) && !app1set.contains(re.Document__c) && !gendocs.contains(re.Document__c)){
                                Map<String, String> bindings = new Map<String, String>();
                                List<String> fieldList = re.Fields__c.split(',');
                                if(fieldList.size() > 0){
                                    for(String fieldName : fieldList){
                                        System.debug('===> fieldName '+fieldName);
                                        if(assts.get(fieldName) != null){
                                            String fieldValue = String.valueOf(assts.get(fieldName));
                                            fieldValue = fieldValue.replaceAll( '/', '');
                                            fieldValue = fieldValue.replaceAll( '\'', '');
                                            fieldValue = fieldValue.replaceAll( '\\s+', '');
                                            fieldValue = fieldValue.replaceAll( '\u2019', '');
                                            bindings.put(re.Object__c.toLowerCase()+'.'+fieldName.toLowerCase(), fieldValue);   
                                        }else{
                                            bindings = new Map<String, String>();
                                            break;
                                        }
                                    }
                                }
                                if(bindings.size() > 0){
                                    //Initialize Rule Engine
                                    Rule rule = new Rule().setExpression(re.Rules__c);   
                                    
                                    //Evaluate rule with Binding values
                                    Boolean retResult = rule.eval(bindings) ;
                                    
                                    if(retResult){
                                        docList.put(re.Document__c+''+opp.Applicant_1__c,createDocumentRequest(opp.Applicant_1__c, re, oppId));
                                        if(re.isGeneral__c){
                                            gendocs.add(re.Document__c);
                                        }else{
                                            app1set.add(re.Document__c);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            System.debug('doclist = '+doclist.size());
            System.debug('doclist = '+doclist);
            ruleList = [SELECT Document__c, Fields__c, Object__c, Description__c, Category__c, Rules__c, isGeneral__c FROM RuleEngine__mdt WHERE Object__c = 'Quote'];
            if(ruleList.size() > 0){
                for(RuleEngine__mdt re : ruleList){
                    System.debug('re.Document__c '+re.Document__c);
                    System.debug('app1docs '+app1docs.contains(re.Document__c)+' '+app1docs);
                    System.debug('app1set '+app1set.contains(re.Document__c)+' '+app1set);
                    System.debug('gendocs '+gendocs.contains(re.Document__c)+' '+gendocs);
                    if(!app1docs.contains(re.Document__c) && !app1set.contains(re.Document__c) && !gendocs.contains(re.Document__c)){
                        Map<String, String> bindings = new Map<String, String>();
                        List<String> fieldList = re.Fields__c.split(',');
                        if(fieldList.size() > 0){
                            for(String fieldName : fieldList){
                                System.debug('===> fieldName '+fieldName);
                                if(selectedQuote.get(fieldName) != null){
                                    String fieldValue = (String)selectedQuote.get(fieldName);
                                    fieldValue = fieldValue.replaceAll( '/', '');
                                    fieldValue = fieldValue.replaceAll( '\'', '');
                                    fieldValue = fieldValue.replaceAll( '\\s+', '');
                                    fieldValue = fieldValue.replaceAll( '\u2019', '');
                                    System.debug('===> fieldValue '+fieldValue);
                                    bindings.put(re.Object__c.toLowerCase()+'.'+fieldName.toLowerCase(), fieldValue);   
                                }else{
                                    bindings = new Map<String, String>();
                                    break;
                                }
                            }
                        }
                        if(bindings.size() > 0){
                            //Initialize Rule Engine
                            Rule rule = new Rule().setExpression(re.Rules__c);   
                            
                            //Evaluate rule with Binding values
                            Boolean retResult = rule.eval(bindings) ;
                            
                            if(retResult){
                                docList.put(re.Document__c+''+opp.Applicant_1__c, createDocumentRequest(opp.Applicant_1__c, re, oppId));
                                if(re.isGeneral__c){
                                    gendocs.add(re.Document__c);
                                }else{
                                    app1set.add(re.Document__c);
                                }
                            }
                        }
                    }
                }
                
                if(checkApplicant2){
                    for(RuleEngine__mdt re : ruleList){
                        if(!app2docs.contains(re.Document__c) && !app2set.contains(re.Document__c) && !gendocs.contains(re.Document__c)){
                            Map<String, String> bindings = new Map<String, String>();
                            List<String> fieldList = re.Fields__c.split(',');
                            if(fieldList.size() > 0){
                                for(String fieldName : fieldList){
                                    System.debug('===> fieldName '+fieldName);
                                    if(selectedQuote.get(fieldName) != null){
                                        String fieldValue = (String)selectedQuote.get(fieldName);
                                        fieldValue = fieldValue.replaceAll( '/', '');
                                        fieldValue = fieldValue.replaceAll( '\'', '');
                                        fieldValue = fieldValue.replaceAll( '\\s+', '');
                                        fieldValue = fieldValue.replaceAll( '\u2019', '');
                                        bindings.put(re.Object__c.toLowerCase()+'.'+fieldName.toLowerCase(), fieldValue);   
                                    }else{
                                        bindings = new Map<String, String>();
                                        break;
                                    }
                                }
                            }
                            if(bindings.size() > 0){
                                //Initialize Rule Engine
                                Rule rule = new Rule().setExpression(re.Rules__c);   
                                
                                //Evaluate rule with Binding values
                                Boolean retResult = rule.eval(bindings) ;
                                if(retResult){
                                    docList.put(re.Document__c+''+opp.Applicant_2__c, createDocumentRequest(opp.Applicant_2__c, re, oppId));
                                    if(re.isGeneral__c){
                                        gendocs.add(re.Document__c);
                                    }else{
                                        app2set.add(re.Document__c);
                                    }
                                }
                            }
                        }        
                    }
                }
            }
            System.debug('doclist = '+doclist.size());
            System.debug('doclist = '+doclist);
            //if(!app1docs.contains('Driving license (front and back)'))
                //docList.add(createDocumentRequest(opp.Applicant_1__c, new RuleEngine__mdt(Document__c='Driving license (front and back)',Category__c='Identification'), oppId));
            //if(!app1docs.contains('Medicare Card') && selectedQuote.Lender__c != 'Community First Credit Union' && (selectedQuote.Purpose__c != 'SolarProducts' || selectedQuote.Purpose__c != 'HomeImprovements' || selectedQuote.Purpose__c != 'DebtConsolidation'))   
                //docList.put('Medicare Card',createDocumentRequest(opp.Applicant_1__c, new RuleEngine__mdt(Document__c='Medicare Card',Category__c='Identification'), oppId));
            
            System.debug('app1docs.contains() = '+app1docs.contains('Selfie holding driving license'));
            
            /*if(!app1docs.contains('Selfie holding driving license'))
                docList.put('Selfie holding driving license'+opp.Applicant_1__c, createDocumentRequest(opp.Applicant_1__c, new RuleEngine__mdt(Document__c='Selfie Holding Driving License',Category__c='Identification', Description__c='Please ensure license details are legible'), oppId));
            
            if(checkApplicant2){
                //if(!app2docs.contains('Driving license (front and back)'))
                    //docList.add(createDocumentRequest(opp.Applicant_2__c, new RuleEngine__mdt(Document__c='Driving license (front and back)',Category__c='Identification'), oppId));
                //if(!app2docs.contains('Medicare Card') && selectedQuote.Lender__c != 'Community First Credit Union' && (selectedQuote.Purpose__c != 'SolarProducts' || selectedQuote.Purpose__c != 'HomeImprovements' || selectedQuote.Purpose__c != 'DebtConsolidation'))
                    //docList.put('Medicare Card', createDocumentRequest(opp.Applicant_2__c, new RuleEngine__mdt(Document__c='Medicare Card',Category__c='Identification'), oppId));
                if(!app2docs.contains('Selfie holding driving license'))
                    docList.put('Selfie holding driving license'+opp.Applicant_2__c, createDocumentRequest(opp.Applicant_2__c, new RuleEngine__mdt(Document__c='Selfie Holding Driving License',Category__c='Identification', Description__c='Please ensure license details are legible'), oppId));
			}*/
            
            //added by kunal
            Boolean temp = false;
            if(liabilities != null){
                if(liabilities.size() > 0){
                    for(AssetsAndLiabilities__c liab: liabilities){
                        if(liab.AssetsAndLiabilitiesType__c == 'Home Loan/Mortgage' || liab.AssetsAndLiabilitiesType__c == 'Investment Home Loan'){
                            temp = true;
                            break;
                        }    
                    }   
                }                
            }
            
            if(empDetail.get('applicant1').Employment__r != null && empDetail.get('applicant1').Employment__r.size() > 0){
                List<Employment__c> empList = empDetail.get('applicant1').Employment__r;
                for(Employment__c emp : empList){
                    if(selectedQuote.Opportunity.Applicant_1__r.Does_your_spouse_earn_an_income__pc == 'Yes' && opp.Lender__c == 'Community First Credit Union' && temp == true){
                        if(!gendocs.contains('Council or water rates notice')){
                            docList.put('Council or water rates notice', createDocumentRequest(opp.Applicant_1__c, new RuleEngine__mdt(Document__c='Council or water rates notice',Category__c='Assets',isGeneral__c=true, Description__c='Less than 6 months old'), oppId));
                        	break;
                        }                
                    }        
                }
            }      
            
            //added by tazeem on 10-02-23
            if(empDetail.get('applicant1').Employment__r != null && empDetail.get('applicant1').Employment__r.size() > 0){
                List<Employment__c> empList = empDetail.get('applicant1').Employment__r;
                for(Employment__c emp : empList){
                    if(emp.EmploymentStatus__c == 'Casual / Temporary' && opp.Lender__c != 'Transport Mutual Credit Union'){
                        if(!app1docs.contains('Last Year\'s Income Statement (Group Certificate)')){
                            docList.put('Last Year\'s Income Statement (Group Certificate)', createDocumentRequest(opp.Applicant_1__c, new RuleEngine__mdt(Document__c='Last Year\'s Income Statement (Group Certificate)',Category__c='Income',isGeneral__c=false, Description__c='Your employer provides you with an Income Statement every year OR you can access it via ATO Online Services via your myGov account.'), oppId));
                        	break;
                        }                
                    }        
                }
            }
            if(opp.Applicant_2__c != null){
                if(empDetail.get('applicant2').Employment__r != null && empDetail.get('applicant2').Employment__r.size() > 0){
                    List<Employment__c> empList = empDetail.get('applicant2').Employment__r;
                    for(Employment__c emp : empList){
                        if(emp.EmploymentStatus__c == 'Casual / Temporary' && opp.Lender__c != 'Transport Mutual Credit Union'){
                            if(!app1docs.contains('Last Year\'s Income Statement (Group Certificate)')){
                                docList.put('Last Year\'s Income Statement (Group Certificate)', createDocumentRequest(opp.Applicant_2__c, new RuleEngine__mdt(Document__c='Last Year\'s Income Statement (Group Certificate)',Category__c='Income',isGeneral__c=false, Description__c='Your employer provides you with an Income Statement every year OR you can access it via ATO Online Services via your myGov account.'), oppId));
                            	break;
                            }                
                        }        
                    }
                }
            }
            //added by tazeem on 10-02-23
            Boolean flag = false;
            if(assets != null){
                if(assets.size() > 0){
                    for(AssetsAndLiabilities__c assts: assets){
                        if(assts.Rental_Amount__c > 0){
                            flag = true;
                            break;
                        }    
                    }   
                }                
            }
            
            if(!gendocs.contains('Rental Statement') && flag){
                docList.put('Rental Statement', createDocumentRequest(opp.Applicant_1__c, new RuleEngine__mdt(Document__c='Rental Statement',Category__c='Income',isGeneral__c=true, Description__c='Include rental income in your assessment by providing a rent statement from your real estate agent -  must be no older than 4 weeks.'), oppId));
            }
            
            if(!gendocs.contains('Bank Statement Data') && (selectedQuote.Lender__c == 'Community First Credit Union' && (selectedQuote.Purpose__c == 'SolarProducts' || selectedQuote.Purpose__c == 'HomeImprovements') && selectedQuote.Total_loan_amount__c > 25000)){
                docList.put('Bank Statement Data', createDocumentRequest(opp.Applicant_1__c, new RuleEngine__mdt(Document__c='Bank Statement Data',Category__c='Bank Statements',isGeneral__c=true, Description__c='Provide your transaction bank account data via secure service BankStatements.com.au.'), oppId));
            }    
            
            if(selectedQuote.Opportunity.ReferredByContact__c != null || (cvList!= null && cvList.size() > 0)){
                if(docList.get('Purchase Quote or Invoice'+opp.Applicant_1__c) != null)
                    docList.remove('Purchase Quote or Invoice'+opp.Applicant_1__c);
                if(docList.get('Purchase Quote or Invoice'+opp.Applicant_2__c) != null)
                    docList.remove('Purchase Quote or Invoice'+opp.Applicant_2__c);
            }
            //added by tazeem on 10-02-23
            if(selectedQuote.Lender__c == 'Transport Mutual Credit Union'){
                if(docList.get('Payslips'+opp.Applicant_1__c) != null)
                    docList.remove('Payslips'+opp.Applicant_1__c);
                if(docList.get('Payslips'+opp.Applicant_2__c) != null)
                    docList.remove('Payslips'+opp.Applicant_2__c);
                
                    
                /*if(selectedQuote.Purpose__c != 'DebtConsolidation'){
                    if(!gendocs.contains('Purchase Quote or Invoice'))
                        docList.add(createDocumentRequest(opp.Applicant_1__c, new RuleEngine__mdt(Document__c='Purchase Quote or Invoice',Category__c='Loan Purpose',isGeneral__c=true,Description__c='e.g. solar system quote'), oppId));
                }*/
                
                //docList.add(createDocumentRequest(opp.Applicant_1__c, new RuleEngine__mdt(Document__c='Bank Statements (or link account above)',Category__c='Income', Description__c='3 months bank statements showing income credits'), oppId));
                /*if(empDetail.get('applicant1').Employment__r.size() > 0){
                    System.debug('===> '+empDetail.get('applicant1').Employment__r.size());
                    List<Employment__c> empList = empDetail.get('applicant1').Employment__r;
                    if(empList[0].EmploymentStatus__c == 'Full time permanent' || empList[0].EmploymentStatus__c == 'Part time permanent'){
                        docList.add(createDocumentRequest(opp.Applicant_1__c, new RuleEngine__mdt(Document__c='1 month bank statement showing income credits (or link account above)',Category__c='Income'), oppId));
                    }
                    if(empList[0].EmploymentStatus__c != 'Full time permanent' || empList[0].EmploymentStatus__c != 'Part time permanent'){
                        docList.add(createDocumentRequest(opp.Applicant_1__c, new RuleEngine__mdt(Document__c='3 months bank statements showing income credits (or link account above)',Category__c='Income'), oppId));
                    }
                }*/
            }
            
            System.debug('--0-----docListSize--=------ '+docList);
            System.debug('docListSize '+docList.size());
            
            
            if(docList.size() > 0){
                insert docList.values();
                isSuccess = true;
            }else if(docList.size() == 0){
                isSuccess = true;
            }
        }catch(Exception e){
            isSuccess = false;
            UtilityClass.createException(oppId, 'CreateDocumentController', 'createDocumentRequest', e.getMessage(), e.getStackTraceString(), ''+e.getLineNumber(),
                                         e.getTypeName(), ''+e.getCause());
        }
        return isSuccess;
    }
    
    public static Document_Requested__c createDocumentRequest(Id appId, RuleEngine__mdt re, String oppId){
        Document_Requested__c doc = new Document_Requested__c();
        doc.Document__c = re.Document__c;
        doc.Description__c = re.Description__c;
        doc.Category__c = re.Category__c;
        if(!re.isGeneral__c){
            if(appId != null){
                doc.Person_Account__c = appId;
            }
        }else{
            doc.IsJoint__c = true;
        }
        doc.Opportunity__c = oppId;
        
        return doc;
    }
    
    public static Map<String, Contact> fetchEmpDetails(Id recordId){
        Opportunity opp = [SELECT Applicant_1__c, Applicant_2__c, Applicant_1__r.PersonContactId, Applicant_2__r.PersonContactId
                           FROM Opportunity WHERE Id =: recordId limit 1];
        Set<Id> conIds = new Set<Id>();
        if(opp.Applicant_1__c != null){
            conIds.add(opp.Applicant_1__r.PersonContactId);
        }
        if(opp.Applicant_2__c != null){
            conIds.add(opp.Applicant_2__r.PersonContactId);
        }
        Map<Id, Contact> conEmploymentMap = new Map<Id, Contact>([SELECT Name, CurrentEmployer__c, 
              Occupation__c, MaritalStatus__c, Email,
             (SELECT Id, Name, Occupation__c, AnnualIncome__c, EmployerAddress__c,Minimum_hours_per_week__c,
              EmployerPhoneNumber__c, EmploymentStatus__c, Income_Frequency__c, Months__c,
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
              FROM Employment__r)
              FROM Contact WHERE Id in :conIds]);
        Map<String, Contact> conMap = new Map<String, Contact>();
        if(opp.Applicant_1__c != null){
            conMap.put('applicant1', conEmploymentMap.get(opp.Applicant_1__r.PersonContactId));
        }
        if(opp.Applicant_2__c != null){
            checkApplicant2 = true;
            conMap.put('applicant2', conEmploymentMap.get(opp.Applicant_2__r.PersonContactId));
        }

        return conMap;
    }
    
    public static Quote fetchSelectedQuote(Id recordId){
        try{
            Quote qt = [SELECT Id, Customer_Amount__c, Loan_Term__c, Monthly_Repayment__c, Purpose__c,  Interest_Rate__c,Total_Loan_Cost__c,Total_Fees__c,Brokerage_Amount__c,
                        Lead__c, Lead__r.FirstName, Lead__r.LastName, Lead__r.Email, Shared_Message__c, Monthly_Repayments__c,Product__r.Interest_Rate_Type__c,Credit_Available_after_Setup_Costs__c,
                        Opportunity.Applicant_1__r.PersonContactId, Opportunity.Applicant_1__r.Does_your_spouse_earn_an_income__pc, Opportunity.ReferredByContact__c, Product__c, Product__r.Name,Total_loan_amount__c,Total_Setup_Fees__c,Product__r.Ongoing_Fees__c,Lender__c
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
    
    public static Map<String, List<AssetsAndLiabilities__c>> fetchAssetsAndLiabilities(Id recordId){
        List<AssetsAndLiabilities__c> assetsAndLiabilitiesList = 
            [SELECT Amount__c, Description__c, RecordType.Name, Limit__c, Monthly_Repayment__c,
             Ownership__c, AssetsAndLiabilitiesType__c, Address__c, Interest_Rate__c,
             Approximate_Remaining_Term_Years__c, Bank_Type__c, Country__c, Institution__c, Repayment_Type__c,
             Is_Address_Same__c, Is_Find_Address__c, Make_Model__c, Payment_Frequency__c, Postal_Code__c,
             Property_Managed_By__c, Rate_Expires_in_Months__c, Rate_Expires_in_Years__c, Rate_Type__c, Rental_Amount__c,
             Rental_Frequency__c, Repayment_Frequency__c, State__c, Street__c, Street_Number__c, Street_Type__c, Suburb__c,
             Type_of_Fund__c, Type_of_Tenancy__c, Unit_Number__c, Year__c, Post_Payment_Frequency__c, Post_tax_lease_Payment__c,
             Pre_Payment_Frequency__c, Pre_tax_lease_Payment__c, Ownership_Share__c, Other_Ownership_Share__c, Value__c
             FROM AssetsAndLiabilities__c 
             WHERE PrimaryOwner__c in (SELECT Applicant_1__c FROM Opportunity WHERE Id =: recordId)];
        Map<String, List<AssetsAndLiabilities__c>> assetsAndLiabilitiesMap = new Map<String, List<AssetsAndLiabilities__c>>();
        for(AssetsAndLiabilities__c assLiab : assetsAndLiabilitiesList){
            List<AssetsAndLiabilities__c>assLiabList = assetsAndLiabilitiesMap.get(assLiab.RecordType.Name);
            if(assLiabList == Null){
                assLiabList = new List<AssetsAndLiabilities__c>();
            }
            assLiabList.add(assLiab);
            assetsAndLiabilitiesMap.put(assLiab.RecordType.Name, assLiabList);
        }
        return assetsAndLiabilitiesMap;
    }
    
    public class employmentStatus{
        public Contact con{get;set;}
        public Employment__c emp{get;set;}
    } 
    
}