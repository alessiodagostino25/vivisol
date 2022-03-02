public without sharing class ContentDocumentLinkDAO {
    
    public static List<ContentDocumentLink> getCDLsFromEntityIds(List<String> queryFields, List<String> entityIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        	query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ContentDocumentLink WHERE LinkedEntityId IN: entityIds';
        System.debug('getCDLsFromEntityIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<ContentDocumentLink> getCDLsFromCDIds(List<String> queryFields, List<String> contentDocumentIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        	query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ContentDocumentLink WHERE ContentDocumentId IN: contentDocumentIds';
        System.debug('getCDLsFromCDIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<ContentDocumentLink> getCDLsFromIds(List<String> queryFields, List<String> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        	query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ContentDocumentLink WHERE Id IN: relatedIds';
        System.debug('getCDLsFromIds QUERY: ' + query);
        
        return Database.query(query);
    }
}