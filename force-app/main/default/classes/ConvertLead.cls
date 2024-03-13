/*
* @Description       : This is the test class for ConvertLead Apex Class.
* @Author            : Sumit Mahawar
* @Created on        : 10-01-2024
* @Last Modified By  : Sumit Mahawar
* @Last Modified On  : 28-02-2024
*/
public class ConvertLead {
    
    /**
    * @description this for to get the single lead data
    * @author Sumit Mahawar
    * @Created on : 10-01-2024
    **/
    @AuraEnabled(cacheable=true)
    public static List<Lead> getLead(String Id){
        List<Lead> leList = [SELECT Id, Salutation, Name, FirstName, LastName, Company, Status, OwnerId  
                             FROM Lead 
                             WHERE Id = :Id LIMIT 1];
        return leList;
    }
    
    /**
    * @description this for to find the Opportunity record
    * @author Sumit Mahawar
    * @Created on : 10-01-2024
    **/
    @AuraEnabled
    public static List<Opportunity> findAccRelatedOpp(String accId){
        List<Opportunity> oppList = [SELECT Id, Name, CloseDate, Amount, Owner.Name, AccountId, Account.Name
                                     FROM Opportunity
                                     WHERE AccountId =: accId];
        System.debug('All Record : ' + oppList);
        return oppList;
    }
    
