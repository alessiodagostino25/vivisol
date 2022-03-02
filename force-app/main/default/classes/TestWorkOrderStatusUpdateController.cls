@isTest
public class TestWorkOrderStatusUpdateController {
    
    @isTest
    static void getStatusTest() {
        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.Status = 'New';
        insert wo;

        Test.startTest();

        String status = WorkOrderStatusUpdateController.getStatus(wo.Id);

        Test.stopTest();

        System.assertEquals('New', status);
    }

    @isTest
    static void getReasonTest() {
        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.Status = 'Canceled';
        wo.Reason__c = 'Rescheduled';
        insert wo;

        Test.startTest();

        String reason = WorkOrderStatusUpdateController.getReason(wo.Id);

        Test.stopTest();

        System.assertEquals('Rescheduled', reason);
    }

    @isTest
    static void goodsMovementSerializedItemRemovalTest() {
        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        accountTreatment.Business_Line__c = null;
        accountTreatment.Treatment_Type__c = null;
        insert accountTreatment;

        Schema.Location location = TestDataFactory.createLocation();
        location.IsInventoryLocation = true;
        location.Account__c = a.Id;
        insert location;

        WorkOrder workOrder = TestDataFactory.createWorkOrder();
        workOrder.Document_Type__c = 'ZRET';
        workOrder.LocationId = location.Id;
        workOrder.Account_Treatment__c = accountTreatment.Id;
        workOrder.Pricebook2Id = Test.getStandardPricebookId();
        insert workOrder;

        Product2 product = TestDataFactory.createProduct();
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        Asset asset = TestDataFactory.createAsset(a.Id);
        asset.LocationId = location.Id;
        insert asset;

        ProductItem productItem = TestDataFactory.createProductItem();
        productItem.LocationId = location.Id;
        productItem.Serialized_Item__c = asset.Id;
        insert productItem;

        WorkOrderLineItem WOLI = TestDataFactory.createWOLI(workOrder.Id, pricebookEntry.Id);
        WOLI.Status = 'New';
        WOLI.QuantityDelivered__c = 3;
        WOLI.WorkOrderId = workOrder.Id;
        WOLI.AssetId = asset.Id;
        WOLI.Serial_Number__c = '12345X';
        WOLI.Movement_Type__c = 'Removal (-)';
        insert WOLI;

        Test.startTest();

        WorkOrderStatusUpdateController.processGoodsMovement(workOrder.Id);

        Test.stopTest();

        List<ProductTransfer> productTransfers = [SELECT Id FROM ProductTransfer];
        List<Product_Asset_Patient_History__c> PAPHs = [SELECT Id FROM Product_Asset_Patient_History__c];
        List<WorkOrderLineItem> WOLIs = [SELECT Id, Status FROM WorkOrderLineItem];

        System.assertEquals(1, productTransfers.size());
        System.assertEquals(1, PAPHs.size());
        System.assertEquals('Completed', WOLIs[0].Status);
    }

    @isTest
    static void goodsMovementBatchRemovalTest() {
        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        accountTreatment.Business_Line__c = null;
        accountTreatment.Treatment_Type__c = null;
        insert accountTreatment;

        Schema.Location location = TestDataFactory.createLocation();
        location.IsInventoryLocation = true;
        location.Account__c = a.Id;
        insert location;

        WorkOrder workOrder = TestDataFactory.createWorkOrder();
        workOrder.Document_Type__c = 'ZRET';
        workOrder.LocationId = location.Id;
        workOrder.Account_Treatment__c = accountTreatment.Id;
        workOrder.Pricebook2Id = Test.getStandardPricebookId();
        insert workOrder;

        Product2 product = TestDataFactory.createProduct();
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        Asset asset = TestDataFactory.createAsset(a.Id);
        asset.LocationId = location.Id;
        insert asset;

        ProductItem productItem = TestDataFactory.createProductItem();
        productItem.LocationId = location.Id;
        productItem.Product2Id = product.Id;
        productItem.BatchNumber__c = '1';
        productItem.QuantityOnHand = 3;
        insert productItem;

        WorkOrderLineItem WOLI = TestDataFactory.createWOLI(workOrder.Id, pricebookEntry.Id);
        WOLI.Status = 'New';
        WOLI.QuantityDelivered__c = 3;
        WOLI.WorkOrderId = workOrder.Id;
        WOLI.Movement_Type__c = 'Removal (-)';
        WOLI.LocationId = location.Id;
        WOLI.Batch_Number__c = '1';
        insert WOLI;

        Test.startTest();

        WorkOrderStatusUpdateController.processGoodsMovement(workOrder.Id);

        Test.stopTest();

        List<ProductTransfer> productTransfers = [SELECT Id FROM ProductTransfer];
        List<Product_Asset_Patient_History__c> PAPHs = [SELECT Id FROM Product_Asset_Patient_History__c];
        List<WorkOrderLineItem> WOLIs = [SELECT Id, Status FROM WorkOrderLineItem];

        System.assertEquals(1, PAPHs.size());
        System.assertEquals('Completed', WOLIs[0].Status);
    }
}