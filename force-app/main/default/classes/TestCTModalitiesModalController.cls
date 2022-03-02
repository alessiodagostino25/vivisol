@isTest
public class TestCTModalitiesModalController {
    @isTest
    static void getContractTreatmentModalitiesTest() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Modality__c ctm = TestDataFactory.createContractTreatmentModality(contractTreatment);
        ctm.Installation_Type__c = 'HV';
        insert ctm;

        Test.startTest();

        List<ContractTreatmentModalityDTO> DTOs = CTModalitiesModalController.getContractTreatmentModalities(contractTreatment.Id, 'CTM_Treatment');

        Test.stopTest();

        System.assertEquals(1, DTOs.size());
        System.assertEquals(ctm.Id, DTOs[0].id);
    }

    @isTest
    static void deleteCTModalityTest() {
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Modality__c ctm = TestDataFactory.createContractTreatmentModality(contractTreatment);
        ctm.Installation_Type__c = 'HV';
        insert ctm;

        Test.startTest();

        CTModalitiesModalController.deleteCTModality(ctm.Id);

        Test.stopTest();

        List<Contract_Treatment_Modality__c> modalities = [SELECT Id FROM Contract_Treatment_Modality__c];

        System.assertEquals(0, modalities.size());
    }
}