@RestResource(urlMapping='/ReferralLeadIntegration/*')
global class ReferralLeadIntegration {
    
    @HttpPost
    //global static void createLead(String cFName, String cLName, String cEmail, String cPhone, String supplierdetail){
    global static void createLead(){    
    	String jsonStr ='{}';
        
        try{
            RestRequest req = RestContext.request;
            if(String.isBlank(req.requestBody.toString())){
                jsonStr ='{"Status" : "Error","Message" : "Required API body missing" }';
            }else{
                Map<String, Object> objMap = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
                String cFName = (String)objMap.get('cFName');
                String cLName = (String)objMap.get('cLName');
                String cEmail = (String)objMap.get('cEmail');
                String cPhone = (String)objMap.get('cPhone');
                String cMobilePhone = (String)objMap.get('cMobilePhone');
				String systemType = (String)objMap.get('systemType');
                String systemSize = (String)objMap.get('systemSize');
                String installationAdd = (String)objMap.get('InstallationAddress');
                String quarterlyEnergyBill = (String)objMap.get('QuarterlyEnergyBill');
                
                List<Object> supplierDetailList = New List<Object>();
                if(objMap.containsKey('supplierdetail')){
                	supplierDetailList = (List<Object>)objMap.get('supplierdetail');
                }
                if( String.isBlank(cLName)){
                    jsonStr ='{"Status" : "Error","Message" : "Required field[s] missing" }';
                }else{
                    
                    system.debug('>>supplierdetail>>>>>' + supplierDetailList);
                    Account Accgr = new Account();
                    if(!Test.isRunningTest()){
                        string accId = system.label.Solar_Quotes_Id;
                        Accgr = [select id, name from Account where Id =: accId LIMIT 1];
                    }
                    Lead ld = New Lead(FirstName = cFName, LastName = cLName, Email = cEmail, Phone = cPhone,
                                       MobilePhone = cMobilePhone, What_type_of_system_are_you_after__c = systemType,
                                       size__c = systemSize, installationAddressLineOne__c = installationAdd,Referred_by_Aggregator_Acc__c = Accgr.id,
                                        quarterlyBill__c = QuarterlyEnergyBill,LeadSource='SolarQuotes', Point_of_Origin__c = 'SolarQuotes API'); 
                    insert ld;
                    
                    List<Supplier__c> suppList = New List<Supplier__c>();
                    for(Object obj: supplierDetailList ){
                        Map<String, Object> objSMap = (Map<String, Object>)obj;
                        Supplier__c supp = New Supplier__c(Name = (String)objSMap.get('sName'), Lead__c = ld.Id);
                        suppList.add(supp);
                    }
                    
                    insert suppList;
                    
                    
                    jsonStr = '{"Status" : "Success","Message" : "New Lead Inserted successfully","LeadId" : "' + ld.Id + '"}';
                }
            }
        }catch(exception e){
            jsonStr = '{"Status" : "Error","Message" : "'+e.getMessage()+'"}';
        }
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(jsonStr);
        return;
    }
    
    
}