    /**
    * @description this for to convert the lead into Account, Contact and Opportunity
    * @author Sumit Mahawar
    * @Created on : 10-01-2024
    **/
    @AuraEnabled
    public static void convertLead(
        //Lead
        String LeadId, String LeadOwnerId,
        //Account
        String accNewName, String accExistingId, 
        //Contact
        String conNewSalutation, String conNewFirstName, String conNewLastName, 
        String conExistingId, Boolean conExistingCheckBox,
        //Opportunity
        String oppNewName, Boolean oppNewCheckBox, String oppExistingId){
            List<Lead> leQuery = new List<Lead>();
            leQuery=[SELECT Id, Salutation, Name, FirstName, LastName, Company, Title, LeadSource, Industry, AnnualRevenue, Phone, 
                     MobilePhone, Fax, Email,Website, Rating, NumberOfEmployees, Description, Street, City, PostalCode, State, 
                     Country, ProductInterest__c, SICCode__c,NumberofLocations__c, CurrentGenerators__c, Primary__c ,ConvertedDate,
                     Status , IsConverted
                     FROM Lead
                     WHERE Id =:LeadId LIMIT 1];
            
            //Account Section ------------------------------------------------
            List<Account> accList = new List<Account>();
            if(accExistingId == null){
                Lead leRecord = leQuery[0];
                Account acc = new Account();
                acc.OwnerId = LeadOwnerId;
                acc.Name = accNewName;
                acc.Industry = leRecord.Industry;
                acc.AnnualRevenue = leRecord.AnnualRevenue;
                acc.Rating = leRecord.Rating;
                acc.Phone = leRecord.Phone;
                acc.Fax = leRecord.Fax;
                acc.Website = leRecord.Website;
                acc.NumberOfEmployees = leRecord.NumberOfEmployees;
                acc.Sic = leRecord.SICCode__c;
                acc.BillingStreet = leRecord.Street;
                acc.BillingCity = lerecord.City;
                acc.BillingPostalCode = leRecord.PostalCode;
                acc.BillingState = leRecord.State;
                acc.BillingCountry = leRecord.Country;
                acc.Description = leRecord.Description;
                acc.NumberofLocations__c = leRecord.NumberofLocations__c;
                accList.add(acc);
                if(!accList.isEmpty()){
                    System.debug('New Account Record : ' + accList);
                    insert accList;
                }
            }
            else if(accExistingId != null){
                Lead leRecord = leQuery[0];
                Account acc = new Account();
                acc.OwnerId = LeadOwnerId;
                acc.Id = accExistingId;
                acc.Name = leRecord.Company;
                acc.Industry = leRecord.Industry;
                acc.AnnualRevenue = leRecord.AnnualRevenue;
                acc.Rating = leRecord.Rating;
                acc.Phone = leRecord.Phone;
                acc.Fax = leRecord.Fax;
                acc.Website = leRecord.Website;
                acc.NumberOfEmployees = leRecord.NumberOfEmployees;
                acc.Sic = leRecord.SICCode__c;
                acc.BillingStreet = leRecord.Street;
                acc.BillingCity = lerecord.City;
                acc.BillingPostalCode = leRecord.PostalCode;
                acc.BillingState = leRecord.State;
                acc.BillingCountry = leRecord.Country;
                acc.Description = leRecord.Description;
                acc.NumberofLocations__c = leRecord.NumberofLocations__c;
                accList.add(acc);
                if(!accList.isEmpty()){
                    System.debug('Existing Account Record : ' + accList);
                    update accList;
                }
            }
            
            //Contact Section ------------------------------------------------
            List<Contact> conList = new List<Contact>();
            if(conExistingId == null){
                Lead leRecord = leQuery[0];
                Contact con = new Contact();
                con.OwnerId = LeadOwnerId;
                con.Salutation = conNewSalutation;
                con.FirstName = conNewFirstName;
                con.LastName = conNewLastName;
                con.AccountId = accList[0].Id;
                con.Title = leRecord.Title;
                con.LeadSource = leRecord.LeadSource;
                con.Phone = leRecord.Phone;
                con.MobilePhone = leRecord.MobilePhone;
                con.Fax = leRecord.Fax;
                con.Email = leRecord.Email;
                con.MailingStreet = leRecord.Street;
                con.MailingCity = leRecord.City;
                con.MailingPostalCode = leRecord.PostalCode;
                con.MailingState = leRecord.State;
                con.MailingCountry = leRecord.Country;
                con.Description = leRecord.Description;
                conList.add(con);
                if(!conList.isEmpty()){
                    System.debug('New Contact Record : ' + conList);
                    insert conList;
                }
            }
            else if(conExistingId != null){
                if(conExistingCheckBox == false){
                    Lead leRecord = leQuery[0];
                    Contact con = new Contact();
                    con.OwnerId = LeadOwnerId;
                    con.Id = conExistingId;
                    con.Salutation = leRecord.Salutation;
                    con.FirstName = leRecord.FirstName;
                    con.LastName = leRecord.LastName;
                    con.AccountId = accExistingId;
                    con.Title = leRecord.Title;
                    con.Phone = leRecord.Phone;
                    con.MobilePhone = leRecord.MobilePhone;
                    con.Fax = leRecord.Fax;
                    con.Email = leRecord.Email;
                    con.MailingStreet = leRecord.Street;
                    con.MailingCity = leRecord.City;
                    con.MailingPostalCode = leRecord.PostalCode;
                    con.MailingState = leRecord.State;
                    con.MailingCountry = leRecord.Country;
                    con.Description = leRecord.Description;
                    conList.add(con);    
                    if(!conList.isEmpty()){
                        System.debug('Existing Contact Record : ' + conList);
                        update conList;
                    }
                }
                else if(conExistingCheckBox != false){
                    Lead leRecord = leQuery[0];
                    Contact con = new Contact();
                    con.OwnerId = LeadOwnerId;
                    con.Id = conExistingId;
                    con.Salutation = leRecord.Salutation;
                    con.FirstName = leRecord.FirstName;
                    con.LastName = leRecord.LastName;
                    con.AccountId = accExistingId;
                    con.Title = leRecord.Title;
                    con.LeadSource = leRecord.LeadSource;
                    con.Phone = leRecord.Phone;
                    con.MobilePhone = leRecord.MobilePhone;
                    con.Fax = leRecord.Fax;
                    con.Email = leRecord.Email;
                    con.MailingStreet = leRecord.Street;
                    con.MailingCity = leRecord.City;
                    con.MailingPostalCode = leRecord.PostalCode;
                    con.MailingState = leRecord.State;
                    con.MailingCountry = leRecord.Country;
                    con.Description = leRecord.Description;
                    conList.add(con);
                    if(!conList.isEmpty()){
                        System.debug('Existing Contact Record : ' + conList);
                        update conList;
                    }
                }   
            }
            
            //Opportunity Section ------------------------------------------------
            List<Opportunity> oppList = new List<Opportunity>();
            if(oppNewCheckBox == false){
                if(oppExistingId == null){
                    Lead leRecord = leQuery[0];
                    Opportunity opp = new Opportunity();
                    opp.OwnerId = LeadOwnerId;
                    opp.Name = oppNewName;
                    opp.AccountId = accList[0].Id;
                    opp.LeadSource = leRecord.LeadSource;
                    opp.CloseDate = System.today();
                    opp.StageName = 'Prospecting';
                    opp.Description = leRecord.Description;
                    oppList.add(opp);
                    if(!oppList.isEmpty()){
                        System.debug('New Opporunity Record : ' + oppList);
                        insert oppList;
                    }
                }
                else if(oppExistingId != null){
                    Lead leRecord = leQuery[0];
                    Opportunity opp = new Opportunity();
                    opp.OwnerId = LeadOwnerId;
                    opp.Id = oppExistingId;
                    opp.Name = leRecord.Company;
                    opp.AccountId = accExistingId;
                    opp.LeadSource = leRecord.LeadSource;
                    opp.CloseDate = System.today();
                    opp.StageName = 'Prospecting';
                    opp.Description = leRecord.Description;
                    oppList.add(opp);
                    if(!oppList.isEmpty()){
                        System.debug('Existing Opporunity Record : ' + oppList);
                        update oppList;
                    }
                }      
            }
            else if(oppNewCheckBox != false){
                System.debug('Opportunity is not created');
            }
            
            //Update the Lead Status To Convert ------------------------------------
            List<Lead> leList = new List<Lead>();
            Lead leRecord = leQuery[0];
            if(oppNewCheckBox == false && accList[0].Id != null && conList[0].Id != null && oppList[0].Id != null){
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(LeadId);
                lc.setAccountId(accList[0].Id);
                lc.setContactId(conList[0].Id);
                lc.setOpportunityId(oppList[0].Id);
                lc.setConvertedStatus('Closed - Converted');
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                System.debug('LCR : ' + lcr);
            }
            else if(oppNewCheckBox != false && accList[0].Id != null && conList[0].Id != null){        
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(LeadId);
                lc.setAccountId(accList[0].Id);
                lc.setContactId(conList[0].Id);
                lc.setDoNotCreateOpportunity(true);
                lc.setConvertedStatus('Closed - Converted');
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                System.debug('LCR : ' + lcr);
            }
        }
}