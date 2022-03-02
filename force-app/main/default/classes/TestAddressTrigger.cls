@isTest
public class TestAddressTrigger {
    
    @isTest
    public static void updateAddress(){
        Account a = TestDataFactory.initAccountWithAddress();
        Schema.Location location = TestDataFactory.initLocation(a);
       	Schema.Address newAddress = TestDataFactory.initAddress(a, location);
        Schema.Address newAddress2 = TestDataFactory.initAddress2(a, location);
        Test.startTest();
        newAddress.city='cityTest';
        newAddress.Is_Default__c=true;
        update newAddress;
        Test.stopTest();
        List<Schema.Address> address = [SELECT Id, city FROM Address where City='cityTest'];
        system.assertEquals(1, address.size());
    }


}