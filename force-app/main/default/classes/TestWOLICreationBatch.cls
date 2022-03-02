@isTest
public inherited sharing class TestWOLICreationBatch {
    @isTest
    static void batchTest() {
        Product2 product = TestDataFactory.createProduct();
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        //insert pricebookEntry;

        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        insert accountTreatment;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Price_list_code__c = Test.getStandardPricebookId();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Contract_Framework__c = contractFramework.Id;
        insert CTJ;

        Account_Treatment_Job__c ATJ = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        ATJ.Contract_Treatment_Job__c = CTJ.Id;
        insert ATJ;

        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.Pricebook2Id = Test.getStandardPricebookId();
        wo.Account_Treatment__c = accountTreatment.Id;
        wo.Account_Treatment_Job__c = ATJ.Id;
        insert wo;

        pricebookEntry.Pricebook2Id = wo.Pricebook2Id;
        insert pricebookEntry;

        Account_Treatment_Job_Product__c ATJP = TestDataFactory.createATJP(ATJ.Id);
        ATJP.Product__c = product.Id;
        insert ATJP;

        Test.startTest();

        WOLICreationBatch batch = new WOLICreationBatch();
        batch.ATJMap = new Map<Id, Account_Treatment_Job__c>{ATJ.Id => ATJ};
        batch.jobToProductsMap = new Map<Id, List<Account_Treatment_Job_Product__c>>{ATJ.Id => new List<Account_Treatment_Job_Product__c>{ATJP}};
        batch.pricebookIdToPEMap = new Map<Id, List<PricebookEntry>>{wo.Pricebook2Id => new List<PricebookEntry>{pricebookEntry}};
        batch.workOrders = new List<WorkOrder>{wo};

        Database.executeBatch(batch);

        WOLICreationBatch batch1 = new WOLICreationBatch();
        batch1.workOrders = new List<WorkOrder>{wo};

        Database.executeBatch(batch1);

        Test.stopTest();

        List<WorkOrderLineItem> WOLIs = [SELECT Id FROM WorkOrderLineItem WHERE WorkOrderId =: wo.Id];

        //System.assertEquals(1, WOLIs.size());
    }
}