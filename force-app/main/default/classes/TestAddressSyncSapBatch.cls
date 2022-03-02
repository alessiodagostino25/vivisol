@isTest
public class TestAddressSyncSapBatch {
    @isTest
    static void batchTest() {
        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Schema.Location location = TestDataFactory.createLocation();
        location.Account__c = account.Id;
        insert location;

        Schema.Address address = TestDataFactory.createDefaultAddress(account, location);
        address.IsSyncSAP__c = false;
        insert address;

        Schema.Location location1 = TestDataFactory.createLocation();
        location1.Account__c = account.Id;
        insert location1;

        Schema.Address address1 = TestDataFactory.createDefaultAddress(account, location1);
        address1.IsSyncSAP__c = false;
        address1.IsCreatedSAP__c = false;
        insert address1;

        Test.startTest();

        Database.executeBatch(new AddressSyncSapBatch());

        Test.stopTest();

        Schema.Address queriedAddress = [SELECT IsSyncSAP__c FROM Address WHERE Id =: address.Id];
        Schema.Address queriedAddress1 = [SELECT IsSyncSAP__c, IsCreatedSAP__c FROM Address WHERE Id =: address1.Id];

        //TODO: da rimettere le assert
/*
        System.assertEquals(true, queriedAddress.IsSyncSAP__c);
        System.assertEquals(true, queriedAddress1.IsSyncSAP__c);
        System.assertEquals(true, queriedAddress1.IsCreatedSAP__c);
        */
    }
}