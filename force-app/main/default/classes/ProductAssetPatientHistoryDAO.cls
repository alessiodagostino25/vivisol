public with sharing class ProductAssetPatientHistoryDAO {
    
    public static List<Product_Asset_Patient_History__c> getPAPHFromAssetIds(List<String> queryFields, List<Id> assetIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Product_Asset_Patient_History__c WHERE Serialized_Item__c IN: assetIds AND Serialized_Item__c != null';
        System.debug('getPAPHFromAssetIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Product_Asset_Patient_History__c> getPAPHFromExternalIds(List<String> queryFields, List<String> externalIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Product_Asset_Patient_History__c WHERE External_Id__c IN: externalIds AND External_Id__c != null';
        System.debug('getPAPHFromExternalIds QUERY: ' + query);
        
        return Database.query(query);
    }
}