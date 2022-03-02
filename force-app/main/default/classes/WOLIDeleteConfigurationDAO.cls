public without sharing class WOLIDeleteConfigurationDAO {

    public static List<WOLI_Delete_Configuration__mdt> getAllWOLIDeleteConfigs() {
        String query = 'SELECT Field_API_Name__c, Field_Value__c ';

        query += ' FROM WOLI_Delete_Configuration__mdt ';
        System.debug('getAssignedResourcesFromSAIds QUERY: ' + query);
        
        return Database.query(query);
    }

}