@isTest
public class QuoteLineItemControllerTest {
    
    public static testMethod void getPricebookEntry(){
        Account acc = TestDataFactory.insertAccountPatient();
        Pricebook2 pb = TestDataFactory.createPricebook();
        insert pb;
        
        Product2 pr = TestDataFactory.initProduct2();
        pr.Manufacturer_part_number__c='test';
        update pr;
        PricebookEntry pe =  TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), pr.Id);
        pe.IsActive = false;
        insert pe;

        PricebookEntry pe2 =  TestDataFactory.createActivePricebookEntry(pb.Id, pr.Id);
        insert pe2;

        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pb);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Quote__c q = TestDataFactory.initQuote(acc, pb, ct);
        List<PricebookEntry> pricebookentryList = new List<PricebookEntry>();
        Test.startTest();
        List<PricebookEntry> result = QuoteLineItemController.getPricebookEntry(q.Id, pr.Manufacturer_part_number__c, pricebookentryList);
        Test.stopTest();
        system.assert(result.size()>0);
        
    }

	public static testMethod void getAllProducts(){
        Account acc = TestDataFactory.insertAccountPatient();
        Pricebook2 pb = TestDataFactory.createPricebook();
        insert pb;
        Product2 pr = TestDataFactory.initProduct2();
        pr.Manufacturer_part_number__c='test';
        update pr;
        PricebookEntry pe =  TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), pr.Id);
        pe.IsActive = false;
        insert pe;

        PricebookEntry pe2 =  TestDataFactory.createActivePricebookEntry(pb.Id, pr.Id);
        insert pe2;
        
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pb);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Quote__c q = TestDataFactory.initQuote(acc, pb, ct);
        List<Object> pricebookentryList = new List<Object>();
        Test.startTest();
        List<PricebookEntry> result = QuoteLineItemController.getAllProducts(q.Id, pricebookentryList);
        Test.stopTest();
        system.assert(result.size()>0);
        
    }      
    
    public static testMethod void getQuoteLineItemsTest(){
        Account acc = TestDataFactory.insertAccountPatient();
        Pricebook2 pb = TestDataFactory.createPricebook();
        insert pb;
        Product2 pr = TestDataFactory.initProduct();
        PricebookEntry pe =  TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), pr.Id);
        insert pe;
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pb);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Quote__c q = TestDataFactory.initQuote(acc, pb, ct);
		Quote_Line_Item__c qli = TestDataFactory.initQuoteLineItem(q, pb, pr);
        
        Test.startTest();
        List<QuoteLineItemDTO> items = QuoteLineItemController.getQuoteLineItems(q.id);
        system.assert(items.size() > 0);
        Test.stopTest();
        
    }
    
   
    
    public static testMethod void getQuoteLineItemByIds(){
        Account acc = TestDataFactory.insertAccountPatient();
        Pricebook2 pb = TestDataFactory.createPricebook();
        insert pb;
        Product2 pr = TestDataFactory.initProduct();
        PricebookEntry pe =  TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), pr.Id);
        insert pe;
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pb);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Quote__c q = TestDataFactory.initQuote(acc, pb, ct);
		Quote_Line_Item__c qli = TestDataFactory.initQuoteLineItem(q, pb, pr);
        List<String> qliList = new List<String>{qli.Id};
        Test.startTest();
        List<QuoteLineItemDTO> items = QuoteLineItemController.getQuoteLineItemByIds(qliList);
        system.assert(items.size() > 0);
        Test.stopTest(); 
    }
    
    public static testMethod void getQuoteStatus(){
        Account acc = TestDataFactory.insertAccountPatient();
        Pricebook2 pb = TestDataFactory.createPricebook();
        insert pb;
        Product2 pr = TestDataFactory.initProduct();
        PricebookEntry pe =  TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), pr.Id);
        insert pe;
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pb);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Quote__c q = TestDataFactory.initQuote(acc, pb, ct);
        Test.startTest();
        String status = QuoteLineItemController.getQuoteStatus(q.Id);
        Test.stopTest();
        system.assert(status!='');
        system.assert(status!=null);
        
    }
    
  
    
    public static testMethod void getQuoteLineItemByIdsToObj(){
        Account acc = TestDataFactory.insertAccountPatient();
        Pricebook2 pb = TestDataFactory.createPricebook();
        insert pb;
        Product2 pr = TestDataFactory.initProduct();
        PricebookEntry pe =  TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), pr.Id);
        insert pe;
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pb);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Quote__c q = TestDataFactory.initQuote(acc, pb, ct);
		Quote_Line_Item__c qli = TestDataFactory.initQuoteLineItem(q, pb, pr);
        List<Object> qliList = new List<Object>{qli.Id};
        Test.startTest();
        List<Quote_Line_Item__c> items = QuoteLineItemController.getQuoteLineItemByIdsToObj(qliList);
        system.assert(items.size() > 0);
        Test.stopTest(); 
    }
    
    public static testMethod void createQuoteLineItem(){
        Account acc = TestDataFactory.insertAccountPatient();
        Pricebook2 pb = TestDataFactory.createPricebook();
        insert pb;
        Product2 pr = TestDataFactory.initProduct();
        PricebookEntry pe =  TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), pr.Id);
        insert pe;
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pb);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Quote__c q = TestDataFactory.initQuote(acc, pb, ct);
        Object pricebook2id = 'pricebook2id';
        Object product2id = 'product2id';
        Map<Object,Object> data = new Map<Object,Object>();
        data.put(pricebook2id, pb.Id);
        data.put(product2id, pr.Id);
        
         List<Object> pricebookentryList = new List<Object>{data};
        Test.startTest();
        List<String> items = QuoteLineItemController.createQuoteLineItem(pricebookentryList, q.Id);
        
        system.assert(items.size() > 0);
        Test.stopTest(); 
    }

}