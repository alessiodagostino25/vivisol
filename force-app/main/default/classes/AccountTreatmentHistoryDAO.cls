public with sharing class AccountTreatmentHistoryDAO {
    
    public static List<Account_Treatment_History__c> getATHsFromIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Treatment_History__c WHERE Id IN: relatedIds';
        System.debug('getATHsFromIds QUERY: ' + query);
        return Database.query(query);
    }
}