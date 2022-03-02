@isTest
public class TestContractTreatmentTrigger {
    
    @TestSetup
    static void makeData(){
        Contract_Framework__c contractFramework = TestDataFactory.createContractFramework();
        contractFramework.PriceListCode__c = '6300';

        insert contractFramework;
    }

    @isTest
    static void insertTest() {
        Contract_Framework__c contractFramework = [SELECT Id, PriceListCode__c FROM Contract_Framework__c];
        Contract_Treatment__c contractTreatment = TestDataFactory.createContractTreatment(contractFramework.Id);

        Test.startTest();

        Database.SaveResult result = Database.insert(contractTreatment);

        Test.stopTest();

        Contract_Treatment__c queriedContractTreatment = [SELECT Id, PriceListCode__c FROM Contract_Treatment__c];

        System.assert(result.isSuccess());
        System.assertEquals(queriedContractTreatment.PriceListCode__c, contractFramework.PriceListCode__c);
    }
}