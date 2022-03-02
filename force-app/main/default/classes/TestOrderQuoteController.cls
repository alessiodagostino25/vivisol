@isTest
public class TestOrderQuoteController {

    
    public static testMethod  void createOrderWithAccountPatient(){
        Account acc = insertAccountPatient();
        Pricebook2 pb = TestDataFactory.initPricebookStandard();
        Product2 pr = TestDataFactory.initProduct();
        PricebookEntry pe =  TestDataFactory.initPricebookEntry(pb, pr);
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pb);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Quote__c q = new Quote__c();
        q.Name = 'Test Quote';
        q.Account_Name__c = acc.Id;
        q.Price_Book__c = pb.id;
        q.Contract_Treatment__c = ct.id;
        insert q;
        Quote_Line_Item__c qli = new Quote_Line_Item__c();
        qli.Description__c = 'Test Description';
        qli.Quote_Name__c = q.Id;
        qli.Pricebook__c = pb.id;
        qli.Product__c = pr.id;
        qli.Quantity__c = 20;
        insert qli;
        
        Test.startTest();
        OrderQuoteController.createOrder(q.Id);
        Test.stopTest();
        
        Order ord = [SELECT Id, Name FROM Order WHERE Quote__c = :q.Id LIMIT 1];
        System.assert(ord != null);
        System.assertEquals(q.Name, ord.Name);
        List<OrderItem> orditems = [SELECT Id, Description FROM OrderItem WHERE orderid = :ord.Id];
        System.assert(orditems.size() > 0);
        System.assertEquals(orditems.get(0).Description, 'Test Description');
    }
    
    public static testMethod  void createOrderWithAccountB2B(){
        Account acc = getAccountB2B();
        //Pricebook2 pb = TestDataFactory.initPricebookStandard();
        Product2 pr = TestDataFactory.initProduct();
        PricebookEntry pe =  TestDataFactory.createActivePricebookEntry(Test.getStandardPricebookId(), pr.Id);
        insert pe;
        Contract_Framework__c cf = TestDataFactory.createContractFramework();
        cf.Price_list_code__c = Test.getStandardPricebookId();
        insert cf;
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);        
        Quote__c q = new Quote__c();
        q.Name = 'Test Quote';
        q.Account_Name__c = acc.Id;
        q.Price_Book__c = Test.getStandardPricebookId();
        insert q;
        Quote_Line_Item__c qli = new Quote_Line_Item__c();
        qli.Description__c = 'Test Description';
        qli.Quote_Name__c = q.Id;
        qli.Pricebook__c = Test.getStandardPricebookId();
        qli.Product__c = pr.id;
        qli.Quantity__c = 20;
        insert qli;
        
        Test.startTest();
        OrderQuoteController.createOrder(q.Id);
        Test.stopTest();
        
        Order ord = [SELECT Id, Name FROM Order WHERE Quote__c = :q.Id LIMIT 1];
        System.assert(ord != null);
        System.assertEquals(q.Name, ord.Name);
        List<OrderItem> orditems = [SELECT Id, Description FROM OrderItem WHERE orderid = :ord.Id];
        System.assert(orditems.size() > 0);
        System.assertEquals(orditems.get(0).Description, 'Test Description');
    }
    
    private static Account getAccountB2B(){
        String personAccountRcId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Account_B2B').getRecordTypeId();
        system.debug('personAccountRcId: ' +personAccountRcId);
        Account acc = new Account();
        acc.Name='B2B name';  
        acc.RecordtypeId = personAccountRcId;
        acc.Language__c='I';
        acc.Billing_method__c='01';
        acc.ShippingCity='city';
        acc.ShippingCountry='Italy';
        acc.ShippingPostalCode='27029';
        acc.ShippingStreet='via ';
        acc.BillingCity = acc.ShippingCity;
        acc.BillingCountry = acc.ShippingCountry;
        acc.BillingPostalCode =acc.ShippingPostalCode;
        acc.BillingStreet = acc.ShippingStreet;

        insert acc;
        return acc;
    }
    
     public static Account insertAccountPatient(){
        String personAccountRcId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Account_Patient').getRecordTypeId();
        system.debug('personAccountRcId: ' +personAccountRcId);
        Account acc = new Account();
        acc.FirstName='first name'; 
        acc.LastName='lasta name'; 
        acc.RecordtypeId = personAccountRcId;
        acc.Language__c='I';
        acc.Billing_method__c='01';
        acc.PersonBirthdate=Date.newInstance(1990, 12, 01);
        acc.ShippingCity='Vigevano';
        acc.ShippingCountry='Italy';
        acc.ShippingPostalCode='27029';
        acc.ShippingStreet='via ';

        insert acc;
        return acc;
    }    
}