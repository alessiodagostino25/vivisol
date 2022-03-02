@isTest
public class TestAccountTreatmentJobProductTrigger {
    @TestSetup
    static void makeData(){
        RecordType maintenanceRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'AccountTreatment_Maintenance'];

        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Schema.Location plantLocation = TestDataFactory.createLocation();
        plantLocation.LocationType = 'Plant';
        insert plantLocation;

        Schema.Location storageLocation = TestDataFactory.createLocation();
        storageLocation.LocationType = 'Warehouse';
        storageLocation.Location_Id__c = 'test';
        storageLocation.Sales_Org_Code__c = '6300';
        insert storageLocation;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        //contractFramework.Customer__c = account.Id;
        //contractFramework.Branch_of_belonging_sales_office__c = accountSalesOrg.Id;
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        accountTreatment.Status__c = 'A';
        accountTreatment.RecordTypeId = maintenanceRT.Id;
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;
        insert accountTreatment;

        Asset asset = TestDataFactory.createAsset(account.Id);
        asset.LocationId = storageLocation.Id;
        insert asset;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        insert CTJ;

        Account_Treatment_Job__c accountTreatmentJobYear = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        accountTreatmentJobYear.Contract_Treatment_Job__c = CTJ.Id;
        accountTreatmentJobYear.Frequency__c = 3;
        accountTreatmentJobYear.Frequency_Unit_of_measure__c = 'Year';
        accountTreatmentJobYear.Task__c = true;
        accountTreatmentJobYear.Work_Order__c = true;
        accountTreatmentJobYear.Scheduling_Time_Frame__c = 365;
        accountTreatmentJobYear.Frequency_Type__c = 'NPU';
        insert accountTreatmentJobYear;

        Product2 product = TestDataFactory.createProduct();
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        WorkOrder workOrder = TestDataFactory.createWorkOrder();
        workOrder.Account_Treatment_Job__c = accountTreatmentJobYear.Id;
        workOrder.Pricebook2Id = Test.getStandardPricebookId();
        workOrder.Document_Type__c = 'YOV0';
        insert workOrder;
    }

    @isTest
    static void insertAndUpdateTest() {
        Account_Treatment_Job__c accountTreatmentJob = [SELECT Id FROM Account_Treatment_Job__c WHERE Frequency_Unit_of_measure__c = 'Year'];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Product2 product = [SELECT Id FROM Product2];
        Schema.Location plantLocation = [SELECT Id FROM Location WHERE LocationType = 'Plant' LIMIT 1];
        Schema.Location storageLocation = [SELECT Id FROM Location WHERE LocationType = 'Warehouse' LIMIT 1];

        Account_Treatment_Job_Product__c ATJP = TestDataFactory.createATJP(accountTreatmentJob.Id);
        ATJP.Product__c = product.Id;
        ATJP.Status__c = 'Active';
        ATJP.Asset__c = asset.Id;

        Test.startTest();

        Database.SaveResult result = Database.insert(ATJP);

        ATJP.Status__c = 'Inactive';
        ATJP.Plant__c = plantLocation.Id;
        ATJP.Storage_Location__c = storageLocation.Id;
        update ATJP;

        Test.stopTest();

        System.assert(result.isSuccess());

        List<WorkOrderLineItem> WOLIs = [SELECT Id FROM WorkOrderLineItem];

        System.assertEquals(1, WOLIs.size());
    }
}