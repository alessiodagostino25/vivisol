@isTest
public class TestContractTreatmentController {
    @isTest
    static void getContractTreatmentTest() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Test.startTest();

        List<ContractTreatmentListDTO> DTOs = ContractTreatmentController.newGetContractTreatmentList(contractFramework.Id);

        Test.stopTest();

        System.assertEquals(1, DTOs.size());
    }

    @isTest
    static void getCTNumber() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Test.startTest();

        String CTNumber = ContractTreatmentController.newGetContractTreatmentListNumber(contractFramework.Id);

        Test.stopTest();

        System.assertEquals('1', CTNumber);
    }

    @isTest
    static void getCorporateTreatmentTest() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Corporate_Treatment__c corporateTreatment = TestDataFactory.createCorporateTreatment();
        insert corporateTreatment;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        contractTreatment.Corporate_Treatment__c = corporateTreatment.Id;
        insert contractTreatment;

        Test.startTest();

        String corporateTreatmentId = ContractTreatmentController.getCorporateTreatment(contractTreatment.Id);

        Test.stopTest();

        System.assertEquals(corporateTreatment.Id, corporateTreatmentId);
    }

    @isTest
    static void getFrameworkStatusTest() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Status__c = 'Draft';
        insert contractFramework;

        Test.startTest();

        String frameworkStatus = ContractTreatmentController.getFrameworkStatus(contractFramework.Id);

        Test.stopTest();

        System.assertEquals('Draft', frameworkStatus);
    }

    @isTest
    static void getNameFromIdTest() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        contractTreatment.Name = 'Test Contract Treatment';
        insert contractTreatment;

        Test.startTest();

        String name = ContractTreatmentController.getNameFromId(contractTreatment.Id);

        Test.stopTest();

        System.assertEquals('Test Contract Treatment', name);
    }

    @isTest
    static void removePermSetTest() {
        Test.startTest();

        ContractTreatmentController.assignPermSetNew();
        ContractTreatmentController.removePermSet();

        Test.stopTest();
    }

    @isTest
    static void cloneContractTreatmentTest() {
        Product2 product = TestDataFactory.createProduct();
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

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Contract_Framework__c = contractFramework.Id;
        insert CTJ;

        Contract_Treatment_Job_SLA__c SLA = TestDataFactory.createFullCalendarSLA(CTJ.Id);
        insert SLA;

        Contract_Treatment_Job_Product__c CTJP = TestDataFactory.createCTJP(CTJ.Id);
        CTJP.Product__c = product.Id;
        insert CTJP;

        Contract_Product_Limit__c CPL = TestDataFactory.createLimit(contractTreatment.Id, product.Id);
        insert CPL;

        Test.startTest();

        ContractTreatmentController.cloneContractTreatment(contractTreatment.Id, contractFramework1.Id, 'Clone CT');

        Test.stopTest();

        List<Contract_Treatment__c> contractTreatments = [SELECT Id FROM Contract_Treatment__c 
                                                          WHERE Id !=: contractTreatment.Id AND Contract_Framework__c =: contractFramework1.Id];
        List<Contract_Treatment_Job__c> CTJs = [SELECT Id FROM Contract_Treatment_Job__c WHERE Id !=: CTJ.Id];
        List<Contract_Treatment_Job_SLA__c> SLAs = [SELECT Id FROM Contract_Treatment_Job_SLA__c WHERE Id !=: SLA.Id];
        List<Contract_Treatment_Job_Product__c> CTJPs = [SELECT Id FROM Contract_Treatment_Job_Product__c WHERE Id !=: CTJP.Id];
        List<Contract_Product_Limit__c> limits = [SELECT Id FROM Contract_Product_Limit__c WHERE Id !=: CPL.Id];

        //System.assert(newCTJId != null);
        System.assertEquals(1, contractTreatments.size());
        System.assertEquals(1, CTJs.size());
        System.assertEquals(1, SLAs.size());
        System.assertEquals(1, CTJPs.size());
        System.assertEquals(1, limits.size());
    }

    @isTest
    static void checkForSLAWarningTest() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Framework__c contractFramework1 = TestDataFactory.createContractFramework();
        insert contractFramework1;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        contractTreatment.Name = 'Test Contract Treatment';
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Contract_Framework__c = contractFramework.Id;
        CTJ.Scheduling_Rule__c = 'Autoscheduled';
        insert CTJ;

        Test.startTest();

        Boolean showWarning = ContractTreatmentController.checkForSLAWarning(contractTreatment.Id);

        Contract_Treatment_Job_SLA__c SLA = TestDataFactory.createFullCalendarSLA(CTJ.Id);
        insert SLA;

        Boolean showWarning1 = ContractTreatmentController.checkForSLAWarning(contractTreatment.Id);

        Test.stopTest();

        System.assertEquals(true, showWarning);
        System.assertEquals(false, showWarning1);
    }

    @isTest
    static void updateCTJandCTJPsBillableTest() {
        Product2 product = TestDataFactory.createProduct();
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

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Contract_Framework__c = contractFramework.Id;
        CTJ.Scheduling_Rule__c = 'Autoscheduled';
        insert CTJ;

        Contract_Treatment_Job_Product__c CTJP = TestDataFactory.createCTJP(CTJ.Id);
        CTJP.Product__c = product.Id;
        insert CTJP;

        Test.startTest();

        ContractTreatmentService.updateCTJandCTJPsBillable(new List<Contract_Treatment__c>{contractTreatment});

        Test.stopTest();

        Contract_Treatment_Job__c queriedCTJ = [SELECT Billable__c FROM Contract_Treatment_Job__c WHERE Id =: CTJ.Id];
        Contract_Treatment_Job_Product__c queriedCTJP = [SELECT Billable__c FROM Contract_Treatment_Job_Product__c WHERE Id =: CTJP.Id];

        System.assertEquals(true, queriedCTJ.Billable__c);
        System.assertEquals(true, queriedCTJP.Billable__c);
    }

    @isTest
    static void getBusinessLineOptionsBySOTest() {
        Test.startTest();

        List<ProductTypeDTO> options = ContractTreatmentController.getBusinessLineOptionsBySO('6200');

        Test.stopTest();

        System.assert(options != null);
    }

    @isTest
    static void getBusinessLineOptionsBySOAndBLTest() {
        Test.startTest();

        List<ProductTypeDTO> options = ContractTreatmentController.getTreatmentTypeOptionsBySOAndBL('6200', 'LTOT');

        Test.stopTest();

        System.assert(options != null);
    }
}