@isTest
public class TestContractTreatmentJobProductTrigger {

    @TestSetup
    static void makeData(){
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Contract_Framework__c = contractFramework.Id;
        insert CTJ;

        Product2 product = TestDataFactory.createProduct();
        insert product;
    }

    @isTest
    static void insertTest() {
        Contract_Treatment_Job__c CTJ = [SELECT Id FROM Contract_Treatment_Job__c];
        Product2 product = [SELECT Id, Name, Product_Code__c FROM Product2];

        Contract_Treatment_Job_Product__c CTJP = TestDataFactory.createCTJP(CTJ.Id);
        CTJP.Quantity__c = 2;
        CTJP.Product__c = product.Id;

        Test.startTest();

        Database.SaveResult result = Database.insert(CTJP);

        Test.stopTest();

        Contract_Treatment_Job_Product__c queriedCTJP = [SELECT Id, Product_Name_Text__c, Product_Code_Text__c FROM Contract_Treatment_Job_Product__c];

        System.assert(result.isSuccess());

        System.assertEquals(queriedCTJP.Product_Name_Text__c, product.Name);
        System.assertEquals(queriedCTJP.Product_Code_Text__c, product.Product_Code__c);
    }

    @isTest
    static void updateTest() {
        Contract_Treatment_Job__c CTJ = [SELECT Id, Status__c FROM Contract_Treatment_Job__c];

        List<Contract_Framework__c> cfs = [SELECT Id, Status__c FROM Contract_Framework__c];
        cfs[0].Status__c = 'Draft';
        update (cfs[0]);

        Product2 product = [SELECT Id, Name, Product_Code__c FROM Product2];

        Contract_Treatment_Job_Product__c CTJP = TestDataFactory.createCTJP(CTJ.Id);
        CTJP.Quantity__c = 2;
        CTJP.Product__c = product.Id;
        insert CTJP;

        CTJP.Quantity__c = 3;

        Test.startTest();

        Database.SaveResult result = Database.update(CTJP);

        Test.stopTest();

        List<Contract_Treatment_Job_Product__c> CTJPs = [SELECT Id, Quantity__c, Last_Propagated_Quantity__c FROM Contract_Treatment_Job_Product__c];

        System.assert(CTJPs.size() > 0);
        System.assertEquals(CTJPs[0].Quantity__c, CTJPs[0].Last_Propagated_Quantity__c);
    }
}