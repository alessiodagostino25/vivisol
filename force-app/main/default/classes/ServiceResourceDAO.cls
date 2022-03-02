public with sharing class ServiceResourceDAO {
    
    public static List<ServiceResource> getServiceResourcesFromIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ServiceResource WHERE Id IN: relatedIds';
        System.debug('getServiceResourcesFromIds QUERY: ' + query);
        
        return Database.query(query);
    }
    public static List<ServiceResource> getServiceResourcesFromlocationIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ServiceResource WHERE LocationId  IN: relatedIds';
        System.debug('getServiceResourcesFromlocationIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<ServiceResource> getServiceResourcesFromNextLocationIds(List<String> queryFields, List<Id> nextLocationIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ServiceResource WHERE NextLocation__c IN: nextLocationIds';
        System.debug('getServiceResourcesFromNextLocationIds QUERY: ' + query);
        
        return Database.query(query);
    }
}