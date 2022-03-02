@isTest
public class TestOrderItemCardController {
    public static testMethod void getCardTitleTest(){
        String personAccountRcId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Account_Patient').getRecordTypeId();
        Account acc = TestDataFactory.createPersonAccount();
        acc.RecordTypeId = personAccountRcId;
        insert acc;

        Pricebook2 pb = TestDataFactory.initPricebookStandard();
        Product2 pr = TestDataFactory.initProduct();
        PricebookEntry pe =  TestDataFactory.initPricebookEntry(pb, pr);
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pb);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Order o = TestDataFactory.initOrder(acc, pb, ct);
		OrderItem oi = TestDataFactory.initOrderItem(o, pb, pr, pe);
        
        Test.startTest();
        String cardtitle = OrderItemCardController.getCardTitle(oi.Id); 
        Test.stopTest();
    }
    public static testMethod void deleteOrderItemTest(){
        String personAccountRcId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Account_Patient').getRecordTypeId();
        Account acc = TestDataFactory.createPersonAccount();
        acc.RecordTypeId = personAccountRcId;
        insert acc;
        
        Pricebook2 pb = TestDataFactory.initPricebookStandard();
        Product2 pr = TestDataFactory.initProduct();
        PricebookEntry pe =  TestDataFactory.initPricebookEntry(pb, pr);
        Contract_Framework__c cf = TestDataFactory.initContractFramework2(pb);
        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Order o = TestDataFactory.initOrder(acc, pb, ct);
		OrderItem oi = TestDataFactory.initOrderItem(o, pb, pr, pe);
        
        Test.startTest();
        OrderItemCardController.deleteOrderItem(oi.Id); 
        Test.stopTest();
    }
 
}