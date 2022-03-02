@isTest
public class TestOrderItemCardListController {
    public static testMethod void getOrderItemIdsTest() {

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
        List<Id> orderItems = OrderItemCardListController.getOrderItemIds(o.Id); 
        Test.stopTest();
    }
    public static testMethod void getOrderStatusTest() {

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
        String orderstatus = OrderItemCardListController.getOrderStatus(o.Id); 
        Test.stopTest();
    }
}