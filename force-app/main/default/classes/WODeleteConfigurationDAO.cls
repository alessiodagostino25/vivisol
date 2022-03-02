public class WODeleteConfigurationDAO {
    public static List<WO_Delete_Configuration__mdt> getAllWODeleteConfigs() {
        String query = 'SELECT Field_API_Name__c, Field_Value__c ';
        query += ' FROM WO_Delete_Configuration__mdt ';
        System.debug('getAllWODeleteConfigs QUERY: ' + query);
        return Database.query(query);
    }
}