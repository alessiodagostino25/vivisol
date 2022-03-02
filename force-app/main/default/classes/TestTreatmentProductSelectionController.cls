@isTest
public class TestTreatmentProductSelectionController {
    
    @isTest
    public static void getProducts(){
        
        Product2 p = TestDataFactory.initProduct2();
       	List<String> preselectedrowslist = new List<String>();
        preselectedrowslist.add(p.Id);            
        //Pricebook2 pricebook= TestDataFactory.initPricebookStandard();
        Pricebook2 pricebook = TestDataFactory.createPricebook();
        pricebook.IsActive = true;
        insert pricebook;

        PricebookEntry standardPricebookEntry = TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), p.Id);
        standardPricebookEntry.IsActive = false;
        insert standardPricebookEntry;

        PricebookEntry pricebookEntry = TestDataFactory.createActivePricebookEntry(pricebook.Id, p.Id);
        insert pricebookEntry;

        Corporate_Treatment_Job__c corporateTreatmentJob = TestDataFactory.initCorporateTreatmentJob();
        Contract_Framework__c contractFramework= TestDataFactory.createContractFramework();
        contractFramework.Price_list_code__c = pricebook.Id;
        insert contractFramework;
        
        Contract_Treatment__c contractTreatment=TestDataFactory.initContractTreatment(contractFramework.Id);
        Contract_Treatment_Job__c contractTreatmentJob= TestDataFactory.initContractTreatmentJob(contractTreatment.Id, corporateTreatmentJob.Id);
        contractTreatmentJob.Contract_Framework__c=contractFramework.Id;
        update contractTreatmentJob;
        Account a = TestDataFactory.createPersonAccount();
        insert a;

        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        insert accountTreatment;

        Account_Treatment_Job__c atj= TestDataFactory.initAccountTreatmentJob2(p, contractTreatmentJob, accountTreatment);
        Contract_Treatment_Job_Product__c ctjpList = TestDataFactory.initCTJP(contractTreatmentJob, p);
        Test.startTest();
        List<Product2DTO> product= TreatmentProductSelectionController.getProducts(p.Product_Name_Translate__c, atj.Id, '' ,preselectedrowslist );
        Test.stopTest();
        System.assertEquals(1, product.size());    
    }
    

    @isTest
    public static void getAsset(){
        Schema.Location locationNoAccount = TestDataFactory.createLocation();
        insert locationNoAccount;
        
        Account a1 = TestDataFactory.initAccount2();
        Product2 p = TestDataFactory.initProduct2();

        Asset asset = TestDataFactory.createAsset(a1.Id);
        asset.LocationId = locationNoAccount.Id;
        insert asset;
        
        String id = asset.Id;
        List<String> preselectedrowslistasset = new List<String>{id};        
        Pricebook2 pricebook= TestDataFactory.initPricebook();
        Corporate_Treatment_Job__c corporateTreatmentJob = TestDataFactory.initCorporateTreatmentJob();
        Contract_Framework__c contractFramework=TestDataFactory.initContractFramework2(pricebook);
        Contract_Treatment__c contractTreatment=TestDataFactory.initContractTreatment(contractFramework.Id);
        Contract_Treatment_Job__c contractTreatmentJob= TestDataFactory.initContractTreatmentJob(contractTreatment.Id, corporateTreatmentJob.Id);
        contractTreatmentJob.Contract_Framework__c=contractFramework.Id;
        update contractTreatmentJob;
        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a1);
        accountTreatment.Business_Line__c = null;
        accountTreatment.Treatment_Type__c = null;
        insert accountTreatment;
        
        CTJAssetSelectionController.createContractAssets(new List<String>{asset.Id}, contractTreatment.Id);
        Account_Treatment_Job__c atj= TestDataFactory.initAccountTreatmentJob2(p, contractTreatmentJob, accountTreatment);
        Test.startTest();
        System.debug('ALL CONTRACT ASSETS: ' + [SELECT Id FROM Contract_Asset__c].size());
        List<ContractAssetDTO> assetList = TreatmentProductSelectionController.getAsset(asset.SerialNumber , preselectedrowslistasset ,atj.Id);
        Test.stopTest();           
        System.assertEquals(1, assetList.size());
    }
    
    @isTest
    public static void createAccountProduct(){
  
        Account a = TestDataFactory.createPersonAccount();
        insert a;

        List<String> selectedproducts = TestDataFactory.initListProductId();
        List<Product2> productList= [SELECT Id FROM Product2 WHERE Id in:selectedproducts];        
        Pricebook2 pricebook= TestDataFactory.initPricebook();
        Corporate_Treatment_Job__c corporateTreatmentJob = TestDataFactory.initCorporateTreatmentJob();
        Corporate_Treatment__c corporateTreatment = TestDataFactory.initCorporateTreatment();
		Contract_Framework__c contractFramework=TestDataFactory.initContractFramework2(pricebook);
        Contract_Treatment__c contractTreatment=TestDataFactory.initContractTreatment(contractFramework.Id);
        Contract_Treatment_Job__c contractTreatmentJob= TestDataFactory.initContractTreatmentJob(contractTreatment.Id, corporateTreatmentJob.Id);
        contractTreatmentJob.Contract_Framework__c=contractFramework.Id;
        update contractTreatmentJob;
        List<Contract_Treatment_Job_Product__c> ctjpList = TestDataFactory.initCTJPList(contractTreatmentJob, productList);
        Account_Treatment__c accountTreatment = TestDataFactory.createMRDAccountTreatment(a);
        accountTreatment.Business_Line__c = null;
        accountTreatment.Treatment_Type__c = null;
        insert accountTreatment;

        Account_Treatment_Job__c atj= TestDataFactory.initAccountTreatmentJob2(productList.get(0), contractTreatmentJob, accountTreatment);
        Test.startTest();
        TreatmentProductSelectionController.createAccountProduct(selectedproducts, atj.Id);
        Test.stopTest();
    
    }
    
    @isTest
    public static void createAccountAsset(){
       
        Product2 p = TestDataFactory.initProduct2();  
        List<Asset> al=TestDataFactory.getAssetList();
        List<String> selectedasset = TestDataFactory.assetList(al);
        Account_Treatment_Job__c atj= TestDataFactory.initAccountTreatmentJob(p);      
        Test.startTest();
        TreatmentProductSelectionController.createAccountAsset(selectedasset,atj.Id);
        Test.stopTest();
  
    }
    
    

}