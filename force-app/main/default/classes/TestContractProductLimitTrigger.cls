@IsTest
public class TestContractProductLimitTrigger {

    static testMethod void ContractProductLimitTrigger(){
        Pricebook2 pb=TestDataFactory.initPricebook();
        Contract_Framework__c cf=TestDataFactory.initContractFramework(pb);
        Contract_Treatment__c ct=TestDataFactory.initContractTreatment(cf.id);
        Product2 p=TestDataFactory.initProduct();
        Contract_Product_Limit__c cpl=TestDataFactory.initContarctProductLimit2(ct, p);
        Test.startTest();
        Database.SaveResult result=Database.insert(cpl);
        System.debug('result'+result);
        Test.stopTest();
        System.assert(result.isSuccess());
       
        
       
    }
}