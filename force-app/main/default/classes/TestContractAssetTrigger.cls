@isTest
public class TestContractAssetTrigger {
    @isTest
    static void updateTest() {
        Schema.Location plant = TestDataFactory.createLocation();
        plant.LocationType = 'Plant';
        insert plant;

        Schema.Location storage = TestDataFactory.createLocation();
        storage.LocationType = 'Warehouse';
        storage.Location_Id__c = 'test';
        storage.Sales_Org_Code__c = '6300';
        insert storage;

        Account_Treatment__c accountTreatment = TestDataFactory.createAccountTreatmentWithJobFull();
        Contract_Treatment__c contractTreatment = [SELECT Id FROM Contract_Treatment__c WHERE Id =: accountTreatment.Contract_Treatment__c LIMIT 1];

        Asset asset = TestDataFactory.createAsset([SELECT Id FROM Account LIMIT 1].Id);
        asset.LocationId = storage.Id;
        insert asset;

        Account_Treatment_Job__c ATJ = [SELECT Id, Patient_Treatment__r.Contract_Treatment__c FROM Account_Treatment_Job__c WHERE Patient_Treatment__c =: accountTreatment.Id LIMIT 1];
        Account_Treatment_Job_Product__c ATJP = TestDataFactory.createATJP(ATJ.Id);
        ATJP.Plant__c = plant.Id;
        ATJP.Storage_Location__c = storage.Id;
        ATJP.Asset__c = asset.Id;
        insert ATJP;

        Contract_Asset__c contractAsset = new Contract_Asset__c(
            Contract_Treatment__c = ATJ.Patient_Treatment__r.Contract_Treatment__c,
            Asset__c = asset.Id
        );

        Test.startTest();

        insert contractAsset;

        contractAsset.Status__c = 'Inactive';

        Database.SaveResult result = Database.update(contractAsset);

        Test.stopTest();

        Account_Treatment_Job_Product__c queriedATJP = [SELECT Status__c FROM Account_Treatment_Job_Product__c WHERE Id =: ATJP.Id];

        System.assert(result.isSuccess());
        System.assertEquals('Inactive', queriedATJP.Status__c);
    }
}