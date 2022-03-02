@isTest
public class TestProductTransferTrigger {
    @TestSetup
    static void makeData(){
        List<Account_Treatment__c> accountTreatmentsToInsert = new List<Account_Treatment__c>();
        List<ProductItem> productItemsToInsert = new List<ProductItem>();
        List<Product_Asset_Patient_History__c> PAPHsToInsert = new List<Product_Asset_Patient_History__c>();

        ProductItem pi = TestDataFactory.createProductItem();
        ProductItem pi2 = TestDataFactory.createProductItem();
        ProductItem pi3 = TestDataFactory.createProductItem();

        List<Account> accounts =[SELECT Id, ShippingCity, ShippingCountry, ShippingStreet, ShippingPostalCode, ShippingCountryCode FROM Account];
        Account account = accounts[0];
        Account account2 = accounts[1];
        Account account3 = accounts[2];

        Schema.Location locationNoAccount = TestDataFactory.createLocation();
        insert locationNoAccount;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        accountTreatmentsToInsert.add(accountTreatment);

        Account_Treatment__c accountTreatment2 = TestDataFactory.createMRDAccountTreatment(account2);
        accountTreatmentsToInsert.add(accountTreatment2);

        Account_Treatment__c accountTreatment3 = TestDataFactory.createMRDAccountTreatment(account3);
        accountTreatmentsToInsert.add(accountTreatment3);

        insert accountTreatmentsToInsert;

        Asset asset = TestDataFactory.createAsset(account.Id);
        asset.LocationId = locationNoAccount.Id;

        Asset asset2 = TestDataFactory.createAsset(account2.Id);
        asset2.LocationId = locationNoAccount.Id;

        Asset asset3 = TestDataFactory.createAsset(account3.Id);
        asset3.AssetServicedById = account3.Id;
        asset3.Account_Treatment__c = accountTreatment3.Id;
        asset3.LocationId = locationNoAccount.Id;
        //insert asset3;

        insert (new List<Asset>{asset, asset2, asset3});
        
        pi.Serialized_Item__c = asset.Id;
        pi.Status__c = 'Valid';
        productItemsToInsert.add(pi);

        pi2.Serialized_Item__c = asset2.Id;
        pi2.Status__c = 'NotValid';
        productItemsToInsert.add(pi2);

        pi3.Serialized_Item__c = asset3.Id;
        pi3.Status__c = 'NotValid';
        productItemsToInsert.add(pi3);
        System.debug('Asset3 Id: ' + asset3.Id);

        insert productItemsToInsert;

        Product_Asset_Patient_History__c PAPH2 = TestDataFactory.createPAPH(asset2.Id);
        PAPH2.Account_Treatment__c = accountTreatment2.Id;
        PAPH2.Date__c = Date.today();
        PAPH2.Type__c = 'Removal';
        PAPH2.External_Id__c = 'TEST-0000001';
        PAPHsToInsert.add(PAPH2);

        Product_Asset_Patient_History__c PAPH3 = TestDataFactory.createPAPH(asset2.Id);
        PAPH3.Account_Treatment__c = accountTreatment2.Id;
        PAPH3.Date__c = Date.today();
        PAPH3.Type__c = 'Removal';
        PAPH3.External_Id__c = 'TEST-0000002';
        PAPHsToInsert.add(PAPH3);

        Product_Asset_Patient_History__c PAPH4 = TestDataFactory.createPAPH(asset2.Id);
        PAPH4.Account_Treatment__c = accountTreatment2.Id;
        PAPH4.Date__c = Date.today();
        PAPH4.Type__c = 'Delivery';
        PAPH4.External_Id__c = 'TEST-0000003';
        PAPHsToInsert.add(PAPH4);

        Product_Asset_Patient_History__c PAPH5 = TestDataFactory.createPAPH(asset3.Id);
        PAPH5.Account_Treatment__c = accountTreatment3.Id;
        PAPH5.Date__c = Date.today();
        PAPH5.Type__c = 'Delivery';
        PAPH5.External_Id__c = 'TEST-0000004';
        PAPHsToInsert.add(PAPH5);

        Product_Asset_Patient_History__c PAPH6 = TestDataFactory.createPAPH(asset3.Id);
        PAPH6.Account_Treatment__c = accountTreatment3.Id;
        PAPH6.Date__c = Date.today();
        PAPH6.Type__c = 'Delivery';
        PAPH6.External_Id__c = 'TEST-0000005';
        PAPHsToInsert.add(PAPH6);

        Product_Asset_Patient_History__c PAPH7 = TestDataFactory.createPAPH(asset3.Id);
        PAPH7.Account_Treatment__c = accountTreatment3.Id;
        PAPH7.Date__c = Date.today();
        PAPH7.Type__c = 'Removal';
        PAPH7.External_Id__c = 'TEST-0000006';
        PAPHsToInsert.add(PAPH7);

        insert PAPHsToInsert;

    }

