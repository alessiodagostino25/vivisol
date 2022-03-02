public with sharing class ContractFrameworkDAO {
    
    public static Contract_Framework__c getContractFrameworkFromId(List<String> queryFields, String contractFrameworkId) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
          query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Framework__c WHERE Id =: contractFrameworkId';
        
        return Database.query(query);
    }

    @AuraEnabled
    public static List<Contract_Framework__c> getCFsFromIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Framework__c WHERE Id IN: relatedIds';
        System.debug('getCFsFromIds QUERY: ' + query);
        
        return Database.query(query);
    }
    
    public static List<Contract_Framework__c> getContractFrameworkpricelistcode(List<Id> ctframeworksids) {
        String query = 'SELECT Id,PriceListCode__c FROM Contract_Framework__c WHERE Id IN :ctframeworksids';
        
        return Database.query(query);
    }
    public static List<Contract_Framework__c> getContractFrameworkFromListId(List<Id> cfIds) {
        String query = 'SELECT Id,PriceListCode__c,Contract_Number__c,Name,Contract_Start_date__c,Contract_End_date__c,Sales_Organization__c,Distribution_Channel__c,Division__c,Customer__r.Account_External_Id__c,Contract_Type__c, IsSyncSAP__c, IsCreatedSAP__c FROM Contract_Framework__c WHERE Id IN :cfIds';    
        return Database.query(query);
    }
    public static List<Contract_Framework__c> getCFsFromrecordids(List<String> queryFields, List<String> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Framework__c WHERE Contract_Number__c IN: relatedIds';
        System.debug('getCFsFromrecordids QUERY: ' + query);
        
        return Database.query(query);
    }

}