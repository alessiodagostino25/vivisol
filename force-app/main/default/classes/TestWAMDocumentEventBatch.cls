@isTest
public class TestWAMDocumentEventBatch {
    @isTest
    static void batchTest() {
        List<ContentVersion> contentVersionsToInsert = new List<ContentVersion>();
        List<ContentDocumentLink> CDLsToInsert = new List<ContentDocumentLink>();

        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Prescription__c prescription = new Prescription__c(
            Patient__c = account.Id,
            Received_date__c = Date.today()
        );
        insert prescription;

        WorkOrder workOrder = TestDataFactory.createWorkOrder();
        workOrder.Pricebook2Id = Test.getStandardPricebookId();
        insert workOrder;

        Product2 product = TestDataFactory.createProduct();
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        WorkOrderLineItem WOLI = TestDataFactory.createWOLI(workOrder.Id, pricebookEntry.Id);
        insert WOLI;

        OperatingHours operatingHours = TestDataFactory.createOperatingHours();
        insert operatingHours;

        ServiceTerritory serviceTerritory = TestDataFactory.createServiceTerritory(operatingHours.Id, true);
        insert serviceTerritory;

        ServiceAppointment serviceAppointment = TestDataFactory.createServiceAppointment(workOrder.Id, serviceTerritory.Id, 'New');
        insert serviceAppointment;

        ContentVersion contentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Test Document'),
            Title = 'Test Document Title',
            PathOnClient = 'Test Document Title.pdf'
        );
        contentVersionsToInsert.add(contentVersion);

        insert contentVersionsToInsert;

        ContentVersion queriedContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id];

        ContentDocumentLink CDL = new ContentDocumentLink(
            ContentDocumentId = queriedContentVersion.ContentDocumentId,
            LinkedEntityId = prescription.Id
        );
        CDLsToInsert.add(CDL);

        ContentDocumentLink CDL1 = new ContentDocumentLink(
            ContentDocumentId = queriedContentVersion.ContentDocumentId,
            LinkedEntityId = serviceAppointment.Id
        );
        CDLsToInsert.add(CDL1);

        ContentDocumentLink CDL2 = new ContentDocumentLink(
            ContentDocumentId = queriedContentVersion.ContentDocumentId,
            LinkedEntityId = workOrder.Id
        );
        CDLsToInsert.add(CDL2);

        ContentDocumentLink CDL3 = new ContentDocumentLink(
            ContentDocumentId = queriedContentVersion.ContentDocumentId,
            LinkedEntityId = WOLI.Id
        );
        CDLsToInsert.add(CDL3);

        insert CDLsToInsert;

        Test.startTest();

        Id batchId = Database.executeBatch(new WAMDocumentEventBatch(), 3);

        Test.stopTest();
 
        AsyncApexJob aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors 
                            FROM AsyncApexJob WHERE ID =: batchId];

        System.assertEquals(0, aaj.NumberOfErrors);
    }
}