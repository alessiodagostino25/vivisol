@isTest
public class TestCreateQuoteButtonController {
    public static testMethod void getPrefilledOrderTest() {
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
        CreateQuoteButtonController.getPrefilledQuote(c.Id); 
        CreateQuoteButtonController.getPrefilledQuote(cf.Id);
        CreateQuoteButtonController.getPrefilledQuote(c1.Id);
        Test.stopTest();
    }
}