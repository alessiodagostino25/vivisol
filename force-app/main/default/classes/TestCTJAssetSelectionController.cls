@isTest
public class TestCTJAssetSelectionController {
    @isTest
    static void getAssetsTest() {
        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Product2 product = TestDataFactory.createProduct();
        product.Name = 'Test Product';
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Framework__c contractFramework1 = TestDataFactory.createContractFramework();
        insert contractFramework1;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        contractTreatment.Name = 'Test Contract Treatment';
        insert contractTreatment;

        Schema.Location storageLocation = TestDataFactory.createLocation();
        storageLocation.LocationType = 'Warehouse';
        storageLocation.Location_Id__c = 'test';
        storageLocation.Sales_Org_Code__c = '6300';
        insert storageLocation;

        Asset asset = new Asset(
            Product2Id = product.Id,
            Name = 'Test Asset',
            AccountId = a.Id,
            LocationId = storageLocation.Id
        );
        insert asset;

        Test.startTest();

        List<AssetDTO> DTOs = CTJAssetSelectionController.getAssets(contractTreatment.Id, 'Test', new List<String>(), 10);

        Test.stopTest();

        System.assertEquals(1, DTOs.size());
    }

    @isTest
    static void createContractAssetTest() {
        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Product2 product = TestDataFactory.createProduct();
        product.Name = 'Test Product';
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Framework__c contractFramework1 = TestDataFactory.createContractFramework();
        insert contractFramework1;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        contractTreatment.Name = 'Test Contract Treatment';
        insert contractTreatment;

        Schema.Location storageLocation = TestDataFactory.createLocation();
        storageLocation.LocationType = 'Warehouse';
        storageLocation.Location_Id__c = 'test';
        storageLocation.Sales_Org_Code__c = '6300';
        insert storageLocation;

        Asset asset = new Asset(
            Product2Id = product.Id,
            Name = 'Test Asset',
            AccountId = a.Id,
            LocationId = storageLocation.Id
        );
        insert asset;

        Test.startTest();

        CTJAssetSelectionController.createContractAssets(new List<String>{asset.Id}, contractTreatment.Id);
        List<ContractAssetDTO> DTOs = CTJAssetSelectionController.getContractAssetsForCT(contractTreatment.Id);

        Test.stopTest();

        List<Contract_Asset__c> contractAssets = [SELECT Id FROM Contract_Asset__c WHERE Contract_Treatment__c =: contractTreatment.Id AND Asset__c =: asset.Id];

        System.assertEquals(1, contractAssets.size());
        System.assertEquals(1, DTOs.size());
    }

    @isTest
    static void deleteContractAssetTest() {
        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Product2 product = TestDataFactory.createProduct();
        product.Name = 'Test Product';
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Framework__c contractFramework1 = TestDataFactory.createContractFramework();
        insert contractFramework1;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        contractTreatment.Name = 'Test Contract Treatment';
        insert contractTreatment;

        Schema.Location storageLocation = TestDataFactory.createLocation();
        storageLocation.LocationType = 'Warehouse';
        storageLocation.Location_Id__c = 'test';
        storageLocation.Sales_Org_Code__c = '6300';
        insert storageLocation;

        Asset asset = new Asset(
            Product2Id = product.Id,
            Name = 'Test Asset',
            AccountId = a.Id,
            LocationId = storageLocation.Id
        );
        insert asset;

        Contract_Asset__c contractAsset = new Contract_Asset__c(
            Asset__c = asset.Id,
            Contract_Treatment__c = contractTreatment.Id
        );
        insert contractAsset;

        Test.startTest();

        CTJAssetSelectionController.deleteContractAsset(contractAsset.Id);

        Test.stopTest();

        List<Contract_Asset__c> contractAssets = [SELECT Id FROM Contract_Asset__c WHERE Id =: contractAsset.Id];

        System.assertEquals(0, contractAssets.size());
    }
}