@isTest
public class TestCorporateTJPController {
    @isTest
    static void getCorporateTreatmentJobProductTest() {
        Pricebook2 pricebook = TestDataFactory.createPricebook();
        pricebook.IsActive = true;
        insert pricebook;

        Corporate_Treatment__c corporateTreatment = TestDataFactory.createCorporateTreatment();
        insert corporateTreatment;

        Corporate_Treatment_Job__c corporateTJ = TestDataFactory.createCorporateTJ();
        insert corporateTJ;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Price_list_code__c = pricebook.Id;
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        insert CTJ;

        Product2 family = TestDataFactory.createProduct();
        insert family;

        Product2 product = TestDataFactory.createProduct();
        product.Product_Family__c = family.Id;
        product.Product_Code__c = 'productCode';
        product.IsActive = true;
        insert product;

        Corporate_Treatment_Job_Product__c corporateTJP = new Corporate_Treatment_Job_Product__c(
            Product_Activities_Family__c = family.Id,
            Corporate_Treatment__c = corporateTreatment.Id,
            Corporate_Treatment_Job__c = corporateTJ.Id
        );
        insert corporateTJP;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        PricebookEntry pricebookEntry1 = TestDataFactory.createActivePricebookEntry(pricebook.Id, product.Id);
        insert pricebookEntry1;

        PricebookEntry pricebookEntry2 = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), family.Id);
        insert pricebookEntry2;

        Test.startTest();

        List<CorporateTreatmentJobProductDTO> dtoList = CorporateTreatmentJobProductController.getCorporateTreatmentJobProduct(
            corporateTreatment.Id, 
            corporateTJ.Id, 
            contractFramework.Id, 
            CTJ.Id, 
            '', 
            '', 
            new List<String>(), 
            new List<String>()
        );

        List<CorporateTreatmentJobProductDTO> dtoList1 = CorporateTreatmentJobProductController.getCorporateTreatmentJobProduct(
            corporateTreatment.Id, 
            corporateTJ.Id, 
            contractFramework.Id, 
            CTJ.Id, 
            'testSearch', 
            'testSearch', 
            new List<String>(), 
            new List<String>()
        );

        List<CorporateTreatmentJobProductDTO> dtoList2 = CorporateTreatmentJobProductController.getCorporateTreatmentJobProduct(
            corporateTreatment.Id, 
            corporateTJ.Id, 
            contractFramework.Id, 
            CTJ.Id, 
            '', 
            'productC', 
            new List<String>(), 
            new List<String>()
        );

        List<CorporateTreatmentJobProductDTO> dtoList3 = CorporateTreatmentJobProductController.getCorporateTreatmentJobProduct(
            corporateTreatment.Id, 
            corporateTJ.Id, 
            contractFramework.Id, 
            CTJ.Id, 
            'testSearch', 
            '', 
            new List<String>(), 
            new List<String>()
        );

        Test.stopTest();

        System.assertEquals(1, dtoList.size());
        System.assertEquals(0, dtoList1.size());
        System.assertEquals(1, dtoList2.size());
        System.assertEquals(0, dtoList3.size());
    }

    @isTest
    static void getProductTypesTest() {
        Test.startTest();

        List<ProductTypeDTO> productTypes = CorporateTreatmentJobProductController.getProductTypes();

        Test.stopTest();

        System.assert(productTypes.size() > 0);
    }

    @isTest
    static void createCTJPTest() {
        Pricebook2 pricebook = TestDataFactory.createPricebook();
        pricebook.IsActive = true;
        insert pricebook;

        Product2 family = TestDataFactory.createProduct();
        insert family;

        Product2 product = TestDataFactory.createProduct();
        product.Product_Family__c = family.Id;
        product.Product_Code__c = 'productCode';
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        PricebookEntry pricebookEntry1 = TestDataFactory.createActivePricebookEntry(pricebook.Id, product.Id);
        insert pricebookEntry1;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Price_list_code__c = pricebook.Id;
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        insert CTJ;

        Test.startTest();

        CorporateTreatmentJobProductController.createCTJP(new List<String>{product.Id}, CTJ.Id);

        Test.stopTest();

        List<Contract_Treatment_Job_Product__c> CTJPs = [SELECT Id FROM Contract_Treatment_Job_Product__c WHERE Contract_Treatment_Job__c =: CTJ.Id];
        List<Contract_Product_Limit__c> limits = [SELECT Id FROM Contract_Product_Limit__c WHERE Product__c =: product.Id AND Contract_Treatment__c =: contractTreatment.Id];

        System.assertEquals(1, CTJPs.size());
        System.assertEquals(1, limits.size());
    }

    @isTest
    static void getCTJPTest() {
        Pricebook2 pricebook = TestDataFactory.createPricebook();
        pricebook.IsActive = true;
        insert pricebook;

        Product2 family = TestDataFactory.createProduct();
        insert family;

        Product2 product = TestDataFactory.createProduct();
        product.Product_Family__c = family.Id;
        product.Product_Code__c = 'productCode';
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        PricebookEntry pricebookEntry1 = TestDataFactory.createActivePricebookEntry(pricebook.Id, product.Id);
        insert pricebookEntry1;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Price_list_code__c = pricebook.Id;
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        insert CTJ;

        Contract_Treatment_Job_Product__c CTJP = TestDataFactory.createCTJP(CTJ.Id);
        CTJP.Product__c = product.Id;
        insert CTJP;

        Test.startTest();

        List<CorporateTreatmentJobProductDTO> DTOs = CorporateTreatmentJobProductController.getCTJP(CTJ.Id, 'productC');

        Test.stopTest();

        System.assertEquals(1, DTOs.size());
    }

    @isTest
    static void getFamilyIdsTest() {
        Pricebook2 pricebook = TestDataFactory.createPricebook();
        pricebook.IsActive = true;
        insert pricebook;

        Product2 family = TestDataFactory.createProduct();
        insert family;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), family.Id);
        insert pricebookEntry;

        PricebookEntry pricebookEntry1 = TestDataFactory.createActivePricebookEntry(pricebook.Id, family.Id);
        insert pricebookEntry1;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Price_list_code__c = pricebook.Id;
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        insert CTJ;

        Contract_Treatment_Job_Product__c CTJP = TestDataFactory.createCTJP(CTJ.Id);
        CTJP.Product__c = family.Id;
        insert CTJP;

        Test.startTest();

        List<String> familyIds = CorporateTreatmentJobProductController.getFamilyIds(CTJ.Id);

        Test.stopTest();

        System.assertEquals(1, familyIds.size());
    }

    @isTest
    static void getProductIdsTest() {
        Pricebook2 pricebook = TestDataFactory.createPricebook();
        pricebook.IsActive = true;
        insert pricebook;

        Product2 family = TestDataFactory.createProduct();
        insert family;

        Product2 product = TestDataFactory.createProduct();
        product.Product_Family__c = family.Id;
        product.Product_Code__c = 'productCode';
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        PricebookEntry pricebookEntry1 = TestDataFactory.createActivePricebookEntry(pricebook.Id, product.Id);
        insert pricebookEntry1;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Price_list_code__c = pricebook.Id;
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        insert CTJ;

        Contract_Treatment_Job_Product__c CTJP = TestDataFactory.createCTJP(CTJ.Id);
        CTJP.Product__c = product.Id;
        insert CTJP;

        Test.startTest();

        List<String> productIds = CorporateTreatmentJobProductController.getProductIds(CTJ.Id);

        Test.stopTest();

        System.assertEquals(1, productIds.size());
    }

    @isTest
    static void deleteProductTest() {
        Pricebook2 pricebook = TestDataFactory.createPricebook();
        pricebook.IsActive = true;
        insert pricebook;

        Product2 family = TestDataFactory.createProduct();
        insert family;

        Product2 product = TestDataFactory.createProduct();
        product.Product_Family__c = family.Id;
        product.Product_Code__c = 'productCode';
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        PricebookEntry pricebookEntry1 = TestDataFactory.createActivePricebookEntry(pricebook.Id, product.Id);
        insert pricebookEntry1;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Price_list_code__c = pricebook.Id;
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        insert CTJ;

        Contract_Treatment_Job_Product__c CTJP = TestDataFactory.createCTJP(CTJ.Id);
        CTJP.Product__c = product.Id;
        insert CTJP;

        Test.startTest();

        CorporateTreatmentJobProductController.deleteProduct(CTJP.Id);

        Test.stopTest();

        List<Contract_Treatment_Job_Product__c> CTJPs = [SELECT Id FROM Contract_Treatment_Job_Product__c];

        System.assertEquals(0, CTJPs.size());
    }

    @isTest
    static void checkForCTJPActivationTest() {
        Pricebook2 pricebook = TestDataFactory.createPricebook();
        pricebook.IsActive = true;
        insert pricebook;

        Product2 family = TestDataFactory.createProduct();
        insert family;

        Product2 product = TestDataFactory.createProduct();
        product.Product_Family__c = family.Id;
        product.Product_Code__c = 'productCode';
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        PricebookEntry pricebookEntry1 = TestDataFactory.createActivePricebookEntry(pricebook.Id, product.Id);
        insert pricebookEntry1;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Price_list_code__c = pricebook.Id;
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        insert CTJ;

        Contract_Treatment_Job_Product__c CTJP = TestDataFactory.createCTJP(CTJ.Id);
        CTJP.Product__c = product.Id;
        insert CTJP;

        Contract_Treatment_Job_Product__c CTJP1 = TestDataFactory.createCTJP(CTJ.Id);
        CTJP1.Product__c = family.Id;
        insert CTJP1;

        Test.startTest();

        Boolean canActivate = CorporateTreatmentJobProductController.checkForCTJPActivation(CTJP.Id);
        Boolean canActivate1 = CorporateTreatmentJobProductController.checkForCTJPActivation(CTJP1.Id);

        Test.stopTest();

        System.assertEquals(false, canActivate);
        System.assertEquals(false, canActivate1);
    }

    @isTest
    static void getCTJPFamilyTest() {
        Pricebook2 pricebook = TestDataFactory.createPricebook();
        pricebook.IsActive = true;
        insert pricebook;

        Product2 family = TestDataFactory.createProduct();
        insert family;

        Product2 product = TestDataFactory.createProduct();
        product.Product_Family__c = family.Id;
        product.Product_Code__c = 'productCode';
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        PricebookEntry pricebookEntry1 = TestDataFactory.createActivePricebookEntry(pricebook.Id, product.Id);
        insert pricebookEntry1;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Price_list_code__c = pricebook.Id;
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        insert CTJ;

        Contract_Treatment_Job_Product__c CTJP = TestDataFactory.createCTJP(CTJ.Id);
        CTJP.Product__c = product.Id;
        insert CTJP;

        Test.startTest();

        String familyId = CorporateTreatmentJobProductController.getCTJPFamily(CTJP.Id);

        Test.stopTest();

        System.assertEquals(family.Id, familyId);
    }

    @isTest
    static void getCTJPTableActionsTest() {
        Pricebook2 pricebook = TestDataFactory.createPricebook();
        pricebook.IsActive = true;
        insert pricebook;

        Product2 family = TestDataFactory.createProduct();
        insert family;

        Product2 product = TestDataFactory.createProduct();
        product.Product_Family__c = family.Id;
        product.Product_Code__c = 'productCode';
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        PricebookEntry pricebookEntry1 = TestDataFactory.createActivePricebookEntry(pricebook.Id, product.Id);
        insert pricebookEntry1;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Status__c = 'Draft';
        contractFramework.Price_list_code__c = pricebook.Id;
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Contract_Framework__c = contractFramework.Id;
        insert CTJ;

        Contract_Treatment_Job_Product__c CTJP = TestDataFactory.createCTJP(CTJ.Id);
        CTJP.Product__c = product.Id;
        insert CTJP;

        Test.startTest();

        List<TableAction> tableActions = CorporateTreatmentJobProductController.getCTJPTableActions(CTJP.Id);

        contractFramework.Status__c = 'Active';
        contractFramework.Contract_Start_date__c = Date.today();
        update contractFramework;

        List<TableAction> tableActions1 = CorporateTreatmentJobProductController.getCTJPTableActions(CTJP.Id);

        Test.stopTest();

        System.assertEquals(2, tableActions.size());
        System.assertEquals(2, tableActions1.size());
    }

    @isTest
    static void propagateCTJPQuantityTest() {
        Pricebook2 pricebook = TestDataFactory.createPricebook();
        pricebook.IsActive = true;
        insert pricebook;

        Product2 family = TestDataFactory.createProduct();
        insert family;

        Product2 product = TestDataFactory.createProduct();
        product.Product_Family__c = family.Id;
        product.Product_Code__c = 'productCode';
        insert product;

        List<PricebookEntry> PEsToInsert = new List<PricebookEntry>();

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        PEsToInsert.add(pricebookEntry);

        PricebookEntry pricebookEntry1 = TestDataFactory.createActivePricebookEntry(pricebook.Id, product.Id);
        PEsToInsert.add(pricebookEntry1);

        insert PEsToInsert;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Status__c = 'Draft';
        contractFramework.Price_list_code__c = pricebook.Id;
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Contract_Framework__c = contractFramework.Id;
        insert CTJ;

        Contract_Treatment_Job_Product__c CTJP = TestDataFactory.createCTJP(CTJ.Id);
        CTJP.Quantity__c = 3;
        CTJP.Product__c = product.Id;
        insert CTJP;

        List<Schema.Location> locationsToInsert = new List<Schema.Location>();

        Schema.Location plant = TestDataFactory.createLocation();
        plant.LocationType = 'Plant';
        plant.IsInventoryLocation = true;
        locationsToInsert.add(plant);

        Schema.Location storage = TestDataFactory.createLocation();
        storage.LocationType = 'Warehouse';
        storage.IsInventoryLocation = true;
        storage.Location_Id__c = 'test';
        storage.Sales_Org_Code__c = '6300';
        locationsToInsert.add(storage);

        insert locationsToInsert;

        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;
        insert accountTreatment;

        Account_Treatment_Job__c ATJ = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        ATJ.Contract_Treatment_Job__c = CTJ.Id;
        insert ATJ;

        Account_Treatment_Job_Product__c ATJP = TestDataFactory.createATJP(ATJ.Id);
        ATJP.Product__c = product.Id;
        ATJP.Contract_Treatment_Job_Product__c = CTJP.Id;
        ATJP.Plant__c = plant.Id;
        ATJP.Storage_Location__c = storage.Id;
        insert ATJP;

        Test.startTest();

        WorkOrder wo = TestDataFactory.createWorkOrder();
        wo.Account_Treatment__c = accountTreatment.Id;
        wo.Account_Treatment_Job__c = ATJ.Id;
        wo.Pricebook2Id = pricebook.Id;
        insert wo;

        WorkOrderLineItem WOLI = TestDataFactory.createWOLI(wo.Id, pricebookEntry1.Id);
        WOLI.Account_Treatment_Job_Product__c = ATJP.Id;
        insert WOLI;

        CorporateTreatmentJobProductController.propagateCTJPQuantity(CTJP.Id);

        Test.stopTest();

        WorkOrderLineItem queriedWOLI = [SELECT Quantity FROM WorkOrderLineItem WHERE Id =: WOLI.Id];

        System.assertEquals(3, queriedWOLI.Quantity);
    }

    @isTest
    static void CTJPSwapTest() {
        Pricebook2 pricebook = TestDataFactory.createPricebook();
        pricebook.IsActive = true;
        insert pricebook;

        Product2 family = TestDataFactory.createProduct();
        insert family;

        Product2 product = TestDataFactory.createProduct();
        product.Product_Family__c = family.Id;
        product.Product_Code__c = 'productCode';
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        PricebookEntry pricebookEntry1 = TestDataFactory.createActivePricebookEntry(pricebook.Id, product.Id);
        insert pricebookEntry1;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Status__c = 'Draft';
        contractFramework.Price_list_code__c = pricebook.Id;
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Contract_Framework__c = contractFramework.Id;
        insert CTJ;

        Contract_Treatment_Job_Product__c CTJP = TestDataFactory.createCTJP(CTJ.Id);
        CTJP.Quantity__c = 3;
        CTJP.Product__c = product.Id;
        insert CTJP;

        Contract_Treatment_Job_Product__c CTJP1 = TestDataFactory.createCTJP(CTJ.Id);
        CTJP1.Quantity__c = 2;
        CTJP1.Product__c = product.Id;
        insert CTJP1;

        Schema.Location plant = TestDataFactory.createLocation();
        plant.LocationType = 'Plant';
        plant.IsInventoryLocation = true;
        insert plant;

        Schema.Location storage = TestDataFactory.createLocation();
        storage.LocationType = 'Warehouse';
        storage.IsInventoryLocation = true;
        storage.Location_Id__c = 'test';
        storage.Sales_Org_Code__c = '6300';
        insert storage;

        Account account = TestDataFactory.createPersonAccount();
        insert account;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(account);
        accountTreatment.Contract_Treatment__c = contractTreatment.Id;
        insert accountTreatment;

        Account_Treatment_Job__c ATJ = TestDataFactory.createAccountTreatmentJob(accountTreatment.Id);
        ATJ.Contract_Treatment_Job__c = CTJ.Id;
        insert ATJ;

        Account_Treatment_Job_Product__c ATJP = TestDataFactory.createATJP(ATJ.Id);
        ATJP.Product__c = product.Id;
        ATJP.Contract_Treatment_Job_Product__c = CTJP.Id;
        ATJP.Plant__c = plant.Id;
        ATJP.Storage_Location__c = storage.Id;
        insert ATJP;

        Test.startTest();

        CorporateTreatmentJobProductController.substituteCTJP(CTJP.Id, CTJP1.Id);

        Test.stopTest();

        List<Account_Treatment_Job_Product__c> ATJPs = [SELECT Id FROM Account_Treatment_Job_Product__c];

        System.assertEquals(2, ATJPs.size());
    }

    @isTest
    static void checkIsFamilyCTJPTest() {
        Pricebook2 pricebook = TestDataFactory.createPricebook();
        pricebook.IsActive = true;
        insert pricebook;

        Product2 family = TestDataFactory.createProduct();
        insert family;

        Product2 product = TestDataFactory.createProduct();
        product.Product_Family__c = family.Id;
        product.Product_Code__c = 'productCode';
        insert product;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), product.Id);
        insert pricebookEntry;

        PricebookEntry pricebookEntry1 = TestDataFactory.createActivePricebookEntry(pricebook.Id, product.Id);
        insert pricebookEntry1;

        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.Status__c = 'Draft';
        contractFramework.Price_list_code__c = pricebook.Id;
        insert contractFramework;

        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);
        insert contractTreatment;

        Contract_Treatment_Job__c CTJ = TestDataFactory.createContractTreatmentJob(contractTreatment.Id);
        CTJ.Contract_Framework__c = contractFramework.Id;
        insert CTJ;

        Contract_Treatment_Job_Product__c CTJP = TestDataFactory.createCTJP(CTJ.Id);
        CTJP.Product__c = product.Id;
        insert CTJP;

        Test.startTest();

        Boolean isFamily = CorporateTreatmentJobProductController.checkIsFamilyCTJP(CTJP.Id);

        Test.stopTest();

        System.assertEquals(false, isFamily);
    }
}