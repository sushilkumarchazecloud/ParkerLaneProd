/**
* @description      : This class TestDataFactory for unit testing data
* @author           : Sethu Singh Rawat
* @created on       : 20-02-2024
* @last Modified By : 
* @last Modified on :
**/
public class TestDataFactory {
    /**
    * @description This method creates the Account records 
    * @author           : Sethu Singh Rawat
    * @created date     : 20-02-2024
    * @param            : numOfRecords
    * @return           : List<Account>
    */
    public static List<Account> createAccounts(Integer numOfRecords){
        List<Account> accounts = new List<Account>();
        for(Integer count=0; count<numOfRecords; count++){
            Account acc = new Account();
            acc.Name = 'Salesforce.com'+count;
            acc.Rating = 'Hot';
            acc.Industry = 'Technology';
            acc.Description = 'This is a test account';
            acc.Phone = '4158889999';
            accounts.add(acc);
        }
        return accounts;
    }
    
    /**
    * @description      : This method is used to create users
    * @author           : Sethu Singh Rawat
    * @created date     : 20-02-2024
    * @param            : userWithProfile
    * @return           : List<User> key is user name and user is value
    */
    public static List<User> createUsers(Map<String, String> userWithProfile) {
        List<User> newUsers = new List<User>();
        Map<String, Profile> profiles = new Map<String, Profile>();
        for(Profile profileRecord : [SELECT Id, Name FROM Profile WHERE Name in : userWithProfile.values()]) {
            profiles.put(profileRecord.Name, profileRecord);
        }
        for(String userName : userWithProfile.keySet()) {
            newUsers.add(new User(
                ProfileId = profiles.get(userWithProfile.get(userName)).Id,
                LastName = userName,
                Email = userName+'@test.com',
                Username = userName+'@test.com' + System.currentTimeMillis(),
                CompanyName = 'TET',
                Title = 'test',
                Alias = 'test',
                Country = 'India',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'));
        }
        return newUsers;
    }
    
    /**
    * @description This method creates the Contact records 
    * @author           : Sethu Singh Rawat
    * @created date     : 22-02-2024
    * @param            : numOfRecords,accountId
    * @return           : List<Contact>
    */
    public static List<Contact> createContacts(Integer numOfRecords,Id accountId){
        List<Contact> contacts = new List<Contact>();
        for(Integer count=0; count<numOfRecords; count++){
            Contact con = new Contact();
            con.FirstName = 'Salesforce.com'+count;
            con.LastName = 'Test';
            con.AccountId = accountId;
            contacts.add(con);
        }
        return contacts;
    }
    
    /**
    * @description This method creates the Opportunity records 
    * @author           : Sethu Singh Rawat
    * @created date     : 22-02-2024
    * @param            : numOfRecords,accountId
    * @return           : List<Opportunity>
    */
    public static List<Opportunity> createOpportunities(Integer numOfRecords,Id accountId){
        List<Opportunity> opportunities = new List<Opportunity>();
        for(Integer count=0; count<numOfRecords; count++){
            Opportunity opp = new Opportunity();
            opp.Name = 'Salesforce.com'+count;
            opp.CloseDate = System.today();
            opp.StageName = 'Prospecting';
            opp.AccountId = accountId;
            opportunities.add(opp);
        }
        return opportunities;
    }
    
    /**
    * @description This method creates the Lead records 
    * @author           : Sumit Mahawar
    * @created date     : 22-02-2024
    * @param            : numOfRecords,accountId
    * @return           : List<Lead>
    */
    public static List<Lead> createLeads(Integer numOfRecords){
        List<Lead> leads = new List<Lead>();
        for(Integer count=0; count<numOfRecords; count++){
            Lead le = new Lead();
            le.Salutation = 'Mr.';
            le.FirstName = 'John';
            le.LastName = 'Doe' + count;
            le.Company = 'Test Company'+ count;
            le.Status = 'Open';
            leads.add(le);
        }
        return Leads;
    }
}