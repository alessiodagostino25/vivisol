@isTest
public class TestWorkOrderTrigger {
    
    @isTest
    static void insertWithServiceTerritoryTest() {
        RecordType therapyRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'AccountTreatment_Therapy'];

        OperatingHours oh = TestDataFactory.createOperatingHours();
        insert oh;

        ServiceTerritory st = TestDataFactory.createServiceTerritory(oh.Id, true);
        insert st;

        Account account = TestDataFactory.createPersonAccount();
        account.DefaultTrainingServiceTerritory__c = st.Id;
        insert account;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        accountTreatment.RecordTypeId = therapyRT.Id;
        insert accountTreatment;

        Entitlement entitlement = TestDataFactory.createEntitlement(account.Id, oh.Id);
        insert entitlement;

        FSL__Polygon__c polygon = TestDataFactory.createPolygon(st.Id);
        //insert polygon;

        Test.startTest();
        
        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.Latitude = 51.54312343707734;
        wo.Longitude = 5.1087930696021076;
        wo.ServiceTerritoryId = st.Id;
        wo.Delivery_Type__c = 'Welcome Model';
        wo.Account_Treatment__c = accountTreatment.Id;
        Database.SaveResult result = Database.insert(wo);

        Test.stopTest();

        System.assert(result.isSuccess());
    }

    @isTest
    static void insertWithoutServiceTerritoryTest() {
        Account account = TestDataFactory.createPersonAccount();
        insert account;

        OperatingHours oh = TestDataFactory.createOperatingHours();
        insert oh;

        ServiceTerritory st = TestDataFactory.createServiceTerritory(oh.Id, true);
        insert st;

        Entitlement entitlement = TestDataFactory.createEntitlement(account.Id, oh.Id);
        insert entitlement;

        Test.startTest();
        
        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.Latitude = 51.54312343707734;
        wo.Longitude = 5.1087930696021076;
        Database.SaveResult result = Database.insert(wo);

        Test.stopTest();

        System.assert(result.isSuccess());
    }

    @isTest
    static void updateTest() {
        RecordType therapyRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'AccountTreatment_Therapy'];

        Schema.Location location = TestDataFactory.createLocation();
        location.IsInventoryLocation = true;
        insert location;

        Product2 product = TestDataFactory.createProduct();
        insert product;

        PricebookEntry pe = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pe;

        OperatingHours oh = TestDataFactory.createOperatingHours();
        insert oh;

        ServiceTerritory st = TestDataFactory.createServiceTerritory(oh.Id, true);
        insert st;

        ServiceTerritory st2 = TestDataFactory.createServiceTerritory(oh.Id, true);
        st2.Name = 'Test ServiceTerritory 2';
        insert st2;

        Account account = TestDataFactory.createPersonAccount();
        account.DefaultTrainingServiceTerritory__c = st.Id;
        insert account;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        accountTreatment.RecordTypeId = therapyRT.Id;
        insert accountTreatment;

        Asset asset = TestDataFactory.createAsset(account.Id);
        asset.SerialNumber = 'X12345Y';
        asset.LocationId = location.Id;
        insert asset;

        ProductItem pi = TestDataFactory.createProductItem();
        pi.Serialized_Item__c = asset.Id;
        insert pi;

        Entitlement entitlement = TestDataFactory.createEntitlement(account.Id, oh.Id);
        insert entitlement;

        FSL__Polygon__c polygon = TestDataFactory.createPolygon(st.Id);
        //insert polygon;

        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.Latitude = 51.54312343707734;
        wo.Longitude = 5.1087930696021076;
        wo.ServiceTerritoryId = st.Id;
        wo.Delivery_Type__c = 'Welcome Model';
        wo.Account_Treatment__c = accountTreatment.Id;
        wo.Pricebook2Id = Test.getStandardPricebookId();
        wo.LocationId = location.Id;
        wo.AccountId = account.Id;
        insert wo;

        WorkOrderLineItem WOLI = TestDataFactory.createWOLI(wo.Id, pe.Id);
        WOLI.Status = 'Nuovo';   // TO CHANGE: 'New'
        WOLI.QuantityDelivered__c = 2;
        WOLI.AssetId = asset.Id;
        WOLI.Serial_Number__c = 'TestSerialNumber';
        insert WOLI;

        wo.Latitude = 52.54312343707734;
        wo.ServiceTerritoryId = st2.Id;
        wo.Status = 'Completed';
        wo.Delivery_Type__c = 'Currier';
        Test.startTest();

        Database.SaveResult result = Database.update(wo);

        Test.stopTest();

        List<Product_Asset_Patient_History__c> PAPHs = [SELECT Id FROM Product_Asset_Patient_History__c];
        List<ProductTransfer> productTransfers = [SELECT Id FROM ProductTransfer];
        List<Asset> assets = [SELECT Id, AssetServicedById, Account_Treatment__c FROM Asset];

        System.assert(result.isSuccess());
        System.assert(PAPHs.size() > 0);
        System.assert(productTransfers.size() > 0);

        System.assertEquals(assets[0].AssetServicedById, account.Id);
        System.assertEquals(assets[0].Account_Treatment__c, accountTreatment.Id);
    }

    @isTest
    static void updateNullATTest() {
        RecordType therapyRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'AccountTreatment_Therapy'];

        Schema.Location location = TestDataFactory.createLocation();
        location.IsInventoryLocation = true;
        insert location;

        Product2 product = TestDataFactory.createProduct();
        insert product;

        PricebookEntry pe = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pe;

        OperatingHours oh = TestDataFactory.createOperatingHours();
        insert oh;

        ServiceTerritory st = TestDataFactory.createServiceTerritory(oh.Id, true);
        insert st;

        ServiceTerritory st2 = TestDataFactory.createServiceTerritory(oh.Id, true);
        st2.Name = 'Test ServiceTerritory 2';
        insert st2;

        Account account = TestDataFactory.createPersonAccount();
        account.DefaultTrainingServiceTerritory__c = st.Id;
        insert account;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        accountTreatment.RecordTypeId = therapyRT.Id;
        insert accountTreatment;

        Asset asset = TestDataFactory.createAsset(account.Id);
        asset.SerialNumber = 'X12345Y';
        asset.LocationId = location.Id;
        insert asset;

        ProductItem pi = TestDataFactory.createProductItem();
        pi.Serialized_Item__c = asset.Id;
        insert pi;

        Entitlement entitlement = TestDataFactory.createEntitlement(account.Id, oh.Id);
        insert entitlement;

        FSL__Polygon__c polygon = TestDataFactory.createPolygon(st.Id);
        //insert polygon;

        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.Latitude = 51.54312343707734;
        wo.Longitude = 5.1087930696021076;
        wo.ServiceTerritoryId = st.Id;
        wo.Delivery_Type__c = 'Welcome Model';
        // wo.Account_Treatment__c = accountTreatment.Id;
        wo.Pricebook2Id = Test.getStandardPricebookId();
        wo.LocationId = location.Id;
        wo.AccountId = account.Id;
        insert wo;

        WorkOrderLineItem WOLI = TestDataFactory.createWOLI(wo.Id, pe.Id);
        WOLI.Status = 'Nuovo';   // TO CHANGE: 'New'
        WOLI.QuantityDelivered__c = 2;
        WOLI.AssetId = asset.Id;
        WOLI.Serial_Number__c = 'TestSerialNumber';
        WOLI.Batch_Number__c = '2';
        insert WOLI;

        wo.Latitude = 52.54312343707734;
        wo.ServiceTerritoryId = st2.Id;
        wo.Status = 'Completed';
        wo.Delivery_Type__c = 'Currier';
        Test.startTest();

        Database.SaveResult result = Database.update(wo);

        Test.stopTest();

        List<Product_Asset_Patient_History__c> PAPHs = [SELECT Id FROM Product_Asset_Patient_History__c];
        List<ProductTransfer> productTransfers = [SELECT Id FROM ProductTransfer];
        List<Asset> assets = [SELECT Id, AssetServicedById, Account_Treatment__c FROM Asset];

        System.assert(result.isSuccess());
        System.assert(PAPHs.size() == 0);
        System.assert(productTransfers.size() > 0);

        System.assertEquals(assets[0].AssetServicedById, account.Id);
        System.assertEquals(assets[0].Account_Treatment__c, null);
    }

    @isTest
    static void updateNoAssetIdTest() {
        RecordType therapyRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'AccountTreatment_Therapy'];

        Schema.Location location = TestDataFactory.createLocation();
        location.IsInventoryLocation = true;
        insert location;

        Product2 product = TestDataFactory.createProduct();
        insert product;

        PricebookEntry pe = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pe;

        OperatingHours oh = TestDataFactory.createOperatingHours();
        insert oh;

        ServiceTerritory st = TestDataFactory.createServiceTerritory(oh.Id, true);
        insert st;

        ServiceTerritory st2 = TestDataFactory.createServiceTerritory(oh.Id, true);
        st2.Name = 'Test ServiceTerritory 2';
        insert st2;

        Account account = TestDataFactory.createPersonAccount();
        account.DefaultTrainingServiceTerritory__c = st.Id;
        insert account;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        accountTreatment.RecordTypeId = therapyRT.Id;
        insert accountTreatment;

        Asset asset = TestDataFactory.createAsset(account.Id);
        asset.LocationId = location.Id;
        insert asset;

        ProductItem pi = TestDataFactory.createProductItem();
        pi.Serialized_Item__c = asset.Id;
        pi.BatchNumber__c = '2';
        pi.LocationId = location.Id;
        pi.Product2Id = product.Id;
        insert pi;

        System.debug('--- PRODUCT ITEM ---');
        System.debug('pi.Serialized_Item__c: ' + pi.Serialized_Item__c);
        System.debug('pi.BatchNumber__c: ' + pi.BatchNumber__c);
        System.debug('pi.LocationId: ' + pi.LocationId);
        System.debug('pi.Product2Id: ' + pi.Product2Id);

        Entitlement entitlement = TestDataFactory.createEntitlement(account.Id, oh.Id);
        insert entitlement;

        FSL__Polygon__c polygon = TestDataFactory.createPolygon(st.Id);
        //insert polygon;

        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.Latitude = 51.54312343707734;
        wo.Longitude = 5.1087930696021076;
        wo.ServiceTerritoryId = st.Id;
        wo.Delivery_Type__c = 'Welcome Model';
        // wo.Account_Treatment__c = accountTreatment.Id;
        wo.Pricebook2Id = Test.getStandardPricebookId();
        wo.LocationId = location.Id;
        wo.AccountId = account.Id;
        insert wo;

        WorkOrderLineItem WOLI = TestDataFactory.createWOLI(wo.Id, pe.Id);
        WOLI.Status = 'Nuovo';   // TO CHANGE: 'New'
        WOLI.QuantityDelivered__c = 2;
        WOLI.Batch_Number__c = '2';
        /* WOLI.AssetId = asset.Id;
        WOLI.Serial_Number__c = 'TestSerialNumber'; */
        insert WOLI;

        wo.Latitude = 52.54312343707734;
        wo.ServiceTerritoryId = st2.Id;
        wo.Status = 'Completed';
        wo.Delivery_Type__c = 'Currier';
        Test.startTest();

        Database.SaveResult result = Database.update(wo);

        Test.stopTest();

        List<Product_Asset_Patient_History__c> PAPHs = [SELECT Id FROM Product_Asset_Patient_History__c];
        List<ProductTransfer> productTransfers = [SELECT Id FROM ProductTransfer];
        List<Asset> assets = [SELECT Id, AssetServicedById, Account_Treatment__c FROM Asset];

        System.assert(result.isSuccess());
        System.assert(PAPHs.size() == 0);
        System.assert(productTransfers.size() == 0);

        System.assertEquals(assets[0].AssetServicedById, null);
        System.assertEquals(assets[0].Account_Treatment__c, null);
    }

    @isTest
    static void updateNoBatchNumberTest() {
        RecordType therapyRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'AccountTreatment_Therapy'];

        Schema.Location location = TestDataFactory.createLocation();
        location.IsInventoryLocation = true;
        insert location;

        Schema.Location location2 = TestDataFactory.createLocation();
        location2.IsInventoryLocation = true;
        insert location2;

        Product2 product = TestDataFactory.createProduct();
        insert product;

        PricebookEntry pe = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pe;

        OperatingHours oh = TestDataFactory.createOperatingHours();
        insert oh;

        ServiceTerritory st = TestDataFactory.createServiceTerritory(oh.Id, true);
        insert st;

        ServiceTerritory st2 = TestDataFactory.createServiceTerritory(oh.Id, true);
        st2.Name = 'Test ServiceTerritory 2';
        insert st2;

        Account account = TestDataFactory.createPersonAccount();
        account.DefaultTrainingServiceTerritory__c = st.Id;
        insert account;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        accountTreatment.RecordTypeId = therapyRT.Id;
        insert accountTreatment;

        Asset asset = TestDataFactory.createAsset(account.Id);
        asset.LocationId = location.Id;
        insert asset;

        ProductItem pi = TestDataFactory.createProductItem();
        pi.Serialized_Item__c = asset.Id;
        // pi.BatchNumber__c = '2';
        pi.LocationId = location2.Id;
        pi.Product2Id = product.Id;
        insert pi;

        System.debug('--- PRODUCT ITEM ---');
        System.debug('pi.Serialized_Item__c: ' + pi.Serialized_Item__c);
        System.debug('pi.BatchNumber__c: ' + pi.BatchNumber__c);
        System.debug('pi.LocationId: ' + pi.LocationId);
        System.debug('pi.Product2Id: ' + pi.Product2Id);

        Entitlement entitlement = TestDataFactory.createEntitlement(account.Id, oh.Id);
        insert entitlement;

        FSL__Polygon__c polygon = TestDataFactory.createPolygon(st.Id);
        //insert polygon;

        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.Latitude = 51.54312343707734;
        wo.Longitude = 5.1087930696021076;
        wo.ServiceTerritoryId = st.Id;
        wo.Delivery_Type__c = 'Welcome Model';
        // wo.Account_Treatment__c = accountTreatment.Id;
        wo.Pricebook2Id = Test.getStandardPricebookId();
        wo.LocationId = location.Id;
        wo.AccountId = account.Id;
        insert wo;

        WorkOrderLineItem WOLI = TestDataFactory.createWOLI(wo.Id, pe.Id);
        WOLI.Status = 'Nuovo';   // TO CHANGE: 'New'
        WOLI.QuantityDelivered__c = 2;
        // WOLI.Batch_Number__c = '2';
        /* WOLI.AssetId = asset.Id;
        WOLI.Serial_Number__c = 'TestSerialNumber'; */
        insert WOLI;

        wo.Latitude = 52.54312343707734;
        wo.ServiceTerritoryId = st2.Id;
        wo.Status = 'Completed';
        wo.Delivery_Type__c = 'Currier';
        Test.startTest();

        Database.SaveResult result = Database.update(wo);

        Test.stopTest();

        List<Product_Asset_Patient_History__c> PAPHs = [SELECT Id FROM Product_Asset_Patient_History__c];
        List<ProductTransfer> productTransfers = [SELECT Id FROM ProductTransfer];
        List<Asset> assets = [SELECT Id, AssetServicedById, Account_Treatment__c FROM Asset];

        System.assert(result.isSuccess());
        System.assert(PAPHs.size() == 0);
        System.assert(productTransfers.size() == 0);

        System.assertEquals(assets[0].AssetServicedById, null);
        System.assertEquals(assets[0].Account_Treatment__c, null);
    }

    @isTest
    static void updateNoBatchNumberWithATTest() {
        RecordType therapyRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'AccountTreatment_Therapy'];

        Schema.Location location = TestDataFactory.createLocation();
        location.IsInventoryLocation = true;
        insert location;

        Schema.Location location2 = TestDataFactory.createLocation();
        location2.IsInventoryLocation = true;
        insert location2;

        Product2 product = TestDataFactory.createProduct();
        insert product;

        PricebookEntry pe = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pe;

        OperatingHours oh = TestDataFactory.createOperatingHours();
        insert oh;

        ServiceTerritory st = TestDataFactory.createServiceTerritory(oh.Id, true);
        insert st;

        ServiceTerritory st2 = TestDataFactory.createServiceTerritory(oh.Id, true);
        st2.Name = 'Test ServiceTerritory 2';
        insert st2;

        Account account = TestDataFactory.createPersonAccount();
        account.DefaultTrainingServiceTerritory__c = st.Id;
        insert account;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        accountTreatment.RecordTypeId = therapyRT.Id;
        insert accountTreatment;

        Asset asset = TestDataFactory.createAsset(account.Id);
        asset.LocationId = location.Id;
        insert asset;

        ProductItem pi = TestDataFactory.createProductItem();
        pi.Serialized_Item__c = asset.Id;
        // pi.BatchNumber__c = '2';
        pi.LocationId = location2.Id;
        pi.Product2Id = product.Id;
        insert pi;

        System.debug('--- PRODUCT ITEM ---');
        System.debug('pi.Serialized_Item__c: ' + pi.Serialized_Item__c);
        System.debug('pi.BatchNumber__c: ' + pi.BatchNumber__c);
        System.debug('pi.LocationId: ' + pi.LocationId);
        System.debug('pi.Product2Id: ' + pi.Product2Id);

        Entitlement entitlement = TestDataFactory.createEntitlement(account.Id, oh.Id);
        insert entitlement;

        FSL__Polygon__c polygon = TestDataFactory.createPolygon(st.Id);
        //insert polygon;

        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.Latitude = 51.54312343707734;
        wo.Longitude = 5.1087930696021076;
        wo.ServiceTerritoryId = st.Id;
        wo.Delivery_Type__c = 'Welcome Model';
        wo.Account_Treatment__c = accountTreatment.Id;
        wo.Pricebook2Id = Test.getStandardPricebookId();
        wo.LocationId = location.Id;
        wo.AccountId = account.Id;
        insert wo;

        WorkOrderLineItem WOLI = TestDataFactory.createWOLI(wo.Id, pe.Id);
        WOLI.Status = 'Nuovo';   // TO CHANGE: 'New'
        WOLI.QuantityDelivered__c = 2;
        // WOLI.Batch_Number__c = '2';
        /* WOLI.AssetId = asset.Id;
        WOLI.Serial_Number__c = 'TestSerialNumber'; */
        insert WOLI;

        wo.Latitude = 52.54312343707734;
        wo.ServiceTerritoryId = st2.Id;
        wo.Status = 'Completed';
        wo.Delivery_Type__c = 'Currier';
        Test.startTest();

        Database.SaveResult result = Database.update(wo);

        Test.stopTest();

        List<Product_Asset_Patient_History__c> PAPHs = [SELECT Id, Name, Account_Treatment__c, Account__c FROM Product_Asset_Patient_History__c];
        List<ProductTransfer> productTransfers = [SELECT Id FROM ProductTransfer];
        List<Asset> assets = [SELECT Id, AssetServicedById, Account_Treatment__c FROM Asset];

        System.assert(result.isSuccess());
        System.assert(PAPHs.size() > 0);
        System.debug('----------- NEW PAPH: ' + PAPHs[0]);
        System.assert(productTransfers.size() == 0);

        System.assertEquals(assets[0].AssetServicedById, null);
        System.assertEquals(assets[0].Account_Treatment__c, null);
    }

    @isTest
    static void dependentActivitiesSchedulingTest() {
        RecordType therapyAT = [SELECT Id FROM RecordType WHERE DeveloperName = 'AccountTreatment_Therapy'];
        Account_Treatment__c accountTreatment = TestDataFactory.createAccountTreatmentWithJobFull();
        accountTreatment.RecordTypeId = therapyAT.Id;
        update accountTreatment;

        Contract_Framework__c contractFramework = [SELECT Id FROM Contract_Framework__c LIMIT 1];
        contractFramework.Price_list_code__c = Test.getStandardPricebookId();
        update contractFramework;

        Contract_Treatment__c contractTreatment = [SELECT Id FROM Contract_Treatment__c WHERE Contract_Framework__c =: contractFramework.Id LIMIT 1];

        Product2 product = TestDataFactory.createProduct();
        product.Type__c = 'ZJOB';
        product.Product_Code__c = 'testProductCode';
        insert product;

        Product2 product2 = TestDataFactory.createProduct();
        insert product2;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product2.Id);
        insert pricebookEntry;

        Corporate_Treatment_Job__c corporateTreatmentJob = TestDataFactory.createCorporateTJ();
        insert corporateTreatmentJob;

        Contract_Treatment_Job__c contractTreatmentJob = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        contractTreatmentJob.Contract_Framework__c = contractFramework.Id;
        contractTreatmentJob.Corporate_Treatment_Job__c = corporateTreatmentJob.Id;
        contractTreatmentJob.Contract_Treatment_Job_Code__c = product.Id;
        insert contractTreatmentJob;

        Contract_Treatment_Job_SLA__c SLA = TestDataFactory.createFullCalendarSLA(contractTreatmentJob.Id);
        SLA.Max_Time__c = 1;
        insert SLA;

        Account account = [SELECT Id FROM Account LIMIT 1];

        Account_Treatment_Job__c accountTreatmentJob = [SELECT Id, Work_Order__c, Task__c, Task_Type__c FROM Account_Treatment_Job__c LIMIT 1];
        accountTreatmentJob.Work_Order__c = true;
        accountTreatmentJob.Task__c = true;
        accountTreatmentJob.Task_Type__c = 'Call';
        update accountTreatmentJob;

        Account_Treatment_Job__c dependentATJ = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        dependentATJ.Scheduling_Rule__c = 'Dependent Job Execution';
        dependentATJ.Account_Treatment_Job__c = accountTreatmentJob.Id;
        dependentATJ.Contract_Treatment_Job__c = contractTreatmentJob.Id;
        dependentATJ.Work_Order__c = true;
        dependentATJ.Task__c = true;
        dependentATJ.Task_Type__c = 'Call';
        dependentATJ.Frequency__c = 1;
        dependentATJ.Frequency_Unit_of_measure__c = 'Month';
        dependentATJ.Scheduling_Time_Frame__c = 365;
        dependentATJ.Frequency_Type__c = 'NPU';
        insert dependentATJ;

        /* Account_Treatment_Job_Product__c ATJP = TestDataFactory.createATJP(dependentATJ.Id);
        ATJP.Product__c = product2.Id;
        insert ATJP; */

        Test.startTest();

        Case c = TestDataFactory.createCase();
        c.Account_Treatment__c = accountTreatment.Id;
        c.AccountId = account.Id;
        c.Account_Treatment_Job__c = accountTreatmentJob.Id;
        c.External_Id__c = 'C_EXT_111';
        insert c;

        WorkOrder workOrder = TestDataFactory.createWorkOrder();
        workOrder.CaseId = c.Id;
        workOrder.Account_Treatment__c = accountTreatment.Id;
        workOrder.Account_Treatment_Job__c = accountTreatmentJob.Id;
        insert workOrder;

        workOrder.EndDate = Datetime.now();
        workOrder.Status = 'Completed';

        Database.SaveResult result = Database.update(workOrder);

        Test.stopTest();

        List<Case> cases = [SELECT Id FROM Case WHERE Id !=: c.Id];
        List<WorkOrder> workOrders = [SELECT Id FROM WorkOrder WHERE Id !=: workOrder.Id];
        List<Task> tasks = [SELECT Id FROM Task];

        System.assert(result.isSuccess());
        System.assert(cases.size() > 1);
        System.assert(workOrders.size() > 1);
        System.assert(tasks.size() > 1);
    }

    @isTest
    static void canceledTestPart1() {
        List<WorkOrder> workOrdersToInsert = new List<WorkOrder>();
        List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>();
        List<WorkOrderLineItem> WOLIsToInsert = new List<WorkOrderLineItem>();
        List<Asset> assetsToInsert = new List<Asset>();
        List<Product2> productsToInsert = new List<Product2>();
        List<PricebookEntry> pricebookEntriesToInsert = new List<PricebookEntry>();
        List<ProductItem> productItemsToInsert = new List<ProductItem>();
        List<Schema.Location> locationsToInsert = new List<Schema.Location>();

        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Schema.Location inventory = TestDataFactory.createLocation();
        inventory.IsInventoryLocation = true;
        locationsToInsert.add(inventory);

        Schema.Location van = TestDataFactory.createLocation();
        van.LocationType = 'Van';
        van.IsInventoryLocation = true;
        locationsToInsert.add(van);

        insert locationsToInsert;

        //Account_Treatment__c accountTreatment = TestDataFactory.createAccountTreatmentWithJobFull();
        Account_Treatment__c accountTreatment = new Account_Treatment__c(Account__c = account.Id);
        insert accountTreatment;

        // WorkOrders

        WorkOrder workOrder = TestDataFactory.createWorkOrder();
        workOrder.Status = 'In progress';
        workOrder.Pricebook2Id = Test.getStandardPricebookId();
        workOrder.Delivery_Type__c = 'Home Visit';
        workOrder.Account_Treatment__c = accountTreatment.Id;
        workOrder.LocationId = inventory.Id;
        workOrder.Source_Location__c = van.Id;
        workOrdersToInsert.add(workOrder);

        WorkOrder workOrder1 = TestDataFactory.createWorkOrder();
        workOrder1.Status = 'In progress';
        workOrder1.Pricebook2Id = Test.getStandardPricebookId();
        workOrder1.Delivery_Type__c = 'Home Visit';
        workOrder1.Account_Treatment__c = accountTreatment.Id;
        workOrder1.Document_Type__c = 'ZRET';
        workOrder1.LocationId = inventory.Id;
        workOrder1.Source_Location__c = van.Id;
        workOrdersToInsert.add(workOrder1);

        insert workOrdersToInsert;

        // Products

        Product2 product = TestDataFactory.createProduct();
        product.Type__c = 'ZSRT';
        productsToInsert.add(product);

        Product2 product1 = TestDataFactory.createProduct();
        product1.Type__c = 'ZSRT';
        productsToInsert.add(product1);

        Product2 product2 = TestDataFactory.createProduct();
        product2.Type__c = 'ZSRT';
        productsToInsert.add(product2);

        Product2 product3 = TestDataFactory.createProduct();
        product3.Type__c = 'ZSRT';
        productsToInsert.add(product3);

        Product2 product4 = TestDataFactory.createProduct();
        product4.Type__c = 'ZSRT';
        productsToInsert.add(product4);

        Product2 product5 = TestDataFactory.createProduct();
        product5.Type__c = 'ZSRT';
        productsToInsert.add(product5);

        insert productsToInsert;

        // PricebookEntries

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        pricebookEntriesToInsert.add(pricebookEntry);

        PricebookEntry pricebookEntry1 = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product1.Id);
        pricebookEntriesToInsert.add(pricebookEntry1);

        PricebookEntry pricebookEntry2 = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product2.Id);
        pricebookEntriesToInsert.add(pricebookEntry2);

        PricebookEntry pricebookEntry3 = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product3.Id);
        pricebookEntriesToInsert.add(pricebookEntry3);

        PricebookEntry pricebookEntry4 = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product5.Id);
        pricebookEntriesToInsert.add(pricebookEntry4);

        insert pricebookEntriesToInsert;

        // Assets

        Asset asset = TestDataFactory.createAsset(account.Id);
        asset.Product2Id = product.Id;
        asset.SerialNumber = 'X12345Y';
        asset.LocationId = inventory.Id;
        assetsToInsert.add(asset);

        Asset asset1 = TestDataFactory.createAsset(account.Id);
        asset1.Product2Id = product1.Id;
        asset1.SerialNumber = 'X12346Y';
        asset1.LocationId = inventory.Id;
        assetsToInsert.add(asset1);

        Asset asset2 = TestDataFactory.createAsset(account.Id);
        asset2.Product2Id = product5.Id;
        asset2.Equipment_Key__c = 'equipmentKey';
        asset2.SerialNumber = 'X12347Y';
        asset2.LocationId = inventory.Id;
        assetsToInsert.add(asset2);

        insert assetsToInsert;

        // ProductItems

        Test.startTest();
        ProductItem productItem = TestDataFactory.createProductItem();
        productItem.Serialized_Item__c = asset.Id;
        productItemsToInsert.add(productItem);

        ProductItem productItem1 = TestDataFactory.createProductItem();
        productItem1.Serialized_Item__c = asset1.Id;
        productItemsToInsert.add(productItem1);

        ProductItem productItem2 = TestDataFactory.initProductItem(product2, inventory);
        productItem2.BatchNumber__c = '1';
        productItem2.Product2Id = product2.Id;
        productItem2.LocationId = inventory.Id;
        productItem2.QuantityOnHand = 2;
        productItemsToInsert.add(productItem2);

        ProductItem productItem3 = TestDataFactory.initProductItem(product3, inventory);
        productItem3.BatchNumber__c = '1';
        productItem3.Product2Id = product3.Id;
        productItem3.LocationId = inventory.Id;
        productItem3.QuantityOnHand = 2;
        productItemsToInsert.add(productItem3);

        ProductItem vanProductItem3 = TestDataFactory.initProductItem(product4, van);
        vanProductItem3.BatchNumber__c = '1';
        vanProductItem3.Product2Id = product4.Id;
        vanProductItem3.LocationId = van.Id;
        vanProductItem3.QuantityOnHand = 2;
        vanProductItem3.HU__c = 'handlingUnit';
        productItemsToInsert.add(vanProductItem3);

        ProductItem productItem4 = TestDataFactory.initProductItem(product5, inventory);
        productItem4.BatchNumber__c = '1';
        productItem4.Product2Id = product5.Id;
        productItem4.LocationId = inventory.Id;
        productItem4.QuantityOnHand = 2;
        productItem4.RelatedContainer__c = asset2.Id;
        productItemsToInsert.add(productItem4);


        insert productItemsToInsert;

        // WOLIs

        WorkOrderLineItem WOLI = TestDataFactory.createWOLI(workOrder.Id, pricebookEntry.Id);
        WOLI.AssetId = asset.Id;
        WOLI.Status = 'Completed';
        WOLI.Serial_Number__c = 'X12345';
        WOLI.HU__c = 'handlingUnit';
        WOLI.Movement_Type__c = 'Delivery (+)';
        WOLI.QuantityDelivered__c = 1;
        WOLIsToInsert.add(WOLI);

        WorkOrderLineItem WOLI1 = TestDataFactory.createWOLI(workOrder1.Id, pricebookEntry1.Id);
        WOLI1.AssetId = asset1.Id;
        WOLI1.Status = 'Completed';
        WOLI1.Serial_Number__c = 'X12345';
        WOLI1.HU__c = 'handlingUnit';
        WOLI1.Movement_Type__c = 'Removal (-)';
        WOLIsToInsert.add(WOLI1);

        WorkOrderLineItem WOLI2 = TestDataFactory.createWOLI(workOrder.Id, pricebookEntry2.Id);
        WOLI2.Status = 'Completed';
        WOLI2.Batch_Number__c = '1';
        WOLI2.Movement_Type__c = 'Delivery (+)';
        WOLI2.QuantityDelivered__c = 1;
        WOLIsToInsert.add(WOLI2);

        WorkOrderLineItem WOLI3 = TestDataFactory.createWOLI(workOrder.Id, pricebookEntry3.Id);
        WOLI3.Status = 'Completed';
        WOLI3.Batch_Number__c = '1';
        WOLI3.Movement_Type__c = 'Delivery (+)';
        WOLI3.QuantityDelivered__c = 1;
        WOLI3.HU__c = 'handlingUnit';
        WOLIsToInsert.add(WOLI3);

        WorkOrderLineItem WOLI4 = TestDataFactory.createWOLI(workOrder.Id, pricebookEntry4.Id);
        WOLI4.Status = 'Completed';
        WOLI4.Batch_Number__c = '1';
        WOLI4.Movement_Type__c = 'Delivery (+)';
        WOLI4.QuantityDelivered__c = 1;
        WOLI4.HU__c = 'handlingUnit';
        WOLI4.Related_Equipment_Key__c = 'equipmentKey';
        WOLIsToInsert.add(WOLI4);

        WorkOrderLineItem WOLI5 = TestDataFactory.createWOLI(workOrder1.Id, pricebookEntry1.Id);
        WOLI5.Status = 'Completed';
        WOLI5.QuantityDelivered__c = 1;
        WOLI5.Batch_Number__c = '1';
        WOLI5.Movement_Type__c = 'Removal (-)';
        WOLIsToInsert.add(WOLI5);

        insert WOLIsToInsert;

        OperatingHours operatingHours = TestDataFactory.createOperatingHours();
        insert operatingHours;

        ServiceTerritory serviceTerritory = TestDataFactory.createServiceTerritory(operatingHours.Id, true);
        insert serviceTerritory;

        ServiceAppointment serviceAppointment = TestDataFactory.createServiceAppointment(workOrder.Id, serviceTerritory.Id, 'None');
        insert serviceAppointment;

        workOrder.Status = 'Canceled';
        workOrder1.Status = 'Canceled';

        workOrdersToUpdate.add(workOrder);
        workOrdersToUpdate.add(workOrder1);

        List<Database.SaveResult> results = Database.update(workOrdersToUpdate);

        Test.stopTest();

        ServiceAppointment queriedSA = [SELECT Status FROM ServiceAppointment WHERE Id =: serviceAppointment.Id];
        List<ProductTransfer> productTransfers = [SELECT Id FROM ProductTransfer];

        for(Database.SaveResult result : results) {
            System.assert(result.isSuccess());
        }
        System.assertEquals('Canceled', queriedSA.Status);
        System.assertEquals(2, productTransfers.size());
    }

    @isTest
    static void canceledTestPart2() {
        List<WorkOrder> workOrdersToInsert = new List<WorkOrder>();
        List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>();
        List<WorkOrderLineItem> WOLIsToInsert = new List<WorkOrderLineItem>();
        List<Asset> assetsToInsert = new List<Asset>();
        List<Product2> productsToInsert = new List<Product2>();
        List<PricebookEntry> pricebookEntriesToInsert = new List<PricebookEntry>();
        List<ProductItem> productItemsToInsert = new List<ProductItem>();
        List<Schema.Location> locationsToInsert = new List<Schema.Location>();
        List<String> productItemIds = new List<String>();

        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Schema.Location inventory = TestDataFactory.createLocation();
        inventory.IsInventoryLocation = true;
        locationsToInsert.add(inventory);

        Schema.Location van = TestDataFactory.createLocation();
        van.LocationType = 'Van';
        van.IsInventoryLocation = true;
        locationsToInsert.add(van);

        insert locationsToInsert;

        //Account_Treatment__c accountTreatment = TestDataFactory.createAccountTreatmentWithJobFull();
        Account_Treatment__c accountTreatment = new Account_Treatment__c(Account__c = account.Id);
        insert accountTreatment;

        // WorkOrders

        WorkOrder workOrder = TestDataFactory.createWorkOrder();
        workOrder.Status = 'In progress';
        workOrder.Pricebook2Id = Test.getStandardPricebookId();
        workOrder.Delivery_Type__c = 'Home Visit';
        workOrder.Account_Treatment__c = accountTreatment.Id;
        workOrder.LocationId = inventory.Id;
        workOrder.Source_Location__c = van.Id;
        workOrdersToInsert.add(workOrder);

        WorkOrder workOrder1 = TestDataFactory.createWorkOrder();
        workOrder1.Status = 'In progress';
        workOrder1.Pricebook2Id = Test.getStandardPricebookId();
        workOrder1.Delivery_Type__c = 'Home Visit';
        workOrder1.Account_Treatment__c = accountTreatment.Id;
        workOrder1.Document_Type__c = 'ZRET';
        workOrder1.LocationId = inventory.Id;
        workOrder1.Source_Location__c = van.Id;
        workOrdersToInsert.add(workOrder1);

        insert workOrdersToInsert;

        // Products

        Product2 product = TestDataFactory.createProduct();
        product.Type__c = 'ZSRT';
        productsToInsert.add(product);

        Product2 product1 = TestDataFactory.createProduct();
        product1.Type__c = 'ZSRT';
        productsToInsert.add(product1);

        Product2 product2 = TestDataFactory.createProduct();
        product2.Type__c = 'ZSRT';
        productsToInsert.add(product2);

        Product2 product3 = TestDataFactory.createProduct();
        product3.Type__c = 'ZSRT';
        productsToInsert.add(product3);

        insert productsToInsert;

        // PricebookEntries

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        pricebookEntriesToInsert.add(pricebookEntry);

        PricebookEntry pricebookEntry1 = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product1.Id);
        pricebookEntriesToInsert.add(pricebookEntry1);

        PricebookEntry pricebookEntry2 = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product2.Id);
        pricebookEntriesToInsert.add(pricebookEntry2);

        PricebookEntry pricebookEntry3 = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product3.Id);
        pricebookEntriesToInsert.add(pricebookEntry3);

        insert pricebookEntriesToInsert;

        // Assets

        Asset asset = TestDataFactory.createAsset(account.Id);
        asset.Product2Id = product.Id;
        asset.Equipment_Key__c = 'equipmentKey';
        asset.LocationId = inventory.Id;
        assetsToInsert.add(asset);

        insert assetsToInsert;

        // ProductItems

        ProductItem productItem = TestDataFactory.createProductItem();
        productItem.BatchNumber__c = '1';
        productItem.Product2Id = product.Id;
        productItem.Locationid = inventory.Id;
        productItem.QuantityOnHand = 2;
        productItem.RelatedContainer__c = asset.Id;
        productItemsToInsert.add(productItem);

        ProductItem productItem1 = TestDataFactory.createProductItem();
        productItem1.Product2Id = product1.Id;
        productItem1.Locationid = inventory.Id;
        productItem1.QuantityOnHand = 2;
        productItemsToInsert.add(productItem1);

        ProductItem productItem2 = TestDataFactory.createProductItem();
        productItem2.Product2Id = product2.Id;
        productItem2.Locationid = inventory.Id;
        productItem2.QuantityOnHand = 2;
        productItem2.HU__c = 'handlingUnit';
        productItemsToInsert.add(productItem2);

        ProductItem productItem3 = TestDataFactory.createProductItem();
        productItem3.Product2Id = product3.Id;
        productItem3.Locationid = inventory.Id;
        productItem3.QuantityOnHand = 2;
        productItemsToInsert.add(productItem3);

        insert productItemsToInsert;

        for(ProductItem pi : productItemsToInsert) {
            productItemIds.add(pi.Id);
        }

        // WOLIs

        WorkOrderLineItem WOLI = TestDataFactory.createWOLI(workOrder.Id, pricebookEntry.Id);
        WOLI.Status = 'Completed';
        WOLI.QuantityDelivered__c = 1;
        WOLI.Movement_Type__c = 'Delivery (+)';
        WOLI.Batch_Number__c = '1';
        WOLI.AssetId = asset.Id;
        WOLI.Related_Equipment_Key__c = 'equipmentKey';
        WOLI.Equipment_Key_Tank__c = 'equipmentKeyTank';
        WOLIsToInsert.add(WOLI);

        WorkOrderLineItem WOLI1 = TestDataFactory.createWOLI(workOrder.Id, pricebookEntry1.Id);
        WOLI1.Status = 'Completed';
        WOLI1.QuantityDelivered__c = 1;
        WOLI1.Movement_Type__c = 'Delivery (+)';
        WOLIsToInsert.add(WOLI1);

        WorkOrderLineItem WOLI2 = TestDataFactory.createWOLI(workOrder.Id, pricebookEntry2.Id);
        WOLI2.Status = 'Completed';
        WOLI2.QuantityDelivered__c = 1;
        WOLI2.Movement_Type__c = 'Delivery (+)';
        WOLI2.HU__c = 'handlingUnit';
        WOLIsToInsert.add(WOLI2);

        WorkOrderLineItem WOLI3 = TestDataFactory.createWOLI(workOrder1.Id, pricebookEntry3.Id);
        WOLI3.Status = 'Completed';
        WOLI3.QuantityDelivered__c = 1;
        WOLI3.Movement_Type__c = 'Removal (-)';
        WOLIsToInsert.add(WOLI3);

        Test.startTest();

        insert WOLIsToInsert;

        workOrder.Status = 'Canceled';
        workOrder1.Status = 'Canceled';

        workOrdersToUpdate.add(workOrder);
        workOrdersToUpdate.add(workOrder1);

        List<Database.SaveResult> results = Database.update(workOrdersToUpdate);

        Test.stopTest();

        List<ProductItem> productItems = [SELECT Id FROM ProductItem WHERE Id NOT IN: productItemIds];

        for(Database.SaveResult result : results) {
            System.assert(result.isSuccess());
        }
        System.assert(productItems.size() > 0);
    }

    @isTest
    static void canceledTestPart3() {
        List<WorkOrder> workOrdersToInsert = new List<WorkOrder>();
        List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>();
        List<WorkOrderLineItem> WOLIsToInsert = new List<WorkOrderLineItem>();
        List<Asset> assetsToInsert = new List<Asset>();
        List<Product2> productsToInsert = new List<Product2>();
        List<PricebookEntry> pricebookEntriesToInsert = new List<PricebookEntry>();
        List<ProductItem> productItemsToInsert = new List<ProductItem>();
        List<Schema.Location> locationsToInsert = new List<Schema.Location>();
        List<String> productItemIds = new List<String>();

        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Schema.Location inventory = TestDataFactory.createLocation();
        inventory.IsInventoryLocation = true;
        locationsToInsert.add(inventory);

        Schema.Location van = TestDataFactory.createLocation();
        van.LocationType = 'Van';
        van.IsInventoryLocation = true;
        locationsToInsert.add(van);

        Schema.Location storage = TestDataFactory.createLocation();
        storage.LocationType = 'Warehouse';
        storage.IsInventoryLocation = true;
        storage.Location_Id__c = 'test';
        storage.Sales_Org_Code__c = '6300';
        locationsToInsert.add(storage);

        insert locationsToInsert;

        Account_Treatment__c accountTreatment = TestDataFactory.createAccountTreatmentWithJobFull();

        // WorkOrders

        WorkOrder workOrder = TestDataFactory.createWorkOrder();
        workOrder.Status = 'New';
        workOrder.Pricebook2Id = Test.getStandardPricebookId();
        workOrder.Delivery_Type__c = 'Consignment Stock';
        workOrder.Account_Treatment__c = accountTreatment.Id;
        workOrder.LocationId = inventory.Id;
        workOrder.Source_Location__c = van.Id;
        workOrder.SAP_Storage_Location__c = storage.Id;
        workOrdersToInsert.add(workOrder);

        WorkOrder workOrder1 = TestDataFactory.createWorkOrder();
        workOrder1.Status = 'New';
        workOrder1.Pricebook2Id = Test.getStandardPricebookId();
        workOrder1.Delivery_Type__c = 'Consignment Stock';
        workOrder1.Account_Treatment__c = accountTreatment.Id;
        workOrder1.Document_Type__c = 'ZRET';
        workOrder1.LocationId = inventory.Id;
        workOrder1.Source_Location__c = van.Id;
        workOrder1.SAP_Storage_Location__c = storage.Id;
        workOrdersToInsert.add(workOrder1);

        WorkOrder workOrder2 = TestDataFactory.createWorkOrder();
        workOrder2.Status = 'New';
        workOrder2.Pricebook2Id = Test.getStandardPricebookId();
        workOrder2.Delivery_Type__c = 'Currier';
        workOrder2.Account_Treatment__c = accountTreatment.Id;
        workOrder2.LocationId = inventory.Id;
        workOrder2.Source_Location__c = van.Id;
        workOrder2.SAP_Storage_Location__c = storage.Id;
        workOrdersToInsert.add(workOrder2);

        WorkOrder workOrder3 = TestDataFactory.createWorkOrder();
        workOrder3.Status = 'New';
        workOrder3.Pricebook2Id = Test.getStandardPricebookId();
        workOrder3.Delivery_Type__c = 'Currier';
        workOrder3.Account_Treatment__c = accountTreatment.Id;
        workOrder3.Document_Type__c = 'ZRET';
        workOrder3.LocationId = inventory.Id;
        workOrder3.SAP_Storage_Location__c = storage.Id;
        workOrder3.Source_Location__c = van.Id;
        workOrdersToInsert.add(workOrder3);

        insert workOrdersToInsert;

        // Products

        Product2 product = TestDataFactory.createProduct();
        product.Type__c = 'ZSRT';
        productsToInsert.add(product);

        Product2 product1 = TestDataFactory.createProduct();
        product1.Type__c = 'ZSRT';
        productsToInsert.add(product1);

        Product2 product2 = TestDataFactory.createProduct();
        product2.Type__c = 'ZSRT';
        productsToInsert.add(product2);

        Product2 product3 = TestDataFactory.createProduct();
        product3.Type__c = 'ZSRT';
        productsToInsert.add(product3);

        insert productsToInsert;

        // PricebookEntries

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        pricebookEntriesToInsert.add(pricebookEntry);

        PricebookEntry pricebookEntry1 = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product1.Id);
        pricebookEntriesToInsert.add(pricebookEntry1);

        PricebookEntry pricebookEntry2 = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product2.Id);
        pricebookEntriesToInsert.add(pricebookEntry2);

        PricebookEntry pricebookEntry3 = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product3.Id);
        pricebookEntriesToInsert.add(pricebookEntry3);

        insert pricebookEntriesToInsert;


        // WOLIs

        WorkOrderLineItem WOLI = TestDataFactory.createWOLI(workOrder.Id, pricebookEntry.Id);
        WOLI.Status = 'Completed';
        WOLI.QuantityDelivered__c = 1;
        WOLI.Movement_Type__c = 'Delivery (+)';
        WOLI.Batch_Number__c = '1';
        WOLIsToInsert.add(WOLI);

        WorkOrderLineItem WOLI1 = TestDataFactory.createWOLI(workOrder.Id, pricebookEntry1.Id);
        WOLI1.Status = 'Completed';
        WOLI1.QuantityDelivered__c = 1;
        WOLI1.Movement_Type__c = 'Delivery (+)';
        WOLIsToInsert.add(WOLI1);

        WorkOrderLineItem WOLI2 = TestDataFactory.createWOLI(workOrder.Id, pricebookEntry2.Id);
        WOLI2.Status = 'Completed';
        WOLI2.QuantityDelivered__c = 1;
        WOLI2.Movement_Type__c = 'Delivery (+)';
        WOLI2.HU__c = 'handlingUnit';
        WOLIsToInsert.add(WOLI2);

        WorkOrderLineItem WOLI3 = TestDataFactory.createWOLI(workOrder1.Id, pricebookEntry3.Id);
        WOLI3.Status = 'Completed';
        WOLI3.QuantityDelivered__c = 1;
        WOLI3.Movement_Type__c = 'Removal (-)';
        WOLIsToInsert.add(WOLI3);

        WorkOrderLineItem WOLI4 = TestDataFactory.createWOLI(workOrder2.Id, pricebookEntry3.Id);
        WOLI4.Status = 'Completed';
        WOLI4.QuantityDelivered__c = 1;
        WOLI4.Movement_Type__c = 'Delivery (+)';
        WOLIsToInsert.add(WOLI4);

        WorkOrderLineItem WOLI5 = TestDataFactory.createWOLI(workOrder3.Id, pricebookEntry3.Id);
        WOLI5.Status = 'Completed';
        WOLI5.QuantityDelivered__c = 1;
        WOLI5.Movement_Type__c = 'Removal (-)';
        WOLIsToInsert.add(WOLI5);

        Test.startTest();

        insert WOLIsToInsert;

        workOrder.Status = 'Canceled';
        workOrder1.Status = 'Canceled';

        workOrdersToUpdate.add(workOrder);
        workOrdersToUpdate.add(workOrder1);

        List<Database.SaveResult> results = Database.update(workOrdersToUpdate);

        Test.stopTest();

        for(Database.SaveResult result : results) {
            System.assert(result.isSuccess());
        }
    }

    @isTest
    static void welcomeModelNewSTTest() {
        WorkOrder workOrder = TestDataFactory.createWorkOrder();
        workOrder.Delivery_Type__c = 'Welcome Model';
        insert workOrder;

        OperatingHours oh = TestDataFactory.createOperatingHours();
        insert oh;

        ServiceTerritory st = TestDataFactory.createServiceTerritory(oh.Id, true);
        st.Street = 'Via Torino';
        st.City = 'Milano';
        st.CountryCode = 'IT';
        insert st;

        workOrder.ServiceTerritoryId = st.Id;

        Test.startTest();

        Database.SaveResult result = Database.update(workOrder);

        Test.stopTest();

        WorkOrder queriedWorkOrder = [SELECT Street, City, CountryCode FROM WorkOrder WHERE Id =: workOrder.Id];

        System.assertEquals(st.Street, queriedWorkOrder.Street);
        System.assertEquals(st.City, queriedWorkOrder.City);
        System.assertEquals(st.CountryCode, queriedWorkOrder.CountryCode);
    }

    @isTest
    static void retrySAPSyncTest() {
        WorkOrder workOrder = TestDataFactory.createWorkOrder();
        workOrder.Delivery_Type__c = 'Welcome Model';
        insert workOrder;

        Test.startTest();

        WorkOrderService.retrySAPSync(new List<String>{workOrder.Id});

        Test.stopTest();
    }

    @isTest
    static void remoteCallInsertTest() {
        OperatingHours oh = TestDataFactory.createOperatingHours();
        insert oh;

        ServiceTerritory st = TestDataFactory.createServiceTerritory(oh.Id, true);
        st.Service_Territory_Code__c = '6300';
        st.Street = 'Via Torino';
        st.City = 'Milano';
        st.CountryCode = 'IT';
        insert st;

        WorkOrder workOrder = TestDataFactory.createWorkOrder();
        workOrder.Delivery_Type__c = 'Remote Call';
        workOrder.SalesOrganization__c = '6300';
        
        Test.startTest();

        Database.SaveResult result = Database.insert(workOrder);

        Test.stopTest();

        System.assert(result.isSuccess());
    }

    @isTest
    static void workTypeUpdateTest() {
        WorkType workType = new WorkType();
        workType.Name = 'TestWorkType';
        workType.EstimatedDuration = 8.0;
        workType.ShouldAutoCreateSvcAppt = true;
        insert workType;

        WorkOrder workOrder = TestDataFactory.createWorkOrder();
        workOrder.Delivery_Type__c = 'Remote Call';
        workOrder.SalesOrganization__c = '6300';
        insert workOrder;

        workOrder.WorkTypeId = workType.Id;

        Test.startTest();

        Database.SaveResult result = Database.update(workOrder);

        Test.stopTest();

        System.assert(result.isSuccess());
    }

    @isTest
    static void newLocationTest() {
        List<Schema.Location> locationsToInsert = new List<Schema.Location>();

        Schema.Location location = TestDataFactory.createLocation();
        locationsToInsert.add(location);

        insert locationsToInsert;

        WorkOrder workOrder = TestDataFactory.createWorkOrder();
        workOrder.Delivery_Type__c = 'Home Visit';
        workOrder.SalesOrganization__c = '6300';
        insert workOrder;

        workOrder.LocationId = location.Id;

        Test.startTest();

        Database.SaveResult result = Database.update(workOrder);

        Test.stopTest();

        System.assert(result.isSuccess());
    }

    @isTest
    static void assignedUpdateTest() {
        List<Schema.Location> locationsToInsert = new List<Schema.Location>();

        Product2 product = TestDataFactory.createProduct();
        product.Type__c = 'ZSRT';
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        Schema.Location storage = TestDataFactory.createLocation();
        storage.LocationType = 'Warehouse';
        storage.IsInventoryLocation = true;
        storage.Location_Id__c = 'test';
        storage.Sales_Org_Code__c = '6300';
        locationsToInsert.add(storage);

        Schema.Location plant = TestDataFactory.createLocation();
        plant.LocationType = 'Plant';
        plant.IsInventoryLocation = true;
        locationsToInsert.add(plant);

        insert locationsToInsert;

        OperatingHours oh = TestDataFactory.createOperatingHours();
        insert oh;

        ServiceTerritory st = TestDataFactory.createServiceTerritory(oh.Id, true);
        st.Stock__c = true;
        st.Plant__c = plant.Id;
        st.Warehouse__c = storage.Id;
        insert st;

        WorkOrder workOrder = TestDataFactory.createWorkOrder();
        workOrder.Delivery_Type__c = 'Welcome Model';
        workOrder.SalesOrganization__c = '6300';
        workOrder.Pricebook2Id = Test.getStandardPricebookId();
        workOrder.ServiceTerritoryId = st.Id;
        insert workOrder;

        WorkOrderLineItem WOLI = TestDataFactory.createWOLI(workOrder.Id, pricebookEntry.Id);
        WOLI.QuantityDelivered__c = 1;
        WOLI.Movement_Type__c = 'Delivery (+)';
        WOLI.Plant__c = plant.Id;
        WOLI.StorageLocation__c = storage.Id;
        insert WOLI;

        workOrder.Status = 'Assigned';

        Test.startTest();

        Database.SaveResult result = Database.update(workOrder);

        Test.stopTest();

        System.assert(result.isSuccess());
    }

    @isTest
    static void updateCaseStartDateTest() {
        Case c = TestDataFactory.createCase();
        c.External_Id__c = 'EXT_1_AAA';
        c.Start_Date__c = Date.today().addDays(2);
        insert c;

        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.CaseId = c.Id;
        wo.StartDate = Date.today().addDays(2);
        insert wo;

        WorkOrder wo1 = TestDataFactory.createWorkOrder();
        wo1.CaseId = c.Id;
        wo1.StartDate = Date.today().addDays(1);
        insert wo1;


        Task t = TestDataFactory.createTask();
        t.WhatId = c.Id;
        t.ActivityDate = Date.today().addDays(2);
        insert t;

        Test.startTest();

        wo.StartDate = Date.today();
        Database.SaveResult result = Database.update(wo);
        
        Test.stopTest();

        Case queriedCase = [SELECT Start_Date__c FROM Case WHERE Id =: c.Id];

        System.assert(result.isSuccess());
    } 

    // MISSING POLYGON PART, AUTOSCHEDULING FOR DEPENDENT JOBS PART AND REMOVAL PART
}