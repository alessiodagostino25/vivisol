@isTest
public class TestLocationTrigger {
    @isTest
    static void updateTest() {
        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Schema.Location location = [SELECT Id FROM Location LIMIT 1];

        Test.startTest();

        location.Street__c = 'Via Test 1';
        Database.SaveResult result = Database.update(location);

        Test.stopTest();

        Schema.Address address = [SELECT Is_Portal_Sync__c FROM Address LIMIT 1];

        System.assert(result.isSuccess());
        System.assertEquals('03', address.Is_Portal_Sync__c);
    }
}