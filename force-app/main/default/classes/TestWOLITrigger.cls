@isTest
public class TestWOLITrigger {
    
    @TestSetup
    static void makeData(){
        List<ServiceReportLayout> SRLs = [SELECT Id FROM ServiceReportLayout];
        ServiceReportLayout SRL = SRLs[0];

        Questionnaire__c questionnaire = TestDataFactory.createQuestionnaire();
        questionnaire.ServiceReportTemplateId__c = SRL.Id;
        insert questionnaire;

        Contract_Framework__c contractFramework = TestDataFactory.initContractFramework();

        Contract_Treatment__c contractTreatment = TestDataFactory.initContractTreatment(contractFramework.Id);

        Contract_Treatment_Job__c contractTreatmentJob = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        insert contractTreatmentJob;

        Contract_Treatment_Job_Product__c CTJP = TestDataFactory.createCTJP(contractTreatmentJob.Id);
        CTJP.Questionnaire__c = questionnaire.Id;
        insert CTJP;

        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        insert accountTreatment;

        Account_Treatment_Job__c accountTreatmentJob = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        insert accountTreatmentJob;

        Account_Treatment_Job_Product__c ATJP = TestDataFactory.createATJP(accountTreatmentJob.Id);
        ATJP.Contract_Treatment_Job_Product__c = CTJP.Id;
        insert ATJP;

        Product2 product = TestDataFactory.createProduct();
        product.Type__c = 'ZSER';
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        WorkOrder workOrder = TestDataFactory.createWorkOrder();
        workOrder.Pricebook2Id = Test.getStandardPricebookId();
        insert workOrder;
    }

    @isTest
    static void insertTest() {
        Questionnaire__c questionnaire = [SELECT Id, ServiceReportTemplateId__c FROM Questionnaire__c];
        PricebookEntry pricebookEntry = [SELECT Id, Product2Id, Pricebook2Id FROM PricebookEntry];
        WorkOrder workOrder = [SELECT Id, Pricebook2Id FROM WorkOrder];
        Account_Treatment_Job_Product__c ATJP = [SELECT Id FROM Account_Treatment_Job_Product__c];

        WorkOrderLineItem woli = TestDataFactory.createWOLI(workOrder.Id, pricebookEntry.Id);
        woli.Quantity = 3;
        woli.Account_Treatment_Job_Product__c = ATJP.Id;

        Test.startTest();

        Database.SaveResult result = Database.insert(woli);

        Test.stopTest();

        WorkOrderLineItem queriedWOLI = [SELECT Id, OrderLineItemExternalId__c, ServiceReportTemplateId, Questionnaire__c FROM WorkOrderLineItem WHERE Id =: woli.Id];

        System.assert(result.isSuccess());
        System.debug('queriedWOLI.OrderLineItemExtId: ' + queriedWOLI.OrderLineItemExternalId__c);
        System.assert(queriedWOLI.OrderLineItemExternalId__c != null);

        List<WorkOrderLineItem> WOLIs = [SELECT Id FROM WorkOrderLineItem];
        System.assertEquals(3, WOLIs.size());
        System.assertEquals(queriedWOLI.ServiceReportTemplateId, questionnaire.ServiceReportTemplateId__c);
        System.assertEquals(queriedWOLI.Questionnaire__c, questionnaire.Id);
    }

    @isTest
    static void pimcoreInsertTest() {
        Contract_Framework__c contractFramework = [SELECT Id FROM Contract_Framework__c LIMIT 1];

        Contract_Treatment__c contractTreatment =  [SELECT Id FROM Contract_Treatment__c LIMIT 1];

        Contract_Treatment_Job__c contractTreatmentJob = [SELECT Id FROM Contract_Treatment_Job__c LIMIT 1];

        Contract_Treatment_Job_Product__c CTJPToDelete = [SELECT Id FROM Contract_Treatment_Job_Product__c LIMIT 1];
        delete CTJPToDelete;

        Account account = TestDataFactory.createPersonAccountWithExternalId('WOLIACC_1');
        insert account;

        Test.startTest();

        Account_Treatment_Status__c accTreatStatus = [SELECT External_Id__c FROM Account_Treatment_Status__c limit 1];
        accTreatStatus.External_Id__c = 'ATSEXT-1236541';
        update accTreatStatus;
        
        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        accountTreatment.External_Id__c = 'EXT-12345432';
        insert accountTreatment;

        Account_Treatment_Job__c accountTreatmentJob = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        accountTreatmentJob.External_Id__c = 'JBEXT-12345432';
        accountTreatmentJob.Contract_Treatment_Job__c = contractTreatmentJob.Id;
        accountTreatmentJob.Billable__c = true;
        insert accountTreatmentJob;

        Product2 product = TestDataFactory.createProduct();
        product.Type__c = 'ZSER';
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        WorkOrder workOrder = TestDataFactory.createWorkOrder();
        workOrder.Status = 'Draft';
        workOrder.Pricebook2Id = Test.getStandardPricebookId();
        workOrder.Account_Treatment__c = accountTreatment.Id;
        workOrder.Account_Treatment_Job__c = accountTreatmentJob.Id;
        workOrder.Document_Type__c = 'YP00';
        insert workOrder;

        WorkOrderLineItem woli = TestDataFactory.createWOLI(workOrder.Id, pricebookEntry.Id);
        woli.Quantity = 3;

        Database.SaveResult result = Database.insert(woli);

        Test.stopTest();

        WorkOrderLineItem queriedWOLI = [SELECT Billable__c FROM WorkOrderLineItem WHERE Id =: woli.Id];

        System.assert(result.isSuccess());
        System.assertEquals(true, queriedWOLI.Billable__c);
    }
}