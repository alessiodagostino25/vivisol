@isTest
public class TestJobTileController {

    public static testMethod void getPreviouslySelectedProducts(){
        
        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Product2 p = TestDataFactory.initProduct2();
        
        Account_Treatment__c at = TestDataFactory.createMRDAccountTreatment(a);
        at.Business_Line__c = null;
        at.Treatment_Type__c = null;
        insert at;

        Account_Treatment_Job__c atj = TestDataFactory.initAccountTreatmentJob2(p, at);
        Account_Treatment_Job_Product__c atjobid = TestDataFactory.initAccountTreatmentJobProduct2(atj, p);
        Test.startTest();
        List<String> productIds = JobTileController.getPreviouslySelectedProducts(atjobid.Patient_Treatment_Job__c);
        Test.stopTest();
        System.assertEquals(1, productIds.size());
    }

    @isTest
    static void deleteATJProductsTest() {
        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Product2 product = TestDataFactory.createProduct();
        insert product;

        PricebookEntry pe = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pe;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        insert CTJ;

        Contract_Treatment_Job_Product__c CTJP = TestDataFactory.createCTJP(CTJ.Id);
        CTJP.Product__c = product.Id;
        insert CTJP;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;
        insert accountTreatment;

        Account_Treatment_Job__c ATJ = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        ATJ.Contract_Treatment_Job__c = CTJ.Id;
        insert ATJ;

        Account_Treatment_Job_Product__c ATJP = TestDataFactory.createATJP(ATJ.Id);
        ATJP.Product__c = product.Id;
        insert ATJP;

        Test.startTest();

        JobTileController.deleteproductsrelatedtoatj(ATJ.Id);

        Test.stopTest();

        List<Account_Treatment_Job_Product__c> ATJPs = [SELECT Id FROM Account_Treatment_Job_Product__c];

        System.assertEquals(0, ATJPs.size());
    }

    @isTest
    static void getShowButtonsTest() {
        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        insert CTJ;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;
        insert accountTreatment;

        Account_Treatment_Job__c ATJ = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        ATJ.Contract_Treatment_Job__c = CTJ.Id;
        insert ATJ;

        Test.startTest();

        Boolean showFrequencyButton = JobTileController.getShowFrequencyButton(ATJ.Id);
        Boolean showDeliveryButton = JobTileController.getShowDeliveryButton(ATJ.Id);

        Test.stopTest();

        System.assertEquals(false, showFrequencyButton);
        System.assertEquals(false, showDeliveryButton);
    }
}