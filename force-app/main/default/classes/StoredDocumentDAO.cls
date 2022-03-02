public without sharing class StoredDocumentDAO {
    
    public static List<Stored_Document__c> getStoredDocumentsFromIds(List<String> queryFields, List<String> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        	query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Stored_Document__c WHERE Id IN: relatedIds';
        System.debug('getStoredDocumentsFromIds QUERY: ' + query);
        
        return Database.query(query);
    }
}