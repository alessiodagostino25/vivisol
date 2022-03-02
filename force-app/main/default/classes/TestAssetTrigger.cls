@isTest
public class TestAssetTrigger{
	@TestSetup
	static void makeData(){
        ProductItem pi = TestDataFactory.createProductItem();
        Product2 product = TestDataFactory.createProduct();
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;
        
		WorkOrder workOrder = TestDataFactory.createWorkOrder();
		workOrder.Pricebook2Id = Test.getStandardPricebookId();
        workOrder.EndDate = null;
        workOrder.Status = 'New';
        insert workOrder;

        WorkOrderLineItem woli = TestDataFactory.createWOLI(workOrder.Id, pricebookEntry.Id);
        woli.Serial_Number__c = 'testtemporarylabel';
		insert woli;

        woli.Status = 'Completed';
        update woli;

        workOrder.Status = 'Completed';
        update workOrder;
        
		List<Account> accounts = [SELECT Id, ShippingCity, ShippingCountry, ShippingStreet, ShippingPostalCode, ShippingCountryCode
		                          FROM Account];
        Account account = accounts[0];

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        insert accountTreatment;
        
        Schema.Location storageLocation = TestDataFactory.createLocation();
        storageLocation.LocationType = 'Warehouse';
        storageLocation.Location_Id__c = 'test';
        storageLocation.Sales_Org_Code__c = '6300';
        insert storageLocation;

        Schema.Location plant = TestDataFactory.createLocation();
        plant.LocationType = 'Plant';
        insert plant;

        Asset Asset1 = TestDataFactory.createAsset(account.Id);
        Asset1.Product2Id = product.Id;
        Asset1.StorageLocation__c = storageLocation.Id;
        Asset1.Plant__c = plant.Id;
        Asset1.TemporaryLabel__c = 'testtemporarylabel1';
        Asset1.Account_Treatment__c = accountTreatment.Id;
        Asset1.LocationId = storageLocation.Id;
        insert Asset1;

        pi.Serialized_Item__c = Asset1.Id;
        pi.Status__c = 'Valid';
        insert pi;
	}

	@IsTest
	static void updateAsset(){
		Asset a = [SELECT Id, TemporaryLabel__c
		           FROM Asset];
        a.TemporaryLabel__c = 'testtemporarylabel';
		Test.startTest();

		Database.SaveResult result = Database.update(a);

        Test.stopTest();
        
        System.assert(result.isSuccess());

        List<Product_Asset_Patient_History__c> PAPHs = [SELECT Id FROM Product_Asset_Patient_History__c];
        List<ProductTransfer> pt = [SELECT Id FROM ProductTransfer ];
        List<WorkOrderLineItem> wolis = [SELECT Id FROM WorkOrderLineItem];
        List<WorkOrder> wos = [SELECT Id FROM WorkOrder] ;

        System.assertEquals(1, PAPHs.size());
        System.assertEquals(1, pt.size());
        System.assertEquals(2, wolis.size());
        System.assertEquals(2, wos.size());
	}

    @isTest
    static void accountTreatmentUpdateTest() {
        List<Account> accounts = [SELECT Id, ShippingCity, ShippingCountry, ShippingStreet, ShippingPostalCode, ShippingCountryCode
		                          FROM Account];
        Account account = accounts[0];

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        insert accountTreatment;

        List<Asset> assetList = [SELECT Account_Treatment_Number__c FROM Asset LIMIT 1];
        assetList[0].Account_Treatment__c = accountTreatment.Id;

        Test.startTest();

        Database.SaveResult result = Database.update(assetList[0]);

        Test.stopTest();

        Account_Treatment__c queriedAT = [SELECT Account_Treatment_Number__c FROM Account_Treatment__c WHERE Id =: accountTreatment.Id];
        Asset queriedAsset = [SELECT Account_Treatment_Number__c FROM Asset WHERE Id =: assetList[0].Id];

        System.assert(result.isSuccess());
        System.assertEquals(queriedAT.Account_Treatment_Number__c, queriedAsset.Account_Treatment_Number__c);
    }
}