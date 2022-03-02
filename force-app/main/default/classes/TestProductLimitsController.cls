@isTest
public class TestProductLimitsController {
   
     static testMethod  void getInactiveLimits1(){
        List<Product2> products = TestDataFactory.initProductList();
        List<String> allSelectedIds = new List<String>();
        for (Product2 p: products){
            allSelectedIds.add(p.id);           
        }
        Pricebook2 pr = TestDataFactory.initPricebook();
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pr);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Contract_Product_Limit__c cpl= TestDataFactory.initContarctProductLimit(ct, products.get(0));
        Test.startTest();
        List<ProductLimitDTO> result = ProductLimitsController.getInactiveLimits(ct.Id, '', allSelectedIds, ''); 
        Test.stopTest();
        system.assertEquals(1, result.size());
       
    }
    
   
    
    
    static testMethod void getInactiveLimits2(){
        List<Product2> products = TestDataFactory.initProductList();
        List<String> allSelectedIds = new List<String>();
        for (Product2 p: products){
            allSelectedIds.add(p.id);           
        }
        Pricebook2 pr = TestDataFactory.initPricebook();
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pr);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Contract_Product_Limit__c cpl= TestDataFactory.initContarctProductLimit(ct, products.get(1));
        Test.startTest();
        List<ProductLimitDTO> result = ProductLimitsController.getInactiveLimits(ct.Id, '', allSelectedIds, 'products'); 
        Test.stopTest();
        system.assertEquals(1, result.size());
       
    }
    
     
     static testMethod void getInactiveLimits3(){
        List<Product2> products = TestDataFactory.initProductList();
        List<String> allSelectedIds = new List<String>();
        for (Product2 p: products){
            allSelectedIds.add(p.id);           
        }
        Pricebook2 pr = TestDataFactory.initPricebook();
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pr);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Contract_Product_Limit__c cpl= TestDataFactory.initContarctProductLimit(ct, products.get(2));
        Test.startTest();
        List<ProductLimitDTO> result = ProductLimitsController.getInactiveLimits(ct.Id, '', allSelectedIds, 'services'); 
        Test.stopTest();
        system.assertEquals(1, result.size());
       
    }
    
    
     static testMethod void getInactiveLimits4(){
        List<Product2> products = TestDataFactory.initProductList();
        List<String> allSelectedIds = new List<String>();
        for (Product2 p: products){
            allSelectedIds.add(p.id);           
        }
        Pricebook2 pr = TestDataFactory.initPricebook();
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pr);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Contract_Product_Limit__c cpl= TestDataFactory.initContarctProductLimit(ct, products.get(0));
        Test.startTest();
        List<ProductLimitDTO> result = ProductLimitsController.getInactiveLimits(ct.Id, 'prova1', allSelectedIds, ''); 
        Test.stopTest();
        system.assertEquals(1, result.size());
       
    }
    
    
     static testMethod void getInactiveLimits5(){
        List<Product2> products = TestDataFactory.initProductList();
        List<String> allSelectedIds = new List<String>();
        for (Product2 p: products){
            allSelectedIds.add(p.id);           
        }
        Pricebook2 pr = TestDataFactory.initPricebook();
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pr);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Contract_Product_Limit__c cpl= TestDataFactory.initContarctProductLimit(ct, products.get(1));
        Test.startTest();
        List<ProductLimitDTO> result = ProductLimitsController.getInactiveLimits(ct.Id, 'prova2', allSelectedIds, 'products'); 
        Test.stopTest();
        system.assertEquals(1, result.size());
       
    }
    
     
     static testMethod void getInactiveLimits6(){
        List<Product2> products = TestDataFactory.initProductList();
        List<String> allSelectedIds = new List<String>();
        for (Product2 p: products){
            allSelectedIds.add(p.id);           
        }
        Pricebook2 pr = TestDataFactory.initPricebook();
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pr);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Contract_Product_Limit__c cpl= TestDataFactory.initContarctProductLimit(ct, products.get(2));
        Test.startTest();
        List<ProductLimitDTO> result = ProductLimitsController.getInactiveLimits(ct.Id, 'prova3', allSelectedIds, 'services'); 
        Test.stopTest();
        system.assertEquals(1, result.size());
       
    }
    
     
     static testMethod void getInactiveLimits7(){
        List<Product2> products = TestDataFactory.initProductList();
        List<String> allSelectedIds = new List<String>();
        for (Product2 p: products){
            allSelectedIds.add(p.id);           
        }
        Pricebook2 pr = TestDataFactory.initPricebook();
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pr);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Contract_Product_Limit__c cpl= TestDataFactory.initContarctProductLimit(ct, products.get(0));
        Test.startTest();
        List<ProductLimitDTO> result = ProductLimitsController.getInactiveLimits(ct.Id, '', allSelectedIds, 'null'); 
        Test.stopTest();
        system.assertEquals(1, result.size());
       
    }
    
    
     static testMethod void getLimits1(){
        List<Product2> products = TestDataFactory.initProductList();
        List<String> allSelectedIds = new List<String>();
        for (Product2 p: products){
            allSelectedIds.add(p.id);           
        }
        Pricebook2 pr = TestDataFactory.initPricebook();
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pr);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Contract_Product_Limit__c cpl= TestDataFactory.initContarctProductLimit(ct, products.get(0));
        cpl.Status__c='Active';
        update cpl;
        Test.startTest();
        List<ProductLimitDTO> result = ProductLimitsController.getLimits(allSelectedIds, ct.Id, '', ''); 
        Test.stopTest();
        system.assertEquals(1, result.size());
       
    }
    
    
     static testMethod void getLimits2(){
        List<Product2> products = TestDataFactory.initProductList();
        List<String> allSelectedIds = new List<String>();
        for (Product2 p: products){
            allSelectedIds.add(p.id);           
        }
        Pricebook2 pr = TestDataFactory.initPricebook();
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pr);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Contract_Product_Limit__c cpl= TestDataFactory.initContarctProductLimit(ct, products.get(1));
        cpl.Status__c='Active';
        update cpl;
        Test.startTest();
        List<ProductLimitDTO> result = ProductLimitsController.getLimits(allSelectedIds, ct.Id, 'products', ''); 
        Test.stopTest();
        system.assertEquals(1, result.size());
       
    }
    
     
     static testMethod void getLimits3(){
        List<Product2> products = TestDataFactory.initProductList();
        List<String> allSelectedIds = new List<String>();
        for (Product2 p: products){
            allSelectedIds.add(p.id);           
        }
        Pricebook2 pr = TestDataFactory.initPricebook();
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pr);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Contract_Product_Limit__c cpl= TestDataFactory.initContarctProductLimit(ct, products.get(2));
        cpl.Status__c='Active';
        update cpl;
        Test.startTest();
        List<ProductLimitDTO> result = ProductLimitsController.getLimits(allSelectedIds, ct.Id, 'services', '');
        Test.stopTest();
        system.assertEquals(1, result.size());
       
    }
    
    
     static testMethod void getLimits4(){
        List<Product2> products = TestDataFactory.initProductList();
        List<String> allSelectedIds = new List<String>();
        for (Product2 p: products){
            allSelectedIds.add(p.id);           
        }
        Pricebook2 pr = TestDataFactory.initPricebook();
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pr);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Contract_Product_Limit__c cpl= TestDataFactory.initContarctProductLimit(ct, products.get(0));
        cpl.Status__c='Active';
        update cpl;
        Test.startTest();
        List<ProductLimitDTO> result = ProductLimitsController.getLimits(allSelectedIds, ct.Id, '', 'prova1');
        Test.stopTest();
        system.assertEquals(1, result.size());
       
    }
    
    
     static testMethod void getLimits5(){
        List<Product2> products = TestDataFactory.initProductList();
        List<String> allSelectedIds = new List<String>();
        for (Product2 p: products){
            allSelectedIds.add(p.id);           
        }
        Pricebook2 pr = TestDataFactory.initPricebook();
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pr);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Contract_Product_Limit__c cpl= TestDataFactory.initContarctProductLimit(ct, products.get(1));
        cpl.Status__c='Active';
        update cpl;
        Test.startTest();
        List<ProductLimitDTO> result = ProductLimitsController.getLimits(allSelectedIds, ct.Id, 'products', 'prova2');
        Test.stopTest();
        system.assertEquals(1, result.size());
       
    }
    
     
     static testMethod void getLimits6(){
        List<Product2> products = TestDataFactory.initProductList();
        List<String> allSelectedIds = new List<String>();
        for (Product2 p: products){
            allSelectedIds.add(p.id);           
        }
        Pricebook2 pr = TestDataFactory.initPricebook();
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pr);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Contract_Product_Limit__c cpl= TestDataFactory.initContarctProductLimit(ct, products.get(2));
        cpl.Status__c='Active';
        update cpl;
        Test.startTest();
        List<ProductLimitDTO> result = ProductLimitsController.getLimits(allSelectedIds, ct.Id, 'services', 'prova3');
        Test.stopTest();
        system.assertEquals(1, result.size());
       
    }
    
     
     static testMethod void updateLimitsToActive(){
        List<Product2> products = TestDataFactory.initProductList();
        List<String> allSelectedIds = new List<String>();
        for (Product2 p: products){
            allSelectedIds.add(p.id);           
        }
        Pricebook2 pr = TestDataFactory.initPricebook();
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pr);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Contract_Product_Limit__c cpl= TestDataFactory.initContarctProductLimit(ct, products.get(0));
        Test.startTest();
		ProductLimitsController.updateLimitsToActive(allSelectedIds, ct.Id); 
        Test.stopTest();
       
    }
    
     
     static testMethod void deleteLimit(){
        List<Product2> products = TestDataFactory.initProductList();
        List<String> allSelectedIds = new List<String>();
        for (Product2 p: products){
            allSelectedIds.add(p.id);           
        }
        Pricebook2 pr = TestDataFactory.initPricebook();
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pr);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Contract_Product_Limit__c cpl= TestDataFactory.initContarctProductLimit(ct, products.get(0));
        cpl.Status__c='Active';
        update cpl;
        Test.startTest();
		ProductLimitsController.deleteLimit(cpl.Id); 
        Test.stopTest();
       
    }
    
    

    
}