    @isTest
    static void insertReturnTest() {
        List<Account> accounts = [SELECT Id, ShippingCity, ShippingCountry, ShippingStreet, ShippingPostalCode, ShippingCountryCode FROM Account];
        Account account = accounts[0];
        List<ProductItem> productItems = [SELECT Id, LocationId, QuantityOnHand, Product2Id FROM ProductItem WHERE Status__c = 'Valid'];
        ProductItem productItem = productItems[0];
        Schema.Location location = [SELECT Id FROM Location WHERE Account__c =: account.Id];

        ProductTransfer productTransfer = new ProductTransfer(
            SourceProductItemId = productItem.Id,
            QuantitySent = 2,
            DestinationLocationId = location.Id,
            Return__c = true
        );

        Test.startTest();

        Database.SaveResult result = Database.insert(productTransfer);

        Test.stopTest();

        System.assert(result.isSuccess());
    }

    @isTest
    static void insertNotReturnTest() {
        List<Account> accounts = [SELECT Id, ShippingCity, ShippingCountry, ShippingStreet, ShippingPostalCode, ShippingCountryCode FROM Account];
        Account account = accounts[1];
        List<ProductItem> productItems = [SELECT Id, LocationId, QuantityOnHand, Product2Id FROM ProductItem WHERE Status__c = 'NotValid'];
        ProductItem productItem = productItems[0];
        Schema.Location location = [SELECT Id FROM Location WHERE Account__c =: account.Id];

        ProductTransfer productTransfer = new ProductTransfer(
            SourceProductItemId = productItem.Id,
            QuantitySent = 2,
            DestinationLocationId = location.Id,
            Return__c = false
        );

        Test.startTest();

        Database.SaveResult result = Database.insert(productTransfer);

        Test.stopTest();

        System.assert(result.isSuccess());
    }

    @isTest
    static void insertReceivedNoAccountOnLocationTest() {
        List<ProductItem> productItems = [SELECT Id, LocationId, QuantityOnHand, Product2Id, Serialized_Item__c FROM ProductItem 
        WHERE Serialized_Item__r.AssetServicedById != null];
        ProductItem productItem = productItems[0];
        Schema.Location location = [SELECT Id FROM Location WHERE Account__c = null];

        ProductTransfer productTransfer = new ProductTransfer(
            SourceProductItemId = productItem.Id,
            QuantitySent = 2,
            DestinationLocationId = location.Id,
            Return__c = false,
            QuantityReceived = 2,
            isReceived = true
        );

        Test.startTest();

        Database.SaveResult result = Database.insert(productTransfer);

        Test.stopTest();

        System.assert(result.isSuccess());

        List<Product_Asset_Patient_History__c> PAPHs = [SELECT Id FROM Product_Asset_Patient_History__c];

        System.assertEquals(PAPHs.size(), 7);
    }

    @isTest
    static void insertReceivedRemovalPAPHTest() {
        Test.startTest();
        
        List<Account> accounts = [SELECT Id, ShippingCity, ShippingCountry, ShippingStreet, ShippingPostalCode, ShippingCountryCode FROM Account];
        Account account = accounts[1];
        List<ProductItem> productItems = [SELECT Id, LocationId, QuantityOnHand, Product2Id, Serialized_Item__c, Serialized_Item__r.Account_Treatment__c 
        FROM ProductItem 
        WHERE Serialized_Item__r.AssetServicedById != null];
        ProductItem productItem = productItems[0];
        Schema.Location location = [SELECT Id FROM Location WHERE Account__c =: account.Id];

        ProductTransfer productTransfer = new ProductTransfer(
            SourceProductItemId = productItem.Id,
            QuantitySent = 2,
            DestinationLocationId = location.Id,
            Return__c = false,
            QuantityReceived = 2,
            isReceived = true
        );

        Database.SaveResult result = Database.insert(productTransfer);

        Test.stopTest();

        System.assert(result.isSuccess());

        List<Product_Asset_Patient_History__c> PAPHs = [SELECT Id FROM Product_Asset_Patient_History__c];

        System.assertEquals(PAPHs.size(), 6);
    }

    @isTest
    static void shareProductTransfersTest() {
        List<Account> accounts = [SELECT Id, ShippingCity, ShippingCountry, ShippingStreet, ShippingPostalCode, ShippingCountryCode FROM Account];
        Account account = accounts[1];
        List<ProductItem> productItems = [SELECT Id, LocationId, QuantityOnHand, Product2Id FROM ProductItem WHERE Status__c = 'NotValid'];
        ProductItem productItem = productItems[0];
        Schema.Location location = [SELECT Id FROM Location WHERE Account__c =: account.Id];

        ProductTransfer productTransfer = new ProductTransfer(
            SourceProductItemId = productItem.Id,
            QuantitySent = 2,
            DestinationLocationId = location.Id,
            Return__c = false,
            Sales_Org_Code__c = '6300'
        );

        Test.startTest();

        Database.SaveResult result = Database.insert(productTransfer);

        Test.stopTest();

        System.assert(result.isSuccess());
    }
}