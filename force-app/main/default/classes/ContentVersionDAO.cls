public without sharing class ContentVersionDAO {

    public static List<ContentVersion> getVersionsFromExternalId(List<String> queryFields, List<String> externalIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        	query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ContentVersion WHERE External_Id__c IN: externalIds';
        System.debug('getPrescriptionsFromIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<ContentVersion> getLatestContentVersionsFromContentDocuments(List<String> queryFields, List<String> contentDocumentIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
        	query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ContentVersion WHERE ContentDocumentId IN: contentDocumentIds AND IsLatest = true';
        System.debug('getLatestContentVersionsFromContentDocuments QUERY: ' + query);
        
        return Database.query(query);
    }
}