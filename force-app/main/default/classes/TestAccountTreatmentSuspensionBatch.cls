@isTest
public class TestAccountTreatmentSuspensionBatch {
    @isTest
    static void batchTest() {
        List<Account_Treatment_Status__c> toInsert = new List<Account_Treatment_Status__c>();

        Account_Treatment__c accountTreatment = TestDataFactory.createAccountTreatmentWithJobFull();
        Account_Treatment_Status__c ATS = new Account_Treatment_Status__c(
            Patient_Treatment__c = accountTreatment.Id,
            Status__c = 'R',
            StartDate__c = Date.today()
        );
        toInsert.add(ATS);

        Test.startTest();

        Account_Treatment__c accountTreatment1 = TestDataFactory.createAccountTreatmentWithJobFull();
        Account_Treatment_Status__c ATS1 = new Account_Treatment_Status__c(
            Patient_Treatment__c = accountTreatment1.Id,
            Status__c = 'S',
            Suspension_start_date__c = Date.today().addDays(-2),
            Suspension_end_date__c = Date.today().addDays(-1)
        );
        toInsert.add(ATS1);

        List<Database.SaveResult> results = Database.insert(toInsert);

        Database.executeBatch(new AccountTreatmentSuspensionBatch());

        Test.stopTest();

        Account_Treatment__c queriedAT = [SELECT Status__c, Account__r.Status__c FROM Account_Treatment__c WHERE Id =: accountTreatment.Id];
        Account_Treatment__c queriedAT1 = [SELECT Status__c, Account__r.Status__c FROM Account_Treatment__c WHERE Id =: accountTreatment1.Id];

        for(Database.SaveResult result : results) {
            System.assert(result.isSuccess());
        }

        System.assertEquals(ATS.Status__c, queriedAT.Status__c);
        System.assertEquals('W', queriedAT1.Status__c);
        System.assertEquals('INACTIVE', queriedAT.Account__r.Status__c);
    }
}