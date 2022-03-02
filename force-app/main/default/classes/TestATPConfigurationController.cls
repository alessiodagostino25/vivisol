@isTest
public class TestATPConfigurationController {
    @TestSetup
    static void makeData(){
        List<Schema.Location> locationsToInsert = new List<Schema.Location>();

        Schema.Location plant = TestDataFactory.createLocation();
        plant.LocationType = 'Plant';
        locationsToInsert.add(plant);

        Schema.Location storage = TestDataFactory.createLocation();
        storage.LocationType = 'Warehouse';
        storage.Location_Id__c = 'test';
        storage.Sales_Org_Code__c = '6300';
        locationsToInsert.add(storage);

        insert locationsToInsert;

        Account_Treatment__c accountTreatment = TestDataFactory.createAccountTreatmentWithJobFull();

        Account_Treatment_Job_Product__c ATJP = TestDataFactory.createATJP(
            [SELECT Id FROM Account_Treatment_Job__c WHERE Patient_Treatment__c =: accountTreatment.Id LIMIT 1].Id
        );
        ATJP.Plant__c = plant.Id;
        ATJP.Storage_Location__c = storage.Id;
        ATJP.Quantity__c = 1;
        insert ATJP;
    }

    @isTest
    static void getShowQuantityButtonTest() {
        Account_Treatment_Job_Product__c ATJP = [SELECT Id FROM Account_Treatment_Job_Product__c LIMIT 1];

        Test.startTest();

        Boolean showQuantityButton = ATPConfigurationController.getShowQuantityButton(ATJP.Id);

        Test.stopTest();

        System.assertEquals(false, showQuantityButton);
    }

    @isTest
    static void propagateQuantityTest() {
        Account_Treatment_Job_Product__c ATJP = [SELECT Id FROM Account_Treatment_Job_Product__c LIMIT 1];

        Product2 product = TestDataFactory.createProduct();
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        WorkOrder workOrder = TestDataFactory.createWorkOrder();
        workOrder.Pricebook2Id = Test.getStandardPricebookId();
        insert workOrder;

        Test.startTest();

        WorkOrderLineItem WOLI = TestDataFactory.createWOLI(workOrder.Id, pricebookEntry.Id);
        WOLI.Account_Treatment_Job_Product__c = ATJP.Id;
        WOLI.Quantity = 2;
        insert WOLI;

        Boolean success = ATPConfigurationController.propagateQuantity(ATJP.Id);

        Test.stopTest();

        WorkOrderLineItem queriedWOLI = [SELECT Quantity FROM WorkOrderLineItem WHERE Id =: WOLI.Id];

        System.assertEquals(true, success);
        System.assertEquals(1, queriedWOLI.Quantity);
    }

    @isTest
    static void propagateDeletionTest() {
        Account_Treatment_Job_Product__c ATJP = [SELECT Id FROM Account_Treatment_Job_Product__c LIMIT 1];

        Product2 product = TestDataFactory.createProduct();
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        WorkOrder workOrder = TestDataFactory.createWorkOrder();
        workOrder.Pricebook2Id = Test.getStandardPricebookId();
        insert workOrder;

        Test.startTest();

        WorkOrderLineItem WOLI = TestDataFactory.createWOLI(workOrder.Id, pricebookEntry.Id);
        WOLI.Account_Treatment_Job_Product__c = ATJP.Id;
        insert WOLI;

        Boolean success = ATPConfigurationController.propagateDeleteToWOLI(ATJP.Id);

        Test.stopTest();

        System.assertEquals(true, success);
    }
}