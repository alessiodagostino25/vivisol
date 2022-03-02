@isTest
public class TestAssignATLogsBatch {
    @isTest
    static void batchTest() {
        Account acc = TestDataFactory.initAccount2();
        
        Account_Treatment__c at = new Account_Treatment__c();
        at.Account__c = acc.Id;
        at.Status__c = 'W';
        insert at;


        Account_Treatment__c queriedAT = [SELECT External_Id__c FROM Account_Treatment__c WHERE Id =: at.Id];

        Callout_Logger__c newCL = new Callout_Logger__c(RecordId__c = queriedAT.External_Id__c, Service__c = 'SFDC_PIMCORE_PATIENT_TREATMENT_UPSERT');

        insert newCL;

        newCL.Related_Account_Treatment__c = null;
        update newCL;

        Test.startTest();

        Database.executeBatch(new AssignAccountTreatmentLogsBatch());

        Test.stopTest();

        Callout_Logger__c queriedCL = [SELECT Related_Account_Treatment__c FROM Callout_Logger__c LIMIT 1];

        System.assertEquals(queriedAT.Id, queriedCL.Related_Account_Treatment__c);
    }
}