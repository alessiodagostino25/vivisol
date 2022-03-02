public with sharing class ContractProductLimitController {

    @AuraEnabled(cacheable=true)
    public static List<Contract_Product_Limit__c> getContractProductLimitController() {
        return  [SELECT Id, Product__r.Product_Name_Translate__c, Name, Frequency__c, Frequency_Unit_of_measure__c FROM Contract_Product_Limit__c];
    }
}