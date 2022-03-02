@isTest
public class TestATASelectionController {
    
    @isTest
    static void getATAsTest() {
        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        accountTreatment.Business_Line__c = null;
        accountTreatment.Treatment_Type__c = null;
        insert accountTreatment;

        Account_Treatment_Address__c ATA = TestDataFactory.createATA(accountTreatment);
        insert ATA;

        Test.startTest();

        List<AccountTreatmentAddressDTO> DTOs = ATASelectionController.getATAs(accountTreatment.Id);

        Test.stopTest();

        System.assertEquals(ATA.Id, DTOs[0].Id);
    }
}