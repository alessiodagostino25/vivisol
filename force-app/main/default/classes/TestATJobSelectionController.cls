@isTest
public class TestATJobSelectionController {
    
    @isTest
    static void getJobsSampathTest() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Status__c = 'Active';
        insert CTJ;

        Test.startTest();

        List<Contract_Treatment_Job__c> CTJList = accountTreatmentJobSelectionController.getJobssampath('Test', contractTreatment.Id, null);

        Test.stopTest();

        System.assertEquals(1, CTJList.size());
        System.assertEquals(CTJ.Id, CTJList[0].Id);
    }

    @isTest
    static void getJobsTest() {
        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Status__c = 'Active';
        insert CTJ;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        insert accountTreatment;

        Account_Treatment_Job__c ATJ = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        insert ATJ;

        Test.startTest();

        List<Contract_Treatment_Job__c> CTJs = accountTreatmentJobSelectionController.getJobs(null, contractTreatment.Id, accountTreatment.Id);

        Test.stopTest();

        System.assertEquals(1, CTJs.size());
        System.assertEquals(CTJ.Id, CTJs[0].Id);
    }

    @isTest
    static void createATJsTest() {
        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        insert accountTreatment;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Status__c = 'Active';
        insert CTJ;

        Test.startTest();

        accountTreatmentJobSelectionController.createAccountTreatmentJobs(accountTreatment.Id, new List<String>{CTJ.Id});

        Test.stopTest();

        List<Account_Treatment_Job__c> ATJs = [SELECT Id FROM Account_Treatment_Job__c];

        System.assertEquals(1, ATJs.size());
    }

    @isTest
    static void createATJsChildTest() {
        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        insert accountTreatment;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Corporate_Treatment_Job__c corporateTJ = TestDataFactory.createCorporateTJ();
        insert corporateTJ;

        Corporate_Treatment_Job__c corporateTJ2 = TestDataFactory.createCorporateTJ();
        insert corporateTJ2;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Product2 product = TestDataFactory.createProduct();
        product.Type__c = 'ZJOB';
        product.Product_Code__c = 'testCode1';
        insert product;

        Product2 product2 = TestDataFactory.createProduct();
        product2.Type__c = 'ZJOB';
        product2.Product_Code__c = 'testCode2';
        insert product2;

        String CTId = contractTreatment.Id;
        String productId = product.Id;
        String product2Id = product2.Id;

        Contract_Treatment_Job__c fatherCTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        fatherCTJ.Status__c = 'Active';
        fatherCTJ.Contract_Treatment_Job_Code__c = product.Id;
        //fatherCTJ.Key__c = CTId + productId;
        insert fatherCTJ;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Status__c = 'Active';
        CTJ.Contract_Treatment_Job__c = fatherCTJ.Id;
        CTJ.Contract_Treatment_Job_Code__c = product2.Id;
        //CTJ.Key__c = CTId + product2Id;
        insert CTJ;

        Test.startTest();

        accountTreatmentJobSelectionController.createAccountTreatmentJobs(accountTreatment.Id, new List<String>{CTJ.Id});

        Test.stopTest();

        List<Account_Treatment_Job__c> ATJs = [SELECT Id FROM Account_Treatment_Job__c];

        System.assertEquals(1, ATJs.size());
    }

    @isTest
    static void getATJsEditModeTest() {
        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        insert accountTreatment;

        Account_Treatment_Job__c ATJ = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        insert ATJ;

        Test.startTest();

        List<Account_Treatment_Job__c> ATJs = accountTreatmentJobSelectionController.getseletedjobsineditmode(accountTreatment.Id);

        Test.stopTest();

        System.assertEquals(1, ATJs.size());
    }

    @isTest
    static void getATNameTest() {
        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        insert accountTreatment;

        Test.startTest();

        List<Account_Treatment__c> ATs = accountTreatmentJobSelectionController.getAccountTreatmentName(accountTreatment.Id);

        Test.stopTest();

        System.assertEquals(1, ATs.size());
    }
}