@istest
public class AddresApiControllerTest {
    static testmethod void getAddressTest(){
        string addApi = AddresApiController.getAddressAutoComplete('Ajm');
        System.assertEquals('Unit Test', addApi, 'Value should be same');
        
        string add= AddresApiController.getAddressDetails ('123');
        System.assertEquals('Unit Test', add, 'Value should be same');
    }
}