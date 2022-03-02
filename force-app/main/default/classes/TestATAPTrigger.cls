@isTest
public class TestATAPTrigger {
    @isTest
    static void updateTest() {
        List<Account> accountsToInsert = new List<Account>();

        Account account = TestDataFactory.createPersonAccount();
        accountsToInsert.add(account);

        Account firstPayer = TestDataFactory.createPersonAccount();
        accountsToInsert.add(firstPayer);

        Account secondPayer = TestDataFactory.createPersonAccount();
        accountsToInsert.add(secondPayer);

        insert accountsToInsert;

        Schema.Location location = TestDataFactory.createLocation();
        location.Account__c = account.Id;
        insert location;

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

        Account_Treatment_Address__c ATA = TestDataFactory.createATA(accountTreatment);
        ATA.Location__c = location.Id;
        ATA.Account__c = account.Id;
        insert ATA;

        Test.startTest();

        Account_Treatment_Address_Payer__c ATAP = new Account_Treatment_Address_Payer__c(
            Account_Treatment__c = accountTreatment.Id,
            Account_Treatment_Address__c = ATA.Id,
            Payer__c = firstPayer.Id
        );
        insert ATAP;

        Case c = TestDataFactory.createCase();
        c.Origin = 'System';
        c.Status = 'New';
        c.Contract_Treatment__c = contractTreatment.Id;
        c.AccountId = account.Id;
        c.Patient__c = account.Id;
        c.Account_Treatment__c = accountTreatment.Id;
        c.Account_Treatment_Job__c = ATJ.Id;
        insert c;

        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.CaseId = c.Id;
        wo.Status = 'Draft';
        wo.LocationId = location.Id;
        wo.Account_Treatment__c = accountTreatment.Id;
        wo.Account_Treatment_Job__c = ATJ.Id;
        wo.Contract_Framework__c = contractFramework.Id;
        insert wo;

        ATAP.Payer__c = secondPayer.Id;

        Database.SaveResult result = Database.update(ATAP);

        Test.stopTest();

        WorkOrder queriedWO = [SELECT Id, Payer__c FROM WorkOrder WHERE Id =: wo.Id];

        System.assert(result.isSuccess());
        System.assertEquals(secondPayer.Id, queriedWO.Payer__c);
    }
}