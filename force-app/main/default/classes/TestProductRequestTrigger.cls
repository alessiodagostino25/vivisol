@isTest
public class TestProductRequestTrigger {
    
    @TestSetup
    static void makeData(){
        ProductRequestLineItem PRLI = TestDataFactory.createPRLI();
        insert PRLI;

        ProductRequestLineItem PRLIExtraLoading = TestDataFactory.createPRLIExtraLoading();
        insert PRLIExtraLoading;
    }

    @isTest
    static void pickingLoadingSuccessTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, true));

        ProductRequest pr = [SELECT Id, Status FROM ProductRequest WHERE RecordType.Name != 'ProductRequest_ExtraLoading'];
        pr.Status = '2';

        Test.startTest();

        Database.SaveResult updateResult = Database.update(pr);

        Test.stopTest();

        System.assert(updateResult.isSuccess());
    }

    @isTest
    static void pickingLoadingFailTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(202, false));

        ProductRequest pr = [SELECT Id, Status FROM ProductRequest WHERE RecordType.Name != 'ProductRequest_ExtraLoading'];
        pr.Status = '2';

        Test.startTest();

        Database.SaveResult updateResult = Database.update(pr);

        Test.stopTest();

        System.assert(updateResult.isSuccess());
    }

    @isTest
    static void extraLoadingSuccessTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, true));

        ProductRequest pr = [SELECT Id, Status FROM ProductRequest WHERE RecordType.Name = 'ProductRequest_ExtraLoading'];
        pr.Status = '2';
        pr.Outbound_Delivery_Number__c = null;

        Test.startTest();

        Database.SaveResult updateResult = Database.update(pr);

        Test.stopTest();

        System.assert(updateResult.isSuccess());
    }

    @isTest
    static void extraLoadingFailTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(202, false));

        ProductRequest pr = [SELECT Id, Status FROM ProductRequest WHERE RecordType.Name = 'ProductRequest_ExtraLoading'];
        pr.Status = '2';
        pr.Outbound_Delivery_Number__c = null;

        Test.startTest();

        Database.SaveResult updateResult = Database.update(pr);

        Test.stopTest();

        System.assert(updateResult.isSuccess());
    }

    @isTest
    static void VANUnloadingInventoryLaunch() {
        RecordType inventoryRecordType = [SELECT DeveloperName FROM RecordType WHERE DeveloperName = 'ProductRequest_Inventory'];

        ProductRequest pr = [SELECT Id, Status FROM ProductRequest WHERE RecordType.Name != 'ProductRequest_ExtraLoading'];
        pr.RecordTypeId = inventoryRecordType.Id;
        pr.Status = '0';

        Test.startTest();

        Database.SaveResult result = Database.update(pr);

        Test.stopTest();

        System.assert(result.isSuccess());
    }

    @isTest
    static void VANUnloadingSAPLaunch() {
        RecordType inventoryRecordType = [SELECT DeveloperName FROM RecordType WHERE DeveloperName = 'ProductRequest_VanUnLoadfromSAP'];

        ProductRequest pr = [SELECT Id, Status FROM ProductRequest WHERE RecordType.Name != 'ProductRequest_ExtraLoading'];
        pr.RecordTypeId = inventoryRecordType.Id;
        pr.Status = '0';

        update pr;

        pr.Status = '1';

        Test.startTest();

        Database.SaveResult result = Database.update(pr);

        Test.stopTest();

        System.assert(result.isSuccess());
    }

    @isTest
    static void VANLoadingSAPLaunch() {
        RecordType inventoryRecordType = [SELECT DeveloperName FROM RecordType WHERE DeveloperName = 'ProductRequest_Inventory'];

        ProductRequest pr = [SELECT Id, Status FROM ProductRequest WHERE RecordType.Name != 'ProductRequest_ExtraLoading'];
        pr.RecordTypeId = inventoryRecordType.Id;
        pr.Status = '0';

        update pr;

        pr.Status = '1';

        Test.startTest();

        Database.SaveResult result = Database.update(pr);

        Test.stopTest();

        System.assert(result.isSuccess());
    }

    @isTest
    static void vanLoadingInventoryTest() {
        List<ProductItem> productItemsToInsert = new List<ProductItem>();
        List<ProductRequest> productRequestsToInsert = new List<ProductRequest>();
        List<ProductRequestLineItem> PRLIsToInsert = new List<ProductRequestLineItem>();
        List<Product2> productsToInsert = new List<Product2>();
        List<Schema.Location> locationsToInsert = new List<Schema.Location>();
        List<String> productItemIds = new List<String>();

        RecordType inventoryRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'ProductRequest_Inventory'];

        // Locations

        Schema.Location destinationLocation = TestDataFactory.createLocation();
        destinationLocation.IsInventoryLocation = true;
        locationsToInsert.add(destinationLocation);

        insert locationsToInsert;

        // ProductRequest

        ProductRequest productRequest = TestDataFactory.createProductRequest();
        productRequest.RecordTypeId = inventoryRT.Id;
        productRequest.Status = '0';
        productRequest.DestinationLocationId = destinationLocation.Id;
        productRequestsToInsert.add(productRequest);

        insert productRequestsToInsert;

        // Products

        Product2 product = TestDataFactory.createProduct();
        productsToInsert.add(product);

        Product2 product1 = TestDataFactory.createProduct();
        productsToInsert.add(product1);

        Product2 product2 = TestDataFactory.createProduct();
        productsToInsert.add(product2);

        Product2 product3 = TestDataFactory.createProduct();
        productsToInsert.add(product3);

        Product2 product4 = TestDataFactory.createProduct();
        productsToInsert.add(product4);

        Product2 product5 = TestDataFactory.createProduct();
        productsToInsert.add(product5);

        insert productsToInsert;

        // ProductItems

        ProductItem productItem = new ProductItem(
            Product2Id = product1.Id,
            SerialNumber = 'equipmentKey',
            LocationId = destinationLocation.Id,
            QuantityOnHand = 1
        );
        productItemsToInsert.add(productItem);

        ProductItem productItem1 = new ProductItem(
            Product2Id = product2.Id,
            LocationId = destinationLocation.Id,
            QuantityOnHand = 1,
            BatchNumber__c = '1'
        );
        productItemsToInsert.add(productItem1);

        ProductItem productItem2 = new ProductItem(
            Product2Id = product5.Id,
            LocationId = destinationLocation.Id,
            QuantityOnHand = 1,
            HU__c = 'handlingUnit'
        );
        productItemsToInsert.add(productItem2);

        insert productItemsToInsert;

        for(ProductItem pi : productItemsToInsert) {
            productItemIds.add(pi.Id);
        }

        // ProductRequestLineItems

        ProductRequestLineItem prli = new ProductRequestLineItem();
        prli.Product2Id = product.Id;
        prli.ParentId = productRequest.Id;
        prli.QuantityRequested = 1;
        prli.Status = '1';
        prli.Availability__c = 'Available';
        prli.Loaded_Quantity__c = 1;
        PRLIsToInsert.add(prli);

        ProductRequestLineItem prli1 = new ProductRequestLineItem();
        prli1.Product2Id = product1.Id;
        prli1.ParentId = productRequest.Id;
        prli1.QuantityRequested = 1;
        prli1.Status = '1';
        prli1.Availability__c = 'Available';
        prli1.Loaded_Quantity__c = 1;
        prli1.Serial_Number__c = 'serialNumber';
        prli1.EquipmentKey__c = 'equipmentKey';
        prli1.HU__c = 'handlingUnit';
        PRLIsToInsert.add(prli1);

        ProductRequestLineItem prli2 = new ProductRequestLineItem();
        prli2.Product2Id = product2.Id;
        prli2.ParentId = productRequest.Id;
        prli2.QuantityRequested = 1;
        prli2.Status = '1';
        prli2.Availability__c = 'Available';
        prli2.Loaded_Quantity__c = 1;
        prli2.Batch_Number__c = '1';
        PRLIsToInsert.add(prli2);

        ProductRequestLineItem prli3 = new ProductRequestLineItem();
        prli3.Product2Id = product3.Id;
        prli3.ParentId = productRequest.Id;
        prli3.QuantityRequested = 1;
        prli3.Status = '1';
        prli3.Availability__c = 'Available';
        prli3.Loaded_Quantity__c = 1;
        prli3.Batch_Number__c = '1';
        prli3.HU__c = 'handlingUnit';
        PRLIsToInsert.add(prli3);

        ProductRequestLineItem prli4 = new ProductRequestLineItem();
        prli4.Product2Id = product4.Id;
        prli4.ParentId = productRequest.Id;
        prli4.QuantityRequested = 1;
        prli4.Status = '1';
        prli4.Availability__c = 'Available';
        prli4.Loaded_Quantity__c = 1;
        prli4.Batch_Number__c = '1';
        prli4.RelatedItem__c = 'relatedItem';
        PRLIsToInsert.add(prli4);

        ProductRequestLineItem prli5 = new ProductRequestLineItem();
        prli5.Product2Id = product5.Id;
        prli5.ParentId = productRequest.Id;
        prli5.QuantityRequested = 1;
        prli5.Status = '1';
        prli5.Availability__c = 'Available';
        prli5.Loaded_Quantity__c = 1;
        prli5.HU__c = 'handlingUnit';
        PRLIsToInsert.add(prli5);

        insert PRLIsToInsert;

        productRequest.Status = '1';

        Test.startTest();

        List<Database.SaveResult> results = Database.update(productRequestsToInsert);

        Test.stopTest();

        List<ProductItem> productItems = [SELECT Id FROM ProductItem WHERE Id NOT IN: productItemIds];
        List<ProductTransfer> productTransfers = [SELECT Id FROM ProductTransfer];

        for(Database.SaveResult result : results) {
            System.assert(result.isSuccess());
        }
        System.assert(productItems.size() > 0);
        System.assert(productTransfers.size() > 0);
    }

    @isTest
    static void vanUnloadingSAPTest() {
        List<ProductItem> productItemsToInsert = new List<ProductItem>();
        List<ProductRequest> productRequestsToInsert = new List<ProductRequest>();
        List<ProductRequestLineItem> PRLIsToInsert = new List<ProductRequestLineItem>();
        List<Product2> productsToInsert = new List<Product2>();
        List<Schema.Location> locationsToInsert = new List<Schema.Location>();
        List<Asset> assetsToInsert = new List<Asset>();
        List<String> productItemIds = new List<String>();

        RecordType unloadFromSapRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'ProductRequest_VanUnLoadfromSAP'];

        Account account = TestDataFactory.createPersonAccount();
        insert account;

        // Locations

        Schema.Location sourceLocation = TestDataFactory.createLocation();
        sourceLocation.IsInventoryLocation = true;
        locationsToInsert.add(sourceLocation);

        insert locationsToInsert;

        // ProductRequest

        ProductRequest productRequest = TestDataFactory.createProductRequest();
        productRequest.RecordTypeId = unloadFromSapRT.Id;
        productRequest.Status = '0';
        productRequest.SourceLocationId = sourceLocation.Id;
        productRequestsToInsert.add(productRequest);

        insert productRequestsToInsert;

        // Products

        Product2 product = TestDataFactory.createProduct();
        productsToInsert.add(product);

        Product2 product1 = TestDataFactory.createProduct();
        productsToInsert.add(product1);

        Product2 product2 = TestDataFactory.createProduct();
        productsToInsert.add(product2);

        Product2 product3 = TestDataFactory.createProduct();
        productsToInsert.add(product3);

        Product2 product4 = TestDataFactory.createProduct();
        productsToInsert.add(product4);

        Product2 product5 = TestDataFactory.createProduct();
        productsToInsert.add(product5);

        Product2 product6 = TestDataFactory.createProduct();
        productsToInsert.add(product6);

        insert productsToInsert;

        // Asset

        Asset asset = TestDataFactory.createAsset(account.Id);
        asset.Equipment_Key__c = 'relatedItem';
        asset.LocationId = sourceLocation.Id;
        assetsToInsert.add(asset);

        insert assetsToInsert;

        // ProductItems

        ProductItem productItem = new ProductItem(
            Product2Id = product.Id,
            SerialNumber = 'equipmentKey',
            QuantityOnHand = 1,
            LocationId = sourceLocation.Id
        );
        productItemsToInsert.add(productItem);

        ProductItem productItem1 = new ProductItem(
            Product2Id = product1.Id,
            SerialNumber = 'NLserialNumber',
            QuantityOnHand = 1,
            LocationId = sourceLocation.Id
        );
        productItemsToInsert.add(productItem1);

        ProductItem productItem2 = new ProductItem(
            Product2Id = product2.Id,
            QuantityOnHand = 1,
            LocationId = sourceLocation.Id,
            BatchNumber__c = '1',
            HU__c = 'handlingUnit'
        );
        productItemsToInsert.add(productItem2);

        ProductItem productItem3 = new ProductItem(
            Product2Id = product3.Id,
            QuantityOnHand = 1,
            LocationId = sourceLocation.Id,
            BatchNumber__c = '1'
        );
        productItemsToInsert.add(productItem3);

        ProductItem productItem4 = new ProductItem(
            Product2Id = product4.Id,
            QuantityOnHand = 1,
            LocationId = sourceLocation.Id,
            BatchNumber__c = '1',
            RelatedContainer__c = asset.Id,
            HU__c = 'handlingUnit'
        );
        productItemsToInsert.add(productItem4);

        ProductItem productItem5 = new ProductItem(
            Product2Id = product5.Id,
            QuantityOnHand = 1,
            LocationId = sourceLocation.Id,
            HU__c = 'handlingUnit'
        );
        productItemsToInsert.add(productItem5);

        ProductItem productItem6 = new ProductItem(
            Product2Id = product6.Id,
            QuantityOnHand = 1,
            LocationId = sourceLocation.Id
        );
        productItemsToInsert.add(productItem6);

        insert productItemsToInsert;

        // ProductRequestLineItems

        ProductRequestLineItem prli = new ProductRequestLineItem();
        prli.Product2Id = product.Id;
        prli.ParentId = productRequest.Id;
        prli.QuantityRequested = 1;
        prli.Status = '1';
        prli.Availability__c = 'Available';
        prli.Loaded_Quantity__c = 1;
        prli.Serial_Number__c = 'serialNumber';
        prli.EquipmentKey__c = 'equipmentKey';
        prli.Batch_Number__c = '1';
        prli.HU__c = 'handlingUnit';
        PRLIsToInsert.add(prli);

        ProductRequestLineItem prli1 = new ProductRequestLineItem();
        prli1.Product2Id = product1.Id;
        prli1.ParentId = productRequest.Id;
        prli1.QuantityRequested = 1;
        prli1.Status = '1';
        prli1.Availability__c = 'Available';
        prli1.Loaded_Quantity__c = 1;
        prli1.Serial_Number__c = 'NLserialNumber';
        PRLIsToInsert.add(prli1);

        ProductRequestLineItem prli2 = new ProductRequestLineItem();
        prli2.Product2Id = product2.Id;
        prli2.ParentId = productRequest.Id;
        prli2.QuantityRequested = 1;
        prli2.Status = '1';
        prli2.Availability__c = 'Available';
        prli2.Loaded_Quantity__c = 1;
        prli2.Batch_Number__c = '1';
        prli2.HU__c = 'handlingUnit';
        PRLIsToInsert.add(prli2);

        ProductRequestLineItem prli3 = new ProductRequestLineItem();
        prli3.Product2Id = product3.Id;
        prli3.ParentId = productRequest.Id;
        prli3.QuantityRequested = 1;
        prli3.Status = '1';
        prli3.Availability__c = 'Available';
        prli3.Loaded_Quantity__c = 1;
        prli3.Batch_Number__c = '1';
        PRLIsToInsert.add(prli3);

        ProductRequestLineItem prli4 = new ProductRequestLineItem();
        prli4.Product2Id = product4.Id;
        prli4.ParentId = productRequest.Id;
        prli4.QuantityRequested = 1;
        prli4.Status = '1';
        prli4.Availability__c = 'Available';
        prli4.Loaded_Quantity__c = 1;
        prli4.Batch_Number__c = '1';
        prli4.RelatedItem__c = 'relatedItem';
        prli4.HU__c = 'handlingUnit';
        PRLIsToInsert.add(prli4);

        ProductRequestLineItem prli5 = new ProductRequestLineItem();
        prli5.Product2Id = product5.Id;
        prli5.ParentId = productRequest.Id;
        prli5.QuantityRequested = 1;
        prli5.Status = '1';
        prli5.Availability__c = 'Available';
        prli5.Loaded_Quantity__c = 1;
        prli5.HU__c = 'handlingUnit';
        PRLIsToInsert.add(prli5);

        ProductRequestLineItem prli6 = new ProductRequestLineItem();
        prli6.Product2Id = product6.Id;
        prli6.ParentId = productRequest.Id;
        prli6.QuantityRequested = 1;
        prli6.Status = '1';
        prli6.Availability__c = 'Available';
        prli6.Loaded_Quantity__c = 1;
        PRLIsToInsert.add(prli6);

        insert PRLIsToInsert;

        productRequest.Status = '1';

        Test.startTest();

        List<Database.SaveResult> results = Database.update(productRequestsToInsert);

        Test.stopTest();

        List<ProductTransfer> productTransfers = [SELECT Id FROM ProductTransfer];
        List<ProductItem> deletedProductItemList = [SELECT Id FROM ProductItem WHERE Id =: productItem1.Id];

        for(Database.SaveResult result : results) {
            System.assert(result.isSuccess());
        }
        System.assert(productTransfers.size() > 0);
        System.assertEquals(0, deletedProductItemList.size());
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
       
        Integer responseStatusCode;
        Boolean success;

        public  MockHttpResponseGenerator(Integer status, Boolean success){
            responseStatusCode = status;
            this.success = success;
        }
     
        public HTTPResponse respond(HTTPRequest req) {
            Integer statusCode = 200;
            if(req.getEndpoint() != 'callout:MC_Login') {
                statusCode = responseStatusCode;
            } 
            // Create a response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            if(success == false) {
                res.setBody('{"resultList": [{"success": false,"log_event": {"warningList": [{"uuid_Flow": "afbb1641-abb0-4994-a4d3-8f0a89be14a6","recordId": "abc1234","errorType": "Error","error_Description": "Counter reading smaller than in previous document 66","operationType": "BAPI","operation_Name": "ZFM_IF018_MEASUREMENT_CREATE","originSystem": "Salesforce","objectName": null,"service": "equipment-measurement-sfdc-sap-test","status": "fail","targetSystem": "SAP"}],"errorList": [{"uuid_Flow": "afbb1641-abb0-4994-a4d3-8f0a89be14a6","recordId": "abc1234","errorType": "Error","error_Description": "Counter reading smaller than in previous document 66","operationType": "BAPI","operation_Name": "ZFM_IF018_MEASUREMENT_CREATE","originSystem": "Salesforce","objectName": null,"service": "equipment-measurement-sfdc-sap-test","status": "fail","targetSystem": "SAP"}]}}]}');
            }
            else {
                res.setBody('{"resultList": [{"success": true,"log_event": {"warningList": [],"errorList": []}}]}');
            }
            res.setStatusCode(statusCode);
            res.setStatus('Complete');
            return res;
        }

    }
}