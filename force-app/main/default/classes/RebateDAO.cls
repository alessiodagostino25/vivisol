public with sharing class RebateDAO {
    public static List<Rebate__c> getRebatesFromExternalIds(List<String> queryFields, List<String> externalIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Rebate__c WHERE id_rebate__c IN: externalIds';
        System.debug('getRebatesFromExternalIds QUERY: ' + query);
        
        return Database.query(query);
    }
}