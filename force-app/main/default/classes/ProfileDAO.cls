public without sharing class ProfileDAO {

    public static List<Profile> getProfilesWithoutEmailManagFromNames(List<String> queryFields, List<String> names) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Profile WHERE Name IN: names AND PermissionsEmailTemplateManagement = false';
        System.debug('getProfilesWithoutEmailManagFromNames QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Profile> getProfilesFromNames(List<String> queryFields, List<String> names) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Profile WHERE Name IN: names';
        
        return Database.query(query);
    }

    public static Profile getProfileById(List<String> queryFields, String profileId){
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Profile WHERE Id = :profileId';
        
        return Database.query(query);
    }

}