@isTest
public class TestCreateOrderButtonController {

    @isTest
    public static void getPrefilledOrderTest() {
        String personAccountRcId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Account_Patient').getRecordTypeId();
        Account acc = TestDataFactory.createPersonAccount();
        acc.RecordTypeId = personAccountRcId;
        insert acc;

        Account accvivisol = TestDataFactory.insertAccountVivisol();   
        
        Contract_Framework__c cf = TestDataFactory.createContractFramework();
        cf.Price_list_code__c = Test.getStandardPricebookId();
        insert cf;

        Contract_Treatment__c ct = TestDataFactory.initContractTreatment(cf.Id);
        Case c = TestDataFactory.initCase(acc,ct);
        Case c1 = TestDataFactory.initCase(accvivisol,ct);
        Test.startTest();
        CreateOrderButtonController.getPrefilledOrder(c.Id);
        CreateOrderButtonController.getPrefilledOrder(cf.Id);
        CreateOrderButtonController.getPrefilledOrder(c1.Id);
        Test.stopTest();
    }
    
}