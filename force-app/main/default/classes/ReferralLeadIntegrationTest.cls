@isTest
public class ReferralLeadIntegrationTest {
    @isTest
    static void insertMethod(){
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        //System.Label.Solar_Quotes_Id = testAccount.Id;
        String JsonMsg  = '{"cFName":"test","cLName":"testdtt", "cEmail":"test455@parkerlane.com","cPhone":"041223233","cMobilePhone":"901234123","InstallationAddress":"address","systemType":"xyz", "systemSize":"20","QuarterlyEnergyBill":"2000",';
        JsonMsg += '"supplierdetail":[{"supplierId":"s1","sName":"Supp 1","sEmail":"supp1@gmail.com","sPhone":"9876543211", "spcFName":"spc FName1", "spcLName":"spc LName1", "spcEmail":"spc1@email.com","spcPhone":"9812345670"}]}';
        RestResponse res = new RestResponse();
        Test.startTest();
        RestRequest req = new RestRequest();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/ReferralLeadIntegration/';       
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req; 
        RestContext.response= res;
        ReferralLeadIntegration.createLead();
        
        Test.stopTest();
    }

    
}