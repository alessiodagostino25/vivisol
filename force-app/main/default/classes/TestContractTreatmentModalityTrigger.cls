@isTest
public class TestContractTreatmentModalityTrigger {
    @isTest
    static void insertTreatmentTest() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Modality__c ctm = TestDataFactory.createContractTreatmentModality(contractTreatment);
        ctm.Treatment_Type__c = 'PAP';
        ctm.Sub_Treatment__c = 'CPAP';
        insert ctm;

        Contract_Treatment_Modality__c ctm1 = TestDataFactory.createContractTreatmentModality(contractTreatment);
        ctm1.Treatment_Type__c = 'PAP';
        ctm1.Sub_Treatment__c = 'CPAP';

        Test.startTest();

        List<Database.SaveResult> results = Database.insert(new List<Contract_Treatment_Modality__c>{ctm1}, false);

        Test.stopTest();

        System.assert(!results[0].isSuccess());
    }

    @isTest
    static void insertRebateTest() {
        RecordType rebateRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'CTM_Rebate'];

        Product2 product = new Product2(
            Name = 'Test Product',
            Type__c = 'ZSER'
        );
        insert product;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Modality__c ctm = TestDataFactory.createContractTreatmentModality(contractTreatment);
        ctm.RecordTypeId = rebateRT.Id;
        ctm.Rebate__c = product.Id;
        insert ctm;

        Contract_Treatment_Modality__c ctm1 = TestDataFactory.createContractTreatmentModality(contractTreatment);
        ctm1.RecordTypeId = rebateRT.Id;
        ctm1.Rebate__c = product.Id;

        Test.startTest();

        List<Database.SaveResult> results = Database.insert(new List<Contract_Treatment_Modality__c>{ctm1}, false);

        Test.stopTest();

        System.assert(!results[0].isSuccess());
    }

    @isTest
    static void updateTest() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Modality__c ctm = TestDataFactory.createContractTreatmentModality(contractTreatment);
        ctm.Treatment_Type__c = 'PAP';
        ctm.Sub_Treatment__c = 'CPAP';
        ctm.Status__c = null;
        insert ctm;

        Test.startTest();

        ctm.Status__c = 'Active';
        Database.SaveResult result = Database.update(ctm);

        Test.stopTest();

        System.assert(result.isSuccess());
    }
}