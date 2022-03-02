@isTest
public class TestCaseTrigger {
    
    @isTest
    public static void testCaseTriggerMethod() {
        Account a = TestDataFactory.initAccountWithAddress();
        Test.startTest();
        Case c = new Case();
        c.AccountId = a.Id;
        insert c;
        Test.stopTest();
        system.debug('Case: ' + c);
        Case createdCase = [SELECT id, Patient__C, AccountId from Case where id = :c.Id];
        system.assertEquals(createdCase.Patient__c, createdCase.AccountId);
    }

    @isTest
    public static void testCaseTriggerMethod1() {
        Account a = TestDataFactory.initAccountWithAddress();
        Test.startTest();
        Case c = new Case();
        //c.AccountId = a.Id;
        insert c;
        Test.stopTest();
        system.debug('Case: ' + c);
        Case createdCase = [SELECT id, Patient__C, AccountId from Case where id = :c.Id];
        system.assertEquals(createdCase.Patient__c, null);
    }

}