public with sharing class EndOfMonthHeaderDAO {
    public static List<EndOfMonthHeader__c> getEOMHsFromExternalIds(List<String> queryFields, List<String> externalIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM EndOfMonthHeader__c WHERE ext_order_id__c IN: externalIds';
        System.debug('getEOMHsFromExternalIds QUERY: ' + query);
        
        return Database.query(query);
    }
}