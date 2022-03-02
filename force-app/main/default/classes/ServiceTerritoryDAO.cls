public with sharing class ServiceTerritoryDAO {
    
    public static List<ServiceTerritory> getServiceTerritoriesFromIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ServiceTerritory WHERE Id IN: relatedIds';
        System.debug('getServiceTerritoriesFromIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<ServiceTerritory> getServiceTerritoriesFromCodes(List<String> queryFields, List<String> codes) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ServiceTerritory WHERE Service_Territory_Code__c IN: codes';
        System.debug('getServiceTerritoriesFromCodes QUERY: ' + query);
        
        return Database.query(query);
    }
}