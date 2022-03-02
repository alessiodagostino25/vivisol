@isTest
public class TestATConfigurationController {
    @isTest
    static void getFieldsTest() {
        Test.startTest();

        List<AccountTreatmentFields__mdt> MDTList = accountTreatmentConfigurationController.getFields('MRD', 'Therapy_MRD');

        Test.stopTest();
    }
}