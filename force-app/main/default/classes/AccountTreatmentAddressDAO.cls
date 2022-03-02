public with sharing class AccountTreatmentAddressDAO {
    
    public static List<Account_Treatment_Address__c> getATAsFromAccountTreatment(List<String> queryFields, Id accountTreatmentId) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Treatment_Address__c WHERE Account_Treatment__c =: accountTreatmentId';
        System.debug('getATAsFromAccountTreatment QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Account_Treatment_Address__c> getATAsFromAccountTreatments(List<String> queryFields, List<Id> accountTreatmentIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Treatment_Address__c WHERE Account_Treatment__c IN: accountTreatmentIds';
        System.debug('getATAsFromAccountTreatments QUERY: ' + query);
        
        return Database.query(query);
    }

    public static Account_Treatment_Address__c getATAFromId(List<String> queryFields, Id relatedId) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Treatment_Address__c WHERE Id =: relatedId';
        System.debug('getATAFromId QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Account_Treatment_Address__c> getDefaultATAFromATs(List<String> queryFields, List<Id> accountTreatmentIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Treatment_Address__c WHERE Account_Treatment__c IN: accountTreatmentIds AND Default__c = true';
        System.debug('getDefaultATAFromATs QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Account_Treatment_Address__c> getTemporaryATAsFromATs(List<String> queryFields, List<Id> accountTreatmentIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Treatment_Address__c WHERE Account_Treatment__c IN: accountTreatmentIds AND Default__c = false ' +
        'AND End_Date__c != null AND End_Date__c > TODAY AND Start_Date__c != null';
        System.debug('getTemporaryATAsFromATs QUERY: ' + query);
        
        return Database.query(query);
    }
}