public with sharing class AccountCompanyDAO {

    public static List<Account_Company__c> getAccountcompanyFromRecordIds(List<String> queryFields, List<String> recordIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Company__c WHERE External_Id__c IN: recordIds';
        System.debug('getAccountcompanyFromRecordIds QUERY: ' + query);
        return Database.query(query);
    }
    
    public static List<Account_Company__c> getAccountcompanyFromIds(List<String> queryFields, List<Id> recordIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Company__c WHERE Id IN: recordIds';
        System.debug('getAccountcompanyFromIds QUERY: ' + query);
        return Database.query(query);
    }

}