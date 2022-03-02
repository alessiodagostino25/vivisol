@isTest
public class TestAccountTreatmentController {
    
    @isTest
    static void removePermSetTest() {
        AccountTreatmentController.removePermSet();
    }

    @isTest
    static void assignPermSetTest() {
        AccountTreatmentController.assignPermSetNew();
    }

    @isTest
    static void getAccountIdTest() {
        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        insert accountTreatment;

        Test.startTest();

        String accountId = AccountTreatmentController.getAccountId(accountTreatment.Id);

        Test.stopTest();

        System.assertEquals(a.Id, accountId);
    }
}