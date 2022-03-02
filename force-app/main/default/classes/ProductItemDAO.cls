public with sharing class ProductItemDAO {
    
    public static List<ProductItem> getProductItemsFromIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ProductItem WHERE Id IN: relatedIds';
        System.debug('getProductItemsFromIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<ProductItem> getProductItemsFromSerializedItem(List<String> queryFields, List<Id> serializedItemIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ProductItem WHERE Serialized_Item__c IN: serializedItemIds';
        System.debug('getProductItemsFromSerializedItem QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<ProductItem> getProductItemPatients(List<String> queryFields, List<Id> productIds, List<String> batchNumbers, List<Id> locationIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ProductItem WHERE Product2Id IN: productIds AND (BatchNumber__c IN: batchNumbers OR BatchNumber__c = null) AND LocationId IN: locationIds AND RelatedProductItem__c = null';
        System.debug('getProductItemPatients QUERY: ' + query);
        
        return Database.query(query);
    }

    // This method queries for ProductItems different from the ones of idsNotToMatch, but with same LocationId and FamilyName (and SerializedItem = null)

    public static List<ProductItem> getOtherFamilyProductItems(List<String> queryFields, List<Id> idsNotToMatch, List<Id> locationIds, List<String> families) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ProductItem WHERE Id NOT IN: idsNotToMatch AND LocationId IN: locationIds AND Family__c IN: families AND Serialized_Item__c = null';
        System.debug('getOtherFamilyProductItems QUERY: ' + query);
        
        return Database.query(query);
    }

    // This method queries for ProductItems different from the ones of idsNotToMatch, but with same LocationId and Product2Id (and SerializedItem = null)

    public static List<ProductItem> getOtherSingleProductItems(List<String> queryFields, List<Id> idsNotToMatch, List<Id> locationIds, List<String> productCodes) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ProductItem WHERE Id NOT IN: idsNotToMatch AND LocationId IN: locationIds AND Product_Code__c IN: productCodes AND Serialized_Item__c = null';
        System.debug('getOtherSingleProductItems QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<ProductItem> getProductItemsFromSerialNumbers(List<String> queryFields, List<String> serialNumbers) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ProductItem WHERE SerialNumber != null AND SerialNumber IN: serialNumbers';
        System.debug('getProductItemsFromSerialNumbers QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<ProductItem> getProductItemsWithSameRelatedItem(List<String> queryFields, List<String> relatedItemIds, List<String> toExcludeIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ProductItem WHERE RelatedProductItem__c IN: relatedItemIds AND Id NOT IN: toExcludeIds';
        System.debug('getProductItemsWithSameRelatedItem QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<ProductItem> getProductItemsFromLocationIds(List<String> queryFields, List<Id> locationIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ProductItem WHERE LocationId IN: locationIds';
        System.debug('getProductItemsFromIds QUERY: ' + query);
        
        return Database.query(query);
    }
}