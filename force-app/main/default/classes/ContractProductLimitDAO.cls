public with sharing class ContractProductLimitDAO {
    
    public static List<Contract_Product_Limit__c> getLimitsFromCTIds(List<String> queryFields, List<Id> CTIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Contract_Product_Limit__c WHERE Contract_Treatment__c IN: CTIds';
        System.debug('getLimitsFromCTIds QUERY: ' + query);
        
        return Database.query(query);
    }

}