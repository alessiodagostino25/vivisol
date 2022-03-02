public with sharing class AssignedResourceDAO {
    
    public static List<AssignedResource> getAssignedResourcesFromSAIds(List<String> queryFields, List<Id> serviceAppointmentIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM AssignedResource WHERE ServiceAppointmentId IN: serviceAppointmentIds';
        System.debug('getAssignedResourcesFromSAIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<AssignedResource> getAssignedResourcesFromIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM AssignedResource WHERE Id IN: relatedIds';
        System.debug('getAssignedResourcesFromIds QUERY: ' + query);
        
        return Database.query(query);
    }
}