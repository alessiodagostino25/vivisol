@isTest
public class TestWOLICreationController {
    @isTest
    static void getPricebookEntriesTest() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Price_list_code__c = Test.getStandardPricebookId();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Contract_Framework__c = contractFramework.Id;
        insert CTJ;

        Product2 family = TestDataFactory.createProduct();
        family.IsActive = true;
        insert family;

        Product2 product = TestDataFactory.createProduct();
        product.Product_Family__c = family.Id;
        product.IsActive = true;
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        Contract_Treatment_Job_Product__c CTJP = TestDataFactory.createCTJP(CTJ.Id);
        CTJP.Product__c = product.Id;
        insert CTJP;

        Test.startTest();

        List<PricebookEntryDTO> dtoList = WOLICreationController.getPricebookEntries(CTJ.Id, '');

        Test.stopTest();

        System.assertEquals(1, dtoList.size());
    }

    @isTest
    static void getContractTreatmentJobIdTest() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Price_list_code__c = Test.getStandardPricebookId();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Contract_Framework__c = contractFramework.Id;
        insert CTJ;

        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.Contract_Treatment_Job__c = CTJ.Id;
        insert wo;

        Test.startTest();

        String CTJId = WOLICreationController.getContractTreatmentJobId(wo.Id);

        Test.stopTest();

        System.assertEquals(CTJ.Id, CTJId);
    }

    @isTest
    static void createWOLITest() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Price_list_code__c = Test.getStandardPricebookId();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Contract_Framework__c = contractFramework.Id;
        insert CTJ;

        Product2 product = TestDataFactory.createProduct();
        product.IsActive = true;
        insert product;

        Contract_Treatment_Job_Product__c CTJP = TestDataFactory.createCTJP(CTJ.Id);
        CTJP.Product__c = product.Id;
        insert CTJP;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.Pricebook2Id = Test.getStandardPricebookId();
        wo.Contract_Treatment_Job__c = CTJ.Id;
        insert wo;

        Test.startTest();

        WOLICreationController.createWOLIs(pricebookEntry.Id, wo.Id, 1.0, null, null, null, 'Delivery (+)', true);

        Test.stopTest();

        List<WorkOrderLineItem> WOLIs = [SELECT Id FROM WorkOrderLineItem WHERE WorkOrderId =: wo.Id];

        System.assertEquals(1, WOLIs.size());
    }

    @isTest
    static void checkForDisablingTest() {
        Product2 product = TestDataFactory.createProduct();
        product.Type__c = 'ZSER';
        product.IsActive = true;
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        Test.startTest();

        Boolean assetDisabled = WOLICreationController.checkForAssetDisabling(pricebookEntry.Id);
        Boolean locationShowing = WOLICreationController.checkForLocationFieldsShowing(pricebookEntry.Id);
        
        Test.stopTest();

        System.assertEquals(false, assetDisabled);
        System.assertEquals(false, locationShowing);
    }

    @isTest
    static void getRelatedCTJPTest() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Price_list_code__c = Test.getStandardPricebookId();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Contract_Framework__c = contractFramework.Id;
        insert CTJ;

        Product2 product = TestDataFactory.createProduct();
        product.IsActive = true;
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        Contract_Treatment_Job_Product__c CTJP = TestDataFactory.createCTJP(CTJ.Id);
        CTJP.Product__c = product.Id;
        insert CTJP;

        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.Contract_Treatment_Job__c = CTJ.Id;
        insert wo;

        Test.startTest();

        Contract_Treatment_Job_Product__c relatedCTJP = WOLICreationController.getRelatedCTJP(pricebookEntry.Id, wo.Id);

        Test.stopTest();

        System.assertEquals(CTJP.Id, relatedCTJP.Id);
    }

    @isTest
    static void getWorkOrderDocumentTypeTest() {
        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.Document_Type__c = 'ZRET';
        insert wo;

        Test.startTest();

        String documentType = WOLICreationController.getWorkOrderDocumentType(wo.Id);

        Test.stopTest();

        System.assertEquals(wo.Document_Type__c, documentType);
    }

    @isTest
    static void getSelectedProductTypeTest() {
        Product2 product = TestDataFactory.createProduct();
        product.Type__c = 'ZSER';
        product.IsActive = true;
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        Test.startTest();

        String productType = WOLICreationController.getSelectedProductType(pricebookEntry.Id);

        Test.stopTest();

        System.assertEquals(product.Type__c, productType);
    }
}