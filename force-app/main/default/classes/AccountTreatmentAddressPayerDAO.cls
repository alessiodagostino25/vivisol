public with sharing class AccountTreatmentAddressPayerDAO {
    
    public static List<Account_Treatment_Address_Payer__c> getATAPsFromLocationAndAT(List<String> queryFields, List<Id> ATIds, List<Id> locationIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Treatment_Address_Payer__c WHERE Account_Treatment_Address__r.Location__c IN: locationIds AND Account_Treatment__c IN: ATIds';
        System.debug('getATAPsFromLocationAndAT QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Account_Treatment_Address_Payer__c> getATAPsFromIds(List<String> queryFields, List<Id> relatedIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Treatment_Address_Payer__c WHERE Id IN: relatedIds';
        System.debug('getATAPsFromIds QUERY: ' + query);
        
        return Database.query(query);
    }

    public static List<Account_Treatment_Address_Payer__c> getATAPsFromAddressAndPayer(List<String> queryFields, List<String> addressIds, List<String> payerIds) {
        String query = 'SELECT ';
        for(Integer i = 0; i < queryFields.size(); i++) {
            query += queryFields[i] + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account_Treatment_Address_Payer__c WHERE Account_Treatment_Address__c IN: addressIds AND Payer__c IN: payerIds';
        System.debug('getATAPsFromAddressAndPayer QUERY: ' + query);
        
        return Database.query(query);
    }
}